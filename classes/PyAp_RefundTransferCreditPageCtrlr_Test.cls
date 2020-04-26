/******************************************************************************
@author:      Echo: Dependra Singh
@date:        16 Feb 2018
@description: Test Class for PyAp_RefundTransferCreditPageCtrlr
*******************************************************************************/
@isTest
public class PyAp_RefundTransferCreditPageCtrlr_Test {
	
	//Variable declaration start
    private static final String PROFILENAME = 'System Administrator';
    private static final String USERNAME = 'TestUser111';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String ACCOUNTNAME = 'TestAccount';
    private static final String CONTRACTNAME ='TestContract';
    private static final String	PAYMENT_PLAN_TYPE = 'New Payment Plan';
    private static final Integer NO_OF_INSTALLMENT = 12;
    private static final String YEARLY = 'Yearly';
    private static final String REFUNDACCOUNT = 'Test';
    private static final String  BUDGETPLAN = 'Budget Plan';
    private static final INTEGER CREDITAMOUNT = 100; 
    private static final INTEGER BANKACCOUNTNUMBER = 23232;
    private static final INTEGER AMOUNT   = 5;
    private static final String INVALIDID = 'Null-Id';
    private static final String TOWNCITY  			= 'test';
    private static final String FICODE 				= 'FICODE';
    private static final String POSTCODE 			= 'ws2 8de';
    private static final String SORTCODE    	    = 'Test';   
    private static final String SORTCODEINVALID     = 'Test1';
    //Variable declaration end
	
	private static final List<String> payBankAccFields = new List<String>{
        GlUt_APIConstantsPayments.REFUNDACCOUNTAPINAME, 
        GlUt_APIConstantsPayments.BANKACCSORTCODEAPINAME, 
        GlUt_APIConstantsPayments.BANKACCOUNTNOAPINAME
        };
    private static final List<String> payChequeRefFields = new List<String>{
        GlUt_APIConstantsPayments.REFUNDADDRESSAPINAME,
        GlUt_APIConstantsPayments.REFUNDREFRENCEAPINAME                                                    
        };       
    private static final List<String> accountFields = new List<String>{
        PyAp_Constants.NAME                                                 
        };    
    private static final List < String > contractListFields = new List <String> {
        GlUt_APIConstantsContracts.CUSTOMERAPINAME,
        GlUt_APIConstantsContracts.STATUSAPINAME,
        GlUt_APIConstantsContracts.BALANCEAPINAME
        }; 
    private static final List < String > contractListFieldsForBalance = new List <String> {
       GlUt_APIConstantsContracts.BALANCEAPINAME
        };  
    private static final List < String > balanceFieldList = new List <String> {
       GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME,
       GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME
        }; 

/******************************************************************************
@author:      Echo: Dependra Singh
@date:        16 February 2018
@description: Test data setup method
*******************************************************************************/
 @TestSetup
	static void createTestData(){
	    //Create user record
	    User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
	    Database.insert(objUser); 
	    
	    //Create account record
	    Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
	    Database.insert(objAccount); 
	    
	    //Create Balance record
	    Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
	    Database.insert(objBalance); 
	    
	    // Create PaymentPlanType Record            
	    PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE,YEARLY,NO_OF_INSTALLMENT);
	    Database.insert(objPaymentPlanType);
	    
	    //Create Contract record     
	    BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACTNAME,objAccount);
	    objContract.Balance__c = objBalance.Id;
	    objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
	    Database.insert(objContract); 
        
        BankBranch__c objBankBranch = GlUt_FactoryData_Test.createBankBranch();
        objBankBranch.TownCity__c = TOWNCITY;
        objBankBranch.FICode__c = FICODE;
        objBankBranch.Postcode__c = POSTCODE;
        Database.insert(objBankBranch);
	    
	}

/******************************************************************************
@author:      Echo: Dependra Singh
@date:        16 February 2018
@description: Test method for retrieveBankAccountFields() method positive scenario for bank fields
*******************************************************************************/ 
  static testmethod void retrieveBankAccountFields_Positive(){
  	
    User objUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];	
    System.runAs(objUser){
  		Test.startTest();
		   List<List<GLAp_FieldProps>> twoColFormattedList  = PyAp_RefundTransferCreditPageCtrlr.retrieveBankAccountFields(PyAp_Constants.BANKACCOUNTDETAILS);
	    Test.stopTest();
	     System.assert(twoColFormattedList.size() >0);
  	 }
  } 

/******************************************************************************
@author:      Echo: Dependra Singh
@date:        16 February 2018
@description: Test method for retrieveBankAccountFields() method positive scenario fro cheque fields
*******************************************************************************/  
  static testmethod void retrieveBankAccountFields_Positive1(){
  	
    User objUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
    System.runAs(objUser){
  		Test.startTest();
		   List<List<GLAp_FieldProps>> twoColFormattedList  = PyAp_RefundTransferCreditPageCtrlr.retrieveBankAccountFields(PyAp_Constants.CHEQUEDETAILS);
	    Test.stopTest();
	      System.assert(twoColFormattedList.size() >0);
  	 }

  }     
 
/******************************************************************************
@author:      Echo: Dependra Singh
@date:        16 February 2018
@description: Test method for getExistingAccount() method positive scenario fro cheque fields
*******************************************************************************/  
  static testmethod void getExistingAccount_Positive(){
  	
  	 User objUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
     BillingContract__c objContract =[SELECT Id,Name FROM BillingContract__c LIMIT 1 ];	
     
      System.runAs(objUser){
  		Test.startTest();
		   Account objAccount = PyAp_RefundTransferCreditPageCtrlr.getExistingAccount(objContract.Id);
	    Test.stopTest();
	      System.assert(objAccount != null);
  	 }
  }

/******************************************************************************
@author:      Echo: Dependra Singh
@date:        16 February 2018
@description: Test method for getExistingAccount() method negative scenario fro cheque fields
*******************************************************************************/  	
  static testmethod void getExistingAccount_Negative(){
  	
  	 User objUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
     BillingContract__c objContract =[SELECT Id,Name FROM BillingContract__c LIMIT 1 ];	
     
      System.runAs(objUser){
  		Test.startTest();
		   Account objAccount = PyAp_RefundTransferCreditPageCtrlr.getExistingAccount(objUser.Id);
	    Test.stopTest();
	      System.assert(objAccount == null);
  	 }
  } 
   
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        10 April 2018
    @description: Test method for getExistingAccount() method null scenario fro cheque fields
    *******************************************************************************/  	 
    static testmethod void getExistingAccount_Null(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c objContract =[SELECT Id,Name FROM BillingContract__c LIMIT 1 ];	
        Boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                Account objAccount = PyAp_RefundTransferCreditPageCtrlr.getExistingAccount(INVALIDID);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assert(isException == true);
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
            isBankBranchExists = PyAp_RefundTransferCreditPageCtrlr.checkBankBranchRecords();
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
            bankBranch = PyAp_RefundTransferCreditPageCtrlr.validateSortCodeEntered(SORTCODE);
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
            bankBranch = PyAp_RefundTransferCreditPageCtrlr.validateSortCodeEntered(SORTCODEINVALID);
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
            twoColFormattedList = PyAp_RefundTransferCreditPageCtrlr.retrieveBankBranchFields();
            Test.stopTest();
            System.assertNotEquals(twoColFormattedList.isEmpty(),NULL);
          }
    }
    
}