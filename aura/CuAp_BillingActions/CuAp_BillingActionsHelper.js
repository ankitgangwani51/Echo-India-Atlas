({
	DEBUG: 'BillingActions: ',

    // initialisation
    doInit: function(component) {
        
        if (component.get('v.sObjectName') == 'Account') {
	        var action = component.get('c.isNHHAccount');
	        action.setParams({
	            'accountId': component.get('v.recordId')
	        });
	        action.setCallback(this, function(response) {
	            var state = response.getState();
                console.log('state---'+ state)
                
	            if (state === 'SUCCESS') {
	                component.set('v.isNHHAccount', response.getReturnValue());
	            }
	        });
	        $A.enqueueAction(action);
        }
        
        
        if (component.get('v.sObjectName') == this.setPrefixedString('RuralLicense__c')) {
	        var action = component.get('c.statusOfRuralLicense');
	        action.setParams({
	            'ruralLicenseId': component.get('v.recordId')
	        });
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === 'SUCCESS') {
	                component.set('v.isActiveRuralLicense', response.getReturnValue());
	            }
	        });
	        $A.enqueueAction(action);
        }
        
        //AT-5413, Ankit, 11/03/2019 - Manage Site Supply wizard will only display when supply point device is active
        if (component.get('v.sObjectName') == this.setPrefixedString('SupplyPoint__c')) {
	        var action = component.get('c.isActiveSPD');
	        action.setParams({
	            'supplyPointId': component.get('v.recordId')
	        });
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === 'SUCCESS') {
	                component.set('v.isActiveSPD', response.getReturnValue());
	            }
	        });
	        $A.enqueueAction(action);
        }
        //UL-530 Starts Here
        if (component.get('v.sObjectName') == this.setPrefixedString('BillingContract__c')) {
	        var action = component.get('c.isVoidContract');
	        action.setParams({
	            'contractId': component.get('v.recordId')
	        });
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === 'SUCCESS') {
	                component.set('v.isNonVoidContract', response.getReturnValue());
	            }
	        });
	        $A.enqueueAction(action);
        }
        //UL-530 Ends Here
        
    },

    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
})