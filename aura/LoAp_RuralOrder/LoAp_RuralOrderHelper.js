({
    onSubmit : function(component, event, helper) {
        event.preventDefault();  // stop form submission          
        var eventFields = event.getParam("fields");  //get all fields on form                      
        let params = {recordDetails: eventFields};
        helper.callServer(component,'c.onSave', 
                          function(response) {           
                              component.set('v.resultContainer', response);
                              var wrapperobj = component.get('v.resultContainer');                              
                              if(wrapperobj.isError){                                                                                                
                                  this.showToast($A.get("$Label.c.LoAp_Errors"), wrapperobj.errorMsg);                                 
                              }else{                                  
                                  var confirmMSG = false;
                                  if(wrapperobj.confirmMSG1 != undefined){
                                      component.set("v.isOpen",true);
                                      component.set("v.isMSG1",true);
                                      component.set("v.confirmMSG1",wrapperobj.confirmMSG1);
                                      confirmMSG = true;
                                  }                                 
                                  if(wrapperobj.confirmMSG2 != undefined){
                                      component.set("v.isOpen",true);
                                      component.set("v.isMSG2",true);
                                      component.set("v.confirmMSG2",wrapperobj.confirmMSG2);
                                      confirmMSG = true;
                                  }
                                  if(!confirmMSG){
                                      component.find("recordViewForm").submit();                                     
                                  }
                              }
                          },
                          params);        
    },
    
    closeModel: function(component, event) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
        component.set("v.isMSG1", false);
        component.set("v.isMSG2", false);
        component.set("v.confirmMSG1", "");
        component.set("v.confirmMSG2", "");
    },
    
    onConfirmed:function(component, event){
        component.find("recordViewForm").submit();
        this.closeModel(component, event);      
    },
    
    // show toast message and return
    showToast: function(result, message) {    	 	       
        var title;
        var type;
        switch (result) {
            case $A.get("$Label.c.GlAp_Success"):   
                message = $A.get("$Label.c.GuAp_RecordSuccessfullyUpdatedMsg");
                title = $A.get("$Label.c.GuAp_SuccessTitle");
                type = $A.get("$Label.c.GlAp_Success");
                break;
            default:                                         	
                title   = $A.get("$Label.c.CuAp_LightningStateNotSuccessTitle");
                type    = $A.get("$Label.c.GlAp_NotificationTypeError");
                break;           
        }        
        if(message) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,    
                "type": type,     
                "message": message
            });
            toastEvent.fire();
        }      
    },
    
    // AT-5266 start..
    goToRecord: function(recordId) {        
        var evt = $A.get('e.force:navigateToURL');
        evt.setParams({
            url: '/one/one.app#/sObject/' + recordId
        });
        evt.fire();
    },
    
    handleSuccess : function(component, event, helper) {
        var result = JSON.parse(JSON.stringify(event.getParams()));		        
        this.goToRecord(result.id); 
    }
    // AT-5266 end..
   
})