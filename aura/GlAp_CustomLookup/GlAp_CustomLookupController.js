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
    // Added event on selection of object if need to pass value in parent component- Added By Dependra- 25-01-2019
    itemsChange : function(component, event, helper) {	
        helper.itemsChange(component, event, helper);
    }
})