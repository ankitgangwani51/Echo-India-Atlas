({
    // initialise component
    doInit: function(component) {    
      	this.clearNotification(component);
         component.set('v.lcHost',  'https://' +  window.location.hostname  + [$A.get("$Label.c.GlAp_BatchProcessImage")]);
    
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
        var error = false;
        var renewalDate = component.get("v.renewalDate");
        var seasonAllocation = component.get("v.seasonAllocation");
        
        if(!renewalDate || renewalDate == '') {
            this.showNotification(component, [$A.get("$Label.c.LoAp_RenewalDateError")],'error'); 
            return false;
        }
        
        if(!seasonAllocation || seasonAllocation <= 0 || seasonAllocation > 100) {
            this.showNotification(component, [$A.get("$Label.c.LoAp_SeasonAllocationError")],'error'); 
            return false;
        }
        
        let params = {"renewalDate" : renewalDate,
                      "seasonAllocation" :  Math.round(seasonAllocation),
                      "batchProcessId" : component.get("v.recordId")
                     };
        
        this.callServer(component, 'c.createDefaultBatchRequest',
                        function(response) {
                            if(response == true) {
                                
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
                                component.set("v.renewalDate",'');
                                component.set("v.seasonAllocation",'');
                            }
                        }, 
                        params);
        
    },
    
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notification').clearNotification();
    },  

})