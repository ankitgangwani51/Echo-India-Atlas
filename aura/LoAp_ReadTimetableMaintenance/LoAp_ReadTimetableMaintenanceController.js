({
	doInit: function(component, event, helper) {
		helper.doInit(component);
	},
	
    handleRowClickEvent: function(component, event, helper) {
        helper.handleRowClickEvent(component, event);
    },
    DeleteRow: function(component, event, helper) {
        helper.DeleteRow(component, event);
    },
    AddRow: function(component, event, helper) {
        helper.AddRow(component, event);
    },
    tabSelected: function(component, event, helper) {
        helper.tabSelected(component, event);
    },
    save: function(component, event, helper) {
        return helper.save(component, event);
    },
    close: function(component, event, helper) {
        return helper.close(component, event);
    }
})