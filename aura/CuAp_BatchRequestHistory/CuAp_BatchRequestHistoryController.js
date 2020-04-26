({
	doInit: function(component, event, helper) {
		helper.doInit(component);
	},
	
    handleRowButtonPressEvent : function(component,event,helper){
    	helper.handleRowButtonPressEvent(component, event);
    },
    
    handleRowClickEvent: function(component, event, helper) {
        helper.handleRowClickEvent(component, event);
    },
    
    handleTab: function(component, event, helper) {
        helper.handleTab(component);
    },
    
    // handler for Wizard navigation button events
    handleWizardEvent: function(component, event, helper) {
        // get information from the event and then handle what the
        // wizard should do
		var message = event.getParam('message');
        if (message === 'SAVED') {
        	event.stopPropagation();		// prevent further event propagation
	        helper.getRecords(component);
	    }
    }, 

})