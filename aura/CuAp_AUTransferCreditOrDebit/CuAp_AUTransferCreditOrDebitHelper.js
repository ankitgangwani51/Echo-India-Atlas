({          
	DEBUG: 'AU Transfer Debit Credit: ',
	
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {            
        component.set('v.isInitialised', false);
        component.set('v.locationId', '');
    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	// do checks here if required
        var wizObj = component.get('v.wizardprop');
        if (wizObj.location.Id) {
	    	//if (!component.get('v.isInitialised')) {
	    		this.initialiseDisplayedFields(component);
	    	//}
        }
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {    
        
        // add the selected services to the wizardprop
        return this.validateCreditAmount(component);
        
        return true;
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },   
    /* END: REQUIRED BY FRAMEWORK */
    
    /* PAGE SPECIFIC METHODS */    
    // initialise all the displayed fields
	initialiseDisplayedFields: function(component) {
        
        var wizObj = component.get('v.wizardprop');
        let params = {"locationId": wizObj.location.Id,
                      "newMoveInDate": wizObj.moveInDate,
                      "occType": wizObj.selectedOccType
                     };

        // Retrieve list of fields and properties for the suppression contracts
        this.callServer(component, 'c.retrieveCreditAndDebitAmount',
                        function(response) {    
                            component.set('v.objCreditDebit', response);    
                            component.set('v.amountOfDebt', response['debtOnLocation']);    
                            component.set('v.totalCreditOnContract', response['creditOnContract']);    
                            
                        },  
                        params); 
         component.set('v.isInitialised', true);
    },
    
    // Validation 
    validateCreditAmount: function(component) {
        var wizObj = component.get('v.wizardprop');
        if(component.get('v.totalCreditOnContract') > 0 && component.get('v.creaditToTransfer') > component.get('v.totalCreditOnContract')){
            this.showNotification(component, [$A.get('$Label.c.CuAp_AUMoveInTransferGTCredit')], 'error');
        	return false;
        }

		wizObj.creditAmountToTransfer = component.get('v.creaditToTransfer');
        wizObj.creditAmountOnContract = component.get('v.totalCreditOnContract');
        wizObj.debtOnLocation = component.get('v.amountOfDebt');
        component.set('v.wizardprop', wizObj);
        
        return true;
        
   },
})