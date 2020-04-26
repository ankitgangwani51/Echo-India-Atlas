({
	DEBUG:	'NewBatchRequest: ',
	
    doInit : function(component) {

    },
    
    // navigation with validation/server calls 
    navigateStep: function(component, event) {
        
        console.log(this.DEBUG + 'Wizard navigation handler');
        var message = event.getParam('message');
        if (message === 'CANCEL') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            this.close(component);
            
        } else if (message === 'NEXT') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            this.save(component);
             
        } else if (message === 'BACK') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            // not valid
        }
    },

    // call the notifier method to show a message on the notification component.
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
    
    // displays the modal
    newRequest: function(component) {
    
    	// null batch class defaults to new batch request queue with basic settings
    	if (!component.get('v.batchClass')) {
		    let params = {'batchProcessId': component.get('v.recordId')};
		    this.callServer(component, 'c.createDefaultBatchRequest',
		    				function(response) {
						        this.newRecordAdded(component);
		    				}, 
		                    params);
		                    
    	} else {
    		component.set('v.isActive', true);
    	}

    },
    
    // fire event to signal to the parent component that a new record was added 
    newRecordAdded: function(component) {
        var cmpEvent = component.getEvent('wizEvent');
        cmpEvent.setParams({'message': 'SAVED'});
        cmpEvent.fire();
    },
    
    // Server call to save the data in BRQ.
    save: function(component) {
    	this.clearNotification(component);

    },
    
    // close the modal
    close: function(component) {
        component.set('v.isActive', false);
    },
    
})