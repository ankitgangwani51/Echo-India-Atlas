({
	DEBUG: 'CalculateBill: ',
	POLLING_INTERVAL: 5000,		// ms
	MAX_ATTEMPTS: 5,

	// TO-DO - move this to the billing actions component and handle bill calculation complete event there
	// switch to another record page
    goToRecord: function(recordId) {
        console.log(this.DEBUG + 'redirecting ...');
        var evt = $A.get('e.force:navigateToURL');
        console.log(this.DEBUG + 'record Id: ' + recordId);
        evt.setParams({
            url: '/one/one.app#/sObject/' + recordId
        });
        evt.fire();
    },

	// fire pending bill calculations complete event to pass bill Ids to a parent component
    fireBillsCompleteEvent: function(component) {
        console.log(this.DEBUG + 'firing bill complete event ...');
    	var errorEvent = component.getEvent('billCalculationCompleteEvent');
    	var billIds = component.get('v.billIds');
        //Fix for AT-2303 Starts here
    	var billId = (billIds) ? billIds[0] : null;		// pass first bill Id only
        //Fix for AT-2303 Stops here
        errorEvent.setParams({
            'billId': billId
        });

        // fire the event
        errorEvent.fire();			
   },

    // poll every [interval] until [limit]
	poller: function(callback, interval, limit, component) {
		var loopCounter = 0;
	    callback();

	    var helper = this;
	    var Id = setInterval(function() {
	    	console.log(helper.DEBUG + 'polling ... ' + loopCounter);
	    	callback();
            //Fix AT-2303 starts here
		    if (++loopCounter >= limit) {
            //Fix AT-2303 ends here
		    	clearInterval(Id);
	        	helper.requestComplete(component);
	        	
	        	// display timeout error
	    		console.log(helper.DEBUG + 'request poller timed out ... '+loopCounter );
	        	helper.showNotification(component, $A.get('$Label.c.BlAp_BillMsgPleaseTryLater'));
		    }
		}, interval);
		
		// save the Id
        component.set('v.pollerId', Id);
	},
	
    // handle the bill calculations response
    handleBillCalculations: function(component, response) {

        if (response.getState() === 'SUCCESS') {
        	var billCalculations = response.getReturnValue();
        	component.set('v.billCalculations', billCalculations);
        	console.log(this.DEBUG + 'initiateBillsRequest() Response: ' + JSON.stringify(billCalculations));

	        // make the bill requests
	        if (billCalculations.length > 0) {
	        	this.callApexRequestBills(component);
	        	
	        // no related contracts
	        } else {
	        	console.log(this.DEBUG + 'no related contracts found');
	        	this.requestComplete(component);
	        	this.fireBillsCompleteEvent(component);
	        }
	        	
        // error exit
        } else {
	    	this.requestComplete(component);
        	this.handleError(component, response);
        }
        return false;        
	},

	// handle the bill requests response
    handleBillRequests: function(component, response) {
    
    	var helper = this;
        if (response.getState() === 'SUCCESS') {
        	var billCalculations = response.getReturnValue();
        	component.set('v.billCalculations', billCalculations);
        	console.log(this.DEBUG + 'requestBills() Response: ' + JSON.stringify(billCalculations));
       
        	// poll for bill results
			helper.poller($A.getCallback(function() {
				helper.callApexGetBills(component);
			}), 
			this.POLLING_INTERVAL, this.MAX_ATTEMPTS, component);        	

        // error exit
        } else {
	    	this.requestComplete(component);
        	this.handleError(component, response);
        }
       return false;        
	},

	// handle the bill response
    handleBillId: function(component, response) {

        if (response.getState() === 'SUCCESS') {
        
        	// good exit when the bill is returned
        	if (response.getReturnValue() != null) {
	        	console.log(this.DEBUG + 'got bill result ... ' + JSON.stringify(response.getReturnValue()));
	    		var billIdsMap = response.getReturnValue().billIdsMap;
	    		var error = response.getReturnValue().error;
	        	if (error) {
	        		console.log(this.DEBUG + 'error: ' + error);
	        	
		        	// stop polling
			    	clearInterval(component.get('v.pollerId'));
			    	this.requestComplete(component);
                    //Change Starts Here for AT-2350
                    if (error == $A.get('$Label.c.BlAp_BillCalcResultNoBillResponse')) {
                        this.showNotification(component, error, 'warn');
                    } else {
                        this.showNotification(component, error);
                    }
                    //Change ends Here for AT-2350
			        return null;
	        	}
	    		
	        	console.log(this.DEBUG + 'billIdsMap: ' + JSON.stringify(billIdsMap));
	    		var billIds = component.get('v.billIds');
	    		var billCalculations = component.get('v.billCalculations');
	    		
	    		// find the bill calculation
        		for (var i = 0; i < billCalculations.length; i++) {
        			var billCalculationId = billCalculations[i].Id;
        			if (billCalculationId in billIdsMap) {
        			
        				// get the bill Id
        				if (billIdsMap[billCalculationId].length > 0) {
	        				var billId = billIdsMap[billCalculationId][0];
	        				if (billId) {
	        					console.log(this.DEBUG + 'bill calculation complete Id: ' + billCalculationId);
	        					console.log(this.DEBUG + 'bill Id: ' + billId);
	        					
	        					// set the bill calculation status to complete and add the bill Id to the list
		        				if (billCalculations[i][this.setPrefixedString('Status__c')] != $A.get('$Label.c.BlIn_BillCalculationStatusCompleted')) {
			        				billCalculations[i][this.setPrefixedString('Status__c')] = $A.get('$Label.c.BlIn_BillCalculationStatusCompleted');
		        					billIds.push(billId)
		        					break;
		        				}
		        			}
		        		}
        			}
        		}
	    		component.set('v.billCalculations', billCalculations);
        		component.set('v.billIds', billIds);
        		
        		// if we have all the bill results
        		if (billIds.length >= billCalculations.length) {

		        	// stop polling
			    	clearInterval(component.get('v.pollerId'));
	
		        	this.requestComplete(component);
					if (component.get('v.showButton') == true 
							&& component.get('v.billIds') != null) {
						this.goToRecord(component.get('v.billIds'));
					}
					this.fireBillsCompleteEvent(component);
				}

			// this bill not ready yet
        	} else {
	    		console.log(this.DEBUG + 'bill not ready ... ' );
		    }
        	return true;

        // error exit
        } else {
	    	console.log(this.DEBUG + 'bill result returned error ... ' );
        
        	// stop polling
	    	clearInterval(component.get('v.pollerId'));
	    	this.requestComplete(component);
	    	console.log(this.DEBUG + 'response: ' + response);
        	this.handleError(component, response);
        }
        return false;        
	},

	// initiate a new bills request
    callApexInitiateBillsRequest: function(component, billCalculationType) {
    
    	// default object name is contract
    	var objectName = component.get('v.sObjectName')
    	if (!objectName) {
    		objectName = this.setPrefixedString('BillingContract__c');
    	}

        var listContractIds = component.get('v.listOfContractId');
      //  alert('listContractIds = '+listContractIds)
    	// create or get the bill calculation records
        var action = component.get('c.initiateBillsRequest');
        action.setParams({
        	'recordId': component.get('v.recordId'), 
        	'objectName': objectName, 
        	'billCalculationType': billCalculationType,
            'listContractIds': listContractIds
        });
        action.setCallback(this, function(response) {	
        	this.handleBillCalculations(component, response);
        });
        $A.enqueueAction(action);
		console.log(this.DEBUG + 'recordId: ' + component.get('v.recordId'));
		console.log(this.DEBUG + 'objectName: ' + component.get('v.sObjectName'));
		console.log(this.DEBUG + 'server initiateBillsRequest() call queued');
	},

	// request the bills
    callApexRequestBills: function(component) {

    	// initialise the bill Ids
		var billIds = [];
		component.set('v.billIds', billIds);
		
        var action = component.get('c.requestBills');
        action.setParams({
        	'billCalculationsJSON': JSON.stringify(component.get('v.billCalculations'))
        });
        action.setCallback(this, function(response) {
        	this.handleBillRequests(component, response);
        });
        $A.enqueueAction(action);
        console.log(this.DEBUG + 'server requestPendingBills() call queued');
	},

	// get the bill results
    callApexGetBills: function(component) {
    	var billCalculations = component.get('v.billCalculations');

    	for (var i = 0; i < billCalculations.length; i++) {
    		console.log(this.DEBUG + 'billCalculations[' + i + ']: ' + JSON.stringify(billCalculations[i]));
    		if (billCalculations[i][this.setPrefixedString('Status__c')] != $A.get('$Label.c.BlIn_BillCalculationStatusCompleted')) {
		        var action = component.get('c.getBill');
		        action.setParams({
		        	'billCalculation': billCalculations[i]
		        });
		        action.setCallback(this, function(response) {
		        	//return this.handleBillId(component, response);  // AT-3227
		        	this.handleBillId(component, response);   // AT-3227
		        });
		        $A.enqueueAction(action);
		        console.log(this.DEBUG + 'server getBill() call queued');
		    }
    	}
	},

    // called when a request is initiated to render the spinner etc
    requestInitiated: function(component) {
    	this.showNotification(component, $A.get('$Label.c.BlAp_CalculatingBillMsg'), 'text');
		component.find('spinner').show();
    },

    // called when a request is completed to hide the spinner etc
     requestComplete: function(component) {
    	this.clearNotification(component);
        component.find('spinner').hide();
    },

    // handles any errors
    handleError: function(component, response) {
    	console.log(this.DEBUG + 'Exception caught successfully');
    	console.log('***'+response.getError()[0].message);
        this.showNotification(component, response.getError()[0].message);
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
    	component.find('notifier').showNotification([message], type);
    },

    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
    	component.find('notifier').clearNotification();
    },   
})