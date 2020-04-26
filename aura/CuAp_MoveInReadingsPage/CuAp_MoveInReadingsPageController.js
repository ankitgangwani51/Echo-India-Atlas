({
    /* REQUIRED BY FRAMEWORK */
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

	handleRowButtonPressEvent : function(component,event,helper){
    	helper.handleRowButtonPressEvent(component, event);
    }
})