({
    doInit : function(component, event, helper) {
        var Map1 = new Map(); 
        var Map2 = new Map(); 
        var Map3 = new Map();
        Map1.set('Files','ContentDocument');
        Map1.set('Errors',this.setPrefixedString('BatchError__c'));
        component.set('v.mapTabObject',Map1);
        var mapObjectFieldsArray = [];
        mapObjectFieldsArray.push(this.setPrefixedString('ErrorDetails__c'));
        mapObjectFieldsArray.push(this.setPrefixedString('OperatingRecordId__c'));
        
        Map2.set('ContentDocument',"['Id','ContentSize','FileType']");
        
        Map2.set(this.setPrefixedString('BatchError__c'),mapObjectFieldsArray);  
        
        component.set('v.mapObjectFields',Map2);
        
        Map3.set(this.setPrefixedString('BatchRequestQueue__c'),this.setPrefixedString('LoAp_EstimationScheduling'));
        component.set('v.mapBRQFieldSet',Map3);
    },    
    
    handleScheduleEstimate : function(component, event, helper) {
        component.find('notification').clearNotification();
        this.getScheduleJobs(component, event, helper, 'tab');        
    },
    
    handleSweepUpEstimate : function(component, event, helper) {
        component.find('notification').clearNotification();
        this.getScheduleJobs(component, event, helper, 'tab');              
    },
    
    getScheduleJobs : function(component, event, helper, clickedBy){
        var jobName;
        if(clickedBy == $A.get("$Label.c.CuAp_TabLabel")){
            var tabEvent = event.getSource();
            jobName = tabEvent.get('v.id');
        }
        
        if(clickedBy == $A.get("$Label.c.CuAp_ButtonLabel")){
            jobName = event.getSource().get('v.name');
        }
        
        let params ={
            "jobName": jobName
        };   
        this.callServer(component,'c.retrieveScheduleJobs',
                        function(response){
                            console.log('response = '+JSON.stringify(response));;
                            if(Object.keys(response).length > 0){
                                
                                component.set('v.StartSchedule',false);                                
                                if(jobName == $A.get("$Label.c.LoAp_ScheduleEstimate")){
                                    component.set('v.LastRun1',response['LastRun']);
                                    component.set('v.NextRun1',response['NextRun']);                                    
                                }else{                                    
                                    component.set('v.LastRun2',response['LastRun']);
                                    component.set('v.NextRun2',response['NextRun']);
                                }    
                            }
                            else{
                                component.set('v.StartSchedule',true);
                            }
                        },      				
                        params);  
    },
    
    handleStopSchedule : function(component, event, helper) {
        var jobName = event.getSource().get('v.name');        
        let params ={
            "jobName": jobName
        };            
        
        this.callServer(component,'c.stopScheduleJobs',
                        function(response){
                            component.set('v.StartSchedule',true);
                        },
                        params);
    },
    
    handleStartSchedule : function(component, event, helper) {
        component.find('notification').clearNotification();
        var time;
        var jobName = event.getSource().get('v.name'); 
        if(jobName == $A.get("$Label.c.LoAp_ScheduleEstimate")){
            time = component.get('v.ScheduleTime1');
        }else{
            time = component.get('v.ScheduleTime2');
        }
        
        if(!time){
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_PleaseEnterValidTime")],'error');            
            return false;
        }
            
        if(time){
            component.find('spinner').show();
            var cronTrigger = " 0 " + time.substr(3,4) + " " + time.substr(0,2) + " * * ?"; 
            let params ={
                "jobName": jobName,
                "cronTrigger": cronTrigger
            };            
            
            this.callServer(component,'c.startScheduleJobs',
                            function(response){
                                this.getScheduleJobs(component, event, helper, 'button'); 
                                component.find('spinner').hide();
                            },
                            params);
        }
    },
   newRequest: function(component, event, helper) {
        component.set("v.showComponent",true);
    },
})