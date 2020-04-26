({
	DEBUG: 'MoveInWizard: ',
    // override method for local initialisation
    doLocalInit: function(component, event, helper) {

    	// add the accountId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.accountId = wizObj.recordId;
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
	// TO-DO - make the list of steps into a map and use a loop to call each method
	// then can be moved to template???
	reInitialiseAllSteps: function(component) {
		console.log(this.DEBUG + 'reInitialise all pages');
		if (component.find('selectLocationPage') != undefined) component.find('selectLocationPage').reInitialise();
        if (component.find('moveInDatePage') != undefined) component.find('moveInDatePage').reInitialise();
		if (component.find('additionalOccupantsPage') != undefined) component.find('additionalOccupantsPage').reInitialise();
		if (component.find('selectServicePage') != undefined) component.find('selectServicePage').reInitialise();
        if (component.find('selectBundlePage') != undefined) component.find('selectBundlePage').reInitialise();
		if (component.find('moveInReadingsPage') != undefined) component.find('moveInReadingsPage').reInitialise();
		if (component.find('selectContractPage') != undefined) component.find('selectContractPage').reInitialise();
        if (component.find('welcomeLetterPage') != undefined) component.find('welcomeLetterPage').reInitialise();  // AT-3157 Core7b
        if (component.find('displayBillPage') != undefined) component.find('displayBillPage').reInitialise();
	},
	
	// check the current page on entry
	checksOnEntry: function(component) {
		console.log(this.DEBUG + 'validateOnEntry: ' + component.get('v.stepName'));
        console.log(this.DEBUG + 'validateOnEntry:wizardprop** ' + JSON.stringify(component.get('v.wizardprop')));
    	switch (component.get('v.stepName')) {
    		case $A.get('$Label.c.CuAp_MoveInWizardSelectLocationStep'):
    			if (component.find('selectLocationPage') != undefined) component.find('selectLocationPage').checksOnEntry()
	        	break;
            case $A.get('$Label.c.CuAp_MoveInWizardEnterMoveInDateStep'):
    			if (component.find('moveInDatePage') != undefined) component.find('moveInDatePage').checksOnEntry()
	        	break;
         	case $A.get('$Label.c.CuAp_MoveInWizardAdditionalOccupantsStep'):
    			if (component.find('additionalOccupantsPage') != undefined) component.find('additionalOccupantsPage').checksOnEntry()
        		break;
            case $A.get('$Label.c.CuAp_MoveInWizardSelectServicesStep'):
    			if (component.find('selectServicePage') != undefined) component.find('selectServicePage').checksOnEntry()
        		break;
            case $A.get('$Label.c.CuAp_MoveInWizardSelectBundlesStep'):
                if (component.find('selectBundlePage') != undefined) component.find('selectBundlePage').checksOnEntry()
                break;
            case $A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'):
     			if (component.find('moveInReadingsPage') != undefined) component.find('moveInReadingsPage').checksOnEntry()
                break;
            case $A.get('$Label.c.CuAp_MoveInWizardSelectContractStep'):
    			if (component.find('selectContractPage') != undefined) component.find('selectContractPage').checksOnEntry()
                break;
            case $A.get('$Label.c.CuAp_MoveInWizardWelcomeLetterStep'):    // AT-3157 Core7b start...
    			if (component.find('welcomeLetterPage') != undefined) component.find('welcomeLetterPage').checksOnEntry()
                break;   // AT-3157 end...
            case $A.get('$Label.c.CuAp_MoveInWizardDisplayBillStep'):

            	// move in and calculate bill
            	alert('isCommitted: ' + component.get('v.isCommitted'));
            	if (!component.get('v.isCommitted')) {
	            	this.callApexMoveIn(component);
	            }
	            
	            // remove the 'back' and 'cancel' (TO-DO) buttons
	            component.set('v.startStep', false);
	            
			    if (component.find('displayBillPage') != undefined) component.find('displayBillPage').checksOnEntry()
			    break;
    	}
	},

	// validate the current page on exit to the next page
	// returns true if page validates
	validateOnNext: function(component) {
		console.log(this.DEBUG + 'validateOnNext: ' + component.get('v.stepName'));
    	switch (component.get('v.stepName')) {
    		case $A.get('$Label.c.CuAp_MoveInWizardSelectLocationStep'):
        		if (component.find('selectLocationPage') == undefined
        				|| component.find('selectLocationPage').validateOnNext()) {

        			// update the wizard steps once a location has been selected
        			this.updateWizardSteps(component);
        			return true;
        		}
        		break;
            case $A.get('$Label.c.CuAp_MoveInWizardEnterMoveInDateStep'):
        		if (component.find('moveInDatePage') == undefined
        				|| component.find('moveInDatePage').validateOnNext()) {
        				
        			// update the wizard steps once a move in date has been selected
        			this.updateWizardSteps(component);
        			return true;
        		}
        		break;
            case $A.get('$Label.c.CuAp_MoveInWizardAdditionalOccupantsStep'):
        		if (component.find('additionalOccupantsPage') == undefined
        				|| component.find('additionalOccupantsPage').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get('$Label.c.CuAp_MoveInWizardSelectServicesStep'):
        		if (component.find('selectServicePage') == undefined
        				|| component.find('selectServicePage').validateOnNext()) {
        				
        			// update the wizard steps once services have been selected
        			this.updateWizardSteps(component);
                    return true;
                }
                break;
            case $A.get('$Label.c.CuAp_MoveInWizardSelectBundlesStep'):
                if (component.find('selectBundlePage') == undefined
                        || component.find('selectBundlePage').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'):
                if (component.find('moveInReadingsPage') == undefined
                		|| component.find('moveInReadingsPage').validateOnNext()) {
                    return true;
                }
                break;
             case $A.get('$Label.c.CuAp_MoveInWizardSelectContractStep'):
        		if (component.find('selectContractPage') == undefined
        				|| component.find('selectContractPage').validateOnNext()) {
                    return true;
                }
                break;
             case $A.get('$Label.c.CuAp_MoveInWizardWelcomeLetterStep'):   // AT-3157 Core7b start...                
        		if (component.find('welcomeLetterPage') == undefined
        				|| component.find('welcomeLetterPage').validateOnNext()) {                    
                    return true;
                }
                break; // AT-3157Core7b end...
             case $A.get('$Label.c.CuAp_MoveInWizardDisplayBillStep'):
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
        		console.log(this.DEBUG + 'wizObj: ' + JSON.stringify(component.get('v.wizardprop')));
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
	    						$A.get('$Label.c.CuAp_MoveInWizardSelectLocationStep'), 
				        		$A.get('$Label.c.CuAp_MoveInWizardEnterMoveInDateStep'), 
				        		$A.get('$Label.c.CuAp_MoveInWizardAdditionalOccupantsStep'), 
				        		$A.get('$Label.c.CuAp_MoveInWizardSelectServicesStep'),  
				        		$A.get('$Label.c.CuAp_MoveInWizardSelectBundlesStep'),  
				        		$A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'),  
				        		$A.get('$Label.c.CuAp_MoveInWizardSelectContractStep'), 
            					$A.get('$Label.c.CuAp_MoveInWizardWelcomeLetterStep'),     // AT-3157 Core7b       
				        		$A.get('$Label.c.CuAp_MoveInWizardDisplayBillStep')
			        		];
    	console.log(this.DEBUG + 'allStepNames: ' + allStepNames);
    	
    	// clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        var status = component.get('v.status');

    	// remove the additional occupants step for non-HH accounts
    	if (!status.isHHAccount) {
    		console.log(this.DEBUG + 'removing step: ' + $A.get('$Label.c.CuAp_MoveInWizardAdditionalOccupantsStep'));
    		remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardAdditionalOccupantsStep'));
    	}

    	// remove the select contract step if no active contracts
    	if (!status.hasContract) {
    		console.log(this.DEBUG + 'removing step: ' + $A.get('$Label.c.CuAp_MoveInWizardSelectContractStep'));
    		remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardSelectContractStep'));
    	}

    	// remove the enter reading step if no measured supply point
    	if (!status.hasMeasuredSupplyPoint) {
    		console.log(this.DEBUG + 'removing step: ' + $A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'));
    		remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'));
    	}
        
    	console.log(this.DEBUG + 'stepNames: ', stepNames);
    	
    	// update the steps
        component.set('v.stepNames', stepNames);
    },

    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {
    	
    	console.log(this.DEBUG + 'call server for account status');
        var action = component.get('c.wizardStatus');
    	var wizObj = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizObj
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
            	var status = response.getReturnValue();
		        component.set('v.status', status);
		        console.log(this.DEBUG + 'status: ' + JSON.stringify(status));
		        
		        // update the steps
		        this.setWizardSteps(component);
		        
		        if (init) {		// set to the first step
			        var stepNames = component.get('v.stepNames');
			        component.set('v.stepName', stepNames[0]);
		        	this.checksOnEntry(component);
			        console.log(this.DEBUG + 'stepNames: ' + stepNames);
		        }

		        // set the progress path
		        this.doSetProgressPathDetails(component);    
		        
            } else {
                console.log(this.DEBUG + 'Error: ' + response.getError()[0].message);
                this.showNotification($A.get('$Label.c.CuAp_WizardCompletionError'));
            }
        });
        $A.enqueueAction(action);
    },
    
	// handle the move in response
    handleMoveInResponse: function(component, response) {

        if (response.getState() === 'SUCCESS') {
        	console.log('MoveIn() Response: ' + response.getReturnValue());
        
        	// good exit when a contract Id is returned
        	if (response.getReturnValue() != null) {
	    		console.log(this.DEBUG + 'got contract Id ... ' );
        		return response.getReturnValue();

			// null contract Id exit
        	} else {
        		console.log(this.DEBUG + 'move in returned null ... ' );
	    		this.handleError(component, response);
		    }

        // error exit
        } else {
	    	console.log(this.DEBUG + 'move in returned error ... ' );
	    	this.handleError(component, response);
        }
        return null;        
	},

    // call the server to complete move in
    callApexMoveIn: function(component) {
    	
    	console.log(this.DEBUG + 'call server to complete move in');
    	console.log(this.DEBUG + 'show spinner');
    	component.find('spinner').show();
        var action = component.get('c.moveIn');
    	var wizObj = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizObj
        });
        action.setCallback(this, function(response) {
        	var wizObj = component.get('v.wizardprop');
            //Changes for AT-4532 Starts here 
            var listContract = [];
            listContract = this.handleMoveInResponse(component, response);
            console.log(this.DEBUG + 'listContract.length ' + listContract.length);
            console.log(this.DEBUG + 'contractId: ' + wizObj.contractId);
            console.log(this.DEBUG + 'listContract ' + listContract);
            if(listContract && listContract.length > 1){ // collection of move in and move out contracts  in case of existing occupant move-out
                wizObj.contractId = listContract[0];
                component.set('v.newListOfContractId', listContract);
            }else if(listContract && listContract.length == 1){ // Collection of move in contract i.e new occupant.
                wizObj.contractId = listContract[0];
                component.set('v.newRecordId', listContract[0]);
            }else if(wizObj.contractId){ // Existing contract comes from contract selection screen.
                component.set('v.newRecordId', wizObj.contractId);
            }
            console.log(this.DEBUG + 'hide spinner');
            component.find('spinner').hide();
            // if we've got a contract Id, calculate a bill
            if (wizObj.contractId) { // Either loc occupant existing contract or new contract
            //Changes for AT-4532 Ends here 
            	// flag that the server move in has occurred
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