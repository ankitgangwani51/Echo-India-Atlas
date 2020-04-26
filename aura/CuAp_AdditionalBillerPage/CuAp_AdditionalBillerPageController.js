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
    
    // method to display a new row of additional biller on click of Add more button
    addMoreRows: function(component, event, helper) {	
        helper.addRow(component);
    }
})