({
	myPayments : function(component, event, helper) {
		helper.myPayments(component);
	},
    
    makePayments : function(component, event, helper) {
		helper.makePayments(component);
	},
    
    showNotification: function(component, event, helper) {	
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},
})