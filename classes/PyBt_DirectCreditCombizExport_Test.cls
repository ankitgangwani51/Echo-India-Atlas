/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        31 Jan 2019
@description: Test Class for PyBt_DirectCreditCombizExport
*******************************************************************************/
@isTest
public class PyBt_DirectCreditCombizExport_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String REFUND 				= 'Refund';
    private static final string BANKACCOUNTNUMBER 	= '012345';
    private static final String BANKSORTCODE		= '12345';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String LOADING 			= 'Loading';
    private static final String READY 				= 'Ready';
    private static final string NO 					= 'No';
    private static final Id RecordTypeId 			= Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(REFUND).getRecordTypeId();
    
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
        
        //Create Batch Request Queue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Status__c = LOADING;
        Database.insert(objBatchRequestQueue);
        
        // Create Payment Records
        List<Payment__c> paymentList = new List<Payment__c>();
        for(Integer iCount = 0;iCount<=50;iCount++){
            Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract); 
            Integer i = math.mod(iCount,2);
            if(i == 0){
                objPayment.BankAccountNumber__c  = BANKACCOUNTNUMBER + '0' + iCount;
                objPayment.BankAccountSortCode__c = BANKSORTCODE + '0' + iCount;
            }else
                objPayment.BankAccountDetail__c = objBankAccountDetails.Id;
            
            objPayment.RefundExportStatus__c = READY;
            objPayment.RefundApprovedDate__c = Date.today();
            objPayment.Transferred__c = NO;
            objPayment.RecordTypeId = RecordTypeId;
            paymentList.add(objPayment);  
        }
        if(!paymentList.isEmpty() && paymentList.size() > 0)
            Database.insert(paymentList);
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani 
	@date:        31 Jan 2019
	@description: 
	*******************************************************************************/
    static testmethod void DirectCreditCombizExport_Positive(){     
        setCombizInterfaceMetaData();
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        Boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                PyBt_DirectCreditCombizExport combizDDExport = new PyBt_DirectCreditCombizExport();
                combizDDExport.Initialise(objBatchReqQueue);
                Database.executeBatch(combizDDExport);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            List<ContentDocumentLink> conLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:objBatchReqQueue.Id];
            List<CombizInterface__mdt> combizLists = [SELECT BankAccount__c, BankBranch__c, DDFilename__c, DDLodgementReference__c,
                                                      ProcessingDays__c, RefundFilename__c, RefundLodgementReference__c, 
                                                      UserBank__c, UserName__c, UserNumber__c FROM  CombizInterface__mdt LIMIT 1];
            if(!combizLists.isEmpty() && combizLists.size() > 0)
                system.assertEquals(conLink.size(), 1);
        }          
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani 
	@date:        31 Jan 2019
	@description: 
	*******************************************************************************/
    static testmethod void DirectCreditCombizExport_Negative(){   
        setCombizInterfaceMetaData();
        List<Payment__c> paymentList = new List<Payment__c>();
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        for(Payment__c payment : [SELECT Id, Transferred__c FROM Payment__c]){
            payment.Transferred__c = 'YES';
            paymentList.add(payment);
        }
        
        Boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                Database.update(paymentList);
                PyBt_DirectCreditCombizExport combizDDExport = new PyBt_DirectCreditCombizExport();
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
    @date:        15 Mar 2019
    @description: Enviroment Setting Custom meta data type Data
    *******************************************************************************/ 
    private static void setCombizInterfaceMetaData(){
        GlUt_FactoryData_Test.setCombizInterfaceMetaData();
    }
}