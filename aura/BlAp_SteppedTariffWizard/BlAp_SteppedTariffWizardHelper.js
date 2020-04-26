({
    DEBUG: 'SteppedTariffWizard: ',
    
    // Execute from GlAp_WizardTemplate to initialise the wizard
	doLocalInit: function(component, event, helper) {
        
        // add the contractId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.contractId = wizObj.recordId;
        wizObj.wizardType = $A.get('$Label.c.BlAp_NewStepTariff');
        component.set('v.wizardprop', wizObj);
        
        // check initial status and initialise steps
        this.callApexWizardStatus(component, true);	
    },
    
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        if (component.find('steppedTariffOperation') != undefined) component.find('steppedTariffOperation').reInitialise();
        if (component.find('steppedTariffRenewal') != undefined) component.find('steppedTariffRenewal').reInitialise();
        if (component.find('steppedTariffLocation') != undefined) component.find('steppedTariffLocation').reInitialise();
        if (component.find('steppedTariffAmendment') != undefined) component.find('steppedTariffAmendment').reInitialise();
        if (component.find('steppedTariffLocationAmendment') != undefined) component.find('steppedTariffLocationAmendment').reInitialise();        
    },
    
    // check the current page on entry
    checksOnEntry: function(component) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.BlAp_SteppedTariffPage1"):
                if (component.find('steppedTariffOperation') != undefined) component.find('steppedTariffOperation').checksOnEntry()
                break;
            case $A.get("$Label.c.BlAp_SteppedTariffPage2"):
                if (component.find('steppedTariffRenewal') != undefined) component.find('steppedTariffRenewal').checksOnEntry()
                break;
            case $A.get("$Label.c.BlAp_SteppedTariffPage3"):
                if (component.find('steppedTariffLocation') != undefined) component.find('steppedTariffLocation').checksOnEntry()
                break;
            case $A.get("$Label.c.BlAp_SteppedTariffPage4"):
                if (component.find('steppedTariffAmendment') != undefined) component.find('steppedTariffAmendment').checksOnEntry()
                break; 
            case $A.get("$Label.c.BlAp_SteppedTariffPage5"):
                if (component.find('steppedTariffLocationAmendment') != undefined) component.find('steppedTariffLocationAmendment').checksOnEntry()
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
            case $A.get("$Label.c.BlAp_SteppedTariffPage1"):
                if (component.find('steppedTariffOperation') == undefined
                    || component.find('steppedTariffOperation').validateOnNext()) {
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
            case $A.get("$Label.c.BlAp_SteppedTariffPage2"):
                if (component.find('steppedTariffRenewal') == undefined
                    || component.find('steppedTariffRenewal').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.BlAp_SteppedTariffPage3"):
                if (component.find('steppedTariffLocation') == undefined
                    || component.find('steppedTariffLocation').validateOnNext()) {
                    this.callApexCreateSTAndSTS(component); // This function will create stepped tariff and stepped tariff services records
                    return true;
                }
                break;
            case $A.get("$Label.c.BlAp_SteppedTariffPage4"):
                if (component.find('steppedTariffAmendment') == undefined
                    || component.find('steppedTariffAmendment').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.BlAp_SteppedTariffPage5"):
                if (component.find('steppedTariffLocationAmendment') == undefined
                    || component.find('steppedTariffLocationAmendment').validateOnNext()) {
                    this.updateSteppedTariffServices(component); // This function will update the stepped tariff services values 
                    return true;
                }
                break;
            default:
                return true;
        }
    },
    
    // update the wizard steps following a wizard property change
    updateWizardSteps: function(component) {        
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
            $A.get("$Label.c.BlAp_SteppedTariffPage1"),
            $A.get("$Label.c.BlAp_SteppedTariffPage2"),
            $A.get("$Label.c.BlAp_SteppedTariffPage3"),
            $A.get("$Label.c.BlAp_SteppedTariffPage4"),
            $A.get("$Label.c.BlAp_SteppedTariffPage5")            
        ];
        
        // clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        var status = component.get('v.wizardprop');
        if(status.wizardType === $A.get('$Label.c.BlAp_ExistingStepTariff')){
            remove(stepNames, $A.get('$Label.c.BlAp_SteppedTariffPage2'));
            remove(stepNames, $A.get('$Label.c.BlAp_SteppedTariffPage3'));
        }
        if(status.wizardType === $A.get('$Label.c.BlAp_NewStepTariff')){
            remove(stepNames, $A.get('$Label.c.BlAp_SteppedTariffPage4'));
            remove(stepNames, $A.get('$Label.c.BlAp_SteppedTariffPage5'));
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
                console.log('Error: ' + response.getError()[0].message);
                this.showNotification($A.get("$Label.c.GlUt_ServerConnectionError"), 'error');
                
            }
        });
        $A.enqueueAction(action);
    },
    
    // call the server to complete create stepped tariff and stepped tariff services        
    callApexCreateSTAndSTS: function(component, event, helper) {
        component.find('spinner').show();
        var action = component.get('c.createSteppedTairffAndServices');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var steppedTariffId = this.handleCreateSteppedTariffAndServices(component, response);
            if (steppedTariffId) this.goToRecord(steppedTariffId);
        });
        $A.enqueueAction(action);
    },
    
    // call the server to complete create stepped tariff and stepped tariff services        
    updateSteppedTariffServices: function(component, event, helper) {
        component.find('spinner').show();
        var action = component.get('c.updateSteppedTairffServices');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var steppedTariffId = this.handleUpdateSteppedTariffServices(component, response);
            if (steppedTariffId) this.goToRecord(steppedTariffId);
        });
        $A.enqueueAction(action);
    },
    
    // handle the create discount response
    handleCreateSteppedTariffAndServices: function(component, response) {
        component.find('spinner').hide(); 
        if (response.getState() === 'SUCCESS') {           
            // good exit
            if (response.getReturnValue() != null) {
                console.log('Success msg: '+response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get('$Label.c.GuAp_SuccessTitle'), 
                    "type": $A.get('$Label.c.CuAp_LightningStateSuccess'),
                    "message": $A.get('$Label.c.BlAp_SteppedTariffSuccess')
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
    
    // handle the create discount response
    handleUpdateSteppedTariffServices: function(component, response) {
        component.find('spinner').hide(); 
        if (response.getState() === 'SUCCESS') {        
            
            // good exit
            if (response.getReturnValue() != null) {
                console.log('Success msg: '+response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get('$Label.c.GuAp_SuccessTitle'), 
                    "type": $A.get('$Label.c.CuAp_LightningStateSuccess'),
                    "message": $A.get('$Label.c.BlAp_SteppedTariffSuccessUpdate')
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
    }
})