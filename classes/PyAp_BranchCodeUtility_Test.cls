/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        15 Jan 2019
@description  Test class for PyAp_BranchCodeUtility
@Revisions	  
*******************************************************************************/
@isTest
public class PyAp_BranchCodeUtility_Test {
	
    //Variable declaration start
    private static final String PROFILENAME = 'System Administrator';
    private static final String USERNAME = 'Goodwill_TestUser';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String ACCOUNTNAME = 'TestAccount';
    private static final String CONTRACTNAME ='TestContract';
    private static final String PAYMENT_PLAN_TYPE = 'New Payment Plan';
    private static final Integer NO_OF_INSTALLMENT = 12;
    private static final String YEARLY = 'Yearly';
    private static final INTEGER CREDITAMOUNT = 200; 
    private static final STRING  BANKACCOUNTNUMBER = '23232';
    private static final INTEGER AMOUNT   = 500; 
    private static final INTEGER INSTAMOUNTUNALLOCATED = 200;
    private static final String TOWNCITY  			= 'test';
    private static final String FICODE 				= 'FICODE';
    private static final String POSTCODE 			= 'ws2 8de';
    private static final String SORTCODE    	    = 'Test';   
    private static final String SORTCODEINVALID     = 'Test1';
    //Variable declaration end
    
    /******************************************************************************
    @author:      Echo: Sudhir Kumar
    @date:        3 July 2018
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData() {
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 
        
        //Create Bank Branch record
        BankBranch__c objBankBranch = GlUt_FactoryData_Test.createBankBranch();
        objBankBranch.TownCity__c = TOWNCITY;
        objBankBranch.FICode__c = FICODE;
        objBankBranch.Postcode__c = POSTCODE;
        Database.insert(objBankBranch);
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
            isBankBranchExists = PyAp_BranchCodeUtility.checkBankBranchRecords();
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
            bankBranch = PyAp_BranchCodeUtility.validateSortCodeEntered(SORTCODE);
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
            bankBranch = PyAp_BranchCodeUtility.validateSortCodeEntered(SORTCODEINVALID);
            Test.stopTest();
            System.assertEquals(bankBranch, NULL);
        }
    }
}