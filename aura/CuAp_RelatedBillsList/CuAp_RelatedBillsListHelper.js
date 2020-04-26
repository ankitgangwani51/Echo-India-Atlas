({
	DEBUG: 'RelatedBillsList: ',
	
    // initialise component
    doInit: function(component) {           

        // get the field list and properties
        this.getFieldProperties(component);

        // get the records
        this.getRecords(component);
    },
    
	// retrieve list of fields and properties
    getFieldProperties: function(component) {           
        this.callServer(component, 'c.retrieveFieldProperties',
                          function(response) {
                              component.set('v.fields', response);
                          },
                          {
                        	  'fieldsetName': this.setPrefixedString(component.get('v.detailListFields'))
                          });
    },

	// get the list of records
    getRecords: function(component) {
    	var recordId = component.get('v.recordId');
        console.log(this.DEBUG + 'recordId: ' + recordId);
        
        if (recordId) {
	        this.callServer(component, 'c.retrieveRecords',
	                          function(response) {
	                              component.set('v.records', response);			
	                          },
	                          {
	                        	  'recordId': recordId, 
	                        	  'fieldsetName': this.setPrefixedString(component.get('v.detailListFields'))
	                          });
	    }
    },
    
    // handles a 'View PDF' button press
    handleRowButtonPressEvent: function(component, event) {
    	this.clearNotification(component);
        var rowId = event.getParam('RowId');
        var bills = component.get('v.records');

        for (var i = 0; i < bills.length; i++) {
            if (bills[i].uniqueId == rowId) {
            	component.set('v.selectedBillId', bills[i].uniqueId);

	        	this.showNotification(component, ['View PDF is not implemented']);
        		// TO-DO - call View PDF component method
        		// show spinner whilst waiting
        		// show bill PDF when complete

	            break;
            }
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