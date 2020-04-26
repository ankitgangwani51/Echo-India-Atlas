({
	// initialise component
    doInit: function(component) {           

        // get the field list and properties
        this.getFieldProperties(component);

        // get the records
        this.getRecords(component);
    },
    
	// retrieve list of fields and properties
    getFieldProperties: function(component) {           
        this.callServer(component, 'c.getPaymentPropDetails',
                          function(response) {
                              component.set('v.fieldList', response);
                          },
                        null
                        );
    },

	// get the list of records
    getRecords: function(component) {
        this.callServer(component, 'c.getUserPayments',
                          function(response) {
                              component.set('v.recordList', response);			
                          },
                          null
                          );
    },
    
    makePayment : function(component) {
        component.set("v.showMakePayment",true);
    },
    
})