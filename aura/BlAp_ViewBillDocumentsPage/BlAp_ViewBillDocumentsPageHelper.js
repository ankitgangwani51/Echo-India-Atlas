({
    // Init method is used to initialize component on load.
    doInit : function(component, event, helper) {        
        // Method is used to retrieve columns.
        helper.callServer(component,'c.retrieveBillPropDetails',function(response){
            component.set("v.billsfieldList", response);
        },null);
        // Fetching page record id and passing it as parameter in below method when calling server.
        var recordId = component.get('v.recordId');
        console.log('recordId==='+ recordId);
        if (recordId) {
            let params = {'objectRecordId': recordId  }	; //Sudhir: AT-4095(AU1) 
            helper.callServer(component,'c.getUserBills',function(response){
                console.log('response==='+ JSON.stringify(response));
                component.set("v.billsrecordList", response);			
            },params);
        }
    },
    // on click of view button which we are having in each row , showing document.
    handleRowSelectEvent: function(component, event, helper) {
        var errorMessages = [];  
        var sRowId = event.getParam('RowId');
        var componentId;
        var billsrecordList = component.get('v.billsrecordList');
        for(var i = 0; i < billsrecordList.length; i++){
            if(billsrecordList[i].uniqueId == sRowId){
                componentId = billsrecordList[i].transformFieldMap[this.setPrefixedString('Bill__c')].BillLink;
             }
        }
       console.log('componentId===='+componentId);
        if(componentId)
        {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": componentId
            });
            urlEvent.fire();
        }else{
            errorMessages.push($A.get('$Label.c.BlAp_BillCalcResultUnknownResponse'));
            this.showNotification(component, errorMessages,'error');
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
})