({          
	DEBUG: 'SelectService: ',
	
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {            
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);
        component.set('v.locationId', '');
        component.set('v.fieldList', []);
        component.set('v.recordList', []);        
        component.set('v.recordListFull', []);        
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');

        var wizObj = component.get('v.wizardprop');
        if (wizObj.location.Id) {
	    	if (!component.get('v.isInitialised')) {
	    		this.initialiseDisplayedFields(component);
	    	}
	    	
	        // get the list of all available services from the server        
	        this.getListOfAvailServices(component);
        }
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {  
        
        // add the selected services to the wizardprop
        this.addSelectedServices(component);
        
        var isAuRegion = component.get('v.isAuRegion');
        // check that a service has been selected      
        var wizObj = component.get('v.wizardprop');
        if (isAuRegion == false && (wizObj.selectedServices == undefined || wizObj.selectedServices.length <= 0)) {
        	this.showNotification(component, [$A.get('$Label.c.CuAp_ServiceTypeError')], 'error');
            return false;
        }
        if(isAuRegion == true){
            var errorFlag = false;
            for (var j = 0; j < component.get('v.recordListNew').length; j++) {
                
                var rec = component.get('v.recordListNew')[j];
                var startDate = rec.objectMap[this.setPrefixedString('ServiceItem__c')][this.setPrefixedString('StartDate__c')];
                if(wizObj.selectedOccType == $A.get('$Label.c.CuAp_AUMoveInOccType')){ // Tenant
                    if(startDate < wizObj.moveInDate){
                        errorFlag = true;
                    }
                }
                else{ // Owner\Landlord
                    if(startDate < component.get('v.serviceItemStartDate')){
                        errorFlag = true;
                    }
                }
                if(errorFlag){
                    this.showNotification(component, [$A.get('$Label.c.CuAp_ServiceStartDateError')], 'error');
                    return false;
                }
            }
        }
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
    /* END: REQUIRED BY FRAMEWORK */
    
    /* PAGE SPECIFIC METHODS */    
    // initialise all the displayed fields
	initialiseDisplayedFields: function(component) {

        // Retrieve list of fields and properties for the suppression contracts
        this.callServer(component, 'c.retrieveSerAvailServiceFieldPropDetails',
                        function(response) {  
                            console.log('response-- '+ JSON.stringify(response));
                            component.set('v.fieldList', response);    
                        },  
                        null); 
         component.set('v.isInitialised', true);
    },
    
    // gets the list of all services available at a location from the server    
    getListOfAvailServices: function(component) {
        
        var wizObj = component.get('v.wizardprop');        
        var locationId = component.get('v.locationId');
        // if the location has changed
        if (locationId != wizObj.location.Id) {
        	component.set('v.locationId', wizObj.location.Id);        	
	        let params = {'sLocationId': component.get('v.locationId'),
                          'moveInDate': wizObj.moveInDate,
                          'occType': wizObj.selectedOccType};
	        
	        // Retrieve list of avail services for the location
	        this.callServer(component, 'c.fetchListOfAvailServices',
	                        function(response) {                              
                                
                                console.log('response wrapper--** '+ JSON.stringify(response));
                                component.set('v.isAuRegion', response.auRegion);
                                
                                var wizObjNew = component.get('v.wizardprop');
                                wizObjNew.isAuRegion = response.auRegion;
                                component.set('v.wizardprop', wizObjNew);
                                
	                            // save the list of all records including duplicates
	                            var recordListFull = response.availServiceListToBeReturn;
	                            component.set('v.recordListFull', recordListFull);
	
	                            // build a list to display (with the duplicates removed)
	                            var showRecords = [];
	                            var recordList = [];
	                            var serviceItemStartDate;
	                            if (recordListFull != undefined || recordListFull != '') {
	                                for (var i = 0; i < recordListFull.length; i++) {                                        
                                        if (showRecords.indexOf(recordListFull[i].objectMap[this.setPrefixedString('AvailableService__c')][this.setPrefixedString('ServiceType__c')]) == -1) {
                                            showRecords.push(recordListFull[i].objectMap[this.setPrefixedString('AvailableService__c')][this.setPrefixedString('ServiceType__c')]);
                                            recordList.push(recordListFull[i]);
                                        }
                                        if(component.get('v.isAuRegion') == true)
                                            serviceItemStartDate = recordListFull[i].objectMap[this.setPrefixedString('ServiceItem__c')][this.setPrefixedString('StartDate__c')];
                                    }
                                }
                                component.set('v.recordList', recordList);        
                                if(component.get('v.isAuRegion') == true)
                                    component.set('v.serviceItemStartDate', serviceItemStartDate);        
                            },                         
	                        params);
        }
        
        
	},
    
    // adds the selected services to the wizardprop 
    addSelectedServices: function(component) {
        
        var wizObj = component.get('v.wizardprop');
        var recordList = component.get('v.recordList');
        var recordListFull = component.get('v.recordListFull');
        wizObj.selectedServices = [];
        var recordListNew = [];
        
        if (recordList) {
            for (var i = 0; i < recordList.length; i++) {
                
                if (recordList[i].isSelected) {
                    
                    for (var j = 0; j < recordListFull.length; j++) {
                        
                        if (recordListFull[j].objectMap[this.setPrefixedString('AvailableService__c')][this.setPrefixedString('ServiceType__c')] == recordList[i].objectMap[this.setPrefixedString('AvailableService__c')][this.setPrefixedString('ServiceType__c')]) {
                            
                            var rec = {sobjectType : this.setPrefixedString('AvailableService__c'),
                                       Id: recordListFull[j].objectMap[this.setPrefixedString('AvailableService__c')]['Id'],
                                       [this.setPrefixedString('ServiceType__c')]: recordListFull[j].objectMap[this.setPrefixedString('AvailableService__c')][this.setPrefixedString('ServiceType__c')],
                                       [this.setPrefixedString('SupplyPoint__c')]: recordListFull[j].objectMap[this.setPrefixedString('AvailableService__c')][this.setPrefixedString('SupplyPoint__c')]
                                      };
                            wizObj.selectedServices.push(rec);
                            recordListNew.push(recordListFull[j]);
                        }
                    }                    
                }
            }
            var isAuRegion = component.get('v.isAuRegion');
            if(isAuRegion == true){
                component.set('v.recordListNew', recordListNew);
                //Need to loop through all of the entries in the list and then set the sObject types so that the 
                //server can reserialise the records
                for(var i=0; i < recordListNew.length; i++){
                    var recEntry = recordListNew[i];
                    var availServEntry = recEntry.objectMap[this.setPrefixedString('AvailableService__c')];    
                    var servTypeEntry = recEntry.objectMap[this.setPrefixedString('ServiceType__c')];
                    var serItemEntry = recEntry.objectMap[this.setPrefixedString('ServiceItem__c')];
                    
                    let availServAtributes =  {
                        "type": this.setPrefixedString('AvailableService__c'),
                    };
                    let servTypeAtributes =  {
                        "type": this.setPrefixedString('ServiceType__c'),
                    };
                    let serItemAtributes =  {
                        "type": this.setPrefixedString('ServiceItem__c'),
                    };
                    availServEntry.attributes=availServAtributes;
                    servTypeEntry.attributes=servTypeAtributes;
                    serItemEntry.attributes=serItemAtributes;
                }
                wizObj.jsonString = JSON.stringify(recordListNew);
            }
        }
        component.set('v.wizardprop', wizObj);
   },
})