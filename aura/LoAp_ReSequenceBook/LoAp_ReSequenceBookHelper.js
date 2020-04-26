({
	doReSequencing : function(component) {
        component.set('v.isActive', true);
	},
    
    doCancel : function(component) {  
        component.set('v.reSequenceGap','');
        component.set('v.isActive', false);        
    },
    
    doSave : function(component) {      
        var reSequenceGap = component.get('v.reSequenceGap');        
        if(reSequenceGap > 0){            
            var action = component.get('c.reSequenceWalkOrder');             
            action.setParams({
                'bookRecordId': component.get('v.recordId'),
                'sequenceSpacing': component.get('v.reSequenceGap')
            });
            component.find('spinner').show();
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.find('spinner').hide();
                    this.doCancel(component);
                    this.showToast(response.getReturnValue());                   
                }
            });
            $A.enqueueAction(action); 
            
        }
        else{
            // Sequence Spacing should be greater than or equal to 1
            this.showNotification(component, [$A.get("$Label.c.LoAp_ValidateReSequenceValue")],$A.get("$Label.c.GlAp_NotificationTypeError") );//AT-3687
            return false;  
        }
    },
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    }, 
    
    // show toast message and return
    showToast: function(result) {    	 	
        var message;
    	switch (result) {
            case 0:
            	message = $A.get("$Label.c.LoAp_ReSequenceNoRecordUpdated");
            	break;
            default:
            	message = $A.get("$Label.c.LoAp_ReSequenceRecordUpdated");
            	break;            
        }
        
        if (message) {
        	var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
        					"title": $A.get("$Label.c.GuAp_SuccessTitle"),//AT-3687
        					"type": $A.get("$Label.c.GlAp_Success"),
        					"message": message 
        				});
        	toastEvent.fire();
        }
       // this.doCancel();
    },
})