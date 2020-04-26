({
    doInit: function(component, event, helper) {
 
    	// call the server to get the suppression status for the account/contract
        var action = component.get('c.getSuppressionStatus'); 
        action.setParams({
        					'sObjectName': component.get('{!v.sObjectName}'), 
         					'recordId': component.get('{!v.recordId}')
       				});
        action.setCallback(this, function(response) {
            component.set('v.suppressionStatus', response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    handleMouseEnter : function(component, event, helper) {
        var popover = component.find("popover");
        $A.util.removeClass(popover,'slds-hide');
    },
    
    //make a mouse leave handler here
    handleMouseLeave : function(component, event, helper) {
        var popover = component.find("popover");
        $A.util.addClass(popover,'slds-hide');
    }
})