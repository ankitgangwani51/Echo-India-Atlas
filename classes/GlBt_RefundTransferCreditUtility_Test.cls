/******************************************************************************
@author:      Echo: Ankit Gangwani 
@date:        05 July 2018
@description: Test Class for GlBt_RefundTransferCreditUtility
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class GlBt_RefundTransferCreditUtility_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME 			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name'; 
    private static final String NAME 				= 'Test';
    private static final String PAYMENT_FREQUENCY 	= 'Monthly';
    private static final Integer NO_OF_INSTALMENT 	= 5;
    private static final String BUDGET_PLAN 		= 'Budget Plan';
    private static final String REFUND 				= 'Refund';
    private static final String MONTHLY				= 'Monthly';
    private static final String DIRECTDEBIT			= 'Direct Debit';
    private static final String FULLYALLOCATED		= 'Fully Allocated';
    /*****************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        04 July 2018
    @description: Test data setup method
    ******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(NAME);
        Database.insert(objAccount);    
        
        // Create Payment Plan Type
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(NAME, PAYMENT_FREQUENCY, NO_OF_INSTALMENT);
        objPaymentPlanType.PlanType__c = BUDGET_PLAN;
        objPaymentPlanType.CreditHandling__c = REFUND;
        objPaymentPlanType.NumberofRollingInstalments__c = 2.0;
        objPaymentPlanType.MinRefundHousehold__c = 10.00;
        objPaymentPlanType.MaxRefundHousehold__c = 200.00;
        objPaymentPlanType.MaxRenewalThreshold__c = 150;
        objPaymentPlanType.MinRenewalThreshold__c = 10;
        objPaymentPlanType.AlignBudgetPlanRenewalToReadings__c = true;
		objPaymentPlanType.PaymentFrequency__c = MONTHLY;        
        objPaymentPlanType.EndDate__c = '01/01';
        Database.insert(objPaymentPlanType);
        
        // Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);          
        Database.insert(objBalance);
        
        // Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(NAME, objAccount);
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.Balance__c = objBalance.Id;
        objContract.PaymentPlanRenewalDate__c = Date.today();
        objContract.DayOfWeek__c = System.Label.VmDr_MondayLabel;
        objContract.DayOfMonth__c = '3';
        objContract.BudgetPlanHold__c = True;  
        objContract.LastBillCalculationDate__c = Date.today().addMonths(-1);
        Database.insert(objContract);
        
        Id PAYMENTRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
       
        // Create Payment Record
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        objPayment.PaymentDate__c = Date.today();
        objPayment.CreditAmount__c = 100.00;
        objPayment.RecordTypeId = PAYMENTRECORDTYPEONPAYMENT;
        objPayment.Amount__c = 50.00;
        objPayment.BillAllocationStatus__c = FULLYALLOCATED;
        objPayment.PaymentMethod__c = DIRECTDEBIT;
        objPayment.InstalmentAmountUnallocated__c = 10.00;
        objPayment.AmendmentReason__c = REFUND;
        objPayment.BillAmountUnallocated__c = 15.00;
        objPayment.ReversedAmount__c = 16.00;
        objPayment.BillingContract__c = objContract.Id;
        Database.insert(objPayment);
        
    }
    
    /*****************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        05 July 2018
    @description: Method to test getExistingPaymnts for GlBt_RefundTransferCreditUtility 
    to get all Existing Payment Records
    ******************************************************************************/
    static testmethod void refundCreditUtility_First()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Set<Id> setContractIds = new Set<Id>();
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        setContractIds.add(objContract.Id);
        List<Payment__c> paymentLists = new List<Payment__c>();
        
        System.runAs(objUser){
            Test.startTest();       
            paymentLists = GlBt_RefundTransferCreditUtility.getExistingPaymnts(setContractIds);
            Test.stopTest();
            System.assert(paymentLists.size() > 0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        05 July 2018
    @description: Method to test creditRefund for GlBt_RefundTransferCreditUtility 
    to create new payment record and update existing payment records with Amount__c = 100.00
    *******************************************************************************/
    static testmethod void creditRefund_Positive()
    {            
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive = TRUE
                        AND USERNAME =: USERNAMECOMPLETE 
                        LIMIT 1];
        
        Account objAccount = [SELECT Id 
                              FROM Account 
                              LIMIT 1];
        
        BillingContract__c objContract = [SELECT Id 
                                          FROM BillingContract__c 
                                          LIMIT 1];
        
        List<Payment__c> listNewPayment = new List<Payment__c>();
        
        List<Payment__c> existingPaymentList = [SELECT Id, 
                                                PaymentDate__c,
                                                CreditAmount__c,
                                                RecordTypeId,
                                                Amount__c,
                                                BillAllocationStatus__c,
                                                PaymentMethod__c,
                                                InstalmentAmountUnallocated__c,
                                                AmendmentReason__c,
                                                BillAmountUnallocated__c,
                                                ReversedAmount__c,
                                                BillingContract__c
                                                FROM Payment__c];
        
        // Create Payment Record
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        objPayment.PaymentDate__c = Date.today();
        objPayment.CreditAmount__c = 100.00;
        objPayment.Amount__c = 100.00;
        objPayment.BillAllocationStatus__c = FULLYALLOCATED;
        objPayment.PaymentMethod__c = DIRECTDEBIT;
        objPayment.InstalmentAmountUnallocated__c = 10.00;
        objPayment.AmendmentReason__c = REFUND;
        objPayment.BillAmountUnallocated__c = 15.00;
        objPayment.ReversedAmount__c = 16.00;
        objPayment.BillingContract__c = objContract.Id;
        listNewPayment.add(objPayment);        
        
        System.runAs(objUser){
            Test.startTest();       
            GlBt_RefundTransferCreditUtility.creditRefund(listNewPayment, existingPaymentList);
            Test.stopTest();
            
            List<PaymentAssociation__c> paymentAssocistionList = [SELECT Id,Name FROM PaymentAssociation__c WHERE OriginalPayment__c =: existingPaymentList[0].Id];
            System.assert(paymentAssocistionList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        05 July 2018
    @description: Method to test creditRefund for GlBt_RefundTransferCreditUtility 
    to create new payment record and update existing payment records with Amount__c = 30.00
    *******************************************************************************/
    static testmethod void refundCreditUtility_Third()
    {            
        User objUser =[SELECT Id,Name 
                       FROM user 
                       WHERE isActive = TRUE 
                       AND USERNAME =:USERNAMECOMPLETE 
                       LIMIT 1];
        
        Account objAccount = [SELECT Id
                              FROM Account 
                              LIMIT 1];
        
        BillingContract__c objContract = [SELECT Id 
                                          FROM BillingContract__c 
                                          LIMIT 1];
        
        List<Payment__c> listNewPayment = new List<Payment__c>();
        
        List<Payment__c> existingPaymentList = [SELECT Id, 
                                                PaymentDate__c,
                                                CreditAmount__c,
                                                RecordTypeId,
                                                Amount__c,
                                                BillAllocationStatus__c,
                                                PaymentMethod__c,
                                                InstalmentAmountUnallocated__c,
                                                AmendmentReason__c,
                                                BillAmountUnallocated__c,
                                                ReversedAmount__c,
                                                BillingContract__c
                                                FROM Payment__c];
        
        // Create Payment Record
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        objPayment.PaymentDate__c = Date.today();
        objPayment.CreditAmount__c = 100.00;
        objPayment.Amount__c = 30.00;
        objPayment.BillAllocationStatus__c = FULLYALLOCATED;
        objPayment.PaymentMethod__c = DIRECTDEBIT;
        objPayment.InstalmentAmountUnallocated__c = 10.00;
        objPayment.AmendmentReason__c = REFUND;
        objPayment.BillAmountUnallocated__c = 15.00;
        objPayment.ReversedAmount__c = 16.00;
        objPayment.BillingContract__c = objContract.Id;
        listNewPayment.add(objPayment);        
        
        System.runAs(objUser){
            Test.startTest();       
           
            GlBt_RefundTransferCreditUtility.creditRefund(listNewPayment, existingPaymentList);
            Test.stopTest();
            
            List<PaymentAssociation__c> paymentAssocistionList = [SELECT Id,Name FROM PaymentAssociation__c WHERE OriginalPayment__c =: existingPaymentList[0].Id];
            System.assert(paymentAssocistionList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        05 July 2018
    @description: Method to test creditRefund for GlBt_RefundTransferCreditUtility 
    to create new payment record and update existing payment records with Amount__c = 30.00
    ReversedAmount__c = null, InstalmentAmountUnallocated__c = null, BillAmountUnallocated__c = null
    *******************************************************************************/
    static testmethod void refundCreditUtility_Fourth()
    {            
        User objUser =[SELECT Id,Name 
                       FROM user 
                       WHERE isActive = TRUE
                       AND USERNAME =:USERNAMECOMPLETE
                       LIMIT 1];
        
        Account objAccount = [SELECT Id 
                              FROM Account
                              LIMIT 1];
        
        BillingContract__c objContract = [SELECT Id 
                                          FROM BillingContract__c
                                          LIMIT 1];
        
        List<Payment__c> existingPaymentList = new List<Payment__c>();        
        List<Payment__c> listNewPayment = new List<Payment__c>();
        
        Payment__c existPayment = [SELECT Id, 
                                   PaymentDate__c,
                                   CreditAmount__c,
                                   RecordTypeId,
                                   Amount__c,
                                   BillAllocationStatus__c,
                                   PaymentMethod__c,
                                   InstalmentAmountUnallocated__c,
                                   AmendmentReason__c,
                                   BillAmountUnallocated__c,
                                   ReversedAmount__c,
                                   BillingContract__c
                                   FROM Payment__c LIMIT 1];
        
        existPayment.ReversedAmount__c = null;
        existPayment.InstalmentAmountUnallocated__c = null;
        existPayment.BillAmountUnallocated__c = null;
        update existPayment;
        existingPaymentList.add(existPayment);
            
        // Create Payment Record
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        objPayment.PaymentDate__c = Date.today();
        objPayment.CreditAmount__c = 100.00;
        objPayment.Amount__c = 30.00;
        objPayment.BillAllocationStatus__c = FULLYALLOCATED;
        objPayment.PaymentMethod__c = DIRECTDEBIT;
        objPayment.InstalmentAmountUnallocated__c = 10.00;
        objPayment.AmendmentReason__c = REFUND;
        objPayment.BillAmountUnallocated__c = 15.00;
        objPayment.ReversedAmount__c = 16.00;
        objPayment.BillingContract__c = objContract.Id;
        listNewPayment.add(objPayment);      
        
        System.runAs(objUser){
            Test.startTest();       
            GlBt_RefundTransferCreditUtility.creditRefund(listNewPayment, existingPaymentList);
            Test.stopTest();   
            
            List<PaymentAssociation__c> paymentAssocistionList = [SELECT Id,Name FROM PaymentAssociation__c WHERE OriginalPayment__c =: existingPaymentList[0].Id];
            System.assert(paymentAssocistionList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Sept 2018
    @description: Method to test creditRefund for GlBt_RefundTransferCreditUtility with Negative Scenario
    *******************************************************************************/
    static testmethod void creditRefund_Negative()
    {            
        Boolean isExpected = false;
        User objUser =[SELECT Id,Name 
                       FROM user 
                       WHERE isActive = TRUE
                       AND USERNAME =:USERNAMECOMPLETE
                       LIMIT 1];
        
        Account objAccount = [SELECT Id 
                              FROM Account
                              LIMIT 1];
        
        BillingContract__c objContract = [SELECT Id 
                                          FROM BillingContract__c
                                          LIMIT 1];
        
        List<Payment__c> existingPaymentList = new List<Payment__c>();        
        List<Payment__c> listNewPayment = new List<Payment__c>();
            
        // Create Payment Record
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        objPayment.PaymentDate__c = Date.today();
        objPayment.CreditAmount__c = 100.00;
        objPayment.Amount__c = 30.00;
        objPayment.BillAllocationStatus__c = FULLYALLOCATED;
        objPayment.PaymentMethod__c = DIRECTDEBIT;
        objPayment.InstalmentAmountUnallocated__c = 10.00;
        objPayment.AmendmentReason__c = REFUND;
        objPayment.BillAmountUnallocated__c = 15.00;
        objPayment.ReversedAmount__c = 16.00;
        objPayment.BillingContract__c = objContract.Id;
        listNewPayment.add(objPayment);      
        
        System.runAs(objUser){
            try{
                Test.startTest();       
                GlBt_RefundTransferCreditUtility.creditRefund(listNewPayment, NULL);
                Test.stopTest();            
            }catch(Exception ex) {
                isExpected = TRUE;
                system.debug('exception caught in test context:: ' + ex);                                
            }
            System.assert(isExpected == TRUE);
        }
    }

}