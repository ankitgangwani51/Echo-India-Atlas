({
    //Initialization/Constructor method for current component.
    doInit: function(component, event, helper) {
        try{
            component.find('spinner').show();
            let params = {"contractId": component.get('v.recordId')};  
            this.callServer(component,'c.getInfoToDisplay', 
                            function(response) {
                                component.find('spinner').hide();
                                component.set("v.resultContainer", response);
                                if(component.get("v.resultContainer").errorText){
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error!",
                                        "type":"Error",
                                        "message": component.get("v.resultContainer").errorText
                                    });
                                    toastEvent.fire();
                                }else if(component.get("v.resultContainer").authKey){
                                    component.set('v.authKey',component.get("v.resultContainer").authKey);
                                    component.set('v.iframeSrcUrl',component.get("v.resultContainer").bPointDetails[this.setPrefixedString('IframeURL__c')]+component.get("v.resultContainer").authKey);
                                }
                                component.set('v.paymentFields',component.get("v.resultContainer").fieldPropList);
                                component.set('v.TransformPaymentObject',component.get("v.resultContainer").billingContract);
                                component.set('v.TransformPaymentObject',{'sobjectType': this.setPrefixedString('BillingContract__c'),
                                                                          ['PaymentDate']: component.get("v.resultContainer").todaysDate,
                                                                          [this.setPrefixedString('AccountName__c')]: component.get('v.TransformPaymentObject')[this.setPrefixedString('AccountName__c')],
                                                                          ['Name']: component.get('v.TransformPaymentObject')['Name'],
                                                                          ['Id']: component.get('v.recordId')});
                                
                                
                            },
                            params);
        }
        catch (error) {
            this.showNotification(component,error.message,'Error');
            console.log(this.DEBUG + 'error when activate component: ' + error.message);
        }
    },
    //Activate the LC
    doActive: function(component,event, helper) {
        component.set('v.isActive', true); 
        helper.doInit(component, event, helper);
    },
    //Close the LC
    doCancel:function(component,event, helper) {
        component.set('v.isActive', false);
        helper.doReset(component,event, helper);
    },
    //Reset the values of LC
    doReset:function(component,event, helper){
       component.set('v.authKey', '');
       this.clearNotification(component);
    },
    //Clear the error Notification of LC
     clearNotification: function(component) {
        component.find('notification').clearNotification();
    },
    //Process Payment using Bpoint.
    doSave: function(component,event, helper) {
        try{
            if(component.get('v.TransformPaymentObject')){
                if(!component.get('v.TransformPaymentObject')['CardHolderName']){
                    this.showNotification(component,[$A.get("$Label.c.PyAp_CardHolderName")],'Error');
                }else if(!component.get('v.TransformPaymentObject')['Amount']){
                    this.showNotification(component,[$A.get("$Label.c.PyAp_Amount")],'Error');
                }else if(!component.get('v.TransformPaymentObject')['PaymentMethod']){
                    this.showNotification(component,[$A.get("$Label.c.PyAp_PaymentMethod")],'Error');
                }else{
                    var amount = component.get('v.TransformPaymentObject')['Amount'];
                    var cardHolderName = component.get('v.TransformPaymentObject')['CardHolderName'];
                    var contractNo =   component.get('v.TransformPaymentObject')['Name'];
                    var contractId = component.get('v.TransformPaymentObject')['Id'];
                    var accountId = component.get('v.TransformPaymentObject')[this.setPrefixedString('AccountName__c')];
                    var paymentMethod = component.get('v.TransformPaymentObject')['PaymentMethod'];
                    let params = {"contractNo": contractNo,
                                  "cardHolderName": cardHolderName,
                                  "amount": amount,
                                  "authKey" : component.get('v.authKey'),
                                  "contractId":  contractId,
                                  "accountId": accountId,
                                  "paymentMethod": paymentMethod
                                 };       
                    component.find('spinner').show();
                    //To get contract details from server
                    this.callServer(component,'c.processPayment',
                                    function(response){ 
                                        component.find('spinner').hide();
                                        if(response.errorText){
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                "title": "Error!",
                                                "type":"Error",
                                                "message": response.errorText
                                            });
                                            toastEvent.fire();
                                        }else if(response.successText){
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                "title": "Success!",
                                                "type":"Success",
                                                "message": $A.get("$Label.c.PyAp_PaymentSuccessful")
                                            });
                                            toastEvent.fire();
                                            var urlEvent = $A.get("e.force:navigateToURL");
                                            urlEvent.setParams({
                                                "url": response.redirectionUrl
                                            });
                                            urlEvent.fire();
                                        }
                                        this.clearNotification(component);
                                    },                         
                                    params);
                }
            }
        }catch (error) {
                this.showNotification(component,error.message,'Error');
                console.log(this.DEBUG + 'error when saving: ' + error.message);
            }
    },
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    //Had to add the call server here as there was an issue when resolving the
    //component when going to the base class
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                      this.showNotification(component,[errors[0].message],'Error');
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });       
        $A.enqueueAction(action);
    },
})