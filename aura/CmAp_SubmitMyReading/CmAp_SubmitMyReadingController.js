({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper) ;
    } ,
    submitReading : function(component, event, helper) {
        helper.submitReading(component) ;
    } ,
    saveMyReading : function(component, event, helper) {
        helper.saveMyReading(component) ;
    }, 
    showNotification: function(component, event, helper) {	
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
    },
})