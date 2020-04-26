({
    /* REQUIRED BY FRAMEWORK - these functions must be implemented in the wizard page controller */
    // re-initialise  component on wizard close/exit
    reInitialise: function(component, event, helper) {	
    	return helper.reInitialise(component, event, helper);
    },
    
    // checks the component data for the component 
    checksOnEntry: function(component, event, helper) {	
    	return helper.checksOnEntry(component, event, helper);
    },
    
    // validate the data gathered by the component 
    validateOnNext: function(component, event, helper) {
    	return helper.validateOnNext(component, event, helper);
    },
	/* END: REQUIRED BY FRAMEWORK */
    
    /* PAGE SPECIFIC METHODS */
    handleRowSelectEvent: function(component, event, helper) {
		helper.handleRowSelectEvent(component, event, helper);
    }
})