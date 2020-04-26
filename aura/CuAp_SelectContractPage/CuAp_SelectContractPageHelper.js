({
	DEBUG: 'SelectContract: ',

    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
	// clear the entered data and start afresh
    reInitialise: function(component) {
        component.set('v.isInitialised', false);
        component.set('v.accountId', null);
        component.set('v.moveInDate', null);
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.showContracts', false);
        component.set('v.selectedOption', $A.get('$Label.c.CuAp_CreateContractOption'));
        component.set('v.rowId', null);
        component.set('v.isRowSelected', false);
    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');

		if (!component.get('v.isInitialised')) {
			this.initialiseDisplayedFields(component);
		}
        this.getContracts(component);

        if (component.get('v.showContracts')) {
            var recordList = component.get('v.recordList');

            for (var i = 0; i < recordList.length; i++) {

                // select the row which was selected before hitting back button
                if (!component.get('v.isRowSelected')) {
                    break;
                }
                else if (recordList[i].uniqueId == component.get('v.rowId') && component.get('v.isRowSelected')) {
                    recordList[i].isSelected = true;
                    break;
                }
            }
            component.set('v.recordList', recordList);
        }
    },

    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        
        //check for errors
        if (this.hasError(component)) {
            this.showNotification(component, [$A.get('$Label.c.CuAp_NoContractSelectedError')]);
            return false;
        }
        else {
            this.sendSelectedOption(component);
            return true;
        }		
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

		// Call method to retrieve field properties of contract fields to be displayed
        this.callServer(component, 'c.retrieveContractFieldPropDetails',
        					function(response) {
        						component.set('v.fieldList', response);
        					},
        					null);
        component.set('v.isInitialised', true);
    },

	// call server and get contracts
	getContracts: function(component) {
        var wizObj = component.get('v.wizardprop');
        
        // if the account or move in date have changed
		if (component.get('v.accountId') != wizObj.accountId
				|| component.get('v.moveInDate') != wizObj.moveInDate) {
			component.set('v.accountId', wizObj.accountId);
			component.set('v.moveInDate', wizObj.moveInDate);
	
	        let params = {
	            'customerId': wizObj.accountId, 
	            'moveInDate': wizObj.moveInDate, 
	        };
	        
	        // Call method to retrieve active contracts related to account
	        this.callServer(component, 'c.retrieveContractSuppressions',
	        					function(response) {
	        						component.set('v.recordList', response);
	        					},
	        					params);
	    }
	},

	// perform actions when option is changed to 'Create a new contract'
    hideContracts: function(component) {
        
        // Set selected option to Create a New Contract
        component.set('v.selectedOption', $A.get('$Label.c.CuAp_CreateContractOption'));
        
        // hide the contracts table
        component.set('v.showContracts', false);
        var recordList = component.get('v.recordList');
        
		// deselect the row selected
        for (var i = 0; i < recordList.length; i++) {
            if (recordList[i].isSelected) {
                recordList[i].isSelected = false;
                break;
            }
        }
        component.set('v.rowId', null);
        component.set('v.recordList', recordList);
        
        // clear any error message
        this.clearNotification(component);
        return true;
	},

	// perform actions when option is changed to 'Select an existing contract'
    showContracts: function(component) {
        
        // Set selected option to Select an Existing Contract
        component.set('v.selectedOption', $A.get('$Label.c.CuAp_SelectExistingContractOption'));
        
        // display the contracts table
		component.set('v.showContracts', true);
	},

	// perform actions when a contract is selected
    handleRowSelectEvent: function(component, event) {
        var sRowId = event.getParam('RowId');
        var recordList = component.get('v.recordList');

        for (var i = 0; i < recordList.length; i++) {
            if (recordList[i].uniqueId != sRowId) {
                recordList[i].isSelected = false;
            }
        }
        component.set('v.recordList', recordList);
        
        // set id of selected contract in component attribute
		component.set('v.rowId', sRowId);
        
        // clear error message once a contract is selected
        this.clearNotification(component);
        
        // check if any row is selected or deselected
        this.checkSelectedRow(component);
    },

    // check if any row is selected/ deselected
	checkSelectedRow: function(component,event,helper){
        var recordList = component.get('v.recordList');
        var selectedOption = component.get('v.selectedOption');

        for (var i = 0; i < recordList.length; i++) {
            if (!recordList[i].isSelected) {
                component.set('v.isRowSelected', false);
            }
            else if (recordList[i].isSelected) {
                component.set('v.isRowSelected', true);
                break;
            }
        }        
    },

    // perform actions when Next button is clicked
    sendSelectedOption: function(component) {
        var recordList = component.get('v.recordList');
		var wizObj = component.get('v.wizardprop');
        var selectedOption = component.get('v.selectedOption');
        
        // set contract Id to null if creating contract
        if (selectedOption == $A.get('$Label.c.CuAp_CreateContractOption')) {
			wizObj.contractId = null;
		}
        else {
            // otherwise set Id of selected contract
            wizObj.contractId = component.get('v.rowId');
        }
		component.set('v.wizardprop', wizObj);
	},

	// check for errors on click of Next button
    hasError: function(component) {
		var locFound = component.get('v.recordList');
        var radios = document.getElementsByName('options');
        var selectedOption = component.get('v.selectedOption');
		
        // good return if creating new contract
        if (selectedOption == $A.get('$Label.c.CuAp_CreateContractOption')) {
            return false;
        } else {
            var contractSel = false;
            for (var i = 0; i < locFound.length; i++) {
            	
                // good return if a contract is already selected
                if (locFound[i].isSelected) {
                    contractSel = true;
                }
            }
            
            if(contractSel){
                return false;
            } else {
                // error return if no contract is selected
                return true;
            }
        }
    },
})