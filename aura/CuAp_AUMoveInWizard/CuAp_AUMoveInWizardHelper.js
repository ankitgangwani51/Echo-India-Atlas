({
	DEBUG: 'AU MoveInWizard: ',
    // override method for local initialisation
    doLocalInit: function(component, event, helper) {

    	// add the accountId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.accountId = wizObj.recordId;
        component.set('v.wizardprop', wizObj);

    	// check initial status and initialise steps
    	this.callApexWizardStatus(component, true);	
	},
	
    // update the bill Id from the event
    handleBillCalculationComplete: function(component, event, helper) {

    	// add the billId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.billId = event.getParam('billId');
        component.set('v.wizardprop', wizObj);
	},
	
	// reInitialise all pages on Wizard exit/close
	// TO-DO - make the list of steps into a map and use a loop to call each method
	// then can be moved to template???
	reInitialiseAllSteps: function(component) {
		if (component.find('selectLocationPage') != undefined) component.find('selectLocationPage').reInitialise();
        if (component.find('moveInDatePage') != undefined) component.find('moveInDatePage').reInitialise();
		if (component.find('additionalOccupantsPage') != undefined) component.find('additionalOccupantsPage').reInitialise();
		if (component.find('selectServicePage') != undefined) component.find('selectServicePage').reInitialise();
        if (component.find('selectBundlePage') != undefined) component.find('selectBundlePage').reInitialise();
		if (component.find('moveInReadingsPage') != undefined) component.find('moveInReadingsPage').reInitialise();
		if (component.find('selectContractPage') != undefined) component.find('selectContractPage').reInitialise();
        if (component.find('welcomeLetterPage') != undefined) component.find('welcomeLetterPage').reInitialise();  // AT-3157 Core7b
        if (component.find('transferDebtCredit') != undefined) component.find('transferDebtCredit').reInitialise();  // AT-3157 Core7b
        if (component.find('displayBillPage') != undefined) component.find('displayBillPage').reInitialise();
	},
	
	// check the current page on entry
	checksOnEntry: function(component) {
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
            case $A.get('$Label.c.CuAp_AUMoveInWizardDebtCreditTransfer'):    // AT-3157 Core7b start...
    			if (component.find('transferDebtCredit') != undefined) component.find('transferDebtCredit').checksOnEntry()
                break;       
            case $A.get('$Label.c.CuAp_MoveInWizardDisplayBillStep'):

            	// move in and calculate bill
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
        var wizObj = component.get('v.wizardprop');
        
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
                    
                    if(wizObj.selectedOccType != $A.get('$Label.c.CuAp_AUMoveInOccType')){
                        this.callApexMoveIn(component);
                    }
                    
                    return true;
                }
                break; // AT-3157Core7b end...
             case $A.get('$Label.c.CuAp_AUMoveInWizardDebtCreditTransfer'):   // AT-3157 Core7b start...                
        		if (component.find('transferDebtCredit') == undefined
        				|| component.find('transferDebtCredit').validateOnNext()) {                    
                    return true;
                }
                break;   
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
            this.doBack(component, event, helper);
        	this.checksOnEntry(component);
        }	
	},

    // update the wizard steps following a wizard property change
    updateWizardSteps: function(component) {
    	// update the list of steps
    	this.callApexWizardStatus(component);
    },
    
    handleOccTypeChangeEvent:function(component, event, helper) {
        var wizObj = component.get('v.wizardprop');  
        var allStepNames;
        if(wizObj.selectedOccType == $A.get("$Label.c.CuAp_AUMoveInOccType")){
            component.set('v.selectedOccType', wizObj.selectedOccType);
            this.updateWizardSteps(component);
        }else{
             this.updateWizardSteps(component);
        }
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
        
        const allStepNames = [
            
            $A.get('$Label.c.CuAp_MoveInWizardSelectLocationStep'), 
            $A.get('$Label.c.CuAp_MoveInWizardEnterMoveInDateStep'), 
            $A.get('$Label.c.CuAp_MoveInWizardAdditionalOccupantsStep'), 
            $A.get('$Label.c.CuAp_MoveInWizardSelectServicesStep'),  
            $A.get('$Label.c.CuAp_MoveInWizardSelectBundlesStep'),  
            $A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'),  
            $A.get('$Label.c.CuAp_MoveInWizardSelectContractStep'),
            $A.get('$Label.c.CuAp_AUMoveInWizardDebtCreditTransfer'),    
            $A.get('$Label.c.CuAp_MoveInWizardWelcomeLetterStep'),       
            $A.get('$Label.c.CuAp_MoveInWizardDisplayBillStep')
        ];
    	
    	// clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        var status = component.get('v.status');

    	// remove the additional occupants step for non-HH accounts
    	if (!status.isHHAccount) {
    		remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardAdditionalOccupantsStep'));
    	}

    	// remove the select contract step if no active contracts
    	if (!status.hasContract) {
    		remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardSelectContractStep'));
    	}

    	// remove the enter reading step if no measured supply point
    	if (!status.hasMeasuredSupplyPoint) {
    		remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'));
    	}
        
        if(wizObj.selectedOccType){
            if(wizObj.selectedOccType == $A.get("$Label.c.CuAp_AUMoveInOccType")){
                remove(stepNames, $A.get('$Label.c.CuAp_AUMoveInWizardDebtCreditTransfer'));
            }
            else{
                remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardEnterReadingsStep'));
                remove(stepNames, $A.get('$Label.c.CuAp_MoveInWizardDisplayBillStep'));
                //component.set('v.endStep', true);
            }
        }
    	// update the steps
        component.set('v.stepNames', stepNames);
    },

    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {
    	
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
                this.showNotification($A.get('$Label.c.CuAp_WizardCompletionError'));
            }
        });
        $A.enqueueAction(action);
    },
    
	// handle the move in response
    handleMoveInResponse: function(component, response) {

        if (response.getState() === 'SUCCESS') {
        
        	// good exit when a contract Id is returned
        	if (response.getReturnValue() != null) {
        		return response.getReturnValue();

			// null contract Id exit
        	} else {
	    		this.handleError(component, response);
		    }

        // error exit
        } else {
	    	this.handleError(component, response);
        }
        return null;        
	},

    // call the server to complete move in
    callApexMoveIn: function(component) {
    	
    	component.find('spinner').show();
        var action = component.get('c.moveIn');
    	var wizObj = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizObj
        });
        action.setCallback(this, function(response) {
        	var wizObj = component.get('v.wizardprop');
            
            var wizardResponse = this.handleMoveInResponse(component, response);
            component.set('v.wizardResponse', wizardResponse);
          
            //wizObj.contractId = this.handleMoveInResponse(component, response);
            wizObj.contractId = wizardResponse.contractId;
            
            component.find('spinner').hide();
            var returnContractIds = [];
            
            if(wizardResponse.contractIdList){
                
                var listContract = wizardResponse.contractIdList;
                listContract = listContract.split(';');
                var ids = [];
                for(var k = 0; k < listContract.length; k++){
                    returnContractIds.push(listContract[k]);
                }
                
                if(returnContractIds.length > 0){
                    component.set('v.newListOfContractId', returnContractIds);
                }
                
            }
            
            // if we've got a contract Id, calculate a bill
            if (wizObj.contractId) {
                // It means there was debt on location and make a separate callout
                if(wizObj.debtOnLocation && wizObj.debtOnLocation > 0){
                    wizObj.wizBillCalculationId = wizardResponse.wizBillCalculationId;
                    
                    component.set('v.wizardprop', wizObj);
                    // Call transferDebts method and call heroku api to transfer debt information
                    var action = component.get('c.debtTransferCallOut');
                    action.setParams({
                        'billCalcId': wizardResponse.wizBillCalculationId,
                        'contractId': wizardResponse.contractId,
                        'locationId': wizardResponse.locationId
                        
                    });
                    action.setCallback(this, function(response) {
                        var responseFromDebtTransfer = this.handleMoveInResponse(component, response);
                        
                        if(responseFromDebtTransfer && responseFromDebtTransfer == $A.get('$Label.c.GlUt_OK')){
                            this.goToRecord(wizObj.contractId);
                        }
                    });
                    $A.enqueueAction(action);
                }
                else if(wizObj.creditAmountToTransfer && wizObj.creditAmountToTransfer > 0){
                    this.goToRecord(wizObj.contractId);
                }
                else if(wizObj.selectedOccType && wizObj.selectedOccType == $A.get('$Label.c.CuAp_AUMoveInOccType')){
                    
                    if(returnContractIds.length == 0){
                        component.set('v.newRecordId', wizObj.contractId);
                    }
                    component.set('v.wizardprop', wizObj);
                    // flag that the server move in has occurred
                    component.set('v.isCommitted', true);
                    // calculate the bill
                    var calculateBillCmp = component.find('calculateBillComponent');
                    calculateBillCmp.calculateBills(function(response) {
                        wizObj.billId = response;
                    });
                }
                else{
                    this.goToRecord(wizObj.contractId);
                }
            }
            component.set('v.wizardprop', wizObj);
        });
        $A.enqueueAction(action);
    }
})