({
    // Init function calling on page load.
    doInit : function(component, event, helper) {
        helper.doInit(component,event, helper);
    },
   // Method is calling from on click of debt transfer button to show modal box. 
    doActive : function(component, event, helper) {
        helper.doActive(component,event, helper);
    },
    // Calling this method on cancel button to close modal box
    doCancel : function(component, event, helper) {
        helper.doCancel(component,event, helper);
    },
    // Method is used to call apex function to call Heroku API
    doSave : function(component, event, helper) {
        helper.doSave(component,event, helper);
    },
})