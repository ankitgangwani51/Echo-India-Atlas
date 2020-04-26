({	   
    onSubmit : function(component, event, helper) {
        helper.onSubmit(component, event,helper);
    },
      
    closeModel: function(component, event, helper) {      
      helper.closeModel(component, event, '');
   	},
    
    onConfirmed: function(component, event, helper) {      
      helper.onConfirmed(component, event, '');
   	}, 
    
    handleSuccess : function(component, event, helper) {  // AT-5266
        helper.handleSuccess(component, event,helper);
    },
   
})