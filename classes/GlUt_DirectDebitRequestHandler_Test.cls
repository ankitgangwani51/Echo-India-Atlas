/******************************************************************************
@author         Vivek Sethi
@date           04 July 2018
@description    Test Class For GlUt_DirectDebitRequestHandler
*******************************************************************************/
@isTest
public class GlUt_DirectDebitRequestHandler_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final Date INSTALMENT_DUE_DATE	 	= system.today();
    private static final String  PAYMENT_PLAN_TYPE      = 'New Payment Plan';
    private static final String PAYMENT_FREQ            = 'Monthly';
    private static final Integer MAX_INSTALLMENT        = 12;
    private static final Integer PLAN_AMOUNT            = 50;
    private static final Integer INSTALMENT_AMOUNT_DUE  = 50;
    private static final Integer SUM_OF_ALLOCATED_PAY   = 10;
    private static final String ACCOUNT_NAME            = 'TestAccount';
    private static final String INVALID_STATUS          = 'Test';
    
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
        objDirectDebitRequest.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_PENDING ;
        objDirectDebitRequest.RequestDate__c = system.today();
        Database.insert(objDirectDebitRequest);
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           04 July 2018
	@description:   Test Method to check allocatePaymentToDirectDebitRequest method Positive scenario
	*******************************************************************************/
    static testmethod void allocatePaymentToDirectDebitRequest_Positive() {
        User objUser = [SELECT Id, Name FROM User WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        DirectDebitRequest__c objDirectDebitRequest = [SELECT Id, Status__c  FROM DirectDebitRequest__c LIMIT 1]; 
        objDirectDebitRequest.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED;  
            
        System.runAs(objUser){
            Test.startTest();
            update objDirectDebitRequest;
            Test.stopTest();
        }
	    Instalment__c objInstalment = [SELECT Id, InstalmentDueDate__c, InstalmentAmountDue__c  FROM Instalment__c LIMIT 1];
        Payment__c objPayment = [SELECT Id, Amount__c, PaymentDate__c  FROM Payment__c WHERE DirectDebitRequest__c =:  objDirectDebitRequest.Id LIMIT 1]; 
        
        system.assertEquals(objPayment.Amount__c, objInstalment.InstalmentAmountDue__c);
        system.assertEquals(objPayment.PaymentDate__c, objInstalment.InstalmentDueDate__c);   
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           04 July 2018
    @description:   Test Method to check allocatePaymentToDirectDebitRequest  negative scenario 
	*******************************************************************************/
    static testmethod void  allocatePaymentToDirectDebitRequest_Negative() {
        User objUser = [SELECT Id, Name FROM User WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        DirectDebitRequest__c objDirectDebitRequest = [SELECT Id, Status__c  FROM DirectDebitRequest__c LIMIT 1]; 
        objDirectDebitRequest.Status__c = INVALID_STATUS;  
        Boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                update objDirectDebitRequest;
            } catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            system.assertEquals(isException, true);
        }
    }
 }