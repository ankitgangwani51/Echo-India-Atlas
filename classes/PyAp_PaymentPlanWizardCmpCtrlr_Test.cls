/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        13 Feb 2018
@description: Test Class for PyAp_PaymentPlanWizardCmpCtrlr
*******************************************************************************/
@isTest
public class PyAp_PaymentPlanWizardCmpCtrlr_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';

	private static String PAYMENT_METHOD_TYPE1 = 'Payment Card';
    private static String PAYMENT_METHOD_TYPE2 = 'Giro Slips';
    private static String PAYMENT_METHOD_TYPE3 = 'Direct Debit';
    private static String PLAN_NAME = 'DD FORTNIGHTLY';
    private static String PAY_FREQ = 'Monthly';
    private static Integer NUM_OF_INSTAL = 5;
    private static String PLAN_NAME2 = 'PAY IN FULL';
    private static String PAY_FREQ2 = 'Monthly';
    private static Integer NUM_OF_INSTAL2 = 1;
    private static String PLAN_NAME3 = 'BUDGET PLAN';
    private static String PAY_FREQ3 = 'Fortnightly';
    private static Integer NUM_OF_INSTAL3 = 4;
    private static String AVAIL_PAY_DAY_NAME = 'APD Monday';
    private static String DAY_OF_MONTH = '2';
    private static String DAY_OF_WEEK = 'Monday';
    private static String ACCOUNT_NAME = 'Test Account';
    private static String CONTACT_NAME = 'Test Contact';
    private static String PROFILE = 'Profile 1';
    private static String BUDGETPLAN = 'Budget Plan';
    private static String INSTALMAENTPLAN = 'Instalment Plan';
    private static String PAYINFULL = 'Pay In Full';
    private static String REMINDER1 ='Reminder 1';
    private static String HOLDREASON = 'Instalment Amount out of Threshhold';
    
    private static final INTEGER CREDITAMOUNT = 100; 
    private static final INTEGER BANKACCOUNTNUMBER = 23232;
    private static final INTEGER AMOUNT   = 5; 
    
    
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    @revesion :Change By Dependra Singh- 25-02-2019- Salesforce Limit Analysis
    ********************************************************************/ 
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        List<PaymentMethodType__c> lstPaymentMethodType = new List<PaymentMethodType__c>();
        PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE1;
        lstPaymentMethodType.add(objPaymentMethodType);
        
        PaymentMethodType__c  objPaymentMethodType2 = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType2.Name = PAYMENT_METHOD_TYPE2;
        lstPaymentMethodType.add(objPaymentMethodType2);
        
        PaymentMethodType__c  objPaymentMethodType3 = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType3.Name = PAYMENT_METHOD_TYPE3;
        lstPaymentMethodType.add(objPaymentMethodType3);
        Database.insert(lstPaymentMethodType);
        
        List<PaymentPlanType__c> lstPaymentPlanType = new List<PaymentPlanType__c>();
        PaymentPlanType__c  objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME,PAY_FREQ,NUM_OF_INSTAL);
        objPaymentPlanType.PlanType__c = PAYINFULL;
        objPaymentPlanType.FinalPaymentPlan__c = false;
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.Active__c = true;
        objPaymentPlanType.ResetDebtRecovery__c = true;
        objPaymentPlanType.DebtRecoveryProfile__c = PROFILE;
        lstPaymentPlanType.add(objPaymentPlanType);
        
        PaymentPlanType__c  objPaymentPlanType2 = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME2,PAY_FREQ2,NUM_OF_INSTAL2);
        objPaymentPlanType2.PlanType__c = BUDGETPLAN;
        objPaymentPlanType2.FinalPaymentPlan__c = false;
        objPaymentPlanType2.DaysNotice__c = 10;
        objPaymentPlanType2.Active__c = true;
        objPaymentPlanType2.DebtRecoveryProfile__c = PROFILE;
        lstPaymentPlanType.add(objPaymentPlanType2);
        
        PaymentPlanType__c  objPaymentPlanType3 = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME3,PAY_FREQ3,NUM_OF_INSTAL3);
        objPaymentPlanType3.PlanType__c = INSTALMAENTPLAN;
        objPaymentPlanType3.FinalPaymentPlan__c = false;
        objPaymentPlanType3.DaysNotice__c = 10;
        objPaymentPlanType3.Active__c = true;
        objPaymentPlanType3.DebtRecoveryProfile__c = PROFILE;
        lstPaymentPlanType.add(objPaymentPlanType3); 
        Database.insert(lstPaymentPlanType);
        
        List<PaymentMethod__c> lstPaymentMethod = new List<PaymentMethod__c>();
        PaymentMethod__c  objPaymentMethod = GlUt_FactoryData_Test.createPaymentMethod(lstPaymentMethodType[0],objPaymentPlanType);
        lstPaymentMethod.add(objPaymentMethod);
        
        PaymentMethod__c  objPaymentMethod2 = GlUt_FactoryData_Test.createPaymentMethod(lstPaymentMethodType[1],objPaymentPlanType2);
        lstPaymentMethod.add(objPaymentMethod2);
        
        PaymentMethod__c  objPaymentMethod3 = GlUt_FactoryData_Test.createPaymentMethod(lstPaymentMethodType[2],objPaymentPlanType3);
        lstPaymentMethod.add(objPaymentMethod3);
        Database.insert(lstPaymentMethod);
        
        
        AvailablePaymentDay__c  objAvailPaymentDay = GlUt_FactoryData_Test.createAvailPaymentDay(AVAIL_PAY_DAY_NAME,DAY_OF_MONTH,DAY_OF_WEEK,lstPaymentMethodType[0]);
        Database.insert(objAvailPaymentDay);
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);
        
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction.BillItemAmount__c = 100; // AT-3275
        objBalanceTransaction.BillAmount__c = 100; // AT-3275
        objBalanceTransaction.PaymentAmount__c = 100;
        objBalanceTransaction.RefundAmount__c = 100;
        objBalanceTransaction.ReturnTransferAmount__c = 100;
        Database.insert(objBalanceTransaction);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;
        objContract.Balance__c = objBalance.Id;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.DebtRecoveryProfile__c = PROFILE;
        objContract.PaymentMethodType__c = objPaymentMethodType.Id;
        Database.insert(objContract);
        
        DebtRecoveryProcess__c objDebtRecoveryProcess = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract);
        objDebtRecoveryProcess.CurrentStage__c = REMINDER1;
        objDebtRecoveryProcess.Flag__c = true;
        Database.insert(objDebtRecoveryProcess);
        
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        Database.insert(objPayment);
        
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13-Feb-2018
    @description: Test method for Payment Plan Wizard process
    *******************************************************************************/   
    static testmethod void paymentPlanWizard_Positive(){
        
        
        //Query user record created in test setup data method
        
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
                                          Name 
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.Id limit 1];
        
        PaymentPlanType__c objPaymentPlanType = [Select Id,
                                                 Name ,
                                                 PlanType__c,
                                                 FinalPaymentPlan__c,
                                                 ResetDebtRecovery__c,
                                                 DebtRecoveryProfile__c
                                                 FROM PaymentPlanType__c 
                                                 WHERE Active__c = true
                                                 AND PlanType__c =:PAYINFULL LIMIT 1];   
        
        PaymentPlan__c objPaymentPlan = new PaymentPlan__c();
        objPaymentPlan.PaymentPlanType__c = objPaymentPlanType.Id;
        
        List<Instalment__c> lstInstalments = new List<Instalment__c>();
        
        //Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objAccount);
        //Database.insert(objInstalment);
        
        for (Integer i = 0 ; i < 5; i++) {
            
            Instalment__c objInstal = new Instalment__c();
            objInstal.InstalmentNumber__c = i;
            objInstal.InstalmentDueDate__c = system.today() + i;
            objInstal.InstalmentAmountDue__c = 100 + i;
            
            lstInstalments.add(objInstal);
            
        }
        
        PyAp_PaymentPlanWizardCmpCtrlr.WizardObject objWizardObject = new PyAp_PaymentPlanWizardCmpCtrlr.WizardObject();
        objWizardObject.recordId = objContract.Id; 
        objWizardObject.contractId = objContract.Id;
        objWizardObject.paymentPlanRecord = objPaymentPlan;
        objWizardObject.lstInstalments = lstInstalments;
        objWizardObject.isCreditRefund = true;
        objWizardObject.isCreditTransfer = false;
        objWizardObject.planStartDate = String.valueOf(system.today());
        objWizardObject.dayOfMonth = DAY_OF_MONTH;
        objWizardObject.dayOfWeek = DAY_OF_WEEK;
        objWizardObject.payMethod = PAYMENT_METHOD_TYPE1;
        
        String jsonStr = JSON.serialize(objWizardObject);
        System.runAs(objUser[0]){
            Test.startTest();
            PyAp_PaymentPlanWizardCmpCtrlr.WizardStatus(jsonStr);
            ID contractId = PyAp_PaymentPlanWizardCmpCtrlr.paymentPlanWizard(jsonStr);
            Test.stopTest();
            System.assertEquals(objContract.Id, contractId);
            System.assertEquals(5, [Select count() From Instalment__c]);
            
        }        
        
    } 
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13-Feb-2018
    @description: Test method for Payment Plan Wizard process
    *******************************************************************************/    
    static testmethod void paymentPlanWizard_BudgetOnHold_Positive(){
        
        
        //Query user record created in test setup data method
        
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
                                   		  Name 
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.Id limit 1];
        
        objContract.BudgetPlanHold__c = True;
        update objContract;
        
        ForecastedInstalment__c objForecastInstalment = new ForecastedInstalment__c(BillingContract__c = objContract.Id,
                                                                                    HoldReason__c = HOLDREASON,
                                                                                    Amount__c = 10.00,
                                                                                    FromDate__c = system.today().addmonths(1),
                                                                                    ToDate__c = system.today().addmonths(2));
        
        insert objForecastInstalment;
        
        PaymentPlanType__c objPaymentPlanType = [Select Id,
                                     					Name ,
                                                 		PlanType__c,
                                                 		FinalPaymentPlan__c,
                                                 		ResetDebtRecovery__c,
                                                 		DebtRecoveryProfile__c
                              		 	 		 FROM PaymentPlanType__c 
                                         		 WHERE Active__c = true
                                                 AND PlanType__c =: BUDGETPLAN LIMIT 1];   
        
        PaymentPlan__c objPaymentPlan = new PaymentPlan__c();
        objPaymentPlan.PaymentPlanType__c = objPaymentPlanType.Id;
        
        List<Instalment__c> lstInstalments = new List<Instalment__c>();
        
        //Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objAccount);
        //Database.insert(objInstalment);
        
        for (Integer i = 0 ; i < 5; i++) {
            
			Instalment__c objInstal = new Instalment__c();
            objInstal.InstalmentNumber__c = i;
            objInstal.InstalmentDueDate__c = system.today() + i;
            objInstal.InstalmentAmountDue__c = 100 + i;
            
            lstInstalments.add(objInstal);
            
        }
        
        BankAccountDetails__c objBankAccountDetail = GlUt_FactoryData_Test.createBankAccountDetails(objAccount);
        /*objBankAccountDetail.BankAccountNumber__c= '12345678';
        objBankAccountDetail.NameOnAccount__c= 'Test Name';
        objBankAccountDetail.BankAccountSortCode__c= '123456';
        objBankAccountDetail.Account__c= objAccount.Id; */
        
        PyAp_PaymentPlanWizardCmpCtrlr.WizardObject objWizardObject = new PyAp_PaymentPlanWizardCmpCtrlr.WizardObject();
        objWizardObject.recordId = objContract.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.paymentPlanRecord = objPaymentPlan;
        objWizardObject.lstInstalments = lstInstalments;
        objWizardObject.isCreditRefund = true;
        objWizardObject.isCreditTransfer = false;
        objWizardObject.planStartDate = String.valueOf(system.today());
        objWizardObject.dayOfMonth = DAY_OF_MONTH;
        objWizardObject.dayOfWeek = DAY_OF_WEEK;
        objWizardObject.payMethod = PAYMENT_METHOD_TYPE1;
        objWizardObject.bankAccountDetail = objBankAccountDetail;
        
        String jsonStr = JSON.serialize(objWizardObject);
        
        System.runAs(objUser[0]){
            Test.startTest();
            PyAp_PaymentPlanWizardCmpCtrlr.WizardStatus(jsonStr);
            ID contractId = PyAp_PaymentPlanWizardCmpCtrlr.paymentPlanWizard(jsonStr);
            Test.stopTest();
            
            System.assertEquals(objContract.Id, contractId);
            
            System.assertEquals(5, [Select count() From Instalment__c]);
            
        }        
        
    } 
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13-Feb-2018
    @description: Negative Test method for Payment Plan Wizard process
    *******************************************************************************/
    static testmethod void paymentPlanWizard_Negative(){
        
        //Query user record created in test setup data method
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        //Run test class in user context
        ID contractId;
        System.runAs(objUser[0]){
            Test.startTest();
            try{
                contractId = PyAp_PaymentPlanWizardCmpCtrlr.paymentPlanWizard('');
            } catch(Exception e){
                System.debug('exception message = ' + e.getMessage());
                System.assert(e.getMessage() != null);
            }
            Test.stopTest();
          //  System.assertEquals(contractId, null);
        }

    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13-Feb-2018
    @description: Positive Test method for Payment Plan Wizard - creditRefundTransfer method
    *******************************************************************************/
    static testmethod void creditRefund_Positive(){
        
        Account objAccount = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   		  Name 
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.Id LIMIT 1];
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Payment__c objPayment = [Select Id,
                                     	Name 
                              	 FROM Payment__c
                              	 WHERE Account__c =: objAccount.Id
                                 AND BillingContract__c =: objContract.Id LIMIT 1];
        
        PyAp_PaymentPlanWizardCmpCtrlr.WizardObject objWizardObject = new PyAp_PaymentPlanWizardCmpCtrlr.WizardObject();
        objWizardObject.recordId = objContract.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = true;
        objWizardObject.isCreditTransfer = false;
        
        String jsonStr = JSON.serialize(objWizardObject);
        
        System.runAs(objUser[0]){
            Test.startTest();
            Map<String, String> status = PyAp_PaymentPlanWizardCmpCtrlr.WizardStatus(jsonStr);
            PyAp_PaymentPlanWizardCmpCtrlr.creditRefundTransfer();
            Test.stopTest();
            System.assert(status.Keyset().size() > 0);
            
        }
     }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13-Feb-2018
    @description: Positive Test method for Payment Plan Wizard - creditRefundTransfer method
    *******************************************************************************/
    static testmethod void creditTransfer_Positive(){
        
        Account objAccount = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   		  Name 
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.Id LIMIT 1];
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Payment__c objPayment = [Select Id,
                                     	Name 
                              	 FROM Payment__c
                              	 WHERE Account__c =: objAccount.Id
                                 AND BillingContract__c =: objContract.Id LIMIT 1];
        
        PyAp_PaymentPlanWizardCmpCtrlr.WizardObject objWizardObject = new PyAp_PaymentPlanWizardCmpCtrlr.WizardObject();
        objWizardObject.recordId = objContract.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = false;
        objWizardObject.isCreditTransfer = true;
        
        String jsonStr = JSON.serialize(objWizardObject);
        
        System.runAs(objUser[0]){
            Test.startTest();
            Map<String, String> status = PyAp_PaymentPlanWizardCmpCtrlr.WizardStatus(jsonStr);
            PyAp_PaymentPlanWizardCmpCtrlr.creditRefundTransfer();
            Test.stopTest();
            System.assert(status.Keyset().size() > 0);
        }

     }
    
}