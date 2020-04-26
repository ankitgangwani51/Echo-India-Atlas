({
    // initialise component
    doInit: function(component) {    
      	this.clearNotification(component);
        component.set('v.discountTypeId',null);
        component.set('v.lcHost',  'https://' +  window.location.hostname  + [$A.get("$Label.c.GlAp_BatchProcessImage")]);
        this.callServer(component, 'c.retrieveFieldList',
                        function(response) {
                            component.set('v.fieldList', response);                             
                        },
                        null);  
        
        this.callServer(component, 'c.retrieveRecordList',
                        function(response) {
                            component.set('v.recordList', response);                           
                        },
                        null);   
    },
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	 component.find('notification').clearNotification();
    },
    
      // displays the modal
    newRequest: function(component) {
        // null batch class defaults to new batch request queue with basic settings
       	this.clearNotification(component);
        var recList = component.get("v.recordList");
        var discTypeId = component.get("v.discountTypeId");
        if(discTypeId == null)
            this.showNotification(component, [$A.get("$Label.c.GlAp_DiscountTypeError")],'error'); 
        else {
            //Need to loop through all of the entries in the list and then set the sObject types so that the 
            //server can reserialise the records
            for(var i=0; i < recList.length; i++){
                var recEntry = recList[i];
                var disTypeEntry = recEntry.objectMap[this.setPrefixedString('DiscountType__c')];    
                
                let msgatributes =  {
                    "type": this.setPrefixedString('DiscountType__c'),
                }; 
                disTypeEntry.attributes=msgatributes;            
            }
            let params = {"responseJSON" : JSON.stringify(recList),
                          "batchProcessId" : component.get("v.recordId")
                         };
            
            this.callServer(component, 'c.createDefaultBatchRequest',
                            function(response) {
                                if(response == false)
                                    this.showNotification(component, [$A.get("$Label.c.GlAp_DiscountTypeError")],'error'); 
                                else {
                                    var appEvent = $A.get("e.c:GlAp_AppRefreshEvent");
                                    appEvent.setParams({
                                        "refreshFlag" : true });
                                    appEvent.fire();      //Fired Application Event to refresh CuAp_BatchRequestHistory Component
                                    
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "success",
                                        "message": $A.get("$Label.c.GlAp_NewBatchRequestCreated") 
                                    });        
                                    toastEvent.fire();
                                    for(var i=0; i < recList.length; i++){   //To reset the Selected Values
                                        recList[i].isSelected = false;
                                    }
                                    component.set('v.recordList', recList);
                                }
                            }, 
                            params);
        }
    },
    
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notification').clearNotification();
    },  
    
    handleRowClickEvent: function(component, event, helper) {
        this.clearNotification(component);
        var  sRowId   = event.getParam('RowId');
        component.set('v.discountTypeId',sRowId);
    }
})