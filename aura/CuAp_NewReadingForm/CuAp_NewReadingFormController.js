({
	doInit: function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
	
    doToggleSection: function(component, event, helper) {
    	if (component.get('v.allowSectionToggle')) {
    		helper.doToggleSection(component);
    	}
	},
	
	doEdit: function(component, event, helper) {
		component.set('v.editMode', true);
	},
	
	doCancel: function(component, event, helper) {				
		helper.doCancel(component);	
	},
	
	validateForm: function(component, event, helper) {
		return helper.validateForm(component);
	},
	
	doSave: function(component, event, helper) {
		helper.doSave(component, event, helper);
	},
    
    //called when an change event fired on component
    handleInputChangeEvent:function(component, event, helper) {
        return helper.handleInputChangeEvent(component, event, helper);
    }
})