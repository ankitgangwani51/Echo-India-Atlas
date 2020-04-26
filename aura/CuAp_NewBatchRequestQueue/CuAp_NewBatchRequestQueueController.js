({
    // Component Constructor Method
    doInit : function(component, event, helper) {
        helper.doInit(component);
	},
	
	// handler for navigation button events
    handleNavigationEvent: function(component, event, helper) {
        helper.navigateStep(component, event);
    }, 
    
	// makes the modal active
    newRequest: function(component, event, helper) {
        helper.newRequest(component);
    },

    close: function(component, event, helper) {
        return helper.close(component);
    },
})