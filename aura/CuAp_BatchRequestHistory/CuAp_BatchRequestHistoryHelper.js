({
	DEBUG: 'BatchRequestHistory: ',
	
    // initialise component
    doInit: function(component) {           

    	// get the tab field properties
        this.getTabFieldProperties(component);
        
        // get the field list and properties
        this.getFieldProperties(component);

        // get the records
        this.getRecords(component);
    },
    
	// retrieve the tab field properties
    getTabFieldProperties: function(component) {           
        this.callServer(component, 'c.retrieveTabFieldProperties',
	                        function(response) {
	                            component.set('v.tabFields', response);
	                            console.log('tabFields: ' + JSON.stringify(response));
	                        },
	                        {
	                        	'batchProcessId': component.get('v.recordId'), 
	                        });
    },
    
	// retrieve list of fields and properties
    getFieldProperties: function(component) {           
        this.callServer(component, 'c.retrieveFieldProperties',
	        				function(response) {
                                console.log("responsefields = " +JSON.stringify(response));
        						component.set('v.fields', response);
	        				},
	        				{
	        					'fieldsetName': this.setPrefixedString(component.get('v.batchRequestFields'))
	        				});
    },

	// get the list of records
    getRecords: function(component) {
    	var recordId = component.get('v.recordId');
        console.log(this.DEBUG + 'recordId: ' + recordId);
        
        if (recordId) {
	        this.callServer(component, 'c.retrieveRecords',
	        					function(response) {
                                    console.log("response = " +JSON.stringify(response));
        							component.set('v.records', response);			
	        					},
	        					{
	        						'recordId': recordId, 
	        						'fieldsetName': this.setPrefixedString(component.get('v.batchRequestFields')) 
	        					});
	    }
    },

    handleRowClickEvent: function(component, event) {
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        console.log(this.DEBUG + 'rowId: ' + rowId);
        
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        
        // select the record if not already selected
        if (tableName == 'BatchRequestQueueTable' && rowId != component.get('v.rowId')) {
        	event.stopPropagation();
        	this.clearNotification(component);
            component.set('v.rowId', rowId);
	        
            // get the tab related records for the selected record
            let params = {
            				'batchProcessId': component.get('v.recordId'), 
            				'batchRequestQueueId': rowId,
	                    	};
            this.callServer(component, 'c.getTabRecords',
            				function(response) {
            					var tabRecords = response;
            					
            					// add the field names to the tab records
                                var tabFields = component.get('v.tabFields');
                                for (var i = 0; i < tabRecords.length; i++) {
                                	tabRecords[i].fields = tabFields[tabRecords[i].tabName];
                                }
                                component.set('v.tabRecords', tabRecords);
	                            console.log('tabRecords: ' + JSON.stringify(tabRecords));
                                
                                // enable tabs once a row has been clicked
						        if (!component.get('v.showTabs')) {
						            component.set('v.showTabs', true);
						        }
            				}, 
                            params);            
        }
    },
    
    // called when a tab is clicked
    handleTab: function(component) {
    	this.clearNotification(component);
    },
    
    // handles a cancel button press
    handleRowButtonPressEvent: function(component, event) {
    	this.clearNotification(component);
        var rowId = event.getParam('RowId');
        var batchRequestQueues = component.get('v.records');

        for (var i = 0; i < batchRequestQueues.length; i++) {
            if (batchRequestQueues[i].uniqueId == rowId) {
            	var status = batchRequestQueues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')];

            	if (status == $A.get('$Label.c.GlAp_Initialised') 
            			|| status == $A.get('$Label.c.GlAp_Processing')  
            			|| status == $A.get('$Label.c.GlAp_Pending')) {
                			         
			        let params = {
			            'batchRequestQueueId' : rowId
			        };
		            this.callServer(component, 'c.cancelBatchRequestQueue',
		                            function(response) {
		                            
		                            	// refresh the records
							        	this.getRecords(component);
		                            },      				
		                            params);

		        } else {
		        	this.showNotification(component, [$A.get('$Label.c.GlAp_CannotCancelBatch')]);
		        }
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