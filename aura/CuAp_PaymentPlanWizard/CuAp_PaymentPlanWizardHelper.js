({
    DEBUG: 'PP Wizard: ',
    // override method for local initialisation
    doLocalInit: function(component, event, helper) {
        
        // add the contractId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.contractId = wizObj.recordId;
        component.set('v.wizardprop', wizObj);
        var strBalanceAmount = 0.0;
        
        let paramsnew = {"contractId": wizObj.recordId
                        };
        this.callServer(component,'c.getCreditDetails',
                          function(response){
                              
                              strBalanceAmount = parseFloat(response);
                              if(strBalanceAmount > 0){
                                  component.set('v.skipScreens', true); 
                                  var wizObjNew = component.get('v.wizardprop');
                                  wizObjNew.creditAmount = strBalanceAmount;
                                  component.set('v.wizardprop', wizObjNew);
                              }
                              // check initial status and initialise steps
                              this.callApexWizardStatus(component, true);
                              
                          },      				
                          paramsnew);
    },
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        
        if (component.find('selectCreditPage') != undefined) component.find('selectCreditPage').reInitialise();
        if (component.find('selectRefundTransferPage') != undefined) component.find('selectRefundTransferPage').reInitialise();    
        if (component.find('selectPaymentPlanPage') != undefined) component.find('selectPaymentPlanPage').reInitialise();
        //AT-2882 - Upldated By Dependra Singh
        if (component.find('selectBankAccountDetailPage') != undefined) component.find('selectBankAccountDetailPage').reInitialise();

    },        
    
    // check the current page on entry
    checksOnEntry: function(component) {
        console.log(this.DEBUG + 'checksOnEntry:wizardprop** ' + JSON.stringify(component.get('v.wizardprop')));
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.CuAp_PaymentPlanPage2"):
                if (component.find('selectCreditPage') != undefined) component.find('selectCreditPage').checksOnEntry()
                break;
                
            case $A.get("$Label.c.CuAp_PaymentPlanPage3"):
                if (component.find('selectRefundTransferPage') != undefined) component.find('selectRefundTransferPage').checksOnEntry()
                break;
                
            case $A.get("$Label.c.CuAp_PaymentPlanPage1"):
                if (component.find('selectPaymentPlanPage') != undefined) component.find('selectPaymentPlanPage').checksOnEntry()
                break;
            case $A.get("$Label.c.CuAp_PaymentPlanPage4"):
                if (component.find('selectBankAccountDetailPage') != undefined) component.find('selectBankAccountDetailPage').checksOnEntry()
                break;    
        }
    },
    handlePickListChangeEvent:function(component, event, helper) {
        var wizObj = component.get('v.wizardprop');  
        var allStepNames;
        if(wizObj.selectedPaymentMethod == $A.get("$Label.c.PyAp_DirectDebit")){
            component.set('v.selectedPaymentMethod', wizObj.selectedPaymentMethod);
            this.updateWizardSteps(component);
            component.set('v.endStep', false);
        }else{
             this.updateWizardSteps(component);
             component.set('v.endStep', true);
        }
    },
    
    // validate the current page on exit to the next page
    // returns true if page validates
    validateOnNext: function(component) {
        var wizObj = component.get('v.wizardprop'); 
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.CuAp_PaymentPlanPage2"):
                if (component.find('selectCreditPage') == undefined
                    || component.find('selectCreditPage').validateOnNext()) {
                    
                    // update the wizard steps once a device has been selected
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
                
            case $A.get("$Label.c.CuAp_PaymentPlanPage3"):
                if (component.find('selectRefundTransferPage') == undefined
                    || component.find('selectRefundTransferPage').validateOnNext()) {
                    
                    // update the wizard steps once a device has been selected
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
                
            case $A.get("$Label.c.CuAp_PaymentPlanPage1"):
                if (component.find('selectPaymentPlanPage') == undefined || component.find('selectPaymentPlanPage').validateOnNext()) {
                    // Core 7a- If selected payment method is direct debit then update payment plan wizard otherwise save data.
                   
                    if(wizObj.selectedPaymentMethod == $A.get("$Label.c.PyAp_DirectDebit")){
                        this.updateWizardSteps(component);
                        return true;
                    }else{
                        this.callApexPaymentPlanWizard(component);
                    }
                }
                break;
              case $A.get("$Label.c.CuAp_PaymentPlanPage4"):
                if (component.find('selectBankAccountDetailPage') == undefined || component.find('selectBankAccountDetailPage').validateOnNext()) {
                    // update the wizard steps once a device has been selected
                    this.callApexPaymentPlanWizard(component);
                }
                break;   
            default:
                return true;
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
                this.doNext(component, event, helper);
                this.checksOnEntry(component);
            }
            
        } else if (message === 'BACK') {
            this.checksOnEntry(component);
            this.doBack(component, event, helper);
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
        var wizObj = component.get('v.wizardprop');  
        var allStepNames;
        if(wizObj.selectedPaymentMethod == $A.get("$Label.c.PyAp_DirectDebit")){
            allStepNames = [
                $A.get("$Label.c.CuAp_PaymentPlanPage2"),
                $A.get("$Label.c.CuAp_PaymentPlanPage3"),
                $A.get("$Label.c.CuAp_PaymentPlanPage1"),
                $A.get("$Label.c.CuAp_PaymentPlanPage4")
                
            ];
        }
        else{
              allStepNames = [
                $A.get("$Label.c.CuAp_PaymentPlanPage2"),
                $A.get("$Label.c.CuAp_PaymentPlanPage3"),
                $A.get("$Label.c.CuAp_PaymentPlanPage1")
            ];
        }
        
        var stepNames = allStepNames;
        var status = component.get('v.status');
        var skipScreens = component.get('v.skipScreens');
        
        if(skipScreens == false){
            remove(stepNames, $A.get('$Label.c.CuAp_PaymentPlanPage2'));
            remove(stepNames, $A.get('$Label.c.CuAp_PaymentPlanPage3'));
            component.set('v.endStep', false);
        }
        if(wizObj.creditRefund != undefined && wizObj.creditRefund == 'false'){
            remove(stepNames, $A.get('$Label.c.CuAp_PaymentPlanPage3'));
        }
        
        // initialise the stepNames
        component.set('v.stepNames', stepNames);
    },
    
    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {
        var action = component.get('c.WizardStatus');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        
        action.setParams({
            'wizardprop': wizardprop
        });
        this.setWizardSteps(component);
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                var status = response.getReturnValue();
                component.set('v.status', status);
                if(status.creditDetails == 'true'){
                    component.set('v.isCredit', true);    
                }
                
                // update the steps
                if (init) {		// set to the first step
                    var stepNames = component.get('v.stepNames');
                    component.set('v.stepName', stepNames[0]);
                    
                    this.checksOnEntry(component);
                }
                // set the progress path
                this.doSetProgressPathDetails(component);    
                
            } else {
                console.log('Error: ' + response.getError()[0].message);
                this.showNotification($A.get('$Label.c.BlAp_BillCalcResultUnknownResponse'), 'error');
            }
        });
        $A.enqueueAction(action);
    },     
    
    // call the server to complete device exchange        
    callApexPaymentPlanWizard: function(component, event, helper) {
        
        var action = component.get('c.paymentPlanWizard');
        console.log('Final Wizardprop Values = '+JSON.stringify(component.get('v.wizardprop')));
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var contractId = this.handlePaymentPlanWizardResponse(component, response);
            if (contractId) this.goToRecord(contractId);
        });
        $A.enqueueAction(action);
    }, 
    
    // handle the device exchange response
    handlePaymentPlanWizardResponse: function(component, response) {
        if (response.getState() === 'SUCCESS') {        
            
            // good exit
            if (response.getReturnValue() != null) {
                console.log('Success msg: '+response.getReturnValue());
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
    }
})