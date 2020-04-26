({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) { 
        component.set("v.objSteppedTariff", []);
        component.set("v.steppedTariffFields", []);
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
            if(wizObj.steppedTariff){
                component.set("v.objSteppedTariff", {'sobjectType':this.setPrefixedString('SteppedTariff__c'),
                                                     [this.setPrefixedString('StartDate__c')] 	: wizObj.steppedTariff[this.setPrefixedString('StartDate__c')],
                                                     [this.setPrefixedString('EndDate__c')] 	: wizObj.steppedTariff[this.setPrefixedString('EndDate__c')],
                                                     ['ServiceType'] 							: component.get('v.mapOfServiceId2Name').get(wizObj.steppedTariff[this.setPrefixedString('ServiceType__c')]),
                                                     ['DurationInMonths'] 						: wizObj.steppedTariff[this.setPrefixedString('RenewalMonths__c')]});
                
                
            }
            else{
                component.set("v.objSteppedTariff", {'sobjectType':this.setPrefixedString('SteppedTariff__c'),
                                                     [this.setPrefixedString('StartDate__c')] 	: '',
                                                     [this.setPrefixedString('EndDate__c')] 	: '',
                                                     ['ServiceType'] 							: '',
                                                     ['DurationInMonths'] 						: '12'});
                
                
                var ContractId = wizObj.contractId; 
                var serviceTypeName2Id = new Map(); 
                var serviceTypeId2Name = new Map(); 
                
                let params = {
                    "ContractId": ContractId,
                };
                helper.callServer(component,'c.retrieveSteppedTariffFields',
                                  function(response){
                                      component.set('v.steppedTariffFields', response);
                                  },      				
                                  params); 
                
                helper.callServer(component,'c.retrieveServicesOnContract',
                                  function(response){
                                      if(response != null){
                                          for (var i = 0; i < response.length; i++) { 
                                              serviceTypeName2Id.set(response[i].Name,response[i].Id);
                                              serviceTypeId2Name.set(response[i].Id,response[i].Name);
                                          }
                                          component.set('v.mapOfServiceName2Id', serviceTypeName2Id);
                                          component.set('v.mapOfServiceId2Name', serviceTypeId2Name);
                                      }
                                      
                                  },      				
                                  params); 
            }
        }
    },
    
    validateSteppedTariffField: function(component, event, helper){
        this.clearNotification(component);
        var steppedTariffValues = component.get('v.objSteppedTariff');
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        
        
        if(!steppedTariffValues['ServiceType']){
            this.showNotification(component, [$A.get("$Label.c.BlAp_SelectServiceType")],'error');
            return false;            
        }
        
        if(!steppedTariffValues[this.setPrefixedString('StartDate__c')]){
            this.showNotification(component, [$A.get("$Label.c.BlAp_EnterStartDate")],'error');
            return false;           
        }
        
        if(steppedTariffValues[this.setPrefixedString('EndDate__c')] && steppedTariffValues[this.setPrefixedString('EndDate__c')] < todaysDate){
            this.showNotification(component, [$A.get("$Label.c.BlAp_EndDateShouldNotLessEqualToday")],'error');
            return false;    
        }
        
        
        if(steppedTariffValues[this.setPrefixedString('EndDate__c')] && steppedTariffValues[this.setPrefixedString('StartDate__c')] >= steppedTariffValues[this.setPrefixedString('EndDate__c')]){
            this.showNotification(component, [$A.get("$Label.c.BlAp_StartDateMustBeLess")],'error');
            return false;            
        }

        var wizObj = component.get('v.wizardprop');
        wizObj.steppedTariff = {sobjectType: this.setPrefixedString('SteppedTariff__c'), 
                                [this.setPrefixedString('BillingContract__c')]	: wizObj.contractId,
                                [this.setPrefixedString('StartDate__c')]		: steppedTariffValues[this.setPrefixedString('StartDate__c')],
                                [this.setPrefixedString('EndDate__c')]			: steppedTariffValues[this.setPrefixedString('EndDate__c')] != '' ? steppedTariffValues[this.setPrefixedString('EndDate__c')] : null,
                                [this.setPrefixedString('ServiceType__c')]		: component.get('v.mapOfServiceName2Id').get(steppedTariffValues['ServiceType']),
                                [this.setPrefixedString('RenewalMonths__c')]	: steppedTariffValues['DurationInMonths']}
        
        wizObj.serviceType = steppedTariffValues['ServiceType'];
        
        return true;
    }
})