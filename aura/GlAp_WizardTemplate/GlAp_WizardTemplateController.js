({
 	showNotification: function(component, event, helper) {	
       
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},

	// button pressed; show the Wizard
    doStartWizard: function(component, event, helper) {	
		helper.doStartWizard(component);
	},
	
	// cancel button handler
    doCancel: function(component, event, helper) {	
		helper.doCancel(component);
	},
	
	// next button handler
    doNext: function(component, event, helper) {	
		helper.doNext(component);
	},
	
	// back button handler
 	doBack: function(component, event, helper) {	
		helper.doBack(component);
	}
})