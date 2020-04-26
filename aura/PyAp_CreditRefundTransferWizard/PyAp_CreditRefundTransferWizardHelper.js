({
    DEBUG: 'CreditRefundTransferWizard: ',
    
    // override method for local initialisation
    doLocalInit: function(component, event, helper) {
        // add the contractId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        component.set('v.wizardprop', wizObj);
        this.fetchContractId(component,helper, true)
        component.set('v.startStep', true);
        component.set('v.endStep', true);
    },
    //Method is used to get the contract id and credit details from balance.
    fetchContractId: function(component,helper, init) {
        var wizObj = component.get('v.wizardprop');
        var action = component.get('c.getContractId');
        action.setParams({
            'strBalanceId' : wizObj.recordId
        });
        this.setWizardSteps(component);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var strBalanceAmount = 0.0;
                wizObj.contractId =response.getReturnValue();
                
                let params = {"contractId": wizObj.contractId};
                // Server call to get actual credit amount.
                this.callServer(component,'c.getCreditDetails', function(resp){
                    debugger;
                    var objBalanceWrapper = resp;
                    wizObj.creditAmount = objBalanceWrapper.totalCreditAmount;
                    wizObj.alreadyRequestedRefundAmount = objBalanceWrapper.alreadyRequestedCreditAmount;
                    wizObj.isInActiveWithDebt = objBalanceWrapper.isInActiveWithDebt;
                    /*  strBalanceAmount = parseFloat(resp); 
                    wizObj.creditAmount = strBalanceAmount;*/
                    component.set('v.wizardprop', wizObj); 
                    this.callApexWizardStatus(component, true);	
                    
                },params);  
            } else {
                console.log('Error: ' + response.getError()[0].message);
                this.showNotification('An error occured when contacting the server', 'error');
            }
        });
        $A.enqueueAction(action);
    },
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        if (component.find('refundTransferCreditError') != undefined) component.find('refundTransferCreditError').reInitialise();
        if (component.find('refundTransferCreditPage') != undefined) component.find('refundTransferCreditPage').reInitialise();
    },
    
    // check the current page on entry
    checksOnEntry: function(component) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.PyAp_CreditPayment"):
                if (component.find('refundTransferCreditError') != undefined) component.find('refundTransferCreditError').checksOnEntry()
                break;    
            case $A.get("$Label.c.CuAp_PaymentPlanPage3"):
                if (component.find('refundTransferCreditPage') != undefined) component.find('refundTransferCreditPage').checksOnEntry()
                break;
        }
    },
    
    // override method for navigation with validation/server calls 
    navigateStep: function(component, event, helper) {
        var message = event.getParam('message');
        if (message === 'CANCEL') {
            this.reInitialiseAllSteps(component);
            this.doCancel(component, event, helper);
            
        } else if (message === 'NEXT') {
            if (this.validateOnNext(component)) {
                //this.doNext(component, event, helper);
                this.checksOnEntry(component);
            }
            
        } else if (message === 'BACK') {
            this.doBack(component, event, helper);
            this.checksOnEntry(component);
        }
    },
    
    // validate the current page on exit to the next page
    // returns true if page validates
    validateOnNext: function(component) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.PyAp_CreditPayment"):
                if (component.find('refundTransferCreditError') == undefined
                    || component.find('refundTransferCreditError').validateOnNext()) {
                    // update the wizard steps
                    this.updateWizardSteps(component);
                    return true;
                }
                break;       
            case $A.get("$Label.c.CuAp_PaymentPlanPage3"):
                if (component.find('refundTransferCreditPage') == undefined
                    || component.find('refundTransferCreditPage').validateOnNext()) {
                    this.callApexRefundTransfer(component);
                    return true;
                }
                break;
                
            default:
                return true;
        }
    },
    
    // initialise the wizard steps
    initialiseWizardSteps: function(component) {
        
        // update the list of steps
        this.callApexWizardStatus(component, true);
    },
    
    // update the wizard steps following a wizard property change
    updateWizardSteps: function(component) {
        // update the list of steps
        this.callApexWizardStatus(component);
    },
    
    // update the wizard step names based on validation
    setWizardSteps: function(component) {
        function remove(array, element) {
            const index = array.indexOf(element);
            if (index !== -1) {
                array.splice(index, 1);
            }
        }
        const allStepNames = [
            $A.get("$Label.c.PyAp_CreditPayment"),
            $A.get("$Label.c.CuAp_PaymentPlanPage3")
        ];
        
        // clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        var isBudgetPlan = component.get('v.isBudgetPlan');
        if(isBudgetPlan){
            remove(stepNames, $A.get('$Label.c.CuAp_PaymentPlanPage3'));
        }else{
            remove(stepNames, $A.get('$Label.c.PyAp_CreditPayment'));
        }
        // initialise the stepNames
        component.set('v.stepNames', stepNames);
    },
    
    // call the server to complete create credit refund or transfer. 
    callApexRefundTransfer: function(component) {
        debugger;
        component.find('spinner').show();
        var action = component.get('c.creditRefundTransfer');
        console.log('Final Wizardprop Values = '+JSON.stringify(component.get('v.wizardprop')));
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            debugger;
            var balanceId = this.handleCreateRefundTransferResponse(component, response);
            if (balanceId) this.goToRecord(balanceId);
        });
        $A.enqueueAction(action);
    },        
    // handle the create credit refund or transfer response
    handleCreateRefundTransferResponse: function(component, response) {
        component.find('spinner').hide(); 
        if (response.getState() === 'SUCCESS') {        
            
            // good exit
            if (response.getReturnValue() != null) {
                console.log('Success msg: '+response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"Success",
                    "message": $A.get("$Label.c.PyAp_CreditRefundTransferSucessMessage")
                });
                toastEvent.fire();
                return response.getReturnValue();
                
                // null exit
            } else {
                console.log('Error msg: '+response.getReturnValue());
                this.handleError(component, response);
            }
            
            // error exit
        } else {
            console.log('Error msg: '+response.getReturnValue());
            this.handleError(component, response);
        }
        return false;        
    },
    
    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {   
        var action = component.get('c.wizardStatus');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var status = response.getReturnValue();
                component.set('v.status', status);
                console.log(this.DEBUG + 'status: ' + JSON.stringify(status));
                if(status[$A.get('$Label.c.CuAp_PaymentPlanTypePlanTypeBudgetPlan')]){ 	
                    component.set('v.isBudgetPlan', true);
                }else{
                    component.set('v.isBudgetPlan', false);	
                }
                // update the steps
                this.setWizardSteps(component);
                if (init) {		// set to the first step
                    var stepNames = component.get('v.stepNames');
                    component.set('v.stepName', stepNames[0]);
                    this.checksOnEntry(component);
                }
                // set the progress path
                this.doSetProgressPathDetails(component);    
                
            } else {
                console.log('Error: ' + response.getError()[0].message);
                this.showNotification('An error occured when contacting the server', 'error');
            }
        });
        $A.enqueueAction(action);
    }, 
})