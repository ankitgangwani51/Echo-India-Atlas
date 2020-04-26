({
    // show notification events
    showNotification: function(component, event, helper) {
    	var params = event.getParam('arguments');
    	if (params) {
            helper.showNotification(component, params.message, params.type);
       }   	
    },

    // clear notification
    clearNotification: function(component, event, helper) {	
    	helper.showNotification(component, null);
	}
})