/******************************************************************************
@author:      Echo: Vivek Sethi 
@date:        30-03-2018  
@description: Test Class for GlUt_BillEventHandler
@revision:    25-06-2018 - Swati -- AT-2947, to cover method updatePDFrequest added to main class
*******************************************************************************/

@isTest 
public class GlUt_BillEventHandler_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String CONTRACT_NAME = 'Con00021';
    private static final String BILLEVENTSTATUS ='Pending';
    private static final String BILLEVENTUPDATEDSTATUS = 'Replaced';
    //AT-2947 - START
    private static final String BILLEVENTTYPE = 'Payment Plan Change'; 
	private static final String PAYMENTPLANNOTIFICATION = 'Payment Plan Notification';
	private static final String XMLSOURCETYPE = 'Data Transfer XML';
	private static final String PENDINGSTATUS = 'Pending';  
    //AT-2947 - END
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        30-03-2018  
	@description: Test data setup method
	*******************************************************************************/    
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Contract Record            
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);  
        
        // Create LetterPDFRequest Record -- AT-2947           
        PDFRequest__c objPDFRequest = GlUt_FactoryData_Test.createLetterPDFRequest(objAccount);
        objPDFRequest.BillingContract__c = objContract.Id;
        objPDFRequest.CorrespondenceType__c = PAYMENTPLANNOTIFICATION;
        objPDFRequest.SourceType__c = XMLSOURCETYPE;
        objPDFRequest.Status__c = PENDINGSTATUS;
        Database.insert(objPDFRequest); 
        
        // Create first Bill Event Record           
        BillEvent__c objBillEvent = GlUt_FactoryData_Test.createBillEvent(objContract);
        objBillEvent.Status__c = BILLEVENTSTATUS;
        objBillEvent.EventType__c = BILLEVENTTYPE; //AT-2947
        Database.insert(objBillEvent);        
        
    }    
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        30-03-2018  
	@description: Method to insert  a new record
	*******************************************************************************/
    static testmethod void insertBillItem()
    {  
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        BillingContract__c objContract = [SELECT id FROM BillingContract__c LIMIT 1];   
        BillEvent__c objBillEvent = GlUt_FactoryData_Test.createBillEvent(objContract);
        objBillEvent.Status__c = BILLEVENTSTATUS;
        objBillEvent.EventType__c = BILLEVENTTYPE; //AT-2947
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objBillEvent);           
            Test.stopTest();
        }       
         BillEvent__c objUpdatedBillEvent = [SELECT id FROM BillEvent__c WHERE Status__c =: BILLEVENTUPDATEDSTATUS];   
         system.assert(objUpdatedBillEvent.id != null);      
    }
}