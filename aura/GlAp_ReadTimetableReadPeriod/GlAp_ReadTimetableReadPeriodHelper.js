({
	// initialise component
    doInit: function(component) {  
        
        // retrieve list of fields and properties for Read Timetable
        this.callServer(component, 'c.retrieveFieldPropDetails',
                          function(response) {
                              component.set('v.fieldList', response);
                          },
                          null);
        
        //Retrieve list of fields and properties for Read Period
            this.callServer(component,'c.retrieveReadPeriodFieldPropDetails',
                              function(response){
                                  component.set('v.recordFields', response);   
                              },      				
                              null);
        
        // get the records for Read Timetable
        this.callServer(component, 'c.retrieveRecords',
                        function(response) {
                            var defaultRowId;
                            component.set('v.recordList', response);	
                            var records = component.get('v.recordList');
                            if(records.length > 0){
                                defaultRowId = records[0].objectMap[this.setPrefixedString('ReadTimetable__c')]['Id']; 
                                component.set('v.defaultRowId', defaultRowId);
                                this.getPeriodRecords(component, defaultRowId);  
                            }
                        },
                        null); 
        
        
    }, 
    handleRowClickEvent: function(component, event) {
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        if (tableName == $A.get("$Label.c.LoAp_ReadTimetableObject")) {
            // get the records for Read Period
            this.getPeriodRecords(component, rowId); 
        }
    },    
	
    getPeriodRecords: function(component, rowId) {
        component.find('spinner').show();
         let params ={
                "ReadTimetableId": rowId
            };            
            this.callServer(component,'c.retrieveReadPeriodRecords',
                              function(response){
                                  component.set('v.records', response); 
                                  component.find('spinner').hide();
                              },      				
                              params);  
    },
})