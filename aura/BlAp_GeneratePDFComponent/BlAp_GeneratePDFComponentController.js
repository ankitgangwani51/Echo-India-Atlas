({
	// initialise the component
	initialise: function(component, event, helper) {
        helper.initialise(component);
    },

    // display the pdf attachment
	view: function(component, event, helper) {
		helper.view(component);
    },

    // generates the pdf by calling a Heroku service via the apex controller
	generatePDF: function(component, event, helper) {
		helper.generatePDF(component, helper);
    }, 
})