({
	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {    
        component.set("v.value", "isNewST");     
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {    	
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        
        var SelectedOpt = component.get("v.value");                
        var Obj = component.get("v.wizardprop");  
        
        if (SelectedOpt == 'isNewST')
            Obj.wizardType = $A.get('$Label.c.BlAp_NewStepTariff');  //NewStepTariff        
        else
            Obj.wizardType = $A.get('$Label.c.BlAp_ExistingStepTariff'); //ExistingStepTariff
                     
        // Null the steppedTarrif and steppedTariffServices variable because this variable is used in Add and Manage both screens
        Obj.steppedTariff = null;
        Obj.steppedTariffServices = null;
        component.set("v.wizardprop",Obj);               
        return true;
    }         
})