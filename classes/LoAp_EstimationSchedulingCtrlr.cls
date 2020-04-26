/******************************************************************************
@author    		Echo: Ankit Gangwani
@date      		10 May 2018
@description 	Component controller for Estimation Scheduling.
*******************************************************************************/
public with sharing class LoAp_EstimationSchedulingCtrlr {
    
    private static List<string> cronJobDetailsFields;
    private static List<string> cronTriggerFields;
    
    static{ 
        //Get Fields from the CronJobDetails Object
        cronJobDetailsFields = new List<string>();
        cronJobDetailsFields.add(GlUt_APIConstantsCronJobDetail.ID);
        
        //Get Fields from the CronTrigger Object
        cronTriggerFields = new List<string>();
        cronTriggerFields.add(GlUt_APIConstantsCronTrigger.ID);
        cronTriggerFields.add(GlUt_APIConstantsCronTrigger.NEXTFIRETIMEAPINAME);
        cronTriggerFields.add(GlUt_APIConstantsCronTrigger.PREVIOUSFIRETIMEAPINAME);
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           10 May 2018
    @param          Job Name - Schedule Estimate/Sweeep Up Estimate
    @return         Void
    @description    Abort the schedule job on click of Stop Schedule button
    *******************************************************************************/
    @AuraEnabled
    public static Map<String,String> retrieveScheduleJobs(String jobName) {
        Map<String,String> timeZoneConvertorMap = new Map<String,String>();
        String whereClause = 'WHERE Name = \'' + jobName + '\'';
        List<CronTrigger> cronTriggerList = new List<CronTrigger>();
        List<CronJobDetail> cronJobDetailList = (List<CronJobDetail>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCronJobDetail.CronJobDetailAPINAME,
                                                                                                         cronJobDetailsFields,
                                                                                                         whereClause);
        
        if(cronJobDetailList.size() > 0){
            cronTriggerList = (List<CronTrigger>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCronTrigger.CronTriggerAPINAME,
                                                                                     cronTriggerFields,
                                                                                     cronJobDetailList[0].Id,
                                                                                     GlUt_APIConstantsCronJobDetail.CronJobDetailIdAPINAME);
             
            Datetime nextFireGMT = cronTriggerList[0].NextFireTime;
            Datetime lastFireGMT = cronTriggerList[0].PreviousFireTime;
            
            if(nextFireGMT == null){
                timeZoneConvertorMap.put(LoAp_Constants.NEXTRUN,'');
            }else{
                timeZoneConvertorMap.put(LoAp_Constants.NEXTRUN,nextFireGMT.format(LoAp_Constants.DATEFORMAT,''));
            }
            
            if(lastFireGMT == null){
                timeZoneConvertorMap.put(LoAp_Constants.LASTRUN,'');
            }else{
                timeZoneConvertorMap.put(LoAp_Constants.LASTRUN,lastFireGMT.format(LoAp_Constants.DATEFORMAT,''));
            }
        }         
        
        return timeZoneConvertorMap;
    }
    
    @AuraEnabled
    public static void stopScheduleJobs(String jobName) {
        String whereClause = 'WHERE Name = \'' + jobName + '\'';
        List<CronTrigger> cronTriggerList = new List<CronTrigger>();
        List<CronJobDetail> cronJobDetailList = (List<CronJobDetail>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCronJobDetail.CronJobDetailAPINAME,
                                                                                                         cronJobDetailsFields,
                                                                                                         whereClause);
        if(cronJobDetailList.size() > 0){
            cronTriggerList = (List<CronTrigger>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCronTrigger.CronTriggerAPINAME,
                                                                                     cronTriggerFields,
                                                                                     cronJobDetailList[0].Id,
                                                                                     GlUt_APIConstantsCronJobDetail.CronJobDetailIdAPINAME);
            System.abortJob(cronTriggerList[0].Id);
        }             
    }
    
    
    
    @AuraEnabled
    public static void startScheduleJobs(String jobName, String cronTrigger) {
        
        String BatchClass;
        if(jobName == System.Label.LoAp_ScheduleEstimate)
            BatchClass = System.Label.LoBt_ScheduledEstimatesLabel;
        else  
            BatchClass = System.Label.LoBt_SweepUpEstimatesLabel;
        
        GlBt_ScheduleBatchRequest myBatchObject = new GlBt_ScheduleBatchRequest(BatchClass);
        System.schedule(jobName, cronTrigger, myBatchObject);
        
        
    }
}