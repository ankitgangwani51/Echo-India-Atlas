/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        17 Feb 2018
@description: Test Class for GlUt_BalanceHandler 
*******************************************************************************/
@isTest
public class GlUt_BalanceHandler_Test {
    
    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String USER_FNAME			= 'FN123';
    private static final String USER_LNAME			= 'LN123';
    private static String CONTACT_NAME 				= 'Test Contact';
    private static Decimal AMOUNT 					= 100.0;
    private static Decimal NEWAMOUNT 			 	= 150.0;
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static String MONTHLY 					= Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    private static String PAYMENT_METHOD_TYPE1 		= 'Payment Card';
    private static String PLAN_NAME 				= 'DD FORTNIGHTLY';
    private static String PAY_FREQ 					= 'Monthly';
    private static Integer NUM_OF_INSTAL 			= 3;
    private static String AVAIL_PAY_DAY_NAME 		= 'APD Monday';
    private static String DAY_OF_MONTH 				= '2';
    private static String DAY_OF_WEEK 				= 'Monday';
    
    /*******************************************************************
    @author:      Echo: Tarun Gupta
    @date:        17 Feb 2018
    @param:       N/A
    @return:      void
    @description: method to create test data used by all test methods
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE1;
        Database.insert(objPaymentMethodType);
        
        PaymentPlanType__c  objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME,PAY_FREQ,NUM_OF_INSTAL);
        objPaymentPlanType.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypeInstalmentPlan;
        objPaymentPlanType.FinalPaymentPlan__c = true;
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.Active__c = true;
        objPaymentPlanType.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType.MaximumNumberOfInstalments__c = 4;
        Database.insert(objPaymentPlanType);
        
        PaymentMethod__c  objPaymentMethod = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType,objPaymentPlanType);
        Database.insert(objPaymentMethod);
        
        AvailablePaymentDay__c  objAvailPaymentDay = GlUt_FactoryData_Test.createAvailPaymentDay(AVAIL_PAY_DAY_NAME,DAY_OF_MONTH,DAY_OF_WEEK,objPaymentMethodType);
        Database.insert(objAvailPaymentDay);
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);
        
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction.BillItemAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.BillAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill').getRecordTypeId(); // AT-3275
        Database.insert(objBalanceTransaction);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.Balance__c = objBalance.Id;
        Database.insert(objContract);
        
    }
    
    /*******************************************************************
    @author:      Echo: Tarun Gupta
    @date:        17 Feb 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for calculateNewPaymentPlans
    ********************************************************************/
        
    static testmethod void calculateNewPaymentPlans_PositiveTest(){
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Account objAccount = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   		  Name,
                                   		  DayOfMonth__c,
                                   		  DayOfWeek__c,
                                   		  CurrentPaymentPlanType__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        Balance__c objBalance = [SELECT Id,
                                		Name,
                                		Account__c,
                                		Balance__c
                                FROM Balance__c
                                WHERE Account__c =: objAccount.Id  LIMIT 1];
        
        BalanceTransaction__c objBalanceTransaction = [Select Id,
                                                       		  Name,
                                                       		  //BillItemAmount__c // AT-3275
                                                       		  BillAmount__c // AT-3275
                                                       FROM BalanceTransaction__c
                                                       WHERE Balance__c =: objBalance.Id LIMIT 1];
        
        //objBalanceTransaction.BillItemAmount__c = NEWAMOUNT; // AT-3275
        objBalanceTransaction.BillAmount__c = NEWAMOUNT; // AT-3275
            
        System.runAs(objUser[0]){
            Test.starttest();
            update objBalanceTransaction;
            Test.stoptest();
            
            Balance__c objBalanceUpdated = [SELECT Id,
                                                   Name,
                                                   Account__c,
                                                   Balance__c,
                                            	   //TotalBillItemAmount__c // AT-3275
                                            	   TotalBillAmount__c // AT-3275
                                            FROM Balance__c
                                            WHERE Account__c =: objAccount.Id  LIMIT 1];
            
            //Decimal billAmount =  objBalanceUpdated.TotalBillItemAmount__c; // AT-3275
            Decimal billAmount =  objBalanceUpdated.TotalBillAmount__c; // AT-3275
            
            system.assertEquals(NEWAMOUNT, billAmount);
            
        }
        
    }
    
}