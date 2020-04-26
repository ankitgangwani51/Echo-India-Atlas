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
        var exportInstalmentUpto = component.get("v.exportInstalmentUpto");
        
        if(!exportInstalmentUpto || exportInstalmentUpto == '') {
            this.showNotification(component, [$A.get("$Label.c.PyAp_ExportInstalmentDate")],'error'); 
            return false;
        }
        
        let params = {"exportInstalmentUpto" : exportInstalmentUpto,
                      "batchProcessId" : component.get("v.recordId")
                     };
        
        this.callServer(component, 'c.createDefaultBatchRequest',function(response) {
            if(response == true) {
                var appEvent = $A.get("e.c:GlAp_AppRefreshEvent");
                appEvent.setParams({
                    "refreshFlag" : true });
                //Fired Application Event to refresh CuAp_BatchRequestHistory Component
                appEvent.fire();      
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": $A.get("$Label.c.GlAp_NewBatchRequestCreated") 
                });        
                toastEvent.fire();
                component.set("v.exportInstalmentUpto",'');
            }
        },params);
    } 
})