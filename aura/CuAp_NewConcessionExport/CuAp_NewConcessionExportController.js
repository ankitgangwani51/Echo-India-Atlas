({
    // Component Constructor Method
    doInit : function(component, event, helper) {
        helper.doInit(component);
	},
	
	// handler for navigation button events
    handleNavigationEvent: function(component, event, helper) {
        // allow event propagation
    	helper.clearNotification(component);
        helper.navigateStep(component, event);
    }, 
    
    // Row Click Event method
    handleRowClickEvent: function(component, event, helper) {
        return helper.handleRowClickEvent(component, event);
    },
    
    // Row select Event method
    handleRowSelectEvent: function(component, event, helper) {
        return helper.handleRowSelectEvent(component, event);
    },
    
	// makes the modal active
    newRequest: function(component, event, helper) {
        helper.newRequest(component);
    },

    close: function(component, event, helper) {
        return helper.close(component);
    },

})