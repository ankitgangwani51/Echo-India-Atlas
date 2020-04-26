({
     //method call from Wizard Cancel button
    doisWizardCancel : function(component, event, helper) {
        helper.doisWizardCancel(component);
	},
    // Call wizard screen for transfer service scenario.
    doAdd : function(component, event, helper) {
        helper.doAdd(component);
	},
     // Call wizard screen for remove services scenario.
    doRemove : function(component, event, helper) {
        helper.doRemove(component);
	},
    //Close Manage Contract Screen.
    doCancel: function(component, event, helper) {
        helper.doCancel(component);
	},
    //Show Manage Contract Screen.
    showManageContractComponent: function(component, event, helper) {
        helper.showManageContractComponent(component);
	},
    
})