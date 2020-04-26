/******************************************************************************
@author         Echo:Vivek Sethi
@date           27 June 2018
@description    Component controller for Direct Debit Request Export lightning component
@revesion 		Changes by Dependra Singh - Security Review - 14-09-2018
*******************************************************************************/
public with sharing class PyAp_DirectDebitRequestExportCtrlr {
    
    private static final String CLASS_NAME = 'PyAp_DirectDebitRequestExportCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author    	    Echo: Ankit Gangwani
    @date      		28 Jan 2019
    @param			String exportInstalmentUpto, Id batchProcessId
    @return			Boolean
    @description 	creates a new batch request queue record
    *******************************************************************************/
    @AuraEnabled
    public static Boolean createDefaultBatchRequest(String exportInstalmentUpto , Id batchProcessId) {
        Savepoint sp = Database.setSavepoint();
        BatchRequestQueue__c objBRQ = new BatchRequestQueue__c();
        String convert2Json;
        Boolean isBrqCreate = false;
        
        try{
            PyPr_DirectDebitRequestParameters directDebitRequestWrapper = new PyPr_DirectDebitRequestParameters();
            directDebitRequestWrapper.requestDate = Date.valueOf(exportInstalmentUpto);
            convert2Json = Json.serialize(directDebitRequestWrapper);
            if(!string.isBlank(convert2Json)){
 
                objBRQ = GlUt_BatchRequestQueueUtilities.createBatchRequestQueue(convert2Json,false ,LoAp_Constants.HIGH,LoAp_Constants.DIRECTDEBITEXPORT, 
                                                                                 LoAp_Constants.IMPORTFROMFILEFALSE,LoAp_Constants.BATCHPROCESSOPERATION,
                                                                                 PyAp_Constants.BATCHPROCESSEXPORTBOOKCLASSNAME,UserInfo.getUserId(),
                                                                                 LoAp_Constants.INITIALISED, null);  
                if(objBRQ.Id != null){
                    isBrqCreate = true;
                } 
               
            }
        } catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }        
        return isBrqCreate;
    } 
}