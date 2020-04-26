({
    //This will create the void management process fields from fieldset
    doInit : function(component, event, helper) {
        
        component.set("v.fieldSet", this.setPrefixedString('VmUI_RecordSelectionFieldSet'));
        component.set("v.objectType", this.setPrefixedString('VoidManagementProcess__c'));
        component.set('v.voidManagementProcess', {'sobjectType': this.setPrefixedString('VoidManagementProcess__c')});
        
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
       // action.setStorable();
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
    
    //Reset all the values to default
    setDefault: function(component, event, helper) {
        component.set("v.Monday",'false');
        component.set("v.Tuesday",'false');
        component.set("v.Wednesday",'false');
        component.set("v.Thursday",'false');
        component.set("v.Friday",'false');
        component.set("v.Saturday",'false');
        component.set("v.Sunday",'false');
        component.set("v.dayInput","1");
        component.set("v.selectTime",null);
    },
    
    //Set immediate as true and rest all as false
    setImmediate: function(component, event, helper) {
        component.set("v.weekly",false);
        component.set("v.monthly",false);
        component.set("v.daily",false);
        component.set("v.immediate",true);
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
    
    //Set Monthly as true and rest all as false
    setMonthly: function(component, event, helper) {
        component.set("v.weekly",false);
        component.set("v.monthly",true);
        component.set("v.immediate",false);        
        component.set("v.daily",false);
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
    
    //validate the input fields, given criteria and batch/schedule the batch report
    runReport: function(component, event, helper) {
        
        //Clears down the toast messages displays on screen
        component.find('notification').clearNotification(); 
        
        var time      = component.get("v.selectTime");
        var immediate = component.get("v.immediate");
        var daily     = component.get("v.daily");
        var weekly    = component.get("v.weekly");
        var monthly   = component.get("v.monthly");        
        
        if(weekly == true){
            var monday    = document.getElementById("monday").checked;
            var tuesday   = document.getElementById("tuesday").checked;
            var wednesday = document.getElementById("wednesday").checked;
            var thursday  = document.getElementById("thursday").checked;
            var friday    = document.getElementById("friday").checked;
            var saturday  = document.getElementById("saturday").checked;
            var sunday    = document.getElementById("sunday").checked;
        }
        
        var dayInput    = component.get("v.dayInput");
        var resultLimit = component.get("v.resultLimit");  
        
        var voidManagementObj     = component.get("v.voidManagementProcess"); 
        var voidManagementProfile = voidManagementObj[this.setPrefixedString('VoidManagementProfile__c')];
        var currentStage          = voidManagementObj[this.setPrefixedString('CurrentStage__c')];
        var currentStageDateTime  = voidManagementObj[this.setPrefixedString('CurrentStageDateTime__c')];
        
        
        //Field Criteria Validations
        if (voidManagementProfile == undefined || voidManagementProfile == ''){
            component.find('notification').showNotification([$A.get("$Label.c.VmUI_VoidManagementProfileMessage")],'error');
            return false;
        }
        
        if (resultLimit == null){
            component.find('notification').showNotification([$A.get("$Label.c.ResLimitNull")],'error');            
            return false;
        }  
        
        if (resultLimit < 1){
            component.find('notification').showNotification([$A.get("$Label.c.ResLimitLessThenOne")],'error');
            return false;
        }  
        
        if(immediate != true){            
            if (time == '' || time == null){
                component.find('notification').showNotification([$A.get("$Label.c.PleaseSelectTime")],'error');
                return false;
            }
        }
        
        // Weekly Validations
        if (weekly ==  true){            
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
        
        if(immediate == true){
            reportType='immediate';
        }
        if(daily == true){
            //Daily CRON Expression
            cronTrigger = "0 0 " + time + " * * ?";  
            reportType='daily';
        }
        if(weekly == true){
            if (monday == true){
                weekArray.push($A.get("$Label.c.VmDr_MondayLabel"));                    
            }
            if (tuesday == true){
                weekArray.push($A.get("$Label.c.VmDr_TuesdayLabel"));
            }
            if (wednesday == true){
                weekArray.push($A.get("$Label.c.VmDr_WednesdayLabel"));
            }
            if (thursday == true){
                weekArray.push($A.get("$Label.c.VmDr_ThursdayLabel"));
            }
            if (friday == true){
                weekArray.push($A.get("$Label.c.VmDr_FridayLabel"));
            }
            if (saturday == true){
                weekArray.push($A.get("$Label.c.VmDr_SaturdayLabel"));
            }
            if (sunday == true){
                weekArray.push($A.get("$Label.c.VmDr_SundayLabel"));
            }       
            
            //Weekly CRON Expression                
            cronTrigger = "0 0 " + time + " ? * " + weekArray;
            reportType='weekly';
        }
        if(monthly == true){
            if(dayInput == 'last'){
                //Last Day of Every Month CRON Expression   
                cronTrigger = "0 0 " + time + " L * ?";                
            }else{
                //<Day> of Every Month CRON Expression
                cronTrigger = "0 0 " + time + " " + dayInput + " * ?";
            }  
            reportType='monthly';
        }
        
        let params = {
            "voidManagementProfile": voidManagementProfile, 
            "currentStage": currentStage,
            "currentStageDateTime": currentStageDateTime,
            "resultLimit":resultLimit,
            "cronTrigger":cronTrigger,
            "reportType": reportType                        
        };
        
        helper.callServer(	component,'c.callingBatchEvaluateMode',
                          function(response){
                              
                              if(response == true){
                                  component.find('notification').showNotification([$A.get("$Label.c.DuplicateJob")],'error');
                              }else{   
                                  if (immediate == true){
                                      component.find('notification').showNotification([$A.get("$Label.c.SuccessBatchJob")],'info');
                                  }
                                  
                                  if(daily == true){
                                      component.find('notification').showNotification(['Job has been scheduled at ' + time + ':00 every Day..!!!'],'info');
                                      
                                  }
                                  if(weekly == true){
                                      if(weekArray.length > 1){
                                          var weektest = weekArray.slice(0,weekArray.length - 1).toString() + ' and ' + weekArray[weekArray.length - 1];                                      
                                      }else{
                                          var weektest = weekArray.slice(0,weekArray.length).toString();
                                      }
                                      component.find('notification').showNotification(['Job has been scheduled at ' + time + ':00 on every ' + weektest],'info');
                                      
                                  }
                                  if(monthly == true){
                                      var suffix = this.nth(dayInput);
                                      
                                      if(dayInput == 'last'){
                                          component.find('notification').showNotification(['Job has been scheduled on ' + dayInput + ' day of every month  at ' + time + ':00'],'info');                                          
                                      }else{
                                          component.find('notification').showNotification(['Job has been scheduled on ' + dayInput + suffix + ' day of every month  at ' + time + ':00'],'info');                                          
                                      }
                                  }
                                  
                                  var newVoidManagement = {'sobjectType': this.setPrefixedString('VoidManagementProcess__c'),
                                                           [this.setPrefixedString('VoidManagementProfile__c')]: '',
                                                           [this.setPrefixedString('CurrentStage__c')]: ''
                                                          };
                                  component.set("v.voidManagementProcess",newVoidManagement);
                                  component.set("v.resultLimit",2000);
                                  this.setImmediate(component, event, helper);
                                  this.doInit(component, event, helper);                                  
                              }
                          },      				
                          params);
    }
})