({
	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {
    	return helper.reInitialise(component);
    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
    	return helper.checksOnEntry(component);
    },

    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
    	return helper.validateOnNext(component);
    },

})