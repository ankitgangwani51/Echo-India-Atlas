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
    
    // method called when click on the row of bundle table
    handleRowClickEvent: function(component, event, helper) {
        helper.handleRowClickEvent(component, event, helper);
    },
})