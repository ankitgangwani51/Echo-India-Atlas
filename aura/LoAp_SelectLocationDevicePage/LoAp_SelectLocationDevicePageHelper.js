({    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {    
        component.set('v.location', {'sobjectType': this.setPrefixedString('Location__c')});
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.SelectedRecord', '');
        component.set('v.isInitialised', false); 
        
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
         if(!component.get('v.isInitialised')) {
            component.set('v.location', {'sobjectType': this.setPrefixedString('Location__c')});
            this.initialiseDisplayedFields(component, event, helper);
        } 
    },  
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        
        var wizObj = component.get('v.wizardprop');    
        
        // device is required
        if (wizObj.supplyPointDevice === undefined || wizObj.supplyPointDevice === null) {
            this.showNotification(component, ['You must select a Device'], 'error');
            return false;
        }
        return true;
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    initialiseDisplayedFields: function(component, event, helper) {  
        var wizObj = component.get("v.wizardprop");        
        let params = {"sLocationId": wizObj.recordId,};
        
        //This is to change the outfield to GlAp_GenericField to make sure namespace issue is resolved
        this.callServer(component,'c.retrieveLocationFields', 
                        function(response) {
                            console.log('response---'+ JSON.stringify(response));
                            component.set('v.locationFields', response);
                        },
                        null);
        
        this.callServer(component,'c.getInfoToDisplay',
                        function(response){
                            component.set("v.resultContainer", response);
                            component.set("v.location" , component.get("v.resultContainer").locObject);
                            component.set("v.fieldList" , component.get("v.resultContainer").fieldPropList);
                            component.set("v.recordList" , component.get("v.resultContainer").devicesList);
                            component.set('v.isInitialised', true);
                            var result = component.get("v.recordList"); 
                            if(result.length == 0 ){ 
                                component.set("v.deviceExchangeActive",false);
                            }
                            
                        },                         
                        params);    
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
       // action.setStorable();
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
        var sRowId = event.getParam('RowId');
        var deviceFound = component.get('v.recordList');
        var wizObj = component.get('v.wizardprop');
        wizObj.supplyPointDevice = null;
        
        for (var i = 0; i < deviceFound.length; i++) {
            if (deviceFound[i].uniqueId != sRowId) {
                deviceFound[i].isSelected = false;
            } else if(deviceFound[i].isSelected == true) {
                component.set('v.SelectedRecord', deviceFound[i]);
                var SPD = component.get('v.SelectedRecord').objectMap[this.setPrefixedString('SupplyPointDevice__c')]; 
                var SP = component.get('v.SelectedRecord').objectMap[this.setPrefixedString('SupplyPoint__c')]; 
                if(wizObj.wizardType === $A.get("$Label.c.LoAp_RemoveDevice")){
                    var sp = {sobjectType : this.setPrefixedString('SupplyPoint__c'),
                              [this.setPrefixedString('Measured__c')]: false, //AT-3174
                              //[this.setPrefixedString('ReadFrequency__c')] : $A.get('$Label.c.LoAp_ReadingFrequency') ,	//AT-3707
                              Id : SPD[this.setPrefixedString('SupplyPoint__c')]}
                    wizObj.selectedSupplyPointRemoved = sp;
                    wizObj.supplyPointDevice = {sobjectType: this.setPrefixedString('SupplyPointDevice__c'), 
                                                Id: sRowId,
                                                [this.setPrefixedString('Device__c')]: SPD[this.setPrefixedString('Device__c')], 
                                                [this.setPrefixedString('SupplyPoint__c')]: SPD[this.setPrefixedString('SupplyPoint__c')],
                                                [this.setPrefixedString('RemovalDate__c')] : null}
                    component.set('v.wizardprop',wizObj);
                }
                if(wizObj.wizardType === $A.get("$Label.c.LoAp_ExchangeDevice")){
                    var sp = {sobjectType : this.setPrefixedString('SupplyPoint__c'),
                       //      [this.setPrefixedString('ReadFrequency__c')]: SP[this.setPrefixedString('ReadFrequency__c')],
                              Id : SPD[this.setPrefixedString('SupplyPoint__c')]}
                    wizObj.selectedSupplyPointRemoved = sp;
                    console.log('****selectedSupplyPointRemoved'+JSON.stringify(wizObj.selectedSupplyPointRemoved));
                    wizObj.supplyPointDevice = {sobjectType: this.setPrefixedString('SupplyPointDevice__c'), 
                                                Id: sRowId,
                                                [this.setPrefixedString('Device__c')]: SPD[this.setPrefixedString('Device__c')], 
                                                [this.setPrefixedString('SupplyPoint__c')]: SPD[this.setPrefixedString('SupplyPoint__c')],
                                                [this.setPrefixedString('RemovalDate__c')] : null}
                    component.set('v.wizardprop',wizObj); 
                }
            }
        }
        component.set('v.recordList', deviceFound);  
        
        
        this.clearNotification(component);
    }
})