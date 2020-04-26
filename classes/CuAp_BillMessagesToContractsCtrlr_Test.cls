/******************************************************************************
@author:      Echo: Neha 
@date:        18 July 2018  
@description: Test Class for CuAp_BillMessagesToContractsCtrlr_Test
*******************************************************************************/
@isTest 
public class CuAp_BillMessagesToContractsCtrlr_Test {
    
	private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String CONTACT_NAME = 'test1';
    private static final String BILL_MSG = 'Pdf Contract Message';
    private static final String BILL_MSG1 = 'bill_message';
    private static final String BILL_MSG2 = 'TestBatchPDF'; 
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        18 July 2018  
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
                
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);        
        Database.insert(objContract);  
        
        //Create Bill Message Record
        BillMessage__c objBillMessage = GlUt_FactoryData_Test.createBillMessage(BILL_MSG);        
        Database.insert(objBillMessage);
        
        //Create Contract Bill Message Record
        ContractBillMessage__c objContractBillMessage = GlUt_FactoryData_Test.createContractBillMessage(objBillMessage,objContract);        
        Database.insert(objContractBillMessage);
        
        //Create Bill Message Record
        BillMessage__c objBillMessage1 = GlUt_FactoryData_Test.createBillMessage(BILL_MSG1);        
        Database.insert(objBillMessage1);
        
        //Create Contract Bill Message Record
        ContractBillMessage__c objContractBillMessage1 = GlUt_FactoryData_Test.createContractBillMessage(objBillMessage1,objContract);  
        objContractBillMessage1.Active__c = false;
        Database.insert(objContractBillMessage1);
        
        //Create Bill Message Record - 2
        BillMessage__c objBillMessage2 = GlUt_FactoryData_Test.createBillMessage(BILL_MSG2);        
        Database.insert(objBillMessage2);
     
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        18 July 2018   
	@description: 
	*******************************************************************************/
    static testmethod void retrieveBillMessagePropDetails_Positive()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];             
        System.runAs(objUser){
            Test.startTest();             
        	List<GLAp_FieldProps> billMsgProps = CuAp_BillMessagesToContractsCtrlr.retrieveBillMessagePropDetails(GlUt_APIConstantsContracts.CONTRACTAPINAME);
            Test.stopTest();            
            system.assert( billMsgProps.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        18 July 2018  
	@description: 
	*******************************************************************************/
    static testmethod void retrieveBillMessageRecordsDetails_Positive()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1]; 
        System.runAs(objUser){
            Test.startTest();             
        	List<BlAp_CombinedRecord> BillMessageSelectList = CuAp_BillMessagesToContractsCtrlr.retrieveBillMessageRecordsDetails(GlUt_APIConstantsContracts.CONTRACTAPINAME,objContract.Id );            
            Test.stopTest();            
            system.assert( BillMessageSelectList.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        18 July 2018  
	@description: 
	*******************************************************************************/
    static testmethod void retrieveBillMessageRecordsDetails_Negative()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1]; 
        List<ContractBillMessage__c> contractBillMessageList = [SELECT Id FROM ContractBillMessage__c ];
        database.delete(contractBillMessageList);
        List<BillMessage__c> billMessageList = [SELECT Id FROM BillMessage__c ];
        database.delete(billMessageList);
        System.runAs(objUser){
            Test.startTest();             
        	List<BlAp_CombinedRecord> BillMessageSelectList = CuAp_BillMessagesToContractsCtrlr.retrieveBillMessageRecordsDetails(GlUt_APIConstantsContracts.CONTRACTAPINAME,objContract.Id );            
            Test.stopTest();            
            system.assert( BillMessageSelectList.size() == 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        18 July 2018  
	@description: 
	*******************************************************************************/
    static testmethod void saveContractBillMessageDetails_Positive()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
    	String result;
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1]; 
        System.runAs(objUser){
            Test.startTest();             
        	List<BlAp_CombinedRecord> BillMessageSelectList = CuAp_BillMessagesToContractsCtrlr.retrieveBillMessageRecordsDetails(GlUt_APIConstantsContracts.CONTRACTAPINAME,objContract.Id );
            Set<Id> cbmBillMessageIdSet = new Set<Id>();
            if(BillMessageSelectList.size() > 0){
                Integer icount = 1;
                for(ContractBillMessage__c objContractBillMessage: [SELECT Id,BillingContract__c,BillMessage__c 
                                                                    FROM ContractBillMessage__c LIMIT 1] ){
                	cbmBillMessageIdSet.add(objContractBillMessage.BillMessage__c);                                                         
                }
                
                for(BlAp_CombinedRecord objCR: BillMessageSelectList){
                    objCR.isSelected = true;
                    if(icount == 1 && cbmBillMessageIdSet.contains(objCR.objectMap.get(GlUt_APIConstantsBillMessage.BILLMESSAGEAPINAME).id)){
                        objCR.isSelected = false;
                    }
                }
                String responseJSON = JSON.serialize(BillMessageSelectList);
                result = CuAp_BillMessagesToContractsCtrlr.saveContractBillMessageDetails(responseJSON, objContract.Id, GlUt_APIConstantsContracts.CONTRACTAPINAME);
            }
            Test.stopTest();            
            system.assert(result == 'Success');
        }
    }
        
}