({
    DEBUG:	'ServiceInformation: ',
    //Fetch service related information on the basis of Contract Id or S.P Id.
    getServiceRelatedInfo : function(component, event, helper) {
        if(component.get('v.oldRecordList') && component.get('v.oldRecordList').length > 0){
            var isChecked = true;
            component.set('v.fieldList',  component.get("v.oldFieldList"));
            var recordList = component.get('v.oldRecordList');
            for(var i=0;i<recordList.length;i++){
                if(recordList[i].isSelected == false)
                    isChecked = false;
            }
            component.set('v.recordList',component.get('v.oldRecordList'));
            component.set('v.isChecked',isChecked);
        }else{
        var parameter = event.getParam('arguments');
        var contractId;
        var supplyPointId;
        if (parameter) {
            if(parameter.contractId){
                contractId = parameter.contractId;
                component.set('v.selectionType',$A.get('$Label.c.GlAp_ContractLabel'));
            }
            if(parameter.supplyPointId){
                supplyPointId = parameter.supplyPointId;
                component.set('v.selectionType',$A.get('$Label.c.GlAp_SupplyPointLabel'));                
            }
        }
        let params ={
            "contractId": contractId,
            "supplyPointId": supplyPointId
        };
        helper.callServer(component,'c.getInfoToDisplay',
                          function(response) {
                              component.set("v.resultContainer", response);
                              component.set('v.fieldList',  component.get("v.resultContainer").fieldPropList);
                              component.set('v.recordList', component.get("v.resultContainer").combinedList);
                              component.set('v.isChecked', component.get("v.resultContainer").isChecked);
                              component.set('v.oldRecordList',component.get('v.recordList'));
                              component.set('v.oldFieldList',  component.get("v.fieldList"));
                              
                          },
                          params); 
        }
    },
    // Row select Event method
    handleRowSelectEvent : function(component, event) {
        var rowId = event.getParam('RowId');
        var servicesRemove = [];
        var recordList = component.get('v.recordList');
        console.log('recordList amits component ===== '+JSON.stringify(recordList));
        for (var i = 0; i < recordList.length; i++) {
            if(recordList[i].isSelected == true) {
                if(component.get('v.selectionType') && component.get('v.selectionType') == $A.get('$Label.c.GlAp_ContractLabel')){
                    var sobjectRecord ={ sobjectType: this.setPrefixedString('Service__c'),
                                        Id: recordList[i].uniqueId,
                                        [this.setPrefixedString('SupplyPoint__c')] : recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('SupplyPoint__c')],
                                        [this.setPrefixedString('ServiceType__c')] : recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('ServiceType__c')],
                                        [this.setPrefixedString('ServiceStartDate__c')] : recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('ServiceStartDate__c')],
                                        [this.setPrefixedString('ServiceEndDate__c')] : recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('ServiceEndDate__c')]
                                       }
                    servicesRemove.push(sobjectRecord);
                }
            }
        }
        component.set('v.servicesRemove',servicesRemove);
    },
})