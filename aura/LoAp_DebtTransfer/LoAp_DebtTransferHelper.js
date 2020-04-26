({
    // Init function calling on page load to initialize variables.
    doInit: function(component,event, helper) {
        component.set('v.objLocation', {'sobjectType': this.setPrefixedString('Location__c')});
        component.set('v.objBillTransfer', {'sobjectType': this.setPrefixedString('BillTransfer__c'),
                                            [this.setPrefixedString('TransferReason__c')]: '' 
                                            
                                           });
    },
    
    // Method is calling from on click of debt transfer button to show modal box. 
    doActive: function(component,event, helper) {
        component.set('v.isActive', true);     
        // Calling server method to display the information.
        let params = {"locationRecordId" : component.get("v.recordId")}; 
        this.callServer(component,'c.getInfoToDisplay', 
                        function(response) {
                            debugger;
                            component.set('v.objWrapper', response);
                            component.set('v.locationFieldList', response.locationFieldList);
                            component.set('v.billFieldList', response.transferReasonList);
                            component.set('v.objLocation', response.locationObj);
                            //component.set('v.isDebtExist', response.isDebtExist);
                            var locationObj = component.get('v.objLocation');
                            locationObj['DebtAmount'] = response.debtAmount;
                            component.set("v.objLocation", locationObj);
                            debugger;
                        },
                        params);
    },
    
    // Calling this helper method on cancel button to close modal box
    doCancel: function(component,event, helper) { 
        // Set all variables to default values 
        component.set("v.isActive", false);         
    },
    
    // Helper method is used to call apex function to call Heroku API
    doSave : function(component,event, helper) {    
        var locationObj = component.get('v.objLocation');
        if(locationObj['DebtAmount']  && locationObj['DebtAmount'] > 0){
            if(!component.get('v.selectedContractId')){
                this.showNotification(component, [$A.get("$Label.c.CuAp_BillTransferSelectAContract ")], 'error');
                return false;
            }    
            var objBillTransfer = component.get('v.objBillTransfer');
            if(objBillTransfer[this.setPrefixedString('TransferReason__c')] == ''){
                this.showNotification(component, [$A.get("$Label.c.CuAp_BillTransferReason ")], 'error');
                return false;
            }
            var selectedContractId = component.get('v.selectedContractId');
            let params = {"contractId": selectedContractId['Id']};
            helper.callServer(component,'c.createBillCalculation', function(response) {
                if(response != null){
                    var billCalculationId = response;
                    // Call transferDebts method and call heroku api to transfer debt information
                    var action = component.get('c.transferDebts');
                    action.setParams({"LocationID" : component.get("v.recordId"),
                                      "contractToTransferID" : selectedContractId['Id'],
                                      "transferReason" : objBillTransfer[this.setPrefixedString('TransferReason__c')],
                                      "billCalculationId":billCalculationId
                                     });
                    
                    action.setCallback(this, function(response) {
                        this.handleResponse(component, response,helper);
                    });
                    $A.enqueueAction(action);				 
                    
                }else{
                    var errorMessagesNew = [];
                    errorMessagesNew.push(response.getError()[0].message);
                    this.showNotification(component, errorMessagesNew, 'error');
                    return false;
                }
            },params);
        }else{
            var errorMessagesNew = [];
            errorMessagesNew.push($A.get("$Label.c.LoAp_NoDebtExistForThisLocation"));
            this.showNotification(component, errorMessagesNew, 'error');
            return false;
        }
        
    },
    
    // show toast message and return
    showToast: function(result) {    	 	
        var message = result;
        switch (result) {
            case $A.get("$Label.c.GlAp_Success"):
                message = $A.get("$Label.c.GuAp_RecordSuccessfullyUpdatedMsg");
                break;        
        }
        if (message) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title":  $A.get("$Label.c.GuAp_SuccessTitle"),
                "type": $A.get("$Label.c.GlAp_Success"),
                "message": message
            });
            toastEvent.fire();
        }      
    },    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    //Handling response 
    handleResponse: function(component, response,helper) {
        if (response.getState() === 'SUCCESS') {
            if (response.getReturnValue() != null) {
                this.doCancel(component,event, helper);
                this.showToast($A.get("$Label.c.LoAp_DebtTransferred"));
                $A.get('e.force:refreshView').fire();
            }
        }else{
            var errorMessagesNew = [];
            errorMessagesNew.push(response.getError()[0].message);
            this.showNotification(component, errorMessagesNew, 'error');
            return false;
            
        }
    },
})