({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper) ;
	} ,
    
    doActive: function(component, event, helper) {
        helper.doActive(component) ;      
    },
    
    doCancel: function(component, event, helper) {         
        helper.doCancel(component);        
    },
    
    doSave : function(component, event, helper) {
		helper.doSave(component);
	},
})