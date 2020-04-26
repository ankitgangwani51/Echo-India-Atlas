/******************************************************************************
@author         Echo: Dependra Singh
@date           17-Sept-2018
@description    Class for Batch Request Queue Utilities 
*******************************************************************************/
public class GlUt_BatchRequestQueueUtilities {
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           17-Sept-2018
    @param          string strJson,Boolean isSendEmailNotification, string strPriority, string strRequestName, string strImportFromFile
    @return         BatchRequestQueue__c
    @description    Method is used to create Batch request queue object. 
    **********************************************************************************************/   
    public static BatchRequestQueue__c createBatchRequestQueue(string strJson,Boolean isSendEmailNotification, string strPriority, string strRequestName, 
                                                               string strImportFromFile,string strBatchProcessOperation, string strbatchProcessClassName, 
                                                               Id idUser, string strStatus, string brqType) {
        BatchRequestQueue__c objBatchRequestQueue;
        BatchRequestQueue__c  objBatchReqQueue;
        if(string.isNotBlank(strBatchProcessOperation) && string.isNotBlank(strbatchProcessClassName)){
            List<BatchProcess__c> lstBatchProcess = [SELECT Id FROM BatchProcess__c WHERE Operation__c =: strBatchProcessOperation 
                                               AND BatchClass__c =:strbatchProcessClassName Limit 1]; 
            if(lstBatchProcess != null && lstBatchProcess.size() > 0){
                objBatchRequestQueue = new BatchRequestQueue__c();
                if(!string.isBlank(strJson)){
                    objBatchRequestQueue.Parameters__c = strJson;
                }
                objBatchRequestQueue.Status__c = strStatus;
                objBatchRequestQueue.Priority__c =  string.isNotBlank(strPriority) ? strPriority : LoAp_Constants.LOW;
                objBatchRequestQueue.SendEmailNotification__c = isSendEmailNotification;
                objBatchRequestQueue.RequestName__c =  string.isNotBlank(strRequestName) ? strRequestName : null;
                objBatchRequestQueue.ImportFromFile__c = string.isNotBlank(strImportFromFile) ? strImportFromFile : null;
                objBatchRequestQueue.BatchProcess__c = lstBatchProcess[0].Id;
                objBatchRequestQueue.NotificationUser__c = idUser;
                if(brqType != null)                            //AT-4188
                    objBatchRequestQueue.Type__c = brqType;   //AT-4188
                objBatchReqQueue = (BatchRequestQueue__c)GlUt_FieldSecurity.cleanseFields(objBatchRequestQueue, false); 
            }
            if(objBatchReqQueue != null){
                insert objBatchReqQueue;
            }
        }
        return objBatchReqQueue;
    }
}