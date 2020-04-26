({
    //Initialization/Constructor method for current component.
    doInit: function(component, event, helper) {
        component.set('v.paymentObject', {'sobjectType': this.setPrefixedString('Payment__c')});
        component.set('v.selectedContractId', {'sobjectType': this.setPrefixedString('BillingContract__c')});
        
        var optionList = [];
        optionList.push({
            label: $A.get("$Label.c.PyAp_PaymentAmendmentOption1"),
            value: $A.get("$Label.c.PyAp_PaymentAmendmentOptValue1")
        });
        optionList.push({
            label: $A.get("$Label.c.PyAp_PaymentAmendmentOption2"),
            value: $A.get("$Label.c.PyAp_PaymentAmendmentOptValue2")
        });
        component.set('v.options',optionList);
        component.set('v.radioValue',optionList[0].value);
        
        this.callServer(component,'c.retrievePaymentFields', 
                        function(response) {
                            component.set('v.paymentFields', response);
                        },
                        null);
        this.getExistingAccount(component, event, helper);
        component.set('v.selectedContractId','');
        
    },
    // Function call when attribute 'existingPaymentAccount' value changed
    handleSelectedAccountValueChange: function(component) {
        component.set("v.selectedContractId",null); 
    },
    // call the notifier method to show a message on the notification component.
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // method to perform the dml operation in order to save and update the payment records for transfer payment or return payment scenario.
    doSave: function(component, event, helper) {
        var ErrorMessageVal = [];
        var paymentType = component.get('v.radioValue');
        console.log('originalPaymentRecordType === '+JSON.stringify(component.get('v.originalPaymentRecordType')))
        console.log('label === '+$A.get("$Label.c.PyAp_ReturnTransferPaymentRecordType"));
        if(component.get('v.originalPaymentRecordType') == $A.get("$Label.c.PyAp_ReturnTransferPaymentRecordType") || component.get('v.isPaymentExist')){
            ErrorMessageVal.push($A.get("$Label.c.PyAp_AmendmentError"));
        }else{
            if(component.get('v.paymentObject')[this.setPrefixedString('PaymentTransferReason__c')] == undefined  || component.get('v.paymentObject')[this.setPrefixedString('PaymentTransferReason__c')] == ''){
                if(paymentType == $A.get("$Label.c.PyAp_PaymentAmendmentOptValue1"))
                    ErrorMessageVal.push($A.get("$Label.c.PyAp_ReasonForReturn"));
                else
                    ErrorMessageVal.push($A.get("$Label.c.PyAp_ReasonForTransfer"));    
            }
            if(paymentType == $A.get("$Label.c.PyAp_PaymentAmendmentOptValue2")){
                
                if(component.get('v.isTransferToSuspense') == false){
                    if(component.get('v.existingPaymentAccount') == undefined || component.get('v.existingPaymentAccount') == ''){
                        ErrorMessageVal.push($A.get("$Label.c.PyAp_AccountContractSelectionError"));
                    }else if(component.get('v.selectedContractId') == null){
                        ErrorMessageVal.push($A.get("$Label.c.PyAp_AccountContractSelectionError"));
                    }else if(component.get('v.selectedContractId').Id == undefined || component.get('v.selectedContractId').Id == ''){
                        ErrorMessageVal.push($A.get("$Label.c.PyAp_AccountContractSelectionError"));
                    }
                }
            }
        }
        // Check if there is any error in array
        if(ErrorMessageVal.length > 0  ){
            this.showNotification(component,ErrorMessageVal, 'error');
        }
        else{
            var originalPaymentId = component.get('v.recordId');
            var paymentTransferReason = component.get('v.paymentObject')[this.setPrefixedString('PaymentTransferReason__c')];
            var selectedContractId;
            var selectedAccountId;
            let params1={
                'originalPaymentId': originalPaymentId,
            };
            
            this.callServer(component,'c.getLocationOnPayment', 
                            function(response) {
                                if(response && paymentType == $A.get("$Label.c.PyAp_PaymentAmendmentOptValue2")){
                                    this.showNotification(component, [$A.get("$Label.c.PyAp_SettlementError")],'error');
                                    return false;  
                                }
                                else{
                                    if(component.get('v.isTransferToSuspense') == false){
                                        if(component.get('v.selectedContractId') != null)
                                            selectedContractId = component.get('v.selectedContractId').Id;
                                        if(component.get('v.existingPaymentAccount') !=null)
                                            selectedAccountId = component.get('v.existingPaymentAccount').Id;
                                    }
                                    
                                    let params = {
                                        'originalPaymentId': originalPaymentId,
                                        'paymentType': paymentType,
                                        'paymentTransferReason' : paymentTransferReason,
                                        'selectedContractId' : selectedContractId,
                                        'selectedAccountId' : selectedAccountId,
                                        'isDoNotPrint': component.get('v.isDoNotPrint')  // AT-4897
                                    }; 
                                    
                                    // Call server method to update and create a payment record for return payment or transfer payment scenario.
                                    this.callServer(component,'c.paymentAmendment', 
                                                    function(response) {
                                                        //To check there is no exception from server & navigate to record                                  
                                                        if(response != null && response != undefined && response.indexOf("Error") == -1){
                                                            var toastEvent = $A.get("e.force:showToast");
                                                            toastEvent.setParams({
                                                                "title": "Success!",
                                                                "type":"Success",
                                                                "message": $A.get("$Label.c.PyAp_SuccessMessage")
                                                            });
                                                            toastEvent.fire();
                                                            var urlEvent = $A.get("e.force:navigateToSObject");
                                                            urlEvent.setParams({
                                                                "recordId": component.get('v.recordId'),
                                                                "isredirect": "true"
                                                            });
                                                            urlEvent.fire();
                                                        }
                                                        if(response.indexOf("Error") != -1){
                                                            var errorMsg = [];
                                                            errorMsg.push(response);
                                                            this.showNotification(component,errorMsg, 'error');
                                                        }
                                                    },
                                                    params);
                                    
                                }
                            },
                            params1);
            
            
        }
        
    },
    //Had to add the call server here as there was an issue when resolving the
    //component when going to the base class
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });       
        $A.enqueueAction(action);
    },
    //Show or hide the transfer payment section.
    showDetailsSection: function(component, event, helper) {  
        var changeValue = event.getParam("value");
        if(changeValue == $A.get("$Label.c.PyAp_PaymentAmendmentOptValue1")){
            component.set('v.isShowTransfer',false); 
        }
        if(changeValue == $A.get("$Label.c.PyAp_PaymentAmendmentOptValue2")){
            component.set('v.isShowTransfer',true); 
        }
    },
    // Hide/Refresh the component.
    doCancel: function(component, event, helper) {
        component.set('v.isShowTransfer', false);
        component.set('v.isActive', false);
        component.set('v.radioValue',$A.get("$Label.c.PyAp_PaymentAmendmentOptValue1"));
        component.set('v.selectedContractId','');
        component.set('v.paymentObject','');
        component.set('v.isDoNotPrint',false);  //AT-4897        
        this.getExistingAccount(component, event, helper);
        
    },
    // Fetch the existing account associated with current payment record.
    getExistingAccount: function(component, event, helper) {
        var originalPaymentId = component.get('v.recordId');
        let params = {
            'originalPaymentId': originalPaymentId
        }
        this.callServer(component,'c.getExistingPaymentAccount',
                        function(response){
                            console.log('response********** ==== '+JSON.stringify(response));
                            component.set("v.resultContainer", response);
                            component.set("v.isPaymentExist" , component.get("v.resultContainer").isPaymentExist);
                            component.set("v.existingPaymentAccount" , component.get("v.resultContainer").Account);
                            component.set("v.originalPaymentRecordType" , component.get("v.resultContainer").existingRecordTypeName);
                            if(component.get('v.originalPaymentRecordType') == $A.get("$Label.c.PyAp_ReturnTransferPaymentRecordType") || component.get('v.isPaymentExist')){
                                component.set('v.isPaymentExist', true); 
                            }
                            console.log('isPaymentExist********** ==== '+component.get('v.isPaymentExist'));
                        },                         
                        params);
    },
    // Activate the component.
    doPageActive: function(component, event, helper) {
        component.set('v.isActive', true);
    }
})