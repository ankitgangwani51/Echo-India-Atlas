({
	// Select the record from the list
    itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	},
    
    // Call the server
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    
    // Remove the selected record
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    },
    itemsChange: function(component, event, helper) {	
        helper.itemsChange(component, event, helper);
    },
})