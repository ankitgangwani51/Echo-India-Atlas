({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    doUpdateValue : function(component, event, helper) {
        helper.doUpdateValue(component, event, helper);
    },
    doObjectUpdated : function(component, event, helper) {
        helper.doObjectUpdated(component, event, helper);
    },
   doEdit : function(component, event, helper) {
		var editEvent = component.getEvent("editModeEvent");
		editEvent.fire();
	},
    display : function(component, event, helper) {
        var toggleText = component.find("tooltip1");      
        $A.util.removeClass(toggleText, "slds-hide");
 	 },

  	displayOut : function(component, event, helper) {
        var toggleText = component.find("tooltip1");      
        $A.util.addClass(toggleText, "slds-hide");
  	}
})