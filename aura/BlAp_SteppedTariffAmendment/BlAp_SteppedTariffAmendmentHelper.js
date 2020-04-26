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
    
    // doInit function: displays the service type list and renewals parameters
    doInit: function(component, event, helper){
        
        var wizObj = component.get('v.wizardprop');
        
        if(wizObj != null){
            if(wizObj.steppedTariffId){
                
                var recordList = component.get('v.recordList');
                
                for (var i = 0; i < recordList.length; i++) {
                    if(recordList[i].uniqueId == wizObj.steppedTariffId)
                        recordList[i].isSelected = true;
                    else
                        recordList[i].isSelected = false;
                }
                component.set('v.recordList', []);
                component.set('v.recordList', recordList);
                
            }
            else{
                helper.callServer(component,'c.retrieveSteppedTariffFields',
                                  function(response){
                                      component.set('v.fieldList', response);
                                  },      				
                                  null);   
                
                var ContractId = wizObj.contractId;  
                let params = {
                    "ContractId": ContractId,
                };
                
                helper.callServer(component,'c.retrieveSteppedTariffRecords',
                                  function(response){                                      
                                      component.set('v.recordList', response);                                      
                                  },      				
                                  params);   
            }
        }        
    },
    
    // Validate the stepped tariff fields
    validateSteppedTariffField: function(component, event, helper){
        this.clearNotification(component);        
        var isSelectOne = false;
        var wizObj = component.get('v.wizardprop'); 
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        var recordList = component.get('v.recordList');
        
        if(recordList.length == 1){
            wizObj.steppedTariff = {sobjectType: this.setPrefixedString('SteppedTariff__c'), 
                                    [this.setPrefixedString('BillingContract__c')]		: wizObj.contractId,
                                    [this.setPrefixedString('StartDate__c')]	: recordList[0].objectMap[this.setPrefixedString('SteppedTariff__c')][this.setPrefixedString('StartDate__c')],
                                    [this.setPrefixedString('EndDate__c')]		: recordList[0].objectMap[this.setPrefixedString('SteppedTariff__c')][this.setPrefixedString('EndDate__c')],
                                    [this.setPrefixedString('ServiceType__c')]	: recordList[0].objectMap[this.setPrefixedString('SteppedTariff__c')][this.setPrefixedString('ServiceType__c')]}
            wizObj.steppedTariffId = recordList[0].uniqueId; 
        }
        
        for (var i = 0; i < recordList.length; i++) {
            var rowNo = i+1;
            if(recordList[i].isSelected){
                isSelectOne = true;               
            }
        }
        if(!isSelectOne){
            this.showNotification(component, [$A.get("$Label.c.BlAp_OneSteppedTariffMandat")],'error');
            return false;    
        }
        return true;
    },
    
    // Set the stepped tariff values into wizard variable on selection of the row to process further
    handleRowSelectEvent: function(component, event, helper) {
        this.clearNotification(component);
        
        var sRowId = event.getParam('RowId');
        var recordList = component.get('v.recordList');
        var wizObj = component.get('v.wizardprop');
        
        for (var i = 0; i < recordList.length; i++) {
            console.log('recordList[i] ='+JSON.stringify(recordList[i]));
            if (recordList[i].uniqueId != sRowId) {
                recordList[i].isSelected = false;
            } else if(recordList[i].isSelected == true) {
                wizObj.steppedTariff = {sobjectType: this.setPrefixedString('SteppedTariff__c'), 
                                        [this.setPrefixedString('BillingContract__c')]			: wizObj.contractId,
                                        [this.setPrefixedString('StartDate__c')]		: recordList[i].objectMap[this.setPrefixedString('SteppedTariff__c')][this.setPrefixedString('StartDate__c')],
                                        [this.setPrefixedString('EndDate__c')]			: recordList[i].objectMap[this.setPrefixedString('SteppedTariff__c')][this.setPrefixedString('EndDate__c')],
                                        [this.setPrefixedString('ServiceType__c')]		: recordList[i].objectMap[this.setPrefixedString('SteppedTariff__c')][this.setPrefixedString('ServiceType__c')]}
                wizObj.steppedTariffId = recordList[i].uniqueId;
            }
        }

        component.set('v.wizardprop',wizObj);        
        component.set('v.recordList', recordList);
    }
})