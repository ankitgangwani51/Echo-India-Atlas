/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        15 March 2017
@description: Test Class for GlAp_RecordListTitleWithIconCtrlr_Test
*******************************************************************************/
@isTest
public class GlAp_RecordListTitleWithIconCtrlr_Test {
    //Variable declaration start
    private static final string USERPROFILENAME 	= 'System Administrator';
    private static final string USERNAME 		 	= 'TestUser';
    private static final String USERNAMECOMPLETE    = USERNAME + '@unitest.com';
    private static final string MANAGERID 			= Null;
    private static final string OBJECTS 			= 'Contact';
    
    //Variable declaration end
    
    /******************************************************************************
@author:      Echo: Vivek Sethi
@date:        15 March 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILENAME, USERNAME , MANAGERID);
        Database.insert(objUser);
    }
    /******************************************************************************
@author:      Echo: Vivek Sethi
@date:        15 March 2017
@description: Test method for retrieveObjectProperties methods.
*******************************************************************************/            
    static testmethod void retrieveObjectProperties_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id from user where isActive = true AND Username =: USERNAMECOMPLETE  limit 1];
        Map<String, String> retrieveObjectPropertiesMap = new  Map<String, String> ();
        Account objAccount = new Account();
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            retrieveObjectPropertiesMap = GlAp_RecordListTitleWithIconCtrlr.retrieveObjectProperties(OBJECTS);
            Test.stopTest();
        }
        System.assert(retrieveObjectPropertiesMap.keySet() != null);
        System.assert(retrieveObjectPropertiesMap.containsKey('iconURL'));
        
    }
}