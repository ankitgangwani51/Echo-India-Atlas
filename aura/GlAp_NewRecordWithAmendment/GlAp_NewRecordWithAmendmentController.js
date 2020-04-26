({
	doInit: function(component, event, helper) {        
		helper.doInit(component);
	},
	
	// handler for navigation button events
    handleNavigationEvent: function(component, event, helper) {
        helper.navigateStep(component, event, helper);
    }, 
    
 	showNotification: function(component, event, helper) {	
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},

    // parent record Id change handler
    parentRecordChange: function(component, event, helper) {
        helper.checksOnEntry(component);
    },
    
	// button pressed; show the Wizard
    doStart: function(component, event, helper) {	
		helper.doStart(component);
	},
	
	// button pressed; show the Wizard
    doCancel: function(component, event, helper) {	
		helper.doCancel(component);
	},
	
	// handler for bill calculation complete events
    handleBillCalculationComplete: function(component, event, helper) {
        event.stopPropagation();		// prevent further event propagation
        helper.handleBillCalculationComplete(component, event, helper);
    },
    
    //AT-3854
    doCancelQuestion : function(component, event, helper){
        helper.doCancelQuestion(component, event, helper);
    },

    //AT-3854
    doYes : function(component, event, helper){
        helper.doYes(component, event, helper);
    },
    doNo : function(component, event, helper){
        helper.doNo(component, event, helper);
    },
    doAcceptQuestion : function(component, event, helper){
        helper.doAcceptQuestion(component);
    }   
})