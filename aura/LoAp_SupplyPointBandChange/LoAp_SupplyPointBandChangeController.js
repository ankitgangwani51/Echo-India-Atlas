({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper) ;
	},
    
    doOpenBandChangeComponent : function(component, event, helper) {
      helper.doOpenBandChangeComponent(component) ;  
    },
    
    doCancel : function(component, event, helper) {
        helper.doCancel(component) ;
    }, 
    
    doSave: function(component, event, helper) {
        helper.doSave(component, event, helper) ;
    }, 
    
    handleBillCalculationComplete: function(component, event, helper) {
        event.stopPropagation();		
        helper.handleBillCalculationComplete(component, event, helper);
    },
    
    showNotification: function(component, event, helper) {	       
        event.stopPropagation();		
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	},

})