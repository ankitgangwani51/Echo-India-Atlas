({
    // This function will display the list of instalments in the generic table with table header
	doInit: function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
    
    // This function will get the list of selected instalments to delete
    handleRowSelectEvent: function(component, event, helper) {
		helper.handleRowSelectEvent(component, event, helper);
    },
    
    // This function is allocate the first instalment amount to the first instalment and spread the remaining amount to the remaining instalments
    doSpreadRemaining: function(component, event, helper) {
		helper.doSpreadRemaining(component, event, helper);
    },
    
    // This function will delete the selected instalments
    doDeleteSelected: function(component, event, helper) {
		helper.doDeleteSelected(component, event, helper);
    },
    
    // This function is basically for the confirmation for delete selected instalments
    doDeleteQuestion: function(component, event, helper) {
		helper.doDeleteQuestion(component, event, helper);
    },
    
    // This function will close the delete confirmation modal
    doCancelQuestion: function(component, event, helper) {
		helper.doCancelQuestion(component, event, helper);
    }
})