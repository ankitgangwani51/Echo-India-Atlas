({
	doInit: function(component, event, helper) {		
		var labelSize = component.get("v.label");        
        if(typeof labelSize != "undefined" ||  labelSize!= null ) {            
        	component.set("v.labelSize", labelSize.length);
        }
	},
	
	onChangeFunction: function(component, event, helper) {		
		helper.onChangeFunction(component, event);
	},
    
    display1 : function(component, event, helper) {
        var toggleText = component.find("tooltip1"); 
        $A.util.removeClass(toggleText, "slds-hide");
 	 },

  	displayOut2 : function(component, event, helper) {      
        var toggleText = component.find("tooltip1");
        $A.util.addClass(toggleText, "slds-hide");
  	}
})