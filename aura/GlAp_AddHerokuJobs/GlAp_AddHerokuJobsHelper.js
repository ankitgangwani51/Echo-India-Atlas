({
    doInit : function(component, event, helper) {
        
        // initialise tab names        
        var callBy = component.get('v.callBy');
        if(callBy == $A.get('$Label.c.GlAp_Add')){
            var tabNames = [$A.get('$Label.c.VmDr_ImmediateLabel'),
                            $A.get('$Label.c.GlAp_ScheduleTypeDaily'), 
                            $A.get('$Label.c.GlAp_ScheduleTypeWeekly'), 
                            $A.get('$Label.c.GlAp_ScheduleTypeMonthly')];
        }
        else{
            // Once the batch has been scheduled, user cannot fire it immediately
            var tabNames = [$A.get('$Label.c.GlAp_ScheduleTypeDaily'), 
                            $A.get('$Label.c.GlAp_ScheduleTypeWeekly'), 
                            $A.get('$Label.c.GlAp_ScheduleTypeMonthly')];
        }
    	component.set('v.tabNames', tabNames);

        // initialise week days
        var daysOfWeek = [];        
        daysOfWeek.push({value:false,key:$A.get('$Label.c.GlAp_DayOfWeekMonday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekTuesday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekWednesday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekThursday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekFriday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekSaturday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekSunday')});
        component.set('v.listOfWeekDays',daysOfWeek);
        
        // initialise the date options
        var dateOptions = [];
    	dateOptions.push(' ');
    	for (var i = 1; i <= 31; i++) {
    		dateOptions.push(i.toString());
    	}
        dateOptions.push($A.get('$Label.c.GlAp_LastLabel'));
    	component.set('v.dateOptions', dateOptions);
        
        // Manage Heroku Batch
        var herokuBatchRecord = component.get('v.herokuBatchRecord');
        if(herokuBatchRecord){
            component.set('v.options',herokuBatchRecord.transformFieldMap.JOB_TYPE_BatchJobs.JOB_TYPE);
            component.set('v.recordBy',herokuBatchRecord.transformFieldMap.JOB_TYPE_BatchJobs.JOB_TYPE);
            var cronExpression = herokuBatchRecord.transformFieldMap.cronExpression.cronExpression;
            cronExpression = cronExpression.split(" ");
            if(cronExpression){        
                var minutes = cronExpression[1];
                var hours = cronExpression[2];
                var dayOfMonth = cronExpression[3];
                var month = cronExpression[4];
                var dayOfWeek = cronExpression[5]; // 1,3,5
                
                if(dayOfWeek != '*' && dayOfWeek != '?'){
                    component.set('v.activeTab',$A.get('$Label.c.GlAp_ScheduleTypeWeekly'));
                }
                
                if(dayOfMonth != '*' && dayOfMonth != '?'){
                    component.set('v.activeTab',$A.get('$Label.c.GlAp_ScheduleTypeMonthly'));
                }
                
                if((dayOfMonth == '*' || dayOfMonth == '?') && (month == '*' || month == '?') &&(dayOfWeek == '*' || dayOfWeek == '?')){
                    component.set('v.activeTab',$A.get('$Label.c.GlAp_ScheduleTypeDaily'));
                }   
            }
        }else{
            this.callServer(component, 'c.getJobTypeValues',
                            function(response) {   
                                component.set('v.options',response);
                            }, 
                            null); 
        }
    },
    
    handleTab: function (component, event, helper) {
        component.find('notification').clearNotification();
        var herokuBatchRecord = component.get('v.herokuBatchRecord');
        component.set('v.timeInput', null);
        component.set('v.dateInput', null);
        var daysOfWeek = [];        
        var monday = false;
        var tuesday = false;
        var wednesday = false;
        var thursday = false;
        var friday = false;
        var saturday = false;
        var sunday = false;
        
        daysOfWeek.push({value:false,key:$A.get('$Label.c.GlAp_DayOfWeekMonday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekTuesday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekWednesday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekThursday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekFriday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekSaturday')},
                        {value:false,key:$A.get('$Label.c.GlAp_DayOfWeekSunday')});
        component.set('v.listOfWeekDays',daysOfWeek);
        if(herokuBatchRecord){
            var cronExpression = herokuBatchRecord.transformFieldMap.cronExpression.cronExpression;
            cronExpression = cronExpression.split(" ");
            if(cronExpression){        
                var minutes 	= cronExpression[1];
                var hours 		= cronExpression[2];
                var dayOfMonth 	= cronExpression[3];
                var month 		= cronExpression[4];
                var dayOfWeek 	= cronExpression[5];         
                
                component.set('v.timeInput',hours + ':' + minutes);
                dayOfWeek = dayOfWeek.split(",");
                if(dayOfWeek != '*' && dayOfWeek != '?'){
                    for(var j=0;j<dayOfWeek.length;j++){
                        
                        if(dayOfWeek[j] == $A.get('$Label.c.GlAp_DayOfWeekMonday'))
                            monday = true;
                        if(dayOfWeek[j] == $A.get('$Label.c.GlAp_DayOfWeekTuesday'))
                            tuesday = true;
                        if(dayOfWeek[j] == $A.get('$Label.c.GlAp_DayOfWeekWednesday'))
                            wednesday = true;
                        if(dayOfWeek[j] == $A.get('$Label.c.GlAp_DayOfWeekThursday'))
                            thursday = true;
                        if(dayOfWeek[j] == $A.get('$Label.c.GlAp_DayOfWeekFriday'))
                            friday = true;
                        if(dayOfWeek[j] == $A.get('$Label.c.GlAp_DayOfWeekSaturday'))
                            saturday = true;
                        if(dayOfWeek[j] == $A.get('$Label.c.GlAp_DayOfWeekSunday'))
                            sunday = true;                        
                    }
                    var daysOfWeekNew = []
                    
                    daysOfWeekNew.push({value:monday,key:$A.get('$Label.c.GlAp_DayOfWeekMonday')},
                                       {value:tuesday,key:$A.get('$Label.c.GlAp_DayOfWeekTuesday')},
                                       {value:wednesday,key:$A.get('$Label.c.GlAp_DayOfWeekWednesday')},
                                       {value:thursday,key:$A.get('$Label.c.GlAp_DayOfWeekThursday')},
                                       {value:friday,key:$A.get('$Label.c.GlAp_DayOfWeekFriday')},
                                       {value:saturday,key:$A.get('$Label.c.GlAp_DayOfWeekSaturday')},
                                       {value:sunday,key:$A.get('$Label.c.GlAp_DayOfWeekSunday')});
                    component.set('v.listOfWeekDays',daysOfWeekNew);
                    
                }
                if(dayOfMonth != '*' && dayOfMonth != '?'){
                    if(dayOfMonth == 'L')
                        component.set('v.dateInput',$A.get('$Label.c.GlAp_LastLabel'));
                    else
                        component.set('v.dateInput',dayOfMonth);
                }
            }
        }
    },
    
    handleRecordBy : function(component, event, helper){
        component.find('notification').clearNotification();
        component.set('v.toDate',null);
    },
    
    handleCancel : function(component, event, helper){
        component.set('v.manageTrue',false);
    },
    
    handleDaysOfWeek : function(component, event, helper){
        var listOfWeekDays = component.get('v.listOfWeekDays');
        var clickedBy = event.target.id;
        var isChecked = event.target.checked;
        for(var i=0;i<listOfWeekDays.length;i++){
            if(listOfWeekDays[i].key == clickedBy)
                listOfWeekDays[i].value = isChecked;
        }
        component.set('v.listOfWeekDays',listOfWeekDays);
    },
       
    handleSave: function (component, event, helper) {
        component.find('notification').clearNotification();
        var activeTab = component.get('v.activeTab');
        var timeInput = component.get('v.timeInput');
        var dateInput = component.get('v.dateInput');
        var herokuBatchRecord = component.get('v.herokuBatchRecord');
        var daysOfWeekList = [];
        var listOfWeekDays = component.get('v.listOfWeekDays');
        var jobType = component.get('v.recordBy');
        var toDate = component.get('v.toDate');
        var callBy = component.get('v.callBy');
        // Select Job Type Validation
        if(!jobType){
            component.find('notification').showNotification([$A.get('$Label.c.GlAp_SelectHerokuJobType')],'error');            
            return false;  
        }
        
        // To Date is mandatory for Accruals Job Type
        if(jobType == $A.get('$Label.c.GlAp_AccrualsLabel') && !toDate){            
            component.find('notification').showNotification([$A.get('$Label.c.GlAp_EnterToDate')],'error');            
            return false; 
        }
        
        // Schedule details validation only for Forecast and Batch Billing 
        if(jobType != $A.get('$Label.c.GlAp_AccrualsLabel')){
            if(activeTab != $A.get('$Label.c.VmDr_ImmediateLabel')){
                if(!timeInput){
                    component.find('notification').showNotification([$A.get('$Label.c.GlAp_EnterTime')],'error');            
                    return false;                
                } 
                
                timeInput = timeInput.split(":");
                var hour = timeInput[0];
                var minute = timeInput[1];
                var cronMaker = "0 " + minute + ' ' + hour;
                
                // Validate details for Daily
                if(activeTab == $A.get('$Label.c.GlAp_ScheduleTypeDaily')){
                    cronMaker = cronMaker + ' * * ?';
                }
                
                // Validate details for Monthly
                if(activeTab == $A.get('$Label.c.GlAp_ScheduleTypeMonthly')){                    
                    if(!dateInput){
                        component.find('notification').showNotification([$A.get('$Label.c.GlAp_EnterADayInMonth')],'error');            
                        return false;  
                    }
                    if(dateInput == $A.get('$Label.c.GlAp_LastLabel'))
                        cronMaker = cronMaker + ' ' + 'L' + ' * ?';
                    else
                        cronMaker = cronMaker + ' ' + dateInput + ' * ?';
                }
                
                // Validate details for Weekly
                if(activeTab == $A.get('$Label.c.GlAp_ScheduleTypeWeekly')){
                    for(var i=0;i<listOfWeekDays.length;i++){
                        if(listOfWeekDays[i].value == true)
                            daysOfWeekList.push(listOfWeekDays[i].key);
                    }
                    if(daysOfWeekList.length < 1){
                        component.find('notification').showNotification([$A.get('$Label.c.GlAp_SelectADayInWeek')],'error');            
                        return false; 
                    }
                    cronMaker = cronMaker + ' ? * ' + daysOfWeekList;
                }  
            }
            else{
                cronMaker = null;                
            }   
        }  
        
        if(callBy == $A.get('$Label.c.GlAp_Add')){
            let param = {
                "activeTab" : activeTab,
                "cronMaker" : cronMaker,
                "jobType"   : jobType,
                "toDate"    : toDate,
            };
            
            helper.callServer(component,'c.calloutToHerokuPOST',
                              function(response){
                                  if(!response.isSuccess){
                                      component.find('notification').showNotification([response.message],'error');            
                                      return false; 
                                  }
                                  else{
                                      component.set('v.recordBy','');
                                      component.set('v.activeTab',$A.get('$Label.c.VmDr_ImmediateLabel'));
                                      this.doInit(component, event, helper);
                                      var toastEvent = $A.get("e.force:showToast");
                                      toastEvent.setParams({
                                          "title": "Success!",
                                          "type":"Success",
                                          "message": $A.get('$Label.c.GlAp_JobSavedSuccessLabel')
                                      });
                                      toastEvent.fire();
                                  }                                  
                              },      				
                              param);
        }
        else{
            let param = {
                "activeTab" : activeTab,
                "cronMaker" : cronMaker,
                "jobType"   : jobType,
                "herokuId"  : herokuBatchRecord.uniqueId
            };
            
            helper.callServer(component,'c.calloutToHerokuPUT',
                              function(response){
                                  console.log('response ***********= '+JSON.stringify(response));
                                  if(!response.isSuccess){
                                      component.find('notification').showNotification([response.message],'error');            
                                      return false; 
                                  }
                                  else{                 
                                      var refreshEvent = component.getEvent("refreshHerokuJobs");
                                      refreshEvent.fire();
                                      component.set('v.manageTrue',false);
                                      var toastEvent = $A.get("e.force:showToast");
                                      toastEvent.setParams({
                                          "title": "Success!",
                                          "type":"Success",
                                          "message": $A.get('$Label.c.GlAp_JobSavedSuccessLabel')
                                      });
                                      toastEvent.fire();
                                  }
                              },      				
                              param);
        }
    }
})