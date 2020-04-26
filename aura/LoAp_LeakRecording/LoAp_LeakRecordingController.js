({
	doSave : function(component, event, helper) {
        helper.doSave(component, event, helper);		
	},
    showNotification: function(component, event, helper) {	
       
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},
    doInit: function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
    handleBillCalculationComplete: function(component, event, helper) {
        event.stopPropagation();		// prevent further event propagation
        helper.handleBillCalculationComplete(component, event, helper);
    },
})