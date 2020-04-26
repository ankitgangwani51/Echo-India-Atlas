/******************************************************************************
@author         Ankit Gangwani
@date           20 DEC 2017
@description    Test Class For VmBt_ProcessAction
*******************************************************************************/
@isTest
public class VmBt_ProcessAction_Test {
    
    private static final String USER_PROFILE 					='System Administrator';
    private static final String USER_NAME 						='FN123LN123'; 
    private static final String USER_FNAME						= 'FN123';	
    private static final String USER_LNAME						= 'LN123';
    private static final String LOCATION_NAME 					='A99 9AA';
    private static final String LOCATION_SUB_TYPE 				= 'Detached';
    private static final String STREET 							= 'teststreet'; 
    private static final String SENDVOIDMGMTVISITNOTICE 		= 'Send Void Management Visit Notice';
    private static final String SENDVOIDMGMTVISITNOTIFICATION 	= 'Send Void Management Visit Notification';
    private static final String SENDOCCUPATIONFORM 				= 'Send Occupation Form';
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          20 DEC 2017   
    @param         -
    @return        Void   
    @description   Setup Method for Unit Testing
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Location record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c = LOCATION_SUB_TYPE ; 
        objLocation.Street__c = STREET ;
        Database.insert(objLocation);
        
        //Create Void Management Process record
        VoidManagementProcess__c objVoidMgtProcess = GlUt_FactoryData_Test.createVoidManagementProcess(objLocation);
        objVoidMgtProcess.ProcessComplete__c = TRUE;        
        Database.insert(objVoidMgtProcess);  
        
        VoidManagementAction__c objVoidMgtAction1 = GlUt_FactoryData_Test.createVoidManagementAction(objVoidMgtProcess);
        objVoidMgtAction1.Processed__c = FALSE;
        objVoidMgtAction1.Action__c = SENDVOIDMGMTVISITNOTICE;
        Database.insert(objVoidMgtAction1);
        
        VoidManagementAction__c objVoidMgtAction2 = GlUt_FactoryData_Test.createVoidManagementAction(objVoidMgtProcess);
        objVoidMgtAction2.Processed__c = FALSE;
        objVoidMgtAction2.Action__c = SENDVOIDMGMTVISITNOTIFICATION;
        Database.insert(objVoidMgtAction2);
        
        VoidManagementAction__c objVoidMgtAction3 = GlUt_FactoryData_Test.createVoidManagementAction(objVoidMgtProcess);
        objVoidMgtAction3.Processed__c = FALSE;
        objVoidMgtAction3.Action__c = SENDOCCUPATIONFORM;
        Database.insert(objVoidMgtAction3);
    }
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          20 DEC 2017
    @revision      Ankit Gangwani, 10 April 2018
    @return        Void   
    @description   Method To test Evaluate checkbox update scenario 
    *******************************************************************************/     
    static testmethod void TestEvaluateMethod(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        VoidManagementProcess__c objVMId = [SELECT Id,ProcessComplete__c FROM VoidManagementProcess__c LIMIT 1];       
        
        System.runAs(objUser[0]){
            Test.starttest();
            VmBt_ProcessAction objVMProcessBatch = new VmBt_ProcessAction();
            Id batchId = Database.executeBatch(objVMProcessBatch);       
            String jobID = System.schedule('Test Process Action', '0 0 12 * * ?', objVMProcessBatch);
            Test.stoptest();
            System.assert(jobID != null);
            System.assertEquals(objVMId.ProcessComplete__c,true);
        }
    }
    
}