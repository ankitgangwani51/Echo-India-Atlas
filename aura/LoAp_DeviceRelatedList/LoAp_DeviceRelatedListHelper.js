({
	DEBUG: 'DeviceRelatedList: ',
	
    // initialise component
    doInit: function(component) {           

        // retrieve list of fields and properties
        this.callServer(component, 'c.retrieveFieldPropDetails',
                          function(response) {
                              component.set('v.recordFields', response);
                          },
                          null);

        // get the records
        this.getRecords(component);        
    },
    
    handleRowClickEvent: function(component, event) {
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        console.log(this.DEBUG + 'rowId: ' + rowId);
        
        if (tableName == component.get('v.object.labelPlural') + 'Table') {
	    	component.set('v.selectedId', rowId);
            
	    	var sObjectName = component.get('v.sObjectName');
        	
        	// flag if the selected record is active
        	var records = component.get('v.records');
	    	for (var i = 0; i < records.length; i++) {
	    		if (records[i].objectMap[sObjectName]['Id'] === rowId) {
	    			component.set('v.recordIsActive', records[i].objectMap[sObjectName][this.setPrefixedString('Active__c')]);
	    		}
	    	}
        }
    },
    
	// get the list of records
    getRecords: function(component) {
        console.log(this.DEBUG + 'recordId: ' + component.get('v.recordId'));
        
        this.callServer(component, 'c.retrieveRecords',
                          function(response) {
                              component.set('v.records', response);	
                          },
                          {'recordId': component.get('v.recordId'),
        });    
    },
})