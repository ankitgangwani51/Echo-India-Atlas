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
    
    /* PAGE SPECIFIC METHODS */
    // perform actions when option is changed to "Create a new contract"
    hideContracts: function(component, event, helper) {
        helper.hideContracts(component);
    },

    // perform actions when option is changed to "Select an existing contract"
    showContracts: function(component, event, helper) {
        helper.showContracts(component);
    },

    // perform actions when a contract is selected
    handleRowSelectEvent: function(component, event, helper) {
        helper.handleRowSelectEvent(component, event);
    }
})