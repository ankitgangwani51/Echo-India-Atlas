/******************************************************************************
@author         Echo: Swati Mathur
@date           22 May 2018
@description    Component controller for Requested Reading Export lightning component
@revesion 		Changes by Dependra Singh - Security Review - 17-09-2018
*******************************************************************************/
public with sharing class LoAp_RequestedReadingExportCtrlr {
    private static final String CLASS_NAME = 'LoAp_RequestedReadingExportCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final List<String> batchProcessFields = new List<String> {GlUt_APIConstantsBatchProcess.ID};    
        /******************************************************************************
@author         Echo: Swati Mathur
@date           08 May 2018
@return         none
@description    create batch process and batch request queue record
*******************************************************************************/
        @AuraEnabled
        Public static void createBRQ(){            
            BatchRequestQueue__c objBRQ;
            Savepoint sp = Database.setSavepoint();
            //Changes by Dependra Singh - Security Review - 17-09-2018-AT-3696
            try{       
                objBRQ = GlUt_BatchRequestQueueUtilities.createBatchRequestQueue(null,true,LoAp_Constants.HIGH,null,null,LoAp_Constants.BATCHPROCESSOPERATION,
                                                                                 LoAp_Constants.BATCHPROCESSEXPORTREQUESTEDREADINGCLASSNAME,UserInfo.getUserId(),
                                                                                 LoAp_Constants.INITIALISED,null); 
            }
            catch (exception e){
                GlUt_Logger.logException(e);
                Database.rollback(sp); 
                throw new AuraHandledException(e.getMessage());                      
            } finally {   
                GlUt_Logger.writeLogsToDatabase();
            }
        }
}