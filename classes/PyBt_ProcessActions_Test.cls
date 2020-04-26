/******************************************************************************
@author         Vivek Sethi
@date           04 July 2018
@description    Test Class For PyBt_ProcessActions
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class PyBt_ProcessActions_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123';  
    private static final String USERNAMECOMPLETE        =  USER_NAME + '@unitest.com';
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123'; 
    private static final Date INSTALMENT_DUE_DATE       = system.today();
    private static final String  PAYMENT_PLAN_TYPE     = 'New Payment Plan';
    private static final String PAYMENT_FREQ           = 'Monthly';
    private static final Integer MAX_INSTALLMENT       = 1200;
    private static final Integer PLAN_AMOUNT           = 50;
    private static final Integer INSTALMENT_AMOUNT_DUE = 50;
    private static final Integer SUM_OF_ALLOCATED_PAY  = 10;
    private static final String  BANK_ACCOUNT_PARAMETER = 'Pay In Full';
    private static final String ACCOUNT_NAME            = 'TestAccount';
    private static final String PROCESSED               = 'Processed';
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
    
        //Create account
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);
        
        //Create Balance Transaction Record
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction.BillItemAmount__c = 0; // AT-3275
        objBalanceTransaction.BillAmount__c = 0; // AT-3275
        Database.insert(objBalanceTransaction);
        
        //Create Balance Transaction Record
        BalanceTransaction__c objBalanceTransaction1 = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction1.BillItemAmount__c = 0; // AT-3275
        objBalanceTransaction.BillAmount__c = 0; // AT-3275
        Database.insert(objBalanceTransaction1);
        
        //Create Contract
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        objContract.Balance__c = objBalance.Id;
        Database.insert(objContract);
        
        //Create Payment
        Payment__c objPayment =   GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        Database.insert(objPayment);   
           
        //Create Bank Account Change Record
        BankAccountChange__c objBankAccountChange = GlUt_FactoryData_Test.createBankAccountChange(objContract);
        Database.insert(objBankAccountChange);
        
        // Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE, PAYMENT_FREQ, MAX_INSTALLMENT);
        objPaymentPlanType.Name = BANK_ACCOUNT_PARAMETER;
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
                    
        //Create Direct Debit Return Record
        DirectDebitReturn__c objDirectDebitReturn = GlUt_FactoryData_Test.createDirectDebitReturn(objContract);
        objDirectDebitReturn.Payment__c = objPayment.Id;
        objDirectDebitReturn.DirectDebitRequest__c = objDirectDebitRequest.Id;
        Database.insert(objDirectDebitReturn);
        
        List<BankAccountAction__c >  bankAccountActionList = new List<BankAccountAction__c >();
        //Create Bank Account Action Record
        BankAccountAction__c objBankAccountAction = GlUt_FactoryData_Test.createBankAccountAction();
        objBankAccountAction.Action__c = PyBt_Constants.BANK_ACCOUNT_ACTION_CHANGE_PAYMEMENT_PLAN;
        objBankAccountAction.Parameters__c  = BANK_ACCOUNT_PARAMETER;
        objBankAccountAction.BankAccountChange__c = objBankAccountChange.Id;
        bankAccountActionList.add(objBankAccountAction);

        //Create Bank Account Action Record
        BankAccountAction__c objBankAccountAction5 = GlUt_FactoryData_Test.createBankAccountAction();
        objBankAccountAction5.Action__c = PyBt_Constants.BANK_ACCOUNT_ACTION_CHANGE_PAYMEMENT_PLAN;
        objBankAccountAction5.Parameters__c  = BANK_ACCOUNT_PARAMETER;
        objBankAccountAction5.DirectDebitReturn__c = objDirectDebitReturn.Id;
        bankAccountActionList.add(objBankAccountAction5);
        
        //Create Bank Account Action Record
        BankAccountAction__c objBankAccountAction1 = GlUt_FactoryData_Test.createBankAccountAction();
        objBankAccountAction1.Action__c = PyBt_Constants.BANK_ACCOUNT_ACTION_CREATE_CORRESPONDENCE;
        objBankAccountAction1.Parameters__c  = BANK_ACCOUNT_PARAMETER;
        objBankAccountAction1.DirectDebitReturn__c = objDirectDebitReturn.Id;
        bankAccountActionList.add(objBankAccountAction1);
        
        //Create Bank Account Action Record
        BankAccountAction__c objBankAccountAction2 = GlUt_FactoryData_Test.createBankAccountAction();
        objBankAccountAction2.Action__c = PyBt_Constants.BANK_ACCOUNT_ACTION_UPDATE_BANK_DETAILS;
        objBankAccountAction2.Parameters__c  = BANK_ACCOUNT_PARAMETER;
        objBankAccountAction2.BankAccountChange__c = objBankAccountChange.Id;
        bankAccountActionList.add(objBankAccountAction2);
        
        //Create Bank Account Action Record
        BankAccountAction__c objBankAccountAction6 = GlUt_FactoryData_Test.createBankAccountAction();
        objBankAccountAction6.Action__c = PyBt_Constants.BANK_ACCOUNT_ACTION_UPDATE_BANK_DETAILS;
        objBankAccountAction6.Parameters__c  = BANK_ACCOUNT_PARAMETER;
        objBankAccountAction6.DirectDebitReturn__c = objDirectDebitReturn.Id;
        bankAccountActionList.add(objBankAccountAction6);
        
        //Create Bank Account Action Record
        BankAccountAction__c objBankAccountAction3 = GlUt_FactoryData_Test.createBankAccountAction();
        objBankAccountAction3.Action__c = PyBt_Constants.BANK_ACCOUNT_ACTION_RETURN_PAYMENT;
        objBankAccountAction3.Parameters__c  = BANK_ACCOUNT_PARAMETER;
        objBankAccountAction3.DirectDebitReturn__c = objDirectDebitReturn.Id;
        bankAccountActionList.add(objBankAccountAction3);
        
        //Create Bank Account Action Record
        BankAccountAction__c objBankAccountAction4 = GlUt_FactoryData_Test.createBankAccountAction();
        objBankAccountAction4.Action__c = PyBt_Constants.BANK_ACCOUNT_ACTION_CHANGE_PAYMEMENT_PLAN;
        objBankAccountAction4.Parameters__c  = BANK_ACCOUNT_PARAMETER;
        bankAccountActionList.add(objBankAccountAction4);
       
        if(!bankAccountActionList.isEmpty())
            insert bankAccountActionList;
        
        //Create BatchRequestQueue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        Database.insert(objBatchRequestQueue);
        
    }
    
    /******************************************************************************
    @author         Vivek Sethi
    @date           04 July 2018
    @description:   Test Method to check PyBt_ProcessActions 
    *******************************************************************************/
    static testmethod void PyBt_ProcessActions_Positive() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c BatchRequestQueue = [select Id  from BatchRequestQueue__c limit 1]; 

        System.runAs(objUser){
            Test.startTest();
            PyBt_ProcessActions obj = new PyBt_ProcessActions();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
        BankAccountAction__c objBankAccAction = [SELECT Id,Status__c,Action__c FROM BankAccountAction__c where Status__c != null LIMIT 1];
        system.assertEquals(objBankAccAction.Status__c, PROCESSED);
    }
    
    /******************************************************************************
    @author         Vivek Sethi
    @date           04 July 2018
    @description:   Test Method to check PyBt_ProcessActions 
    *******************************************************************************/
    static testmethod void PyBt_ProcessActions_Negative() {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c BatchRequestQueue = new BatchRequestQueue__c(); 
        PyBt_ProcessActions obj = new PyBt_ProcessActions();
        System.runAs(objUser){
            Test.startTest();
            try{
                obj.Initialise(BatchRequestQueue);
                DataBase.executeBatch(obj);
            } catch(Exception ex){}
            Test.stopTest();
            System.assert(obj.batchRequestQueue.Id == null);
        }
    }
}