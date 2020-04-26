({
    DEBUG: 'GeneratePDF: ',
    
    initialise: function(component) {
        this.clearNotification(component);
        var actionShow = component.get('c.isShowComponent');
        actionShow.setParams({
            'recordId': component.get('v.recordId')	// Sudhir: AU1 AT-4098: renamed variable
        });
        
        actionShow.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.isShowComponent', response.getReturnValue());
                // make server call to check for pdf attachment
                if(response.getReturnValue()){
                    var action = component.get('c.getAttachmentId');
                    action.setParams({
                        'recordId': component.get('v.recordId')	// Sudhir: AU1 AT-4098: renamed variable
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === 'SUCCESS') {
                            component.set('v.attachmentId', response.getReturnValue());
                        } else {
                            this.handleError(component, response);
                        }
                    });
                    $A.enqueueAction(action);
                }                
            } else {
                this.handleError(component, response);
            }
        });
        $A.enqueueAction(actionShow);
    },
    
    // display the pdf attachment
    view: function(component) {
        if(component.get('v.attachmentId')) {
            //START: Sudhir AT-3889 (Core CC Bugs)
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": component.get('v.attachmentId')
            });
            urlEvent.fire();
            //END: Sudhir AT-3889 (Core CC Bugs)
        }
    },
    
    // generates the pdf by calling a Heroku service via the apex controller
    generatePDF: function(component, helper) {
        this.showNotification(component, $A.get('$Label.c.BlAp_PDFGenerationGeneratingPDFMsg'), 'text');
        component.find('spinner').show();
        
        // make server call to generate bill
        
        var action = component.get('c.getGeneratedPDF');
        action.setParams({
            'recordId': component.get('v.recordId') // Sudhir: AU1 AT-4098: renamed variable
        });
        action.setCallback(this, function(response) {
            if(response) {	// AU1
                var state = response.getState();
                var responseMessage = response.getReturnValue() ;
                if (state === 'SUCCESS' && responseMessage && !responseMessage.includes('error')) {	//Sudhir: check if response is not null
                    component.set('v.attachmentId', responseMessage);
                } else {
                    //this.handleError(component, response);
                    this.showToast(component, responseMessage, helper);
                }
                this.clearNotification(component);
                component.find('spinner').hide();
            } else { // AU1
                this.showToast(component, responseMessage, helper);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    // handles any errors
    handleError: function(component, response) {
        this.showNotification(component, response.getError()[0].message);
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification([message], type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    }, 
    //Show message returned from the apex controller
    showToast : function(component, result, helper) {
        var message = result ;
        switch (result) {
            case 'SUCCESS' :
                message = $A.get('$Label.c.GlUt_PDFGeneratedSuccessfully') ;  // TO DO:: Use Labels
                break ;
        }
        var toastMessage = $A.get("e.force:showToast") ;
        if(message.includes('error')) {
            toastMessage.setParams({
                "mode" : $A.get("$Label.c.GlUt_ToastStickyMode") ,
                "title" : $A.get("$Label.c.CuAp_LightningStateNotSuccessTitle") ,
                "type" : $A.get("$Label.c.GlAp_NotificationTypeError") 
            }) ;
            component.set("v.validationMessage", message) ;
        } else {
            toastMessage.setParams({
                "mode" : $A.get("$Label.c.GlUt_ToastDismissibleMode") ,
                "title" : $A.get("$Label.c.GuAp_SuccessTitle") ,
                "type" : $A.get("$Label.c.GlAp_Success") 
            }) ;
            helper.goToRecord(component.get('v.recordId')) ;
        }
        toastMessage.setParams({
            "message" : message
        }) ;
        toastMessage.fire() ;
    } ,
})