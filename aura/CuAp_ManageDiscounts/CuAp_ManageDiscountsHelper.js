({
    // REQUIRED BY FRAMEWORK - these functions must be implemented in the wizard page controller 
    // re-initialise  component on wizard close/exit
    reInitialise: function(component, event, helper){ 
        component.set('v.DiscountFieldList', []);
        component.set('v.DiscountRecordList', []);
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.showSecond', false);
        component.set('v.oldEndDate',null);
    },
    
    // checks the component data for the component 
    checksOnEntry: function(component, event, helper){
        this.doInit(component, event, helper);
    },
    
    // validate the data gathered by the component    
    validateOnNext: function(component, event, helper){
        this.clearNotification(component);
        var recList = component.get('v.DiscountRecordList');
        // Changes for AT-3448 starts here
        var checkSelected = [];
        for(var i=0;i<recList.length;i++){        
                        
            if(recList[i].isSelected == true){
                if(recList[i].objectMap[this.setPrefixedString('DiscountType__c')][this.setPrefixedString('Type__c')] == $A.get("$Label.c.CuAp_PercentageLabel") && recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] > 100){
                    this.showNotification(component, [$A.get("$Label.c.CuAp_OverrideDiscountCannotmorethan100") + ' ' + recList[i].objectMap[this.setPrefixedString('DiscountType__c')]['Name']],'error');
                    return false;                    
                }
                
                if(recList[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] < 0){
                    this.showNotification(component, [$A.get("$Label.c.CuAp_OverrideDiscountCannotlessthan0") + ' ' + recList[i].objectMap[this.setPrefixedString('DiscountType__c')]['Name']],'error');
                    return false; 
                }
                
                if(recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')] == ''){                
                    this.showNotification(component, [$A.get("$Label.c.CuAp_StartDateCannotBeBlank") + ' ' + recList[i].objectMap[this.setPrefixedString('DiscountType__c')]['Name']],'error');
                    return false;
                }
                
                if(recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')] != '' &&
                   (recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')] > recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')] || 
                    recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')] === recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')])){
                    this.showNotification(component, [$A.get("$Label.c.CuAp_EndDateMustAfterStartDate") + ' ' + recList[i].objectMap[this.setPrefixedString('DiscountType__c')]['Name']],'error');
                    return false;
                }
                /*AT-2107*/ 
                if(recList[i].objectMap[this.setPrefixedString('DiscountType__c')][this.setPrefixedString('StartDate__c')] > recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')]){
                    this.showNotification(component, [$A.get("$Label.c.CuAp_StartDateBeforeError") + ': ' + recList[i].objectMap[this.setPrefixedString('DiscountType__c')]['Name']],'error');
                    return false;                    
                }
                 checkSelected.push(recList[i].isSelected);
            }
        }
        if(checkSelected.indexOf(true) < 0){
            this.showNotification(component,[$A.get('$Label.c.GlAp_SelectMandatory')], 'error');
            return false;
        }

        // Changes for AT-3448 Ends here
        var wizObj = component.get('v.wizardprop');
        wizObj.discount = recList;
        component.set("v.wizardprop",wizObj);
        return true;
    },
    // END: REQUIRED BY FRAMEWORK 
    
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },  
    
    //call made to server
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
    
    // doInit function: displays the discount fields header and discount records in the table
    doInit: function(component, event, helper) {
        helper.callServer(component,'c.retrieveDiscountPropDetails',
                          function(response){
                              component.set('v.DiscountFieldList', response);
                          },      				
                          null);
        
        var wizObj = component.get('v.wizardprop');
        var ContractId = wizObj.contractId;        
        
        var dateMap = new Map(); 
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        
        let params = {
            "ContractId": ContractId,
        };
        
        helper.callServer(component,'c.retrieveDiscountTypeRecords',
                          function(response){
                              debugger;
                              console.log('response for my discount record list--'+ JSON.stringify(response));
                              for (var i = 0; i < response.length; i++) {                                   
                                  //Create a Map to set End Date against with unique Id for further use
                                  dateMap.set(response[i].uniqueId,response[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')]);
                                  if(response[i].objectMap[this.setPrefixedString('DiscountType__c')] && response[i].objectMap[this.setPrefixedString('DiscountType__c')][this.setPrefixedString('CanbeOverridden__c')] != true){
                                      response[i].readOnlyFields[this.setPrefixedString('Discount__c.Override_Discount')] = true;
                                  }
                                  else{
                                      if(response[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_FixedDiscount"))
                                          response[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] = response[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('OverriddenDiscountAmount__c')];
                                      
                                      else if(response[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_BillToBillDiscount"))
                                          response[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] = response[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('OverriddenDailyDiscountAmount__c')];
                                      
                                          else if(response[i].transformFieldMap[this.setPrefixedString('Discount__c')]['RecordType'] == $A.get("$Label.c.CuAp_PercentageDiscount"))
                                              response[i].objectMap[this.setPrefixedString('Discount__c')]['Override_Discount'] = response[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('OverriddenDiscountPercentage__c')];                                      
                                  }
                                  if(!response[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')]){
                                      response[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('StartDate__c')] = todaysDate;
                                  }
                              }     
                              component.set('v.mapOldEndDate',dateMap);
                              component.set('v.DiscountRecordList', response);                                
                          },      				
                          params);
    },
    
    // This function will make the editable fields as read-only fields when the records gets de-selected and make them editable once selected again
    handleRowSelectEvent: function(component,event,helper){
        var sRowId = event.getParam("RowId");
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        var recList = component.get('v.DiscountRecordList');
        
        for (var i = 0; i < recList.length; i++) {
           // Changes for AT-3448 starts here
            if (recList[i].uniqueId != sRowId) {
                recList[i].isSelected = false;
            }
            recList[i].objectMap[this.setPrefixedString('Discount__c')][this.setPrefixedString('EndDate__c')] = component.get('v.mapOldEndDate').get(recList[i].uniqueId);
           // Changes for AT-3448 Ends here
		}     
        component.set('v.DiscountRecordList', []);
        component.set('v.DiscountRecordList', recList);
    },
    
    // This function will display the "Allocation to Bill Items" records to the lower table on the basis of discount record
    handleRowClickEvent: function(component, event, helper) {
        
        var sRowId = event.getParam('RowId');
        var tableName = event.getParam('Source');
        
        if(tableName == $A.get("$Label.c.CuAp_DiscountLabel")){
            component.set("v.showSecond",false);
            
            //Retrieve list of fields and properties for the suppression contracts            
            helper.callServer(component,'c.retrieveBillItemsfieldList',
                              function(response){
                                  component.set('v.fieldList', response);   
                              },      				
                              null);
            
            let params ={
                "DiscountId": sRowId
            };
            
            helper.callServer(component,'c.retrieveBillItemsrecordList',
                              function(response){
                                  component.set('v.recordList', response);   
                              },      				
                              params);            
            component.set("v.showSecond",true);
        }
    }
})