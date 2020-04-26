({
	doInit : function(component, event, helper) {
		//helper.doInit(component);
	},
    
    doActive : function(component, event, helper) {
		helper.doActive(component);
        helper.doInit(component);
	},
    
    doCancel : function(component, event, helper) {
		helper.doCancel(component);
	},
    
    doSave : function(component, event, helper) {
		helper.doSave(component, event, helper);
	},
    
    handleRowSelectEvent: function(component, event, helper) {
		//helper.handleRowSelectEvent(component, event, helper);
    }
})