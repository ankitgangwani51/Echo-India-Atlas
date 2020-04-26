({
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.objectName", this.setPrefixedString('AvailableBundle__c'));
        component.set("v.supplyPointId", component.get("v.recordId"));
        let param = {"recordId" : component.get("v.recordId")};
        this.callServer(component, 'c.retrieveAvailaleService',function(response) {
            if(response) {
                console.log('retrieveAvailaleService => ' + JSON.stringify(response)) ;
                var settingMapIntoList = [];
                for(var key in response){
                    if(key) settingMapIntoList.push({value:response[key], key:key});	// AT-3683
                }
                console.log('settingMapIntoList => ' + JSON.stringify(settingMapIntoList)) ;
                component.set("v.mapOfAvailableServiceIdTOServiceTypeName", settingMapIntoList);
                if(settingMapIntoList.length > 0) this.getAvailableBundleRecords(component, settingMapIntoList[0].key);	// AT-3683
            }
        },param);
        
        this.callServer(component, 'c.retrieveAvailableBundleFields',function(response) { 
            component.set('v.fieldList', response);
        },null);
    },
    
    getAvailableBundleRecords : function(component, availableServiceId){
        let param = {"availableServiceId" : availableServiceId};
        this.callServer(component, 'c.retrieveAvailableBundleRecords',function(response) {
            console.log('retrieveAvailableBundleRecords => ' + JSON.stringify(response)) ;
            component.set('v.recordList', response);
        },param);
    },
    
    fetchAvailableBundleRecords : function(component, event, helper) {
        this.getAvailableBundleRecords(component, event.target.id);
    },
    
    buttonPressed : function(component, event, helper){
        var buttonId = event.getParam("ButtonId");
        var recordId = event.getParam("RowId");
        console.log('buttonId => ' + buttonId) ;
        console.log('recordId => ' + recordId) ;
        component.set("v.availableBundleRecordId", recordId);
        if(buttonId == $A.get('$Label.c.LoAp_ChangeBundleField')){
            component.set("v.openChangeBundleComponent", true);
        } else if(buttonId == "Action"){
            component.set("v.openMakeBundleActiveComponent", true);
        }
    }
})