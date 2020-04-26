/******************************************************************************
@author         Echo: Tarun Gupta
@date           12 Feb 2019
@description    AT-5240 , Test class for PyUt_AUSplitCombinedBankAccountNumber
*******************************************************************************/
@isTest
public class PyUt_AUSplitCombinedBankAccNmbr_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String BANK_ACC_COMBINED	= '777-888123456789';
    private static final String SORT_CODE	= '777-888';
    private static final String BANK_ACC_NUMBER	= '123456789';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Contract for Refund Paymet           
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Feb 2019
	@description: Positive method of populateAccountAndSortCodes 
	*******************************************************************************/
    static testmethod void populateAccountAndSortCodes_Positive(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [Select Id,Name FROM BillingContract__c WHERE AccountName__c =: objAccount.Id limit 1];
        Boolean isException = false;
        List<DirectDebitReturn__c> listDDR = new List<DirectDebitReturn__c>();
        
        DirectDebitReturn__c objDDR = GlUt_FactoryData_Test.createDirectDebitReturn(objContract);
        objDDR.BankAccountNumberCombined__c = BANK_ACC_COMBINED;
        listDDR.add(objDDR);
        
        System.runAs(objUser){
            Test.startTest();
            try{
                Database.insert(listDDR);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
        }          
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Feb 2019
	@description: Negative method of populateAccountAndSortCodes 
	*******************************************************************************/
    static testmethod void populateAccountAndSortCodes_Negative(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [Select Id,Name FROM BillingContract__c WHERE AccountName__c =: objAccount.Id limit 1];
        Boolean isException = false;
        List<DirectDebitReturn__c> listDDR = new List<DirectDebitReturn__c>();
        DirectDebitReturn__c objDDR = GlUt_FactoryData_Test.createDirectDebitReturn(objContract);
        listDDR.add(objDDR);
        
        System.runAs(objUser){
            Test.startTest();
            try{
                Database.insert(listDDR);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            DirectDebitReturn__c objDDRUpdate = [SELECT Id,BankAccountSortCode__c,BankAccountNumber__c,BankAccountNumberCombined__c FROM DirectDebitReturn__c LIMIT 1];
            system.assert(objDDRUpdate.BankAccountNumber__c == null);
            system.assert(objDDRUpdate.BankAccountSortCode__c == null);
        }          
    }

}