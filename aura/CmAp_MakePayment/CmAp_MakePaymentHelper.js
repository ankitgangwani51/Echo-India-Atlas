({
    //hiding this component and displaying the myPayment component
	myPayments : function(component) {
		component.set("v.showMakePayment",false);
	}, 
    
    //saving the payment when clicked on pay button
    makePayments : function(component) {
        
        var amount = component.get("v.payAmount");
        
        //validate that the payment is greater than zero
        if(amount <= 0){
            this.showNotification(component, [$A.get('$Label.c.CmAp_PymtAmtGrtrThnZero')], 'error'); 
            return;
        }
        let params = {
            "Amount": amount,
        };
        component.find('spinner').show();
       
        var action = component.get("c.createPayment") ;
        action.setParams({
            'Amount' : amount
        }) ;
        component.find('spinner').show();
        // calling the server to save the payment
        action.setCallback(this, function(response) {
            console.log(' setCallback response:: ' + JSON.stringify(response)) ;
            component.find('spinner').hide();
            this.handleCallbackResponse(component, response) ;
        }) ;
        $A.enqueueAction(action) ;
	},
    
    handleCallbackResponse : function(component, response) {
        if(response.getState() === 'SUCCESS') {
            this.myPayments(component);
            var appEvent = component.getEvent("refreshMyPayments");
            appEvent.fire();
        } else {
            this.handleError(component, response) ;
        }
    } ,
    
    handleError : function(component, response) {
        console.log(this.DEBUG + 'Exception caught.');
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showNotification(component, errorMessage, 'error') ;
    } ,
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
})