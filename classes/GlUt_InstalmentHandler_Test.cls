/******************************************************************************
@author:      Echo: Swati Mathur
@date:        14 February 2018
@description: Test Class for GlUt_InstalmentHandler
*******************************************************************************/

@isTest
public class GlUt_InstalmentHandler_Test {
   
    //Variable declaration start
    private static String USER_PROFILE = 'System Administrator';
    private static final String USER_FNAME= 'TestFName';
    private static final String USER_LNAME= 'TestLName';
    private static String USER_NAME = 'TestUser';
    private static String USER_NAME_COMPLETE = USER_NAME+ '@unitest.com'; 
    private static String ACCOUNT_NAME = 'TestAccount';
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static integer LIST_SIZE = 200;
    private static integer LIST_START = 0;
    private static String PAYMENT_PLAN_TYPE_NAME = 'Test Payment Plan Type1';
    private static String FREQUENCY = 'Monthly';
    private static Integer MAX_INSTALMENT = 12;
    private static Integer PLAN_AMOUNT = 12345;
    private static Integer NUMBER_OF_INSTALMENTS = 07; 
    private static Integer INSTALMENT_AMOUNT_DUE = 100;
    private static String PLAN_TYPE = 'Instalment Plan';
    
    //MT - 27-08-2018 Start of AT-3429 
    private static Integer INSTALMENTAMOUNTDUE = 500;
    private static Integer SUMOFALLOCATEDPAYMENT = 200;
    //End of AT-3429
    
    // Trigger Specific variables
    private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';
    
    /*******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        
        Database.insert(objContract);
        
        //MT - 27-08-2018 Start of AT-3429
        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract);
        Database.insert(objDebtRecProcess);
        objContract.CurrentDebtRecoveryProcess__c = objDebtRecProcess.Id;
        Database.update(objContract);
        //End of AT-3429
        
        //Create payment plan type record
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE_NAME, FREQUENCY, MAX_INSTALMENT);
        objPaymentPlanType.PlanType__c = PLAN_TYPE;
        Database.insert(objPaymentPlanType);
        
        //Create payment plan record
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
        
    }
   
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    static testmethod void insertInstalment_Bulk(){
        //Query user record created in test setup data method
        User objUser =[SELECT id,name FROM user WHERE isActive = true AND username =: USER_NAME_COMPLETE LIMIT 1];
        PaymentPlan__c objPP = [SELECT id FROM PaymentPlan__c];
        
        List<Instalment__c> lstInstalment = new List<Instalment__c>();
        for(integer i=LIST_START; i<LIST_SIZE; i++)
        {
            Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPP);
            lstInstalment.add(objInstalment);
        }
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.insert(lstInstalment);            
            System.assert(lstInstalment.size()>0);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
                
    }
  
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A  
    ********************************************************************/
    static testmethod void updateInstalment_Bulk(){
        //Query user record created in test setup data method
        User objUser =[SELECT id,name FROM user WHERE isActive = true AND username =: USER_NAME_COMPLETE LIMIT 1];
        PaymentPlan__c objPP = [SELECT id FROM PaymentPlan__c];
        
        //MT - 27-08-2018 Start of AT-3429
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE AccountName__c = :objAccount.Id LIMIT 1];
        DebtRecoveryProcess__c objDebtRecProcess = [SELECT Id FROM DebtRecoveryProcess__c WHERE BillingContract__c = :objContract.Id LIMIT 1];

        List<DebtRecoveryInstalment__c> lstDebtRecoveryInstalment = new List<DebtRecoveryInstalment__c>();
        //End of AT-3429
    
