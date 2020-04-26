({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
	
	populateReferenceName: function(component, event, helper) {
		helper.populateReferenceName(component);
	},
	
	keyPressController : function(component, event, helper) {      
      helper.keyPressController(component, event, helper);         
	},
  	
	// function for clear the Record Selaction 
    clear :function(component,event, helper){
         helper.clear(component, event, helper);
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    		helper.handleComponentEvent(component, event, helper);
	},
	
	// automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        helper.hideSpinner(component, event, helper);   
    },
    
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        helper.showSpinner(component, event, helper);  
    }
})