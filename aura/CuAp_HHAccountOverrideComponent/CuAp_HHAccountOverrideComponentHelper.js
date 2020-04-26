({
	// fetch record types for account.
    fetchListOfRecordTypes: function(component, event, helper) {
      
	  var action = component.get("c.fetchRecordTypeValues");
      action.setCallback(this, function(response) {
         component.set("v.lstOfRecordType", response.getReturnValue());
      });
      $A.enqueueAction(action);
    },

	// override household account create page with custom household account/contact create page.
	createRecord: function(component, event, helper) {
	  var rtDet = document.querySelector('input[name="recordTypeRadio"]:checked');
      component.set("v.isOpen", true);
        if(rtDet != null){
            var action = component.get("c.getRecTypeId");
            var radios = document.getElementsByName("recordTypeRadio");
            var recordTypeLabel;
			
			//fetch record type id for selected record type
            for( var i = 0; i < radios.length; i++ ) {
				if( radios[i].checked ) {
					recordTypeLabel = radios[i].id;
				}
                 
            }
			
			action.setParams({
				"recordTypeLabel": recordTypeLabel
			});
		    action.setCallback(this, function(response) {
			   var state = response.getState();
                
			   if (state === $A.get("$Label.c.CuAp_LightningStateSuccess")) {
					var createRecordEvent = $A.get("e.force:createRecord");
					var recTypeID  = response.getReturnValue();
					var evt = $A.get("e.force:navigateToComponent");
					//redirect to custom HH account create page for Household Account record type else to standard account create page
					if(recordTypeLabel == $A.get("$Label.c.AccAp_AccountRecordTypeHouseholdAccount")){
						evt.setParams({
						   componentDef: "c:CuAp_HHCustomerPage",
						   componentAttributes:{manageFields: "true",
                                                headerValue: $A.get("$Label.c.CuAp_NewHHAccountHeader")
                                                }
						});
						evt.fire();
				    }
				    else{
						createRecordEvent.setParams({
						   "entityApiName": $A.get("$Label.c.CuAp_AccountObjectName"),
						   "recordTypeId": recTypeID
						});
						createRecordEvent.fire();
					}			
				 
				} 
				else{
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
    },

	// close the modal box.
	closeModal: function(component, event, helper) {
      
	  // set "isOpen" attribute to false for hide/close model box 
      component.set("v.isOpen", false);
	  window.history.back();
	  return false;
    }
})