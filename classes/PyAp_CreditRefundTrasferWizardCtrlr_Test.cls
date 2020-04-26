/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        13 February 2018
@description: Test Class for PyAp_CreditRefundTransferWizardCtrlr_Test
*******************************************************************************/
@isTest
public class PyAp_CreditRefundTrasferWizardCtrlr_Test{
    //Variable declaration start
   
    private static final String PROFILENAME = 'System Administrator';
    private static final String USERNAME = 'TestUser111';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String ACCOUNTNAME = 'TestAccount';
    private static final String CONTRACTNAME ='TestContract';
    private static final String PAYMENT_PLAN_TYPE = 'New Payment Plan';
    private static final Integer NO_OF_INSTALLMENT = 12;
    private static final String YEARLY = 'Yearly';
    private static final String BALANCEAMOUNT = '1000.00';
    private static final String REFUNDACCOUNT = 'Test';
    private static final String  BUDGETPLAN = 'Budget Plan';
    private static final String  INVALIDID = 'abc';
    private static final INTEGER CREDITAMOUNT = 200; 
    private static final STRING  BANKACCOUNTNUMBER = '23232';
    private static final INTEGER AMOUNT   = 500; 
    private static final INTEGER REVERSEDAMOUNT  = 50;
    private static final INTEGER INSTAMOUNTUNALLOCATED = 200;
    private static final INTEGER PAYMENTAMOUNT   = 100; 
    private static final INTEGER PAYMENTAMOUNT2  = 200;
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
        
        List<Balance__c> lstBalance = new List<Balance__c>();
        //Create Balance record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        lstBalance.add(objBalance); 
        
        //Create Another Balance record which is unlinked with contract to cover the else scenario 
        Balance__c objBalance1 = GlUt_FactoryData_Test.createBalance(objAccount);
        lstBalance.add(objBalance1); 
        
        //Create Another Balance record which is linked with contract to cover the Budget Plan scenario
        Balance__c objBalance2 = GlUt_FactoryData_Test.createBalance(objAccount);
        lstBalance.add(objBalance2); 
        Database.insert(lstBalance);
        
        List<PaymentPlanType__c> lstPaymentPlan = new List<PaymentPlanType__c>();
        // Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE,YEARLY,NO_OF_INSTALLMENT);
        lstPaymentPlan.add(objPaymentPlanType);
        
        // Create PaymentPlanType Record for Budget Plan        
        PaymentPlanType__c objPaymentPlanType1 = GlUt_FactoryData_Test.createPaymentPlanType(BUDGETPLAN,YEARLY,NO_OF_INSTALLMENT);
        objPaymentPlanType1.PlanType__c = BUDGETPLAN;
        lstPaymentPlan.add(objPaymentPlanType1);
        Database.insert(lstPaymentPlan);
        
