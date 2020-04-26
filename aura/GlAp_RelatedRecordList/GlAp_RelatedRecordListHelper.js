({
	DEBUG: 'RelatedRecordList: ',
	
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
                        	  'objectName': component.get('v.objectName'), 
                        	  'fieldsetName': component.get('v.detailListFields'),
                              'deleteOption': component.get('v.deleteOption') //Changes for AT-3317 Starts/Ends Here
                          });
    },

	// get the list of records
    getRecords: function(component) {
    	var recordId = component.get('v.recordId');
        console.log(this.DEBUG + 'recordId: ' + recordId);
        console.log('v.filter === '+component.get('v.filter'))
        if (recordId) {
	        this.callServer(component, 'c.retrieveRecords',
	                          function(response) {
	                              component.set('v.records', response);			
	                          },
	                          {
	                        	  'recordId': recordId, 
	                        	  'objectName': component.get('v.objectName'), 
	                        	  'parentField': component.get('v.parentField'),  
	                        	  'fieldsetName': component.get('v.detailListFields'), 
	                        	  'filter': component.get('v.filter')
	                          });
	    }
    },

    handleRowClickEvent: function(component, event) {
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        console.log(this.DEBUG + 'rowId: ' + rowId);
        
        if (tableName == component.get('v.object.labelPlural') + 'Table') {
        	event.stopPropagation();		// prevent further event propagation
	    	var records = component.get('v.records');
	    	var selectedRecord;
	    	var selectedRecords = [];
	    	var amendAllAfter = component.get('v.amendAllAfter');
	    	var foundSelected = false;
	    	
	    	// unselect the selected row if it was clicked again and this is an amendments related list
	    	if (component.get('v.forAmendments') && component.get('v.selectedRecord.Id') == rowId) {
	    		rowId = null;
	    	}
        
	        for (var i = 0; i < records.length; i++) {
	            if (rowId && records[i].uniqueId == rowId) {
	            	records[i].isSelected = true;
	            	selectedRecord = records[i].objectMap[component.get('v.objectName')];
	            	foundSelected = true;
	            	if (!amendAllAfter) selectedRecords.push(records[i]);
	            }
	            else {
	                records[i].isSelected = false;
	            	if (amendAllAfter && rowId && !foundSelected) {
	            		selectedRecords.push(records[i]);
	            	}
	            }
	        }
	        component.set('v.records', []);
	        component.set('v.records', records);
	        component.set('v.selectedRecord', selectedRecord);
	        component.set('v.selectedRecords', selectedRecords);
	        console.log(this.DEBUG + 'selectedRecords: ' + JSON.stringify(selectedRecords));
        }
    },
    //Changes for AT-3317 Start Here
    // handles a cancel button press
    handleRowButtonPressEvent: function(component, event) {
        var rowId = event.getParam('RowId');
        var recordValues = component.get('v.records');
        for (var i = 0; i < recordValues.length; i++) {
            if (recordValues[i].uniqueId == rowId) {
                let params = {
                    'sobjectRowId' : rowId
                };
                this.callServer(component, 'c.setRecordInvalid',
                                function(response) {
                                    if(response.length > 0){
                                        this.getRecords(component);
                                        component.set('v.invalidRecordId',rowId);
                                        console.log(this.DEBUG + 'Calculating pending bills ...')
                                        var calculateBillCmp = component.find('calculatePendingBillComponent');
                                        calculateBillCmp.calculateBills(function(response) {
                                            var billIds = response;
                                            console.log(this.DEBUG + 'bill Ids: ' + billIds)
                                        });
                                    }
                                },      				
                                params);
                break;
            }
        }
        
    },
    //Changes for AT-3317 Ends Here
})