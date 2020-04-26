({
	selectObject : function(component, event, helper) {
	  // get the selected Account from list  
      var getSelectedObject = component.get("v.oObject");
      // call the event   
      var compEvent = component.getEvent("oSelectedObjectEvent");
  	  // set the Selected Account to the event attribute.  
      compEvent.setParams({"objectByEvent" : getSelectedObject });  
      // fire the event  
      compEvent.fire();
	}
})