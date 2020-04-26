({
    DEBUG: 'DiscountManageWizard: ',
    
    // override method for local initialisation
    doLocalInit: function(component, event, helper) {
        
        // add the contractId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.contractId = wizObj.recordId;
        wizObj.wizardType = $A.get('$Label.c.CuAp_NewDiscount');
        component.set('v.wizardprop', wizObj);
        
        // check initial status and initialise steps
        this.callApexWizardStatus(component, true);	
    },
    
    handleBillCalculationComplete: function(component, event, helper) {
        //alert('id = '+component.get('v.finalDiscountId'))                
        this.goToRecord(component.get('v.finalDiscountId'));
        
    },
    
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        if (component.find('selectDiscountOperationPage') != undefined) component.find('selectDiscountOperationPage').reInitialise();
        if (component.find('selectDiscountApplyPage') != undefined) component.find('selectDiscountApplyPage').reInitialise();
        if (component.find('addDiscountPage') != undefined) component.find('addDiscountPage').reInitialise();
        if (component.find('manageDiscount') != undefined) component.find('manageDiscount').reInitialise();
    },
    
    // check the current page on entry
    checksOnEntry: function(component) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.CuAp_DiscountPathPage1"):
                if (component.find('selectDiscountOperationPage') != undefined) component.find('selectDiscountOperationPage').checksOnEntry()
                break;
            case $A.get("$Label.c.CuAp_DiscountPathPage2"):
                if (component.find('selectDiscountApplyPage') != undefined) component.find('selectDiscountApplyPage').checksOnEntry()
                break;
            case $A.get("$Label.c.CuAp_DiscountPathPage3"):
                if (component.find('addDiscountPage') != undefined) component.find('addDiscountPage').checksOnEntry()
                break;
            case $A.get("$Label.c.CuAp_DiscountPathPage4"):
                if (component.find('manageDiscount') != undefined) component.find('manageDiscount').checksOnEntry()
                break; 
        }
    },
    
    // override method for navigation with validation/server calls 
    navigateStep: function(component, event, helper) {
        var message = event.getParam('message');
        if (message === 'CANCEL') {
            this.doCancel(component, event, helper);
            this.reInitialiseAllSteps(component);
            
        } else if (message === 'NEXT') {
            if (this.validateOnNext(component)) {
                this.doNext(component, event, helper);
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
            case $A.get("$Label.c.CuAp_DiscountPathPage1"):
                if (component.find('selectDiscountOperationPage') == undefined
                    || component.find('selectDiscountOperationPage').validateOnNext()) {
                    // update the wizard steps
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
            case $A.get("$Label.c.CuAp_DiscountPathPage2"):
                if (component.find('selectDiscountApplyPage') == undefined
                    || component.find('selectDiscountApplyPage').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.CuAp_DiscountPathPage3"):
                if (component.find('addDiscountPage') == undefined
                    || component.find('addDiscountPage').validateOnNext()) {
                    // create discount
                    this.callApexCreateDiscount(component);
                    return true;
                }
                break;
            case $A.get("$Label.c.CuAp_DiscountPathPage4"):
                if (component.find('manageDiscount') == undefined
                    || component.find('manageDiscount').validateOnNext()) {
                    this.callApexCreateUpdateDiscount(component);
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
            $A.get("$Label.c.CuAp_DiscountPathPage1"),
            $A.get("$Label.c.CuAp_DiscountPathPage2"),
            $A.get("$Label.c.CuAp_DiscountPathPage3"),
            $A.get("$Label.c.CuAp_DiscountPathPage4")
        ];
        
        // clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        var status = component.get('v.wizardprop');
        // remove step 2 and step 3 if ExistingDiscount.
        if(status.wizardType === $A.get('$Label.c.CuAp_ExistingDiscount')){
            remove(stepNames, $A.get('$Label.c.CuAp_DiscountPathPage2'));
            remove(stepNames, $A.get('$Label.c.CuAp_DiscountPathPage3'));
        }
        // remove step 4 if NewDiscount.
        if(status.wizardType === $A.get('$Label.c.CuAp_NewDiscount')){
            remove(stepNames, $A.get('$Label.c.CuAp_DiscountPathPage4'));
        }
        // initialise the stepNames
        component.set('v.stepNames', stepNames);
    },
    
    
    // call the server to complete update discount - Ankit Gangwani       
    callApexCreateUpdateDiscount: function(component, event, helper) {
        component.find('spinner').show();
        var wizObj = component.get('v.wizardprop');
        var recList = wizObj.discount;
        var rec;
        var discountSelected = [];
        var discountIds = [];
        var mixOverrideDiscount;
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        for(var i = 0;i<recList.length;i++){
            
            if(recList[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_FixedDiscount")){
                mixOverrideDiscount = recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('OverriddenDiscountAmount__c')]; 
            }else if(recList[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_BillToBillDiscount")){
                mixOverrideDiscount = recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('OverriddenDailyDiscountAmount__c')];
            }else if(recList[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_PercentageDiscount")){
                mixOverrideDiscount = recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('OverriddenDiscountPercentage__c')];
            }
            
            if(recList[i].isSelected == true && 
               (recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')] != recList[i].transformFieldMap[this.setPrefixedString('Discount__c')]['Old_Start_Date'] ||                
                recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')] < todaysDate ||
                (recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] != undefined && 
                 recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] != null &&
                 recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] != mixOverrideDiscount))){
                
                var endDate = (recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')] ? recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')] : null)
                rec = {sobjectType: this.setPrefixedString('Discount__c'),
                       [this.setPrefixedString('DiscountType__c')]		: recList[i].objectMap[this.setPrefixedString('DiscountType__c')]['Id'],
                       [this.setPrefixedString('BillingContract__c')]	: wizObj.contractId,
                       [this.setPrefixedString('StartDate__c')]			: recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')],
                       [this.setPrefixedString('EndDate__c')]			: endDate};
                
                discountIds.push(recList[i].uniqueId);
                if(recList[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_FixedDiscount")){
                    
                    rec[this.setPrefixedString('BaseDiscountAmount__c')] 	= recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('BaseDiscountAmount__c')];
                    rec[this.setPrefixedString('OverriddenDiscountAmount__c')]  = recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'];
                    
                }else if(recList[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_PercentageDiscount")){
                    
                    rec[this.setPrefixedString('BaseDiscountPercentage__c')] 		= recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('BaseDiscountPercentage__c')];
                    rec[this.setPrefixedString('OverriddenDiscountPercentage__c')]  = recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'];
                    
                }else if(recList[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_BillToBillDiscount")){
                    
                    rec[this.setPrefixedString('BaseDailyDiscountAmount__c')] 		= recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('BaseDailyDiscountAmount__c')];
                    rec[this.setPrefixedString('Concession__c')] 					= recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('Concession__c')];
                    rec[this.setPrefixedString('OverriddenDailyDiscountAmount__c')] = recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'];
                    
                }
                discountSelected.push(rec);
            }
        }
        console.log('discountSelecteddiscountSelected == '+JSON.stringify(discountSelected))
        console.log('discountSelecteddiscountSelected == '+discountSelected);
        if(discountSelected.length > 0){
            wizObj.discount = discountSelected;
            wizObj.lstDiscountIds = discountIds;
            component.set("v.wizardprop",wizObj);
            
            var action = component.get('c.createUpdateDiscount');
            var wizardprop = JSON.stringify(component.get('v.wizardprop'));
            
            action.setParams({
                'wizardprop': wizardprop
            });
            action.setCallback(this, function(response) {
                var contractId = this.handleCreateDiscountResponse(component, response);
                // Changes for AT-3448 Starts/Ends here            
            });
            $A.enqueueAction(action);
        }
        // Updated Amended By Discount to the existing ones
        var discountNotSelected = [];        
        
        for(var i = 0;i<recList.length;i++){            
            if(discountIds.indexOf(recList[i].uniqueId) < 0){
               // Changes for AT-3448 Starts here            
              if(recList[i].isSelected == true && recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')] >= todaysDate){                    
                    rec = {sobjectType: this.setPrefixedString('Discount__c'),
                           Id: recList[i].uniqueId,
                           [this.setPrefixedString('BillingContract__c')]: wizObj.contractId,
                           [this.setPrefixedString('EndDate__c')]: recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')]};                    
                    discountNotSelected.push(rec);
                }
            }
        }
        if(discountNotSelected.length > 0){
            wizObj.discount = discountNotSelected;
            component.set("v.wizardprop",wizObj);
            
            var action = component.get('c.updateDiscount');
            var wizardprop = JSON.stringify(component.get('v.wizardprop'));
            
            action.setParams({
                'wizardprop': wizardprop
            });
            action.setCallback(this, function(response) {
                var contractId = this.handleCreateDiscountResponse(component, response);            
               // Changes for AT-3448 Ends here
            });
            $A.enqueueAction(action);
        }
        // Changes for AT-3448 Starts here 
        if(discountNotSelected.length == 0 && discountSelected.length == 0){
            component.find('spinner').hide();
            this.showNotification(component,[$A.get('$Label.c.GuAp_NoRecordUpdated')], 'error');
        }
         // Changes for AT-3448 Ends here 
    },
    // Changes for AT-3448 Starts here 
     // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    // Changes for AT-3448 Ends here 
    // call the server to complete create discount        
    callApexCreateDiscount: function(component, event, helper) {
        component.find('spinner').show();
        var action = component.get('c.createDiscount');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var contractId = this.handleCreateDiscountResponse(component, response);
            if (contractId) this.goToRecord(contractId);
        });
        $A.enqueueAction(action);
    }, 
    
    // handle the create discount response
    handleCreateDiscountResponse: function(component, response) {
        component.find('spinner').hide(); 
        if (response.getState() === 'SUCCESS') {        
            // good exit
            if (response.getReturnValue() != null) {
                // Changes for AT-3448 Starts here
                var jsonResponse = response.getReturnValue();
                if(jsonResponse){
                    component.set('v.finalDiscountId',jsonResponse.Id);
                    // calculate the pending bills
                    var calculateBillCmp = component.find('calculatePendingBillComponent');
                    calculateBillCmp.calculateBills(function(response) {
                        var contractId = jsonResponse[this.setPrefixedString('BillingContract__c')];
                        if(contractId)
                            this.goToRecord(contractId);
                    });
                }
                // Changes for AT-3448 Ends here
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.GuAp_SuccessTitle"),
                    "type": $A.get("$Label.c.GlAp_Success"), 
                    "message": $A.get("$Label.c.CuAp_AddDiscountSuccess")
                });
                toastEvent.fire();
                return response.getReturnValue();
                
                // null exit
            } else {
                this.handleError(component, response);
            }
            
            // error exit
        } else {
            this.handleError(component, response);
        }
        return false;        
    },
    
    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {   
        var action = component.get('c.WizardStatus');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        // update the steps
        this.setWizardSteps(component);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                // update the steps
                if (init) {		// set to the first step
                    var stepNames = component.get('v.stepNames');
                    component.set('v.stepName', stepNames[0]);
                    this.checksOnEntry(component);
                }
                // set the progress path
                this.doSetProgressPathDetails(component);    
                
            } else {
                this.showNotification($A.get('$Label.c.GlUt_ServerConnectionError'), 'error');  
            }
        });
        $A.enqueueAction(action);
    }, 
})