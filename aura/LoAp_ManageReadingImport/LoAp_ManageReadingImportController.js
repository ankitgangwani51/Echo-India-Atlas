({
    //  Displays the Reading Upload values to the components
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
    
    // change event function fo handle the checkbox field to show/hide the input field based on checkbox    
    handleInputChangeEvent:function(component, event, helper) {
     	helper.handleInputChangeEvent(component, event, helper);
    },
    
    // Reset the selected values to the previous tab
    handleTab: function(component, event, helper) {
        helper.handleTab(component, event, helper);
    },
    
    // shows the manage reading component and hide the manage reading import button
    showManageReadingComponent: function(component, event, helper) {
        helper.showManageReadingComponent(component, event, helper);
    },
    
    // shows the manage reading import button and hide the manage reading component
    hideManageReadingComponent: function(component, event, helper) {
        helper.hideManageReadingComponent(component, event, helper);
    },
    
    // Validate the override values and create the reading, schedule read and reading upload values 
    handleOverride: function(component, event, helper) {
        helper.handleOverride(component, event, helper);
    },
    
    // Validate the Request Date and create Request Reading records associated with the Supply Point
    handleRequestRead: function(component, event, helper) {
        helper.handleRequestRead(component, event, helper);
    },
    
    // Validate new reading with previous readings and create Reading, Schedule Read and Reading Upload records
    handleAccept: function(component, event, helper) {
        helper.handleAccept(component, event, helper);
    },
    
    // Validate new reading with previous readings and create Reading, Schedule Read and Reading Upload records, also generate an amendment bill    
    handleAmendPrevious: function(component, event, helper) {
        helper.handleAmendPrevious(component, event, helper);
    },    
    
    handleBillCalculationComplete: function(component, event, helper) {
        event.stopPropagation();		// prevent further event propagation
        helper.handleBillCalculationComplete(component, event, helper);
    },
    
    showNotification: function(component, event, helper) {	
       
        event.stopPropagation();		// prevent further event propagation
        helper.showNotification(component, event.getParam('message'), event.getParam('type'));
 	}
})