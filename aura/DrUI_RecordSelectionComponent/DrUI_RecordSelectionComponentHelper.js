({    
    //This will create the debt recovery process fields from fieldset
    doInit : function(component, event, helper) {
        
        component.set("v.fieldSet",  this.setPrefixedString('DrUI_RecordSelectionFieldSet'));
        component.set("v.objectType",  this.setPrefixedString('DebtRecoveryProcess__c'));
        component.set('v.debtRecoveryProcess', {'sobjectType': this.setPrefixedString('DebtRecoveryProcess__c')});
        var dayPicklist = [];
        for (var iCount = 1;iCount<=31;iCount++){
            dayPicklist.push(iCount);
        }
        component.set("v.dayPicklist",dayPicklist);    
        
        helper.getObjectFields(component, event, helper,       
                               function(response){
                                   component.set("v.fieldSetResultsList", response);                                   
                               });
    },
    
    //call made to server
    callServer : function(component,method,callback,params) {
        
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }        
     //   action.setStorable();
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {                    
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
    
    //Clears down the toast message
    doCancel: function(component, event, helper) {
        component.set("v.isForAll",false);    
    },
    
    //Reset all the values to default
    setDefault: function(component, event, helper) {        
        component.set("v.Monday",false);    // AT-4256
        component.set("v.Tuesday",false);	// AT-4256
        component.set("v.Wednesday",false);	// AT-4256
        component.set("v.Thursday",false);	// AT-4256
        component.set("v.Friday",false);	// AT-4256
        component.set("v.Saturday",false);	// AT-4256
        component.set("v.Sunday",false);	// AT-4256
        component.set("v.dayInput","1");
        component.set("v.selectTime",null);        
    },
    
    //Set evaluate as true and predict as false
    setEvaluate: function(component, event, helper) {
        component.set("v.evaluate",true);
        component.set("v.predict",false);  
        component.set("v.immediate",true);
        component.set("v.daily",false);		// AT-4256
        component.set("v.weekly",false);	// AT-4256
        component.set("v.monthly",false);	// AT-4256
        this.setDefault(component, event, helper); 
    },
    
    //Set predict as true and evaluate as false
    setPredict: function(component, event, helper) {
        component.set("v.evaluate",false);
        component.set("v.predict",true);
        component.set("v.immediate",true);
        component.set("v.daily",false);		// AT-4256
        component.set("v.weekly",false);	// AT-4256
        component.set("v.monthly",false); 	// AT-4256       
        this.setDefault(component, event, helper); 
    },
    
    //Set immediate as true and rest all as false
    setImmediate: function(component, event, helper) {
        component.set("v.weekly",false);
        component.set("v.monthly",false);
        component.set("v.daily",false);
        component.set("v.immediate",true);
        this.setDefault(component, event, helper); 
    },
    
    //Set daily as true and rest all as false
    setDaily: function(component, event, helper) {
        component.set("v.weekly",false);
        component.set("v.monthly",false);
        component.set("v.immediate",false);
        component.set("v.daily",true);
        this.setDefault(component, event, helper);  
    },
    
    //Set weekly as true and rest all as false
    setWeekly: function(component, event, helper) {
        component.set("v.weekly",true);
        component.set("v.monthly",false);
        component.set("v.immediate",false);
        component.set("v.daily",false);
        this.setDefault(component, event, helper); 
    },
    
    //Set monthly as true and rest all as false
    setMonthly: function(component, event, helper) {
        component.set("v.weekly",false);
        component.set("v.monthly",true);
        component.set("v.immediate",false);        
        component.set("v.daily",false);
        this.setDefault(component, event, helper); 
    },
    
    //Returns the nth standard suffix on the basis of incoming date
    nth: function(days) {        
        if(days>3 && days<21) return 'th';
        
        switch (days % 10) {
            case 1:  return "st";                
            case 2:  return "nd";                
            case 3:  return "rd";                
            default: return "th";
        }        
    },
    
    runDirectReport : function(component, event, helper){
        component.set("v.runForAll",true);
        this.runReport(component, event, helper, component.get("v.runForAll"));
    },    
    
    //validate the input fields, given criteria and batch/schedule the batch report
    // Sudhir: AT-3995: Security Review: Do not evaluate Boolean with Boolean
    runReport : function(component, event, helper, runForAll) {
        
        //Clears down the toast messages displays on screen
        component.find('notification').clearNotification(); 
        
        
        var time      = component.get("v.selectTime");
        var evaluate  = component.get("v.evaluate");
        var predict   = component.get("v.predict");
        var immediate = component.get("v.immediate");
        var daily     = component.get("v.daily");
        var weekly    = component.get("v.weekly");
        var monthly   = component.get("v.monthly");        
        
        //if(weekly == true){
        if(weekly) {  // Sudhir: AT-3995: Security Review
            var monday    = document.getElementById("monday").checked;
            var tuesday   = document.getElementById("tuesday").checked;
            var wednesday = document.getElementById("wednesday").checked;
            var thursday  = document.getElementById("thursday").checked;
            var friday    = document.getElementById("friday").checked;
            var saturday  = document.getElementById("saturday").checked;
            var sunday    = document.getElementById("sunday").checked;
        }
        
        var dayInput          = component.get("v.dayInput");
        var resultLimit = 0;
        //if(evaluate == true){
        if(evaluate) { // Sudhir: AT-3995: Security Review
            resultLimit = component.get("v.resultLimit");        
        }
        
        var debtManagementObj     = component.get("v.debtRecoveryProcess"); 
        var debtRecoveryProfile   = debtManagementObj[this.setPrefixedString('DebtRecoveryProfile__c')];
        var currentStage          = debtManagementObj[this.setPrefixedString('CurrentStage__c')];
        var currentStageDateTime  = debtManagementObj[this.setPrefixedString('CurrentStageDateTime__c')];
        var totatAmountDue        = debtManagementObj[this.setPrefixedString('TotalAmountDue__c')];
        
        //Field Criteria Validations        
        if ((debtRecoveryProfile  == undefined || debtRecoveryProfile  == '') &&
            (currentStage         == undefined || currentStage         == '') &&
            (currentStageDateTime == undefined || currentStageDateTime == '') &&
            (totatAmountDue       == undefined || totatAmountDue       == null) && 
            (runForAll 			  == undefined || runForAll            == false)){
            
            component.set("v.isForAll",true);            
            return false;
        }        
        
        component.set("v.runForAll",false);
        component.set("v.isForAll",false);
        
        //if (evaluate == true){            
        if(evaluate) { // Sudhir: AT-3995: Security Review
            /* if (resultLimit == null){
                component.find('notification').showNotification([$A.get("$Label.c.ResLimitNull")],'error');            
                return false;
            }  */
            
            //if(immediate != true){
            if(!immediate) { // Sudhir: AT-3995: Security Review
                if (time == '' || time == null){
                    component.find('notification').showNotification([$A.get("$Label.c.PleaseSelectTime")],'error');
                    return false;
                }                
            }            
            // Weekly Validations
            //if (weekly ==  true){                
            if(weekly) {  // Sudhir: AT-3995: Security Review
                if ((monday    != true) && 
                    (tuesday   != true) && 
                    (wednesday != true) && 
                    (thursday  != true) &&
                    (friday    != true) && 
                    (saturday  != true) &&
                    (sunday    != true)){  
                    component.find('notification').showNotification([$A.get("$Label.c.SpecificDayWeeklyRecursion")],'error');
                    return false;                
                }
            } 
            
            var cronTrigger;
            var weekArray = [];  
            var reportType;
            
            //if(immediate == true){
            if(immediate) { // Sudhir: AT-3995: Security Review
                reportType='immediate';
            }
            
            //if(daily == true){
            if(daily) { // Sudhir: AT-3995: Security Review
                //Daily CRON Expression
                cronTrigger = "0 0 " + time + " * * ?";  
                reportType='daily';
            }
            
            if(weekly){ // Sudhir: AT-3995: Security Review
                if (monday){	// Sudhir: AT-3995: Security Review
                    weekArray.push($A.get("$Label.c.VmDr_MondayLabel"));                  
                }
                if (tuesday){
                    weekArray.push($A.get("$Label.c.VmDr_TuesdayLabel")); 
                }
                if (wednesday){
                    weekArray.push($A.get("$Label.c.VmDr_WednesdayLabel")); 
                }
                if (thursday){
                    weekArray.push($A.get("$Label.c.VmDr_ThursdayLabel")); 
                }
                if (friday){
                    weekArray.push($A.get("$Label.c.VmDr_FridayLabel")); 
                }
                if (saturday){
                    weekArray.push($A.get("$Label.c.VmDr_SaturdayLabel")); 
                }
                if (sunday){                    
                    weekArray.push($A.get("$Label.c.VmDr_SundayLabel")); 
                }            
                //Weekly CRON Expression                
                cronTrigger = "0 0 " + time + " ? * " + weekArray;
                reportType='weekly';
            }
            
            if(monthly){ // Sudhir: AT-3995: Security Review
                if(dayInput == 'last'){
                    //Last Day of Every Month CRON Expression   
                    cronTrigger = "0 0 " + time + " L * ?";                
                }
                else{
                    //<Day> of Every Month CRON Expression
                    cronTrigger = "0 0 " + time + " " + dayInput + " * ?";
                }  
                reportType='monthly';
            }
        }
        
        var sMode;
        if(evaluate) { // Sudhir: AT-3995: Security Review
            sMode = 'evaluate';
        }
        else{
            sMode = 'predict';
        }
        
        let params = {
            "debtRecoveryProfile": debtRecoveryProfile, 
            "currentStage": currentStage,
            "currentStageDateTime": currentStageDateTime,
            "totatAmountDue": totatAmountDue,
            "resultLimit":resultLimit,
            "cronTrigger":cronTrigger,
            "reportType": reportType,
            "sMode":sMode
        }; 
        
        helper.callServer(component,'c.callingBatchOrSchedule',
                          function(response){
                               
                              if(response){ // Sudhir: AT-3995: Security Review
                                  component.find('notification').showNotification([$A.get("$Label.c.DuplicateJob")],'error');
                              }
                              else{
                                  this.doCancel(component, event, helper);     
                                  if(predict){ // Sudhir: AT-3995: Security Review
                                      component.find('notification').showNotification([$A.get("$Label.c.SuccessBatchJob")],'info');                                      
                                      this.setPredict(component, event, helper);
                                  }
                                  else{
                                      
                                      if (immediate){ // Sudhir: AT-3995: Security Review
                                          component.find('notification').showNotification([$A.get("$Label.c.SuccessBatchJob")],'info');
                                      }
                                      
                                      if(daily){
                                          component.find('notification').showNotification(['Job has been scheduled at ' + time + ':00 every Day..!!!'],'info');
                                          
                                      }
                                      if(weekly){
                                          if(weekArray.length > 1){
                                              var weektest = weekArray.slice(0,weekArray.length - 1).toString() + ' and ' + weekArray[weekArray.length - 1];                                      
                                          }
                                          else{
                                              var weektest = weekArray.slice(0,weekArray.length).toString();
                                          }
                                          component.find('notification').showNotification(['Job has been scheduled at ' + time + ':00 on every ' + weektest],'info');
                                          
                                      }
                                      if(monthly){
                                          var suffix = this.nth(dayInput);
                                          
                                          if(dayInput == 'last'){
                                              component.find('notification').showNotification(['Job has been scheduled on ' + dayInput + ' day of every month  at ' + time + ':00'],'info');                                          
                                          }
                                          else{
                                              component.find('notification').showNotification(['Job has been scheduled on ' + dayInput + suffix + ' day of every month  at ' + time + ':00'],'info');                                          
                                          }
                                      }                                      
                                      this.setEvaluate(component, event, helper);
                                      this.setImmediate(component, event, helper);
                                      
                                  }
                                  
                                  /*var newDebtManagement = {'sobjectType': 'DebtRecoveryProcess__c',
                                                           'DebtRecoveryProfile__c': '',
                                                           'CurrentStage__c': ''
                                                          };*/
                                  
                                   var newDebtManagement = {'sobjectType': this.setPrefixedString('DebtRecoveryProcess__c')};
                                   newDebtManagement[this.setPrefixedString('DebtRecoveryProfile__c')]= '';
                                   newDebtManagement[this.setPrefixedString('CurrentStage__c')]= '';
                                  
                                  component.set("v.debtRecoveryProcess",newDebtManagement);                                  
                                  this.doInit(component, event, helper);                                  
                              }
                          },      				
                          params);
    }
})