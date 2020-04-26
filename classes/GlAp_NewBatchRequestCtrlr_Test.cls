/******************************************************************************
@author         Echo: Vivek Sethi
@date           04 Dec 2018
@description    Test Class for GlAp_NewBatchRequestCtrlr
Revision(s)     
*******************************************************************************/
@isTest 
public class GlAp_NewBatchRequestCtrlr_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String BATCH_CLASS = 'LoBt_ScheduledEstimates';
    private static final String STAGING_TABLE = 'ReadingUpload__c';
    private static final String INVALIDID      = 'a211v000002iyaOAAQ';
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           04 Dec 2018
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
        BatchProcess__c batchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS);
        batchProcess.Name = 'TestProcess';
        batchProcess.Operation__c = GlUt_Constants.BATCHPROCESSOPERATION;
        batchProcess.StagingTable__c = STAGING_TABLE;
        batchProcesses.add(batchProcess);
        insert batchProcesses;
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           04 Dec 2018
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void retrieveRecords_Positive(){            
        BatchProcess__c batchProcess = [select Id from BatchProcess__c limit 1];
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest(); 
            Id recordBRQ = GlAp_NewBatchRequestCtrlr.createDefaultBatchRequest(batchProcess.Id); 
            system.assert(recordBRQ != NULL);
            Test.stopTest();                     
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           04 Dec 2018
    @description    Records test (no records returned)
    *******************************************************************************/
    static testmethod void retrieveRecords_Negative() {    
        Boolean isException;       
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        System.runAs(testUser) {
            try{
                Test.startTest(); 
                Id recordBRQ = GlAp_NewBatchRequestCtrlr.createDefaultBatchRequest(INVALIDID); 
                system.assert(recordBRQ == NULL);
                Test.stopTest();  
            }catch(exception e) {
                isException = true;
            } 
            system.assertEquals(isException, true);
        }  
    } 
}