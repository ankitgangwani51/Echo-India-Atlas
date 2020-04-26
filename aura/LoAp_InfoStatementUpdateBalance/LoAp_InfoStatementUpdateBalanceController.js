({
    
    doUpdateBalance : function(component, event, helper) {
        helper.doUpdateBalance(component,event, helper);
    },
    showNotification: function(component, event, helper) {	
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},
})