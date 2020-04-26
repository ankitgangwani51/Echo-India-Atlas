({
    // runs when component intialises
    doInit : function(component, event) {
    
    	// get the tab field properties
        this.callServer(component, 'c.retrieveFieldPropDetails',
                        function(response) {
                            component.set('v.tabFields', response);
                            console.log('tabFields: ' + JSON.stringify(response));
                        },
                        null); 
        
        // get the batch request field properties
        this.callServer(component, 'c.retrieveBookExportRequestFields',
                        function(response) {
                           component.set('v.fieldList', response); 
                        },
                        null); 

        // get the batch request records
         this.callServer(component, 'c.retrieveBookExportRequestRecords',
                        function(response) {
                           component.set('v.recordList', response); 
                        },
                        null);
    },

    // called when a table row is clicked
    handleRowClickEvent: function(component, event) {
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        
        // select the record if not already selected
        if (tableName == 'Batch_Request_Queue' && rowId != component.get('v.rowId')) {
        	event.stopPropagation();
        	this.clearNotification(component);
            component.set('v.rowId', rowId);
	        
            // the period Id is required to fetch the Meter Book tab values
            var periodIds;
            var batchRequestList = component.get('v.recordList');
            for (var i = 0; i < batchRequestList.length; i++) {
                if (rowId == batchRequestList[i].uniqueId) {
                	var parameters = batchRequestList[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Parameters__c')]
                    if (parameters) {
                        periodIds = JSON.parse(parameters).periodID;
                    }
                    break;
                }
            }
            
            // get the tab related records for the selected record
            let params = {'batchRequestQueueId': rowId, 
            				'periodIds': periodIds
            				};
            this.callServer(component, 'c.retrieveTabRecords',
                            function(response) {
            					var tabRecords = response;
            					
            					// add the field names to the tab records
                                var tabFields = component.get('v.tabFields');
                                for (var i = 0; i < tabRecords.length; i++) {
                                	tabRecords[i].fields = tabFields[tabRecords[i].tabName];
                                }
                                component.set('v.tabRecords', tabRecords);
                                
                                // enable tabs once a row has been clicked
						        if (!component.get('v.showTabs')) {
						            component.set('v.showTabs', true);
						        }
                            },      				
                            params);            
        }
    },   
    
    // handles a cancel button press
    handleRowButtonPressEvent: function(component, event) {
    	this.clearNotification(component);
        var rowId = event.getParam('RowId');
        var brqValues = component.get('v.recordList');

        for (var i = 0; i < brqValues.length; i++) {
            if (brqValues[i].uniqueId == rowId) {
            	var status = brqValues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')];

            	if (status == $A.get('$Label.c.GlAp_Initialised') 
            			|| status == $A.get('$Label.c.GlAp_Processing')  
            			|| status == $A.get('$Label.c.GlAp_Pending')) {
                			         
			        let params = {
			            'BRQId' : rowId
			        };
		            this.callServer(component, 'c.cancelledStatus',
		                            function(response) {                                    
							        	component.set('v.recordList', response); 
		                            },      				
		                            params);

		        } else {
		        	this.showNotification(component, [$A.get('$Label.c.GlAp_CannotCancelBatch')]);
		        }
	            break;
            }
        }
    },
    
    // called when a tab is clicked
    handleTab: function(component) {
    	this.clearNotification(component);
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