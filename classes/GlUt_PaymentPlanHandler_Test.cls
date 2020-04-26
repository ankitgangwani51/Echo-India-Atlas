/******************************************************************************
@author    		Echo: Mohit Tayal
@date      		16 Feb 2018
@description 	Test Class for GlUt_PaymentPlanHandler
@revision(s)	21-Jun-2018 Swati, AT-2946 -- To cover changes made in addBillingEventToContract method of main class
*******************************************************************************/
@isTest
public class GlUt_PaymentPlanHandler_Test {

    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount';    
    private static final String CONTRACT_NAME1       = 'TestContract1';
    private static final String CONTRACT_NAME2       = 'TestContract2';   
    private static final String PAYMENTPLANTYPE_NAME = 'TestPaymentPlanType';
    private static final Integer PLANAMOUNT          = 5000;
    private static final Integer NUMBEROFINSTALMENTS = 10;
    private static final String YEARLY              = 'Yearly';
    private static final String INSTALMENTPLAN      = 'Instalment Plan';
    private static final Integer MAXNUMOFINSTALMENTS = 12;
    //AT-2946 -- start
    private static final String ACCOUNT_NAME2 = 'TestAccount2'; 
	private static final String CONTRACT_NAME3 = 'TestContract3'; 
    private static final String BILL_NAME = 'Test Bill';
    //AT-2946 -- end    
    
/*******************************************************************
@author:      Echo: Mohit Tayal
@date:        16 Feb 2018
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
        
        //Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);
        
        //Create Balance Transaction Record
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction.BillItemAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.BillAmount__c = 100; // AT-3275
        objBalanceTransaction.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill').getRecordTypeId(); // AT-3275
        Database.insert(objBalanceTransaction);
        
        BillingContract__c con1 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME1,objAccount); 
        con1.Balance__c = objBalance.Id;
        Database.insert(con1);
        
        BillingContract__c con2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2,objAccount); 
        con2.Balance__c = objBalance.Id;
        Database.insert(con2); 

        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME, YEARLY, MAXNUMOFINSTALMENTS);
        objPaymentPlanType.PlanType__c = INSTALMENTPLAN;
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, con1, PLANAMOUNT);
        objPaymentPlan.StartDate__c = Date.today() - 20;
        //objPaymentPlan.EndDate__c = Date.today() + 300;
        Database.insert(objPaymentPlan);
        system.debug('objPaymentPlan = ' +objPaymentPlan);
        
        //AT-2946 -- start
        Account objAccount2 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);
        Database.insert(objAccount2);
		
		BillingContract__c con3 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME3,objAccount2); 
        Database.insert(con3);
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME, con3);
		objBill.DataXml__c = false;
        Database.insert(objBill);
        
        PaymentPlan__c objPaymentPlan2 = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, con3, PLANAMOUNT);
		Database.insert(objPaymentPlan2);        
        //AT-2946 -- end

    }
    
/******************************************************************************
	@author:      Echo: Mohit Tayal
	@date:        16 Feb 2018  
	@description: Test method for mainEntry positive scenario
	*******************************************************************************/
    static testmethod void MainEntry_Positive()
    {            
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE AccountName__c = :objAccount.Id LIMIT 1]; 
        PaymentPlanType__c objPaymentPlanType = [SELECT Id FROM PaymentPlanType__c WHERE NAME = :PAYMENTPLANTYPE_NAME LIMIT 1];
        //Payment__c objPayment = [SELECT id FROM Payment__c LIMIT 1];  
        PaymentPlan__c objPaymentPlan = new PaymentPlan__c();
        objPaymentPlan.PaymentPlanType__c = objPaymentPlanType.Id;
        objPaymentPlan.BillingContract__c = objContract.Id;   //AT-3174
        objPaymentPlan.ForecastAmount__c = PLANAMOUNT;
        objPaymentPlan.StartDate__c = Date.today();
        System.runAs(objUser){
            Test.startTest(); 
            Database.insert(objPaymentPlan);
            Test.stopTest();
            
            system.assert(objPaymentPlan.Id != null);
        }
    }  
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        23 Aug 2018  
	@description: Test method for endActivePaymentPlans positive scenario
	*******************************************************************************/
    static testmethod void endActivePaymentPlans_Positive()
    {            
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE AccountName__c = :objAccount.Id LIMIT 1]; 
        PaymentPlanType__c objPaymentPlanType = [SELECT Id FROM PaymentPlanType__c WHERE NAME = :PAYMENTPLANTYPE_NAME LIMIT 1];
        
        system.debug('endActivePaymentPlans_Positive***');
        
        PaymentPlan__c objPaymentPlan = new PaymentPlan__c();
        objPaymentPlan.PaymentPlanType__c = objPaymentPlanType.Id;
        objPaymentPlan.BillingContract__c = objContract.Id;   //AT-3174
        objPaymentPlan.ForecastAmount__c = PLANAMOUNT;
        objPaymentPlan.StartDate__c = Date.today();
        
        Database.insert(objPaymentPlan);
        
        system.debug('objPaymentPlan***'+ objPaymentPlan);
        
        List<Instalment__c> listInstalment = new List<Instalment__c>{new Instalment__c(PaymentPlan__c = objPaymentPlan.Id,
                                                                                      InstalmentNumber__c = 1,
                                                                                      InstalmentAmountDue__c = 10,
                                                                                     InstalmentDueDate__c = Date.today().addDays(7)),
            
                                                                    new Instalment__c(PaymentPlan__c = objPaymentPlan.Id,
                                                                                      InstalmentNumber__c = 2,
                                                                                      InstalmentAmountDue__c = 20,
                                                                                     InstalmentDueDate__c = Date.today().addDays(14))};
                                                                                         
                                                                                         system.debug('listInstalment***'+ listInstalment);
                                                                                         
		Database.insert(listInstalment);
        
        DebtRecoveryProcess__c objDebtRecProcess = new DebtRecoveryProcess__c();
        objDebtRecProcess.BillingContract__c = objContract.Id;
        objDebtRecProcess.CurrentStage__c = 'Reminder 1';
        
        Database.insert(objDebtRecProcess);
        
        system.debug('objDebtRecProcess***'+ objDebtRecProcess);
        
        List<DebtRecoveryInstalment__c> listDebtRecInstal = new List<DebtRecoveryInstalment__c>();
        
        for(Instalment__c objInstalment : listInstalment){
            
            DebtRecoveryInstalment__c objDRI = new DebtRecoveryInstalment__c();
            objDRI.Active__c = true;
            objDRI.Instalment__c = objInstalment.Id;
            objDRI.DebtRecoveryProcess__c = objDebtRecProcess.Id;
            objDRI.InstalmentAmountDue__c = objInstalment.InstalmentAmountDue__c;
            
            listDebtRecInstal.add(objDRI);
            
        }
        
        system.debug('listDebtRecInstal***'+ listDebtRecInstal);
        
        PaymentPlan__c objPaymentPlan2 = new PaymentPlan__c();
        objPaymentPlan2.PaymentPlanType__c = objPaymentPlanType.Id;
        objPaymentPlan2.BillingContract__c = objContract.Id;   //AT-3174
        objPaymentPlan2.ForecastAmount__c = PLANAMOUNT;
        objPaymentPlan2.StartDate__c = Date.today();
        
        system.debug('objPaymentPlan2***'+ objPaymentPlan2);
        
        System.runAs(objUser){
            Test.startTest(); 
            Database.insert(objPaymentPlan2);
            Test.stopTest();
            
            system.assert(objPaymentPlan2.Id != null);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        05 Sept 2018  
	@description: Test method for mainEntry negative scenario
	*******************************************************************************/
    static testmethod void MainEntry_Negative()
    {            
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE AccountName__c = :objAccount.Id LIMIT 1]; 
        PaymentPlanType__c objPaymentPlanType = [SELECT Id FROM PaymentPlanType__c WHERE NAME = :PAYMENTPLANTYPE_NAME LIMIT 1];
        //Payment__c objPayment = [SELECT id FROM Payment__c LIMIT 1];  
        PaymentPlan__c objPaymentPlan = new PaymentPlan__c();
        objPaymentPlan.PaymentPlanType__c = objPaymentPlanType.Id;
        //objPaymentPlan.BillingContract__c = objContract.Id;   //AT-3174
        objPaymentPlan.ForecastAmount__c = PLANAMOUNT;
        objPaymentPlan.StartDate__c = Date.today();
        
        Boolean isException = false;
        
        System.runAs(objUser){
            
            try{
                Test.startTest(); 
                Database.insert(objPaymentPlan);
                Test.stopTest();
            }
            catch(exception e)
            {
                isException = true;
            }
            
            system.assert(isException = true);
        }
    } 
}