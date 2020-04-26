({
	handleRowClickEvent: function(component, event, helper) {
        helper.handleRowClickEvent(component, event, helper);
    },
    
    // Row Select Event method
    handleRowSelectEvent: function(component,event,helper){
    	return helper.handleRowSelectEvent(component, event, helper);
    },
    
    // This funtion will checked and unchecked all the records based on SelectAll checkbox button    
    doEdit : function(component,event,helper){
		helper.doEdit(component, event, helper);
	}
})