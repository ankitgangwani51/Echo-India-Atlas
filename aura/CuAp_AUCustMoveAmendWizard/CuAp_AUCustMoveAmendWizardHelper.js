({
	DEBUG: 'AU AmendMoveWizard: ',
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
		if (component.find('selectLocationOccPage') != undefined) component.find('selectLocationOccPage').reInitialise();
        if (component.find('amendMoveDetails') != undefined) component.find('amendMoveDetails').reInitialise();
		if (component.find('enterReadingForLocation') != undefined) component.find('enterReadingForLocation').reInitialise();
        if (component.find('newBillingAddressPage') != undefined) component.find('newBillingAddressPage').reInitialise();
        if (component.find('reviewChanges') != undefined) component.find('reviewChanges').reInitialise();
	},
	
	// check the current page on entry
	checksOnEntry: function(component) {
        debugger;
    	switch (component.get('v.stepName')) {
    		case $A.get('$Label.c.CuAp_AmendMoveWizardSelectLocationOccStep'):
    			if (component.find('selectLocationOccPage') != undefined) component.find('selectLocationOccPage').checksOnEntry()
	        	break;
            case $A.get('$Label.c.CuAp_AmendMoveWizardDetailsPageStep'):
    			if (component.find('amendMoveDetails') != undefined) component.find('amendMoveDetails').checksOnEntry()
	        	break;
         	case $A.get('$Label.c.CuAp_AmendMoveWizardReadingPage'):
    			if (component.find('enterReadingForLocation') != undefined) component.find('enterReadingForLocation').checksOnEntry()
        		break;
            case $A.get('$Label.c.CuAp_MoveOutWizardNewBillingAddressStep'):
            	if (component.find('newBillingAddressPage') != undefined) component.find('newBillingAddressPage').checksOnEntry();
                break;    
            case $A.get('$Label.c.CuAp_AmendMoveReviewChanges'):
    			if (component.find('reviewChanges') != undefined) component.find('reviewChanges').checksOnEntry()
        		break;    
    	}
	},

	// validate the current page on exit to the next page
	// returns true if page validates
	validateOnNext: function(component) {
    	switch (component.get('v.stepName')) {
    		case $A.get('$Label.c.CuAp_AmendMoveWizardSelectLocationOccStep'):
        		if (component.find('selectLocationOccPage') == undefined
        				|| component.find('selectLocationOccPage').validateOnNext()) {

        			// update the wizard steps once a location has been selected
        			this.updateWizardSteps(component);
        			return true;
        		}
        		break;
            case $A.get('$Label.c.CuAp_AmendMoveWizardDetailsPageStep'):
        		if (component.find('amendMoveDetails') == undefined
        				|| component.find('amendMoveDetails').validateOnNext()) {
        				
        			// update the wizard steps once a move in date has been selected
        			this.updateWizardSteps(component);
        			return true;
        		}
        		break;
            case $A.get('$Label.c.CuAp_AmendMoveWizardReadingPage'):
        		if (component.find('enterReadingForLocation') == undefined
        				|| component.find('enterReadingForLocation').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get('$Label.c.CuAp_MoveOutWizardNewBillingAddressStep'):
                if (component.find('newBillingAddressPage') == undefined 
                		|| component.find('newBillingAddressPage').validateOnNext()) {
                    return true;
                }
                break;    
            case $A.get('$Label.c.CuAp_AmendMoveReviewChanges'):
        		if (component.find('reviewChanges') == undefined
        				|| component.find('reviewChanges').validateOnNext()) {
                    this.callApexMoveAmend(component);
                    return true;
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
        
        if(wizObj.deleteRecord == 'true'){
            allStepNames = [
                $A.get("$Label.c.CuAp_AmendMoveWizardSelectLocationOccStep"),
                $A.get('$Label.c.CuAp_MoveOutWizardNewBillingAddressStep'),
                //$A.get("$Label.c.CuAp_AmendMoveWizardReadingPage"),
                $A.get("$Label.c.CuAp_AmendMoveReviewChanges")
                
            ];
        }
        else{
            allStepNames = [
                $A.get('$Label.c.CuAp_AmendMoveWizardSelectLocationOccStep'), 
                $A.get('$Label.c.CuAp_AmendMoveWizardDetailsPageStep'), 
                $A.get('$Label.c.CuAp_AmendMoveWizardReadingPage'),
                $A.get('$Label.c.CuAp_AmendMoveReviewChanges')
            ];
        }
    	
    	// clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        
    	// update the steps
        component.set('v.stepNames', stepNames);
    },
    
    handleDeleteLocOccEvent:function(component, event, helper) {
        debugger;
        var wizObj = component.get('v.wizardprop');  
        var allStepNames;
        if(wizObj.deleteRecord == 'true'){
            //component.set('v.selectedPaymentMethod', wizObj.selectedPaymentMethod);
            this.updateWizardSteps(component);
            //component.set('v.endStep', false);
        }else{
             this.updateWizardSteps(component);
             //component.set('v.endStep', true);
        }
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
    
    // handles any errors
    handleError: function(component, response) {
        this.showNotification(component, response.getError()[0].message);
    },

    // call the server to complete move in
    callApexMoveAmend: function(component) {
    	component.find('spinner').show();
        var action = component.get('c.moveIn');
    	var wizObj = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizObj
        });
        action.setCallback(this, function(response) {
        	var wizObj = component.get('v.wizardprop');
            var returnContractIds = []
            returnContractIds = this.handleMoveInResponse(component, response);
            console.log('returnContractIds***'+ returnContractIds)
            
            component.find('spinner').hide();
            // if we've got a contract Id, calculate a bill
            
            if(returnContractIds.length > 0){                
                component.set('v.newListOfContractId', returnContractIds);
                //component.set('v.newRecordId', returnContractIds[0]);
                
                var calculateBillCmp = component.find('calculatePendingBillComponent');
                calculateBillCmp.calculateBills(function(response) {
                    var billIds = response;
                });
                
                console.log('123.......returnContractIds ' + returnContractIds);
                console.log('123.......wizObj.accountId ' + wizObj.accountId);
                if(returnContractIds[0] != null){
                    this.goToRecord(returnContractIds[0]);
                }
                else{
                    this.goToRecord(wizObj.accountId);
                }
            }
            component.set('v.wizardprop', wizObj);
        });
        $A.enqueueAction(action);
    }
})