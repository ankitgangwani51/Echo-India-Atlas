({
	onChangeFunction: function(component, event) {
		 var reqd = component.get("v.required"); 
		 if(reqd){
			 if(event.getSource().get('v.value')=='' || event.getSource().get('v.value') == null){
				 event.getSource().set("v.errors", [{message:"Required Field "}]);	
			 }
			 else{
				  event.getSource().set("v.errors", null);	
			 }	 	 
		 }
     
        
    }
})