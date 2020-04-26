/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        05 Feb 2019
@description: Test Class for PyBt_DirectDebitCombizExport
*******************************************************************************/
@isTest
public class PyBt_DirectDebitCombizExport_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String LOADING 			= 'Loading';
    private static final String PENDING				= 'Pending';
    private static final String PAYMENTPLANNAME 	= 'Test Payment Plan Type';
    private static final String FREQUENCY 			= 'Monthly';
    private static final Integer MAXINSTLLMNT 		= 12;
    private static final Integer PLANAMOUNT 		= 56557;
    private static final String PLANTYP 			= 'Instalment Plan';
    
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Contract for Refund Paymet           
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
        
        // Create Bank Account Details Record        
        BankAccountDetails__c objBankAccountDetails = GlUt_FactoryData_Test.createBankAccountDetails(objAccount);
        Database.insert(objBankAccountDetails); 
        
        // Create Payment Plan Type Record
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANNAME, FREQUENCY, MAXINSTLLMNT);      
        objPaymentPlanType.PlanType__c = PLANTYP;        
        Database.insert(objPaymentPlanType);
        
        // Create Payment Plan Record
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLANAMOUNT);
        Database.insert(objPaymentPlan);
        
        // Create Instalment Record
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);           
        objInstalment.InstalmentAmountDue__c = 5.25;
        Database.insert(objInstalment);   
        
        // Create Direct Debit Requests Record
        DirectDebitRequest__c objDirectDebitRequest = GlUt_FactoryData_Test.createDirectDebitRequest(objContract, objInstalment);
        objDirectDebitRequest.Status__c = PENDING;
        objDirectDebitRequest.BankAccountDetails__c = objBankAccountDetails.Id;
        Database.insert(objDirectDebitRequest);

        //Create Batch Request Queue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Status__c = LOADING;
        Database.insert(objBatchRequestQueue);
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani 
	@date:        05 Feb 2019
	@description: 
	*******************************************************************************/
    static testmethod void DirectDebitCombizExport_Positive() {        
        setCombizInterfaceMetaData();// Added By Echo: Dependra Singh -12-03-2019 - MetaData types Fix
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        Boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                PyBt_DirectDebitCombizExport combizDDExport = new PyBt_DirectDebitCombizExport();
                combizDDExport.Initialise(objBatchReqQueue);
                Database.executeBatch(combizDDExport);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            List<ContentDocumentLink> conLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:objBatchReqQueue.Id];
            system.assert(conLink.size() > 0);
        }          
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani 
	@date:        05 Feb 2019
	@description: Direct Debit Combiz export for negative case test case
	*******************************************************************************/
    static testmethod void DirectDebitCombizExport_Negative(){   
        setCombizInterfaceMetaData();// Added By Echo: Dependra Singh -12-03-2019 - MetaData types Fix
        Boolean isException = false;
        List<DirectDebitRequest__c> ddrListToUpdate = new List<DirectDebitRequest__c>();
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        for(DirectDebitRequest__c ddr : [SELECT Id, Status__c FROM DirectDebitRequest__c]){
            ddr.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED;
            ddrListToUpdate.add(ddr);
        }
        
        System.runAs(objUser){
            Test.startTest();
            try{
                Database.update(ddrListToUpdate);
                PyBt_DirectDebitCombizExport combizDDExport = new PyBt_DirectDebitCombizExport();
                combizDDExport.Initialise(objBatchReqQueue);
                Database.executeBatch(combizDDExport);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            List<ContentDocumentLink> conLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:objBatchReqQueue.Id];
            system.assertEquals(conLink.size(), 0);
        }          
    }
     /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Combiz Interface Custom meta data setting
    *******************************************************************************/ 
    private static void setCombizInterfaceMetaData(){
        GlUt_FactoryData_Test.setCombizInterfaceMetaData();
    }
}