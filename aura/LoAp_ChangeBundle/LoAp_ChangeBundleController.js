({
    doInit : function(component, event, helper){
        helper.doInit(component, event, helper);
    },
	// handler for navigation button events
    handleNavigationEvent: function(component, event, helper) {
        helper.navigateStep(component, event, helper);
    },
    
    showNotification: function(component, event, helper) {	
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},
    
    doCancel: function(component, event, helper) {	
		helper.doCancel(component);
	},
})