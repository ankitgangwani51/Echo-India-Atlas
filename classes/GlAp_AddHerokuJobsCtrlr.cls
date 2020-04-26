/******************************************************************************
@author         Echo : Ankit Gangwani
@date           21 August 2018
@description    Component controller for Add Heroku Jobs
******************************************************************************/
public class GlAp_AddHerokuJobsCtrlr {
    
    @TestVisible private static List<String> jobTypeList;
    
    private static final String CLASS_NAME = 'GlAp_AddHerokuJobsCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 24 August 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<String> getJobTypeValues() {
        try {
            
            // Retrieve the Job Type Picklist values from Custom Setting HerokuBatchJobType__c
            Map<String,HerokuBatchJobType__c> mapOfHerokuBatchDetails = HerokuBatchJobType__c.getAll();
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();            
            
            List<String> jobTypeLists = new List<String>{''};                
            for(String str: mapOfHerokuBatchDetails.keySet()){
                jobTypeLists.add(str);
            }
            jobTypeLists.sort();
            return jobTypeLists;
        }catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
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
    public static ResponseHandler calloutToHerokuPUT(String activeTab, String cronMaker, String jobType, Integer herokuId){
        ResponseHandler objResponseHandler = new ResponseHandler();
        try {
            String payload;
            String endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_JOB;
            if(activeTab != System.Label.VmDr_ImmediateLabel){
                payloadParam5 objPayloadParam5 = new payloadParam5();
                objPayloadParam5.id = herokuId;
                objPayloadParam5.JobCron = cronMaker;
                objPayloadParam5.JobType = jobType;
                objPayloadParam5.SubmittedBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); 
                payload = Json.serialize(objPayloadParam5);
            }
            else{
                payloadParam1 objPayloadParam1 = new payloadParam1();
                objPayloadParam1.id = herokuId;
                objPayloadParam1.JobType = jobType;
                objPayloadParam1.SubmittedBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); 
                payload = Json.serialize(objPayloadParam1);
            }
            // make the callout
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(endPoint, 2000, 'application/json', payload,'PUT');
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
    @author      : Echo: Ankit Gangwani
    @date        : 28 August 2018
    @return      : void
    @description : 
    **********************************************************************************************/
    @AuraEnabled
    public static ResponseHandler calloutToHerokuPOST(String activeTab, String cronMaker,String jobType, String toDate){
        ResponseHandler objResponseHandler = new ResponseHandler();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            
            String payload;
            String endPoint;
            
            if(jobType == System.Label.GlAp_AccrualsLabel){
                endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_IMMEDIATE;
                payloadParam2 objPayloadParam2 = new payloadParam2();
                objPayloadParam2.JobType = jobType;
                objPayloadParam2.SubmittedBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); 
                objPayloadParam2.EndDate = Date.valueOf(toDate);
                payload = Json.serialize(objPayloadParam2);                               
            }else if (jobType == System.Label.GlAp_AnnualAccrualsLabel){ //UL-610, Ankit, 06/03/2019
                endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_IMMEDIATE;
                payloadParam4 objPayloadParam4 = new payloadParam4();
                objPayloadParam4.JobType = jobType.replace(' ','');
                objPayloadParam4.SubmittedBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); 
                payload = Json.serialize(objPayloadParam4);
                
            }else{                
                if(activeTab != System.Label.VmDr_ImmediateLabel){
                    endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_JOB;
                    payloadParam3 objPayloadParam3 = new payloadParam3();
                    objPayloadParam3.JobCron = cronMaker;
                    objPayloadParam3.JobType = jobType;
                    objPayloadParam3.SubmittedBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); 
                    payload = Json.serialize(objPayloadParam3);
                }else{   
                    endPoint = BlUt_HerokuWebservices.HEROKU_BATCH_IMMEDIATE;
                    payloadParam4 objPayloadParam4 = new payloadParam4();
                    objPayloadParam4.JobType = jobType;
                    objPayloadParam4.SubmittedBy = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(); 
                    payload = Json.serialize(objPayloadParam4);
                }
            }
            // make the callout
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(endPoint, 2000, 'application/json', payload);
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
    
    public class payloadParam1 {
        public Integer id;
        public String JobType;    
        public String SubmittedBy; 
    }
    
    public class payloadParam2 {
        public String JobType;    
        public String SubmittedBy; 
        public Date EndDate;
    }
    
    public class payloadParam3 {
        public String JobCron;  
        public String JobType;    
        public String SubmittedBy; 
    }
    
    public class payloadParam4 {         
        public String JobType;    
        public String SubmittedBy;         
    }
    
    public class payloadParam5{
        public Integer id;        
        public String JobCron;  
        public String JobType; 
        public String SubmittedBy; 
    }
}