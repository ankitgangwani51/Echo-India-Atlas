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
        console.log(wizObj);
        console.log("Inside Agreed Rate Page");
        let params = {
            "contractId": component.get("v.wizardprop.contractId"),
        };
        
        
        this.callServer(component,'c.retrieveAgreedRatesNew',
                          function(response){
                              component.set("v.recordList", response);
                              var recList = component.get("v.recordList");	
                          },
                          
                          params);
        this.callServer(component,'c.retrieveContract',
                          function(response){
                              //component.set("v.objContract", response);
                              component.set("v.conStartDate", response[this.setPrefixedString('ContractStartDate__c')]);
                              component.set("v.conEndDate", response[this.setPrefixedString('ContractEndDateBackground__c')]);
                              
                          },
                          
                          params);
        
        
        //Retrieve list of fields and properties for the suppression contracts
        this.callServer(component,'c.retrieveAgreedRatesFieldPropDetails',
                          function(response){
                              component.set("v.fieldList", response);
                              
                          },
                          
                          null);    
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        
        var wizObj = component.get('v.wizardprop');    
        
        var recList = component.get("v.recordList");
        
        //Need to loop through all of the entries in the list and then set the sObject types so that the 
        //server can reserialise the records
        for(var i=0; i < recList.length; i++){
            var recEntry = recList[i];
            var aggEntry = recEntry.objectMap[this.setPrefixedString('AgreedRate__c')];    
            //Swati- 13-Mar-2018 -- Addded variable 'rateEntry' for resolution of defect - AT-2041 
            var rateEntry = recEntry.objectMap[this.setPrefixedString('Rate__c')];
            var serItemEntry = recEntry.objectMap[this.setPrefixedString('ServiceItem__c')];
            
            let aggatributes =  {
                "type": this.setPrefixedString('AgreedRate__c'),
            };
            let rateatributes =  {
                "type": this.setPrefixedString('Rate__c'),
            };
            let serItematributes =  {
                "type": this.setPrefixedString('ServiceItem__c'),
            };            
            
            aggEntry.attributes=aggatributes;
            if(rateEntry){
                rateEntry.attributes=rateatributes;
            }            
            serItemEntry.attributes=serItematributes;
            
        }
        
        //Now turn the list into a string to pass to the server as current bug does not permit lists
        //to be sent to Apex class - an internal error occurs
        
        var agreedRateString = JSON.stringify(recList);
        
        let params = {
            "AgreedRateString": agreedRateString,
        };
        
        this.callServer(component,'c.saveAgreedRate',
                          function(response){

                              if(response === $A.get("$Label.c.CuAp_AgreedRate_Sucess")){
                                  this.showNotification(component, [response], 'info');
                                  var urlEvent = $A.get("e.force:navigateToURL");
                							var currentUrl = window.location.href;
                							urlEvent.setParams({
                								"url" :currentUrl
                							});
                							urlEvent.fire();
                              } else {
                                  this.showNotification(component, [response], 'error');
                              }
                              return false;
                          },
                          
                          params);
        
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
        action.setStorable();
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
        var sRowId = event.getParam("RowId");
        var aggFound = component.get('v.recordList');
        for(var i = 0; i < aggFound.length; i++){
            //alert('befreif');
            if(aggFound[i].uniqueId == sRowId && aggFound[i].objectMap[this.setPrefixedString('AgreedRate__c')]['Id']!=null){
                //alert('insiderowselct'+locFound[i].objectMap['AgreedRate__c']['Id']);
                aggFound[i].readOnlyFields[this.setPrefixedString('AgreedRate__c')][this.setPrefixedString('Value__c')] = true;
                aggFound[i].readOnlyFields[this.setPrefixedString('AgreedRate__c')][this.setPrefixedString('StartDate__c')] = true;
                
                
            }
            if(aggFound[i].uniqueId != sRowId){
                //locFound[i].isSelected = false;
            }
        }
        var wizObj =component.get('v.wizardprop');
        
        //wizObj.locationId = sRowId
        //wizObj.allLocations = locFound;
        component.set('v.recordList', []);
        
        component.set('v.recordList', aggFound);       
        
        this.clearNotification(component);
    }
})