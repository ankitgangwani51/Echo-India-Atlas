({
    doInit: function(component, event) {                  
        component.set('v.serviceItem', {'sobjectType': this.setPrefixedString('ServiceItem__c')});
    },
    
    doActive: function(component) {        
        component.set('v.isActive', true); 
        let param = {"sObjectName" : component.get("v.sObjectName"),
                     "recordId" : component.get("v.recordId")            
        };        
        this.callServer(component,'c.retrieveServiceItemDetails', 
                        function(response) { 
                            component.set('v.objWrapper', response);                            
                            component.set('v.serviceItemFields',response.siFieldPropList);
                            component.set('v.serviceItem',response.objServiceItem);                        
                        },
                        param);         
    },
    
    doCancel: function(component) { 
        // Set all variables to default values 
        component.set("v.isActive", false);         
    },
    
    doSave: function(component){ 
        
        var suspendedStartDate = component.get('v.siSuspendStartDate');
        var records = component.get('v.serviceItem');
        var suspendedEndDate = records[this.setPrefixedString('SuspendEndDate__c')];
        
        //validations
        //Suspend Start Date Cannot be before Start Date 
        if(suspendedStartDate < records[this.setPrefixedString('StartDate__c')] ){
            this.showToast($A.get("$Label.c.CuAp_SuspendStartDateBeforeSIStartDate"));
            return;
        }
        //Suspended End Date Cannot be before Suspend Start Date
        if(suspendedEndDate < suspendedStartDate){
            this.showToast($A.get("$Label.c.CuAp_SuspendEndDatebeforeSuspendStartDate"));
            return;
        }
        //Suspend End Date cannot be after End Date
        if(suspendedEndDate > records[this.setPrefixedString('EndDate__c')]){
            this.showToast($A.get("$Label.c.CuAp_SuspendEndDateAfterSIEndDate"));
            return;
        } 
       
        let param = {"recordId" : component.get("v.recordId"),
                     "suspendedStartDateString" :  component.get('v.siSuspendStartDate'),
                     "suspendedEndDateString" : records[this.setPrefixedString('SuspendEndDate__c')]
        };
        this.callServer(component,'c.saveServiceItemRecord', 
                          function(response) {
                             this.showToast(response);
                             if(response === $A.get("$Label.c.GlAp_Success")){
                                this.doCancel(component);
                             	$A.get('e.force:refreshView').fire();                                
                             }
                          },
                          param);  
    },    
    
    // show toast message and return
    showToast: function(result) {    	 	        
        var title;
        var type;
        var message;
    	switch (result) {
            case 'Success':
                title = $A.get("$Label.c.GuAp_SuccessTitle");
                type = $A.get("$Label.c.GlAp_Success");                
            	message = $A.get("$Label.c.GuAp_RecordSuccessfullyUpdatedMsg");
            	break;
            default:
                title = $A.get("$Label.c.CuAp_LightningStateNotSuccessTitle");
                type = $A.get("$Label.c.GlAp_NotificationTypeError");  
            	message = result;
            	break;           
        }
        
        if (message) {
        	var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
        					"title": title,		
        					"type": type,
        					"message": message
        				});
        	toastEvent.fire();
        }      
    },   
    
    
    
})