/******************************************************************************
@author         Ankit Gangwani
@date           05 June 2018
@description    Test Class For GlAp_BatchRequestQueueCtrlr
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class GlAp_BatchRequestQueueCtrlr_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String BATCH_CLASS             = 'LoBt_ScheduledEstimates';
    private static final String ContentDocument			= 'ContentDocument';
    private static final String SHARETYPE				= 'V';
    private static final String TITLE					= 'test';
    private static List<string> batchReqQueueFieldlist;
    private static List<String> batchProcessFieldlist;
    private static List<String> contentDocumentFieldlist;
    private static List<String> contentDocumentLinkFieldlist;
    private static List<String> batchErrorList;
    private static List<String> readingUploadList;
    
    Static{
        //Get Fields from the Batch Request Queue Object
        batchReqQueueFieldlist = new List<string>();
        batchReqQueueFieldlist.add(GlUt_APIConstantsBatchRequestQueue.CREATEDDATEAPINAME);
        batchReqQueueFieldlist.add(GlUt_APIConstantsBatchRequestQueue.USERAPINAME);
        batchReqQueueFieldlist.add(GlUt_APIConstantsBatchRequestQueue.STATUSAPINAME);  
        
        batchProcessFieldlist = new List<String>();
        batchProcessFieldlist.add(GlUt_APIConstantsBatchProcess.ID);
        
        contentDocumentFieldlist = new List<String>();
        contentDocumentFieldlist.add(LoAp_Constants.Id);
        contentDocumentFieldlist.add(LoAp_Constants.Title);
        contentDocumentFieldlist.add(LoAp_Constants.ContentSize);
        contentDocumentFieldlist.add(LoAp_Constants.FileType);  
        
        contentDocumentLinkFieldlist = new List<String>();
        contentDocumentLinkFieldlist.add(LoAp_Constants.ContentDocumentId);
        
        batchErrorList = new List<String>();
        batchErrorList.add(GlUt_APIConstantsBatchError.ERRORDETAILSAPINAME);
        batchErrorList.add(GlUt_APIConstantsBatchError.OPERATINGRECORDIDAPINAME);
        
        readingUploadList = new List<String>();
        readingUploadList.add(GlUt_APIConstantsReadingUpload.SERIALNOAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGDATEAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGVALUEAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGSTATUSAPINAME);
    }
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          05 June 2018 
    @param         -
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        objUser.Email = EMAIL_ADDRESS;
        Database.insert(objUser); 
        
        //Create Batch Class record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS);
        Database.insert(objBatchProcess);
        
        BatchRequestQueue__c objBRQ = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBRQ.Status__c = LoAp_Constants.INITIALISED;
        objBRQ.BatchProcess__c = objBatchProcess.Id;
        objBRQ.NotificationUser__c = objUser.Id;        
        Database.insert(objBRQ);
        
        BatchError__c objBatchError = GlUt_FactoryData_Test.createBatchError(objBRQ.Id);
        Database.insert(objBatchError);
        
        ReadingUpload__c objReadingUpload = GlUt_FactoryData_Test.createReadingUpload(objBRQ.Id);
        Database.insert(objReadingUpload);
        
        ContentVersion document = new ContentVersion();
        document.Title = TITLE;
        document.VersionData = Blob.valueOf('5');
        document.PathOnClient = TITLE;        
        insert document;
        
        document = [select Id, ContentDocumentId from ContentVersion where Id = :document.Id];
       
        ContentDocumentLink objCDL = new ContentDocumentLink();
        objCDL.LinkedEntityId = objBRQ.Id;
        objCDL.ContentDocumentId = document.ContentDocumentId;
        objCDL.ShareType = SHARETYPE;
        insert objCDL;
        
    }    
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void getBatchRequestQueueDetails_Positive(){
        
        List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            fieldPropList = GlAp_BatchRequestQueueCtrlr.getBatchRequestQueueDetails(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME, LoAp_Constants.LoAp_EstimationSchedulingLABEL);            
            Test.stoptest();
            System.assert(fieldPropList.size() > 0);
        }
    }   
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    /*static testmethod void retrieveBatchReqQueueFieldPropDetails_Positive(){
        
        List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            fieldPropList = GlAp_BatchRequestQueueCtrlr.retrieveBatchReqQueueFieldPropDetails(batchReqQueueFieldlist);
            Test.stoptest();
            System.assert(fieldPropList.size() > 0);
        }
    }*/
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    /*static testmethod void retrieveBatchReqQueueFieldPropDetails_Negative(){
        
        List<String> brqList = new List<String>();
        List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>();        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            fieldPropList = GlAp_BatchRequestQueueCtrlr.retrieveBatchReqQueueFieldPropDetails(brqList);
            Test.stoptest();
            System.assert(fieldPropList.size() == 2);
        }
    }*/
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveBatchReqQueueRecords_Positive(){
        
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();
        List<BatchProcess__c> objBP = [SELECT Id, BatchClass__c FROM BatchProcess__c];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                combinedRecordList = GlAp_BatchRequestQueueCtrlr.retrieveBatchReqQueueRecords(batchReqQueueFieldlist, objBP[0].BatchClass__c);
                Test.stoptest();
                System.assert(combinedRecordList.size() > 0);
            } catch(Exception ex) {}
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveBatchReqQueueRecords_Negative(){
        
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();
        List<BatchProcess__c> objBP = [SELECT Id, BatchClass__c FROM BatchProcess__c];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            combinedRecordList = GlAp_BatchRequestQueueCtrlr.retrieveBatchReqQueueRecords(batchReqQueueFieldlist, '');
            Test.stoptest();
            System.assert(combinedRecordList.size() == 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveFieldPropDetails_ContentDocument(){
        
        List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            fieldPropList = GlAp_BatchRequestQueueCtrlr.retrieveFieldPropDetails(ContentDocument, contentDocumentFieldlist);
            Test.stoptest();
            System.assert(fieldPropList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveFieldPropDetails_BatchError(){
        
        List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            fieldPropList = GlAp_BatchRequestQueueCtrlr.retrieveFieldPropDetails(GlUt_APIConstantsBatchError.BATCHERRORAPINAME, batchErrorList);
            Test.stoptest();
            System.assert(fieldPropList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveFilesRecords(){
        
        List<BatchRequestQueue__c> brqList = [SELECT Id FROM BatchRequestQueue__c];
        Id BatchRequestQueueId = brqList[0].Id;
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            combinedRecordList = GlAp_BatchRequestQueueCtrlr.retrieveFilesRecords(ContentDocument, contentDocumentFieldlist, String.valueOf(BatchRequestQueueId));
            Test.stoptest();
            System.assert(combinedRecordList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveErrorRecords(){
        
        List<BatchRequestQueue__c> brqList = [SELECT Id FROM BatchRequestQueue__c];
        Id BatchRequestQueueId = brqList[0].Id;
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            combinedRecordList = GlAp_BatchRequestQueueCtrlr.retrieveErrorRecords(GlUt_APIConstantsBatchError.BATCHERRORAPINAME, batchErrorList, String.valueOf(BatchRequestQueueId));
            Test.stoptest();
            System.assert(combinedRecordList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveStagingRecords(){
        
        List<BatchRequestQueue__c> brqList = [SELECT Id FROM BatchRequestQueue__c];
        Id BatchRequestQueueId = brqList[0].Id;
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            combinedRecordList = GlAp_BatchRequestQueueCtrlr.retrieveStagingRecords(GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME, readingUploadList, String.valueOf(BatchRequestQueueId));
            Test.stoptest();
            System.assert(combinedRecordList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void cancelledStatus(){
        
        List<BatchRequestQueue__c> brqList = [SELECT Id FROM BatchRequestQueue__c];
        Id BatchRequestQueueId = brqList[0].Id;
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            GlAp_BatchRequestQueueCtrlr.cancelledStatus(BatchRequestQueueId);
            Test.stoptest();
            
            BatchRequestQueue__c objBRQ = [SELECT Id, CreatedDate,NotificationUser__c,Status__c FROM BatchRequestQueue__c WHERE Id=: BatchRequestQueueId];
            System.assert(objBRQ.Status__c == LoAp_Constants.Cancelled);
                
            
            // No assertion required as the return type is void
        }
    }
}