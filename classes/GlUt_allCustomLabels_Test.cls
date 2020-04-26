/******************************************************************************
@author         Echo: Tarun Gupta
@date           12 Mar 2019
@description    Test class for CuAp_AUTransferCreditOrDebitCtrlr
*******************************************************************************/
@isTest
public class GlUt_allCustomLabels_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Mar 2019
	@description: Positive method of GlUt_allCustomLabels  
	*******************************************************************************/
    static testmethod void retrieveAllLables(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                GlUt_allCustomLabels objLabels = new GlUt_allCustomLabels();
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
        }          
    }
}