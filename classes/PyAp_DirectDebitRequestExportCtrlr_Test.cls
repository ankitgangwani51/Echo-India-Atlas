/******************************************************************************
@author:      Echo: Vivek Sethi 
@date:        28-06-2018  
@description: Test Class for PyAp_DirectDebitRequestExportCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest 
public class PyAp_DirectDebitRequestExportCtrlr_Test {
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String EXPORTINSTALMENTSUPTO =  String.valueOf(system.today());
    private static final String INVALIDDATE =  '01/01/01';
    private static final String BATCHCLASS = PyAp_Constants.BATCHPROCESSEXPORTBOOKCLASSNAME;
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        28-06-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData() {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Batch Process Record            
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCHCLASS);
        objBatchProcess.Operation__c = PyAp_Constants.BATCHPROCESSOPERATION;
        Database.insert(objBatchProcess); 
        
    } 
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        28-06-2018  
	@description: Method to create BRQ  Record Positive Scenario
	*******************************************************************************/
    static testmethod void createBRQ_Positive() {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BatchProcess__c bp = [SELECT Id,BatchClass__c,Operation__c FROM BatchProcess__c WHERE Operation__c =: PyAp_Constants.BATCHPROCESSOPERATION 
                              AND BatchClass__c =: PyAp_Constants.BATCHPROCESSEXPORTBOOKCLASSNAME Limit 1];
        system.debug('bp==='+bp);      
        System.runAs(objUser){
            Test.startTest(); 
			system.debug('EXPORTINSTALMENTSUPTO==='+EXPORTINSTALMENTSUPTO);            
            PyAp_DirectDebitRequestExportCtrlr.createDefaultBatchRequest(EXPORTINSTALMENTSUPTO, bp.Id);     
            Test.stopTest();
        }     
        
        BatchRequestQueue__c objBatchRequestQueue = [SELECT Id FROM  BatchRequestQueue__c LIMIT 1];
        system.assert(objBatchRequestQueue.id != null);        
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        28-06-2018  
	@description: Method  Method to create BRQ  Record Negative Scenario
	*******************************************************************************/
    static testmethod void createBRQ_Negative() {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Boolean  isException;
        String invalidId = null;
        System.runAs(objUser) {
            Test.startTest();
            try {
                PyAp_DirectDebitRequestExportCtrlr.createDefaultBatchRequest(INVALIDDATE,invalidId) ;   
                Test.stopTest();
            } catch(Exception ex){
                isException = TRUE;
            }
            
        }     
        system.assertEquals(isException, TRUE);
    }     
}