({
	DEBUG: 'MoveOutWizard: ',
	
    // override method for local initialisation
    doLocalInit: function(component, event, helper) {
        
        // add the accountId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.accountId = component.get('v.recordId');
        console.log(this.DEBUG + 'accountId: ' + wizObj.accountId);
        component.set('v.wizardprop', wizObj);
        
        // check initial status and initialise steps
        this.callApexWizardStatus(component, true);
    },
    
    // update the bill Id from the event
    handleBillCalculationComplete: function(component, event, helper) {

    	// add the billId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.billId = event.getParam('billId');
		console.log(this.DEBUG + 'billId: ' + wizObj.billId);
        component.set('v.wizardprop', wizObj);
	},
	
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        console.log(this.DEBUG + 'reInitialise all pages');
        if (component.find('selectAccountLocationPage') != undefined) component.find('selectAccountLocationPage').reInitialise();
        if (component.find('selectOccupantsPage') != undefined) component.find('selectOccupantsPage').reInitialise();
        if (component.find('moveOutReadingsPage') != undefined) component.find('moveOutReadingsPage').reInitialise();
        if (component.find('newBillingAddressPage') != undefined) component.find('newBillingAddressPage').reInitialise();
        if (component.find('sendOccupationFormPage') != undefined) component.find('sendOccupationFormPage').reInitialise();  // AT-3158 core 7b
        if (component.find('displayBillPage') != undefined) component.find('displayBillPage').reInitialise();
    },
    
    // check the current page on entry
    checksOnEntry: function(component) {
        
        console.log(this.DEBUG + 'validateOnEntry: ' + component.get('v.stepName'));
        switch (component.get('v.stepName')) {
            case $A.get('$Label.c.CuAp_MoveOutWizardSelectLocationStep'):
            	if (component.find('selectAccountLocationPage') != undefined) component.find('selectAccountLocationPage').checksOnEntry();
                break;
            case $A.get('$Label.c.CuAp_MoveOutWizardSelectOccupantsStep'):
            	if (component.find('selectOccupantsPage') != undefined) component.find('selectOccupantsPage').checksOnEntry();
                break;   
            case $A.get('$Label.c.CuAp_MoveOutWizardEnterReadingsStep'):
            	if (component.find('moveOutReadingsPage') != undefined) component.find('moveOutReadingsPage').checksOnEntry();
                break;    
            case $A.get('$Label.c.CuAp_MoveOutWizardNewBillingAddressStep'):
            	if (component.find('newBillingAddressPage') != undefined) component.find('newBillingAddressPage').checksOnEntry();
                break;
            case $A.get('$Label.c.CuAp_MoveOutWizardSendOccupationFormStep'):  // AT-3158 core7b start...
            	if (component.find('sendOccupationFormPage') != undefined) component.find('sendOccupationFormPage').checksOnEntry();
                break;  //AT-3158 core7b end...
            case $A.get('$Label.c.CuAp_MoveOutWizardDisplayBillStep'):

            	// move out and calculate bill
            	console.log(this.DEBUG + 'isCommitted: ' + component.get('v.isCommitted'));
            	if (!component.get('v.isCommitted')) {
	            	this.callApexMoveOut(component);
	            }          	

			    if (component.find('displayBillPage') != undefined) component.find('displayBillPage').checksOnEntry()
			    break;    
        }
    },
    
    // validate the current page on exit to the next page
    // returns true if page validates
    validateOnNext: function(component) {
        console.log(this.DEBUG + 'validateOnNext: ' + component.get('v.stepName'));
        switch (component.get('v.stepName')) {
            case $A.get('$Label.c.CuAp_MoveOutWizardSelectLocationStep'):
                if (component.find('selectAccountLocationPage') == undefined 
                		|| component.find('selectAccountLocationPage').validateOnNext()) {

                    // update the wizard steps once the location has been selected
                    this.updateWizardSteps(component);
                    return false;		// wait for server call before proceeding
                }
                break;
            case $A.get('$Label.c.CuAp_MoveOutWizardSelectOccupantsStep'):
                if (component.find('selectOccupantsPage') == undefined 
                		|| component.find('selectOccupantsPage').validateOnNext()) {
                    return true;
                }
                break; 
            case $A.get('$Label.c.CuAp_MoveOutWizardEnterReadingsStep'):
                if (component.find('moveOutReadingsPage') == undefined 
                		|| component.find('moveOutReadingsPage').validateOnNext()) {
                    return true;
                }
                break;    
            case $A.get('$Label.c.CuAp_MoveOutWizardNewBillingAddressStep'):
                if (component.find('newBillingAddressPage') == undefined 
                		|| component.find('newBillingAddressPage').validateOnNext()) {
                    return true;
                }
                break;                
            case $A.get('$Label.c.CuAp_MoveOutWizardSendOccupationFormStep'):   // AT-3158 core7b start...
                if (component.find('sendOccupationFormPage') == undefined 
                		|| component.find('sendOccupationFormPage').validateOnNext()) {
                    return true;
                }
                break;   // AT-3158 core7b end...
            case $A.get('$Label.c.CuAp_MoveOutWizardDisplayBillStep'):
            	if (component.find('displayBillPage') == undefined
            			|| component.find('displayBillPage').validateOnNext()) {
            		
        			// finish
	        		var wizObj = component.get('v.wizardprop');
	            	this.goToRecord(wizObj.contractId);
                    return false;
                }
                break;     
            default:
                return true;
        }
    },
    
    // override method for navigation with validation/server calls 
    navigateStep: function(component, event, helper) {
        
        console.log(this.DEBUG + 'Wizard navigation handler');
        var message = event.getParam('message');
        if (message === 'CANCEL') {
            this.reInitialiseAllSteps(component);
            this.doCancel(component, event, helper);
            
        } else if (message === 'NEXT') {
            if (this.validateOnNext(component)) {
                console.log(this.DEBUG + 'wizardprop: ' + JSON.stringify(component.get('v.wizardprop')));
                this.doNext(component, event, helper);
                this.checksOnEntry(component);
            }
            
        } else if (message === 'BACK') {
            this.doBack(component, event, helper);
            this.checksOnEntry(component);
        }
    },
    
    // update the wizard steps following a wizard property change
    updateWizardSteps: function(component) {
        
        console.log(this.DEBUG + 'evaluateWizardSteps');
        
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
        
        console.log(this.DEBUG + 'setWizardSteps');
        
        // initialise the stepNames
    	const allStepNames = [
	    						$A.get('$Label.c.CuAp_MoveOutWizardSelectLocationStep'), 
				        		$A.get('$Label.c.CuAp_MoveOutWizardSelectOccupantsStep'), 
				        		$A.get('$Label.c.CuAp_MoveOutWizardEnterReadingsStep'),  
				        		$A.get('$Label.c.CuAp_MoveOutWizardNewBillingAddressStep'),
            					$A.get('$Label.c.CuAp_MoveOutWizardSendOccupationFormStep'),   // AT-3158 core 7b
				        		$A.get('$Label.c.CuAp_MoveOutWizardDisplayBillStep')
			        		];
        console.log(this.DEBUG + 'allStepNames: ' + allStepNames);
        
        // clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        var status = component.get('v.status');
        
        // remove the additional occupants step for non-HH accounts
        if (!status.isHHAccount) {
            console.log(this.DEBUG + 'removing step: ' + $A.get('$Label.c.CuAp_MoveOutWizardSelectOccupantsStep'));
            remove(stepNames, $A.get('$Label.c.CuAp_MoveOutWizardSelectOccupantsStep'));
        }
        
        // remove the enter reading step if no measured supply point
        if (!status.hasMeasuredSupplyPoint) {
            console.log(this.DEBUG + 'removing step: ' + $A.get('$Label.c.CuAp_MoveOutWizardEnterReadingsStep'));
            remove(stepNames, $A.get('$Label.c.CuAp_MoveOutWizardEnterReadingsStep'));
        }
        console.log(this.DEBUG + 'stepNames: ', stepNames);
        
        // update the steps
        component.set('v.stepNames', stepNames);
    },
    
    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {
        console.log(this.DEBUG + 'call server for account status');
        var action = component.get('c.WizardStatus');
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
                
                // update the steps
                this.setWizardSteps(component);
                
                if (init) { // set to the first step
                    var stepNames = component.get('v.stepNames');
                    component.set('v.stepName', stepNames[0]);
                    console.log(this.DEBUG + 'stepNames: ' + stepNames);

                } else {
                
                	// only allow navigation once the async call has completed
                	this.doNext(component);
                }
	        	this.checksOnEntry(component);
                
                // set the progress path
                this.doSetProgressPathDetails(component);
                
            } else {
                console.log('Error: ' + response.getError()[0].message);
                this.showNotification($A.get('$Label.c.CuAp_WizardCompletionError'));
            }
        });
        $A.enqueueAction(action);
    },
    
	// handle the move out response
    handleMoveOutResponse: function(component, response) {

        if (response.getState() === 'SUCCESS') {
        	console.log(this.DEBUG + 'MoveOut() Response: ' + response.getReturnValue());
        
        	// good exit when a contract Id is returned
        	if (response.getReturnValue() != null) {
	    		console.log(this.DEBUG + 'got contract Id ... ' );
        		return response.getReturnValue();

			// null contract Id exit
        	} else {
        		console.log(this.DEBUG + 'move out returned null ... ' );
	    		this.handleError(component, response);
		    }

        // error exit
        } else {
	    	console.log(this.DEBUG + 'move out returned error ... ' );
	    	this.handleError(component, response);
        }
        return null;        
	},

    // call the server to complete move out
    callApexMoveOut: function(component) {
    	
    	console.log(this.DEBUG + 'call server to complete move out');
    	console.log(this.DEBUG + 'show spinner');
    	component.find('spinner').show();
        var action = component.get('c.MoveOut');
    	var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
        	var wizObj = component.get('v.wizardprop');
            wizObj.contractId = this.handleMoveOutResponse(component, response);
            console.log(this.DEBUG + 'contractId: ' + wizObj.contractId);
            
            console.log(this.DEBUG + 'hide spinner');
            component.find('spinner').hide();
            
            // if we've got a contract Id, calculate a bill
            if (wizObj.contractId) {
            
            	// flag that the server move out has occurred
            	component.set('v.isCommitted', true);
            	
            	// calculate the bill
            	var calculateBillCmp = component.find('calculateBillComponent');
            	calculateBillCmp.calculateBills(function(response) {
            		console.log(this.DEBUG + 'bill Id: ' + response)
	            	wizObj.billId = response;
            	});
            }
        	component.set('v.wizardprop', wizObj);
        });
        $A.enqueueAction(action);
    }
})