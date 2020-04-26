({
    //Show Manage Contract Component.
    showManageSupplyPointComponent: function(component) {
        component.set('v.isActive',true);
    },
    getServiceRelatedInfo : function(component, event, helper) {
        let params ={
            "locationId": locationId
        };
        helper.callServer(component,'c.getInfoToDisplay',
                          function(response) {
                              component.set("v.resultContainer", response);
                              component.set('v.fieldList',  component.get("v.resultContainer").fieldPropList);
                              component.set('v.recordList', component.get("v.resultContainer").combinedList);
                          },
                          params); 
    },
    doSave : function(component) {
    },
    doCancel:function(component) {
        component.set('v.isActive',false);
    },
})