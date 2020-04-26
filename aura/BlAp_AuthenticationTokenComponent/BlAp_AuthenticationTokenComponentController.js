({
	// check that the token input is valid (not empty for the moment)
	validate: function(component, event, helper) {
        var token = component.find('token');
        component.set('v.valid', token.get('v.value').length > 0);
	
	},

    // saves the token in the protected custom setting
	handleUpdateToken: function(component, event, helper) {
		helper.clearNotification(component);
        var token = component.find('token');
        if (token.get('v.value').length > 0) {
        	console.debug('Saving token: ' + token.get('v.value'));
	        var action = component.get('c.updateToken');
	        action.setParams({
	        	'token': token.get('v.value')
	        });
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === 'SUCCESS') {
	                console.debug(response.getReturnValue());
	                if (response.getReturnValue()) {
	                	helper.showNotification($A.get('$Label.c.GuAp_RecordSuccessfullyUpdatedMsg'), 'success');
	                	
	                	// clear the token entry
	                	token.set('v.value', '');
	
	                } else {
	                	helper.showError(component, $A.get('$Label.c.BlAp_AuthenticationTokenUpdateError'));
	                }                
	            } else {
	            	helper.handleError(component, response);
	            }
	        });
	        $A.enqueueAction(action);
	    }
    }
})