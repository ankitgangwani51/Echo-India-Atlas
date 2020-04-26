({
    // initialise component
    doInit: function(component) {
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
        let params = {'batchProcessId': component.get('v.recordId')};
        this.callServer(component, 'c.createDefaultBatchRequest',
                        function(response) {
                            
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
                        }, 
                        params);
        
    },
})