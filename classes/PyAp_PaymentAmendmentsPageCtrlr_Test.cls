/******************************************************************************
@author:      Echo: Amit K. 
@date:        30-01-2018  
@description: Test Class for PyAp_PaymentAmendmentsPageCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest  
public class PyAp_PaymentAmendmentsPageCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String PAYMENT_TYPE_RETURN = 'returnPayment';
    private static final String PAYMENT_TYPE_TRANSFER = 'transferPayment';
    private static final String PAYMENT_TRANSFER_REASON = 'Mis-post';
    private static final String INVALID_CONTRACT_ID = 'XYZ';
    

    /******************************************************************************
	@author:      Echo: Amit K.
	@date:        30-01-2018  
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
        
        // Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(ACCOUNT_NAME, objAccount);        
        Database.insert(objContract);  
        
        //Create Payment Record
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        Database.insert(objPayment);
        
    }
    
   /******************************************************************************
	@author:      Echo: Amit K.
	@date:        30-01-2018  
	@description: Test Method to handel transfer payment in POSITIVE scenario
	*******************************************************************************/
    static testmethod void paymentAmendmentTransferPayment_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Payment__c objPayment = [SELECT Id FROM Payment__c LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        Account objAccount =  [SELECT Id FROM Account LIMIT 1];
        
        String result;
        
        System.runAs(objUser){
            Test.startTest();
            result = PyAp_PaymentAmendmentsPageCtrlr.paymentAmendment(objPayment.Id,PAYMENT_TYPE_TRANSFER,PAYMENT_TRANSFER_REASON,objContract.Id,objAccount.Id, false);           
            Test.stopTest();
        }
        System.assert(result != null);
    }
        
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        31-01-2018  
	@description: Test Method to handel transfer payment in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void paymentAmendmentTransferPayment_Negative()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Payment__c objPayment = new Payment__c();
        
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        Account objAccount =  [SELECT Id FROM Account LIMIT 1];
        
        String result;
        
        System.runAs(objUser){
            Test.startTest();
            result = PyAp_PaymentAmendmentsPageCtrlr.paymentAmendment(objPayment.Id,PAYMENT_TYPE_TRANSFER,PAYMENT_TRANSFER_REASON,objContract.Id,objAccount.Id, false);           
            Test.stopTest();
        }
        System.assert(result != null);
    }
    
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        30-01-2018  
	@description: Test Method to handel transfer payment in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void paymentAmendmentTransferPaymentException_Negative()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Payment__c objPayment = [SELECT Id FROM Payment__c LIMIT 1];       
        Account objAccount =  [SELECT Id FROM Account LIMIT 1];
        
        boolean isException;
        String result;
        
        System.runAs(objUser){
            try{
            Test.startTest();
            result = PyAp_PaymentAmendmentsPageCtrlr.paymentAmendment(objPayment.Id,PAYMENT_TYPE_TRANSFER,PAYMENT_TRANSFER_REASON,INVALID_CONTRACT_ID,objAccount.Id, false);           
            }catch(Exception e)
            {
                isException = true;            
            }
            Test.stopTest();
        }
        System.assert(isException == true);
    }
    
    /******************************************************************************
	@author:      Echo: Amit K.
	@date:        30-01-2018  
	@description: Test Method to handel return payment in POSITIVE scenario
	*******************************************************************************/
    static testmethod void paymentAmendmentReturnPayment_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Payment__c objPayment = [SELECT Id FROM Payment__c LIMIT 1];
        
        String result;
        
        System.runAs(objUser){
            Test.startTest();
            result = PyAp_PaymentAmendmentsPageCtrlr.paymentAmendment(objPayment.Id,PAYMENT_TYPE_RETURN,PAYMENT_TRANSFER_REASON,'','', false);
            Test.stopTest();
        }
        System.assert(result != null);
    } 
    
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        31-01-2018  
	@description: Test Method to handel return payment in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void paymentAmendmentReturnPayment_Negative()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Payment__c objPayment = new Payment__c();
        
        String result;
        
        System.runAs(objUser){
            Test.startTest();
            result = PyAp_PaymentAmendmentsPageCtrlr.paymentAmendment(objPayment.Id,PAYMENT_TYPE_RETURN,PAYMENT_TRANSFER_REASON,'','', false);
            Test.stopTest();
        }
        System.assert(result != null);
    }  
     
    /******************************************************************************
	@author:      Echo: Amit K.
	@date:        30-01-2018  
	@description: Test Method to fetch the account on associated payment in POSITIVE scenario
	*******************************************************************************/
    static testmethod void getExistingPaymentAccount_Positive()
    {     
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];  
        Payment__c objPayment = [SELECT Id FROM Payment__c LIMIT 1];
        
        PyAp_PaymentAmendmentsPageCtrlr.ContainerWrapper resultContainer = new PyAp_PaymentAmendmentsPageCtrlr.ContainerWrapper(); 
        
        System.runAs(objUser){
            Test.startTest();                
            resultContainer = PyAp_PaymentAmendmentsPageCtrlr.getExistingPaymentAccount(objPayment.Id);  
            Test.stopTest();
        }
        
        System.assert(resultContainer.Account != null);
    }
    
    /******************************************************************************
	@author:      Echo: Neha R
	@date:        31-01-2018  
	@description: Test Method to fetch the account on associated payment in Negative scenario
	*******************************************************************************/
    static testmethod void getExistingPaymentAccount_Negative()
    {     
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Boolean exceptionStr = false;
        Payment__c objPayment = new Payment__c();
        
        PyAp_PaymentAmendmentsPageCtrlr.ContainerWrapper resultContainer = new PyAp_PaymentAmendmentsPageCtrlr.ContainerWrapper(); 
        
        System.runAs(objUser){
            try{
                Test.startTest();                
                resultContainer = PyAp_PaymentAmendmentsPageCtrlr.getExistingPaymentAccount(objPayment.Id);  
                Test.stopTest();
            }catch(exception e){
                exceptionStr = true;              	  
            }
        }     
        System.assert(resultContainer.Account == null);
    }
    
    /******************************************************************************
	@author:      Echo: Neha R
	@date:        18-06-2018  
	@description: Test Method to
	*******************************************************************************/
    static testmethod void retrievePaymentFields_testmethod()
    {     
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Boolean exceptionStr = false;
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();  
        
        System.runAs(objUser){
            try{
                Test.startTest();                
                twoColFormattedList = PyAp_PaymentAmendmentsPageCtrlr.retrievePaymentFields();  
                Test.stopTest();
                System.assert(twoColFormattedList.size() > 0);
            }catch(exception e){
                exceptionStr = true;              	  
            }
        }   
        
       // System.assert(resultContainer.Account == null);
    }
    
}