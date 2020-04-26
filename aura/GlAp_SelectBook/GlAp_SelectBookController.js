({
    
    //Invoke in case of read period Change
    periodChange: function(component, event, helper) {
        return helper.periodChange(component, event, helper);
    },
    //Invoke in case of picklist value change for Area,Depot
    isPickValChange: function(component, event, helper) {
        return helper.isPickValChange(component, event, helper);
    },
    // Row select Event method
    handleRowSelectEvent: function(component, event, helper) {
        return helper.handleRowSelectEvent(component, event);
    },
   
    //Method Calls from Parent component
    getSelectedBooks: function(component, event, helper) {	
        return helper.getSelectedBooks(component);
    },
  
})