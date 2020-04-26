({
    DEBUG: 'SiteSupplyWizard: ',
    
    // Execute from GlAp_WizardTemplate to initialise the wizard
	doLocalInit: function(component, event, helper) {
        
        // add the contractId to the wizard properties
        var wizObj = component.get('v.wizardprop');
        wizObj.supplyPointId = wizObj.recordId;
        wizObj.wizardType = $A.get("$Label.c.LoAp_isAmend");
        component.set('v.wizardprop', wizObj);
        
        // check initial status and initialise steps
        this.callApexWizardStatus(component, true);	
    },
    
    // reInitialise all pages on Wizard exit/close
    reInitialiseAllSteps: function(component, event, helper) {
        if (component.find('siteSupplyOperation') != undefined) component.find('siteSupplyOperation').reInitialise();
        if (component.find('selectSiteSupply') != undefined) component.find('selectSiteSupply').reInitialise();
        if (component.find('manageSiteSupply') != undefined) component.find('manageSiteSupply').reInitialise();        
    },
    
    // check the current page on entry
    checksOnEntry: function(component, event, helper) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.LoAp_SiteSupplyPage1"):
                if (component.find('siteSupplyOperation') != undefined) component.find('siteSupplyOperation').checksOnEntry()
                break;
            case $A.get("$Label.c.LoAp_SiteSupplyPage2"):
                if (component.find('selectSiteSupply') != undefined) component.find('selectSiteSupply').checksOnEntry()
                break;
            case $A.get("$Label.c.LoAp_SiteSupplyPage3"):
                if (component.find('manageSiteSupply') != undefined) component.find('manageSiteSupply').checksOnEntry()
                break;  
            case $A.get('$Label.c.LoAp_SiteSupplyWizardDisplayBill'):
                if (!component.get('v.isCommitted')) {
                    this.callApexProcessSiteSupply(component, event, helper);
                }
                // remove the 'back' and 'cancel' (TO-DO) buttons
                component.set('v.startStep', false);
                if (component.find('displayBillPage') != undefined) component.find('displayBillPage').checksOnEntry()
                break;
        }
    },
    
    // override method for navigation with validation/server calls 
    navigateStep: function(component, event, helper) {
        var message = event.getParam('message');
        if (message === 'CANCEL') {
            this.doCancel(component, event, helper);
            this.reInitialiseAllSteps(component);            
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
    
    // validate the current page on exit to the next page
    // returns true if page validates
    validateOnNext: function(component, event, helper) {
        switch (component.get('v.stepName')) {
            case $A.get("$Label.c.LoAp_SiteSupplyPage1"):
                if (component.find('siteSupplyOperation') == undefined
                    || component.find('siteSupplyOperation').validateOnNext()) {
                    this.updateWizardSteps(component);
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_SiteSupplyPage2"):
                if (component.find('selectSiteSupply') == undefined
                    || component.find('selectSiteSupply').validateOnNext()) {
                    return true;
                }
                break;
            case $A.get("$Label.c.LoAp_SiteSupplyPage3"):
                if (component.find('manageSiteSupply') == undefined
                    || component.find('manageSiteSupply').validateOnNext()) {
                    //this.callApexProcessSiteSupply(component, event, helper);
                    return true;
                }
                break;     
            case $A.get('$Label.c.LoAp_SiteSupplyWizardDisplayBill'):
                if (component.find('displayBillPage') == undefined
                    || component.find('displayBillPage').validateOnNext()) {
                    
                    // finish
                    var wizObj = component.get('v.wizardprop');
                    this.goToRecord(wizObj.supplyPointId);
                    return false;
                }
                break;
            default:
                return true;
        }
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },  
    
    // method for error message while bill calculations
    handleError : function(component, response) {
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showNotification(component, errorMessage, 'error') ;
    },
    
    // method to process to display bill component, when percentage split popup appears
    callChecksOnEntryForDisplayBill: function(component, event, helper){
        component.set('v.stepName',$A.get("$Label.c.LoAp_SiteSupplyWizardDisplayBill"));
        this.doNext(component);
        this.checksOnEntry(component);
    },
    
    // method will calculate bill based on active Billing Contract   
    handleBillCalculation: function(component, response) {
        if(response != null) {
            var contractIds = [];
            var wizObj = component.get('v.wizardprop');
            var records = response.getReturnValue();
            for(var i=0;i<records.length;i++){
                contractIds.push(records[i]);
            }
            
            //alert('contractIds = '+contractIds)
            if(contractIds && contractIds.length > 1){
                wizObj.contractId = contractIds[0];
                component.set('v.newListOfContractId', contractIds);
            }else if(contractIds && contractIds.length == 1){
                wizObj.contractId = contractIds[0];
                component.set('v.newListOfContractId', contractIds);
                component.set('v.newRecordId', contractIds[0]);
            }else if(wizObj.contractId){ 
                component.set('v.newRecordId', wizObj.contractId);
            }
            //alert('wizObj.contractId '+wizObj.contractId)
            if (wizObj.contractId) {
                component.set('v.isCommitted', true);
                var calculateBillCmp = component.find('calculateBillComponent');
                calculateBillCmp.calculateBills(function(response) {
                    wizObj.billId = response;
                });                
            }
            component.set('v.wizardprop', wizObj);
        }
        else {
            this.handleError(component, response);                
        }
    },
    
    // update the wizard steps following a wizard property change
    updateWizardSteps: function(component, event, helper) {        
        this.callApexWizardStatus(component, event, helper);
    },
    
    // update the wizard step names based on validation
    setWizardSteps: function(component, event, helper) {
        function remove(array, element) {
            const index = array.indexOf(element);
            if (index !== -1) {
                array.splice(index, 1);
            }
        }
        const allStepNames = [
            $A.get("$Label.c.LoAp_SiteSupplyPage1"),
            $A.get("$Label.c.LoAp_SiteSupplyPage2"),
            $A.get("$Label.c.LoAp_SiteSupplyPage3"),
            $A.get('$Label.c.LoAp_SiteSupplyWizardDisplayBill')
            
        ];
        
        // clone the complete list of steps and remove the unnecessary steps
        var stepNames = allStepNames;
        var status = component.get('v.wizardprop');
        if(status.wizardType === $A.get("$Label.c.LoAp_isAmend")){
            remove(stepNames, $A.get('$Label.c.LoAp_SiteSupplyPage2'));
        }
        // initialise the stepNames
        component.set('v.stepNames', stepNames);
    },
    
    // call the server to get status for wizard steps
    callApexWizardStatus: function(component, init) {   
        var action = component.get('c.WizardStatus');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        // update the steps
        this.setWizardSteps(component);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                // update the steps
                if (init) {		// set to the first step
                    var stepNames = component.get('v.stepNames');
                    component.set('v.stepName', stepNames[0]);
                    this.checksOnEntry(component);
                }
                // set the progress path
                this.doSetProgressPathDetails(component);                    
            } else {
                console.log('Error: ' + response.getError()[0].message);
                this.showNotification($A.get("$Label.c.GlUt_ServerConnectionError"), 'error');
                
            }
        });
        $A.enqueueAction(action);
    },
    
    // call the server to complete Create/Add/End Site Supply Record and doing Bill Calculations       
    callApexProcessSiteSupply: function(component, event, helper) {
        var action = component.get('c.processSiteSupplies');
        var wizardprop = JSON.stringify(component.get('v.wizardprop'));
        action.setParams({
            'wizardprop': wizardprop
        });
        action.setCallback(this, function(response) {
            var spId = this.handleBillCalculation(component, response);
        });
        $A.enqueueAction(action);
    },  
})