        List<BillingContract__c> lstBillingContract= new List<BillingContract__c>();
        //Create Contract record     
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACTNAME,objAccount);
        objContract.Balance__c = lstBalance[0].Id;
        objContract.CurrentPaymentPlanType__c = lstPaymentPlan[0].Id;
        lstBillingContract.add(objContract); 
        
        //Create Contract record for Budget Plan   
        BillingContract__c objContract1 = GlUt_FactoryData_Test.CreateContract(CONTRACTNAME,objAccount);
        objContract1.Balance__c = lstBalance[0].Id;
        objContract1.CurrentPaymentPlanType__c = lstPaymentPlan[1].Id;
        lstBillingContract.add(objContract1);  
        Database.insert(lstBillingContract);
        
        List<Payment__c> lstPayment= new List<Payment__c>();
        
        // Create Payment Record         
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,lstBillingContract[0]);
        objPayment.BillAmountUnallocated__c = INSTAMOUNTUNALLOCATED;
        objPayment.BankAccountNumber__c = BANKACCOUNTNUMBER;
        objPayment.Account__c = objAccount.Id;
        objPayment.BillingContract__c = lstBillingContract[0].Id;
        objPayment.Amount__c = AMOUNT;
        objPayment.CreditAmount__c = CREDITAMOUNT;
        objPayment.InstalmentAmountUnallocated__c = INSTAMOUNTUNALLOCATED;
        objPayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
        lstPayment.add(objPayment);
        
        // Create  Another Payment Record         
        Payment__c objPayment1 = GlUt_FactoryData_Test.createPayment(objAccount,lstBillingContract[0]);
        objPayment1.BankAccountNumber__c = BANKACCOUNTNUMBER;
        objPayment1.Account__c = objAccount.Id;
        objPayment1.BillingContract__c = lstBillingContract[0].Id;
        objPayment1.Amount__c = AMOUNT;
        objPayment1.ReversedAmount__c = REVERSEDAMOUNT;
        objPayment1.CreditAmount__c = CREDITAMOUNT;
        objPayment1.InstalmentAmountUnallocated__c = INSTAMOUNTUNALLOCATED;
        objPayment1.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
        lstPayment.add(objPayment1);
        Database.insert(lstPayment);
        
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(lstBalance[0]);
        objBalanceTransaction.BillAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.Balance__c  = lstBalance[0].Id;
        objBalanceTransaction.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();//Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
        Database.insert(objBalanceTransaction);
    }
    
    /******************************************************************************
@author:      Vivek Sethi
@date:        13 February 2018
@description: Test method for getContractId() method positive scenario with 
Balance Id as Input.
*******************************************************************************/
    static testmethod void getContractId_Positive(){
        List<Balance__c> bList =  [Select id,name from Balance__c limit  2];
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String ContractId;
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            for( Balance__c objBalance : bList )   //Scenarios to cover If and Else cases
            {
                ContractId = PyAp_CreditRefundTransferWizardCtrlr.getContractId(objBalance.Id);  
            }
            Test.stopTest();
        }
        System.assertEquals(Null,ContractId );   
    } 
    
    /******************************************************************************
@author:      Vivek Sethi
@date:        13 February 2018
@description: Test method for  getContractId() method  - negative scenario with 
Null Balance Id as Input.
*******************************************************************************/
    static testmethod void getContractIdNullBillId_Negative(){
        
        Balance__c objBalance = new Balance__c();
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String BalanceId;
        Boolean exceptionstr = false;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                BalanceId = PyAp_CreditRefundTransferWizardCtrlr.getContractId(objBalance.Id);
                Test.stopTest();
            }catch(exception e){
                exceptionstr = true;                
            }
                
        }
        System.assertEquals(Null, BalanceId);
    } 
    
    /******************************************************************************
    @author:      Vivek Sethi
    @date:        13 February 2018
    @description: Test method for  getContractId() method  - negative scenario with 
    Null Balance Id as Input.
    *******************************************************************************/
    static testmethod void getContractIdNullBillId_Null(){
        Id BalanceId;
        Boolean isException;
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                BalanceId = PyAp_CreditRefundTransferWizardCtrlr.getContractId(INVALIDID);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assertEquals(isException, true);
        }
    } 
    
    /******************************************************************************
    @author:      Vivek Sethi
    @date:        13 February 2018
    @description: Test method for wizardStatus() method positive scenario with 
    wizardprop as Input.
    *******************************************************************************/
    static testmethod void wizardStatus_Positive(){
        
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, name  from Account];
        Balance__c objBalance =[Select id,name from Balance__c limit  1 ];
        PaymentPlanType__c objPaymentPlanType  =[Select id from PaymentPlanType__c where Name !=: BUDGETPLAN];
        BillingContract__c objContract =[Select id,name from BillingContract__c where CurrentPaymentPlanType__c =: objPaymentPlanType.Id limit 1];    
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.Amount__c = PAYMENTAMOUNT;
        
        PyAp_CreditRefundTransferWizardCtrlr.WizardObject objWizardObject = new PyAp_CreditRefundTransferWizardCtrlr.WizardObject();
        objWizardObject.recordId = objBalance.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = false;
        objWizardObject.isCreditTransfer = true;
        objWizardObject.isCreditWriteOff = true;
        String jsonStr = JSON.serialize(objWizardObject);
        
        Map<String, Boolean> wizardStatusMap = new Map<String, Boolean>();
        List<String> wizardpropList = new List<String>();
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            wizardStatusMap = PyAp_CreditRefundTransferWizardCtrlr.wizardStatus(jsonStr);
            Test.stopTest();
        }
        System.assertEquals(FALSE, wizardStatusMap.get(BUDGETPLAN));
    }
    
    /******************************************************************************
    @author:      Vivek Sethi
    @date:        13 February 2018
    @description: Test method for wizardStatus() method positive scenario with 
    wizardprop as Input.
    *******************************************************************************/
    static testmethod void wizardStatusBudgetPlan_Positive(){
        
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, name  from Account];
        Balance__c objBalance =[Select id,name from Balance__c limit  1 ];
        PaymentPlanType__c objPaymentPlanType  =[Select id from PaymentPlanType__c where Name =: BUDGETPLAN];
        BillingContract__c objContract =[Select id,name from BillingContract__c where CurrentPaymentPlanType__c =: objPaymentPlanType.Id limit 1];    
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.Amount__c = PAYMENTAMOUNT;
        system.debug('501..objContract .' + objContract);
        PyAp_CreditRefundTransferWizardCtrlr.WizardObject objWizardObject = new PyAp_CreditRefundTransferWizardCtrlr.WizardObject();
        objWizardObject.recordId = objBalance.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = false;
        objWizardObject.isCreditTransfer = true;
        objWizardObject.isCreditWriteOff = true;
        String jsonStr = JSON.serialize(objWizardObject);
        
        Map<String, Boolean> wizardStatusMap = new Map<String, Boolean>();
        List<String> wizardpropList = new List<String>();
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            wizardStatusMap = PyAp_CreditRefundTransferWizardCtrlr.wizardStatus(jsonStr);
            Test.stopTest();
        }
        System.assertEquals(TRUE, wizardStatusMap.get(BUDGETPLAN));
    }
    
    /*****************************************************************************
    @author:      Vivek Sethi
    @date:        13 February 2018
    @description: Test method for creditRefundTransfer() method positive scenario with 
    wizardprop as Input.
    *******************************************************************************/
    static testmethod void creditRefundTransfer_EqualAmount_RefundPositive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Boolean exceptionStr = false;
        Account objAccount = [Select id, name  from Account];
        Balance__c objBalance =[Select id,name from Balance__c limit  1 ];
        PaymentPlanType__c objPaymentPlanType  =[Select id from PaymentPlanType__c where Name !=: BUDGETPLAN];
        BillingContract__c objContract =[Select id,name from BillingContract__c where CurrentPaymentPlanType__c =: objPaymentPlanType.Id limit 1];    
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.RefundAddress__c = 'Refund Address';
        objPayment.Amount__c = PAYMENTAMOUNT2;
        
        PyAp_CreditRefundTransferWizardCtrlr.WizardObject objWizardObject = new PyAp_CreditRefundTransferWizardCtrlr.WizardObject();
        objWizardObject.recordId = objBalance.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = true;
        objWizardObject.isCreditTransfer = false;
        objWizardObject.isCreditWriteOff = true;
        String jsonStr = JSON.serialize(objWizardObject);
        String wizardObjId;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                //Refund Scenario
                wizardObjId = PyAp_CreditRefundTransferWizardCtrlr.creditRefundTransfer(jsonStr);
                Test.stopTest();
            }catch(exception e){
                exceptionStr = true;
            }                 
        }
        System.assert(wizardObjId != null);
    }
    
    /******************************************************************************
@author:      Vivek Sethi
@date:        13 February 2018
@description: Test method for creditRefundTransfer() method positive scenario with 
wizardprop as Input.
*******************************************************************************/
    static testmethod void creditRefundTransfer_LesserAmount_RefundPositive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, name  from Account];
        Balance__c objBalance =[Select id,name from Balance__c limit  1 ];
        PaymentPlanType__c objPaymentPlanType  =[Select id from PaymentPlanType__c where Name !=: BUDGETPLAN];
        BillingContract__c objContract =[Select id,name from BillingContract__c where CurrentPaymentPlanType__c =: objPaymentPlanType.Id limit 1];    
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);        
        objPayment.Amount__c = PAYMENTAMOUNT;
        
        PyAp_CreditRefundTransferWizardCtrlr.WizardObject objWizardObject = new PyAp_CreditRefundTransferWizardCtrlr.WizardObject();
        objWizardObject.recordId = objBalance.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = true;
        objWizardObject.isCreditTransfer = false;
        objWizardObject.isCreditWriteOff = true;
        String jsonStr = JSON.serialize(objWizardObject);
        String wizardObjId;
        Boolean exceptionStr = false;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                //Refund Scenario
                wizardObjId = PyAp_CreditRefundTransferWizardCtrlr.creditRefundTransfer(jsonStr);
                Test.stopTest();
            }catch(exception e){
                exceptionStr = true;
            }
        }
        System.assert(wizardObjId != null);
    }
    
    /******************************************************************************
@author:      Vivek Sethi
@date:        13 February 2018
@description: Test method for creditRefundTransfer() method positive scenario with 
wizardprop as Input.
*******************************************************************************/
    static testmethod void creditRefundTransfer_LesserAmount_TransferPositive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, name  from Account];
        Balance__c objBalance =[Select id,name from Balance__c limit  1 ];
        PaymentPlanType__c objPaymentPlanType  =[Select id from PaymentPlanType__c where Name !=: BUDGETPLAN];
        BillingContract__c objContract =[Select id,name from BillingContract__c where CurrentPaymentPlanType__c =: objPaymentPlanType.Id limit 1];    
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.Amount__c = PAYMENTAMOUNT;
        
        PyAp_CreditRefundTransferWizardCtrlr.WizardObject objWizardObject = new PyAp_CreditRefundTransferWizardCtrlr.WizardObject();
        objWizardObject.recordId = objBalance.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = false;
        objWizardObject.isCreditTransfer = true;
        objWizardObject.isCreditWriteOff = true;
        String jsonStr = JSON.serialize(objWizardObject);
        String wizardObjId;
        Boolean exceptionStr = false;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                //Refund Scenario
                wizardObjId = PyAp_CreditRefundTransferWizardCtrlr.creditRefundTransfer(jsonStr);
                Test.stopTest();
            }catch(exception e){
                exceptionStr = true;
            }
        }
        System.assert(wizardObjId != null);
    }    
    
    /******************************************************************************
@author:      Vivek Sethi
@date:        13 February 2018
@description: Test method for creditRefundTransfer() method positive scenario with 
wizardprop as Input.
*******************************************************************************/
    static testmethod void creditRefundTransfer_EqualAmount_TransferPositive(){
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, name  from Account];
        Balance__c objBalance =[Select id,name from Balance__c limit  1 ];
        PaymentPlanType__c objPaymentPlanType  =[Select id from PaymentPlanType__c where Name !=: BUDGETPLAN];
        BillingContract__c objContract =[Select id,name from BillingContract__c where CurrentPaymentPlanType__c =: objPaymentPlanType.Id limit 1];    
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.Amount__c = PAYMENTAMOUNT2; 
        
        PyAp_CreditRefundTransferWizardCtrlr.WizardObject objWizardObject = new PyAp_CreditRefundTransferWizardCtrlr.WizardObject();
        objWizardObject.recordId = objBalance.Id;
        objWizardObject.contractId = objContract.Id;
        objWizardObject.objPayment = objPayment;
        objWizardObject.isCreditRefund = false;
        objWizardObject.isCreditTransfer = true;
        objWizardObject.isCreditWriteOff = true;
        String jsonStr = JSON.serialize(objWizardObject);
        String wizardObjId;
        Boolean exceptionStr = false;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                //Refund Scenario
                wizardObjId = PyAp_CreditRefundTransferWizardCtrlr.creditRefundTransfer(jsonStr);
                Test.stopTest();
            }catch(exception e){
                exceptionStr = true;
            }
        }
        System.assert(wizardObjId != null);
    }    
    
    /******************************************************************************
@author:      Vivek Sethi
@date:        13 February 2018
@description: Test method for creditRefundTransfer() method negative scenario with 
wizardprop as Input.
*******************************************************************************/
    static testmethod void creditRefundTransfernNull_Negative(){
        
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String  wizardObjId, wizardprop = null; 
        Boolean isException;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                wizardObjId = PyAp_CreditRefundTransferWizardCtrlr.creditRefundTransfer(wizardprop);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assertEquals(true,isException);
    }
    
    /*****************************************************************************
    @author:      Vivek Sethi
    @date:        13 February 2018
    @description: Test method for getCreditDetails() method positive scenario with 
    wizardprop as Input.
    *******************************************************************************/
    static testmethod void getCreditDetails_Positive(){
        
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        PyAp_CreditRefundTransferWizardCtrlr.BalanceWrapper wrapper = new PyAp_CreditRefundTransferWizardCtrlr.BalanceWrapper();
        String getBalAmountString;
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            wrapper = PyAp_CreditRefundTransferWizardCtrlr.getCreditDetails(objContract.Id);
            Test.stopTest();
        }
        System.assert(Integer.valueOf(wrapper.totalCreditAmount) > 0);
    }
    /******************************************************************************
@author:      Vivek Sethi
@date:        13 February 2018
@description: Test method for getCreditDetails() method negative scenario with 
wizardprop as Input.
*******************************************************************************/
    static testmethod void getCreditDetailsInvalidId_Negative(){
        
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String getBalAmountString;
        PyAp_CreditRefundTransferWizardCtrlr.BalanceWrapper wrapper = new PyAp_CreditRefundTransferWizardCtrlr.BalanceWrapper();
        boolean isException;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                wrapper = PyAp_CreditRefundTransferWizardCtrlr.getCreditDetails(INVALIDID);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assertEquals(true,isException);
    }
}