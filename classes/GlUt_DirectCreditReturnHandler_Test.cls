/******************************************************************************
@author:      Echo: Vivek Sethi 
@date:        26-06-2018  
@description: Test Class for GlUt_DirectCreditReturnHandler
*******************************************************************************/
@isTest 
public class GlUt_DirectCreditReturnHandler_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final Integer AMOUNT = 120;
    private static final string BANKACCOUNTNUMBER = '123123';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_NAME2 =  'Test Account2';
    private static final String ACCOUNT_NAME3 =  'Test Account3';
    private static final String ACCOUNT_NAME4 =  'Test Account4';
    private static final String CONTRACT_NAME = 'Con00021';
    private static final String CONTRACT_NAME2 = 'Con00022';
    private static final String REFUND = 'Refund';
    private static final String GOODWILL = 'Goodwill';
 
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        26-06-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
         // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Another Account Record            
        Account objAccount2 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);
        Database.insert(objAccount2);
        
        // Create Another Account Record            
        Account objAccount3 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME3);
        Database.insert(objAccount3);
        
          // Create Another Account Record            
        Account objAccount4 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME4);
        Database.insert(objAccount4);
        
        // Create Contract for Refund Paymet           
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);   
        
       // Create Contract Record without payment           
        BillingContract__c objContract2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount2);
        Database.insert(objContract2);    
        
        // Create Contract Record for GOODWILL payment       
        BillingContract__c objContract3 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME , objAccount3);
        Database.insert(objContract3);    
        
         // Create Contract Record for other payment       
        BillingContract__c objContract4 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME , objAccount4);
        Database.insert(objContract4);    
 
       // Create Bank Account Details Record        
        BankAccountDetails__c objBankAccountDetails = GlUt_FactoryData_Test.createBankAccountDetails(objAccount);
        Database.insert(objBankAccountDetails);  
        
        // Create Bank Account Details Record        
        BankAccountDetails__c objBankAccountDetails2 = GlUt_FactoryData_Test.createBankAccountDetails(objAccount3);
        Database.insert(objBankAccountDetails2);
        
        // Create Another Bank Account Details Record without payment record
        BankAccountDetails__c objBankAccountDetails3= GlUt_FactoryData_Test.createBankAccountDetails(objAccount2);
        Database.insert(objBankAccountDetails3);  
        
          // Create Another Bank Account Details Record without payment record
        BankAccountDetails__c objBankAccountDetails4= GlUt_FactoryData_Test.createBankAccountDetails(objAccount4);
        Database.insert(objBankAccountDetails4);  
        
        // Create Payment Record            
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);        
        objPayment.BankAccountNumber__c  = BANKACCOUNTNUMBER;
        objPayment.BankAccountDetail__c = objBankAccountDetails.Id;
        objPayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(REFUND).getRecordTypeId();
        Database.insert(objPayment);  
        
        // Create Payment Record            
        Payment__c objPayment2 = GlUt_FactoryData_Test.createPayment(objAccount3, objContract3);        
        objPayment2.BankAccountNumber__c  = BANKACCOUNTNUMBER;
        objPayment2.BankAccountDetail__c = objBankAccountDetails2.Id;
        objPayment2.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(GOODWILL).getRecordTypeId();
        Database.insert(objPayment2);  
        
          // Create Payment Record            
        Payment__c objPayment3 = GlUt_FactoryData_Test.createPayment(objAccount4, objContract4);        
        objPayment3.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(GOODWILL).getRecordTypeId();
        Database.insert(objPayment3);          
   
    }    
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        26-06-2018  
	@description: Method for insert  a new record
	*******************************************************************************/
    static testmethod void insertDirectCreditReturn_RefundPayment()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c LIMIT 1];
        
        DirectCreditReturn__c objDirectCreditReturn = new DirectCreditReturn__c();
        objDirectCreditReturn = GlUt_FactoryData_Test.createDirectCreditReturn(objContract);
        objDirectCreditReturn.Amount__c = AMOUNT;
     
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objDirectCreditReturn);         
            Test.stopTest();
        }          
        system.assert(objDirectCreditReturn.id != null);        
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        26-06-2018  
	@description: Method for insert  a new record
	*******************************************************************************/
    static testmethod void insertDirectCreditReturn_GoodWillPayment()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Account objAccount = [SELECT Id FROM  Account WHERE Name =: ACCOUNT_NAME3   LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c  WHERE AccountName__c =: objAccount.id    LIMIT 1];
   
        DirectCreditReturn__c objDirectCreditReturn = new DirectCreditReturn__c();
        objDirectCreditReturn = GlUt_FactoryData_Test.createDirectCreditReturn(objContract);
        objDirectCreditReturn.Amount__c = AMOUNT;
     
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objDirectCreditReturn);         
            Test.stopTest();
        }          
        system.assert(objDirectCreditReturn.id != null);        
    }

    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        26-06-2018  
	@description: Method for insert  a new record
	*******************************************************************************/
    static testmethod void insertDirectCreditReturn_OtherPayment()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Account objAccount = [SELECT Id FROM  Account WHERE Name =: ACCOUNT_NAME4   LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c  WHERE AccountName__c =: objAccount.id    LIMIT 1];
   
        DirectCreditReturn__c objDirectCreditReturn = new DirectCreditReturn__c();
        objDirectCreditReturn = GlUt_FactoryData_Test.createDirectCreditReturn(objContract);
        objDirectCreditReturn.Amount__c = AMOUNT;
     
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objDirectCreditReturn);         
            Test.stopTest();
        }          
        system.assert(objDirectCreditReturn.id != null);        
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        26-06-2018  
	@description: Method for insert  a new record without payment
	*******************************************************************************/
    static testmethod void insertDirectCreditReturn_withoutPayment()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [SELECT Id FROM  Account WHERE Name =: ACCOUNT_NAME2   LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c  WHERE AccountName__c =: objAccount.id    LIMIT 1];
        
        DirectCreditReturn__c objDirectCreditReturn = new DirectCreditReturn__c();
        objDirectCreditReturn = GlUt_FactoryData_Test.createDirectCreditReturn(objContract);
        objDirectCreditReturn.Amount__c = AMOUNT;
     
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objDirectCreditReturn);         
            Test.stopTest();
        }          
        system.assert(objDirectCreditReturn.id != null);        
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        26-06-2018  
	@description: Method for insert  a new record without payment
	*******************************************************************************/
    static testmethod void insertDirectCreditReturn_NegativePayment()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = new Account();
        BillingContract__c objContract = new BillingContract__c();
        
        DirectCreditReturn__c objDirectCreditReturn = new DirectCreditReturn__c();
        objDirectCreditReturn = GlUt_FactoryData_Test.createDirectCreditReturn(objContract);
        objDirectCreditReturn.Amount__c = AMOUNT;
        Boolean isException;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                Database.insert(objDirectCreditReturn);   
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
        }   
        system.assertEquals(isException, true);
    }
}