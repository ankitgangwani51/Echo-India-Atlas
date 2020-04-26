({
    DEBUG : 'CmAp_SubmitMyReading: ' ,
    
    doInit : function(component, event, helper) {
        component.set('v.newReading', {'sobjectType':this.setPrefixedString('Reading__c')});
        this.retrieveNewReadingFields(component, event, helper) ;        
    } ,
    
    retrieveNewReadingFields : function(component, event, helper) {
        helper.callServer(component, 'c.retrieveNewReadingPropDetails', function(response){
            if(response) {
                component.set("v.newReadingFieldList", response) ;
            }
        } ,
                          null) ;
    } ,
    
    submitReading : function(component) {
        component.set("v.showSubmitReading", false) ;
    } ,
    
    saveMyReading : function(component) { 
        var deviceId = component.get("v.deviceRef") ;
        var newReading = component.get("v.newReading") ;
        var readingDate = newReading[this.setPrefixedString('ReadingDate__c')] ;
        var actualDeviceReading = newReading[this.setPrefixedString('ActualDeviceReading__c')] ;
        var deviceDigit = component.get("v.deviceDigit") ;
        var lastActualReading = component.get("v.lastActualReading") ;
        if(readingDate == null) {	// Reading Date is required
            this.showNotification(component, [$A.get('$Label.c.CmAp_MyReadingDateRequired')] , 'error') ;
            return ;
        }
        if(actualDeviceReading == null) {	// Actual Device reading is required
            this.showNotification(component, [$A.get('$Label.c.CmAp_ActualDeviceReadingRequired')], 'error') ;
            return ;
        }
        if(lastActualReading.replace(/^0+/, '') >= actualDeviceReading) {	// replace removes leading zeros
            this.showNotification(component, [$A.get('$Label.c.CmAp_MyNewReadingValidation') +  ' ' + lastActualReading.replace(/^0+/, '') + '.'], 'error') ;
            return ;
        }
        //Enter the number of digits for Actual Device Reading as per the related device digits.
        if(actualDeviceReading != 'undefined' && parseInt(deviceDigit) < actualDeviceReading.toString().length) {
            this.showNotification(component, [$A.get('$Label.c.CmAp_MyReadingDeviceDigitValidation') + ' Device digit is ' + deviceDigit + '.'], 'error') ;
            return ;
        }

        component.find('spinner').show();
        var action = component.get("c.submitMyReading") ;
        action.setParams({
            "deviceId" : deviceId, 
            "actualDeviceReading" : actualDeviceReading,
            "readingDate" : readingDate
        }) ;
        action.setCallback(this, function(response) {
            console.log(this.DEBUG + ' setCallback response:: ' + JSON.stringify(response)) ;
            this.handleCallbackResponse(component, response) ;
        }) ;
        $A.enqueueAction(action) ;
    } ,
    
    handleCallbackResponse : function(component, response) {
        component.find('spinner').hide();
        if(response.getState() === 'SUCCESS') {
                this.submitReading(component);
                var refreshEvent = component.getEvent("refreshMyPayments");
                refreshEvent.fire();
        } else {
            this.handleError(component, response) ;
        }
    } ,
    
    handleError : function(component, response) {	
        console.log(this.DEBUG + 'Exception caught.');
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showError(component, errorMessage) ;
    } ,
    
    showError : function(component, errorMessage) {
        this.showNotification(component, errorMessage, 'error') ;
    } ,
    
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    clearNotification: function(component) {
        this.showNotification(component, null);
    },
    
})