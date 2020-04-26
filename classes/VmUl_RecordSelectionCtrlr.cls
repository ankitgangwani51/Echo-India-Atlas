/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           25-Nov-2017
@description:   This class is used to set the dynamic query for Record Selection (Void) and schedule the batch class 
on the basis of CRON Trigger which comes from the helper class
**************************************************************************************************************/
public with sharing class VmUl_RecordSelectionCtrlr {
    
    private static final String CLASS_NAME = 'VmUl_RecordSelectionCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 25-Nov-2017
    @return      : Boolean
    @param       : VoidManagementProfile, CurrentStage, CurrentStageDateTime, ResultLimit, CRON Expression and Report Type(Eg.. Immediate, Daily, Weekly etc.)
    @description : This method is used to passes the dynamic query to the batch class with mode ("Evaluate")
    **********************************************************************************************/
    @AuraEnabled
    public static boolean callingBatchEvaluateMode(String voidManagementProfile, String currentStage, String currentStageDateTime, Integer resultLimit, String cronTrigger, String reportType){
        Boolean isError = false; 
        try {
            String sQuery = 'SELECT ' + GlUt_APIConstantsVoidManagementProcess.EVALUATEAPINAME + ' FROM ' + GlUt_APIConstantsVoidManagementProcess.VOIDMANAGEMENTPROCESSAPINAME 
                + ' WHERE ' + GlUt_APIConstantsVoidManagementProcess.VOIDMANAGEMENTPROFILEAPINAME + ' = \'' + voidManagementProfile + '\'';
            String jobIDCheck = 'Void-' + voidManagementProfile;        
            
            if(currentStage != null && currentStage != ''){
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsVoidManagementProcess.CURRENTSTAGEAPINAME + ' = \'' + currentStage + '\'';
                jobIDCheck = jobIDCheck + '-' + currentStage;
            }        
            
            if(currentStageDateTime != null && currentStageDateTime != ''){
                Date currentStageDate = date.valueOf(currentStageDateTime);
                Datetime finalDateTime = Datetime.newInstance(currentStageDate,Time.newInstance(23, 59, 59,0)); 
                string dateTimeFormat = finalDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsVoidManagementProcess.CURRENTSTAGEDATETIMEAPINAME  + ' <=' + dateTimeFormat;
            }
            sQuery = sQuery + ' LIMIT ' + resultLimit;
            jobIdCheck = jobIdCheck + '-' + reportType;
            system.debug('sQuery = - = - = - ='+sQuery);
            VmBt_ProcessVMRecords myBatchObject = new VmBt_ProcessVMRecords(sQuery,'evaluate');
            if (reportType == 'immediate'){
                Id batchId = Database.executeBatch(myBatchObject);
            }
            else{            
                List<CronTrigger> cronList = [SELECT CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =:jobIDCheck];
                if (cronList.size() == 0){
                    String jobID = System.schedule(jobIDCheck, cronTrigger, myBatchObject);                           
                    isError = false;
                }
                else
                {                
                    isError = true;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
         return isError;
    }
}