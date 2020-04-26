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
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        helper.handleComponentEvent(component, event, helper);
    },
    
    getAllServices : function(component, event, helper) {
        helper.getAllServices(component, event, helper);
    },
    
    setServiceTableBlank : function(component, event, helper) {
        helper.setServiceTableBlank(component, event, helper);
    },
    
    setServiceTableBlank1 : function(component, event, helper) {
        helper.setServiceTableBlank1(component, event, helper);
    },
    
    // Row select Event method
    handleRowSelectEvent: function(component, event, helper) {
        return helper.handleRowSelectEvent(component, event, helper);
    },
    
})