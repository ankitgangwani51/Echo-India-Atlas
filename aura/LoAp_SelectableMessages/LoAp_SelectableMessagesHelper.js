({
	doInit : function(component, event, helper) {        
        this.callServer(component, 'c.retrieveFieldList',
                        function(response) {
                            component.set('v.fieldList', response);                             
                        },
                        null);  
        let param = {recordId : component.get('v.recordId'),
                     sObjectName: component.get('v.sObjectName') };
        this.callServer(component, 'c.retrieveRecordList',
                        function(response) {
                            component.set('v.recordList', response);                           
                        },
                        param);          
        console.log('list=> ' + component.get('v.recordList')) ;
	},
    
    doActive: function(component) {
        component.set('v.isActive', true);            
    },
    
    doCancel: function(component) { 
        // Set all variables to default values        
        component.set("v.isActive", false);         
    },
    
    doSave : function(component) {
        var recList = component.get("v.recordList");
        //Need to loop through all of the entries in the list and then set the sObject types so that the 
        //server can reserialise the records
        for(var i=0; i < recList.length; i++){
            var recEntry = recList[i];
            var msgEntry = recEntry.objectMap[this.setPrefixedString('Message__c')];    
           
            let msgatributes =  {
                "type": this.setPrefixedString('Message__c'),
            }; 
            msgEntry.attributes=msgatributes;            
        }
        
		// retrieve list of fields and properties for 		
        let param = {"responseJSON" : JSON.stringify(recList),
                     "recordId" : component.get("v.recordId"),
                     "sObjectName" : component.get("v.sObjectName")
        			};
        this.callServer(component,'c.saveInformationStatementMessageDetails', 
                          function(response) {                              
                             this.showToast(response);
                          	 $A.get('e.force:refreshView').fire();
                          },
                          param); 
		this.doCancel(component); 
	},
    
    // show toast message and return
    showToast: function(result) {    	 	
        var message;
        var title;
        var type;
    	switch (result) {
            case $A.get("$Label.c.GlAp_Success"):    // AT-4134 review comment  'Success':
            	message = $A.get("$Label.c.GuAp_RecordSuccessfullyUpdatedMsg");
                title = $A.get("$Label.c.GuAp_SuccessTitle");
                type = $A.get("$Label.c.GlAp_Success");
            	break;
            default:                                   // AT-4134 review comment
            	message = result;
                title = $A.get("$Label.c.CuAp_LightningStateNotSuccessTitle");
                type = $A.get("$Label.c.GlAp_NotificationTypeError");
            	break;           
        }
        
        if(message) {
        	var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
        					"title": title,    // AT-4134 review comment "Success!",		// TO-DO - Label
        					"type": type,      // AT-4134 review comment "Success",
        					"message": message
        				});
        	toastEvent.fire();
        }      
    }, 
    
})