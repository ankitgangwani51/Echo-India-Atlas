({  
    /* REQUIRED BY FRAMEWORK - these functions must be implemented in the wizard page controller */
    // re-initialise  component on wizard close/exit
    reInitialise: function(component, event, helper) {	
        return helper.reInitialise(component);
    },
    
    // checks the component data for the component 
    checksOnEntry: function(component, event, helper) {	
        return helper.checksOnEntry(component);
    },
    
    // validate the data gathered by the component 
    validateOnNext: function(component, event, helper) {	
        return helper.validateOnNext(component);
    },
    /* END: REQUIRED BY FRAMEWORK */
    handleChange: function (component,event,helper) {
       return helper.showDetailsSection(component,event, helper); 
    },
    // Operation on check of new radio button.
    onCheckNew: function(component,event,helper) {
        helper.onCheckNew(component,event, helper); 
    },
     // Operation on check of existing radio button.
    onCheckExisting: function(component,event,helper) {
        helper.onCheckExisting(component,event, helper); 
    },
    validateSortCode : function(component,event,helper) {
        helper.validateSortCode(component,event, helper); 
    },
})