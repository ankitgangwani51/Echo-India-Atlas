/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        01 February 2019
@description: Test Class for PyAp_SplitSuspensePaymentCtrlr
*******************************************************************************/
@isTest
public class PyAp_SplitSuspensePaymentCtrlr_Test{
    //Variable declaration start
   
    private static final String PROFILENAME = 'System Administrator';
    private static final String USERNAME = 'TestUser111';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String ACCOUNTNAME = 'TestAccount';
    private static final String CONTRACTNAME ='TestContract';
    private static final String PAYMENT_PLAN_TYPE = 'New Payment Plan';
    private static final Integer NO_OF_INSTALLMENT = 12;
    private static final String YEARLY = 'Yearly';
    private static final STRING  BANKACCOUNTNUMBER = '23232';
    private static final INTEGER AMOUNT   = 1000; 
    private static final INTEGER REMAININGAMOUNT   = 600; 
    private static final INTEGER TRANSFERREDAMOUNT = 400; 
    //Variable declaration end
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        13 February 2018
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount); 
        
        //Create Balance record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance); 
        
        // Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE,YEARLY,NO_OF_INSTALLMENT);
        Database.insert(objPaymentPlanType);

        //Create Contract record     
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACTNAME,objAccount);
        objContract.Balance__c = objBalance.Id;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        Database.insert(objContract); 
		
        // Create Payment Record  
        List<Payment__c> paymentList = new  List<Payment__c> ();
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.BankAccountNumber__c = BANKACCOUNTNUMBER;
        objPayment.Account__c = null;
        objPayment.BillingContract__c = null;
        objPayment.Amount__c = AMOUNT;
        objPayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
        paymentList.add(objPayment);
        
        // Create Payment Record         
        Payment__c objPayment1 = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment1.BankAccountNumber__c = BANKACCOUNTNUMBER;
        objPayment1.Amount__c = AMOUNT;
        objPayment1.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
        paymentList.add(objPayment1);
        Database.insert(paymentList);
    }
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for getInfoToDisplay() method positive scenario 
	*******************************************************************************/
    static testmethod void getInfoToDisplay_Positive(){
        
        List<Payment__c> pList =  [SELECT Id FROM Payment__c  WHERE Account__c = null AND BillingContract__c = null LIMIT  1];
        PyAp_SplitSuspensePaymentCtrlr.ContainerWrapper infoToDisplay = new PyAp_SplitSuspensePaymentCtrlr.ContainerWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            infoToDisplay = PyAp_SplitSuspensePaymentCtrlr.getInfoToDisplay(pList[0].Id); 
            Test.stopTest();
            System.assertEquals(infoToDisplay.isShowCmp, true);
            System.assertNotEquals(infoToDisplay.objPaymnt, null);
        }
    } 
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for getInfoToDisplay() method negative scenario
	*******************************************************************************/
    static testmethod void getInfoToDisplay_Negative(){
        
        List<Payment__c> pList =  [SELECT Id FROM Payment__c  WHERE Account__c != null AND BillingContract__c != null  LIMIT 1];
        PyAp_SplitSuspensePaymentCtrlr.ContainerWrapper infoToDisplay = new PyAp_SplitSuspensePaymentCtrlr.ContainerWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            infoToDisplay = PyAp_SplitSuspensePaymentCtrlr.getInfoToDisplay(pList[0].Id); 
            Test.stopTest();
            System.assertEquals(infoToDisplay.isShowCmp, false);
        }
    }
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for AddMoreRows() 
	*******************************************************************************/
    static testmethod void AddMoreRows(){
        
        PyAp_SplitSuspensePaymentCtrlr.SplitPaymentsWrapper addMoreRows = new PyAp_SplitSuspensePaymentCtrlr.SplitPaymentsWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            addMoreRows = PyAp_SplitSuspensePaymentCtrlr.AddMoreRows(); 
            Test.stopTest();
            System.assertNotEquals(addMoreRows, null);
        }
    }
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for getAccountNameById()  positive scenario 
	*******************************************************************************/
    static testmethod void getAccountNameById_Positive(){
        
        String strAccountName;
        List<Account> aList =  [SELECT Id FROM Account  LIMIT  1];
         User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            strAccountName = PyAp_SplitSuspensePaymentCtrlr.getAccountNameById(aList[0].Id); 
            Test.stopTest();
            System.assertEquals(strAccountName, ACCOUNTNAME);
        }
    }
    
   /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for getAccountNameById()  negative scenario
	*******************************************************************************/
    static testmethod void getAccountNameById_Negative(){
        String strAccountName;
        List<Account> aList =  new List<Account>();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = false;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                strAccountName = PyAp_SplitSuspensePaymentCtrlr.getAccountNameById(aList[0].Id); 
                Test.stopTest();
            }catch(exception e){
                isException = true;                
            }
            System.assertEquals(strAccountName, null);
            System.assertEquals(isException, true);
        }
    }
  
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for SaveSplitPaymentsData()  positive scenario 
	*******************************************************************************/
    static testmethod void saveSplitPaymentsData_Positive(){
        List<Account> aList =  [SELECT Id FROM Account  LIMIT  1];
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        List<Payment__c> pList =  [SELECT Id, PaymentDate__c , PaymentMethod__c, RecordTypeId, Amount__c FROM Payment__c  WHERE Account__c = null AND BillingContract__c = null LIMIT  1];
        List<BillingContract__c> objContract = [SELECT Id FROM BillingContract__c  LIMIT  1];
        PyAp_SplitPaymentWrapper objSplitPaymentWrapper = new PyAp_SplitPaymentWrapper();
        objSplitPaymentWrapper.remaningAmount =  REMAININGAMOUNT;
        objSplitPaymentWrapper.transferredAmount = 400;
        objSplitPaymentWrapper.objPayment = pList[0];
        
        List<PyAp_SplitPaymentWrapper.cls_records> clsRecordList = new List<PyAp_SplitPaymentWrapper.cls_records>();
        PyAp_SplitPaymentWrapper.cls_records clsRecord = new PyAp_SplitPaymentWrapper.cls_records();
        
        clsRecord.objBillingContract =  objContract[0];
        clsRecord.paymentObj = pList[0];
        clsRecordList.add(clsRecord);
        
        objSplitPaymentWrapper.records  = clsRecordList;
        String jsonStr = JSON.serialize(objSplitPaymentWrapper);
        Boolean isDataSaved = false;
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            isDataSaved = PyAp_SplitSuspensePaymentCtrlr.saveSplitPaymentsData(jsonStr); 
            Test.stopTest();
            System.assertEquals(isDataSaved, true);
        }
    }
        
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for SaveSplitPaymentsData()  positive scenario 
	*******************************************************************************/
    static testmethod void saveSplitPaymentsData_Negative(){
        List<Account> aList =  [SELECT Id FROM Account  LIMIT  1];
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        List<Payment__c> pList =  [SELECT Id FROM Payment__c  WHERE Account__c = null AND BillingContract__c = null LIMIT  1];
        List<BillingContract__c> objContract = [SELECT Id FROM BillingContract__c  LIMIT  1];
        PyAp_SplitPaymentWrapper objSplitPaymentWrapper = new PyAp_SplitPaymentWrapper();
        objSplitPaymentWrapper.remaningAmount =  REMAININGAMOUNT;
        objSplitPaymentWrapper.transferredAmount = TRANSFERREDAMOUNT;
        objSplitPaymentWrapper.objPayment = pList[0];
        
        List<PyAp_SplitPaymentWrapper.cls_records> clsRecordList = new List<PyAp_SplitPaymentWrapper.cls_records>();
        PyAp_SplitPaymentWrapper.cls_records clsRecord = new PyAp_SplitPaymentWrapper.cls_records();
        
        clsRecord.objBillingContract =  objContract[0];
        clsRecord.paymentObj = pList[0];
        clsRecordList.add(clsRecord);
        
        objSplitPaymentWrapper.records  = clsRecordList;
        String jsonStr = JSON.serialize(objSplitPaymentWrapper);
        Boolean isDataSaved = false;
        Boolean isException = false;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                isDataSaved = PyAp_SplitSuspensePaymentCtrlr.saveSplitPaymentsData(jsonStr); 
                Test.stopTest();
            }catch(exception e){
                isException = true;                
            }
            System.assertEquals(isException, true);
        }
    }
}