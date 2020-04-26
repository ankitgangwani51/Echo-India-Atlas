/******************************************************************************
@author         Echo: Sudhir Kumar
@date           25-May-2018
@description    Handler for PDF Request trigger : AT-2466

******************************************************************************/

public with sharing class GlUt_PDFGenerationResultHandler  extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_PDFGenerationResultHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private list<Task> listPDFGenerationResultTask  ;
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           25-May-2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        
        try {
            if (inputParam.isInsert && inputParam.isAfter) {
                createTask(inputParam.newmap) ;
            }
        } catch(Exception ex) {
            GlUt_Logger.logException(ex);
        } finally {
            // DML Operation on the related records
            if(listPDFGenerationResultTask != null && !listPDFGenerationResultTask.isEmpty()) {        // create tasks
                listPDFGenerationResultTask = (List<Task>) GlUt_FieldSecurity.cleanseFields(listPDFGenerationResultTask, false);
                Database.insert(listPDFGenerationResultTask) ;
                system.debug('listPDFGenerationResultTask3=> ' + listPDFGenerationResultTask);
            }
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           24-May-2018
    @param          Map<ID, SObject> pgrMap
    @description    This method creates a task for each PDFGenerationResult record
    *******************************************************************************/
    
    public void createTask(Map<Id, SObject> pgrMap) {
        listPDFGenerationResultTask = new list<Task>() ;
        for(PDFGenerationResult__c oPDFGenerationResult : [SELECT Id, PDFFilename__c, PDFRequest__c, PDFRequest__r.CreatedById,  PDFRequest__r.Contact__c, 
                                                           PDFRequest__r.BillingContract__c, PDFRequest__r.Account__c, DataXMLFileName__c 
                                                           FROM PDFGenerationResult__c WHERE Id IN: pgrMap.keySet()]) {
            Task oTask = new Task(Subject = GlUt_APIConstantsPDFGenerationResult.TASKSUBJECT, 
                                  Priority = GlUt_APIConstantsPDFGenerationResult.TASKNORMALPRIORITY,
                                  WhoId = oPDFGenerationResult.PDFRequest__r.Contact__c,
                                  S3Filename__c = oPDFGenerationResult.PDFFilename__c, 
                                  OwnerId = oPDFGenerationResult.PDFRequest__r.CreatedById) ;
           if(oPDFGenerationResult.PDFRequest__r.BillingContract__c != null) {
                oTask.WhatId = oPDFGenerationResult.PDFRequest__r.BillingContract__c ;
           } else if(oPDFGenerationResult.PDFRequest__r.Account__c != null) {
                oTask.WhatId = oPDFGenerationResult.PDFRequest__r.Account__c ;
           }
           

           listPDFGenerationResultTask.add(oTask) ; 
           system.debug(DEBUG + 'listPDFGenerationResultTask1=> ' + listPDFGenerationResultTask);                                                     
        }
    }
}