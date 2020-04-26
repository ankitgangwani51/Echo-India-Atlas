({
    // display a notification message
    showNotification: function(component, notificationMessage, notificationType) {
        var notificationClass = 'slds-notify slds-notify_alert';
        if (notificationType === 'info') notificationClass += ' slds-theme_success';
     	else if (notificationType === 'warn') notificationClass += ' slds-theme_warning';
     	else if (notificationType === 'offline') notificationClass += ' slds-theme_offline';
     	else notificationClass += ' slds-theme_error';

    	var notification = {};
    	notification['message'] = notificationMessage;
    	notification['class'] = notificationClass;
        notification['type'] = notificationType;
		component.set('v.notification', notification);
    },
    
    // clear the notification message
    clearNotification: function(component) {
    	var notification = {};
    	notification['message'] = '';
    	notification['class'] = 'slds-notify slds-notify_alert slds-theme_error';
		component.set('v.notification', notification);
    }
})