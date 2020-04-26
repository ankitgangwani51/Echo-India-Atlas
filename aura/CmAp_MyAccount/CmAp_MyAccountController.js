({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper) ;
	} ,
    
    editMode : function(component, event, helper) {
		helper.editMode(component);
	} ,
    
    selectedAddress : function(component, event, helper) {
        helper.selectedAddress(component, event, helper);
	  },
    
    selectedContact : function(component, event, helper) {
        helper.selectedContact(component, event, helper);
	  },
    
    selectedSic : function(component, event, helper) {
        helper.selectedSic(component, event, helper);
	  },
    
    selectedConsideration : function(component, event, helper) {
       helper.selectedConsideration(component, event, helper);
	  },
    
    selectedAdditional : function(component, event, helper) {
     helper.selectedAdditional(component, event, helper);
	  },
})