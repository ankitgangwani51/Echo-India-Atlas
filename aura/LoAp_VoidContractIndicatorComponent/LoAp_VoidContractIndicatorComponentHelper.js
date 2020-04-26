({
	getVoidStatus : function(component, event, helper) {
		// call the server to get the void contract status for the location
        var action = component.get('c.getVoidContractStatus'); 
        action.setParams({
        					'recordId': component.get('{!v.recordId}')
       				});
        action.setCallback(this, function(response) {
            component.set('v.voidStatus', response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})