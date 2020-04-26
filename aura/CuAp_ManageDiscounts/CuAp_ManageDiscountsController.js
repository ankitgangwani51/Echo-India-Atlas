({
    // REQUIRED BY FRAMEWORK - these functions must be implemented in the wizard page controller 
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
    // END: REQUIRED BY FRAMEWORK 
    
    // Row Select Event method
    handleRowSelectEvent: function(component,event,helper){
    	return helper.handleRowSelectEvent(component, event, helper);
    },
    
    // Row Click Event method
    handleRowClickEvent: function(component, event, helper) {
        return helper.handleRowClickEvent(component, event, helper);
    },
    
    
})