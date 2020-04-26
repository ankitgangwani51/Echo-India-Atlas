({
	DEBUG: 'SuppressionWizard: ',
	
    doInit: function(component, event, helper) {           
        console.log(this.DEBUG + 'initialise');
        
        // Retrieve the lists of contracts and account suppression for the customer
        let params = {
            'customerId': component.get('v.recordId'),
        };
        
        // Retrieve list of fields and properties for the suppression contracts
        this.callServer(component, 'c.retrieveSuppFieldPropDetails',
        				function(response) {
        					component.set('v.fieldList', response);
        				},
        				null);

        // Retrieve list of fields and properties for the account suppression
        this.callServer(component, 'c.retrieveSuppAccountFieldPropDetails',
        				function(response) {
        					component.set('v.fieldListAccSup', response);	
        				},
        				null);

        this.callServer(component, 'c.retrieveContractSuppressions',
        				function(response) {
        					component.set('v.recordList', response);
        				},
        				params);

        this.callServer(component, 'c.retrieveAccountSuppressions',
        				function(response) {
        					component.set('v.recordListAccSup', response);
        				},
        				params);
    },
    
    reloadPage: function() {
		var urlEvent = $A.get('e.force:navigateToURL');
		var currentUrl = window.location.href;
		urlEvent.setParams({
			'url': currentUrl
		});
		urlEvent.fire();
	},

    buildSuppressionsString: function(recList) {
    					
	    // Need to loop through all of the entries in the list and then set the sObject types so that the 
	    // server can reserialise the records
	    for (var i = 0; i < recList.length; i++) {
	    
	        var recEntry = recList[i];
	        var supEntry = recEntry.objectMap[this.setPrefixedString('Suppression__c')];
            var contractEntry = recEntry.objectMap[this.setPrefixedString('BillingContract__c')];
            
	        let suppAttributes = {
	            'type': this.setPrefixedString('Suppression__c'),
	        };
            
            let contractAttributes = {
	            'type': this.setPrefixedString('BillingContract__c'),
	        };
	        
            supEntry.attributes = suppAttributes;
            if(contractEntry){
            	contractEntry.attributes = contractAttributes;    
            }
	        
	    }
	    
	    // Now turn the list into a string to pass to the server as current bug does not permit lists
	    // to be sent to Apex class - an internal error occurs
	    return JSON.stringify(recList);
	},
        
    doSave: function(component, event, helper) {
        var suppressAccount = component.get('v.suppressAccount');

        // build the json string param
        var recordList;
        if (suppressAccount) {
            recordList = component.get('v.recordListAccSup');
            
        } else {
            recordList = component.get('v.recordList');
        }
               
        //Added to handle start date blank scenario -- Swati - 03 Apr 2018
        for (var i = 0; i < recordList.length; i++) {
            if(recordList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressionStartDate__c')] == ''){
                this.showNotification(component, [$A.get("$Label.c.CuAp_SuppressionWizardStartDateValidation")],'error'); 
                return false;
            }
        }
        
        //Added to handle end date blank scenario -- Swati - 03 Apr 2018
        for (var i = 0; i < recordList.length; i++) {
            if(recordList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressionEndDate__c')] == ''){
                delete recordList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressionEndDate__c')];                
            }
        }
        
        
        var suppressionsString = this.buildSuppressionsString(recordList);
        
        let params = {
            'suppressionsString': suppressionsString,
            'customerId': component.get('v.recordId'),
        };
        
        this.callServer(component, 'c.saveSuppressions',
    					function(response) {
    						if (response != 'SUCCESS') {
    							this.showNotification(component, [response]);
    						}
    						else {

    							// reload the page to refresh the suppression indicator
    							this.reloadPage();
    						}
    					},
    					params);
    },

    doManageSuppression: function(component, event, helper) {
        console.log(this.DEBUG + ' doManageSuppression');
        component.set('v.suppressAccount', false);
        component.set('v.suppressSelectedContracts', false);

        // check if the account is suppressed
        var isAccountSuppressed = this.isAccountSuppressed(component);
        if (isAccountSuppressed) {
			this.startSuppressAccount(component);

		} else {

	        // else check if any contracts are suppressed
	        var hasSuppressedContract = this.hasSuppressedContract(component);
			if (hasSuppressedContract) {
				this.startSuppressSelectedContracts(component);
			}
		}

        // activate the wizard
        component.set('v.manageSuppressions', true);
    },

    doCancel: function(component, event, helper) {
        console.log(this.DEBUG + ' doCancel');
        component.set('v.manageSuppressions', false);
    },

    startSuppressSelectedContracts: function(component, event, helper) {
        console.log(this.DEBUG + ' startSuppressSelectedContracts');
        component.set('v.suppressSelectedContracts', true);
        component.set('v.suppressAccount', false);
    },

    startSuppressAccount: function(component, event, helper) {
        console.log(this.DEBUG + ' startSuppressAccount');
        component.set('v.suppressAccount', true);
        component.set('v.suppressSelectedContracts', false);
    },

    // check if we have an active account suppression
    isAccountSuppressed: function(component) {
        var suppressionList = component.get('v.recordListAccSup');
        for (var i = 0; i < suppressionList.length; i++) {

        	// if a row is elected or an Id is present (ie the suppression exists as a record)
        	if (suppressionList[i].isSelected 
        			|| suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')].Id) {
        		return true;
        	}
        }
        return false;
    },
    
    // check if we have any active suppressed contracts
    hasSuppressedContract: function(component) {
        var suppressionList = component.get('v.recordList');
        for (var i = 0; i < suppressionList.length; i++) {

        	// if a row is selected or an Id is present (ie the suppression exists as a record)
        	if (suppressionList[i].isSelected 
        			|| suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')].Id) {
        		return true;
        	}
        }
        return false;
    },
    
    handleRowSelectEvent: function(component, event, helper) {
        var suppressionList;
        var sRowId = event.getParam('RowId');

        // get the records
        var suppressAccount = component.get('v.suppressAccount');
        if (suppressAccount) {
        	suppressionList = component.get('v.recordListAccSup');

        } else {
        	suppressionList = component.get('v.recordList');
        }

        // process the row change
        for (var i = 0; i < suppressionList.length; i++) {

        	// if a selected row is unselected
            if (suppressionList[i].uniqueId == sRowId
            		&& !suppressionList[i].isSelected) {

            	var today = new Date();
            	
            	// if the Id is present (ie the suppression exists as a record)
            	if (suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')].Id) {

	            	// end it using today's date as the end date
		            var endDate = today.getFullYear() + '-' + (parseInt(today.getMonth()) + 1) + '-' + today.getDate();
		            suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressionEndDate__c')] = endDate;

		        } else {
		        
	            	// clear all the displayed suppression fields
		            suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressionReason__c')] = null;
		            suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressBillPrint__c')] = false;
		            suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressRecoveryNotice__c')] = false;
		            suppressionList[i].objectMap[this.setPrefixedString('Suppression__c')][this.setPrefixedString('SuppressionEndDate__c')] = null;
		        }
            }
        }
        
        // update the records
        if (suppressAccount) {
        
        	// hide table to prevent table component rerendering errors whilst updating entries
	        component.set('v.suppressAccount', false);
	        component.set('v.recordListAccSup', suppressionList);

	        // show table again
	        component.set('v.suppressAccount', true);
        
        } else {
        
        	// hide table to prevent table component rerendering errors whilst updating entries
	        component.set('v.suppressSelectedContracts', false);
	        component.set('v.recordList', suppressionList);

	        // show table again
	        component.set('v.suppressSelectedContracts', true);
	    }
    },
 
     // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
    
})