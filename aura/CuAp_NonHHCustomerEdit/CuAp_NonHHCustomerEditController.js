({
/***************************************************************************************
Author: Pratyush Kumar
@date:  06-12-2017
Description: Method to call method to fire save record.
****************************************************************************************/ 
	saveRecord: function(component, event, helper) {
       helper.saveRecord(component, event, helper);
   },
/***************************************************************************************
Author: Pratyush Kumar
@date:  06-12-2017
Description: Method to close modal box.
****************************************************************************************/ 
    closeModal: function(component, event, helper) {
       helper.closeModal(component, event, helper);
    },
/***************************************************************************************
Author: Pratyush Kumar
@date:  06-12-2017
Description: Method to redirect to the detail page when the reord is saved successfully.
****************************************************************************************/ 
    onSaveSuccess : function(component, event, helper) {
        helper.onSaveSuccess(component, event, helper);
    }
})