({
    doInit : function(component, event, helper) {  
        component.set('v.readingId','');
        component.set('v.deviceId','');
        let params = {
            "infoStatementId": component.get("v.recordId"),
        };
        let readingPropertiesParams = {
            "fieldset": this.setPrefixedString($A.get("$Label.c.LoAp_InfoStatementReadingFieldSet"))
        };
        helper.callServer(component,'c.retrieveDevicePropDetails',
                          function(response){
                              component.set("v.devicesfieldList", response);
                          },
                          null);
        
        helper.callServer(component,'c.retrieveDeviceRecords',
                          function(response){
                              component.set("v.devicesrecordList", response);		
                              
                          },
                          params);
        
        helper.callServer(component,'c.retrieveReadingsPropDetails',
                          function(response){
                              component.set("v.readingsFldList", response);
                          },
                          readingPropertiesParams);
        
        

    },
    //AT-5262: auto Select First Device Readings
    autoSelectFirstDeviceReadings : function(component, event, helper) {
        var deviceList =  component.get("v.devicesrecordList") ;
        if(deviceList) {
            var firstDeviceId = deviceList[0].objectMap[this.setPrefixedString('Device__c')].Id ;
            component.set('v.deviceId', firstDeviceId);
            let params1 = {
                "recordId": firstDeviceId,
                "fieldset": $A.get("$Label.c.LoAp_InfoStatementReadingFieldSet"),
                "infoStatementId": component.get("v.recordId")
            };
            // Retrieve the list of Readings for the first device
            helper.callServer(component,'c.retrieveReadings',
                              function(response){
                                  component.set("v.readingsRecordList", response);
                              },
                              params1);
        }
    },
    
    // Method is calling from on click of debt transfer button to show modal box. 
    doActive: function(component,event, helper) {
        component.set('v.isActive', true); 
 		this.clearNotification(component);
        this.autoSelectFirstDeviceReadings(component, event, helper) ;  //AT-5262
    },
    
    // Calling this helper method on cancel button to close modal box
    doCancel: function(component,event, helper) { 
        component.set('v.readingId','');
        component.set('v.readingsRecordList','');
        component.set("v.isActive", false); 
        this.clearNotification(component);
    },
    
    // Helper method is used to call apex function to call Heroku API
    doSave : function(component,event, helper) {  
        var readingId = component.get('v.readingId');
        if (readingId == null || readingId == '') 
            this.showNotification(component, [$A.get("$Label.c.LoAp_InfoStatementReadingError")],'error');    
        else {
            var action = component.get("c.saveRecords");
            action.setParams({
                "selectedreadingId": readingId,
                "infoStatementId": component.get("v.recordId") ,
                "selectedDeviceId": component.get('v.deviceId') // AT-5361
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS') {
                    if(response){
                        component.set('v.isActive',false);
                        //To display toast for some couple of seconds
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "success",
                            "message": $A.get("$Label.c.Loap_ReadingLinkedToInfoStatement") 
                        });        
                        toastEvent.fire();
                    }
                    
                } else {
                    this.handleError(component, response);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notification').clearNotification();
    },     
    // get the selected rowid i.e. readingId in this case
    handleRowSelectEvent: function(component, event, helper) {
        this.clearNotification(component);
        var sRowId = event.getParam('RowId');
        var recordList = component.get('v.readingsRecordList');
        component.set('v.readingId','');
        for (var i = 0; i < recordList.length; i++) {
            if (recordList[i].uniqueId != sRowId) {
                recordList[i].isSelected = false;
            } else if(recordList[i].isSelected == true) {
                component.set('v.readingId',sRowId);
            }
            component.set('v.readingsRecordList', recordList);
        }
    },
    
    // get the clicked rowid i.e. deviceId in this case
    handleRowClickEvent: function(component, event, helper) {
        this.clearNotification(component);
        var  sRowId   = event.getParam('RowId');
        var tableName = event.getParam('Source');
        if(tableName == $A.get("$Label.c.LoAp_InfoStatementSelectDevice")){	//AT-5361
            
            component.set('v.deviceId',sRowId);
            let params = {
                "recordId": sRowId,
                "fieldset":   $A.get("$Label.c.LoAp_InfoStatementReadingFieldSet"),
                "infoStatementId": component.get("v.recordId")
            };
            
            // Retrieve the list of Readings
            helper.callServer(component,'c.retrieveReadings',
                              function(response){
                                  component.set("v.readingsRecordList", response);
                              },
                              params);
            
        }
    },
})