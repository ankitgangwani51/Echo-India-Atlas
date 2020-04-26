({    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start a fresh
    reInitialise: function(component) {
    	console.log('SelectDefaultBundle: reInitialise');
    	component.set('v.bundleFldList', []);
    	component.set('v.bundleRecordsMap', []);
        component.set('v.availableServiceRecordsMap', []);
    	component.set('v.availableBundleRecordsMap', {});		
        component.set('v.availableBundleFinalRecordMap', {});
        component.set('v.isInitialised', false);
        component.set("v.tableList",{});
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {          
        var wizardType = component.get('v.wizardprop.wizardType'); 
        var bundleMap = [];
        var availableBundleMap = new Map();
        var availableServiceMap = new Map();
        var id;
        
        if(wizardType == 'NewDevice'){
            // Set the supply point Id in parameters
            id = component.get('v.wizardprop.selectedSupplyPointAdded.Id');;
        } else{
            // Set the device Id in parameters
            id = component.get('v.wizardprop.supplyPointDevice')[this.setPrefixedString('Device__c')];
        }
        
        let params = {
            "recordId" : id,
            "wizardType" : wizardType
        };

        if (!component.get('v.isInitialised')) {
            
            // Retrieve list of fields properties for the bundles
            this.callServer(component,'c.RetrieveBundleFieldPropDetails',
                            function(response){
                                component.set("v.bundleFldList", response);
                            },
                            null); 
            
            // Retrieve list of fields vales for the bundle
            this.callServer(component,'c.RetrieveBundleRecords',
                            function(response){
                                var bundleMap = component.get("v.bundleRecordsMap");
                                for (var key in response) {             
                                    //creating a map of key and value(list of combined record) in a list to display the table on the screen
                                    bundleMap.push({value:response[key], key:key});
                                }
                                component.set("v.bundleRecordsMap", bundleMap);
                            },
                            params);
            
            // Retrieve list of fields vales for the Available Service   VS  AT-2644
            this.callServer(component,'c.RetrieveAvailableServiceRecords',
                            function(response){
                                for (var key in response) {             
                                    availableServiceMap[key] = response[key];
                                }
                                component.set("v.availableServiceRecordsMap", availableServiceMap);
                            },
                            params);
            
            // Retrieve list of fields values for the available bundle
            this.callServer(component,'c.RetrvAvalbleBndlRecords',
                            function(response){    
                                for(var key in response){
                                    availableBundleMap[key] = response[key];
                                }
                                component.set("v.availableBundleRecordsMap", availableBundleMap);
                                console.log('availableBundleRecordsMap' +JSON.stringify(component.get("v.availableBundleRecordsMap")));
                            },
                            params);
            component.set('v.isInitialised', true);
        }
    },
    
    validateOnNext: function(component) {
        // do all completion validation here
        // validation to check whehter the device is searched or not
        var bundleRecordList = component.get("v.bundleRecordsMap");
        var availableBundlesRecord = [];
        var wizObj = component.get("v.wizardprop");
        console.log('default bundle validateOnNext');
        //validating over the bundle list to identify that atleast one record should be selected from each table
        for(var i=0;i<bundleRecordList.length;i++){
            var recordSelected;
            for(var j=0; j<bundleRecordList[i].value.length; j++){
                if(bundleRecordList[i].value[j].isSelected){
                    recordSelected = true;
                    break;
                } else{
                    recordSelected = false;    
                }
            }
            
            //showing error if atleast one record is not selected from any table 
            if(!recordSelected){
                this.showNotification(component, [$A.get("$Label.c.LoAp_SelectDefaultBundleMstSlctBndl")], 'error');
                return;
            }     
        }
        
        //if records are selected from every table than setting the available bundle record in the wizardprop
        var availableBundlesRecords = component.get("v.availableBundleFinalRecordMap");
        for(var key in availableBundlesRecords){
            var record = availableBundlesRecords[key];
            availableBundlesRecord.push(record);
        }
        wizObj.availabeBundle = availableBundlesRecord;
        component.set("v.wizardprop", wizObj);
        
        return true;
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
    	component.find('notifier').showNotification(message, type);
    },

    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
    	component.find('notifier').clearNotification();
    },
    
    // get the clicked rowid i.e. bundle id in this case
    // by using the bundle id fetch the service type id and then find the available record related to that service type id.
    // Create a record of the available bundle type having bundle id as selected
    handleRowClickEvent: function(component, event, helper) {
        
        var sRowId = event.getParam('RowId');        
        var availableBundles = component.get("v.availableBundleRecordsMap");
        var serviceRecords = component.get("v.availableBundleFinalRecordMap"); 
        var bundleRecordList = component.get("v.bundleRecordsMap");
        var availableServiceList    = component.get("v.availableServiceRecordsMap");    // VS  AT-2644
        var tableName = component.get("v.tableList");
        var selectedKey;
        
        //MT - AT-2217 29-03-2018 handling the multiselect functionality and also removing the available bundle record
        //from availableBundleFinalRecordMap
        if(tableName[event.getParam('Source')]){
            for(var i=0;i<bundleRecordList.length;i++){
                if(bundleRecordList[i].key == tableName[event.getParam('Source')]){
                    for(var j=0; j<bundleRecordList[i].value.length; j++){
                        if(bundleRecordList[i].value[j].uniqueId != sRowId){
                            bundleRecordList[i].value[j].isSelected = false;
                            delete serviceRecords[bundleRecordList[i].value[j].uniqueId];
                        }
                    }
                }
            }
        }
        //iterating on the bundle map if any record is selected or unselected
        for(var i=0;i<bundleRecordList.length;i++){
            for(var j=0; j<bundleRecordList[i].value.length; j++){
                if(bundleRecordList[i].value[j].uniqueId == sRowId){
                    if(bundleRecordList[i].value[j].isSelected){
                        //if the service type of selected record from the bundle map is present in the available bundle map 
                        //than creating a sobject of availabe bundle with the bundle id of selected record  
                        //
                        if(availableBundles[bundleRecordList[i].key]){   
                            tableName[event.getParam('Source')] = bundleRecordList[i].key; //MT - AT-2217 29-03-2018 adding table name
                            var record = {sobjectType : this.setPrefixedString('AvailabeBundle__c'),
                                          Id : availableBundles[bundleRecordList[i].key].Id,
                                          [this.setPrefixedString('AvailableService__c')] : availableBundles[bundleRecordList[i].key][this.setPrefixedString('AvailableService__c')],
                                          [this.setPrefixedString('Bundle__c')] : sRowId};
                            serviceRecords[sRowId] = record;
                            component.set("v.availableBundleFinalRecordMap", serviceRecords);
                        } else {    //VS  #AT-2644
                            if (availableServiceList[bundleRecordList[i].key]) {     
                                tableName[event.getParam('Source')] = bundleRecordList[i].key; //MT - AT-2217 29-03-2018 adding table name
                                var record = {sobjectType : this.setPrefixedString('AvailabeBundle__c'),
                                              [this.setPrefixedString('AvailableService__c')] : availableServiceList[bundleRecordList[i].key].Id,
                                              [this.setPrefixedString('Default__c')] : true,
                                              [this.setPrefixedString('Bundle__c')] : sRowId};
                                serviceRecords[sRowId] = record;
                                component.set("v.availableBundleFinalRecordMap", serviceRecords);
                            }
                        }
                    } else{
                        //if unselecting the record then removing the sboject of availabe bundle with the bundle id of selected record
                        if(serviceRecords[sRowId]){
                            delete serviceRecords[sRowId];
                        }
                        component.set("v.availableBundleFinalRecordMap", serviceRecords); 
                    } 
                    break;
                }    
            }
        }  
        
        component.set("v.tableList",tableName);
        component.set("v.bundleRecordsMap",bundleRecordList);
    }
})