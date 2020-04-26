({
    // On page load assign vlaues in attributes by calling server.
    doInit : function(component, event, helper) {
        let params = {"paymentId": component.get('v.recordId')}; 
        this.callServer(component,'c.getInfoToDisplay',function(response) {
            component.set("v.isShowButton", response.isShowCmp);
            component.set("v.recordList", response.fieldPropList);
            component.set("v.objPayment", response.objPaymnt);
            
        }, params);     
        this.addRow(component);
    },
    // Method is used to active component or open modal box.
    doActive : function(component, event, helper) {
        component.set('v.isActive', true);      
        this.doInit(component, event, helper);
    },
    // Method is used to close component or open modal box.
    doCancel : function(component, event, helper) {
        component.set('v.isActive', false); 
        component.set('v.addMoreInfoList', []);
        
    },
    // Validate Page Before Save.
    checkValidation : function(component, event, helper) {
        debugger;
        this.clearNotification(component);
        var atleastOneBillingContract = false;
        var addMoreInfoList = component.get('v.addMoreInfoList');
        var addMoreInfoList1 = component.get('v.addMoreInfoList');
        //Please Enter Contract to transfer the Payment to
        //At least one Contract Number must be entered
        if(addMoreInfoList.length > 0){
            var isValidRow = true;
            for (var i = 0; i < addMoreInfoList.length; i++) { 
                if (!(addMoreInfoList[i].objBillingContract && addMoreInfoList[i].objBillingContract.Id) || 
                    !addMoreInfoList[i].paymentObj[this.setPrefixedString('Amount__c')]) {
                    isValidRow = false;
                }
                var counter = 0;
                if(addMoreInfoList[i].objBillingContract && addMoreInfoList[i].objBillingContract.Id){
                    for (var j = 0; j < addMoreInfoList1.length; j++) { 
                        if(addMoreInfoList1[j].objBillingContract && addMoreInfoList1[j].objBillingContract.Id){
                            if(addMoreInfoList1[j].objBillingContract.Id == addMoreInfoList[i].objBillingContract.Id){
                                counter= counter+1;
                            }
                        }
                    }
                }      
                if(counter > 1){
                    this.showNotification(component, [$A.get("$Label.c.PyAp_SameContractCanNotBeAddedIfAlreadyExist")],'error');
                    return false;
                    break;
                }
            }
            
        }else{
            this.showNotification(component, [$A.get("$Label.c.PyAp_AtleastOneContractMustSelected")], 'error');
            return false;
        }
        if(!isValidRow){
            this.showNotification(component, [$A.get("$Label.c.PyAp_ContractNoAndAmountBothShouldBeSelected")], 'error');
            return false;
        }else{
            return true;
        }
        //Transferred Amount must less than or equal to Original Amount
        var paymentObject = component.get('v.objPayment');
        var totalAmount = paymentObject[this.setPrefixedString('Amount__c')];
        if(addMoreInfoList.transferredAmount > totalAmount){
            this.showNotification(component, [$A.get("$Label.c.PyAp_TransferedAmountMustLessThanOriginalAmount")], 'error');
            return false;
        }
    },
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notification').clearNotification();
    },
    
   // Method is used to save the split payment records 
    doSave : function(component, event, helper) {
        debugger;
        if(this.checkValidation(component, event, helper)){
            var addMoreInfoObj = component.get('v.addMoreInfoList');
            var finalDataObjectArray = new Array();
            for (var i = 0; i < addMoreInfoObj.length; i++) { 
                var childDataObject = new Object();
                delete addMoreInfoObj[i].objBillingContract['TransformField__t'];
                childDataObject.objBillingContract = addMoreInfoObj[i].objBillingContract;
                childDataObject.paymentObj = addMoreInfoObj[i].paymentObj;
                finalDataObjectArray.push(childDataObject);
            }
            // Creating final object and making JSOn string to call server.
            var finalDatObject = new Object();
            finalDatObject.records = finalDataObjectArray;
            var originalPayment =  component.get("v.objPayment");
            delete originalPayment[$A.get("$Label.c.PyAp_TransferredAmount")];
            delete originalPayment[$A.get("$Label.c.PyAp_RemaningAmount")];
            
            finalDatObject.objPayment= originalPayment;
            finalDatObject.transferredAmount = addMoreInfoObj.transferredAmount;
            finalDatObject.remaningAmount = addMoreInfoObj.remaningAmount;
            let params = {"jsonString": JSON.stringify(finalDatObject)}; 
            this.callServer(component,'c.SaveSplitPaymentsData',function(response) {
                if(response){
                    this.showToast($A.get("$Label.c.PyAp_SplitPaymentsSuccessfullyCreated"));
                    this.doCancel(component, event, helper);
                }
                
            }, params);
        }
    },
    
    // function for delete the row
    removeRow : function(component, event, helper){
        var index = event.currentTarget.parentElement.parentElement.cells[0].innerHTML;
        // get the all List (addMoreInfoList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.addMoreInfoList");
        AllRowsList.splice(parseInt(index-1), 1);
        // set the addMoreInfoList after remove selected row element  
        component.set("v.addMoreInfoList", AllRowsList);
    }, 
    
    // add a biller row to the table
    addRow: function(component) {
        // check for a blank row
        var addMoreInfoObj = component.get('v.addMoreInfoList');
        var blankRow = false;
        for (var i = 0; i < addMoreInfoObj.length; i++) { 
            if (!(addMoreInfoObj[i].objBillingContract && addMoreInfoObj[i].objBillingContract.Id)) {
                blankRow = true;
                break;
            }
        }
        // add a new row if not already a blank row
        if (!blankRow) {
            this.callServer(component, 'c.AddMoreRows', function(response) {
                var paymentObj =  {'sobjectType': this.setPrefixedString('Payment__c')};
                response.paymentObj = paymentObj;
                var wrappers = component.get('v.addMoreInfoList');
                wrappers.push(response);
                component.set('v.addMoreInfoList', wrappers);
            },null);
        }
    },
    // Handle custom look up change event.
    handleCustomLookUpEvent: function(component, event, helper) {	
        this.assignAccountNameInList(component, event, helper);
        
    },
    // Set account Name on select of contract.
    assignAccountNameInList: function(component, event, helper) {	
        var objectValue = event.getParam("objectVal");
        var addMoreInfoObj = component.get('v.addMoreInfoList');
        for (var i = 0; i < addMoreInfoObj.length; i++) { 
            var tempObject = addMoreInfoObj[i];
            if (addMoreInfoObj[i].objBillingContract && addMoreInfoObj[i].objBillingContract.Id) {
                if (addMoreInfoObj[i].objBillingContract.Id == objectValue.Id && !addMoreInfoObj[i].objBillingContract['AccountName']) {
                    if(addMoreInfoObj[i].objBillingContract[this.setPrefixedString('AccountName__c')]){
                        let params = {"accountRecordId": addMoreInfoObj[i].objBillingContract[this.setPrefixedString('AccountName__c')]}; 
                        this.callServer(component,'c.getAccountNameById',function(response) {
                            tempObject.strAccountName = response;
                            addMoreInfoObj[i-1].objBillingContract['AccountName']=response;
                            addMoreInfoObj[i-1] = tempObject;
                            component.set('v.addMoreInfoList', addMoreInfoObj);
                        }, params);
                    }
                }
            }
        }
    },
    // Handle input change event of amount field.
    handleInputChangeEvent:function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams['objectName'] == this.setPrefixedString('Payment__c')){
            var wrappers = component.get('v.addMoreInfoList');
            var transferredAmount = 0.0;
            var remaningAmount = 0.0;
            for (var i = 0; i < wrappers.length; i++) { 
                if (wrappers[i].objBillingContract && wrappers[i].objBillingContract.Id) {
                    if(wrappers[i].paymentObj[this.setPrefixedString('Amount__c')]){
                        transferredAmount += wrappers[i].paymentObj[this.setPrefixedString('Amount__c')];
                    }
                }
            }
            var paymentObject = component.get('v.objPayment');
            var totalAmount = paymentObject[this.setPrefixedString('Amount__c')];
            remaningAmount = totalAmount- transferredAmount;
            wrappers.transferredAmount = transferredAmount;
            wrappers.remaningAmount = remaningAmount;
            paymentObject[$A.get("$Label.c.PyAp_TransferredAmount")] = transferredAmount;
            paymentObject[$A.get("$Label.c.PyAp_RemaningAmount")] = remaningAmount;
            component.set('v.objPayment',paymentObject);
            
        }
    },
    // show toast message and return
    showToast: function(result) {    	 	
        var message = result;
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
})