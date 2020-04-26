({
    doInit: function(component) {      
        component.set('v.objBillTransfer', {'sobjectType': this.setPrefixedString('BillTransfer__c'),
                                    [this.setPrefixedString('TransferReason__c')]: '' 
                                    
                                   });
        
        // retrieve Bill Transfer field properties  and other Information to display on screen.
        let params = {"recordId" : component.get("v.recordId") };        
        this.callServer(component,'c.retrieveBillTransferDetails', 
                        function(response) {
                            var objResponse = response;
                            component.set('v.fieldList', objResponse.fieldList);
                            component.set('v.recordList', objResponse.selectedUnpaidBillList);
                            component.set('v.accId', objResponse.accountId);
                            component.set('v.BillFieldsForGeneric', objResponse.billTransferFields);
                        },
                        params);  
        
        
       /* // retrieve Bill fields properties         
        this.callServer(component,'c.retrieveBillFieldDetails', 
                        function(response) {
                            component.set('v.fieldList', response);
                        },
                        null); 
        
        // retrieve Bill Details               
        let param = {"recordId" : component.get("v.recordId")            
                    };        
        this.callServer(component,'c.getUnpaidBills', 
                        function(response) {
                            component.set('v.recordList', response);
                        },
                        param);        
        
        
        // retrieve contract Details               
        let param2 = {"recordId" : component.get("v.recordId")            
                     };        
        this.callServer(component,'c.getAccountIdDetails', 
                        function(response) {
                            component.set('v.accId', response);
                        },
                        param2);
        
        
        
        this.callServer(component,'c.retrieveTransferReasonDetails', 
                        function(response) {
                            component.set('v.BillFieldsForGeneric', response);
                        },
                        null);*/
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notification').clearNotification();
    },
    
    doActive: function(component) {
        component.set('v.isActive', true);            
    },
    
    doCancel: function(component) { 
        // Set all variables to default values 
        component.set('v.recordList', '');
        component.set('v.fieldList', '');
        component.set('v.selectedContractId', null);
        this.doInit(component);
        component.set("v.isActive", false);         
    },
    // Method is used to create bill calculation record and transfer bill by calling heroku web service.
    // Update Bill Transfer Payload,So now doing two server call instead of one.
    // First for to create bill calculation and second for calling heroku to bill transfer.
	//AT-4049 Date - 23 Oct 2018 - Dependra Singh
    doSave : function(component, event, helper) {        
        var recordList = component.get("v.recordList");
        var selectedBills = [];
        for (var i = 0; i < recordList.length; i++) {
            selectedBills.push(recordList[i].uniqueId);
        }
        if(selectedBills.length == 0){
            this.showNotification(component, [$A.get("$Label.c.CuAp_SelectedBillForTransfer ")], 'error');
            return false;
        }
        var selectedContractObject = component.get("v.selectedContractId");
        if(selectedContractObject != null){
            var selectedContractId = selectedContractObject['Id'];
        }    
        if(!component.get('v.selectedContractId')){
            this.showNotification(component, [$A.get("$Label.c.CuAp_BillTransferSelectAContract ")], 'error');
            return false;
        }
        if(selectedContractId == component.get("v.recordId")){
            this.showNotification(component, [$A.get("$Label.c.CuAp_BillTransferContract ")], 'error');
            return false;
        }
        var objBillTransfer = component.get('v.objBillTransfer');
        if(objBillTransfer[this.setPrefixedString('TransferReason__c')] == ''){
            this.showNotification(component, [$A.get("$Label.c.CuAp_BillTransferReason ")], 'error');
            return false;
        }
        
        let params = {"contractId": selectedContractId};
        this.callServer(component,'c.createBillCalculation', function(response) {
            if(response != null){
                var billCalculationId = response;
                // retrieve list of fields and properties for 
                /*let paramsTransferBill = {"selectedBillIds" : selectedBills,
                                          "contractToTransferId" : selectedContractId,
                                          "contractId" : component.get("v.recordId"),
                                          "transferReason" : objBillTransfer[this.setPrefixedString('TransferredReason__c')],
                                          "billCalculationId":billCalculationId
                                         };
                debugger;
                this.callServer(component,'c.transferBills', 
                                function(response) {    
                                    if(response == $A.get("$Label.c.GlUt_OK")){
                                        this.doCancel(component);
                                        this.showToast($A.get("$Label.c.CuAp_BillIsTransferred"));
                                        $A.get('e.force:refreshView').fire();
                                        
                                    }
                                    else{
                                        var errorMessagesNew = [];
                                        errorMessagesNew.push(response.getError()[0].message);
                                        this.showNotification(component, response, 'error');
                                        return false;
                                    }
                                },
                                paramsTransferBill); */
								
			    debugger;
				
				var action = component.get('c.transferBills');
				 action.setParams({"selectedBillIds" : selectedBills,
								   "contractToTransferId" : selectedContractId,
								   "contractId" : component.get("v.recordId"),
								   "transferReason" : objBillTransfer[this.setPrefixedString('TransferReason__c')],
								   "billCalculationId":billCalculationId
								 });
								 
				action.setCallback(this, function(response) {
		        	//return this.handleBillId(component, response);  // AT-3227
		        	this.handleResponse(component, response,helper);   // AT-3227
		        });
		        $A.enqueueAction(action);						
            }
        },params);
    },
    handleResponse: function(component, response,helper) {
		if (response.getState() === 'SUCCESS') {
			if (response.getReturnValue() != null) {
				debugger;
				this.doCancel(component,event, helper);
                this.showToast($A.get("$Label.c.CuAp_BillIsTransferred"));
                $A.get('e.force:refreshView').fire();
			}
		}else{
				debugger;
				var errorMessagesNew = [];
				errorMessagesNew.push(response.getError()[0].message);
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
    
})