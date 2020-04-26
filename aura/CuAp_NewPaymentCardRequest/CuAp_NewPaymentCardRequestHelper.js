({
	doInit : function(component, event, helper) {        
        let params ={
            'contractId': component.get('v.recordId')         
        };
        this.callServer(component, 'c.allowPaymentCardRequest',
                        function(response) {
                            component.set('v.resultContainer', response);
                            component.set('v.isShow', component.get('v.resultContainer').allowRequest);
                            component.set('v.paymentPlanIdList', component.get('v.resultContainer').paymentPlanIdList);
                        },
                        params);								
	},
    
    changeRequestedOnDate: function(component, event, helper) {    
        let params ={
            'paymentPlanIdList': component.get('v.paymentPlanIdList')
        };
        this.callServer(component, 'c.doChangeRequestedOnDate',
                        function(response) { 
                            var isUpdated = response;
                            var message;   
                            var toastEvent = $A.get("e.force:showToast");
                            if(isUpdated){
                                message = "$Label.c.CuAp_RequestedDateNotification";
                                toastEvent.setParams({
                                    "type": "success",
                                    "message": $A.get(message) 
                                });                                
                            }
                            else{
                                message = "$Label.c.CuAp_PaymentPlanCardNotFound";      
                                toastEvent.setParams({
                                    "type": "error",
                                    "message": $A.get(message) 
                                });
                            }                             
                            toastEvent.fire(); 
                        },
                        params);   
    },
})