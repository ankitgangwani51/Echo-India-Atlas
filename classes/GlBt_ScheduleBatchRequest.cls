/******************************************************************************
@author         Ankit Gangwani
@date           20 May 2018
@description    Scheduled Batch  Class For Batch Request Queue Records Creation
*******************************************************************************/
global class GlBt_ScheduleBatchRequest implements Schedulable{
    
    private final String batchClass;
    private static List<string> batchProcessFields;
    private static final String CLASS_NAME = 'GlBt_ScheduleBatchRequest';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        //Get Fields from the Batch Process Object
        batchProcessFields = new List<string>();
        batchProcessFields.add(GlUt_APIConstantsBatchProcess.ID);
        batchProcessFields.add(GlUt_APIConstantsBatchProcess.BATCHSIZEAPINAME);
        batchProcessFields.add(GlUt_APIConstantsBatchProcess.OWNERIDAPINAME);
    }
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			String batchClassName
    @description    Constructore for GlBt_ScheduleBatchRequest class
					AT-3957 - Dynamic SOQL for GlBt_ScheduleBatchRequest - Added Header (Security Review)
    *******************************************************************************/	
    global GlBt_ScheduleBatchRequest(String batchClassName){ 
        batchClass = batchClassName;
    }   
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
    @description    excecute method for Schedulable interface
					AT-3957 - Dynamic SOQL for GlBt_ScheduleBatchRequest - Added Header (Security Review)
							- Replaced Dynamic SOQL with static SOQL and added check on batchProcessList
                    AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
    *******************************************************************************/	
    global void execute(SchedulableContext sc){        
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<BatchProcess__c> batchProcessList = [SELECT Id FROM BatchProcess__c WHERE BatchClass__c =: batchClass] ;	// AT-3957
            if(batchProcessList != null && !batchProcessList.isEmpty()) {
                BatchRequestQueue__c objBatchReqQueue = new BatchRequestQueue__c();
                objBatchReqQueue.BatchProcess__c = batchProcessList[0].Id;
                objBatchReqQueue.Priority__c = LoAp_Constants.HIGH;
                objBatchReqQueue.SendEmailNotification__c = True;
                objBatchReqQueue.Status__c = LoAp_Constants.INITIALISED;
                objBatchReqQueue.NotificationUser__c = UserInfo.getUserId();
                objBatchReqQueue.Parameters__c = '';
                objBatchReqQueue = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(objBatchReqQueue, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert objBatchReqQueue;
            }
        } catch (exception e) { 
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
        
    }
}