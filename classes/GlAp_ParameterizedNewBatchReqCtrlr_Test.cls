/******************************************************************************
@author         Echo: Vivek Sethi
@date           04 Dec 2018
@description    Test Class for GlAp_ParameterizedNewBatchRequestCtrlr
Revision(s)     
*******************************************************************************/
@isTest 
public class GlAp_ParameterizedNewBatchReqCtrlr_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String BATCH_CLASS = 'CuBt_DiscountRenewal';
    private static final String STAGING_TABLE = 'ReadingUpload__c';
    private static final String INVALIDID  = 'a211v000002iyaOAAQ';
    private static final String SName  = 'Test';
    private static final String RECORDTYPEID	= Schema.SObjectType.DiscountType__c.getRecordTypeInfosByName().get(System.Label.CuAp_BillToBillDiscount).getRecordTypeId();
    
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
        
        //Create Next Financial year Discount Type
        DiscountType__c newDiscountType = GlUt_FactoryData_Test.createDiscountType(sName, Date.today().addMonths(10), Date.today().addMonths(12), null, null);
        newDiscountType.DiscountPerDay__c = 12.00;        
        Database.insert(newDiscountType);
        
        //Create Discount Type
        DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(SName, Date.today(), Date.today().addDays(10), null, null);
        objDiscountType.RecordTypeId = RECORDTYPEID;
        objDiscountType.DiscountPerDay__c = 10.00;
        objDiscountType.DiscountType__c = newDiscountType.Id;
        objDiscountType.Active__c = TRUE;
        Database.insert(objDiscountType);
        
    }

    /******************************************************************************* 
    @author         Echo: Vivek Sethi
    @date           04 Dec 2018
    @description    Field properties test 
    *******************************************************************************/
    static testmethod void retrieveFieldList_Positive() {            
        
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {
            Test.startTest(); 
            List<GLAp_FieldProps> fields = GlAp_ParameterizedNewBatchRequestCtrlr.retrieveFieldList(); 
            system.assert(!fields.isEmpty());
            Test.stopTest();          
        }         
    } 

    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           04 Dec 2018
	@description    Records test (records returned)
	*******************************************************************************/
    static testmethod void retrieveRecordList_Positive(){            
        
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest(); 
            List<BlAp_CombinedRecord> records = GlAp_ParameterizedNewBatchRequestCtrlr.retrieveRecordList(); 
            system.assert(!records.isEmpty());
            Test.stopTest();                     
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           04 Dec 2018
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void retrieveRecords_Positive(){            
        BatchProcess__c batchProcess = [select Id from BatchProcess__c limit 1];
        List<BlAp_CombinedRecord> discountTypeRecords = GlAp_ParameterizedNewBatchRequestCtrlr.retrieveRecordList();         

        for(BlAp_CombinedRecord objCR: discountTypeRecords){
            objCR.isSelected = true;
        }
        
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest(); 
            Boolean recordBRQCreated = GlAp_ParameterizedNewBatchRequestCtrlr.createDefaultBatchRequest(JSON.serialize(discountTypeRecords) , batchProcess.Id); 
            system.assert(recordBRQCreated == TRUE);
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
        
        List<BlAp_CombinedRecord> discountTypeRecords = GlAp_ParameterizedNewBatchRequestCtrlr.retrieveRecordList();         
        
        for(BlAp_CombinedRecord objCR: discountTypeRecords){
            objCR.isSelected = true;
        }
       
        System.runAs(testUser) {
            try{
                Test.startTest(); 
                Boolean recordBRQCreated = GlAp_ParameterizedNewBatchRequestCtrlr.createDefaultBatchRequest(JSON.serialize(discountTypeRecords) , INVALIDID); 
                system.assert(recordBRQCreated == NULL);
                Test.stopTest();  
            }catch(exception e) {
                isException = true;
            } 
            system.assertEquals(isException, true);
        }  
    } 
}