/******************************************************************************
@author         Echo: Sudhir Kumar
@date           3 July 2018
@description    Test class for PyAp_GoodwillPaymentCtrl
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class PyAp_GoodwillPaymentCtrl_Test {
	
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
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount); 
        
        //Create bank Account Detail
        BankAccountDetails__c bankAccountDetail = GlUt_FactoryData_Test.createBankAccountDetails(objAccount) ;
        Database.insert(bankAccountDetail); 
        
        // Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE,YEARLY,NO_OF_INSTALLMENT);
        Database.insert(objPaymentPlanType);
        
        //Create Balance record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance); 
        
        //Create Contract record     
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACTNAME,objAccount);
        objContract.Balance__c = objBalance.Id;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        Database.insert(objContract); 
        
        // Create Payment Record         
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.BillAmountUnallocated__c = INSTAMOUNTUNALLOCATED;
        objPayment.BankAccountNumber__c = BANKACCOUNTNUMBER;
        objPayment.Account__c = objAccount.Id;
        objPayment.BillingContract__c = objContract.Id;
        objPayment.Amount__c = AMOUNT;
        objPayment.CreditAmount__c = CREDITAMOUNT;
        objPayment.InstalmentAmountUnallocated__c = INSTAMOUNTUNALLOCATED;
        objPayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
        Database.insert(objPayment);   
        
        BankBranch__c objBankBranch = GlUt_FactoryData_Test.createBankBranch();
        objBankBranch.TownCity__c = TOWNCITY;
        objBankBranch.FICode__c = FICODE;
        objBankBranch.Postcode__c = POSTCODE;
        Database.insert(objBankBranch);
    }
    
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveAccountFields() method positive scenario with  -- as Input.
    *******************************************************************************/
    static testmethod void retrieveAccountFields_Positive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
      
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            	GLAp_FieldProps fieldProps = PyAp_GoodwillPaymentCtrl.retrieveAccountFields() ;
            Test.stopTest();
            System.assert(fieldProps != null);
        }
    } 
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveAccountFields() method negative scenario with  -- as Input.
    *******************************************************************************/
    static testmethod void retrieveAccountFields_Negative(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
      
        //Run test class in user context
        try {
            System.runAs(objUser){
            Test.startTest();
                GlUt_APIConstantsAccount.ACCOUNTAPINAME = 'Test' ;
                PyAp_GoodwillPaymentCtrl.retrieveAccountFields() ;
                Test.stopTest();
            }
        } catch(Exception ex) {
            system.debug('ex= ' + ex);
            system.assert(ex != null) ;
        }  
    } 
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveGoodwillPaymentFields() method positive scenario with  -- as Input.
    *******************************************************************************/
    static testmethod void retrieveGoodwillPaymentFields_Positive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        system.assert(objUser != null) ;
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            	PyAp_GoodwillPaymentCtrl.retrieveGoodwillPaymentFields() ;
            Test.stopTest();
        }  
    } 
    
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveGoodwillPaymentFields() method negative scenario with  -- as Input.
    *******************************************************************************/
    static testmethod void retrieveGoodwillPaymentFields_Negative(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
      
        //Run test class in user context
        try{
            System.runAs(objUser){
                Test.startTest();
                PyAp_Constants.PAYMENTAPINAME = 'Test' ;
                PyAp_GoodwillPaymentCtrl.retrieveGoodwillPaymentFields() ;
                Test.stopTest();
            }  
        }  catch(Exception ex) {
            system.debug('ex= ' + ex);
            system.assert(ex != null) ;
        } 
        
    } 
    
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveBankAccountFields() method positive scenario with  -- as Input.
    *******************************************************************************/
    static testmethod void retrieveBankAccountFields_Positive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
      
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            	System.assert(PyAp_Constants.BANKACCOUNTDETAILS != null) ;
            	PyAp_GoodwillPaymentCtrl.retrieveBankAccountFields(PyAp_Constants.BANKACCOUNTDETAILS) ;
            	System.assert(PyAp_Constants.CHEQUEDETAILS != null) ;
            	PyAp_GoodwillPaymentCtrl.retrieveBankAccountFields(PyAp_Constants.CHEQUEDETAILS) ;
            Test.stopTest();
        } 
    } 
    
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveBankAccountFields() method Negative scenario with  Input.
    *******************************************************************************/
    static testmethod void retrieveBankAccountFields_Negative(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
      
        //Run test class in user context
        System.runAs(objUser){
            try {
                Test.startTest();
                    PyAp_Constants.BANKACCOUNTDETAILS = 'TestBankDetails' ;
                    PyAp_GoodwillPaymentCtrl.retrieveBankAccountFields(PyAp_Constants.BANKACCOUNTDETAILS) ;
                    PyAp_Constants.CHEQUEDETAILS = 'TestCheque' ;
                    PyAp_GoodwillPaymentCtrl.retrieveBankAccountFields(PyAp_Constants.CHEQUEDETAILS) ;
                Test.stopTest();
            } catch(Exception ex) {
                system.debug('ex= ' + ex);
                system.assert(ex != null) ;
            }
        }  
    } 
    
    
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveAccountInfo() method positive scenario with  -- as Input.
    *******************************************************************************/
    static testmethod void retrieveAccountInfo_Positive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account oAccount = [Select Id, Name From Account Where Name =: ACCOUNTNAME LIMIT 1] ;
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            	system.assert(oAccount != null) ;
            	PyAp_GoodwillPaymentCtrl.retrieveAccountInfo(oAccount.Id) ;
            Test.stopTest();
        }  
    } 
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for retrieveAccountInfo() method Negative scenario with  -- as Input.
    *******************************************************************************/
    static testmethod void retrieveAccountInfo_Negative(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account oAccount = [Select Id, Name From Account Where Name =: ACCOUNTNAME LIMIT 1] ;
        //Run test class in user context
        
        System.runAs(objUser){
            try {
                Test.startTest();
                PyAp_GoodwillPaymentCtrl.retrieveAccountInfo('') ;
                Test.stopTest();
            } catch(Exception ex) {
                system.debug('ex= ' + ex);
                system.assert(ex != null) ;
            }
        }  
    } 
    
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for saveGoodwillPayment() method positive scenario.
    *******************************************************************************/
    static testmethod void saveGoodwillPayment_Positive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account oAccount = [Select Id, Name From Account Where Name =: ACCOUNTNAME LIMIT 1] ; 
        BillingContract__c oContract = [Select Id, Name From BillingContract__c Where AccountName__c =: oAccount.Id LIMIT 1] ;
        BankAccountDetails__c bankAccountDetail = [Select Id From BankAccountDetails__c Where Account__c =: oAccount.Id LIMIT 1] ;
        //Payment__c objPayment = [Select Id, Amount__c From Payment__c Where BillingContract__c =: oContract.Id LIMIT 1] ;
        Payment__c objPaymentRecord = new Payment__c(Amount__c = AMOUNT) ;
        //Run test class in user context
        System.runAs(objUser) {
            Test.startTest();
            	System.assert(objPaymentRecord.Amount__c != null) ;   
            	PyAp_GoodwillPaymentCtrl.saveGoodwillPayment(objPaymentRecord, oAccount.Id, PyAp_Constants.PAYMENT , oContract.Id, bankAccountDetail.Id) ;
            Test.stopTest();
        }
    } 
    
    /******************************************************************************
    @author:      Sudhir Kumar
    @date:        3 July 2018
    @description: Test method for  saveGoodwillPayment() method  - negative scenario.
    *******************************************************************************/
    static testmethod void saveGoodwillPayment_Negative(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account oAccount = [Select Id, Name From Account Where Name =: ACCOUNTNAME LIMIT 1] ; 
        BillingContract__c oContract = [Select Id, Name From BillingContract__c Where AccountName__c =: oAccount.Id LIMIT 1] ;
        BankAccountDetails__c bankAccountDetail = [Select Id From BankAccountDetails__c Where Account__c =: oAccount.Id LIMIT 1] ;
        //Payment__c objPayment = [Select Id, Amount__c From Payment__c Where Contract__c =: oContract.Id LIMIT 1] ;
        Payment__c objPaymentRecord = new Payment__c(Amount__c = AMOUNT) ;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                System.assert(objPaymentRecord != null) ;   
                PyAp_GoodwillPaymentCtrl.saveGoodwillPayment(objPaymentRecord, oAccount.Id, PyAp_Constants.PAYMENT , oContract.Id, bankAccountDetail.Id) ;
                Test.stopTest();
            } catch(Exception ex) {
                system.debug('ex= ' + ex);
                system.assert(ex != null) ;
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
            isBankBranchExists = PyAp_GoodwillPaymentCtrl.checkBankBranchRecords();
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
            bankBranch = PyAp_GoodwillPaymentCtrl.validateSortCodeEntered(SORTCODE);
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
            bankBranch = PyAp_GoodwillPaymentCtrl.validateSortCodeEntered(SORTCODEINVALID);
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
            twoColFormattedList = PyAp_GoodwillPaymentCtrl.retrieveBankBranchFields();
            Test.stopTest();
            System.assertNotEquals(twoColFormattedList.isEmpty(),NULL);
          }
    }
}