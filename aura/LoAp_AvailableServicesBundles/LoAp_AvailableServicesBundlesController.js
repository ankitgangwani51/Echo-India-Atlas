({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
    
    fetchAvailableBundleRecords : function(component, event, helper) {
        helper.fetchAvailableBundleRecords(component, event, helper);
    },
    
    buttonPressed : function(component, event, helper) {
        event.stopPropagation();
        helper.buttonPressed(component, event, helper);
    },
    
    refreshView : function(component, event, helper){
        event.stopPropagation();
        helper.doInit(component, event, helper);
    }
})