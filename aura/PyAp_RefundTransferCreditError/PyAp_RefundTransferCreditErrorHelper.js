({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {   
        this.navigateToSObject(component);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {  
        
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {    
        this.navigateToSObject(component); 
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },
    navigateToSObject: function(component) {
       var wizObj = component.get('v.wizardprop');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": wizObj.recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
    
    
})