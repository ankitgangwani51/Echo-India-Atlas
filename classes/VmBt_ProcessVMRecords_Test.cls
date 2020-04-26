/******************************************************************************
@author         Neha Rajput
@Revise         Ankit Gangwani (05 Dec 2017)
@date           24 Nov 2017
@description    Test Class For VmBt_ProcessVMRecords
@revision:      08-Mar-2018 MT - Use the field from constant class
*******************************************************************************/
@isTest
public class VmBt_ProcessVMRecords_Test {
    
    private static final String USER_PROFILE 			='System Administrator';
    private static final String USER_NAME 				='FN123LN123'; 
    private static final String USER_FNAME				= 'FN123';	
    private static final String USER_LNAME				= 'LN123';
    private static final String LOCATION_NAME 			='A99 9AA';
    private static final String LOCATION_SUB_TYPE 		= 'Detached';
    private static final String STREET 					= 'teststreet';
    private static final String VOID_MANAGEMENT_PROFILE	= 'HH Void Management Profile';
    private static final String CURRENT_STAGE           = 'Stage 1';
    
    public static final String sMode = 'Evaluate'; 
    public static final String sQuery = 'SELECT ' + GlUt_APIConstantsVoidManagementProcess.PREDICTAPINAME + 
        ' FROM ' + GlUt_APIConstantsVoidManagementProcess.VOIDMANAGEMENTPROCESSAPINAME +
        ' WHERE (' + GlUt_APIConstantsVoidManagementProcess.VOIDMANAGEMENTPROFILEAPINAME + ' = \'HH Void Management Profile\' AND ' + GlUt_APIConstantsVoidManagementProcess.CURRENTSTAGEAPINAME + ' = \'Stage 1\'' + ')';
    
    /******************************************************************************
@author        Neha Rajput 
@revise        Ankit Gangwani (05 Dec 2017)
@date          24 Nov 2017   
@param         -
@return        Void   
@description   Setup Method for Initialize Data in VoidManagementProcess__c Object 
for Unit Testing
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
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
                
        //Create Void Management Process record
        VoidManagementProcess__c objVoidMgtProcess = GlUt_FactoryData_Test.createVoidManagementProcess(objLocation);
        objVoidMgtProcess.VoidManagementProfile__c = VOID_MANAGEMENT_PROFILE;   
        objVoidMgtProcess.CurrentStage__c = CURRENT_STAGE;
        Database.insert(objVoidMgtProcess);        
    }
    
/******************************************************************************
@author        Neha Rajput 
@revise        Ankit Gangwani (05 Dec 2017)
@date          24 Nov 2017   
@param         
@return        Void   
@description   Method To test Evaluate checkbox update scenario 
*******************************************************************************/     
    static testmethod void TestEvaluateMethod(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        VoidManagementProcess__c objVMId = [SELECT Id,Evaluate__c FROM VoidManagementProcess__c LIMIT 1];       
        
        System.runAs(objUser[0]){
            Test.starttest();
            VmBt_ProcessVMRecords VMPBatchObject = new VmBt_ProcessVMRecords(sQuery,sMode);
            Id batchId = Database.executeBatch(VMPBatchObject);              
            String jobID = System.schedule('Test Void', '0 0 12 * * ?', VMPBatchObject);                 
            Test.stoptest();
            System.assertEquals(objVMId.Evaluate__c,false);
        }
    }
}