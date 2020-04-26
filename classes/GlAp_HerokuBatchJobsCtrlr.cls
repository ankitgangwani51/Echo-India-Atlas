/******************************************************************************
@author         Echo: Ankit Gangwani
@date           23 August 2018
@description    
*******************************************************************************/
public with sharing class GlAp_HerokuBatchJobsCtrlr {
    
    private static final String CLASS_NAME = 'GlAp_HerokuBatchJobsCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private class HerokuResponseContainer {
        private Integer id; 
        private Integer JobID;
        private String JobCron;
        private String JobType;
        private String JobName;
        private String SubmittedBy;
        private String Status;
        private String Frequency;
        private String TotalRecords;
        private String Success;
        private String Failure;
        private String JobEndTime;
        private String JobSize;
        private String JobInstanceId;
        private String NextSchedule;
    }
    
    private static List<String> statusFields;
    static{
        statusFields = new List<String>();
        statusFields.add(GlUt_Constants.JOBTYPEAPINAME);
        statusFields.add(GlUt_Constants.STATUSAPINAME);
        statusFields.add(GlUt_Constants.FREQUENCYAPINAME);
        statusFields.add(GlUt_Constants.SUBMITTEDBYAPINAME);
        statusFields.add(GlUt_Constants.TOTALRECORDSAPINAME);
        statusFields.add(GlUt_Constants.SUCCESSAPINAME);
        statusFields.add(GlUt_Constants.FAILUREAPINAME);
        statusFields.add(GlUt_Constants.JOBENDTIMEAPINAME);
    }
    
    /**********************************************************************************************
    @author        ECHO: Ankit Gangwani
    @date          23 August 2018
    @param         none
    @return        List<GLAp_FieldProps>
    @description   This method returns the field properties for each of the fields that are
                   to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> getHerokuJobsFields() {
        
        GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
        
        List<GLAp_FieldProps> fieldPropertiesFinal = new List<GLAp_FieldProps>(); 
        
        GLAp_FieldProps jobType = new GLAp_FieldProps();
        jobType.isFLSVisible = true;
        jobType.isEncrypted = false;
        jobType.isEditable = false; 
        jobType.isRequired = false;
        jobType.fieldName = GlUt_Constants.JOBTYPEAPINAME ;
        jobType.fieldLabel = GlUt_Constants.JOBTYPELABEL;
        jobType.fieldType = 'text';
        jobType.buttonField = false;
        jobType.transformField = true;
        jobType.parentObject = GlUt_Constants.JOBTYPEAPINAME + '_' + GlUt_Constants.BATCHJOBSAPINAME;
        fieldPropertiesFinal.add(jobType);
        
        GLAp_FieldProps nextScheduledDate = new GLAp_FieldProps();
        nextScheduledDate.isFLSVisible = true;
        nextScheduledDate.isEncrypted = false;
        nextScheduledDate.isEditable = false; 
        nextScheduledDate.isRequired = false;
        nextScheduledDate.fieldName = GlUt_Constants.NEXTSCHEDULEDAPINAME;
        nextScheduledDate.fieldLabel = GlUt_Constants.NEXTSCHEDULEDLABEL;
        nextScheduledDate.fieldType = 'text';
        nextScheduledDate.buttonField = false;
        nextScheduledDate.transformField = true;
        nextScheduledDate.parentObject = GlUt_Constants.NEXTSCHEDULEDAPINAME + '_' + GlUt_Constants.BATCHJOBSAPINAME;
        fieldPropertiesFinal.add(nextScheduledDate);
        
        GLAp_FieldProps cronExpression = new GLAp_FieldProps();
        cronExpression.isFLSVisible = false;
        cronExpression.isEncrypted = false;
        cronExpression.isEditable = false; 
        cronExpression.isRequired = false;
        cronExpression.fieldName = GlUt_Constants.CRONEXPRESSIONAPINAME;
        cronExpression.fieldLabel = GlUt_Constants.CRONEXPRESSIONAPINAME;
        cronExpression.fieldType = 'text';
        cronExpression.buttonField = false;
        //cronExpression.transformField = false;
        cronExpression.parentObject = GlUt_Constants.CRONEXPRESSIONAPINAME;
        //fieldPropertiesFinal.add(cronExpression);
        
        GLAp_FieldProps submittedBy = new GLAp_FieldProps();
        submittedBy.isFLSVisible = true;
        submittedBy.isEncrypted = false;
        submittedBy.isEditable = false; 
        submittedBy.isRequired = false;
        submittedBy.fieldName = GlUt_Constants.SUBMITTEDBYAPINAME;
        submittedBy.fieldLabel = GlUt_Constants.SUBMITTEDBYLABEL;
        submittedBy.fieldType = 'text';
        submittedBy.buttonField = false;
        submittedBy.transformField = true;
        submittedBy.parentObject = GlUt_Constants.SUBMITTEDBYAPINAME + '_' + GlUt_Constants.BATCHJOBSAPINAME;
        fieldPropertiesFinal.add(submittedBy);
        
        GLAp_FieldProps manageButton = new GLAp_FieldProps();
        manageButton.isFLSVisible = true;
        manageButton.isEncrypted = false;
        manageButton.isEditable = false; 
        manageButton.isRequired = false;
        manageButton.fieldName = System.Label.GlAp_Manage;
        manageButton.fieldLabel = System.Label.GlAp_Manage;
        manageButton.buttonField = true;
        manageButton.transformField = true;
        manageButton.parentObject = GlUt_Constants.BATCHJOBSACTIONSAPINAME;
        fieldPropertiesFinal.add(manageButton);
        
        GLAp_FieldProps deleteButton = new GLAp_FieldProps();
        deleteButton.isFLSVisible = true;
        deleteButton.isEncrypted = false;
        deleteButton.isEditable = false; 
        deleteButton.isRequired = false;
        deleteButton.fieldName = System.Label.CuAp_PPDeleteLabel;
        deleteButton.fieldLabel = System.Label.CuAp_PPDeleteLabel;        
        deleteButton.buttonField = true;
        deleteButton.transformField = true;
        deleteButton.parentObject = GlUt_Constants.BATCHJOBSACTIONSAPINAME;
        fieldPropertiesFinal.add(deleteButton);
        
        return fieldPropertiesFinal;
    }
        
    /**********************************************************************************************
    @author        ECHO: Ankit Gangwani
    @date          23 August 2018
    @param         none
    @return        List<BlAp_CombinedRecord>
    @description   
    **********************************************************************************************/
    @AuraEnabled    
    public static ResponseHandler getHerokuJobsRecords() {
        ResponseHandler objResponseHandler = new ResponseHandler();
        try{        
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTING + DEBUG);
            // Combined record to display the records in the table
            List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
            
            // Initialise the HerokuResponseContainer
            List<HerokuResponseContainer> herokuResponse = new List<HerokuResponseContainer>();
            
            Set<String> herokuIds = new Set<String>();
            Map<Id,HerokuResponseContainer> mapOfHerokuId2CronDetails = new Map<Id,HerokuResponseContainer>();
            String endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_JOB;
            String urlParams = null;
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(endPoint, urlParams, 2000);
            
            System.debug('response = = = = '+response);
            // handle response
            if (response.getStatusCode() == 200 && response.getBody() != null) {
                objResponseHandler.isSuccess = true;
                objResponseHandler.message = response.getBody();
                System.debug(DEBUG +  '!!Success!! Heroku Batch Jobs (GET)');
                System.debug(DEBUG +  'response.getBody(): ' + response.getBody());
                herokuResponse = (List<HerokuResponseContainer>) System.JSON.deserialize(response.getBody(), List<HerokuResponseContainer>.class);
                system.debug('herokuResponse: ' + herokuResponse);
                
                for(HerokuResponseContainer herokuRes : herokuResponse){
                    if(herokuRes.JobCron != null){
                        BlAp_CombinedRecord combRecord = new BlAp_CombinedRecord();
                        combRecord.uniqueId = String.valueOf(herokuRes.id);
                        combRecord.isSelected = false;
                        combRecord.objectMap = new Map<String, sObject>();
                        
                        Map<string, string> jobTypeMap  = new Map<string, string>();
                        jobTypeMap.put(GlUt_Constants.JOBTYPEAPINAME,herokuRes.jobType != null ? herokuRes.jobType : '');
                        
                        Map<string, string> nextScheduleMap = new Map<string, string>();
                        nextScheduleMap.put(GlUt_Constants.NEXTSCHEDULEDAPINAME,herokuRes.NextSchedule);
                        
                        Map<string, string> submittedByMap  = new Map<string, string>();
                        submittedByMap.put(GlUt_Constants.SUBMITTEDBYAPINAME,herokuRes.SubmittedBy != null ? herokuRes.SubmittedBy : '');
                        
                        Map<String,String> cronExpressionMap = new Map<String,String>();
                        cronExpressionMap.put(GlUt_Constants.CRONEXPRESSIONAPINAME, herokuRes.JobCron);
                        
                        combRecord.transformFieldMap = new Map<string,Map<string, string>>();
                        combRecord.transformFieldMap.put(GlUt_Constants.JOBTYPEAPINAME + '_' + GlUt_Constants.BATCHJOBSAPINAME, jobTypeMap);
                        combRecord.transformFieldMap.put(GlUt_Constants.NEXTSCHEDULEDAPINAME + '_' + GlUt_Constants.BATCHJOBSAPINAME, nextScheduleMap);
                        combRecord.transformFieldMap.put(GlUt_Constants.SUBMITTEDBYAPINAME + '_' + GlUt_Constants.BATCHJOBSAPINAME, submittedByMap);
                        combRecord.transformFieldMap.put(GlUt_Constants.CRONEXPRESSIONAPINAME,cronExpressionMap);
                        combinedList.add(combRecord);
                    }
                }
                
                objResponseHandler.combinedList = combinedList;
                // error response
            } else {
                objResponseHandler.isSuccess = false;
                objResponseHandler.message = response.getBody();
                System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());
            }            
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        return objResponseHandler;        
    }
    
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           28 August 2018
    @param          
    @description    Class is used to handle response.
    *******************************************************************************/    
    public class ResponseHandler{
        @AuraEnabled public boolean isSuccess;
        @AuraEnabled public string message;
        @AuraEnabled public List<BlAp_CombinedRecord> combinedList;
        
        public ResponseHandler(){
            isSuccess = false;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 28 August 2018
    @return      : void
    @description : 
    **********************************************************************************************/
    @AuraEnabled
    public static ResponseHandler deleteHerokuJob(Integer deleteId){
        ResponseHandler objResponseHandler = new ResponseHandler();
        try {
            String endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_JOB;
            
            // make the callout
            HttpResponse response = BlUt_HerokuWebservices.makeCalloutDelete(endPoint, '/' + String.valueOf(deleteId), 2000);

            // handle response
            if (response.getStatusCode() == 200) {
                System.debug(DEBUG + 'Good response: ' + response.getStatusCode() + ' ' + response.getStatus());
                objResponseHandler.isSuccess = true;
                objResponseHandler.message = response.getBody();
                
            } else { 
                System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ** ' + 'response = '+response.getBody());
                objResponseHandler.isSuccess = false;
                objResponseHandler.message = response.getBody();
            }
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }     
        return objResponseHandler;
    }
    
    /**********************************************************************************************
    @author        ECHO: Ankit Gangwani
    @date          23 August 2018
    @param         none
    @return        List<GLAp_FieldProps>
    @description   This method returns the field properties for each of the fields that are
                   to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> getHerokuJobStatusFields() {
        
        GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
        
        List<GLAp_FieldProps> fieldPropertiesFinal = new List<GLAp_FieldProps>(); 
        
        for(String str : statusFields){
            GLAp_FieldProps fieldProp = new GLAp_FieldProps();
            fieldProp.isFLSVisible = true;
            fieldProp.isEncrypted = false;
            fieldProp.isEditable = false; 
            fieldProp.isRequired = false;
            fieldProp.fieldName = str;
            fieldProp.fieldLabel = str;
            fieldProp.fieldType = 'text';
            fieldProp.buttonField = false;
            fieldProp.transformField = true;
            fieldProp.parentObject = str + '_' + GlUt_Constants.STATUSAPINAME;
            
            if(fieldProp.fieldName == GlUt_Constants.JOBTYPEAPINAME)
                fieldProp.fieldLabel = GlUt_Constants.JOBTYPELABEL;
            if(fieldProp.fieldName == GlUt_Constants.SUBMITTEDBYAPINAME)
                fieldProp.fieldLabel = GlUt_Constants.SUBMITTEDBYLABEL;
            if(fieldProp.fieldName == GlUt_Constants.TOTALRECORDSAPINAME)
                fieldProp.fieldLabel = GlUt_Constants.TOTALRECORDSLABEL;
            if(fieldProp.fieldName == GlUt_Constants.JOBENDTIMEAPINAME)
                fieldProp.fieldLabel = GlUt_Constants.JOBENDTIMELABEL;
            fieldPropertiesFinal.add(fieldProp);            
        }
        
        GLAp_FieldProps viewButton = new GLAp_FieldProps();
        viewButton.isFLSVisible = true;
        viewButton.isEncrypted = false;
        viewButton.isEditable = false; 
        viewButton.isRequired = false;
        viewButton.fieldName = System.Label.GlAp_ViewReportLabel;
        viewButton.fieldLabel = GlUt_Constants.VIEWREPORTLABEL;        
        viewButton.buttonField = true;
        viewButton.transformField = true;
        viewButton.parentObject = System.Label.GlAp_ViewReportLabel + '_' + GlUt_Constants.STATUSAPINAME;
        fieldPropertiesFinal.add(viewButton);
        
        return fieldPropertiesFinal;
    }
    
    /**********************************************************************************************
    @author        ECHO: Ankit Gangwani
    @date          23 August 2018
    @param         none
    @return        List<GLAp_FieldProps>
    @description   This method returns the field properties for each of the fields that are
                   to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static String getSfdcBaseUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    /**********************************************************************************************
    @author        ECHO: Ankit Gangwani
    @date          23 August 2018
    @param         none
    @return        List<BlAp_CombinedRecord>
    @description   
    **********************************************************************************************/
    @AuraEnabled    
    public static ResponseHandler getHerokuJobStatusRecords(String fromDate, String toDate) {
        
        List<String> fromDateList = fromDate.split('T');
        List<String> toDateList = toDate.split('T');        
        
        DateTime dt1 = Date.valueOf(fromDateList[0]);
        DateTime dt2 = Date.valueOf(toDateList[0]);
        
        ResponseHandler objResponseHandler = new ResponseHandler();
        try{        
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTING + DEBUG);
            // Combined record to display the records in the table
            List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
            
            // Initialise the HerokuResponseContainer
            List<HerokuResponseContainer> herokuResponse = new List<HerokuResponseContainer>();
            
            Set<String> herokuIds = new Set<String>();
            Map<Id,HerokuResponseContainer> mapOfHerokuId2CronDetails = new Map<Id,HerokuResponseContainer>();
            String endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_STATUS;
            String urlParams = '?fromdate=' + dt1.format('dd-MM-yyyy') + '&todate=' + dt2.format('dd-MM-yyyy');
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(endPoint, urlParams, 2000);
            String frequency = '';
            // handle response
            if (response.getStatusCode() == 200 && response.getBody() != null) {
                objResponseHandler.isSuccess = true;
                objResponseHandler.message = response.getBody();
                System.debug(DEBUG +  '!!Success!! Heroku Batch Jobs (GET)');
                System.debug(DEBUG +  'response.getBody(): ' + response.getBody());
                herokuResponse = (List<HerokuResponseContainer>) System.JSON.deserialize(response.getBody(), List<HerokuResponseContainer>.class);
                system.debug('herokuResponse status : ' + herokuResponse);
                
                
                for(HerokuResponseContainer herokuRes : herokuResponse){
                    frequency = '';
                    if(herokuRes.jobCron != null){
                        List<String> cronLists = herokuRes.jobCron.split(' ');
                        if(cronLists != null && !cronLists.isEmpty()){
                            if(cronLists[5] != null && cronLists[5] != '?' && cronLists[5] != '*')
                                frequency = System.Label.VmDr_WeeklyLabel;
                            if(cronLists[3] != null && cronLists[3] != '?' && cronLists[3] != '*')
                                frequency = System.Label.VmDr_MonthlyLabel;
                            if((cronLists[3] != null && (cronLists[3] == '?' || cronLists[3] == '*')) && 
                               (cronLists[5] != null && (cronLists[5] == '?' || cronLists[5] == '*')))
                                frequency = System.Label.VmDr_DailyLabel;
                        }
                    }
                    
                    System.debug('herokuRes iteration = '+herokuRes);
                    BlAp_CombinedRecord combRecord = new BlAp_CombinedRecord();
                    combRecord.uniqueId = herokuRes.JobInstanceId;
                    combRecord.isSelected = false;
                    combRecord.objectMap = new Map<String, sObject>();
                    
                    Map<string, string> jobTypeMap  = new Map<string, string>();
                    jobTypeMap.put(GlUt_Constants.JOBTYPEAPINAME,herokuRes.JobType != null ? herokuRes.jobType : '');
                    
                    Map<string, string> submittedByMap = new Map<string, string>();
                    submittedByMap.put(GlUt_Constants.SUBMITTEDBYAPINAME,herokuRes.SubmittedBy != null ? herokuRes.SubmittedBy : '');
                    
                    Map<string, string> totalRecordMap  = new Map<string, string>();
                    totalRecordMap.put(GlUt_Constants.TOTALRECORDSAPINAME,herokuRes.JobSize);
                    
                    Map<String,String> successRecords = new Map<String,String>();
                    successRecords.put(GlUt_Constants.SUCCESSAPINAME, herokuRes.Success);
                    
                    Map<String,String> failureRecord = new Map<String,String>();
                    failureRecord.put(GlUt_Constants.FAILUREAPINAME, herokuRes.Failure);
                    
                    Map<String,String> jobEndTimeMap = new Map<String,String>();
                    jobEndTimeMap.put(GlUt_Constants.JOBENDTIMEAPINAME, herokuRes.JobEndTime);
                    
                    Map<String,String> frequencyMap= new Map<String,String>();
                    //frequencyMap.put(GlUt_Constants.FREQUENCYAPINAME, herokuRes.Frequency != null ? herokuRes.Frequency : '');
                    frequencyMap.put(GlUt_Constants.FREQUENCYAPINAME, frequency != '' ? frequency : herokuRes.Frequency);
                    
                    Map<String,String> statusMap= new Map<String,String>();
                    statusMap.put(GlUt_Constants.STATUSAPINAME, herokuRes.Status != null ? herokuRes.Status : '');
                    
                    combRecord.transformFieldMap = new Map<string,Map<string, string>>();
                    combRecord.transformFieldMap.put(GlUt_Constants.JOBTYPEAPINAME      + '_' + GlUt_Constants.STATUSAPINAME,   jobTypeMap);
                    combRecord.transformFieldMap.put(GlUt_Constants.SUBMITTEDBYAPINAME  + '_' + GlUt_Constants.STATUSAPINAME,   submittedByMap);
                    combRecord.transformFieldMap.put(GlUt_Constants.TOTALRECORDSAPINAME + '_' + GlUt_Constants.STATUSAPINAME,   totalRecordMap);
                    combRecord.transformFieldMap.put(GlUt_Constants.SUCCESSAPINAME      + '_' + GlUt_Constants.STATUSAPINAME,   successRecords);
                    combRecord.transformFieldMap.put(GlUt_Constants.FAILUREAPINAME      + '_' + GlUt_Constants.STATUSAPINAME,   failureRecord);
                    combRecord.transformFieldMap.put(GlUt_Constants.JOBENDTIMEAPINAME   + '_' + GlUt_Constants.STATUSAPINAME,   jobEndTimeMap);
                    combRecord.transformFieldMap.put(GlUt_Constants.FREQUENCYAPINAME    + '_' + GlUt_Constants.STATUSAPINAME,   frequencyMap);
                    combRecord.transformFieldMap.put(GlUt_Constants.STATUSAPINAME       + '_' + GlUt_Constants.STATUSAPINAME,   statusMap);
                    
                    combinedList.add(combRecord);
                    
                }    
                
                objResponseHandler.combinedList = combinedList;
                // error response
            } else {
                objResponseHandler.isSuccess = false;
                objResponseHandler.message = response.getBody();
                System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());
            }            
       }
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        return objResponseHandler;        
    }
}