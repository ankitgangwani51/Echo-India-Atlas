({
	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {    
        component.set("v.value", "isNewDis");     
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        
        var SelectedOpt = component.get("v.value");
                
        var Obj = component.get("v.wizardprop");            
        if (SelectedOpt == 'isNewDis')
            Obj.wizardType = $A.get('$Label.c.CuAp_NewDiscount');  //NewDiscount        
        else
            Obj.wizardType = $A.get('$Label.c.CuAp_ExistingDiscount'); //ExistingDiscount
                     
        component.set("v.wizardprop",Obj);       
        
        return true;
    }    
     
})