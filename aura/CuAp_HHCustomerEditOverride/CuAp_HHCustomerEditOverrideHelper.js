({
	// check record type of opened record and open standard/ custom edit page as per record type of record.
	doInit : function(component, event, helper) {
		
		//Call apex method to check record type of record opened
		var action = component.get("c.getHHAccountRecordTypeName");
        var recId = component.get("v.recordId");
        action.setParams({
         "recordId": recId
      	});
        action.setCallback(this, function(response) {
            var recTypeName  = response.getReturnValue();
            component.set('v.recordType',recTypeName); 
            //var evt = $A.get("e.force:navigateToComponent");   // --AT-1269
			var editRecordEvent = $A.get("e.force:editRecord");
			
			//redirect to custom HH page if record type is husehold account/ contact  
			/* --AT-1269
            if(recTypeName == $A.get("$Label.c.AccAp_AccountRecordTypeHouseholdAccount")){
               
                
                evt.setParams({
                    componentDef: "c:CuAp_HHCustomerPage",
                    componentAttributes:{
										 manageFields: "true",
                                         recordId: recId,
                                         headerValue: $A.get("$Label.c.CuAp_HHAccountEdit")
										}
            	});
                evt.fire();
            }
			else if(recTypeName == $A.get("$Label.c.CuAp_ContactRecordTypeHouseholdContact")){
                evt.setParams({
                   componentDef: "c:CuAp_HHCustomerPage",
                    componentAttributes:{
										 manageFields: "true",
                                         recordId: recId,
                                         headerValue: $A.get("$Label.c.CuAp_HHContactEdit")
										}
            	});
                evt.fire();
            } 
			else{
                
				// fire the component which will invoke the standard Edit component if record type is NHH account/ contact
                if(recTypeName == 'Other Contact'){
                    evt.setParams({
                       componentDef: "c:CuAp_NonHHCustomerEdit",
                        componentAttributes:{
                                             recordId: recId,
                                             headerValue: "Edit Contact"
                                            }
                    });
                }
                else{
                    evt.setParams({
                       componentDef: "c:CuAp_NonHHCustomerEdit",
                        componentAttributes:{
                                             recordId: recId,
                                             headerValue: "Edit Account"
                                            }
                    });
                }
                evt.fire();
            
            }
            */
        });
        $A.enqueueAction(action);
	}
})