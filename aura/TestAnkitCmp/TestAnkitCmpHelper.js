({
    doInit : function(component, event, helper) {
        var Map1 = new Map(); 
        var Map2 = new Map(); 
        var Map3 = new Map();
        
        Map1.set('Files','ContentDocument');
        Map1.set('Errors','BatchError__c');
        component.set('v.mapTabObject',Map1);
        
        alert('get map 1 index value = '+component.get('v.mapTabObject')[0])
        
        Map2.set('ContentDocument',"['Title','ContentSize','FileType']");
        Map2.set('BatchError__c',"['BatchRequestOperation__c','ErrorDetails__c','Name','BatchRequestType__c','OperatingRecordId__c']");        
        component.set('v.mapObjectFields',Map2);
        
        Map3.set('BatchRequestQueue__c','LoAp_EstimationScheduling');
        component.set('v.mapBRQFieldSet',Map3);
    },    
    
    handleScheduleEstimate : function(component, event, helper) {
        this.getScheduleJobs(component, event, helper, 'tab');        
    },
    
    handleSweepUpEstimate : function(component, event, helper) {
        this.getScheduleJobs(component, event, helper, 'tab');              
    },
    
    getScheduleJobs : function(component, event, helper, clickedBy){
        var jobName;
        if(clickedBy == 'tab'){
            var tabEvent = event.getSource();
            jobName = tabEvent.get('v.id');
        }
        
        if(clickedBy == 'button'){
            jobName = event.getSource().get('v.name');
        }
        
        let params ={
            "jobName": jobName
        };   
        //alert('jobName = '+jobName + '\n' + 'clickedby = '+clickedBy);
        this.callServer(component,'c.retrieveScheduleJobs',
                        function(response){
                            if(Object.keys(response).length > 0){
                                component.set('v.StartSchedule',false);                                
                                if(jobName == 'Schedule Estimate'){
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
        component.find('spinner').show();
        
        var jobName = event.getSource().get('v.name');        
        let params ={
            "jobName": jobName
        };            
        
        //alert('Abort job schedule for ==== '+jobName);
        this.callServer(component,'c.stopScheduleJobs',
                        function(response){
                            component.set('v.StartSchedule',true);
                            component.find('spinner').hide();
                        },
                        params);
    },
    
    handleStartSchedule : function(component, event, helper) {
        component.find('spinner').show();
        var time;
        var jobName = event.getSource().get('v.name'); 
        if(jobName == 'Schedule Estimate'){
            time = component.get('v.ScheduleTime1');
        }else{
            time = component.get('v.ScheduleTime2');
        }
        
        var cronTrigger = " 0 " + time.substr(3,4) + " " + time.substr(0,2) + " * * ?"; 
        //alert('cron t =='+cronTrigger);
        let params ={
            "jobName": jobName,
            "cronTrigger": cronTrigger
        };            
        
        //alert('Start job schedule for ==== '+jobName);
        this.callServer(component,'c.startScheduleJobs',
                        function(response){
                            //alert('response = '+JSON.stringify(response));
                            this.getScheduleJobs(component, event, helper, 'button'); 
                            component.find('spinner').hide();
                        },
                        params);
    },
})