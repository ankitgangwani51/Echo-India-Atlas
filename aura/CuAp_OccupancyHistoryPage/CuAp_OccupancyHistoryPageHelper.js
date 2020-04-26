({
	doInit : function(component, event, helper) {
        
        // fetching the location list field properties
        this.callServer(component, "c.retrieveLocationListFieldProps",
                          function(response){
                            component.set("v.loccationListFieldProps", response);  
                          },
                          null);
        
        let params = {"accountId" : component.get("v.recordId")};
        // fetching the location list data
        this.callServer(component, "c.retrieveLocationListRecords",
                          function(response){
                            component.set("v.loccationListRecords", response);
                            this.fetchOccupantsRecords(component, response[0].uniqueId);
                          },
                          params);
        
        //fetching the occupants list field properties
        this.callServer(component, "c.retrieveOccupantsListFieldProps",
                          function(response){
                            component.set("v.occupantsListFieldProps", response);  
                          },
                          null);
        
	},
    
    //fetching the occupants records
    fetchOccupantsRecords : function(component, recordId){
       let params = {"locationId" : recordId,
                    "accountId" : component.get("v.recordId")};
        this.callServer(component, "c.retrieveOccupantsListRecords",
                          function(response){
                            component.set("v.occupantsListRecords", response);  
                          },
                          params); 
    },
    
    //calls when clicked on the location list row
    handleRowClickEvent : function(component, event, helper) {
        if(event.getParam("Source") == "Location_List"){
            var locationId = event.getParam("RowId");
            this.fetchOccupantsRecords(component, locationId);
        }
    }
})