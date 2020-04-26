/******************************************************************************
@author         Echo: Swati Mathur
@date           29 Jan 2018
@description    Test Class For DrUt_AddToDebtRecovery
*******************************************************************************/
@isTest
public class DrUt_AddToDebtRecovery_Test {
    
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
    @date          29 Jan 2018   
    @param         -
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    /*@testSetup
    static void SetUp()
    {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        Contract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_1,objAccount); 
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
        
        //Created one more contract which does not have DRP on it
        Contract__c objContract2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_2,objAccount); 
        Database.insert(objContract2); 
        
        PaymentPlanType__c objPaymentPlanType2 = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE_NAME_2, FREQUENCY, MAX_INSTALMENT);        
        objPaymentPlanType2.PlanType__c = PLAN_TYPE;
        Database.insert(objPaymentPlanType2);
        
        PaymentPlan__c objPaymentPlan2 = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType2,objContract2,PLAN_AMOUNT);
        Database.insert(objPaymentPlan2);
        
        Instalment__c objInstalment2 = new Instalment__c(PaymentPlan__c= objPaymentPlan2.Id,InstalmentDueDate__c= system.today(),
                                                         InstalmentAmountDue__c= INSTALMENT_AMOUNT_DUE);
        Database.insert(objInstalment2);          
        
    }   */  
    /******************************************************************************
    @author        Swati Mathur
    @date          31 Jan 2018  
    @param         
    @return        Void   
    @description   Test method for processBatches() method
    *******************************************************************************/
   /* @isTest
    private static void processBatches_Test()
    {
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        
        System.runAs(objUser){
            
            
            List<Instalment__c> instList = [SELECT Id, InstalmentAmountDue__c,InstalmentDueDate__c, PaymentPlan__r.BillingContract__c, PaymentPlan__r.BillingContract__r.DebtRecoveryProfile__c FROM Instalment__c
                                            WHERE InstalmentDueDate__c <= Today AND Id NOT IN (Select Instalment__c From DebtRecoveryInstalment__c) ];  // AT-3174 
            
            // Map of Contract Id to Instalment Object       
            Map<Id,List<Instalment__c>> instalmentMap = new Map<Id,List<Instalment__c>>();        
            for(Instalment__c instObj : instList){
                if (!instalmentMap.containsKey(instObj.PaymentPlan__r.BillingContract__c)){  // AT-3174 
                    instalmentMap.put(instObj.PaymentPlan__r.BillingContract__c, new List<Instalment__c>());               
                }
                instalmentMap.get(instObj.PaymentPlan__r.BillingContract__c).add(instObj);  // AT-3174 
            }         
            
            //get DRP record of Latest Payment Due Date for assosiated Contract 
            List<DebtRecoveryProcess__c> dRPList = [SELECT ID, Contract__c, TotalAmountDue__c FROM DebtRecoveryProcess__c 
                                                    WHERE Contract__c IN :instalmentMap.keySet() AND ProcessComplete__c = FALSE 
                                                    ORDER BY PaymentDueDate__c ASC];        
            // Map of Assosiated Contract Id to DRP Id        
            Map<Id,DebtRecoveryProcess__c> dRPMap = new Map<Id,DebtRecoveryProcess__c>();         
            for(DebtRecoveryProcess__c dRPObj : dRPList){
                dRPMap.put(dRPObj.Contract__c, dRPObj);            
            }
            
            //get Balance from assosiated Contract 
            List<Contract__c> contractList = [SELECT Id, Balance__c FROM Contract__c 
                                              WHERE Id IN :instalmentMap.keySet()];        
            // Map of Contract Id to Balance Id
            Map<Id,Id> balanceMap = new Map<Id,Id>();
            for(Contract__c conObj : contractList){
                balanceMap.put(conObj.Id,conObj.Balance__c);
            }
            
            DebtRecoveryProcess__c objectDRP1 = [SELECT Id,TotalAmountDue__c FROM DebtRecoveryProcess__c LIMIT 1]; 
            
            Test.startTest();            
            DrUt_AddToDebtRecovery.processBatches(instalmentMap,dRPMap,balanceMap);
            Test.stopTest();
            
            DebtRecoveryProcess__c objectDRP2 = [SELECT Id,TotalAmountDue__c FROM DebtRecoveryProcess__c LIMIT 1]; 
            
            //Verified that Total Amount Due of DRP has been updated when called DrBt_ProcessInstalments class
            System.assertEquals(objectDRP1.TotalAmountDue__c,null);
            System.assertEquals(objectDRP2.TotalAmountDue__c,100);
        }
    }*/
}