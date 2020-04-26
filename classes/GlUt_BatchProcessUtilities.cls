/******************************************************************************
@author    		Echo: Andrew Edge
@date      		29 March 2018
@description 	Class for Batch Process utilities for Database.Batchable Classes
*******************************************************************************/
public with sharing class GlUt_BatchProcessUtilities {
    
    private static final String CLASS_NAME = 'GlUt_BatchProcessUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

	
    /**********************************************************************************************
    @author        Echo: Andrew Edge
    @date          19-Mar-2017
    @param         ID BatchRequestQueue__c ID
    			   String new status for the request queue record
    @return        void
    @description   updates the associated BatchRequestQueue__c status
    			   Note this includes a DML operation as the status changes as throughout a batch process
    **********************************************************************************************/	
	public static void updateBatchStatus(Id requestID, String status) {
		
		List<BatchRequestQueue__c> brqList = [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE Id = :requestID];
		
		if(!brqList.isEmpty()) {
			for(BatchRequestQueue__c brq : brqList ){
				brq.Status__c = status;
			}
			
			update brqList;
		}			
	}   
    
    
    public static void sendNotificationEmail() {
    	
    }
}