({
    DEBUG: 'WelcomeLetterPage: ',
	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
    	console.log(this.DEBUG + 'reInitialise');
        component.set('v.checkWelcomeLetter', false);    	
    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');    	
    },

    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {    
        var wizObj = component.get('v.wizardprop');
        console.log(this.DEBUG + 'validateOnNext');       
        if(component.get('v.checkWelcomeLetter')){
            wizObj.emailSend = component.get('v.checkWelcomeLetter');
            component.set('v.wizardprop', wizObj);          
        }
        return true;
    },

})