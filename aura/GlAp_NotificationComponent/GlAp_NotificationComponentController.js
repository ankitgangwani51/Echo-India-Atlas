({
    // handler for notification events (errors etc)
    showNotification: function(component, event, helper) {
    	var params = event.getParam('arguments');
    	if (params) {
            helper.showNotification(component, params.message, params.type);
        } else {
        	helper.showNotification(component, event.getParam('message'), event.getParam('type'));
        }
    },

    // clear notification
    clearNotification: function(component, event, helper) {	
    	helper.clearNotification(component);
	}
})