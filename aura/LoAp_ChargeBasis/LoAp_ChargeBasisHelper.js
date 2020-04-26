({
    // This method is used to get all the charge basis records based on location
	doInit : function(component, event, helper) {
		
        helper.callServer(component,'c.getChargeBasisFields',
                              function(response){
                                  component.set('v.fieldList', response);
                              },      				
                              null); 
        
        let params = {
            "locationId" : component.get('v.recordId')
        }
        
        helper.callServer(component,'c.getChargeBasisRecords',
                              function(response){
                                  component.set('v.recordList', response);
                              },      				
                              params); 
	}
})