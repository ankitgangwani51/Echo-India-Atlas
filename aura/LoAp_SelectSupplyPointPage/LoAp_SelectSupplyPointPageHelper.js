({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.supplyPointExist', false);
        component.set('v.noResultFound', false);
        component.set('v.isInitialised', false);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        
        if(!component.get('v.isInitialised')) {
            this.initialiseDisplayedFields(component, event, helper);
        }
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
    	component.find('notifier').showNotification(message, type);
    },
    
    initialiseDisplayedFields: function(component, event, helper) {  
        var wizObj = component.get('v.wizardprop');
        // Retrieve the list of Supply Point on the basis of Location id.
        let params = {
            'locationId':wizObj.locationId 
        }; 
        
        // Retrieve list of fields and properties for Supply Point and Services Available on that Supply Point.
        this.callServer(component,'c.getSupplyPointFieldProps', 
                          function(response) {
                              component.set('v.fieldList', response);
                              console.log(response);
                          },
                          null);
        
        this.callServer(component,'c.getSupplyPointsOnLocation', 
                          function(response) {
                              component.set('v.recordList', response);
                              if (response.length > 0) {
                                  component.set('v.supplyPointExist', true);
                                  component.set('v.noResultFound',false);
                              } else{
                                  component.set('v.supplyPointExist', false);
                                  component.set('v.noResultFound',true);
                              }
                              component.set('v.isInitialised', true);
                          },
                          params);   
    },
    
    // validate the data gathered by the component 
    validateOnNext: function(component, event, helper) {
        var checkSelected = [];
        var supplyPointFound = component.get('v.recordList');
        for (var i = 0; i < supplyPointFound.length; i++) {
            checkSelected.push(supplyPointFound[i].isSelected);
        }
        
        if(checkSelected.indexOf(true) < 0){
            this.showNotification(component,[$A.get('$Label.c.LoAp_SupplyPointSelectError')], 'error');
            return false;
        }
        if(component.get('v.recordNotFound')){
            this.showNotification(component,[$A.get('$Label.c.LoAp_AvailableServiceError')], 'error');
            return false;
        }
        return true;
    },
    
    /* END: REQUIRED BY FRAMEWORK */

    //Handle the row select event for selecting and deselecting the generic table record selection.
    handleRowSelectEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var readingFound = component.get('v.recordList');
        for (var i = 0; i < readingFound.length; i++) {
            if (readingFound[i].uniqueId != sRowId) {
                readingFound[i].isSelected = false;
            }
        }
        
        component.set('v.recordList', readingFound);
        var sp = {sobjectType : this.setPrefixedString('SupplyPoint__c'),
                   [this.setPrefixedString('Measured__c')]: true, //AT-3174
                   //[this.setPrefixedString('ReadFrequency__c')] : null,
                   Id : sRowId}
      
        var wizObj = component.get('v.wizardprop');
        var spd = {sobjectType : this.setPrefixedString('SupplyPointDevice__c'),
                   [this.setPrefixedString('SupplyPoint__c')] : sRowId,
                   [this.setPrefixedString('Device__c')] : wizObj.newDeviceId,
                   [this.setPrefixedString('InstallationDate__c')] : null
                  }
        let params = {
            'supplyPointId':sRowId 
        }; 
        this.callServer(component,'c.getAvailableServicesOnSupplyPoint', 
                        function(response) {
                            if (response.length > 0) {
                                component.set('v.serviceTypeId', response);
                                var serviceRecords = [];
                                var serviceTypeId = component.get('v.serviceTypeId');
                                for(var i=0;i<serviceTypeId.length;i++) {
                                    var rec = {sobjectType : this.setPrefixedString('SupplyPointDeviceService__c'),
                                               [this.setPrefixedString('ServiceType__c')] : serviceTypeId[i],
                                               [this.setPrefixedString('SupplyPointDevice__c')] : null} 
                                    serviceRecords.push(rec);
                                }
                                wizObj.newSPDservices = serviceRecords;
                                component.set('v.wizardprop',wizObj);
                            }
                            else{
                                component.set('v.recordNotFound',true);
                            }
                        },
                        params);
       
        wizObj.spDeviceToBeAdded = spd;
        wizObj.selectedSupplyPointAdded = sp;
        component.set('v.wizardprop',wizObj);
    },
    
     //Fetch serialize response from server after perticular action in Apex Class.
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                callback.call(this,response.getReturnValue()); 
                 return true;
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
                 return false;
            }
        });
        
        $A.enqueueAction(action);
    }
})