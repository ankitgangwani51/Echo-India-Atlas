({
	// redirect to standard/ custom contact create page as per record type selected.
	createRecord: function(component, event, helper) {
		
        // get record type id from the url
        var url_string = window.location.href;
        var recTypeId = url_string.substring(url_string.indexOf("recordTypeId") + 13,url_string.indexOf("recordTypeId") + 28);
        
        // get the record type label from controller's getRecTypeName method 
        var action = component.get("c.getRecTypeName");
        action.setParams({
            "recordTypeId": recTypeId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
			
            if (state === $A.get("$Label.c.CuAp_LightningStateSuccess")) {
                var createRecordEvent = $A.get("e.force:createRecord");
                var recordTypeLabel  = response.getReturnValue();
                var evt = $A.get("e.force:navigateToComponent");
                // if record type is Household contact, then we invoke CuAp_HHCustomerPage lightning component
                if(recordTypeLabel == $A.get("$Label.c.CuAp_ContactRecordTypeHouseholdContact")){
                    evt.setParams({
                        componentDef: "c:CuAp_HHCustomerPage",
                        componentAttributes:{
                            manageFields: "true",
                            recordId: null,
                            recordTypeName: $A.get("$Label.c.CuAp_ContactRecordTypeHouseholdContact"),
                            headerValue: $A.get("$Label.c.CuAp_NewHHContactHeader")
                        }
                    });
                    evt.fire();
                }
                else {
                    // if record type is Other Contact, then we invoke the standard force:createRecord event 
                    createRecordEvent.setParams({
                        "entityApiName": $A.get("$Label.c.CuAp_ContactObjectName"),
                        "recordTypeId": recTypeId
                    });
                    createRecordEvent.fire();
                }          
                
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.CuAp_LightningStateNotSuccessTitle"),
                    "message": $A.get("$Label.c.CuAp_LightningStateNotSuccessMessage")
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);  
    }
})