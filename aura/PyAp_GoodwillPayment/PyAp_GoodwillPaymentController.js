({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper) ;
	},
    
    handleChange: function (component,event,helper) {
        return helper.showDetailsSection(component,event, helper); 
    },
    
    onRefundTypeSelection: function(component,event,helper) {
        helper.onRefundTypeSelection(component,event,helper) ;
    }, 
    
	handleWizardEvent: function(component, event, helper) {
        event.stopPropagation() ; // prevent further event propagation
    	helper.clearNotification(component) ;
        helper.navigateStep(component, event, helper) ;
    }, 
    
    doOpenGoodwillComponent : function(component, event, helper) {
      helper.doOpenGoodwillComponent(component) ;  
    },
    
    innerSectionHandleChange: function (component,event,helper) {
        return helper.showInnerDetailsSection(component,event, helper); 
    },
    
    doCancel : function(component, event, helper) {
        helper.doCancel(component) ;
    }, 
    
    doSave: function(component, event, helper) {
        helper.doSave(component, event, helper) ;
    },  
    
    validateSortCode : function(component,event,helper) {
        helper.validateSortCode(component,event, helper); 
    },
    
})