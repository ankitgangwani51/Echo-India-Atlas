({    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {    
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.SelectedRecord', '');
        component.set('v.criteria', null);
        component.set('v.operation', null);
        component.set('v.filterValue', null);
        component.set('v.discountTypeExist', false);
        component.set('v.noResultFound', false);
    },
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
        var wizObj = component.get('v.wizardprop');    
        // wizard Type selection is required
        if (wizObj.wizardType === undefined || wizObj.wizardType === null) {
            return false;
        }
        this.doInit(component);
        return true;
    },
  
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        var checkSelected = [];
        var criteria = component.get('v.criteria');
        var concessions = component.get('v.concessions');
        var discountTypeFound = component.get('v.recordList');
        for (var i = 0; i < discountTypeFound.length; i++) {
            checkSelected.push(discountTypeFound[i].isSelected);
        }
        
        if(checkSelected.indexOf(true) < 0){
            this.showNotification(component,[$A.get('$Label.c.CuAp_DiscountTypeError')], 'error');
            return false;
        }
        
        if(criteria == $A.get('$Label.c.CuAp_BillToBillDiscount') && concessions.length == 0){
            this.showNotification(component,[$A.get('$Label.c.CuAp_NoConcessionError')], 'error');
            return false;
        }
        
        return true;
    },
    
    // This function will refresh the discount type table when the filter criteria values will change 
    setSelectDiscountBlank : function (component, event, helper){
        component.set('v.filterValue',null);
        component.set('v.operation',null);
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.SelectedRecord', '');
        component.set('v.discountTypeExist', false);
        component.set('v.noResultFound', false);
        this.clearNotification(component);
    },
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },  
    
     //Had to add the call server here as there was an issue when resolving the
    //component when going to the base class
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });       
        $A.enqueueAction(action);
    },
    /* END: REQUIRED BY FRAMEWORK */
    
    // initialise the filter labels
    doInit: function(component) {
        this.callServer(component,'c.picklistvaluesnew',
                          function(response){ 
                              this.assignPickListValues(response,component);                              
                          },                         
                          null);
        const operationVal = [
            $A.get('$Label.c.CuAp_FilterNone'),				    
            $A.get('$Label.c.CuAp_FilterOperationEquals'), 
            $A.get('$Label.c.CuAp_FilterOperationGreaterThan'), 
            $A.get('$Label.c.CuAp_FilterOperationLessThan')
        ];
        component.set('v.operationVal', operationVal);
    },
    
     //Assign picklist values to respective filter
     
    assignPickListValues : function(inputvalues,component){        
        var obj = JSON.parse(JSON.stringify(inputvalues));   
        var criteriaArray = [$A.get('$Label.c.CuAp_FilterNone')];
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                var val = obj[key];
                criteriaArray.push(val);                
            }
        }
        component.set('v.criteriaVal',criteriaArray);
    },
    // retrieve the discount types on the basis of filter criteria.
    retrieveDiscountType: function(component) {
        var wizObj = component.get("v.wizardprop");        
        var filVal = component.get('v.filterValue');
        var opeVal = component.get('v.operation');
        var criVal = component.get('v.criteria');
        let params = {
            "contractId" : wizObj.contractId,
            "sKeyValue" : filVal,
            "sOperation" : opeVal,
            "sfilterOn" : criVal,
        };
        this.callServer(component,'c.getInfoToDisplay',
                        function(response){
                            component.set("v.resultContainer", response);
                            component.set("v.fieldList" , component.get("v.resultContainer").fieldPropList);
                            component.set("v.recordList" , component.get("v.resultContainer").discountList);
                            component.set('v.discountTypeRecordType',component.get("v.resultContainer").discountTypeRecordType);
                            component.set('v.concessions',component.get("v.resultContainer").concessions);
                            var result = component.get("v.recordList");
                            if(result.length > 0 ){ 
                                component.set("v.discountTypeExist",true);
                                component.set('v.noResultFound', false);
                            }
                            else{
                                component.set("v.discountTypeExist",false);
                                component.set('v.noResultFound', true);
                            }
                        },                         
                        params);
        
    },  
    //Handle the row select event for selecting and deselecting the generic table record selection.
    handleRowSelectEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var concession = [];
        var discountTypeFound = component.get('v.recordList');
        var recordType = component.get('v.discountTypeRecordType');  
        var concessions = component.get('v.concessions');
        
        for (var i = 0; i < discountTypeFound.length; i++) {
            if (discountTypeFound[i].uniqueId != sRowId) {
                discountTypeFound[i].isSelected = false;
            }else if(discountTypeFound[i].isSelected == true) {
                component.set('v.SelectedRecord', discountTypeFound[i]);
                var dType = component.get('v.SelectedRecord').objectMap[this.setPrefixedString('DiscountType__c')]; 
                var wizObj = component.get('v.wizardprop');
                wizObj.discountType = {sobjectType: this.setPrefixedString('DiscountType__c'), 
                                       Id: sRowId,
                                       Name: dType.Name,
                                       [this.setPrefixedString('RecurrenceFrequency__c')]			: dType[this.setPrefixedString('RecurrenceFrequency__c')],
                                       [this.setPrefixedString('PercentageDiscountAmount__c')]		: dType[this.setPrefixedString('PercentageDiscountAmount__c')], 
                                       [this.setPrefixedString('AbsoluteDiscountAmount__c')]		: dType[this.setPrefixedString('AbsoluteDiscountAmount__c')],
                                       [this.setPrefixedString('DiscountPerDay__c')]				: dType[this.setPrefixedString('DiscountPerDay__c')],
                                       [this.setPrefixedString('Type__c')]							: component.get('v.discountTypeRecordType'),
                                       [this.setPrefixedString('CanbeOverridden__c')]				: dType[this.setPrefixedString('CanbeOverridden__c')],
                                       [this.setPrefixedString('MaximumDIscountPerServiceItem__c')]	: dType[this.setPrefixedString('MaximumDIscountPerServiceItem__c')],
                                       [this.setPrefixedString('TopUp__c')]							: dType[this.setPrefixedString('TopUp__c')],
                                       [this.setPrefixedString('StartDate__c')]						: dType[this.setPrefixedString('StartDate__c')]}    /*AT-2107  */
                
                if(recordType == $A.get('$Label.c.CuAp_BillToBillDiscount')){
                    for(var j=0;j<concessions.length;j++){
                        concession.push(concessions[j])
                    }
                    wizObj.concessions = concession;
                }
                else
                    wizObj.concessions = null;
                
            }
        }
        component.set('v.recordList', discountTypeFound);
        this.clearNotification(component);
        
    },
    //Get records on the basis of filter value.
    doFilter : function(component,event,helper){
        var criteria = component.get('v.criteria');
        var operation = component.get('v.operation');
        var filterValue = component.get('v.filterValue');        
        if(filterValue === ''){
            filterValue = undefined;
        }
        if(criteria === $A.get('$Label.c.CuAp_FilterNone')){
            this.showNotification(component,[$A.get('$Label.c.CuAp_SelectDiscountType')], 'error'); 
        }else if(criteria === undefined && filterValue === undefined && operation === undefined){
            this.showNotification(component,[$A.get('$Label.c.CuAp_SelectDiscountType')], 'error'); 
        }
        else if(operation === $A.get('$Label.c.CuAp_FilterNone') && filterValue != undefined){
            this.showNotification(component,[$A.get('$Label.c.CuAp_DiscountFilterCriteria')], 'error'); 
        }else{
            this.clearNotification(component);
            this.retrieveDiscountType(component,event,helper);
        }
    },
    //Reset the filter values.
    doReset : function(component,event,helper){
        component.set('v.filterValue',null);
        component.set('v.operation',null);
        component.set('v.criteria',null);
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.SelectedRecord', '');
        component.set('v.discountTypeExist', false);
        component.set('v.noResultFound', false);
        this.clearNotification(component);
    },
})