({          
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) { 
         component.set("v.radioValue",$A.get("$Label.c.PyAp_RefundCreditOptionValue"));
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        
        var optionList = [];
        optionList.push({
            label: $A.get("$Label.c.PyAp_RefundCreditLabel"),
            value: $A.get("$Label.c.PyAp_RefundCreditOptionValue") 
        });
        optionList.push({
            label: $A.get("$Label.c.PyAp_ConsiderCreditForInstalmentCalculationLabel"),
            value: $A.get("$Label.c.PyAp_ConsiderCreditForInstalmentCalcOptionValue") 
        });
        component.set('v.options',optionList);
        
        var wizObj = component.get("v.wizardprop");        
        var creditAmountNew = wizObj.creditAmount;       
        component.set("v.creditAmount",creditAmountNew);
        wizObj.creditRefund = 'true';  //Refund/Transfer Credit Screen 
        component.set("v.wizardprop",wizObj);
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
        
        return true;       
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },   
    /* END: REQUIRED BY FRAMEWORK */
    
    /* PAGE SPECIFIC METHODS */
    setNextScreen: function(component, event, helper) {
        
        var Obj = component.get("v.wizardprop");
        var selectedOption = event.getParam("value");
        
        Obj.creditRefund = 'false';  //Payment Plan Set Up Screen  
        component.set("v.radioValue",$A.get("$Label.c.PyAp_ConsiderCreditForInstalmentCalcOptionValue"));
        
        if(selectedOption == $A.get("$Label.c.PyAp_RefundCreditOptionValue")){
            Obj.creditRefund = 'true';  //Refund/Transfer Credit Screen
            component.set("v.radioValue",$A.get("$Label.c.PyAp_RefundCreditOptionValue"));
        }
        
        component.set("v.wizardprop",Obj);
        
    }
    
})