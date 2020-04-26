({
	doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);		
	},
    
    handleManage: function(component, event, helper) {
		helper.handleManage(component, event, helper);
	},
    
    handleAdd: function(component, event, helper) {
		helper.handleAdd(component, event, helper);
	},
    
    handleRowButtonPressEvent : function(component,event,helper){
    	helper.handleRowButtonPressEvent(component, event);
    },
    
    doCancelQuestion : function(component, event, helper){
        helper.doCancelQuestion(component, event, helper);
    },
    
    handleStatus: function(component, event, helper) {
		helper.handleStatus(component, event, helper);
	},
    
    doCancelQuestion: function(component, event, helper) { 
        helper.doCancelQuestion(component, event, helper);
    },
    
    doDeleteQuestion: function(component, event, helper) {
		helper.doDeleteQuestion(component, event, helper);
    },
    
    handleSearch: function(component, event, helper){
        helper.handleSearch(component, event, helper);
    }
})