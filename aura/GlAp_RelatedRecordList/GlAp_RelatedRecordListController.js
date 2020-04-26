({
	doInit: function(component, event, helper) {
		helper.doInit(component);
	},
	
    handleRowClickEvent: function(component, event, helper) {
        helper.handleRowClickEvent(component, event);
    },
    
    // parent record Id change handler
    parentRecordChange: function(component, event, helper) {
        helper.getRecords(component);
    },
    
    // handler for Wizard navigation button events
    handleWizardEvent: function(component, event, helper) {
        // get information from the event and then handle what the
        // wizard should do
        event.stopPropagation();		// prevent further event propagation
		var message = event.getParam('message');
        if (message === 'SAVED') {
	        helper.getRecords(component);
	    }
    }, 
    //Changes for AT-3317 Start Here
    handleRowButtonPressEvent : function(component,event,helper){
    	helper.handleRowButtonPressEvent(component, event);
    },
    //Changes for AT-3317 Ends Here
})