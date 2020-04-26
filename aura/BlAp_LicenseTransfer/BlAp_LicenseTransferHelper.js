({
    // Init function calling on page load to initialize variables.
    doInit: function(component,event, helper) {
        component.set('v.objRuralLicenseReadOnly', {'sobjectType': this.setPrefixedString('RuralLicense__c')});
        component.set('v.objRuralLicense', {'sobjectType': this.setPrefixedString('RuralLicense__c'),
                                            [this.setPrefixedString('TransferDate__c')]: '' 
                                            
                                           });
    },
    
    // Method is calling from on click of license transfer button to show modal box. 
    doActive: function(component,event, helper) {
        component.set('v.isActive', true);     
        // Calling server method to display the information.
        let params = {"ruralLicenseRecordId" : component.get("v.recordId")}; 
        this.callServer(component,'c.getInfoToDisplay', 
                        function(response) {
                            debugger;
                            component.set('v.objWrapper', response);
                            component.set('v.currentContractFieldList', response.currentContractFieldList);
                            component.set('v.transferDateFieldList', response.transferDateList);
                            component.set('v.objRuralLicenseReadOnly', response.ruralLicenseObj);
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
        
        var objRuralLicenseRecord = component.get('v.objRuralLicenseReadOnly');
        var oldBillingContract = objRuralLicenseRecord[this.setPrefixedString('BillingContract__c')];
        var selectedContractId = component.get('v.selectedContractId');    
        
        if(!component.get('v.selectedContractId')){
            this.showNotification(component, [$A.get("$Label.c.BlAp_RuralLicenseNewContractVal ")], 'error');
            return false;
        }  
        if(oldBillingContract == selectedContractId['Id']){
            this.showNotification(component, [$A.get("$Label.c.BlAp_RuralLicenseNewContractVal ")], 'error');
            return false;
        }
        
        var objRuralLicense = component.get('v.objRuralLicense');
        var licenseStartDate = objRuralLicenseRecord[this.setPrefixedString('StartDate__c')];
        
        if(objRuralLicense[this.setPrefixedString('TransferDate__c')] == '' || objRuralLicense[this.setPrefixedString('TransferDate__c')] < licenseStartDate){
            this.showNotification(component, [$A.get("$Label.c.BlAp_RuralLicenseTransferDateVal ")], 'error');
            return false;
        }
        
        //return;
        
        let params = {"ruralLicenseID" : component.get("v.recordId"),
                      "contractToTransferID" : selectedContractId['Id'],
                      "transferDate" : objRuralLicense[this.setPrefixedString('TransferDate__c')]
                     };
        helper.callServer(component,'c.doLicenseTransfer', function(response) {
            if(response != null){
                var ruralLicenseId = response.newRuralLicenseId;
                var billCalculationId = response.newBillCalculationId;
                // Call transferDebts method and call heroku api to transfer license information
                var action = component.get('c.callHerokuTotransferLicense');
                action.setParams({
                    "oldRuralLicenseID" : component.get("v.recordId"),
                    "contractToTransferID" : selectedContractId['Id'],
                    "newRuralLicenseId":ruralLicenseId,
                    "billCalculationId":billCalculationId
                });
                action.setCallback(this, function(response) {
                    this.handleResponse(component, response,helper);
                });
                $A.enqueueAction(action);				 
            }
        },params);
        
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
                this.showToast($A.get("$Label.c.BlAp_LicenseTransferSuccess"));
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