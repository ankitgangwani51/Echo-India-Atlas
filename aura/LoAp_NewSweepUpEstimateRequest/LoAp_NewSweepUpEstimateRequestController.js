({
    //Component Constructor Method
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
	},
    // Row Click Event method
    handleRowClickEvent: function(component, event, helper) {
        return helper.handleRowClickEvent(component, event);
    },
    // Row select Event method
    handleRowSelectEvent: function(component, event, helper) {
        return helper.handleRowSelectEvent(component, event);
    },
    //Save Record Method
    save: function(component, event, helper) {
        return helper.save(component, event,helper);
    },
    //Refresh Method
    close: function(component, event, helper) {
        return helper.close(component, event,helper);
    }

})