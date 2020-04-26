({
    DEBUG: 'LoAp_InfoStatementCalculateCharges: ',
    
    fetchRecord : function(component, event, helper) {
        let params = {"recordId" : component.get('v.recordId')} ;
        this.callServer(component, 'c.getInformationStatement', 
                          function(response){
                          	component.set('v.infoStatementObj', response) ;
                         }, 
                      params) ;              
    },
    
    //validate the Info Statement data
    validate : function(component, helper, infoStatementObj) {
        var isValid = true ;
        if(infoStatementObj) {
            var errorMessage = '' ;
            if(!infoStatementObj[this.setPrefixedString('Location__c')]) {
                errorMessage = $A.get('$Label.c.LoAp_InfoStatementLocationError') ;
                isValid = false ;
            } else if(!infoStatementObj[this.setPrefixedString('SettlementDate__c')]) {
                errorMessage = $A.get('$Label.c.LoAp_InfoStatementSettlementDateError') ;
                isValid = false ;
            } else if(!infoStatementObj[this.setPrefixedString('TemplateMapping__c')]) {
                errorMessage = $A.get('$Label.c.LoAp_InfoStatementTemplateError') ;
                isValid = false ;
            }
            if(!isValid){
                this.showToast(component, helper, errorMessage) ;
            }
        }
        return isValid ;
    }, 
    
    //call server to get calculated charges from heroku
    doCalculateCharges: function(component,event, helper) {
        this.fetchRecord(component,event, helper) ;
        var infoStmtRecord = component.get('v.infoStatementObj') ;
		var isValid = this.validate(component, infoStmtRecord) ;  
        if(isValid) {
			let params = {"infoStmtRecordId" : component.get("v.recordId")}; 
            this.callServer(component,'c.calculateCharges', 
                            function(response) {
                                if(response) {
                                    this.showToast(component, helper, response) ;  
                                }
                            },
                            params);            
        }
    },
    
    //Show message returned from the apex controller
    showToast : function(component, helper, result) {
        var message = result ;
        switch (result) {
            case 'SUCCESS' :
                message = $A.get('$Label.c.LoAp_InfoStatementCalculateChargesSuccessMessage') ;
                break ;
        }
        var toastMessage = $A.get("e.force:showToast") ;
        if(message.includes('ERROR')) {
            toastMessage.setParams({
                "mode" : $A.get('$Label.c.GlUt_ToastStickyMode') ,
                "title" : $A.get("$Label.c.CuAp_LightningStateNotSuccessTitle") ,
                "type" : $A.get("$Label.c.GlAp_NotificationTypeError") ,
                "message" : message
            }) ;
        } else {
            toastMessage.setParams({
                "mode" : $A.get('$Label.c.GlUt_ToastDismissibleMode') ,
                "title" : $A.get("$Label.c.GuAp_SuccessTitle") ,
                "type" : $A.get("$Label.c.GlAp_Success") ,
                "message" : $A.get('$Label.c.LoAp_InfoStatementCalculateChargesSuccessMessage')
            }) ;
            helper.goToRecord(message) ;
        }
        toastMessage.fire() ;
    } ,
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
 		component.find('notification').showNotification(message, type);
    },
    
})