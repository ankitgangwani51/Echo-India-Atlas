({
    // initialisation
    doInit: function(component, event, helper) {
        helper.doInit(component);
    },

 	showNotification: function(component, event, helper) {	
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},

})