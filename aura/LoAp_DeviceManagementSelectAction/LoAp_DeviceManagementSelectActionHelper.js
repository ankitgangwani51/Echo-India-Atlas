({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {    
        component.set("v.value", $A.get('$Label.c.LoAp_NewDevice'));
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) { 
       var radioOptions = [{'label': $A.get('$Label.c.CuAp_AddDeviceLabel'), 'value': $A.get('$Label.c.LoAp_NewDevice')},
    			           {'label': $A.get('$Label.c.CuAp_RemoveDeviceLabel	'), 'value': $A.get('$Label.c.LoAp_RemoveDevice')},
                          {'label': $A.get('$Label.c.CuAP_ExchangeDeviceLabel'), 'value': $A.get('$Label.c.LoAp_ExchangeDevice')}]
        component.set('v.options',radioOptions);
     
        var Obj = component.get("v.wizardprop");        
        var action = component.get('c.retrieveActiveDevice');
        
        action.setParams({
            'locationId': Obj.locationId 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {                                             
                component.set('v.DeviceManage',response.getReturnValue()); //Sudhir 08-03-2018
            }
            
        });
        $A.enqueueAction(action);         
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        var SelectedOpt = component.get("v.value");
        var Obj = component.get("v.wizardprop"); 
        var ScreenObj = component.get("v.DeviceManage");
        if(SelectedOpt == $A.get('$Label.c.LoAp_NewDevice') && !ScreenObj.activeSupplyPoint)
        {
            this.showNotification(component,[$A.get('$Label.c.LoAp_NoSupplyPoint')], "error");
            return false;
        }
        else if(ScreenObj.noOfActiveDevices == 0 && (SelectedOpt == $A.get('$Label.c.LoAp_RemoveDevice') || SelectedOpt == $A.get('$Label.c.LoAp_ExchangeDevice')))
        {
            this.showNotification(component,[$A.get('$Label.c.LoAp_NoActiveDevice')], "error");
            return false;
        }        
        
        if (SelectedOpt == $A.get('$Label.c.LoAp_NewDevice'))
            Obj.wizardType = $A.get('$Label.c.LoAp_NewDevice');   //NewDevice        
        else if (SelectedOpt == $A.get('$Label.c.LoAp_RemoveDevice')){
            
            Obj.wizardType = $A.get('$Label.c.LoAp_RemoveDevice');  //RemoveDevice
            
            if(ScreenObj.noOfActiveDevices == 1)
            { 
                Obj.supplyPointDevice = {sobjectType: this.setPrefixedString('SupplyPointDevice__c'),
                                         Id:ScreenObj.objSupplyPointDevice.Id ,
                                         [this.setPrefixedString('Device__c')]: ScreenObj.objSupplyPointDevice[this.setPrefixedString('Device__c')], 
                                         [this.setPrefixedString('SupplyPoint__c')]: ScreenObj.objSupplyPointDevice[this.setPrefixedString('SupplyPoint__c')],
                                         [this.setPrefixedString('RemovalDate__c')] : null};
                
                Obj.selectedSupplyPointRemoved = {sobjectType: this.setPrefixedString('SupplyPoint__c'), 
                                                  [this.setPrefixedString('Measured__c')]: false, //AT-3174
                                                  //[this.setPrefixedString('ReadFrequency__c')] : $A.get('$Label.c.LoAp_ReadingFrequency') ,	//AT-3707
                                                  Id : ScreenObj.objSupplyPointDevice[this.setPrefixedString('SupplyPoint__c')]};                
            }
        }
            else{
                Obj.wizardType = $A.get('$Label.c.LoAp_ExchangeDevice');  //ExchangeDevice  
                
                if(ScreenObj.noOfActiveDevices == 1)
                { 
                    Obj.supplyPointDevice = {sobjectType: this.setPrefixedString('SupplyPointDevice__c'), 
                                             Id:ScreenObj.objSupplyPointDevice.Id ,
                                             [this.setPrefixedString('Device__c')]: ScreenObj.objSupplyPointDevice[this.setPrefixedString('Device__c')], 
                                             [this.setPrefixedString('SupplyPoint__c')]: ScreenObj.objSupplyPointDevice[this.setPrefixedString('SupplyPoint__c')],
                                             [this.setPrefixedString('RemovalDate__c')] : null};
                    
                    Obj.selectedSupplyPointRemoved = {sobjectType: this.setPrefixedString('SupplyPoint__c'),                                                 
                                                      //[this.setPrefixedString('ReadFrequency__c')] : ScreenObj[this.setPrefixedString('ReadFrequency__c')],
                                                      Id : ScreenObj.objSupplyPointDevice[this.setPrefixedString('SupplyPoint__c')]};                
                }
            }    
        
        Obj.noOfActiveDevicesPerLocation = ScreenObj.noOfActiveDevices;
        component.set("v.wizardprop",Obj);            
        
        return true;  
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    }
    
})