/******************************************************************************
@author         Echo:Vivek 
@date           07 Dec 2018
@description    Component controller for Entitlement Renewal Lightning component
Revision(s)     
*******************************************************************************/
public with sharing class LoAp_EntitlementRenewalCtrlr {
    private static final String CLASS_NAME = 'LoAp_EntitlementRenewalCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

	/******************************************************************************
	@author    	    Echo:Vivek 
	@date      		07 Dec 2018
	@param			Id - batch process Id
	@return			Id - the Id of the batch request queue record
	@description 	creates a new batch request record
	*******************************************************************************/
    @AuraEnabled
    public static Boolean createDefaultBatchRequest(String renewalDate , Integer seasonAllocation, Id batchProcessId) {
        
        LoBt_EntitlementRenewalWrapper entitlementRenewalWrapper = new LoBt_EntitlementRenewalWrapper();
        entitlementRenewalWrapper.RenewalDate = Date.valueOf(renewalDate);
        entitlementRenewalWrapper.SeasonalAllocation = seasonAllocation;
        
        BatchRequestQueue__c batchRequestQueue = new BatchRequestQueue__c(
            BatchProcess__c = batchProcessId, 
            Priority__c = Label.CuAp_BatchProcessPriorityHigh, 
            Parameters__c = JSON.serialize(entitlementRenewalWrapper),
            SendEmailNotification__c = true, 
            Status__c = Label.CuAp_BatchProcessStatusInitialised, 
            NotificationUser__c = UserInfo.getUserId(),
            Type__c  =  LoBt_Constants.ENTITLEMENTRENEWAL
        );
        
        try {  
            insert batchRequestQueue;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return true;
    }
}