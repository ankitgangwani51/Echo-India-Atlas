({
    // called on component load
	initialise: function(component, event, helper) {
    },

    // called on calculate bill button press or calculate bill method
	calculateBills: function(component, event, helper) {
		helper.requestInitiated(component);

    	// initiate a bill request 
     	helper.callApexInitiateBillsRequest(component, component.get('v.calculationType'));
    },
})