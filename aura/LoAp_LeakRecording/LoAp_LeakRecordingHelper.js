({ 
    doInit: function(component, event, helper) {
         let params = { 
			'recordId': component.get("v.recordId")
		};        
        helper.callServer(component, 'c.getReadingStatus',
                          function(response) {
                              component.set('v.isVisible',JSON.stringify(response));
                          },
                          params);
    },
    doSave : function(component, event, helper) {  	
        
        var effDeviceReading = component.get("v.EffDeviceReading");        
		if (effDeviceReading == '' || effDeviceReading == 0 || effDeviceReading == undefined || isNaN(effDeviceReading)){
            // EffDeviceReading can't be blank
			this.showNotification(component, [$A.get("$Label.c.LoAp_EffDeviceReadingError")],'error');			
            return false;
		}
		let params = { 
			'recordId': component.get("v.recordId"),
			'sObjectName': component.get("v.sObjectName"),
			'effDeviceReading': effDeviceReading
		};        
        helper.callServer(component, 'c.updateLeakReading',
                          function(response) {
                              if(response.finalReadingId){
                                  component.set('v.finalReadingId',response.finalReadingId);
                                  // calculate the pending bills
                                  var calculateBillCmp = component.find('calculatePendingBillComponent');
                                  calculateBillCmp.calculateBills(function(response) {
                                  });
                              }else{
                                  this.showToast(response.message);
                                  $A.get('e.force:refreshView').fire();
                              }
                          },
                          params); 
    },
       
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    }, 
	
	// show toast message and return
    showToast: function(result) {    	 	
        var message = result;
        if (message) {
            var toastEvent = $A.get("e.force:showToast");
            if (message ==  $A.get("$Label.c.GuAp_RecordSuccessfullyUpdatedMsg") || message ==  $A.get("$Label.c.ReadingAmendmentSuccess")){	// AT-3415
                toastEvent.setParams({
                    "title": $A.get("$Label.c.GuAp_SuccessTitle"),		
                    "type": $A.get("$Label.c.GlAp_Success"),
                    "message": message
                });
            }else{  // AT-3415 core 8b 
                toastEvent.setParams({
                    "title": $A.get("$Label.c.GlAp_NotificationTypeError"),		
                    "type": $A.get("$Label.c.GlAp_NotificationTypeError"),
                    "message": message
                });
            }
            toastEvent.fire();
        }      
    },  
    handleBillCalculationComplete: function(component, event, helper) {
        this.showToast($A.get("$Label.c.ReadingAmendmentSuccess"));
        $A.get('e.force:refreshView').fire();
        component.set('v.isVisible',false);
    }
})