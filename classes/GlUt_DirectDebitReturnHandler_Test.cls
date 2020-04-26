/******************************************************************************
@author         Vivek Sethi
@date           04 July 2018
@description    Test Class For GlUt_DirectDebitReturnHandler
*******************************************************************************/
@isTest
public class GlUt_DirectDebitReturnHandler_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final Date INSTALMENT_DUE_DATE	 	= system.today();
    private static final String  PAYMENT_PLAN_TYPE     = 'New Payment Plan';
    private static final String PAYMENT_FREQ           = 'Monthly';
    private static final Integer MAX_INSTALLMENT       = 12;
    private static final Integer PLAN_AMOUNT           = 50;
    private static final Integer INSTALMENT_AMOUNT_DUE = 50;
    private static final Integer SUM_OF_ALLOCATED_PAY  = 10;
    private static final String ACCOUNT_NAME            = 'TestAccount';
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           04 July 2018
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
    
        //Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        Database.insert(objContract);
        
        // Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE, PAYMENT_FREQ, MAX_INSTALLMENT);
        Database.insert(objPaymentPlanType);
        
        // Create PaymentPlan Record            
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract, PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
        
        // Create Instalment Record            
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);      
        objInstalment.InstalmentDueDate__c     = INSTALMENT_DUE_DATE;
        objInstalment.InstalmentAmountDue__c   = INSTALMENT_AMOUNT_DUE;
        objInstalment.SumofAllocatedPayment__c = SUM_OF_ALLOCATED_PAY;
        Database.insert(objInstalment); 
        
        //Create Direct Debit Request Record
        DirectDebitRequest__c objDirectDebitRequest = GlUt_FactoryData_Test.createDirectDebitRequest(objContract , objInstalment);
        objDirectDebitRequest.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED ;
        objDirectDebitRequest.RequestDate__c = system.today();
        Database.insert(objDirectDebitRequest);
        
        //Create Payment Record
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        objPayment.DirectDebitRequest__c = objDirectDebitRequest.Id;
        Database.insert(objPayment);
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           04 July 2018
	@description:   Test Method to check GlUt_DirectDebitReturnHandler Positive scenario
	*******************************************************************************/
    static testmethod void GlUt_DirectDebitReturnHandler_Positive() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c objContract = [select Id  from BillingContract__c limit 1]; 
        DirectDebitReturn__c objDirectDebitReturn =  new DirectDebitReturn__c();
        System.runAs(objUser){
            Test.startTest();
            //Create Direct Debit Return Record
            objDirectDebitReturn = GlUt_FactoryData_Test.createDirectDebitReturn(objContract);
            Database.insert(objDirectDebitReturn);
            Test.stopTest();
        }
        DirectDebitRequest__c objDirectDebitRequest = [select Id, Instalment__c  from DirectDebitRequest__c limit 1];
        Payment__c objPayment = [select Id, BillingContract__c  from Payment__c limit 1]; 
        DirectDebitReturn__c objDirectDebitReturn1 =  [select Id, Instalment__c, BillingContract__c, DirectDebitRequest__c  from DirectDebitReturn__c where Id =: objDirectDebitReturn.Id limit 1];
      
        system.assertEquals(objDirectDebitReturn1.Instalment__c, objDirectDebitRequest.Instalment__c);
        system.assertEquals(objDirectDebitReturn1.BillingContract__c, objPayment.BillingContract__c);
        system.assertEquals(objDirectDebitReturn1.DirectDebitRequest__c, objDirectDebitRequest.Id);        
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           04 July 2018
    @description:   Test Method to check  GlUt_DirectDebitReturnHandler  negative scenario 
	*******************************************************************************/
    static testmethod void PyBt_DirectDebitReturnProcess_Negative() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c objContract = new BillingContract__c(); 
        Boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                //Create Direct Debit Return Record
                DirectDebitReturn__c objDirectDebitReturn = GlUt_FactoryData_Test.createDirectDebitReturn(objContract);
                Database.insert(objDirectDebitReturn);
            } catch(Exception ex){
                isException = True;
            }
            Test.stopTest();
            system.assertEquals(isException, True);
        }
    }
 }