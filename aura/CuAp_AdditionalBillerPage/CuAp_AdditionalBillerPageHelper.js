({
	DEBUG: 'AdditionalBiller: ',
	
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {    
        console.log(this.DEBUG + 'reInitialise');
        
        component.set('v.isInitialised', false);
        component.set('v.billerInfoList', []);
    },

    // check the wizardprop/status on entry 
    checksOnEntry: function(component, event, helper) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');
        
    	if (!component.get('v.isInitialised')) {
    		this.initialiseDisplayedFields(component);
    		this.addRow(component);
    	}
    },

    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {    
    	// do all completion validation here
        this.sendAdditionalBillerInfo(component);
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
    // initialise all the displayed fields
	initialiseDisplayedFields: function(component) {
         component.set('v.isInitialised', true);
    },
    
    // add a biller row to the table
    addRow: function(component) {
    	// check for a blank row
        var billerInfoObj = component.get('v.billerInfoList');
        var blankRow = false;
        
        for (var i = 0; i < billerInfoObj.length; i++) { 
            if (!(billerInfoObj[i].acc && billerInfoObj[i].acc.Id)) {
                blankRow = true;
                break;
            }
        }
        
        // add a new row if not already a blank row
        if (!blankRow) {
	        this.callServer(component, 'c.addBiller', 
	                          function(response) {
	        						var wrappers = component.get('v.billerInfoList');
	        						wrappers.push(response);
	        						component.set('v.billerInfoList', wrappers);
	                          },
	                          null);
	    }
    },
    
    // add the additionalLocationOccupants to the wizardprop object
    sendAdditionalBillerInfo: function(component) {
        debugger;
        var wizObj = component.get('v.wizardprop');                
        var billerInfoObj = component.get('v.billerInfoList');
        var locOccupant = [];        
        //var occTypeValue;
        var billerInfo;
        //var wrappers = [];
        for (var i = 0; i < billerInfoObj.length; i++) { 
            billerInfo = billerInfoObj[i]; 
            /*if (Object.values(billerInfo.locOcc) != billerInfo.occTypeOptions[0]) {
                for (var j = 1; j < billerInfo.occTypeOptions.length; j++) {
                    if (Object.values(billerInfo.locOcc) == billerInfo.occTypeOptions[j]) {
                        occTypeValue = billerInfo.occTypeOptions[j];
                        for (var k = j; k > 0; k--) {
                            billerInfo.occTypeOptions[k] = billerInfo.occTypeOptions[k - 1];
                        }
                        billerInfo.occTypeOptions[0] = occTypeValue;
                        break;
                    }
                }
            }*/
            //wrappers.push(billerInfo);
            if (billerInfoObj[i].acc && billerInfoObj[i].acc.Id) {
                var rec = {sobjectType: this.setPrefixedString('LocationOccupant__c'),
	                           [this.setPrefixedString('Account__c')]: billerInfoObj[i].acc.Id,
	                           [this.setPrefixedString('Location__c')]: component.get('v.wizardprop.location.Id'),
	                           [this.setPrefixedString('Primary__c')]: false,
	                           [this.setPrefixedString('ShowOnBill__c')]: true,
	                           [this.setPrefixedString('EndDate__c')]: null,
	                           [this.setPrefixedString('StartDate__c')]: component.get('v.wizardprop.moveInDate'),
	                           [this.setPrefixedString('OccupancyType__c')]: billerInfoObj[i].occTypeValue
                          };
            	locOccupant.push(rec);
            }
        }

        // Assigning locationOccupant list values to be inserted in the wizard object
        wizObj.additionalLocationOccupants = locOccupant;
        component.set('v.wizardprop', wizObj); 
        //component.set('v.billerInfoList', wrappers);
    }
})