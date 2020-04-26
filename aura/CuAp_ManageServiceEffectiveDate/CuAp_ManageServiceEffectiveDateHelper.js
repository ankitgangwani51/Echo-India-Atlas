({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) { 
        component.set('v.servicesRemove',[]);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        this.doInit(component, event, helper);
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
        var isSuccess = this.validateEffectiveDate(component, event, helper);
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
            if(wizObj.availableServiceTransfers){
                let params = {
                    "availableServiceTransfers": wizObj.availableServiceTransfers
                };
                helper.callServer(component,'c.retrieveServiceFromAvailServices',
                                  function(response){ 
                                      console.log('response retrieveServiceFromAvailServices = '+JSON.stringify(response));
                                      component.set('v.servicesFromAvailableServices',response);
                                  },      				
                                  params); 
            }
        }
    },
    
    validateEffectiveDate: function(component, event, helper){
        this.clearNotification(component);
        var maxStartDate = null;
        var services = null;
        var wizObj = component.get('v.wizardprop');
        var effectiveDate = component.get('v.effectiveDate');
        if(!effectiveDate){
            this.showNotification(component, [$A.get("$Label.c.CuAp_EnterEffectiveDate")],'error');
            return false;
        }
        
        if(wizObj.serviceTransfers){
            services = wizObj.serviceTransfers;
            component.set('v.servicesRemove',null);
        }        
        else if(wizObj.availableServiceTransfers){
            services = component.get('v.servicesFromAvailableServices');
            component.set('v.servicesRemove',null);
        }else
            services = component.get('v.servicesRemove');
        console.log('services = '+JSON.stringify(services));
        if(services){
            for(var i=0;i<services.length;i++){
                if(!maxStartDate && services[i][this.setPrefixedString('ServiceStartDate__c')])
                    maxStartDate = services[i][this.setPrefixedString('ServiceStartDate__c')];                
                else if(services[i][this.setPrefixedString('ServiceStartDate__c')] && maxStartDate < services[i][this.setPrefixedString('ServiceStartDate__c')])
                    maxStartDate = services[i][this.setPrefixedString('ServiceStartDate__c')];                
            }
            
            if(maxStartDate && effectiveDate <= maxStartDate){                
                this.showNotification(component, [$A.get("$Label.c.CuAp_EffectiveDateError") + ' ' + maxStartDate],'error');                    
                return false;
            } 
        }
        
        wizObj.effectiveDate = effectiveDate;
        if(component.get('v.servicesRemove'))
            wizObj.removedServices = services;
        return true;
    }
})