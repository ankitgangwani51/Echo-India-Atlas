({
    // Method is used to initialize variable when component loads.
    doInit : function(component, event, helper) {
        this.getBRQFieldsandRecords(component, event, helper);
    },
    getBRQFieldsandRecords : function(component, event, helper){
        let keys = Array.from(component.get('v.mapTabObject').keys());  
        component.set('v.ListOfTabName',keys);
        var objectName = Array.from(component.get('v.mapBRQFieldSet').keys()).toString();
        let params = {
            "objectType" : objectName,
            "fieldSet" : component.get('v.mapBRQFieldSet').get(objectName),
            "BatchProcess" :component.get('v.BatchProcess')
        };
        this.callServer(component, 'c.getInfoToDisplay',function(response) {
            component.set('v.BatchReqQueueFieldList', response.fieldPropList);
            component.set('v.BatchReqQueueRecordList', response.fieldRecordList);
        }, params); 
    },
    // Method is used to set the status on click event click.
    handleRowButtonPressEvent: function(component, event, helper) { 
        var rowId = event.getParam('RowId');
        var brqValues = component.get('v.BatchReqQueueRecordList');
        let params = {
            "BRQId" : rowId
        };
        for(var i=0;i<brqValues.length;i++){
            if(brqValues[i].uniqueId == rowId && 
               (brqValues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')] == $A.get("$Label.c.GlAp_Initialised") ||
                brqValues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')] == $A.get("$Label.c.GlAp_Processing")  ||
                brqValues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')] == $A.get("$Label.c.GlAp_Pending"))){            
                this.callServer(component,'c.cancelledStatus',function(response){                                    
                },params);
                this.getBRQFieldsandRecords(component, event, helper); 
            }
            else if(brqValues[i].uniqueId == rowId &&
                    brqValues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')] != $A.get("$Label.c.GlAp_Initialised") &&
                    brqValues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')] != $A.get("$Label.c.GlAp_Processing")  &&
                    brqValues[i].objectMap[this.setPrefixedString('BatchRequestQueue__c')][this.setPrefixedString('Status__c')] != $A.get("$Label.c.GlAp_Pending")){
                component.set("v.questionMessage",true);
            }
        } 
    },
    // Method is used to retrieve files, error and staging records and assigning it attibutes.
    handleRowClickEvent: function(component, event, helper) {
        debugger;
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        var recordList = component.get('v.recordList');
        var componentId;
        if(rowId && tableName != $A.get("$Label.c.GlAp_DefaultTable")){
            component.set('v.rowId',rowId);
        }
        var objectName;
        var callServer;
        var params;
        var activeTab = component.get("v.activeTab");
        if(component.get('v.rowId') && tableName != $A.get("$Label.c.GlAp_DefaultTable")){
            var tabNameUpperCase = activeTab.toUpperCase();
            
            if(tabNameUpperCase.includes("file".toUpperCase())){
                objectName = component.get('v.mapTabObject').get(activeTab);
                params = {
                    "objectName": component.get('v.mapTabObject').get(activeTab),
                    "objectFields": component.get('v.mapObjectFields').get(objectName)
                };
                callServer = 'c.retrieveFilesRecords';
            }
            if(tabNameUpperCase.includes("error".toUpperCase())){
                objectName = component.get('v.mapTabObject').get(activeTab);
                params = {
                    "objectName": component.get('v.mapTabObject').get(activeTab),
                    "objectFields": component.get('v.mapObjectFields').get(objectName)
                };
                callServer = 'c.retrieveErrorRecords';
            }
            if(tabNameUpperCase.includes("stag".toUpperCase())){
                objectName = component.get('v.mapTabObject').get(activeTab);
                params = {
                    "objectName": component.get('v.mapTabObject').get(activeTab),
                    "objectFields": component.get('v.mapObjectFields').get(objectName)
                };
                callServer = 'c.retrieveStagingRecords';
            }    
            
            this.callServer(component, 'c.retrieveFieldPropDetails',function(response) {
                debugger;
                component.set('v.fieldList', response);
            },params);  
            
            params.BatchRequestQueueId = component.get('v.rowId');
            this.callServer(component,callServer,function(response){        
                debugger;
                var tempResponse = response;
                component.set('v.recordList', response);
            },params);            
        }  
        else if(tableName != undefined){
            for(var i = 0; i < recordList.length; i++){
                if(recordList[i].uniqueId == rowId){
                    componentId = recordList[i].uniqueId;
                }
            }            
        }
    },   
    handleTab: function(component, event, helper) {
        this.handleRowClickEvent(component, event, helper);
    },
    // Method is used to verify opetation(If we need to cancle request)
    doCancelQuestion: function(component, event, helper) {
        component.set("v.questionMessage",false);
    }
})