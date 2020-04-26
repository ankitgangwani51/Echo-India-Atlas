({
	doInit: function(component) {
        // retrieve Bill Message Details               
        let param = {"sObjectName" : component.get("v.sObjectName"),
                     "recordId" : component.get("v.recordId")            
        };        
        this.callServer(component,'c.retrieveBillMessageRecordsDetails', 
                          function(response) {
                              component.set('v.recordList', response);
                              console.log('1***' + JSON.stringify(response));
                          },
                          param);        
         
        // retrieve Bill Message fields properties 
        let param1 = {"sObjectName" : component.get("v.sObjectName")
        };                                 
        this.callServer(component,'c.retrieveBillMessagePropDetails', 
                          function(response) {
                              component.set('v.fieldList', response);
                              console.log('2***' +  JSON.stringify(response));
                          },
                          param1);         
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
            var billMsgEntry = recEntry.objectMap[this.setPrefixedString('BillMessage__c')];    
           
            let billMsgatributes =  {
                "type": this.setPrefixedString('BillMessage__c'),
            };  
            
            billMsgEntry.attributes=billMsgatributes;            
        }
        
		// retrieve list of fields and properties for 
        let param = {"responseJSON" : JSON.stringify(recList),
                     "recordId" : component.get("v.recordId"),
                     "sObjectName" : component.get("v.sObjectName")
        			};
        this.callServer(component,'c.saveContractBillMessageDetails', 
                          function(response) {                              
                             this.showToast(response);
                          	 $A.get('e.force:refreshView').fire();
                          },
                          param); 
		this.doCancel(component);        
    },
    
    // show toast message and return
    showToast: function(result) {    	 	
        var message = result;
    	switch (result) {
            case 'Success':
            	message = $A.get("$Label.c.GuAp_RecordSuccessfullyUpdatedMsg");
            	break;
            /*default:
            	message = $A.get("$Label.c.GuAp_NoRecordUpdated");
            	break; */           
        }
        
        if (message) {
        	var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
        					"title": "Success!",		// TO-DO - Label
        					"type": "Success",
        					"message": message
        				});
        	toastEvent.fire();
        }      
    },   
    
})