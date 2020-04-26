({
	doInit: function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	doSave: function(component, event, helper) {
		helper.doSave(component, event, helper);
	},

    doCancel: function(component, event, helper) {
		helper.doCancel(component, event, helper);
	},

    doManageSuppression: function(component, event, helper) {
		helper.doManageSuppression(component, event, helper);
	},

    startSuppressSelectedContracts: function(component, event, helper) {
		helper.startSuppressSelectedContracts(component, event, helper);
	},

    startSuppressAccount: function(component, event, helper) {
		helper.startSuppressAccount(component, event, helper);
	},
	
    handleRowSelectEvent: function(component, event, helper) {
        helper.handleRowSelectEvent(component, event, helper);
    }
})