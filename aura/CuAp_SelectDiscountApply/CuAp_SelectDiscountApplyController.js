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
    
    /* Page Specific methods*/
    //select and de-select the generic table rows on event basis.
    handleRowSelectEvent: function(component, event, helper) {
        helper.handleRowSelectEvent(component, event, helper);
    },
    //Filter the search criteria.
    doFilter : function(component, event, helper) {
        helper.doFilter(component, event, helper);
    },
    //Reset the search criteria.
    doReset : function(component, event, helper) {
        helper.doReset(component, event, helper);
    },
    
    // This function will refresh the discount type table when the filter criteria values will change  
    setSelectDiscountBlank : function (component, event, helper){
        helper.setSelectDiscountBlank(component, event, helper);
    }
  
    
})