/******************************************************************************
@author         Echo: Patrick Dixon
@date           05 Jul 2018
@description    Test Class for CuAp_BatchRequestHistoryCtrlr
Revision(s)     
*******************************************************************************/
@isTest 
public class CuAp_BatchRequestHistoryCtrlr_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
    private static final String ACCOUNT_NAME = 'Test Account';
    
    
    private static final String BATCH_CLASS = 'LoBt_ScheduledEstimates';
    private static final String STAGING_TABLE = 'ReadingUpload__c';
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    private static final String FIELDSET_NAME = NAMESPACEPREFIX + 'RelatedListDetails';       // fieldsets must exist
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Jul 2018
    @description    Test data setup
    *******************************************************************************/
    @TestSetup
    static void createTestData() {
        
        // create a user
        User testUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        testUser.FirstName = USER_FIRST_NAME;
        testUser.LastName = USER_LAST_NAME;
        insert testUser;
        
        // create some batch processes
        List<BatchProcess__c> batchProcesses = new List<BatchProcess__c>();
        for (Integer i = 0; i < 10; i++) {
            BatchProcess__c batchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS);
            batchProcess.Name = 'TestProcess' + String.valueOf(i);
            batchProcess.Operation__c = GlUt_Constants.BATCHPROCESSOPERATION;
            batchProcess.StagingTable__c = STAGING_TABLE;
            batchProcesses.add(batchProcess);
        }
        insert batchProcesses;
        
        // create a batch request queue linked to a bacth process
        BatchRequestQueue__c batchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        batchRequestQueue.Status__c = GlBt_Constants.BRQINITIALISEDSTATUS;
        batchRequestQueue.BatchProcess__c = batchProcesses[0].Id;
        batchRequestQueue.NotificationUser__c = testUser.Id;        
        insert batchRequestQueue;
        
        // create some results for the request
        BatchError__c objBatchError = GlUt_FactoryData_Test.createBatchError(batchRequestQueue.Id);
        insert objBatchError;

        ReadingUpload__c readingUpload = GlUt_FactoryData_Test.createReadingUpload(batchRequestQueue.Id);
        insert readingUpload;

        ContentVersion document = new ContentVersion();
        document.Title = 'test';
        document.VersionData = Blob.valueOf('5');
        document.PathOnClient = 'test';        
        insert document;
        
        document = [select Id, ContentDocumentId from ContentVersion where Id = :document.Id];
       
        ContentDocumentLink documentLink = new ContentDocumentLink();
        documentLink.LinkedEntityId = batchRequestQueue.Id;
        documentLink.ContentDocumentId = document.ContentDocumentId;
        documentLink.ShareType = 'V';
        insert documentLink;

    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Jul 2018
    @description    Field properties test 
    *******************************************************************************/
    static testmethod void retrieveFieldProperties_Positive() {            
        
        User testUser = [select Id, 
                                Name 
                        from User 
                        where isActive = true 
                            and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
            List<GLAp_FieldProps> fields = CuAp_BatchRequestHistoryCtrlr.retrieveFieldProperties(FIELDSET_NAME); 
            system.assert(!fields.isEmpty());
            Test.stopTest();          
        }         
    }  
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Jul 2018
    @description    Tab field properties test 
    *******************************************************************************/
    static testmethod void retrieveTabFieldProperties_Positive() {            
        
        Id batchProcessId;
        for (BatchProcess__c batchProcess : [select Id  
                                            from BatchProcess__c
                                            where Id in (select BatchProcess__c from BatchRequestQueue__c)]) {
                                                
            batchProcessId = batchProcess.Id;
            break;
        }

        User testUser = [select Id, 
                                Name 
                        from User 
                        where isActive = true 
                            and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
            Map<String, List<GLAp_FieldProps>> tabFieldsMap = CuAp_BatchRequestHistoryCtrlr.retrieveTabFieldProperties(batchprocessId);
            for (List<GLAp_FieldProps> fields : tabFieldsMap.values()) {
                system.assert(!fields.isEmpty());
            }
            Test.stopTest();          
        }         
    }  
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Jul 2018
    @description    Records test (records returned)
    *******************************************************************************/
    static testmethod void retrieveRecords_Positive(){            
        
        Id batchProcessId;
        for (BatchProcess__c batchProcess : [select Id  
                                            from BatchProcess__c
                                            where Id in (select BatchProcess__c from BatchRequestQueue__c)]) {
                                                
            batchProcessId = batchProcess.Id;
            break;
        }

        User testUser = [select Id, 
                                Name 
                        from User 
                        where isActive = true 
                            and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
            List<BlAp_CombinedRecord> records = CuAp_BatchRequestHistoryCtrlr.retrieveRecords(batchProcessId, FIELDSET_NAME); 
            system.assert(!records.isEmpty());
            Test.stopTest();                     
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Jul 2018
    @description    Records test (no records returned)
    *******************************************************************************/
    static testmethod void retrieveRecords_Negative() {            
        
        Id batchProcessId;
        for (BatchProcess__c batchProcess : [select Id  
                                            from BatchProcess__c
                                            where Id not in (select BatchProcess__c from BatchRequestQueue__c)]) {
                                                
            batchProcessId = batchProcess.Id;
            break;
        }

        User testUser = [select Id, 
                                Name 
                        from User 
                        where isActive = true 
                            and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
            List<BlAp_CombinedRecord> records = CuAp_BatchRequestHistoryCtrlr.retrieveRecords(batchProcessId, ''); 
            system.assert(records == null || records.isEmpty());
            Test.stopTest();                     
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Jul 2018
    @description    Tabs record test
    *******************************************************************************/
    static testmethod void retrieveTabRecords_Positive() {
        
        Id batchProcessId;
        Id batchRequestQueueId;
        for (BatchRequestQueue__c batchRequestQueue : [select Id, 
                                                            BatchProcess__c 
                                                        from BatchRequestQueue__c]) {

            batchProcessId = batchRequestQueue.BatchProcess__c;
            batchRequestQueueId = batchRequestQueue.Id;
            break;
        }

        User testUser = [select Id, 
                                Name 
                        from User 
                        where isActive = true 
                            and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {
            
            Test.startTest();
            List<CuAp_BatchRequestHistoryCtrlr.tab> tabRecords = CuAp_BatchRequestHistoryCtrlr.getTabRecords(batchProcessId, batchRequestQueueId);
            Test.stopTest();
            System.assert(!tabRecords.isEmpty());
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Jul 2018
    @description    Cancel batch request queue test
    *******************************************************************************/
    static testmethod void cancelBatchRequestQueue_Positive() {
    
        Id batchRequestQueueId;
        for (BatchRequestQueue__c batchRequestQueue : [select Id 
                                                        from BatchRequestQueue__c]) {

            batchRequestQueueId = batchRequestQueue.Id;
            break;
        }

        User testUser = [select Id, 
                                Name 
                        from User 
                        where isActive = true 
                            and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {
            
            Test.startTest();
            CuAp_BatchRequestHistoryCtrlr.cancelBatchRequestQueue(batchRequestQueueId);
            Test.stopTest();
            
            for (BatchRequestQueue__c batchRequestQueue : [select Status__c 
                                                            from BatchRequestQueue__c
                                                            where Id = :batchRequestQueueId]) {
    
                System.assert(batchRequestQueue.Status__c == GlBt_Constants.BRQCANCELLEDSTATUS);
            }
        }
    }
    
}