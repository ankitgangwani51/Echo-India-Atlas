({
    // On page load assign vlaues in attributes by calling server.
	doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    // Method is used to show modal.
    doActive : function(component, event, helper) {
		helper.doActive(component);
	},
    // Method is used to hide modal.
    doCancel : function(component, event, helper) {
        helper.doCancel(component);
    },
    // Method is used to save data afer validating it.
    doSave : function(component, event, helper) {
        helper.doSave(component, event, helper);
    },
    // method to display a new row of additional biller on click of Add more button
    addMoreRows: function(component, event, helper) {	
        helper.addRow(component);
    },
    //Method is  used to handle chnage event fo inout field.
    handleInputChangeEvent:function(component, event, helper) {
        return helper.handleInputChangeEvent(component, event, helper);
    },
    // Method is used to handle response of custom lookup field.
    handleCustomLookUpEvent: function(component, event, helper) {	
        helper.handleCustomLookUpEvent(component, event, helper);
    },
    //Method is used to delete row from the tabel.
    removeRow : function(component, event, helper){
        // deleted Row Index to Event parameter/attribute
      helper.removeRow(component, event, helper);
    }, 
    
})