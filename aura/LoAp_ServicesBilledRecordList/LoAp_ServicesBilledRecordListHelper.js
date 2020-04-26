({	
    doInit : function(component, event) {
		this.callServer(component, 'c.retrieveServiceBilledFieldSetList',
                        function(response) {
                           component.set('v.fieldList', response); 
                        },
                        null);   
        this.doChange(component);
	},
    
    doChange : function(component) {
        
        // Reading Record is selected
        var recordId = component.get('v.recordId');
    
        if(recordId != null || recordId != undefined){           
            
            let params = {
                'recordId': recordId
            };
            this.callServer(component, 'c.retrieveServiceBilledFieldRecords',
                            function(response) {
                                component.set('v.recordList', response);                            
                            },
                            params);
        
        }
	}
})