({
	doInit : function(component) {		
        
        var action = component.get('c.customerHighlights');
	    action.setParams({
            'recordId': component.get('v.recordId'),
            'sObjectName': component.get('v.sObjectName')
            
	    });
	    action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.resultValue', response.getReturnValue());
                console.log('123*************************v.resultValue ' + JSON.stringify(response.getReturnValue()));
	        }
	    });
	    $A.enqueueAction(action);
	}
})