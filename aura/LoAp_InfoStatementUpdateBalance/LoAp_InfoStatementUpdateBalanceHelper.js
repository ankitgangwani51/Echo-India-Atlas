({
    doUpdateBalance: function(component,event, helper) {
        
        let params = {"infoStmtRecordId" : component.get("v.recordId")}; 
        this.callServer(component,'c.updateLocationBalance', 
                        function(response) {
                            console.log('response= ' + JSON.stringify(response)) ;
                            this.showToast(component, response) ;
                        },
                        params);
    },
    
    //Call the notification component method to show a notification
    showNotification: function(component, message, type) {
 		component.find('notification').showNotification(message, type);
    },
    //Show message returned from the apex controller
    showToast : function(component, result) {
        var message = result ;
        console.log('message1 = ' + message) ;
        switch (result) {
            case 'SUCCESS' :
                message = $A.get('$Label.c.LoAp_InfoStatementUpdateBalanceSucess') ;  // TO DO:: Use Labels
                break ;
        }
        console.log('message2 = ' + message) ;
        var toastMessage = $A.get("e.force:showToast") ;
        if(message.includes('ERROR')) {
            toastMessage.setParams({
                "title" : $A.get("$Label.c.CuAp_LightningStateNotSuccessTitle") ,
                "type" : $A.get("$Label.c.GlAp_NotificationTypeError")
            }) ;
            var errorMessage = [] ;
            errorMessage.push(message) ;
            this.showNotification(component, errorMessage, 'error') ;
        } else {
            toastMessage.setParams({
                "title" : $A.get("$Label.c.GuAp_SuccessTitle") ,
                "type" : $A.get("$Label.c.GlAp_Success")
            }) ;
            this.goToRecord(component.get('v.recordId')) ;
        }
        toastMessage.setParams({
                "mode" : $A.get('$Label.c.GlUt_ToastDismissibleMode') ,
                "message" : message
            }) ;
        toastMessage.fire() ;
    } ,
})