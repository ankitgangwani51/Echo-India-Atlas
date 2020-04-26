({
    //calling the helper doInit method on page load
	doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    
    // display the payment component
    makePayment : function(component, event, helper) {
		helper.makePayment(component);
	},

})