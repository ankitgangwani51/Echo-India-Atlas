({
	handleWizardEvent : function(component, event) {
        //Do any special processing here and then rethrow event
        var message = event.getParam("message");
        
        //event.stopPropagation();
    }
})