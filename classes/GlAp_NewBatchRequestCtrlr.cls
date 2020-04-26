/******************************************************************************
@author         Echo:Vivek 
@date           30 Nov 2018
@description    Component controller for New Batch Request Lightning component
Revision(s)     
*******************************************************************************/
public with sharing class GlAp_NewBatchRequestCtrlr {
	private static final String CLASS_NAME = 'GlAp_NewBatchRequestCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
	/******************************************************************************
	@author    	    Echo:Vivek 
	@date      		30 Nov 2018
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
         	insert batchRequestQueue;

        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return batchRequestQueue.Id;
    }

}