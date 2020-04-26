({ 
	// call apex method to fetch list of record types for account.
	fetchListOfRecordTypes: function(component, event, helper) {
       helper.fetchListOfRecordTypes(component, event, helper);
	},

	// redirect to account create page as per the record type selected.
	createRecord: function(component, event, helper) {
       helper.createRecord(component, event, helper);
	},

	// close the modal box.
	closeModal: function(component, event, helper) {
       helper.closeModal(component, event, helper);
	}
})