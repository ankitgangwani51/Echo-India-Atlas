/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        22 January 2018
@description: Test Class for DrUt_ChangePaymentPlan 
*******************************************************************************/
@isTest
public class DrUt_ChangePaymentPlan_Test {
    
    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static final String CONTRACT_NAME1      = 'TestContract1';  
    private static final String CONTRACT_NAME2      = 'TestContract2';
    private static final String PAYMENTPLANTYPE_NAME = 'TestPaymentPlanType';
    private static final String PAYMENTPLANTYPE_NAME2 = 'TestPaymentPlanType2';
    private static final String PAYMENTPLANTYPE_NAME3 = 'TestPaymentPlanType3';
    private static final String POSITIVETEST        = 'PositiveTest';
    private static final String NEGATIVETEST        = 'NegativeTest';
    private static final String YEARLY              = 'Yearly';
    private static final String INSTALMENTPLAN      = 'Instalment Plan';
    private static final Integer MAXNUMOFINSTALMENTS = 12;
    private static final String CHANGEPAYMENTPLAN   = 'Change Payment Plan';
    private static final String PROCESSED           = 'Processed';
    private static final String ERROR               = 'Error';

    
/*******************************************************************
@author:      Echo: Mohit Tayal
@date:        22 January 2018
@param:       N/A
@return:      void
@description: method to create test data used by all test methods
********************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME1,objAccount); 
        Database.insert(con);
        
        BillingContract__c con2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2,objAccount); 
        Database.insert(con2); 
                
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount); 
        Database.insert(objBalance);
        con.Balance__c = objBalance.Id;
        Database.update(con); 
        
        /*PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME1, YEARLY, MAXNUMOFINSTALMENTS);
        objPaymentPlanType.PlanType__c = INSTALMENTPLAN;
        objPaymentPlanType.ResetDebtRecovery__c = TRUE;
        objPaymentPlanType.DaysNotice__c = 10;
        Database.insert(objPaymentPlanType);
        
        PaymentPlanType__c objPaymentPlanType2 = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME2, YEARLY, MAXNUMOFINSTALMENTS);
        objPaymentPlanType2.PlanType__c = INSTALMENTPLAN;
        objPaymentPlanType2.ResetDebtRecovery__c = TRUE;
        Database.insert(objPaymentPlanType2);*/

        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess1 = GlUt_FactoryData_Test.createDebtRecoveryProcess(con);
        objDebtRecProcess1.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess1);
        
        
        DebtRecoveryProcess__c objDebtRecProcess2 = GlUt_FactoryData_Test.createDebtRecoveryProcess(con2);
        objDebtRecProcess2.ProcessComplete__c = TRUE;
        objDebtRecProcess2.BillingContract__c = null;
        Database.insert(objDebtRecProcess2);
        
        //Create Debt. Recovery Action record
        //MT - 20 Feb 2018 Changed to create bulk records as per the review comments
        List<PaymentPlanType__c> paymentPlanTypeList = new List<PaymentPlanType__c>();
        List<DebtRecoveryAction__c> debtRecActList = new List<DebtRecoveryAction__c>();
        for(Integer i = 0; i < 100; i++){
            String paymentPlanTypeName = PAYMENTPLANTYPE_NAME + String.valueOf(i);
            PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(paymentPlanTypeName, YEARLY, MAXNUMOFINSTALMENTS);
            objPaymentPlanType.PlanType__c = INSTALMENTPLAN;
            objPaymentPlanType.ResetDebtRecovery__c = TRUE;
            objPaymentPlanType.DaysNotice__c = 10;
            paymentPlanTypeList.add(objPaymentPlanType);
            
            DebtRecoveryAction__c objDebtRecAct;
            
            if(i < 10){
                objDebtRecAct = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
                objDebtRecAct.Parameters__c = paymentPlanTypeName;
            } else if(i >= 10 && i < 20){
                objDebtRecAct = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
            }else if(i >= 20 && i < 30){
                objDebtRecAct = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess2);
                objDebtRecAct.Parameters__c = paymentPlanTypeName;
            }else if(i >= 30 && i < 40){
                objDebtRecAct = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
                objDebtRecAct.Parameters__c = paymentPlanTypeName;
            } else {
                objDebtRecAct = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
                objDebtRecAct.Parameters__c = paymentPlanTypeName;
            }
            
            objDebtRecAct.Action__c = CHANGEPAYMENTPLAN;
            objDebtRecAct.Processed__c = FALSE;
            debtRecActList.add(objDebtRecAct);         
        }

        Database.insert(paymentPlanTypeList);
        Database.insert(debtRecActList);
        
        con.CurrentDebtRecoveryProcess__c = objDebtRecProcess1.Id;
        con.CurrentPaymentPlanType__c = paymentPlanTypeList[0].Id;
        Database.update(con);
        con2.CurrentPaymentPlanType__c = paymentPlanTypeList[0].Id;
        Database.update(con2);
    }

