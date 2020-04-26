({    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {    
    	component.set('v.fieldList', []);
		component.set('v.recordList', []);
    },
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
        
        var wizObj = component.get("v.wizardprop");        
        let params = {"customerId": wizObj.recordId,};
        
        this.callServer(component,'c.retrieveContracts',
                          function(response){
                              component.set("v.recordList", response);
                              var recList = component.get("v.recordList");	
                          },
                          
                          params);
        //Retrieve list of fields and properties for the suppression contracts
        this.callServer(component,'c.retrieveContractFieldPropDetails',
                          function(response){
                              component.set("v.fieldList", response);
                              
                          },
                          
                          null);     
    	
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
    	var wizObj = component.get('v.wizardprop');    
    	// device is required
        if (wizObj.contractId === undefined || wizObj.contractId === null) {
			this.showNotification(component, [$A.get("$Label.c.CuAp_MustSelectContract")], 'error');
			return false;
		}
		return true;
        
    },

    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
    	component.find('notifier').showNotification(message, type);
    },

    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
    	component.find('notifier').clearNotification();
    },   
	/* END: REQUIRED BY FRAMEWORK */
    
    /* PAGE SPECIFIC METHODS */
    
    //Had to add the call server here as there was an issue when resolving the
    //component when going to the base class
    callServer : function(component,method,callback,params) {
        
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }        
     //   action.setStorable();
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {                    
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    //set the selected supply point device record to wizardprop
    handleRowSelectEvent: function(component, event, helper) {
        var conFound = component.get('v.recordList');
        var sRowId = event.getParam("RowId");
        for(var i = 0; i < conFound.length; i++){
            if(conFound[i].uniqueId != sRowId){
                conFound[i].isSelected = false;
            }
        }
        var wizObj =component.get('v.wizardprop');
        wizObj.contractId = sRowId;
        component.set('v.recordList', conFound);        
        this.clearNotification(component);
    }
})