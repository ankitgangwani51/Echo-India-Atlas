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
        debugger;
        return helper.showDetailsSection(component,event, helper); 
    },
    innerSectionHandleChange: function (component,event,helper) {
        return helper.showInnerDetailsSection(component,event, helper); 
    },
    onCheckRefundToCheque: function(component,event,helper) {
        helper.onCheckRefundToCheque(component,event, helper); 
    },
    onCheckRefundToBank: function(component,event,helper) {
        helper.onCheckRefundToBank(component,event, helper); 
    },
    validateSortCode : function(component,event,helper) {
        helper.validateSortCode(component,event, helper); 
    },
})