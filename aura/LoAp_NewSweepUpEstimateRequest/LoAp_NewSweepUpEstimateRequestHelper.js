({
    doInit : function(component, event, helper) {
        var mapOfPicklistLabel2Values = new Map(); 
        var picklistArray = [];
        picklistArray.push($A.get('$Label.c.LoAp_MeterBookSelected'));
        picklistArray.push($A.get('$Label.c.LoAp_MeterBookSelectAll'));
        mapOfPicklistLabel2Values[$A.get('$Label.c.GlAp_SelectBookHeaderEstimate')] = picklistArray;
        component.set('v.mapOfPicklistLabelWithValues',mapOfPicklistLabel2Values);
    },
    //handle row click event orginate from child componenet.
    handleRowClickEvent: function(component, event) {
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        var Ids = [];
        Ids.push(rowId);

        component.set('v.selectedBooks',[]);
        if (tableName == $A.get("$Label.c.LoAp_ReadPeriodObject")) { 
            component.set("v.periodId",Ids);
            component.set('v.isActive',true)
        }  
        if (tableName == $A.get("$Label.c.LoAp_ReadTimetableObject")) {
            component.set("v.timetableID",Ids);
            component.set('v.isActive',false);

        }
        
    },
    //handle row click event orginate from child componenet.
    handleRowSelectEvent : function(component, event) {
        if(component.get('v.isActive')){
            var bookIds = component.find('selectbook').getSelectedBooks();
            component.set('v.selectedBooks',bookIds);
        }
    },
    // call the notifier method to show a message on the notification component.
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    // Server call to save the data in BRQ.
    save: function(component, event,helper) {
        this.handleRowSelectEvent(component);
        var ErrorMessageVal = [];
        component.find('spinner').show();
        if(component.get('v.selectedBooks').length > 0){
            if(component.get('v.executionMode') == $A.get("$Label.c.LoAp_UnAllocatedExecutionMode")){
               component.set('v.selectedBooks',[]);
            }
            let params = {
                "timetableID" : component.get("v.timetableID"),
                "periodId": component.get("v.periodId"),
                "bookIds": component.get('v.selectedBooks'),
                "executionMode": component.get('v.executionMode')
            };
            helper.callServer(component,'c.createBRQ',
                              function(response) {
                                  window.location = '/one/one.app#/sObject/' + response;
                                  component.find('spinner').hide();
                          },
                          params);
        }else{
            component.find('spinner').hide();
            ErrorMessageVal.push($A.get("$Label.c.LoAp_SelectBookToSweepUp"));
            // Check if there is any error in array
            if(ErrorMessageVal.length > 0  ){
                this.showNotification(component,ErrorMessageVal, 'error');
            }
        }
    },
    //refresh the browser.
    close : function(component, event,helper) {
        $A.get('e.force:refreshView').fire();
    }
    
})