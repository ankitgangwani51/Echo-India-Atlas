({
	DEBUG: 'DeviceExchangeWizard: ',

    // override method for local initialisation
    doLocalInit: function(component, event, helper) {

    	// add the locationId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.locationId = wizObj.recordId;
        component.set('v.wizardprop', wizObj);
        // check initial status and initialise steps
    	this.callApexWizardStatus(component, true);	
    },
            
    // update the bill Id from the event
    handleBillCalculationComplete: function(component, event, helper) {

    	// add the billId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.billId = event.getParam('billId');
        component.set('v.wizardprop', wizObj);
        this.showToast(wizObj);
	},
	
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component) {
        if (component.find('selectActionPage') != undefined) component.find('selectActionPage').reInitialise();
        if (component.find('selectDevicePage') != undefined) component.find('selectDevicePage').reInitialise();
        if (component.find('finalReadingPage') != undefined) component.find('finalReadingPage').reInitialise();
        if (component.find('searchDevicePage') != undefined) component.find('searchDevicePage').reInitialise();
        if (component.find('initialReadingPage') != undefined) component.find('initialReadingPage').reInitialise();
        if (component.find('selectSupplyPointPage') != undefined) component.find('selectSupplyPointPage').reInitialise();
        if (component.find('selectBundlePage') != undefined) component.find('selectBundlePage').reInitialise();
    },        
    
	// check the current page on entry
	checksOnEntry: function(component) {
    	switch (component.get('v.stepName')) {
            case $A.get("$Label.c.LoAp_DeviceManagementPath0"):
                if (component.find('selectActionPage') != undefined) component.find('selectActionPage').checksOnEntry()
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath1"):
                if (component.find('selectDevicePage') != undefined) component.find('selectDevicePage').checksOnEntry()
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath2"):
                if (component.find('finalReadingPage') != undefined) component.find('finalReadingPage').checksOnEntry()
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath3"):
                if (component.find('searchDevicePage') != undefined) component.find('searchDevicePage').checksOnEntry()
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath4"):
                if (component.find('initialReadingPage') != undefined) component.find('initialReadingPage').checksOnEntry()
                break;    
            case $A.get("$Label.c.LoAp_DeviceManagementPath6"):
                if (component.find('selectSupplyPointPage') != undefined) component.find('selectSupplyPointPage').checksOnEntry()
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath7"):
                if (component.find('selectBundlePage') != undefined) component.find('selectBundlePage').checksOnEntry()
                break;    
    	}
	},
    
    // validate the current page on exit to the next page
	// returns true if page validates
    validateOnNext: function(component) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.LoAp_DeviceManagementPath0"):
                if (component.find('selectActionPage') == undefined
                    || component.find('selectActionPage').validateOnNext()) {
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath1"):
                if (component.find('selectDevicePage') == undefined
                    || component.find('selectDevicePage').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath2"):
                if (component.find('finalReadingPage') == undefined
                    || component.find('finalReadingPage').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath3"):
                if (component.find('searchDevicePage') == undefined
                    || component.find('searchDevicePage').validateOnNext()) {
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath4"):
                if (component.find('initialReadingPage') == undefined
                    || component.find('initialReadingPage').validateOnNext()) {
                    var wizObj = component.get('v.wizardprop');
                    if(wizObj.wizardType == $A.get("$Label.c.LoAp_ExchangeDevice")){
                        this.callApexManageDevice(component);
                    }
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath6"):
                if (component.find('selectSupplyPointPage') == undefined
                    || component.find('selectSupplyPointPage').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_DeviceManagementPath7"):
                if (component.find('selectBundlePage') == undefined
                    || component.find('selectBundlePage').validateOnNext()) {
                    var wizObj = component.get('v.wizardprop');
                    if(wizObj.wizardType != $A.get("$Label.c.LoAp_ExchangeDevice")){
                       this.callApexManageDevice(component);
                    }
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
        
    // initialise the wizard steps
    initialiseWizardSteps: function(component) {

    	// update the list of steps
    	this.callApexWizardStatus(component, true);
    },
        
    // update the wizard steps following a wizard property change
    updateWizardSteps: function(component) {

    	// update the list of steps
    	this.callApexWizardStatus(component);
    },

    // update the wizard step names based on validation
    setWizardSteps: function(component) {
        function remove(array, element) {
            const index = array.indexOf(element);
            if (index !== -1) {
                array.splice(index, 1);
            }
        }
        var status = component.get('v.wizardprop');
        const allStepNames = [
            $A.get("$Label.c.LoAp_DeviceManagementPath0"),
        ];
        
        var stepNames = allStepNames;
        if (status.wizardType === $A.get("$Label.c.LoAp_NewDevice") || !status.wizardType) {
            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath3"));
            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath6"));
            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath4"));
            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath7"));
            if (status.numberOfSupplyPointPerLocation && status.numberOfSupplyPointPerLocation <= 1) {
            	remove(stepNames, $A.get('$Label.c.LoAp_DeviceManagementPath6'));   
            }

        } else if (status.wizardType === $A.get("$Label.c.LoAp_RemoveDevice")) {
            if (status.noOfActiveDevicesPerLocation == 1) {
            	stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath2"));
            }
            if (status.noOfActiveDevicesPerLocation > 1) {
	            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath1"));
	            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath2"));
            }
            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath7"));

        } else if (status.wizardType === $A.get("$Label.c.LoAp_ExchangeDevice")) {
            if (status.noOfActiveDevicesPerLocation == 1) {
            	stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath2"));
            }
            if (status.noOfActiveDevicesPerLocation > 1) {
	            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath1"));
	            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath2"));
            }
            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath3"));
            stepNames.push($A.get("$Label.c.LoAp_DeviceManagementPath4"));  
        }
        component.set('v.stepNames', stepNames);
    },
    
    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {   
        this.setWizardSteps(component);		// ??
        var action = component.get('c.WizardStatus');
    	var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizardprop
        });
        component.find('spinner').show();
        action.setCallback(this, function(response) {
            component.find('spinner').hide();
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                // update the steps
                //this.setWizardSteps(component);
                
                if (init) {		// set to the first step
                    var stepNames = component.get('v.stepNames');
                    component.set('v.stepName', stepNames[0]);
                    this.checksOnEntry(component);
                }
                
                // set the progress path
                this.doSetProgressPathDetails(component);    
                
            } else {
                this.showNotification($A.get("$Label.c.CuAp_WizardCompletionError"));		
            }
        });
        $A.enqueueAction(action);
    },     
     
	// call the server to complete manage device        
    callApexManageDevice: function(component, event, helper) {

        var action = component.get('c.ManageDevice');
    	var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
        	'wizardprop': wizardprop
        });
        component.find('spinner').show();
        action.setCallback(this, function(response) {
            component.find('spinner').hide();
            this.handleManageDeviceResponse(component, response);
        });
        $A.enqueueAction(action);
    }, 
        
    // handle the manage device response
    handleManageDeviceResponse: function(component, response) {

        // good exit
        if (response.getState() === 'SUCCESS') {        
            var wizObj = component.get('v.wizardprop');
            var finalReadingId = response.getReturnValue();
            component.set('v.finalReadingId', finalReadingId);

            // if there are amendments
	        if (wizObj.amendReadings.length > 0) {

		        // calculate the pending bills
            	var calculateBillCmp = component.find('calculatePendingBillComponent');
                    calculateBillCmp.calculateBills(function(response) {
                    });

            } else {
	        	this.showToast(wizObj);
	        }

        // error exit
        } else {
	    	this.handleError(component, response);
        }
	},

    // show toast message and return
    showToast: function(wizObj) {
    	var message;
    	switch (wizObj.wizardType) {
            case $A.get("$Label.c.LoAp_NewDevice"):
            	message = $A.get("$Label.c.LoAp_AddDeviceSuccessMessage");
            	break;
            case $A.get("$Label.c.LoAp_RemoveDevice"):
            	message = $A.get("$Label.c.LoAp_RemoveDeviceSuccessMessage");
            	break;
            case $A.get("$Label.c.LoAp_ExchangeDevice"):
            	message = $A.get("$Label.c.LoAp_ExchangeDeviceSuccessMessage");
            	break;
        }
        
        if (message) {
        	var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
        					"title": $A.get("$Label.c.GuAp_SuccessTitle"),		
        					"type": "Success",
        					"message": message
        				});
        	toastEvent.fire();
        }
        this.goToRecord(wizObj.locationId);
    },
})