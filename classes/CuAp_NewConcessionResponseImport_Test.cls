/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        08 Jan 2019
@description: Test Class for CuAp_NewConcessionResponseImport
@Revisions	  05/03/19 Tarun , Fixed consdev test class deployment failures.
*******************************************************************************/
@isTest
public class CuAp_NewConcessionResponseImport_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    
    private static final String FILE_NAME 			= 'InputFile.xml';
    private static final String BATCH_CLASS_NAME 	= 'CuBt_ConcessionImport';
    private static final String INVALID_DATA_JOB 	= 'test_invalid_data';
    private static final String VALID_JOB_NAME      = 'Concession Batch';
    private static final Boolean IS_USER_NOTIFY 	= true;
    private static final String USER_NOTIFY 		= 'ankitgangwani@echo-ms.com';
    private static final String CONTENT_TYPE 		= 'xml'; 
    private static final String BATCH_OPERATION 	= 'Import';
    private static final String ACCOUNT_NAME		= 'Test Account';
    private static final String CRN_NUMBER			= '123456789';
    private static final String CONFIRM_DATE		= '2017-01-01';
       
        
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        08 Jan 2019
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {       
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;         
        Database.insert(objUser);
      
		// Create Batch Process Record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS_NAME);
        objBatchProcess.Operation__c = BATCH_OPERATION;
        Database.insert(objBatchProcess);
        
        //Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Concession Record
        Concession__c objConcession = GlUt_FactoryData_Test.createConcession(objAccount);
        objConcession.CRN__c = CRN_NUMBER;
        objConcession.ConfirmDate__c = Date.valueOf(CONFIRM_DATE);        
        Database.insert(objConcession);
        
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        08 Jan 2019
	@description: Test Method 
	*******************************************************************************/
    static testmethod void activeNotifyUserList_Positive(){
        
        User objUser = [SELECT Id,Name  FROM User WHERE isActive=true LIMIT 1];
        List<User> userList = new List<User>();
        System.runAs(objUser){
            Test.startTest();           
            userList = CuAp_NewConcessionResponseImportCtrlr.activeNotifyUserList();
            Test.stopTest();          
        }           
        System.assert (userList.size() > 0);
    }  
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    /*static testmethod void saveDetails_InvalidData(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USER_NOTIFY LIMIT 1];
                
        System.runAs(objUser){
            Test.startTest();
            String filecontent = EncodingUtil.base64Encode(blob.valueOf(FILEDATA1));            
            LoAp_NewReadingImportCtrlr.saveDetails(INVALID_DATA_JOB, IS_USER_NOTIFY, objUser.Id, FILE_NAME, filecontent, CONTENT_TYPE);
            Test.stopTest();          
        } 
    }  */
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        08 Jan 2019
    @description: Test Method 
    *******************************************************************************/
    static testmethod void saveDetails_Positive(){
        
        User objUser = [SELECT Id,Name FROM user  WHERE isActive=true LIMIT 1];
        List<StaticResource> res = new List<StaticResource>();
        res = [SELECT Id, Body FROM StaticResource WHERE Name = 'ConcessionImportXML'] ; 
        System.runAs(objUser){
            Test.startTest();
            String filecontent = EncodingUtil.base64Encode(res[0].Body);
            CuAp_NewConcessionResponseImportCtrlr.saveDetails(VALID_JOB_NAME, IS_USER_NOTIFY, objUser.Id, FILE_NAME, filecontent, CONTENT_TYPE);
            Test.stopTest();          
            List<BatchRequestQueue__c> brqLists = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
            List<ContentDocumentLink> cdLinkLists = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:brqLists[0].Id];
            System.assert(brqLists[0].Id != null);
            System.assert(cdLinkLists[0].Id != null);
                
        } 
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        08 Jan 2019
    @description: Test Method 
    *******************************************************************************/
    static testmethod void saveDetails_Negative(){
        
        User objUser = [SELECT Id,Name FROM user  WHERE isActive=true LIMIT 1];
        List<StaticResource> res = new List<StaticResource>();        
        System.runAs(objUser){
            Test.startTest();
            CuAp_NewConcessionResponseImportCtrlr.saveDetails(INVALID_DATA_JOB, IS_USER_NOTIFY, objUser.Id, null, null, '');
            Test.stopTest();          
            List<BatchRequestQueue__c> brqLists = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
            List<ContentDocumentLink> cdLinkLists = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:brqLists[0].Id LIMIT 1];
            System.assert(brqLists[0].Id != null);
            System.assert(cdLinkLists.isEmpty(),true);
        } 
    }
    
}