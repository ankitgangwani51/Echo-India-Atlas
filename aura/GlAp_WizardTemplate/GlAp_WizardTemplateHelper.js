({
	DEBUG: 'WizardTemplate: ',

	// screen initialisation
    doInit: function(component) {
        
        component.set('v.startStep', true);
        component.set('v.endStep', false);
        component.set('v.wizardprop', new Object());
        var wizObj = component.get('v.wizardprop');
        wizObj.recordId = component.get('v.recordId');
        component.set('v.wizardprop', wizObj);
        this.doLocalInit(component);
    },
    
    // local initialisation - must be overridden in child helper
    // local initialisation must set progress path
    doLocalInit: function(component) {
    },

	// switch to another record page
    goToRecord: function(recordId) {
        console.log(this.DEBUG + 'redirecting ...');
        var evt = $A.get('e.force:navigateToURL');
        console.log(this.DEBUG + 'record Id: ' + recordId);
        evt.setParams({
            url: '/one/one.app#/sObject/' + recordId
        });
        evt.fire();
    },

    // navigation and validation - can be overridden in child helper to add any validation/server calls
	navigateStep: function(component, event) {
	
		var message = event.getParam('message');
        if (message === 'CANCEL') {
            this.doCancel(component);
        }
        else if (message === 'NEXT') {
            this.doNext(component);
        }
        else if (message === 'BACK') {
            this.doBack(component);
        }
	},

    // build the stagelist for the Wizard progress path component
    doSetProgressPathDetails: function(component) {
        var stepNames = component.get('v.stepNames');
        var stepName = component.get('v.stepName');
        var step = stepNames.indexOf(stepName);
        
        var stageList = [];
        for (var i = 0; i < stepNames.length; i++) {
            if (i < step) {
                stageList.push({
                    Name: stepNames[i],
                    Status: 'PastComplete'
                });
            } else if (i == step) {
            	stageList.push({
            		Name: stepNames[i],
            		Status: 'Current'
                });
            } else {
            	stageList.push({
            	   Name: stepNames[i],
            	   Status: 'Future'
               }); 
            }
        } 
        component.set('v.stageList', stageList);
    },
    
    // activate the Wizard
    doStartWizard: function(component) {
        debugger;
        var stepNames = component.get('v.stepNames');
        var stepName = component.get('v.stepName');
        var step = stepNames.indexOf(stepName);
        
        if (step == 0) {
            component.set('v.startStep', true);
        }
        if (step == stepNames.length-1) {
            component.set('v.endStep', true);
        }
        console.log(this.DEBUG + 'wizard active ...');
        component.set('v.isWizardActive', true);
    },
    
    // cancel the Wizard
    doCancel: function(component) {
        this.doInit(component);
        component.set('v.isWizardActive', false);
    },
    
    // move to the next Wizard step
    doNext: function(component) {
        debugger;
        var stepNames = component.get('v.stepNames');
        var stepName = component.get('v.stepName');
        var step = stepNames.indexOf(stepName);
        console.log(this.DEBUG + 'step: ' + step);
        this.resetSteps(component);
        
        if (step < stepNames.length-1) {
            step++;
        }
        if (step == stepNames.length-1) {
            component.set('v.endStep', true);
        }
        console.log(this.DEBUG + 'stepName: ' + stepNames[step]);
        component.set('v.stepName', stepNames[step]);
        this.doSetProgressPathDetails(component);
    },
    
    // go back to the previous Wizard step
    doBack: function(component) {	
        var stepNames = component.get('v.stepNames');
        var stepName = component.get('v.stepName');
        var step = stepNames.indexOf(stepName);
        console.log(this.DEBUG + 'step: ' + step);
        this.resetSteps(component);
        
        if (step > 0) {
            step--;
        }
        if (step == 0) {
            component.set('v.startStep', true);
        }
        console.log(this.DEBUG + 'stepName: ' + stepNames[step]);
        component.set('v.stepName', stepNames[step]);
        this.doSetProgressPathDetails(component);
    },
    
    // reset the Wizard start/end step status
    resetSteps: function(component) {
        component.set('v.startStep', false);
        component.set('v.endStep', false);
    },
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	var notificationCmp = component.find('notification');

    	if (notificationCmp != undefined) {
    		notificationCmp.showNotification(message, type);

    	} else {
    	
    		// fire an event if the helper method was called from an extended component
	    	var errorEvent = component.getEvent('notificationEvent');
	        errorEvent.setParams({
	            'message': message,
	            'type': type 
	        });

	        // fire the event
	        errorEvent.fire();
    	}
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
    
    // handles any errors
    handleError: function(component, response) {
    	console.log(this.DEBUG + 'Exception caught successfully');
    	var errorMessages = [];
    	errorMessages.push(response.getError()[0].message);
        this.showError(component, errorMessages);
    },
    
    // shows the error message
    showError: function(component, errorMessages) {
        console.log(this.DEBUG + 'Displaying error: ', errorMessages);
        this.showNotification(component, errorMessages);
    }
})