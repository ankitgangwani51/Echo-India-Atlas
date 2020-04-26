/******************************************************************************
@author         Echo: Swati Mathur
@date           19 Dec 2017
@description    Test Class For DrBt_ProcessInstalments
@revision(s)    Swati Mathur - 09 Jan 2018 -- Added mandatory fields for object PaymentPlanType 
                of type 'Change Payment Plan'
*******************************************************************************/
@isTest
public class DrBt_ProcessInstalments_Test {
  
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='TestUser'; 
    private static String ACCOUNT_NAME = 'TestAccount'; 
    private static String CONTRACT_NAME_1 ='TestContract1';
    private static String CONTRACT_NAME_2 ='TestContract2';
    private static String PAYMENT_PLAN_TYPE_NAME_1 = 'Test Payment Plan Type1';
    private static String PAYMENT_PLAN_TYPE_NAME_2 = 'Test Payment Plan Type2';
    private static Integer PLAN_AMOUNT = 12345;
    private static Integer NUMBER_OF_INSTALMENTS = 07; 
    private static Integer INSTALMENT_AMOUNT_DUE = 100; 
    private static Integer MAX_INSTALMENT = 12;
    private static String PLAN_TYPE = 'Instalment Plan';
    private static String FREQUENCY = 'Monthly';
       
    /******************************************************************************
    @author        Swati Mathur
    @date          19 Dec 2017   
    @param         -
    @return        Void   
    @description   Setup Method for Initialize Data in DebtRecoveryProcess__c Object 
                   for Unit Testing
    *******************************************************************************/     
    @testSetup
    static void SetUp()
    {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_1,objAccount); 
        Database.insert(objContract); 
        
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE_NAME_1, FREQUENCY, MAX_INSTALMENT);
        objPaymentPlanType.PlanType__c = PLAN_TYPE;
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
        
        Instalment__c objInstalment = new Instalment__c(PaymentPlan__c= objPaymentPlan.Id, InstalmentDueDate__c= system.today(),
                                                        InstalmentAmountDue__c= INSTALMENT_AMOUNT_DUE);
        Database.insert(objInstalment);
        
        DebtRecoveryProcess__c objDRP = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract);
        Database.insert(objDRP);
        
        DebtRecoveryInstalment__c objDebtRecInstalment = new DebtRecoveryInstalment__c(Instalment__c = objInstalment.Id, DebtRecoveryProcess__c = objDRP.Id, InstalmentAmountDue__c = INSTALMENT_AMOUNT_DUE);
        Database.insert(objDebtRecInstalment);
        
        //Created one more contract which does not have DRP on it
        BillingContract__c objContract2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_2,objAccount); 
        Database.insert(objContract2); 
        
        PaymentPlanType__c objPaymentPlanType2 = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE_NAME_2, FREQUENCY, MAX_INSTALMENT);        
        objPaymentPlanType2.PlanType__c = PLAN_TYPE;
        Database.insert(objPaymentPlanType2);
        
        PaymentPlan__c objPaymentPlan2 = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType2,objContract2,PLAN_AMOUNT);
        Database.insert(objPaymentPlan2);
        
        Instalment__c objInstalment2 = new Instalment__c(PaymentPlan__c= objPaymentPlan2.Id,InstalmentDueDate__c= system.today(),
                                                         InstalmentAmountDue__c= INSTALMENT_AMOUNT_DUE);
        Database.insert(objInstalment2);          
        
    }     

    /******************************************************************************
    @author        Swati Mathur
    @date          19 Dec 2017  
    @param         
    @return        Void   
    @description   Method to Run DrBt_ProcessInstalments Schedule job 
    *******************************************************************************/
    @isTest
    private static void runScheduleJob()
    {
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        
        System.runAs(objUser){
            DrBt_ProcessInstalments batchObject = new DrBt_ProcessInstalments();            
            String SchedulerName  = 'Process Instalments';
            String sCronExp = '0 1 * * * ? *';
            
            Account objAccount = [SELECT Id
                                  FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
                
                
                BillingContract__c objContract = [SELECT Id,Name
                                                  FROM BillingContract__c
                                                  WHERE AccountName__c =: objAccount.Id LIMIT 1]; 
            
            DebtRecoveryProcess__c objectDRP1 = [SELECT Id,TotalAmountDue__c
                                                 FROM DebtRecoveryProcess__c 
                                                 WHERE BillingContract__c =: objContract.Id LIMIT 1]; 
            
            system.debug('objectDRP1***'+ objectDRP1);
            
            Test.startTest();
            Database.executeBatch(batchObject);
            String jobID = System.schedule(SchedulerName, sCronExp, batchObject);
            Test.stopTest();
            
            DebtRecoveryProcess__c objectDRP2 = [SELECT Id,TotalAmountDue__c 
                                                 FROM DebtRecoveryProcess__c LIMIT 1];
            
            system.debug('objectDRP2***'+ objectDRP2);
            
            
            //Verified that Total Amount Due of DRP has been updated when called DrBt_ProcessInstalments class
            System.assertEquals(objectDRP1.TotalAmountDue__c,0.0);
            System.assertEquals(objectDRP2.TotalAmountDue__c,0.0);
          
        }
    }
  
}