        List<Instalment__c> lstInstalment = new List<Instalment__c>();
        for(integer i=LIST_START; i<LIST_SIZE; i++)
        {
            Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPP);
            //MT - 27-08-2018 Start of AT-3429
            objInstalment.InstalmentAmountDue__c = INSTALMENTAMOUNTDUE;
            objInstalment.SumofAllocatedPayment__c = SUMOFALLOCATEDPAYMENT; 
            //End of AT-3429
            lstInstalment.add(objInstalment);
        }
        Database.insert(lstInstalment);
        for(integer i=LIST_START; i<LIST_SIZE; i++)
        {
            lstInstalment[i].InstalmentDueDate__c = system.today().addDays(2);
            //MT - 27-08-2018 Start of AT-3429
            DebtRecoveryInstalment__c objDebtRecoveryInstalment = GlUt_FactoryData_Test.createDebtRecoveryInstalment(objDebtRecProcess, lstInstalment[i]);
            lstDebtRecoveryInstalment.add(objDebtRecoveryInstalment);
            if(i < 100)
               lstInstalment[i].InstalmentAmountDue__c += 100;
            else
               lstInstalment[i].SumofAllocatedPayment__c += 50;  
            
        }
        Database.insert(lstDebtRecoveryInstalment);
        //End of AT-3429
        
        List<PaymentAllocationQueue__c> lstPaymntAllocatQueue = new List<PaymentAllocationQueue__c>();       
       
        for(PaymentAllocationQueue__c objPaymntAllocatQueue:  [SELECT id,Status__c,Operation__c FROM PaymentAllocationQueue__c]){
            objPaymntAllocatQueue.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_PROCESSSED;
            lstPaymntAllocatQueue.add(objPaymntAllocatQueue);
        }
        //changed the stauts of a Payment Allocation Queue record to NEW to cover scenario at line 121
        lstPaymntAllocatQueue[0].Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_NEW; 
        Update lstPaymntAllocatQueue;
                    
        
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstInstalment); 
            for(DebtRecoveryInstalment__c objDebtRecoveryInstalment : [SELECT Id, InstalmentAmountDue__c From DebtRecoveryInstalment__c WHERE Id IN : lstDebtRecoveryInstalment]){
                System.assert(objDebtRecoveryInstalment.InstalmentAmountDue__c != Null);
            }
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }        
       
    }
    
    /*******************************************************************
    @author:      Echo: Mohit Tayal
    @date:        30-08-2018
    @params:      Test bulk Insert for Instalment
    @returns:     void
    @description: AT - 3429 Testing Negative scenario for update trigger   
    ********************************************************************/
    static testmethod void updateInstalment_Negative(){
        //Query user record created in test setup data method
        User objUser =[SELECT id,name FROM user WHERE isActive = true AND username =: USER_NAME_COMPLETE LIMIT 1];
        PaymentPlan__c objPP = [SELECT id FROM PaymentPlan__c];
        
        //MT - 27-08-2018 Start of AT-3429
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE AccountName__c = :objAccount.Id LIMIT 1];
        //End of AT-3429
    
        List<Instalment__c> lstInstalment = new List<Instalment__c>();
        for(integer i=LIST_START; i<LIST_SIZE; i++)
        {
            Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPP);
            //MT - 27-08-2018 Start of AT-3429
            objInstalment.InstalmentAmountDue__c = INSTALMENTAMOUNTDUE;
            objInstalment.SumofAllocatedPayment__c = SUMOFALLOCATEDPAYMENT;
            //End of AT-3429
            lstInstalment.add(objInstalment);
        }
        Database.insert(lstInstalment);
        
        for(integer i=LIST_START; i<LIST_SIZE; i++)
        {
            lstInstalment[i].InstalmentDueDate__c = system.today().addDays(2);
            if(i < 100)
               lstInstalment[i].InstalmentAmountDue__c += 100;
            else
               lstInstalment[i].SumofAllocatedPayment__c += 50;  
            
        }
        
        List<PaymentAllocationQueue__c> lstPaymntAllocatQueue = new List<PaymentAllocationQueue__c>();       
       
        for(PaymentAllocationQueue__c objPaymntAllocatQueue:  [SELECT id,Status__c,Operation__c FROM PaymentAllocationQueue__c]){
            objPaymntAllocatQueue.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_PROCESSSED;
            lstPaymntAllocatQueue.add(objPaymntAllocatQueue);
        }
        //changed the stauts of a Payment Allocation Queue record to NEW to cover scenario at line 121
        lstPaymntAllocatQueue[0].Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_NEW; 
        Database.update(lstPaymntAllocatQueue);
                    
        
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstInstalment);       
            System.assert(!lstInstalment.isEmpty());
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }        
       
    }
}