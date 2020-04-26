/******************************************************************************
@author         Vivek Sethi
@date           03 July 2018
@description    Test Class For PyBt_BankAccountChangeProcessActions
*******************************************************************************/
@isTest
public class PyBt_BankAccountChangeProcess_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123';  
    private static final String USERNAMECOMPLETE        =  USER_NAME + '@unitest.com';
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123'; 
    private static final Date INSTALMENT_DUE_DATE       = system.today();
    private static final String  PAYMENT_PLAN_TYPE     = 'New Payment Plan';
    private static final String PAYMENT_FREQ           = 'Monthly';
    private static final String OUTGOING               = 'Outgoing';
    private static final Integer MAX_INSTALLMENT       = 12;
    private static final Integer PLAN_AMOUNT           = 50;
    private static final Integer INSTALMENT_AMOUNT_DUE = 50;
    private static final Integer SUM_OF_ALLOCATED_PAY  = 10;
    private static final String ACCOUNT_NAME            = 'TestAccount';
    
    /******************************************************************************
    @author         Vivek Sethi
    @date           03 July 2018
    @return         Void   
    @description    Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){ 
  
        Id accRecordTypeId = Schema.SObjectType.BankAccountChange__c.getRecordTypeInfosByName().get(OUTGOING).getRecordTypeId();
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
    
        //Create account
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Contract
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        Database.insert(objContract);
       
        //Create Bank Account Change Record
        BankAccountChange__c objBankAccountChange = GlUt_FactoryData_Test.createBankAccountChange(objContract);
        objBankAccountChange.recordTypeId = accRecordTypeId;
        objBankAccountChange.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_ERROR;
        Database.insert(objBankAccountChange);
        
        //Create Bank Account Change Record
        BankAccountChange__c objBankAccountChange1 = GlUt_FactoryData_Test.createBankAccountChange(objContract);
        objBankAccountChange1.recordTypeId = accRecordTypeId;
        objBankAccountChange1.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED;
        Database.insert(objBankAccountChange1);
   
        
        //Create Batch Request Queue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        Database.insert(objBatchRequestQueue);
        
    }
    
    /******************************************************************************
    @author         Vivek Sethi
    @date           08 June 2018
    @description:   Test Method to check PyBt_DirectDebitReturnProcess Batch class
    *******************************************************************************/
    static testmethod void PyBt_DirectDebitReturnProcess_Positive() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c batchRequestQueue = [select Id , Status__c from BatchRequestQueue__c limit 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            PyBt_BankAccountChangeProcessActions obj = new PyBt_BankAccountChangeProcessActions();
            obj.Initialise(batchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
            
            BankAccountChange__c bankAccountChange = [select Id , status__c  from BankAccountChange__c limit 1];
            system.assertEquals(bankAccountChange.status__c,PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_PENDING);
         
            BatchRequestQueue__c batchRequestQueueCompleted = [select Id , Status__c  from BatchRequestQueue__c where Id =: batchRequestQueue.Id limit 1];
            system.assertEquals(batchRequestQueueCompleted.status__c,GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_COMPLETED);
        }
    }
    
    /*****************************************************************************
	@author         Vivek Sethi
	@date           08 June 2018
	@description:   Test Method to check PyBt_BankAccountChangeProcessActions negative scenario 
	*******************************************************************************/
    static testmethod void PyBt_DirectDebitReturnProcess_Negative() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c batchRequestQueue = [select Id , Status__c from BatchRequestQueue__c limit 1]; 
        System.runAs(objUser){
            Test.startTest();
            PyBt_BankAccountChangeProcessActions obj = new PyBt_BankAccountChangeProcessActions();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
            
            BankAccountChange__c bankAccountChange = [select Id , status__c  from BankAccountChange__c where Status__c =: PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED limit 1];
            system.assertNotEquals(bankAccountChange,null);
        }
    }
}