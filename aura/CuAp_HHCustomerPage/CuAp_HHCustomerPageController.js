({
	// open screen and show data in fields.
    doInit : function(component, event, helper) {
		helper.getData(component, event, helper);        
	},

	// bypass duplicate rules and save account and contact records.
    bypassDuplicates : function(component, event, helper) {
		helper.bypassDuplicates(component, event, helper);        
	},

	// save HH account and contact.
    doSave: function(component, event, helper) {
      helper.doSave(component, event, helper);
    },

	// close modal box.
	closeModal: function(component, event, helper) {
        helper.closeModal(component, event, helper);
    },

	// refresh screen with the current record details.
    reloadView : function(component, event, helper) {
        console.log("*** Refresh View ***");
        helper.reloadView(component, event, helper);        
    },
})