/******************************************************************************
@author         Vivek Sethi
@date           02 July 2018
@description    Test Class For PyBt_DirectDebitRequestExport
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class PyBt_DirectDebitRequestExport_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String ACCOUNT_NAME            = 'TestAccount';
    private static final Date INSTALMENT_DUE_DATE	 	= system.today();
    private static final String  PAYMENT_PLAN_TYPE     = 'New Payment Plan';
    private static final String PAYMENT_FREQ           = 'Monthly';
    private static final Integer MAX_INSTALLMENT       = 12;
    private static final Integer PLAN_AMOUNT           = 50;
    private static final Integer INSTALMENT_AMOUNT_DUE = 50;
    private static final Integer SUM_OF_ALLOCATED_PAY  = 10;
     
    private class BRQParameters_JSON {
   		  private  Date requestDate;
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           02 July 2018
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
    
        //Create Account
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Bank Account Details
        BankAccountDetails__c objBankAccountDetails = GlUt_FactoryData_Test.createBankAccountDetails(objAccount);
        Database.insert(objBankAccountDetails);
        
        //Create Payment Method Type
        PaymentMethodType__c objPaymentMethodType   = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PyBt_Constants.PAYMENT_METHOD_TYPE_DIRECTDEBIT; 
        Database.insert(objPaymentMethodType);
        
        //Create Contract
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        objContract.PaymentMethodType__c = objPaymentMethodType.Id;
        objContract.BankAccountDetails__c = objBankAccountDetails.Id;
        Database.insert(objContract);
        
        // Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE, PAYMENT_FREQ, MAX_INSTALLMENT);
        Database.insert(objPaymentPlanType);
        
        // Create PaymentPlan Record            
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract, PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
        
        // Create Bulk Instalments Record  
        List<Instalment__c> instalmentList = new List<Instalment__c>();  
        for(integer i = 0; i < 100 ; i++)
        {          
            Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);      
            objInstalment.InstalmentDueDate__c     = INSTALMENT_DUE_DATE;
            objInstalment.InstalmentAmountDue__c   = INSTALMENT_AMOUNT_DUE;
            objInstalment.SumofAllocatedPayment__c = SUM_OF_ALLOCATED_PAY;
            instalmentList.add(objInstalment);
        }
        Database.insert(instalmentList); 
       
        BRQParameters_JSON brqObj = new  BRQParameters_JSON();
        brqObj.requestDate =  system.today();
        
        //Create BatchRequestQueue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Parameters__c = JSON.serialize(brqObj);
        Database.insert(objBatchRequestQueue);
        
         //Create Direct Debit Request Record
         List<DirectDebitRequest__c> directDebitRequestList = new List<DirectDebitRequest__c>();
         for(Instalment__c InstalmentObj : instalmentList)
        {
            DirectDebitRequest__c objDirectDebitRequest = GlUt_FactoryData_Test.createDirectDebitRequest(objContract , InstalmentObj);
            directDebitRequestList.add(objDirectDebitRequest);
        }
        Database.insert(directDebitRequestList);
    }
    /******************************************************************************
	@author         Vivek Sethi
	@date           02 July 2018
	@description:   Test Method to check LoBt_ExportBooks Batch class
	*******************************************************************************/
    static testmethod void PyBt_DirectDebitRequestExport_Positive() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        BatchRequestQueue__c BatchRequestQueue = [select Id , Parameters__c from BatchRequestQueue__c limit 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            PyBt_DirectDebitRequestExport  obj = new PyBt_DirectDebitRequestExport();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
            System.assertEquals(BatchRequestQueue.Id, obj.batchRequestQueue.Id);
        }
    }

    /******************************************************************************
	@author         Vivek Sethi
	@date           08 June 2018
	@description:   Test Method to check PyBt_DirectDebitRequestExport Batch class Negative Scenario
	*******************************************************************************/
    static testmethod void PyBt_DirectDebitRequestExport_Negative() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                PyBt_DirectDebitRequestExport obj = new PyBt_DirectDebitRequestExport();
                PyPr_DirectDebitRequestParameters.parse(null);
                DataBase.executeBatch(obj);
            }
            catch(Exception e)
            {
                isException = true;            
            }
            Test.stopTest();
        }
        System.assert(isException == true);
    }

}