/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        22 January 2018
@param:       N/A
@return:      void
@description: Positive Test scenario for updatePayment
********************************************************************/
    static testmethod void updatePayment_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1]; 
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id, Action__c,Parameters__c , DebtRecoveryProcess__r.BillingContract__c 
                                         FROM DebtRecoveryAction__c WHERE Processed__c = FALSE]; 
        Map<String,Id> paymentPlanTypeMap = new Map<String,Id>();
        List<Id> debtRecoveryActId = new List<Id>();
        
        for (PaymentPlanType__c payPlanType : [SELECT Id, Name FROM PaymentPlanType__c LIMIT 200]) {
            paymentPlanTypeMap.put(payPlanType.Name, payPlanType.Id);
        }
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            if(paymentPlanTypeMap.containsKey(dRRec.Parameters__c)){
                debtRecoveryActId.add(dRRec.Id);
            }
        }  

        System.runAs(objUser){
            Test.startTest();
            DrUt_ChangePaymentPlan.updatePayment(debtRecoveryActList);
            Test.stopTest();
            
            Map<Id,BillingContract__c> contractMap = new Map<Id,BillingContract__c>([SELECT Id, CurrentPaymentPlanType__c FROM BillingContract__c WHERE AccountName__r.Name = :ACCOUNT_NAME]);
            for(DebtRecoveryAction__c dbRecAction : [SELECT Id, Parameters__c, ErrorMessage__c, Processed__c, Status__c, DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Id IN :debtRecoveryActId]){               
                if(String.isBlank(dbRecAction.Parameters__c)){
                    System.assertEquals(ERROR,dbRecAction.Status__c);
                    System.assertEquals(Label.DrUt_ChangePaymentPlanParamBlankError,dbRecAction.ErrorMessage__c);    
                }else if(dbRecAction.DebtRecoveryProcess__r.BillingContract__c == null){
                    System.assertEquals(ERROR,dbRecAction.Status__c);
                    System.assertEquals(Label.DrUt_ChangePaymentPlanNoConAgainstActionError,dbRecAction.ErrorMessage__c);
                }else if(paymentPlanTypeMap.containsKey(dbRecAction.Parameters__c) || contractMap.get(dbRecAction.DebtRecoveryProcess__r.BillingContract__c).CurrentPaymentPlanType__c != null){
                    System.assertEquals(PROCESSED,dbRecAction.Status__c);
                }else{
                    System.assertEquals(ERROR,dbRecAction.Status__c);
                    System.assertEquals(Label.DrUt_ChangePaymentPlanNoPaymentPlanTypeError,dbRecAction.ErrorMessage__c);
                }
            }
        }
    }   
/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        22 January 2018
@param:       N/A
@return:      void
@description: Negative Test scenario for updatePayment
********************************************************************/
    static testmethod void updatePayment_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1]; 
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id, Action__c,Parameters__c , DebtRecoveryProcess__r.BillingContract__c 
                                                           FROM DebtRecoveryAction__c WHERE Processed__c = FALSE];   
        List<Id> debtRecoveryActId = new List<Id>();
        Integer i = 0;
        
        PaymentPlanType__c objPayPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME + '200', YEARLY, MAXNUMOFINSTALMENTS);
        Database.insert(objPayPlanType);
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            if(i == 1){
                dRRec.Parameters__c = PAYMENTPLANTYPE_NAME;
            }else if(i == 99){
                dRRec.Parameters__c = objPayPlanType.Name;
            }
            i += 1;
            debtRecoveryActId.add(dRRec.Id);
        }  
        
        Database.update(debtRecoveryActList);
        System.runAs(objUser){
            Test.startTest();
            DrUt_ChangePaymentPlan.updatePayment(debtRecoveryActList);
            Test.stopTest();
            
            //MT - 20 Feb 2018 Added asserts as per review comments
            DebtRecoveryProcess__c objDebtRecProcess = [SELECT Id FROM DebtRecoveryProcess__c WHERE  BillingContract__c = null];    
            
            /*for(DebtRecoveryAction__c dbRecAction : [SELECT Id, Parameters__c, Status__c,ErrorMessage__c FROM DebtRecoveryAction__c WHERE DebtRecoveryProcess__c = :objDebtRecProcess.Id]){
                System.assertEquals(ERROR,dbRecAction.Status__c);
                System.assertEquals(Label.DrUt_ChangePaymentPlanNoConAgainstActionError,dbRecAction.ErrorMessage__c);                 
            } */   
            
        }
    }
}