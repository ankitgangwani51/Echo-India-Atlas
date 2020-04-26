/***************************************************************************************************
@author        Echo : Vivek Sethi
@date          08-May-2018
@description:  This is helper class used by Available Bundle object trigger  
@group         TriggerHelper
Revision(s)   
*******************************************************************************************************/
public  class GlUt_ContentDocumentLinkHandler extends GlUt_TriggerHandlerBase {
    
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_ContentDocumentLinkHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    
    /**********************************************************************************************
    @author        Echo : Vivek Sethi
    @date          08-May-2018
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void  MainEntry(GlUt_TriggerHandlerObj inputParam){
        try{
            if( inputParam.isInsert && inputParam.isBefore ){
                ContentDocumentLinkVisibility(inputParam.newlist);
            }
            if( inputParam.isInsert && inputParam.isAfter ){ 
                // calling the processBatchFileImport method
                processBatchFileImport(inputParam.newlist);
            }
            if( inputParam.isUpdate && inputParam.isBefore ){
      
            }
            if( inputParam.isUpdate && inputParam.isAfter ){
               
            }  
            if( inputParam.isDelete && inputParam.isBefore ){
                
            }
            if( inputParam.isDelete && inputParam.isAfter ){
                
            }  
        }
        catch (Exception ex){
            system.debug('Line Number:=' + ex.getLineNumber());
            system.debug('Line Number:=' + ex.getMessage());
            system.debug('Line Number:=' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);
        }
        
        finally{   
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /********************************************************************************************
    @author        Echo : Vivek Sethi
    @date          08-May-2018
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to set to ContentDocumentLink Visibility to 'All Users' for community
    **********************************************************************************************/ 
    public  void ContentDocumentLinkVisibility(List<SObject> newlist) {
        
        if(!newlist.isEmpty()){
            for(ContentDocumentLink cdl : (List<ContentDocumentLink>)newlist){
                cdl.Visibility = GlUt_Constants.ALLUSERS ;
                //     cdl.ShareType = GlUt_Constants.SHARETYPE;
            }
        }
    }
    
    /********************************************************************************************
    @author        Echo : Mohit Tayal
    @date          09-May-2018
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to process file import of batch class if the content document
                   file is csv and the batch process operation associated with the content document link
                   record is import.
    **********************************************************************************************/ 
    public static void processBatchFileImport(List<SObject> newlist) {
        
        system.debug('cdlh newlist = '+newlist);
        Map<ID,ContentDocumentLink> contentDocumentIdAndRecordMap = new Map<ID,ContentDocumentLink>();
        
        if(!newlist.isEmpty()){
            for(ContentDocumentLink cdl : (List<ContentDocumentLink>)newlist){
                contentDocumentIdAndRecordMap.put(cdl.ContentDocumentId,cdl);
            } 
        }
        
        system.debug('cdlh contentDocumentIdAndRecordMap = '+contentDocumentIdAndRecordMap);
        List<ContentDocument> lstContentDocument = [SELECT Id, FileExtension FROM ContentDocument WHERE Id IN :contentDocumentIdAndRecordMap.keySet()];
        system.debug('cdlh lstContentDocument = '+lstContentDocument);
        for(ContentDocument objContentDocument : lstContentDocument){
            // 31/12/18 Ankit Gangwani, Added xml extension condition for temporary, need to discuss
            if(objContentDocument.FileExtension != GlUt_Constants.FILEEXTENSIONCSV && objContentDocument.FileExtension != GlUt_Constants.FILEEXTENSIONXML){
                contentDocumentIdAndRecordMap.remove(objContentDocument.Id);
            }
        }
        
        system.debug('cdlh contentDocumentIdAndRecordMap = '+contentDocumentIdAndRecordMap);
        List<ContentDocumentLink> lstContentDocLink = contentDocumentIdAndRecordMap.values();
        
        system.debug('cdlh lstContentDocLink = '+lstContentDocLink);
        Map<Id,List<ContentDocumentLink>> batchReqQueueIdAndListCDLRecord = new Map<Id,List<ContentDocumentLink>>();
        
        if(!lstContentDocLink.isEmpty()){
            for(ContentDocumentLink cdl : lstContentDocLink){
                if(!batchReqQueueIdAndListCDLRecord.containsKey(cdl.LinkedEntityId)){
                    batchReqQueueIdAndListCDLRecord.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
                }
                batchReqQueueIdAndListCDLRecord.get(cdl.LinkedEntityId).add(cdl);            
            }
            system.debug('cdlh batchReqQueueIdAndListCDLRecord = '+batchReqQueueIdAndListCDLRecord);
            
            List<BatchRequestQueue__c> lstBatchReqQueue = [SELECT Id, BatchProcess__c, BatchProcess__r.Operation__c, BatchProcess__r.BatchClass__c  FROM BatchRequestQueue__c WHERE Id IN :batchReqQueueIdAndListCDLRecord.keySet()];
            
            system.debug('cdlh lstBatchReqQueue = '+lstBatchReqQueue);
            Map<Id,List<ContentDocumentLink>> batchProcessIdAndLstCDLRecord = new Map<Id,List<ContentDocumentLink>>();
            
            if(!lstBatchReqQueue.isEmpty()){
                for(BatchRequestQueue__c objBatchRequestQueue : lstBatchReqQueue){
                    if(objBatchRequestQueue.BatchProcess__r.Operation__c == GlUt_Constants.BATCHPROCESSOPERATION){
                        if(!batchProcessIdAndLstCDLRecord.containsKey(objBatchRequestQueue.BatchProcess__c)){
                            batchProcessIdAndLstCDLRecord.put(objBatchRequestQueue.BatchProcess__c, new List<ContentDocumentLink>());
                        }
                        batchProcessIdAndLstCDLRecord.get(objBatchRequestQueue.BatchProcess__c).addAll(batchReqQueueIdAndListCDLRecord.get(objBatchRequestQueue.Id));  
                    }
                }
                system.debug('cdlh batchProcessIdAndLstCDLRecord = '+batchProcessIdAndLstCDLRecord);
                
                List<BatchRequestQueue__c> lstFileImportNotImplmntedForBRQ = new List<BatchRequestQueue__c>();
                
                for(BatchRequestQueue__c objBatchRequestQueue : lstBatchReqQueue){
                    if(batchProcessIdAndLstCDLRecord.containsKey(objBatchRequestQueue.BatchProcess__c)){
                        String TypeName = objBatchRequestQueue.BatchProcess__r.BatchClass__c;
                        System.debug('cdlh TypeName = '+TypeName);
                        Type t = Type.forName(GlUt_NamespacePrefix.getNamespacePrefix().replace('__',''),TypeName);
                        GlBt_BatchProcess batchfunction = (GlBt_BatchProcess)t.newInstance();
                        try{
                            batchfunction.initialise(objBatchRequestQueue);
                            List<BatchError__c> lstBatchError = batchfunction.fileImport(batchProcessIdAndLstCDLRecord.get(objBatchRequestQueue.BatchProcess__c));
                        }
                        catch(Exception e){
                            if(e.getMessage() == GlUt_Constants.NOTIMPLEMENTEDERROR){
                                objBatchRequestQueue.Status__c = GlUt_Constants.ERRORS;
                                lstFileImportNotImplmntedForBRQ.add(objBatchRequestQueue);
                            }
                        }
                    }
                }
                
                if(!lstFileImportNotImplmntedForBRQ.isEmpty()){
                     lstFileImportNotImplmntedForBRQ = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(lstFileImportNotImplmntedForBRQ, false);
                    Database.update(lstFileImportNotImplmntedForBRQ);
                }
            }
        }
    }    
}