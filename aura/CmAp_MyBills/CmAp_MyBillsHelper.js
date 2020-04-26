({
    doInit : function(component, event, helper) {           
        helper.callServer(component,'c.retrieveBillPropDetails',
                          function(response){
                              component.set("v.billsfieldList", response);
                          },
                          null);
        
        helper.callServer(component,'c.getUserBills',
                          function(response){
                              component.set("v.billsrecordList", response);			
                          },
                          null);
    },
    
    handleRowSelectEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var componentId;
        var billsrecordList = component.get('v.billsrecordList');
        for(var i = 0; i < billsrecordList.length; i++){
            if(billsrecordList[i].uniqueId == sRowId){
                componentId = billsrecordList[i].objectMap.ContentDocumentId.ContentDocumentId;
             }
        }
        
        if(componentId != "undefined")
        {
            $A.get('e.lightning:openFiles').fire({
                recordIds: [componentId]
            });
        }
     }
})