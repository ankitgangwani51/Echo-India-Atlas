({
    DEBUG: 'ChangeBundle: ',
    doInit : function(component, event, helper){
        component.set("v.availableBundleRecord", {"sObjectType" : this.setPrefixedString('AvailableBundle__c')});
        
        let params = {"recId" : component.get("v.recordId")};
        this.callServer(component, 'c.retrieveFieldProps',
                        function(response) {
                           component.set('v.inputFields', response); 
                        },
                        null);
        
        this.callServer(component, 'c.retrieveRecords',
                        function(response) {
                           component.set('v.availableBundleRecord', response); 
                        },
                        params);
        
    },
    
	// navigation with validation/server calls 
    navigateStep: function(component, event) {
        var message = event.getParam('message');
        if (message === 'CANCEL') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            this.doCancel(component);
            
        } else if (message === 'NEXT') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            if (this.validateOnNext(component)) {
                this.callApexSave(component, component.get('v.availableBundleRecord'));
            }
            
        } 
    },
    
    validateOnNext: function(component) {
        var availableBundle = component.get('v.availableBundleRecord');
        if (availableBundle[this.setPrefixedString('LastBundleChangeDate__c')] == null) {
            this.showNotification(component, [$A.get('$Label.c.LoAp_MakeBundleActiveEffectiveDateVal')], 'error');
            return false;
        }
        return true;
    },
    
    // call the server to save the new record and update the records it amends
    callApexSave: function(component, newRecord) {    	
        try {
            // save the record
            var action = component.get("c.saveRecords") ;
            action.setParams({
                'objectName': component.get("v.objectName"),
                'supplyPointId':component.get("v.supplyPointId"),
                'newRecordObject': JSON.stringify(newRecord),
            });
            component.find('spinner').show();
            // calling the server to save the available bundle
            action.setCallback(this, function(response) {
                component.find('spinner').hide();
                this.handleCallbackResponse(component, response) ;
            }) ;
            $A.enqueueAction(action) ;
            
        } catch (error) {
            this.showNotification(error.message);
        }
    },
    
    //handel Call Back Response
    handleCallbackResponse : function(component, response) {
        console.log('response: ' + response) ;
        if(response.getState() === 'SUCCESS') {
            var calculateBillCmp = component.find('calculatePendingBillComponent');
            calculateBillCmp.calculateBills(function(response) {});
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "success",
                "message": $A.get('$Label.c.LoAp_ChangeBundleProcessing')
            });        
            toastEvent.fire();
        }else {
            this.handleError(component, response) ;
        }
    },
    
    handleError : function(component, response) {
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showNotification(component, errorMessage, 'error') ;
    },
    
    doCancel: function(component) {
        component.set('v.isActive', false);
    },
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
        var billCalcMessage = message ;
        if(billCalcMessage == $A.get('$Label.c.BlAp_BillCalcResultNoBillResponse')) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "success",
                "message": $A.get('$Label.c.BlAp_BillCalcResultNoBillResponse')
            });        
            toastEvent.fire();
            var event = component.getEvent("refresh");
            event.setParams({ "refreshFlag": true });
            event.fire();
            component.set('v.isActive',false);
        }
    },
    
    // call the notification component method to clear a notification
    clearNotification: function(component) {
        this.showNotification(component, null);
    },
})