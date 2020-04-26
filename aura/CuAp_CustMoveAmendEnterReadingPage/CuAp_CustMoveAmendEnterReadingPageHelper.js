({          
    DEBUG: 'Amend Move Reading: ',
    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    reInitialise: function(component, event, helper) {            
        component.set('v.locationId', '');
        component.set('v.SPFieldList', []);
        component.set('v.SPRecordList', []);
        component.set('v.recordListFull', []);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {        
        var wizObj = component.get('v.wizardprop');
        
        console.log('wizObj******'+ JSON.stringify(wizObj));
        if(wizObj.combinedSPLists == null){
            component.set("v.showSecond",false);
            this.initialiseDisplayedFields(component, event, helper);        
            this.getListOfSupplyPointAndDevice(component, event, helper); 
            this.getallDeviceReading(component, event, helper);  //AT-5276
        }
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {   
        var isSuccess = this.validateSupplyPointFields(component, event, helper);
        if(isSuccess)
            return true;
        else
            return false;
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
    
    initialiseDisplayedFields: function(component, event, helper) {        
        // Retrieve list of fields and properties for the suppression contracts
        this.callServer(component, 'c.retrieveReadingPropDetails',
                        function(response) {   
                            component.set('v.SPFieldList', response);    
                        },  
                        null); 
    },
    
    // gets the list of all services available at a location from the server    
    getListOfSupplyPointAndDevice: function(component, event, helper) {
        
        var wizObj = component.get('v.wizardprop');  
        
        if(wizObj.locationAddress)
            component.set('v.locationName',wizObj.locationAddress);
        
        if(wizObj.moveInDate)
            component.set('v.moveInDate',wizObj.moveInDate);
        else
            component.set('v.moveInDate',wizObj.moveOutDate);
        
        if(wizObj.locationId != null){
            let params = {
                'locationId': wizObj.locationId
            };
            
            // Retrieve list of Supply Point and Device Records for the location
            this.callServer(component, 'c.getSupplyPointAndDeviceRecords',
                            function(response) {   
                                component.set('v.SPRecordList',response);                               
                            },                         
                            params);
        }        
    },
    
    getallDeviceReading: function(component, event, helper) {        
        var wizObj = component.get('v.wizardprop');                  
        if(wizObj.locationId != null){
            let params = {
                'locationId': wizObj.locationId
            };
            
            // Retrieve all Device Reading Records on the location
            this.callServer(component, 'c.getallDeviceReading',
                            function(response) {   
                              	component.set('v.mapOfDeviceId2Reading',response);                                
                            },                         
                            params);
        }        
    },
    
    
    // Validate the Supply Point Fields
    validateSupplyPointFields: function(component, event, helper) {
        var SPRecordList = component.get('v.SPRecordList'); 
        var wizObj = component.get('v.wizardprop');
        var rec;       
        var newReadingsLists = [];
       
        for(var iCount=0;iCount<SPRecordList.length;iCount++){
            var rowNo = iCount+1;
            if(!SPRecordList[iCount].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')]){
                this.showNotification(component, ['Row ' + rowNo + ' ' + $A.get("$Label.c.CuAp_EnterActualDeviceReading")],'error');
                return false;    
            }
            if(!SPRecordList[iCount].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingMethod__c')]){
                this.showNotification(component, ['Row ' + rowNo + ' ' + $A.get("$Label.c.CuAp_EnterReadingMethod")],'error');
                return false;                     
            } 
            
            //AT-5276
            var deviceMap = component.get('v.mapOfDeviceId2Reading');            
            var readingList = deviceMap[SPRecordList[iCount].uniqueId];            
            
            for(var listCount=0;listCount<readingList.length;listCount++){                
                if( readingList[listCount][this.setPrefixedString('ReadingDate__c')] > component.get('v.moveInDate') &&
                    parseInt(readingList[listCount][this.setPrefixedString('ActualDeviceReading__c')]) < parseInt(SPRecordList[iCount].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')])){
                   	this.showNotification(component, ['Row ' + rowNo + ' ' + $A.get("$Label.c.CuAp_AmendMoveInReadingInvalid")],'error');
                	return false;
                }
                else if(readingList[listCount][this.setPrefixedString('ReadingDate__c')] < component.get('v.moveInDate')){
                    if(parseInt(readingList[listCount][this.setPrefixedString('ActualDeviceReading__c')]) > parseInt(SPRecordList[iCount].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')])){
                        this.showNotification(component, ['Row ' + rowNo + ' ' + $A.get("$Label.c.CuAp_MoveInReadingLess")],'error');
                        return false;
                    }
                break;
                }
            }
            rec = {sobjectType: this.setPrefixedString('Reading__c'), 
                   [this.setPrefixedString('Device__c')]				: SPRecordList[iCount].objectMap[this.setPrefixedString('Device__c')]['Id'],
                   [this.setPrefixedString('ActualDeviceReading__c')]	: SPRecordList[iCount].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')],
                   [this.setPrefixedString('ReadingMethod__c')]			: SPRecordList[iCount].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingMethod__c')]}
            newReadingsLists.push(rec);           
        }
        wizObj.newReadingsLists = newReadingsLists;
       // wizObj.newVoidStartReadingsLists = newVoidStartReadingsLists;   //AT-5418
        
        return true;
    },       
  
    
    // handle Estimate Button
    handleRowButtonPressEvent: function(component, event) {
        this.clearNotification(component);
        if (event.getParam('ButtonId') == 'Estimate') {
            var sRowId = event.getParam('RowId');
            var row = 0;
            var readingEstimate = component.find('readingEstimate');
            var SPRecordList = component.get('v.SPRecordList');
            var wizObj = component.get('v.wizardprop');
            for (var i = 0; i < SPRecordList.length; i++) {
                row = i+1;
                if (SPRecordList[i].uniqueId == sRowId) {
                    var deviceId = SPRecordList[i].objectMap[this.setPrefixedString('Device__c')]['Id'];
                    var readingDate = wizObj.moveInDate;   
                    var helper = this;
                    readingEstimate.getEstimate(deviceId, readingDate, 
                                                function(response) {
                                                    if (response && response[helper.setPrefixedString('ActualDeviceReading__c')]) {
                                                        SPRecordList[i].objectMap[helper.setPrefixedString('Reading__c')][helper.setPrefixedString('ActualDeviceReading__c')] = response[helper.setPrefixedString('ActualDeviceReading__c')];
                                                        SPRecordList[i].objectMap[helper.setPrefixedString('Reading__c')][helper.setPrefixedString('ReadingMethod__c')] = response[helper.setPrefixedString('ReadingMethod__c')];
                                                    } else {
                                                        helper.showNotification(component, [$A.get('$Label.c.CuAp_ExceptionADU')],'warn');
                                                        return false;
                                                    }
                                                    component.set('v.SPRecordList', []);
                                                    component.set('v.SPRecordList', SPRecordList);
                                                });
                    break;
                }
            }
        }
    },
    
    // This function will display the "Allocation to Bill Items" records to the lower table on the basis of discount record
    handleRowClickEvent: function(component, event, helper) {
        
        var sRowId = event.getParam('RowId');
        var tableName = event.getParam('Source');
        
        if(tableName == 'SupplyPoint'){
            component.set("v.showSecond",false);
            
            //Retrieve list of fields and properties for the suppression contracts            
            helper.callServer(component,'c.retrieveReadingsfieldList',
                              function(response){
                                  component.set('v.ReadingFieldList', response);   
                              },      				
                              null);
            
            let params ={
                "deviceId": sRowId
            };
            
            helper.callServer(component,'c.retrieveReadingsRecordList',
                              function(response){
                                  component.set('v.ReadingRecordList', response);   
                              },      				
                              params);            
            component.set("v.showSecond",true);
        }
    },
    
    // add days to input date
    addDays: function (date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    },
    
    // format a date as yyyy-mm-dd
    formatDate: function(date) {
        var dd = date.getDate();
		var mm = date.getMonth() + 1;
        var yyyy = date.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        } 
        if (mm < 10) {
            mm = '0' + mm;
        } 
        return yyyy + '-' + mm + '-' + dd;        
    }
   
        
})