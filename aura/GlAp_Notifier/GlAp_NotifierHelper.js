({
    // fire a component event to display a notification on a parent
    showNotification: function(component, message, type) {
    	var errorEvent = component.getEvent('notificationEvent');
        errorEvent.setParams({
            'message': message,
            'type': type 
        });

        // fire the event
        errorEvent.fire();
	}
})