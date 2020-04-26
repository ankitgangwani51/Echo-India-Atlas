({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        console.log('SearchDevicePage: reInitialise');
        component.set('v.deviceFound', false);
        component.set('v.hasSearched', false);
        component.set('v.isInitialised', false);
        //component.set('v.searchManufacture', {'sobjectType' : this.setPrefixedString('Device__c')});		
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
        if(!component.get('v.isInitialised')){
            component.set('v.searchManufacture', {'sobjectType':this.setPrefixedString('DeviceType__c')});
            component.set('v.searchSerialNumber', {'sobjectType':this.setPrefixedString('Device__c')});
            component.set('v.isInitialised', true);
        }
        
        let params = {
            'fieldType': 'input'
        };
        
        this.callServer(component,'c.retrieveDeviceFields', 
                        function(response) {
                            component.set('v.inputFields',response);
                        },
                        params);
    },
    
    // validations to be checked when clicked on search button and also retriving the data from the server regarding the device searched
    doSearch : function(component,event,helper) {
        let params = {
            'fieldType': 'output'
        };
        
        this.callServer(component,'c.retrieveDeviceFields', 
                        function(response) {
                            component.set('v.deviceFields',response);
                        },
                        params);
        
        helper.clearNotification(component);
        component.set('v.deviceFound', false); 
        component.set('v.hasSearched', false);
        
        var searchManufacture = component.get('v.searchManufacture');
        var sManufacture = searchManufacture[this.setPrefixedString('Manufacturer__c')];
        var searchSerialNo = component.get('v.searchSerialNumber');
        var sSerialNo = searchSerialNo[this.setPrefixedString('SerialNo__c')];
        var oldDeviceId = component.get('v.wizardprop.supplyPointDevice') !== undefined ? component.get('v.wizardprop.supplyPointDevice')[this.setPrefixedString('Device__c')] : '';
        // validation to check whether serial number is entered or not
        if(sSerialNo == '' || sSerialNo == undefined) {
            
            this.showNotification(component, [$A.get("$Label.c.LoAp_SearchDevicePageSerialNoReq")], 'error');
            return;
        } 
        var wizObj = component.get('v.wizardprop');
        var locationId = wizObj.locationId;
        //Changes for AT-3025 Starts Here
        params = {
            'sManufacture': sManufacture,
            'sSerialNo': sSerialNo,  
            'oldDeviceId': oldDeviceId,
            'locationId': locationId,
            'wizardType': wizObj.wizardType
        };
         //Changes for AT-3025 Ends Here
        // server call to validate that whether the device is active on a supply point or not and validate the device services are same as of supply point
        // this server call also fetches the device details from the server
        this.callServer(component,'c.queryForDevice', 
                        function(response) {
                            if(response.activeDevice == true) {
                                this.showNotification(component, [$A.get("$Label.c.LoAp_SearchDevicePageDevAct")], 'error');
                                return;
                            } else {
                                wizObj.numberOfSupplyPointPerLocation = response.numberOfSupplyPointPerLocation;
                                component.set('v.wizardprop',wizObj);  
                                component.set('v.hasSearched', true);
                                if(Object.keys(response.device).length === 0)
                                {
                                    component.set('v.deviceFound', false);
                                } else {
                                    // setting the device details
                                    console.log('response==='+JSON.stringify(response));
                                    component.set('v.deviceRef', response);
                                    component.set('v.deviceFound', true);
                                }
                                console.log('501**Neha******' +JSON.stringify(response));
                            }                                                          
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
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        // do all completion validation here
        // validation to check whehter the device is searched or not
        var wizObj = component.get('v.wizardprop');
        if(wizObj.numberOfSupplyPointPerLocation == 0){
            this.showNotification(component, [$A.get("$Label.c.LoAp_NoSupplyPointExist")], 'error');
            return false;
        }
        var deviceFound = component.get('v.deviceFound');
        if(!deviceFound) {
            this.showNotification(component, [$A.get("$Label.c.LoAp_SearchDevicePageSearchForDev")], 'error');
            return;
        } else {
            var deviceDetails = component.get('v.deviceRef');
            var serviceRecords = [];
            console.log('502Neha******wizObj.wizardType ' + wizObj.wizardType);
            console.log('503Neha******deviceDetails ' + JSON.stringify(deviceDetails));
            wizObj.newDeviceId = deviceDetails.device.Id;
            if(wizObj.wizardType == $A.get("$Label.c.LoAp_ExchangeDevice")){
                for(var i=0;i<deviceDetails.supplyPointDeviceService.length;i++) {
                    var rec = {sobjectType : this.setPrefixedString('SupplyPointDeviceService__c'),
                               [this.setPrefixedString('ServiceType__c')] : deviceDetails.supplyPointDeviceService[i][this.setPrefixedString('ServiceType__c')],
                               [this.setPrefixedString('SupplyPointDevice__c')]  : null} 
                    serviceRecords.push(rec);
                }
                var spd = {sobjectType : this.setPrefixedString('SupplyPointDevice__c'),
                           [this.setPrefixedString('SupplyPoint__c')] : wizObj.selectedSupplyPointRemoved.Id,
                           [this.setPrefixedString('Device__c')] : deviceDetails.device.Id,
                           [this.setPrefixedString('InstallationDate__c')]  : null
                          }
                wizObj.spDeviceToBeAdded = spd;
                wizObj.removalDate = deviceDetails.removalDate[this.setPrefixedString('RemovalDate__c')];
                wizObj.newSPDservices = serviceRecords;
            }
            
            if(wizObj.wizardType == $A.get("$Label.c.LoAp_NewDevice")){
                for(var i=0;i<deviceDetails.serviceTypeId.length;i++) {
                    var rec = {sobjectType : this.setPrefixedString('SupplyPointDeviceService__c'),
                               [this.setPrefixedString('ServiceType__c')]   : deviceDetails.serviceTypeId[i],
                               [this.setPrefixedString('SupplyPointDevice__c')]  : null} 
                    serviceRecords.push(rec);
                }
                if(deviceDetails.activeSupplyPointExist){
                    this.showNotification(component, [$A.get("$Label.c.LoAp_ActiveSupplyPointDeviceError")], 'error');
                    return false;
                }
                var spd = {sobjectType : this.setPrefixedString('SupplyPointDevice__c'),
                           [this.setPrefixedString('SupplyPoint__c')] : deviceDetails.selectedSupplyPoint.Id,
                           [this.setPrefixedString('Device__c')] : deviceDetails.device.Id,
                           [this.setPrefixedString('InstallationDate__c')] : null
                          }
                wizObj.spDeviceToBeAdded = spd;
                wizObj.newSPDservices = serviceRecords;
                
                var sp = {sobjectType : this.setPrefixedString('SupplyPoint__c'),
                          [this.setPrefixedString('Measured__c')]: true, //AT-3174
                          //[this.setPrefixedString('ReadFrequency__c')] : null,
                          Id : deviceDetails.selectedSupplyPoint.Id}
                wizObj.selectedSupplyPointAdded = sp;
                wizObj.removalDate = deviceDetails.removalDate[this.setPrefixedString('RemovalDate__c')];  // AT-1632
                component.set('v.wizardprop',wizObj);
            }
        
        }    
        return true;
    },
    
    //Had to add the call server here as there was an issue when resolving the
    //component when going to the base class
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                callback.call(this,response.getReturnValue());   
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
            }
        });       
        $A.enqueueAction(action);
    }
})