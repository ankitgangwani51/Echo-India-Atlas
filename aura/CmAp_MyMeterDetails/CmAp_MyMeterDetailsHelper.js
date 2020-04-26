({
    doInit : function(component, event, helper) {
        
        component.set('v.deviceType', {'sobjectType':this.setPrefixedString('DeviceType__c')});
        component.set('v.serialNumber', {'sobjectType':this.setPrefixedString('Device__c')});
        // get Device field list and properties
        this.getDeviceFieldProperties(component, event, helper);
        // get Reading field list and properties
        this.getReadingFieldProperties(component, event, helper);
        // get Reading records
        this.getReadingRecords(component, event, helper);
        
    } ,
    
    getDeviceFieldProperties : function(component, event, helper) {
        helper.callServer(component, 'c.retrieveDevicePropDetails',function(response) {
            console.log('getDeviceFieldProperties-retrieveDevicePropDetails' + JSON.stringify(response)) ;
            if(response) {
                component.set("v.deviceFieldList", response) ;
            }
        } ,
                          null) ;
    } ,
    
    getReadingFieldProperties : function(component, event, helper) {
        helper.callServer(component, 'c.retrieveReadingPropDetails', function(response){
            console.log('getReadingFieldProperties-retrieveReadingPropDetails' + JSON.stringify(response)) ;
            if(response) {
                component.set("v.readingFieldList", response) ;
            }
        } ,
                          null) ;
    } ,
    // fetches reading records
    getReadingRecords : function(component, event, helper) {	
        helper.callServer(component, 'c.getUserMeterDetails',function(response){
            if(response) {
                component.set("v.readingRecordList", response) ;
                //component.set("v.deviceRef", response.DeviceReference__c);
                component.set("v.deviceRef", response.Device__c);    // AT-3174
                var readingList = component.get("v.readingRecordList") ;
                var firstReading = readingList[0] ;
                if(firstReading) {
                    component.set("v.readingFound", true) ;
                    //var deviceId = firstReading.objectMap[this.setPrefixedString('Device__c')][this.setPrefixedString('Id')] ;
                    var deviceId = firstReading.objectMap[this.setPrefixedString('Device__c')]['Id'] ; //Sudhir: AT-3956 (SR)
                    if(firstReading.objectMap[this.setPrefixedString('Device__c')]) {
                    	var serialNumber = firstReading.objectMap[this.setPrefixedString('Device__c')][this.setPrefixedString('SerialNo__c')] ;
                    }
                    if(firstReading.objectMap[this.setPrefixedString('DeviceType__c')]) {
                        //var deviceType = firstReading.objectMap[this.setPrefixedString('DeviceType__c')][this.setPrefixedString('Name')]; //MT 07-08-2018 AT-3174 changed from device type to name field
                        var deviceType = firstReading.objectMap[this.setPrefixedString('DeviceType__c')]['Name']; //Security review
                    }
                    if(firstReading.objectMap[this.setPrefixedString('Device__c')]) {
                    	var deviceDigit = firstReading.objectMap[this.setPrefixedString('Device__c')][this.setPrefixedString('Digit__c')] ;
                    }
                    var lastActualReading = firstReading.objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')] ;
                    component.set("v.serialNumber", serialNumber) ;
                    component.set("v.deviceType", deviceType) ; 
                    component.set("v.deviceRef", deviceId) ;
                    component.set("v.deviceDigit", deviceDigit) ;
                    component.set("v.lastActualReading", lastActualReading) ;
                 }
            }
        } ,
        null) ;
    } ,
    
    submitReading : function(component) {
        var readingFound = component.get("v.readingFound") ;
        if(readingFound) {
            component.set("v.showSubmitReading", true) ;
        }
        else {
            component.set("v.showSubmitReading", false) ;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": [$A.get('$Label.c.CmAp_SubmitReadingToastTitle')] ,
                "type":"info",
                "message": [$A.get('&Label.c.CmAp_SubmitReadingToastMessage')]
            });
        }
        
    } ,    
})