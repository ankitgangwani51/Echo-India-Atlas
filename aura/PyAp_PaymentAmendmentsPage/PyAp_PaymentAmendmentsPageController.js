({
    // Intialise the component.
    doInit: function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    //Activate Transfer Payment section
    handleChange: function (component,event,helper) {
        return helper.showDetailsSection(component,event, helper); 
    },
    // cancel button handler
    doCancel: function(component, event, helper) {	
        helper.doCancel(component, event, helper);
    },
    // Activate section handler
    doPageActive: function(component, event, helper) {	
        helper.doPageActive(component, event, helper);
    },
     // method to perform the dml operation in order to save and update the payment records
    doSave: function(component, event, helper) {	
        helper.doSave(component, event, helper);
    },
    // Function call when attribute 'existingPaymentAccount' value changed
    handleSelectedAccountValueChange: function(component, event, helper) {
        return helper.handleSelectedAccountValueChange(component);       
     }
    
})