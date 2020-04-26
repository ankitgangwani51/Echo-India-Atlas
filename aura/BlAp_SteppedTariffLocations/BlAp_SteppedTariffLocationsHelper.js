({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) { 
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        var wizObj = component.get('v.wizardprop');
        if(wizObj.wizardType == $A.get('$Label.c.BlAp_NewStepTariff'))
            this.doInitCreate(component, event, helper);
        else
            this.doInitAmend(component, event, helper);
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
        var isSuccess = this.validateSteppedTariffField(component, event, helper);        
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
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },  
    
    // doInit function: displays the service type list and renewals parameters
    doInitCreate: function(component, event, helper){ 
        var wizObj = component.get('v.wizardprop');
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        
        if(wizObj != null){                        
            component.set("v.objSteppedTariff", {'sobjectType':this.setPrefixedString('SteppedTariff__c'),
                                                 [this.setPrefixedString('StartDate__c')] 	: wizObj.steppedTariff[this.setPrefixedString('StartDate__c')],
                                                 [this.setPrefixedString('EndDate__c')] 	: wizObj.steppedTariff[this.setPrefixedString('EndDate__c')],
                                                 ['ServiceType']							: wizObj.serviceType,
                                                 ['DurationInMonths'] 						: wizObj.steppedTariff[this.setPrefixedString('RenewalMonths__c')]});            
            let param = {
                "wizardType" : wizObj.wizardType
            };
            
            helper.callServer(component,'c.retrieveSteppedTariffFields',
                              function(response){
                                  component.set('v.steppedTariffFields', response);
                              },      				
                              param); 
            
            //Retrieve list of fields and properties for the Service and Location Object
            helper.callServer(component,'c.retrieveServicefieldList',
                              function(response){
                                  console.log('retrieveServicefieldList response = '+JSON.stringify(response));
                                  component.set('v.fieldList', response);   
                              },      				
                              null);
            
            var ContractId = wizObj.contractId;  
            let params = {
                "ContractId": ContractId,
                "serviceType": wizObj.serviceType                
            };
            
            helper.callServer(component,'c.retrieveServicerecordList',
                              function(response){                                  
                                  component.set('v.isChecked',response.isChecked);
                                  component.set('v.recordList', response.serviceRecordCombinedList);                                  
                              },      				
                              params);  
        }
    },
    
    // doInit function: displays the service type list and renewals parameters
    doInitAmend: function(component, event, helper){  
        var wizObj = component.get('v.wizardprop');
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        if(wizObj != null){           
            var ServiceTypeId = wizObj.steppedTariff[this.setPrefixedString('ServiceType__c')];  
            let param1 = {
                "ServiceTypeId": ServiceTypeId,
            };
            
            helper.callServer(component,'c.retrieveSertviceTypeName',
                              function(response){   
                                  component.set("v.objSteppedTariff", {'sobjectType':this.setPrefixedString('SteppedTariff__c'),
                                                                       [this.setPrefixedString('StartDate__c')] : wizObj.steppedTariff[this.setPrefixedString('StartDate__c')],
                                                                       [this.setPrefixedString('EndDate__c')] 	: wizObj.steppedTariff[this.setPrefixedString('EndDate__c')],
                                                                       ['ServiceType']							: response});
                              },      				
                              param1);  
            
            let param2 = {
                "wizardType" : wizObj.wizardType
            };
            
            helper.callServer(component,'c.retrieveSteppedTariffFields',
                              function(response){
                                  component.set('v.steppedTariffFields', response);
                              },      				
                              param2);
            
            //Retrieve list of fields and properties for the Service and Location Object
            helper.callServer(component,'c.retrieveServicefieldList',
                              function(response){
                                  component.set('v.fieldList', response);   
                              },      				
                              null);

            var SteppedTariffId = wizObj.steppedTariffId;            
            let param3 = {
                "SteppedTariffId": SteppedTariffId,
            };
            
            helper.callServer(component,'c.retrieveSTSRecords',
                              function(response){                                  
                                  component.set('v.isChecked',response.isChecked);
                                  component.set('v.recordList', response.serviceRecordCombinedList);                                  
                              },      				
                              param3);  
        }
    },
    
    // Validate the fields and return true if all validation passed and submit record to create stepped tariff and stepped tariff services records
    validateSteppedTariffField: function(component, event, helper){
        this.clearNotification(component);
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        var newRecordList = [];
        var recordList = component.get('v.recordList');       
        var steppedTariffDetails = component.get('v.objSteppedTariff');
        var isSelectOne = false;
        var wizObj = component.get('v.wizardprop');
        var rec;
        
        console.log('recordList = '+JSON.stringify(recordList));
        for (var i = 0; i < recordList.length; i++) {             
            var rowNo = i+1;
            rec = null;
            if(recordList[i].isSelected){
                isSelectOne = true;
                
                // Start date can be changed only when it is in future
                if(recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('StartDate__c')] < todaysDate){
                    this.showNotification(component, ['Row ' + rowNo + $A.get("$Label.c.BlAp_FutureStartDate")],'error');
                    return false;     
                }
                
                // Start date cannot be less than stepped tariff start date
                if(recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('StartDate__c')] < steppedTariffDetails[this.setPrefixedString('StartDate__c')]){
                    this.showNotification(component, ['Row ' + rowNo + $A.get("$Label.c.BlAp_CannotBeforeSteppedTariff")],'error');
                    return false;     
                }
                
                // End date cannot be in past
                if(recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] && 
                   recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] < todaysDate){
                    this.showNotification(component, ['Row ' + rowNo + $A.get("$Label.c.BlAp_EndDateAfterToday")],'error');
                    return false;     
                }
                
                // End date cannot be before Start Date
                if(recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] && 
                   recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('StartDate__c')] &&
                   recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] < recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('StartDate__c')]){
                    this.showNotification(component, ['Row ' + rowNo + $A.get("$Label.c.BlAp_EndCannotBeforeStart")],'error');
                    return false;     
                }
                
                // End date cannot be after stepped tariff end date
                if(steppedTariffDetails[this.setPrefixedString('EndDate__c')] != '' && recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] &&
                   recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] > steppedTariffDetails[this.setPrefixedString('EndDate__c')]){
                    this.showNotification(component, ['Row ' + rowNo + $A.get("$Label.c.BlAp_EndDateAfterSteppedTariff")],'error');                    
                    return false;     
                }
                
                if(wizObj.wizardType == $A.get('$Label.c.BlAp_NewStepTariff')){
                    rec = {sobjectType: this.setPrefixedString('SteppedTariffService__c'), 
                           [this.setPrefixedString('Service__c')]		: recordList[i].uniqueId,
                           [this.setPrefixedString('SteppedTariff__c')]	: null,
                           [this.setPrefixedString('EndDate__c')]		: recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] != '' ? recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] : null,
                           [this.setPrefixedString('StartDate__c')]		: recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('StartDate__c')]}
                    newRecordList.push(rec);
                }else{
                    rec = {sobjectType: this.setPrefixedString('SteppedTariffService__c'), 
                           ['Id']										: recordList[i].uniqueId,
                           [this.setPrefixedString('Service__c')]		: recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('Service__c')],
                           [this.setPrefixedString('SteppedTariff__c')]	: recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('SteppedTariff__c')],
                           [this.setPrefixedString('StartDate__c')]		: recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('StartDate__c')],
                           [this.setPrefixedString('EndDate__c')]		: recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] != '' ? recordList[i].objectMap[this.setPrefixedString('SteppedTariffService__c')][this.setPrefixedString('EndDate__c')] : null}
                    newRecordList.push(rec);
                }
            }
        }
        
        // At least one supply point record must be selected for stepped tariff service record
        if(!isSelectOne){
            if(wizObj.wizardType == $A.get('$Label.c.BlAp_NewStepTariff')){
                this.showNotification(component, [$A.get("$Label.c.BlAp_OneSupplyPointMust")],'error');
                return false; 
            }else{
                this.showNotification(component, [$A.get("$Label.c.BlAp_OneSteppedTariffServiceMust")],'error');
                return false;                 
            }
        }
        
        wizObj.steppedTariff[this.setPrefixedString('RenewalMonths__c')] = steppedTariffDetails.DurationInMonths;
        wizObj.steppedTariffServices = newRecordList;
        return true;
    }
})