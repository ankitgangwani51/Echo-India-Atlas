({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) { 
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        var wizObj = component.get('v.wizardprop');
        if(wizObj.serviceTransfers)
           this.getOldServices(component, event, helper);
        else
         this.doInit(component, event, helper);        
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {        
        var isSuccess = this.validateServiceSearch(component, event, helper);
        if(isSuccess)
            return true;        
        else
            return false;
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },    
    
    setServiceTableBlank: function(component, event, helper) {
        component.set('v.selectedContractId',null)
        component.set('v.oldFieldList',[]);
        component.set('v.oldRecordList',[]);
        var callingServiceCmp = component.find("getServiceInformation");
        callingServiceCmp.getServiceRelatedInfo(null,null);
    },
    
    setServiceTableBlank1: function(component, event, helper) {
        component.set('v.oldFieldList',[]);
        component.set('v.oldRecordList',[]);
        var callingServiceCmp = component.find("getServiceInformation");
        callingServiceCmp.getServiceRelatedInfo(null,null);
    },
    
    // Row select Event method
    handleRowSelectEvent : function(component, event) {
        this.clearNotification(component);
    },
        
    getAllServices: function(component, event, helper) {
        this.clearNotification(component);
        component.set('v.oldRecordList',[]);
        var recordBy 			= component.get('v.recordBy');
        var conLookup		  	= component.get('v.selectedContractId');
        var callingServiceCmp 	= component.find("getServiceInformation");
        if(recordBy == $A.get('$Label.c.GlAp_ContractLabel') && !conLookup){
            this.showNotification(component, [$A.get("$Label.c.CuAp_SelectContract")],'error'); 
            return false;
        }
        if(recordBy == $A.get('$Label.c.GlAp_ContractLabel')){
            callingServiceCmp.getServiceRelatedInfo(component.get('v.selectedContractId').Id,null);    
        }              
    },
    
    getOldServices: function(component, event, helper) {
        this.clearNotification(component);
        var callingServiceCmp 	= component.find("getServiceInformation");
        callingServiceCmp.getServiceRelatedInfo(null,null);
    },
    
    // doInit function: displays the service type list and renewals parameters
    doInit: function(component, event, helper){          
        
        const operationVal = [
            $A.get('$Label.c.GlAp_ContractLabel')          
        ];
        component.set('v.options', operationVal);        
    },
    
    validateServiceSearch: function(component, event, helper){
        this.clearNotification(component);
        var recSelected = false;
        var recordList 			= component.get('v.oldRecordList');
        var recordBy 			= component.get('v.recordBy');
        var conLookup		  	= component.get('v.selectedContractId');
        var rec;
        var newRecordList = [];
        var wizObj = component.get('v.wizardprop');
        if(recordBy == $A.get('$Label.c.GlAp_ContractLabel') && !conLookup){
            this.showNotification(component, [$A.get("$Label.c.CuAp_SelectContract")],'error'); 
            return false;
        }
        
        for(var i=0;i<recordList.length;i++){
            if(recordList[i].isSelected){
                recSelected = true;
                rec = null;
                if(recordBy == $A.get('$Label.c.GlAp_ContractLabel')){
                    rec = {sobjectType: this.setPrefixedString('Service__c'), 
                           ['Id']											: recordList[i].uniqueId,
                           [this.setPrefixedString('ServiceType__c')]		: recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('ServiceType__c')],
                           [this.setPrefixedString('OccupancyType__c')]		: recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('OccupancyType__c')],
                           [this.setPrefixedString('SupplyPoint__c')]		: recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('SupplyPoint__c')],
                           [this.setPrefixedString('ServiceStartDate__c')]	: recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('ServiceStartDate__c')],
                           [this.setPrefixedString('ServiceEndDate__c')]	: recordList[i].objectMap[this.setPrefixedString('Service__c')][this.setPrefixedString('ServiceEndDate__c')]}
                    newRecordList.push(rec);
                }
            }
        }
        
        if(!recSelected){
            if(recordBy == $A.get('$Label.c.GlAp_ContractLabel'))
                this.showNotification(component, [$A.get("$Label.c.CuAp_SelectOneService")],'error');    
            return false;
        }        
        
        wizObj.contractId = component.get('v.recordId');
        
        if(recordBy == $A.get('$Label.c.GlAp_ContractLabel')){
            wizObj.serviceTransfers = newRecordList;
        }
        else{
            wizObj.serviceTransfers = null;
        }
        
        return true;
    }
})