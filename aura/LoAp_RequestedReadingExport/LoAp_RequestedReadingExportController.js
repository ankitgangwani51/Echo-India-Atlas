({
    //Handle component initialization in a client-side controller
	doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    // New request method to call helper
    newRequest: function(component, event, helper) {
        helper.newRequest(component, event, helper);
    },
    
})