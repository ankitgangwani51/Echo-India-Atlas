/******************************************************************************
@author         Echo: Dependra Singh
@date           04 July 2018
@description    Component controller for PyAp_BankAccountDetailCrtlr test class
*******************************************************************************/
@isTest
public class PyAp_BankAccountDetailCtrlr_Test {
    
    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static final String CONTRACT_NAME       = 'TestContract';
    private static final String TOWNCITY  			= 'test';
    private static final String FICODE 				= 'FICODE';
    private static final String POSTCODE 			= 'ws2 8de';
    private static final String SORTCODE    	    = 'Test';   
    private static final String SORTCODEINVALID     = 'Test1';
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        04 July 2018
    @param:       N/A
    @return:      void
    @description: method to create test data used by all test methods
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c con = GlUt_FactoryData_Test.createContract(objAccount); 
        Database.insert(con);
        
        BankBranch__c objBankBranch = GlUt_FactoryData_Test.createBankBranch();
        objBankBranch.TownCity__c = TOWNCITY;
        objBankBranch.FICode__c = FICODE;
        objBankBranch.Postcode__c = POSTCODE;
        Database.insert(objBankBranch);
        
    }
    /*******************************************************************
    @author:      Echo: Dependra Singh
    @date:        04 July 2018
    @param:       N/A
    @return:      void
    @description: Testing the scenario when retrieving Bank Account Detail properties
    ********************************************************************/
    
    static testmethod void retrieveBankAccountDetailsFields_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<List<GLAp_FieldProps>> fieldProps = new  List<List<GLAp_FieldProps>>();
            fieldProps = PyAp_BankAccountDetailCtrlr.retrieveBankAccountDetailsFields();
            Test.stopTest();
            System.assert(fieldProps.size() > 0);
        }
    }
    /*******************************************************************
    @author:      Echo: Dependra Singh
    @date:        04 July 2018
    @param:       N/A
    @return:      void
    @description: Testing the scenario when retrieving Bank Account Detail properties(Negative Scenario)
    ********************************************************************/
    
    static testmethod void retrieveBankAccountDetailsFields_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
		boolean isException = false;

        PyAp_BankAccountDetailCtrlr.bankAccountDetailsFields = null;
        PyAp_BankAccountDetailCtrlr.contractListFields = null;
        PyAp_BankAccountDetailCtrlr.accountFields = null;
        
        System.runAs(objUser){
			try{
                List<List<GLAp_FieldProps>> fieldProps = PyAp_BankAccountDetailCtrlr.retrieveBankAccountDetailsFields();
            }
            catch(Exception exc){
                isException = true;
                System.assertNotEquals(exc.getMessage(),null);
            }
        }
    }
    /*******************************************************************
    @author:      Echo: Dependra Singh
    @date:        04 July 2018
    @param:       N/A
    @return:      void
    @description: Testing the scenario 
    ********************************************************************/
    
    static testmethod void getExistingAccount_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        List<BillingContract__c> contractList = [Select Id, name, AccountName__c from BillingContract__c LIMIT 1];
         system.debug('contractList===='+contractList);
        System.runAs(objUser){
            Test.startTest();
            Account objAccount = new Account();
            if(contractList != null && contractList.size() > 0){
                objAccount = PyAp_BankAccountDetailCtrlr.getExistingAccount(string.valueOf(contractList[0].Id));
                system.debug('objAccount===='+objAccount);
            }
            Test.stopTest();
            System.assert(objAccount != null);
        }
    }
    /*******************************************************************
    @author:      Echo: Dependra Singh
    @date:        04 July 2018
    @param:       N/A
    @return:      void
    @description: Testing the scenario 
    ********************************************************************/
    static testmethod void getExistingAccount_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        boolean isException = false;
        
        System.runAs(objUser){
            try{
                Account objAccount = PyAp_BankAccountDetailCtrlr.getExistingAccount(ACCOUNT_NAME);
            }
            catch(Exception exc){
                isException = true;
                System.assertNotEquals(exc.getMessage(),null);
            }
        }       
    }
    
    /*******************************************************************
    @author:      Echo: Vivek Sethi
    @date:        15 Jan 2019
    @param:       N/A
    @return:      void
    @description: Testing the scenario 
    ********************************************************************/
    static testmethod void checkBankBranchRecords(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        boolean isBankBranchExists = false;
        System.runAs(objUser){
            Test.startTest();
            isBankBranchExists = PyAp_BankAccountDetailCtrlr.checkBankBranchRecords();
            Test.stopTest();
            System.assertEquals(isBankBranchExists, true);
            
        }
    }
    
    /*******************************************************************
    @author:      Echo: Vivek Sethi
    @date:        15 Jan 2019
    @param:       N/A
    @return:      void
    @description: Testing the positive scenario 
    ********************************************************************/
    static testmethod void validateSortCodeEntered_positive(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        BankBranch__c bankBranch = new BankBranch__c();
        System.runAs(objUser){
            Test.startTest();
            bankBranch = PyAp_BankAccountDetailCtrlr.validateSortCodeEntered(SORTCODE);
            Test.stopTest();
            System.assertEquals(bankBranch.TownCity__c,TOWNCITY);
            System.assertEquals(bankBranch.FICode__c,FICODE);
        }
    }
    
    /*******************************************************************
    @author:      Echo: Vivek Sethi
    @date:        15 Jan 2019
    @param:       N/A
    @return:      void
    @description: Testing the negative scenario 
    ********************************************************************/
    static testmethod void validateSortCodeEntered_negative(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        BankBranch__c bankBranch = new BankBranch__c();
        System.runAs(objUser){
            Test.startTest();
            bankBranch = PyAp_BankAccountDetailCtrlr.validateSortCodeEntered(SORTCODEINVALID);
            Test.stopTest();
            System.assertEquals(bankBranch, NULL);

        }
    }
    
    /*******************************************************************
    @author:      Echo: Vivek Sethi
    @date:        15 Jan 2019
    @param:       N/A
    @return:      void
    @description: Testing the positive scenario 
    ********************************************************************/
    static testmethod void retrieveBankBranchFields(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        System.runAs(objUser){
            Test.startTest();
            twoColFormattedList = PyAp_BankAccountDetailCtrlr.retrieveBankBranchFields();
            Test.stopTest();
            System.assertNotEquals(twoColFormattedList.isEmpty(),NULL);
          }
    }
}