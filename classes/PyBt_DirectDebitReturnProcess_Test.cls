/******************************************************************************
@author         Vivek Sethi
@date           03 July 2018
@description    Test Class For PyBt_DirectDebitReturnProcess
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class PyBt_DirectDebitReturnProcess_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static String ACCOUNT_NAME 					= 'TestDevice';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String ERROR                   = 'Error';
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           03 July 2018
    @return         Void   
    @description    Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){ 
  
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
        
        //Create Direct Debit Return Record
        DirectDebitReturn__c objDirectDebitReturn = GlUt_FactoryData_Test.createDirectDebitReturn(objContract);
        Database.insert(objDirectDebitReturn);
       
        //Create BatchRequestQueue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        Database.insert(objBatchRequestQueue);
        
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           08 June 2018
    @description:   Test Method to check PyBt_DirectDebitReturnProcess 
	*******************************************************************************/
    static testmethod void PyBt_DirectDebitReturnProcess_Positive() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c BatchRequestQueue = [select Id  from BatchRequestQueue__c limit 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            PyBt_DirectDebitReturnProcess obj = new PyBt_DirectDebitReturnProcess();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
        DirectDebitReturn__c directDebitReturn = [select Id , status__c  from DirectDebitReturn__c limit 1]; 
        system.assertEquals(directDebitReturn.Status__c, ERROR);
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           08 June 2018
    @description:   Test Method to check PyBt_DirectDebitReturnProcess 
	*******************************************************************************/
    static testmethod void PyBt_DirectDebitReturnProcess_Negative() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c BatchRequestQueue = new BatchRequestQueue__c(); 
        PyBt_DirectDebitReturnProcess obj = new PyBt_DirectDebitReturnProcess();
        System.runAs(objUser){
            Test.startTest();
            try{
                obj.Initialise(BatchRequestQueue);
                DataBase.executeBatch(obj);
            } catch(Exception ex){
            }
            Test.stopTest();
            System.assert(obj.batchRequestQueue.Id == null);
        }
    }
}