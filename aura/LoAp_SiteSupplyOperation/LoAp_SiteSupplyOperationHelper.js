({
	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {    
        component.set("v.value", $A.get("$Label.c.LoAp_isAmend"));     
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {    	
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        
        var SelectedOpt = component.get("v.value");                
        var wizObj = component.get("v.wizardprop");  
        
        if (SelectedOpt == $A.get("$Label.c.LoAp_isAmend"))
            wizObj.wizardType = $A.get("$Label.c.LoAp_isAmend");
        else
            wizObj.wizardType = $A.get("$Label.c.LoAp_isEnd");
                     
        wizObj.effectiveEndDate = null;
        wizObj.siteSuppliesToEnded = null;
        wizObj.siteSuppliesToCreate = null;
        component.set("v.wizardprop",wizObj);               
        return true;
    }         
})