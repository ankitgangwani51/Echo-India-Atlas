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
    
    // mehid is used to create a new row instance for site supply record
    addMoreRows: function(component, event, helper){
        helper.addMoreRows(component, event, helper);
    },
    
    // method is used to auto populate the address based on select supply point
    handleCustomLookUpEvent: function(component, event, helper){
        helper.handleCustomLookUpEvent(component, event, helper);
    },
    
    // method is used to split percentage to 100 
    splitPercentage: function(component, event, helper) {
        helper.splitPercentage(component, event, helper);
    },
    
    // method is used to remove the site supply record from the displayed list
    removeRow : function(component, event, helper){
      helper.removeRow(component, event, helper);
    }, 
    
    // method is used to dipslay the popup when percentage split is in between 99-100
    doAcceptQuestion: function(component, event, helper) {
        helper.doAcceptQuestion(component, event, helper);
    },
    
    // method is used to close the popup appears for percentage split message
    doCancelQuestion: function(component, event, helper) {
        helper.doCancelQuestion(component, event, helper);
    }, 
})