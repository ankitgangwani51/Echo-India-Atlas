/******************************************************************************
@author         Echo: Vivek Sethi
@date           30 May 2018
@description    Handler for BillEvent trigger
@revision:    25-06-2018 - Swati -- AT-2947, added method updatePDFrequest
*******************************************************************************/
public with sharing class GlUt_BillEventHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_BillEventHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<BillEvent__c>   billUpdatedEventList = new List<BillEvent__c>();
    
    // List of the PDF request records that will be updated by this trigger -- AT-2947
    List<PDFRequest__c> PDFRequestListToUpdate;
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           30 May 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            
            // initialise PDF request records List -- AT-2947
            PDFRequestListToUpdate = new List<PDFRequest__c>();
            
            if (inputParam.isInsert && inputParam.isAfter) {
                updateBillEventStatus(inputParam.newMap);
                updatePDFrequest(inputParam.newMap); //-- AT-2947
            }
            if (inputParam.isInsert && inputParam.isBefore) {
                
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        } finally {
            
            // update the related records -- AT-2947
            if(!PDFRequestListToUpdate.isEmpty()){
                PDFRequestListToUpdate = (List<PDFRequest__c>) GlUt_FieldSecurity.cleanseFields(PDFRequestListToUpdate, false);
                update PDFRequestListToUpdate;
            }            
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           30 May 2018
    @param          Map<Id, sObject>  billEventMap
    @description    Updating the status of the Bill Event 'Pending' records to ‘Replaced’ for the same contract.
    @return         void
    *******************************************************************************/
    private void updateBillEventStatus(Map<Id, sObject> billEventMap) {
        Set<Id> contractIdSet = new Set<Id>();
        List<BillEvent__c>  billEventList = new List<BillEvent__c>();
        for (BillEvent__c objBillEvent : (List<BillEvent__c>)billEventMap.values()) {
            if(objBillEvent.BillingContract__c != null){
                contractIdSet.add(objBillEvent.BillingContract__c);
            }
        }
        if(contractIdSet.size() > 0){
            billEventList = [SELECT Id, 
                             Status__c
                             FROM BillEvent__c 
                             WHERE BillingContract__c IN: contractIdSet
                             AND Status__c = :GlUt_Constants.BILLEVENTSTATUS
                             AND Id NOT IN :billEventMap.keySet()];
        }
        
        if (!billEventList.isEmpty()) {
            for (BillEvent__c objBillEvent : billEventList) {
                objBillEvent.Status__c = GlUt_Constants.BILLEVENTUPDATEDSTATUS; 
                billUpdatedEventList.add(objBillEvent);
            }
            billUpdatedEventList = (List<BillEvent__c>) GlUt_FieldSecurity.cleanseFields(billUpdatedEventList, false);
            update billUpdatedEventList;
        }
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           21 June 2018
    @param          Map<Id, sObject>  billEventMap
    @description    AT-2947, Update the status of PDFRequest record from Pending to Cancelled 
    @return         void 
    *******************************************************************************/
    private void updatePDFrequest(Map<Id, sObject> billEventMap) {      
        Set<Id> contractIdSet = new Set<Id>();   
        List<PDFRequest__c>  PDFRequestList = new List<PDFRequest__c>();
        
        for (BillEvent__c objBillEvent : (List<BillEvent__c>)billEventMap.values()) {           
            if( objBillEvent.EventType__c == GlUt_APIConstantsBillEvent.PAYMENTPLANBILLEVENTTYPE && objBillEvent.Status__c == GlUt_APIConstantsBillEvent.PENDINGBILLEVENTSTATUS &&
                objBillEvent.BillingContract__c != null){
                   contractIdSet.add(objBillEvent.BillingContract__c);
               }            
        }
        
        if(contractIdSet.size() > 0){
            PDFRequestList = [SELECT Id,
                              Status__c
                              FROM PDFRequest__c 
                              WHERE BillingContract__c IN: contractIdSet
                              AND CorrespondenceType__c = :GlUt_APIConstantsPDFRequest.PAYMENTPLANNOTIFICATION //'Payment Plan Notification'
                              AND SourceType__c =  :GlUt_APIConstantsPDFRequest.XMLSOURCETYPE //'Data Transfer XML'
                              AND Status__c = :GlUt_APIConstantsPDFRequest.PENDINGSTATUS //'Pending'
                             ]; 
        }
        
        if (!PDFRequestList.isEmpty() && PDFRequestList != null) {
            for(PDFRequest__c objPDFRequest : PDFRequestList){
                objPDFRequest.Status__c = GlUt_APIConstantsPDFRequest.CANCELSTATUS; //'Cancelled'
                PDFRequestListToUpdate.add(objPDFRequest);
            }   
        }    
    }
}