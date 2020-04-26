({
    doInit : function(component) {
        
        // Retrieve the list of locations for the contract
        let params = {
            "contractId": component.get("v.recordId"),
        };
        
        this.callServer(component,'c.retrieveRelatedLocations',
        				function(response) {
        					component.set("v.recordList", response);
        				},
        				params);   
        
        // Retrieve list of fields and properties
        this.callServer(component,'c.retrieveLocationFieldPropDetails',
        				function(response) {
        					component.set("v.fieldList", response);
        				},
        				null);
    },
})