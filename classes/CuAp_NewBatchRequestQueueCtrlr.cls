/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		29 Jun 2018
@description 	Component controller for new batch request queue lightning component
Revision(s)		
*******************************************************************************/
public with sharing class CuAp_NewBatchRequestQueueCtrlr {
	
	private static final String CLASS_NAME = 'CuAp_NewBatchRequestQueueCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		28 Jun 2018
	@param			Id - batch process Id
	@return			Id - the Id of the batch request queue record
	@description 	creates a new batch request record
	*******************************************************************************/
    @AuraEnabled
    public static Id createDefaultBatchRequest(Id batchProcessId) {
    	
        BatchRequestQueue__c batchRequestQueue = new BatchRequestQueue__c(
        																	BatchProcess__c = batchProcessId, 
        																	Priority__c = Label.CuAp_BatchProcessPriorityHigh, 
        																	SendEmailNotification__c = true, 
        																	Status__c = Label.CuAp_BatchProcessStatusInitialised, 
        																	NotificationUser__c = UserInfo.getUserId() 
        																);
        
        try {  
            if(batchRequestQueue != null){
                batchRequestQueue = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(batchRequestQueue, false);
                insert batchRequestQueue;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return batchRequestQueue.Id;
    }
    
}