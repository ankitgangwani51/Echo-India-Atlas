({
	DEBUG: 'DisplayBill: ',
    
	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);
		component.set('v.fieldList', []);
		component.set('v.recordList', []);
		component.set('v.billAmount', null);
    	component.find('spinner').reset();
    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');
    	if (!component.get('v.isInitialised')) {
    		this.initialiseDisplayedFields(component);
    	}
    	this.showBillItemRecords(component);
    },

    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
    	// do all completion validation here
    	console.log(this.DEBUG + 'validateOnNext');       
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

    /* PAGE SPECIFIC FUNCTIONS */
    // initialise all the displayed fields
	initialiseDisplayedFields: function(component) {

        // Retrieve list of fields and properties for the location
        this.callServer(component,'c.retrieveBillItemFieldPropDetails', 
                          function(response) {
                              component.set('v.fieldList', response);
                              console.log('fieldList = ' +JSON.stringify(response));
                              component.set('v.isInitialised', true);
                          },
                          null);
    },  
    
    // get the bill and bill item records
    showBillItemRecords: function(component) {
    	var billId = component.get('v.recordId');
        
        console.log('billId test for new = '+billId);
        
    	if (billId) {
	        let params = {'billId': billId}; 

	        this.callServer(component, 'c.fetchLstOfBillItems',
	                        function(response) {                            
	        					console.log(this.DEBUG + 'bill items : ' + JSON.stringify(response));
                                //MT - 24/05/2018 AT-2685 Start removed the html tags from the ServiceItemTypeName__c field 
                                for(var i = 0; i < response.length; i++){
                                    var text = response[i].objectMap[this.setPrefixedString('BillItem__c')][this.setPrefixedString('ServiceItemTypeName__c')];
                                    var subStringText = text.substring(text.indexOf('>') + 1, text.lastIndexOf('<'));
                                    response[i].objectMap[this.setPrefixedString('BillItem__c')][this.setPrefixedString('ServiceItemTypeName__c')] = subStringText.replace(/&#39;s/,"'s");
                                }
                                //MT - 24/05/2018 AT-2685 End
                                component.set('v.recordList', response);
	                        },                         
	                        params);
	        
	        this.callServer(component, 'c.retrieveBillAmount',
	                        function(response) {     
	                            component.set('v.billAmount', response);
	                        },                         
	                        params);
        }
    },
})