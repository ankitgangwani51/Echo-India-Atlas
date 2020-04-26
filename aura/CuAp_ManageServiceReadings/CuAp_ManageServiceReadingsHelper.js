({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) { 
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        this.doInit(component, event, helper);
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
        var isSuccess = this.validateSupplyPointReadings(component, event, helper);
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
    
    // doInit function: displays the service type list and renewals parameters
    doInit: function(component, event, helper){
        debugger;
        var wizObj = component.get('v.wizardprop');
        
        if(wizObj != null){  
            //Retrieve list of fields and properties for the Service and Reading Object
            helper.callServer(component,'c.fieldProp',
                              function(response){
                                  component.set('v.fieldList', response);   
                              },      				
                              null);
            
            if(wizObj.serviceTransfers){
                let params1 = {
                    "serviceTransfers": wizObj.serviceTransfers,
                    "effectiveDate" : wizObj.effectiveDate
                };
                helper.callServer(component,'c.retrieveSPAndReadingByContract',
                                  function(response){    
                                      component.set('v.recordList', response);                                  
                                  },      				
                                  params1); 
            }
            else if(wizObj.availableServiceTransfers){
                let params2 = {
                    "availableServiceTransfers": wizObj.availableServiceTransfers,
                    "effectiveDate" : wizObj.effectiveDate
                };
                
                helper.callServer(component,'c.retrieveSPAndReadingBySP',
                                  function(response){    
                                      component.set('v.recordList', response);                                  
                                  },      				
                                  params2); 
            }
            else {
                let params3 = {                    
                    "serviceTransfers": wizObj.removedServices,
                    "effectiveDate" : wizObj.effectiveDate
                };
                
                helper.callServer(component,'c.retrieveSPAndReadingByContract',
                                  function(response){    
                                      component.set('v.recordList', response);                                  
                                  },      				
                                  params3); 
            }
        }
    },
    
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
    },
    
    validateSupplyPointReadings: function(component, event, helper){
        this.clearNotification(component);
        var row = 0;
        var newReading;
        var oldReading;
        var addDate = new Date();
        var newRecordList = [];
        var wizObj = component.get('v.wizardprop');
        if(wizObj != null){
            var recordList = component.get('v.recordList');
            for(var i=0;i<recordList.length;i++){
                row = i+1;
                if(recordList[i].transformFieldMap[this.setPrefixedString('Device__c')]['device']){
                    if(!recordList[i].objectMap['Reading']){
                        this.showNotification(component, ['Row: ' + row + ' ' + $A.get("$Label.c.CuAp_NoReadingExist")],'error');
                        return false;
                    }
                }
                if(!recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingSource__c')]){
                    this.showNotification(component, ['Row: ' + row + ' ' + $A.get("$Label.c.CuAp_EnterReadingSource")],'error');
                    return false;
                }
                
                if(!recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingMethod__c')]){
                    this.showNotification(component, ['Row: ' + row + ' ' + $A.get("$Label.c.CuAp_EnterReadingMethod")],'error');
                    return false;
                }
                
                if(!recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')]){
                    this.showNotification(component, ['Row: ' + row + ' ' + $A.get("$Label.c.CuAp_EnterActualDeviceReading")],'error');
                    return false;
                } 
                
                var newReading = recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')].toString();
                var trippedFlag = recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('Tripped__c')];  // AT-3422 core 8b
                
                if(newReading.length > recordList[i].transformFieldMap['Device']['deviceDigit']){
                    this.showNotification(component, ['Row: ' + row + ' ' + $A.get('$Label.c.CuAp_ValidateDigits') + recordList[i].transformFieldMap['Device']['deviceDigit']],'error');
                    return false;
                } 
                
                if(recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')] < 
                  recordList[i].objectMap['Reading'][this.setPrefixedString('Reading__c')]  && !trippedFlag){         // AT-3422 core 8b
                    this.showNotification(component, ['Row: ' + row + ' ' + $A.get("$Label.c.CuAp_ReadingCannotBeLessThanPrevious")],'error');
                    return false;
                }                 
                
                if(wizObj.serviceTransfers || wizObj.availableServiceTransfers){
                    newReading = {sobjectType: this.setPrefixedString('Reading__c'), 
                                  [this.setPrefixedString('Device__c')]					: recordList[i].transformFieldMap[this.setPrefixedString('Device__c')]['device'],
                                  [this.setPrefixedString('ReadingMethod__c')]			: recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingMethod__c')],
                                  [this.setPrefixedString('ReadingSource__c')]			: recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingSource__c')],
                                  [this.setPrefixedString('ActualDeviceReading__c')]	: recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')],
                                  [this.setPrefixedString('ReadingType__c')]			: $A.get("$Label.c.CuAp_ServiceTransferStart"),
                                  [this.setPrefixedString('ReadingDate__c')]			: wizObj.effectiveDate                                  
                                 }                
                    newRecordList.push(newReading);
                }
                
                var addDays;
                if(wizObj.serviceTransfers || wizObj.availableServiceTransfers)
                    addDays = -1;             
                else
                    addDays = 0;
                
                oldReading = {sobjectType: this.setPrefixedString('Reading__c'), 
                              [this.setPrefixedString('Device__c')]					: recordList[i].transformFieldMap[this.setPrefixedString('Device__c')]['device'],
                              [this.setPrefixedString('ReadingMethod__c')]			: recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingMethod__c')],
                              [this.setPrefixedString('ReadingSource__c')]			: recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingSource__c')],
                              [this.setPrefixedString('ActualDeviceReading__c')]	: recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')],
                              [this.setPrefixedString('ReadingType__c')]			: $A.get("$Label.c.CuAp_ServiceTransferEnd"),
                              [this.setPrefixedString('ReadingDate__c')]			: this.formatDate(this.addDays(wizObj.effectiveDate,addDays)),
                              [this.setPrefixedString('Tripped__c')]				: recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('Tripped__c')]		// AT-3422 core 8b
                             }                
                newRecordList.push(oldReading);                
            }      
            wizObj.newReadings = newRecordList;           
        }
        return true;
    },
    
    // handle Estimate Button
    handleRowButtonPressEvent: function(component, event) {
        this.clearNotification(component);
        if (event.getParam('ButtonId') == 'Estimate') {
            var sRowId = event.getParam('RowId');
            var row = 0;
            var readingEstimate = component.find('readingEstimate');
            var recordList = component.get('v.recordList');
            var wizObj = component.get('v.wizardprop');   // AT-3422
            for (var i = 0; i < recordList.length; i++) {
                row = i+1;
                if (recordList[i].uniqueId == sRowId) {
                    if(recordList[i].objectMap['Reading']){
                        var deviceId = recordList[i].objectMap['Reading'][this.setPrefixedString('Device__c')];
                        var readingDate = wizObj.effectiveDate;       // AT-3422 recordList[i].objectMap['Reading'][this.setPrefixedString('ReadingDate__c')];
                        var helper = this;
                        readingEstimate.getEstimate(deviceId, readingDate, 
                                                    function(response) {
                                                        if (response && response[helper.setPrefixedString('ActualDeviceReading__c')]) {
                                                            recordList[i].objectMap[helper.setPrefixedString('Reading__c')][helper.setPrefixedString('ActualDeviceReading__c')] = response[helper.setPrefixedString('ActualDeviceReading__c')];
                                                            recordList[i].objectMap[helper.setPrefixedString('Reading__c')][helper.setPrefixedString('ReadingSource__c')] = response[helper.setPrefixedString('ReadingSource__c')];
                                                            recordList[i].objectMap[helper.setPrefixedString('Reading__c')][helper.setPrefixedString('ReadingMethod__c')] = response[helper.setPrefixedString('ReadingMethod__c')];
                                                            recordList[i].objectMap[helper.setPrefixedString('Reading__c')][helper.setPrefixedString('Tripped__c')] = response[helper.setPrefixedString('Tripped__c')];  // AT-3422 core 8b
                                                        } else {
                                                            helper.showNotification(component, [$A.get('$Label.c.CuAp_ExceptionADU')],'warn');
                                                            return false;
                                                        }
                                                        component.set('v.recordList', []);
                                                        component.set('v.recordList', recordList);                                                        
                                                    });
                    }
                    else {
                        this.showNotification(component, ['Row: ' + row + ' ' + $A.get("$Label.c.CuAp_NoReadingExist")],'error');
                        return false;
                    }
                    break;
                }
            }
        }
    }
})