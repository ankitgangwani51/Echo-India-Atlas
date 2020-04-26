({	
    
    
    //makes a callout from Apex server side to Centrelink 
	doConcessionValidation: function(component,event, helper) {
        this.clearNotification(component) ;	//clear any existing notification
        //validate Concession cnfrmDate first before making callout
        let params = {"concessionId" : component.get("v.recordId")}; 
        
        this.callServer(component,'c.validateConcession', 
                        function(response) {
                            console.log('validateConcession-response= ' + JSON.stringify(response)) ;
                            this.showToast(component, response) ;
                        },
                        params);
    },
    //Call the notification component method to show a notification
    showNotification: function(component, message, type) {
 		component.find('notifier').showNotification(message, type);
    },
    // call the notifier method to clear a message on the notification component on the Goodwill Payment component
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    }, 
    //Show message returned from the apex controller
    showToast : function(component, result) {
        var message = result ;
        var errorMessage = [] ;
        var error = false ;
        var toastMessage = $A.get("e.force:showToast") ;
        for(var i = 0; message, i < message.length; i++) {
        	var eachMessage = message[i].message ; 
            if(eachMessage && !message[i].successFlag) {
                error = true ;
                errorMessage.push(eachMessage) ;
                this.showNotification(component, errorMessage, 'error') ;
            }
        }
        if(!error) {
        	 toastMessage.setParams({
                    "mode" : $A.get('$Label.c.GlUt_ToastDismissibleMode') ,
                    "title" : $A.get("$Label.c.GuAp_SuccessTitle") ,
                    "type" : $A.get("$Label.c.GlAp_Success") ,
                    "message" : $A.get('$Label.c.CuAp_CentrelinkConcessionValidationSuccessMessage')
                }) ;
            toastMessage.fire() ;
            this.goToRecord(component.get("v.recordId")) ;
            /*	
            var navigateEvt = $A.get("e.force:navigateToSObject") ;
            navigateEvt.setParams({
                "recordId" : component.get("v.recordId"),
            }) ;
            navigateEvt.fire() ;
            setTimeout(function() {
                var navigateEvt = $A.get("e.force:navigateToSObject") ;
                navigateEvt.setParams({
                    "recordId" : component.get("v.recordId"),
                }) ;
                navigateEvt.fire() ;
            }, 5000) ;
            */
        }
    } ,
})