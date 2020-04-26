({
    // handles any errors
    handleError: function(component, response) {
    	console.log('Exception caught successfully');
        showError(component, response.getError()[0].message);
    },
    
    // shows the error message
    showError: function(component, errorMessage) {
        console.log('Displaying error: ', errorMessage);
        this.showNotification(component, errorMessage, error);
    },
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    }
})