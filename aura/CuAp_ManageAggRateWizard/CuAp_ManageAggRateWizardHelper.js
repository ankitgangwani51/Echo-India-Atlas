({
	DEBUG: 'DeviceExchangeWizard: ',

    // override method for local initialisation
    doLocalInit: function(component, event, helper) {
    	// add the locationId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.recordId = wizObj.recordId;
        component.set('v.wizardprop', wizObj);

        // check initial status and initialise steps
    	this.callApexWizardStatus(component, true);	
    },
            
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        if (component.find('selectContractPage') != undefined) {
            component.find('selectContractPage').reInitialise();
        }
        if (component.find('AgreedRatePage') != undefined) {
            component.find('AgreedRatePage').reInitialise();
        }
    },        
    
	// check the current page on entry
	checksOnEntry: function(component) {
    	switch (component.get('v.stepName')) {
    		case $A.get("$Label.c.CuAp_AgreedRatePathPage1"):
                if (component.find('selectContractPage') != undefined) {
                    component.find('selectContractPage').checksOnEntry();
                }
	        	break;
            case $A.get("$Label.c.CuAp_AgreedRatePathPage2"):
                if (component.find('AgreedRatePage') != undefined) {
                	component.find('AgreedRatePage').checksOnEntry();  
                } 
                break;
             
    	}
	},
    
    // validate the current page on exit to the next page
	// returns true if page validates
    validateOnNext: function(component) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.CuAp_AgreedRatePathPage1"):
        		if (component.find('selectContractPage') == undefined
        				|| component.find('selectContractPage').validateOnNext()) {
                    
                    // update the wizard steps once a device has been selected
        			this.updateWizardSteps(component);
        			return true;
        		}
        		break;
            
            case $A.get("$Label.c.CuAp_AgreedRatePathPage2"):
        		if (component.find('AgreedRatePage') == undefined
        				|| component.find('AgreedRatePage').validateOnNext()) {
                    
                    // Exchange the device
                	this.callApexDeviceExchange(component);
                    return true;
                }
                break;
        	default:
        		return true;
    	}
    },   
    
    // override method for navigation with validation/server calls 
	navigateStep: function(component, event, helper) {
		var message = event.getParam('message');
        if (message === 'CANCEL') {
        	this.reInitialiseAllSteps(component);
            this.doCancel(component, event, helper);

        } else if (message === 'NEXT') {
        	if (this.validateOnNext(component)) {
        		this.doNext(component, event, helper);
        		this.checksOnEntry(component);
        	}

        } else if (message === 'BACK') {
            this.doBack(component, event, helper);
        	this.checksOnEntry(component);
        }
	},
        
    // update the wizard steps following a wizard property change
    updateWizardSteps: function(component) {

    	// update the list of steps
    	this.callApexWizardStatus(component);
    },

    // update the wizard step names based on validation
    setWizardSteps: function(component) {

        const allStepNames = [
					            $A.get("$Label.c.CuAp_AgreedRatePathPage1"),
					            $A.get("$Label.c.CuAp_AgreedRatePathPage2"),
					        ];
            
        // initialise the stepNames
        component.set('v.stepNames', allStepNames);
    },
    
    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {   
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        
        let params = {
            "customerId": component.get("v.wizardprop.recordId"),
        };
        
        
        this.callServer(component,'c.getActiveContracts',
                          function(response){
                                var multiContract = true;
            					var activeContractList = component.get("v.activeContractList");

            					component.set("v.activeContractList", response);
                                if (activeContractList.length == 1) {
                                    component.set("v.wizardprop.contractId", activeContractList[0].uniqueId);
                                    multiContract = false;
            					}
            					component.set("v.isMultiContract", multiContract);
                          },
                          
                          params);
            
        var action = component.get('c.WizardStatus');
    	var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
		        // update the steps
		        this.setWizardSteps(component);

		        if (init) {		// set to the first step
			        var stepNames = component.get('v.stepNames');
			        var multiContract = component.get("v.isMultiContract");
                    // navigate to agreed rate component, if there's 1 active contract
                    if (multiContract) {
                        component.set('v.stepName', stepNames[0]);
                    } else {
                        component.set('v.stepName', stepNames[1]);
                        component.set('v.endStep', true);
                    }
		        	this.checksOnEntry(component);
		        }

		        // set the progress path
		        this.doSetProgressPathDetails(component);    
		        
            } else {
                console.log('Error: ' + response.getError()[0].message);
                this.showNotification( $A.get("$Label.c.GlUt_ServerConnectionError"), 'error'); 
            }
        });
        $A.enqueueAction(action);
    },     
     
	// call the server to complete device exchange        
    callApexDeviceExchange: function(component, event, helper) {
        var action = component.get('c.DeviceExchange');
        console.log('Final Wizardprop Values = '+JSON.stringify(component.get('v.wizardprop')));
    	var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var locationId = this.handleDeviceExchangeResponse(component, response);
            if (locationId) this.goToRecord(locationId);
        });
        $A.enqueueAction(action);
    }, 
        
    // handle the device exchange response
    handleDeviceExchangeResponse: function(component, response) {
        if (response.getState() === 'SUCCESS') {        
        	
            // good exit
        	if (response.getReturnValue() != null) {
        		return response.getReturnValue();

			// null exit
        	} else {
	    		this.handleError(component, response);
		    }

        // error exit
        } else {
	    	this.handleError(component, response);
        }
        return false;        
	},
	
	//handle the call server 
    callServer : function(component,method,callback,params) {
        
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }        
//        action.setStorable();
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {                    
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action); 
    }
})