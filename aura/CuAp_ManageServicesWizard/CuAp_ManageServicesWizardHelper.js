({
    DEBUG: 'SteppedTariffWizard: ',
    
    // Execute from GlAp_WizardTemplate to initialise the wizard
	doLocalInit: function(component, event, helper) {
        
        // add the contractId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.contractId = wizObj.recordId;
        component.set('v.wizardprop', wizObj);
        
        // check initial status and initialise steps
        this.callApexWizardStatus(component, true);	
    },
    
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        if (component.find('serviceSearch') != undefined) component.find('serviceSearch').reInitialise();
        if (component.find('effectiveDate') != undefined) component.find('effectiveDate').reInitialise();
        if (component.find('readings') != undefined) component.find('readings').reInitialise();
    },
    
    // check the current page on entry
    checksOnEntry: function(component) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.CuAp_ManageServices1"):
                if (component.find('serviceSearch') != undefined) component.find('serviceSearch').checksOnEntry()
                break;
            case $A.get("$Label.c.CuAp_ManageServices2"):
                if (component.find('effectiveDate') != undefined) component.find('effectiveDate').checksOnEntry()
                break;
            case $A.get("$Label.c.CuAp_ManageServices3"):
                if (component.find('readings') != undefined) component.find('readings').checksOnEntry()
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
            case $A.get("$Label.c.CuAp_ManageServices1"):
                if (component.find('serviceSearch') == undefined
                    || component.find('serviceSearch').validateOnNext()) {
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
            case $A.get("$Label.c.CuAp_ManageServices2"):
                if (component.find('effectiveDate') == undefined
                    || component.find('effectiveDate').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.CuAp_ManageServices3"):
                if (component.find('readings') == undefined
                    || component.find('readings').validateOnNext()) {
                    this.startProcessing(component); 
                    return true;
                }
                break;                
            default:
                return true;
        }
    },
    
    startProcessing: function(component, event, helper) {
        var wizardprop = component.get('v.wizardprop');
        if(wizardprop.newReadings)
            this.processingReadings(component);
    },
    
    processingServices: function(component, readings) {
        component.find('spinner').show();
        var action = component.get('c.processingServices');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop,
            'readings' : JSON.stringify(readings)
        });
        action.setCallback(this, function(response) {
            var contractId = this.handleContractId(component, response);
            if (contractId) this.goToRecord(contractId);
        });
        $A.enqueueAction(action);
    },
    
    processingAvailableServices: function(component, readings) {
        
        component.find('spinner').show();
        var action = component.get('c.processingAvailableServices');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop,
            'readings' : JSON.stringify(readings)
        });
        action.setCallback(this, function(response) {
            var contractId = this.handleContractId(component, response);
            if (contractId) this.goToRecord(contractId);
        });
        $A.enqueueAction(action);
    },
    
    removedServices: function(component, readings) {
        component.find('spinner').show();
        
        var action = component.get('c.removedServices');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop,
            'readings' : JSON.stringify(readings)
        });
        action.setCallback(this, function(response) {
            var contractId = this.handleContractId(component, response);
            if (contractId) this.goToRecord(contractId);
        });
        $A.enqueueAction(action);
    },
    
    processingReadings: function(component, event, helper) {
        component.find('spinner').show();
        var action = component.get('c.processingReadings');
        var wizardprop = component.get('v.wizardprop');
        action.setParams({
            'wizardprop': JSON.stringify(wizardprop)
        });
        action.setCallback(this, function(response) {
            if(wizardprop.serviceTransfers)
                this.processingServices(component, response.getReturnValue());            
            else if(wizardprop.availableServiceTransfers)
                this.processingAvailableServices(component, response.getReturnValue());            
            else if(wizardprop.removedServices)
                    this.removedServices(component, response.getReturnValue());
            
        });
        $A.enqueueAction(action);
    },
    
    // handle the create discount response
    handleContractId: function(component, response) {
        component.find('spinner').hide(); 
        if (response.getState() === 'SUCCESS') {        
            // good exit
            if (response.getReturnValue() != null) {
                console.log('Success msg: '+response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"Success", 
                    "message": $A.get("$Label.c.CuAp_SuccessServiceTransfer")
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
        var allStepNames;
        if(component.get('v.wizardType') == $A.get("$Label.c.CuAp_AddLabel")){
            allStepNames = [
                $A.get("$Label.c.CuAp_ManageServices1"),
                $A.get("$Label.c.CuAp_ManageServices2"),
                $A.get("$Label.c.CuAp_ManageServices3")
            ];
        }
        else{
            allStepNames = [
                $A.get("$Label.c.CuAp_ManageServices2"),
                $A.get("$Label.c.CuAp_ManageServices3")
            ];            
        }        
        // clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        
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
                this.showNotification('An error occured when contacting the server', 'error');
            }
        });
        $A.enqueueAction(action);
    }    
})