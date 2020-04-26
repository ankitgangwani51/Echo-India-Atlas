({
	doInit: function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
    
    // handler for Wizard navigation button events
	// has to be here as we can't override an inherited helper method
    handleWizardEvent: function(component, event, helper) {
        // get information from the event and then handle what the
        // wizard should do
        event.stopPropagation();		// prevent further event propagation
    	helper.clearNotification(component);
        helper.navigateStep(component, event, helper);
    },
     handlePickListChangeEvent:function(component, event, helper) {
        return helper.handlePickListChangeEvent(component, event, helper);
    }
})