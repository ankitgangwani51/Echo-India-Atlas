({
/***************************************************************************************
Author: Pratyush Kumar
@date:  06-12-2017
Description: Method to call method to fire save record.
****************************************************************************************/ 
    saveRecord: function(component, event, helper) {
        component.find("editRecordId").get("e.recordSave").fire();
    },
/***************************************************************************************
Author: Pratyush Kumar
@date:  06-12-2017
Description: Method to close modal box.
****************************************************************************************/
    closeModal: function(component, event, helper) {	
        var communities = component.get("v.communities");
        if(communities == true){
            $A.get("e.force:navigateToURL").setParams({
                "url": "/my-account",
                isredirect: true
            }).fire();
        }else{
            window.history.go(-2);
        }
    },
/***************************************************************************************
Author: Pratyush Kumar
@date:  06-12-2017
Description: Method to redirect to the detail page when the reord is saved successfully.
****************************************************************************************/
    // Method to redirect to the detail page when the reord is saved successfully
    onSaveSuccess : function(component, event, helper) {
        var communities = component.get("v.communities");
        var recordId = component.get('v.recordId');
        if(communities){//AT-1269
            $A.get("e.force:navigateToURL").setParams({
                "url": communities == true ? "/my-account" : '/' + recordId,
                isredirect: true
            }).fire();
        }
        else {//AT-1269
            window.location = '/one/one.app#/sObject/' + recordId;
        }
    }
})