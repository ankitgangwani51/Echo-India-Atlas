/******************************************************************************
@author         Echo: Sudhir Kumar
@date           03 Dec 2018
@description    Test Class for LoIn_ReqInformationStatement
******************************************************************************/
@isTest
private class LoIn_ReqInformationStatement_Test {
	private static final String USER_PROFILE        	= 'System Administrator' ;
    private static final String USER_NAME           	= 'LoIn_ReqInfoStatementTestUser' ;
    private static final String USERNAMECOMPLETE   		=  USER_NAME + '@unitest.com' ;
    private static final String ZIPCODE1 				= 'WS2 8DE';	
    private static final String ZIPCODE2 				= 'SK8 9PK';	
    private static final String ZIPCODE3 				= 'SK8 3PK';	
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData() {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        Database.insert(objUser); 
		System.runAs(objUser) {
            // Create Location Record            
            Location__c objLocation1 = GlUt_FactoryData_Test.createLocation(ZIPCODE1);
            Location__c objLocation2 = GlUt_FactoryData_Test.createLocation(ZIPCODE2);
            Location__c objLocation3 = GlUt_FactoryData_Test.createLocation(ZIPCODE3);
            Database.insert(new list<Location__c> {objLocation1, objLocation2, objLocation3});
            
            //Custodian Req
            
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Dec 2018
    @description    positive test scenario for getInformationStatement method
    *******************************************************************************/ 
    static testmethod void getInformationStatement_Positive() {
        User objUser = [select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Dec 2018
    @description    Negative test scenario for getInformationStatement method
    *******************************************************************************/ 
    static testmethod void getInformationStatement_Negative() {
        User objUser = [select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Dec 2018
    @description    positive test scenario for getCustodianResponses method
    *******************************************************************************/ 
    static testmethod void getCustodianResponses_Positive() {
        User objUser = [select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Dec 2018
    @description    Negative test scenario for getCustodianResponses method
    *******************************************************************************/ 
    static testmethod void getCustodianResponses_Negative() {
        User objUser = [select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Dec 2018
    @description    positive test scenario for getLocationId method
    *******************************************************************************/ 
    static testmethod void getLocationId_Positive() {
        User objUser = [select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Dec 2018
    @description    Negative test scenario for getLocationId method
    *******************************************************************************/ 
    static testmethod void getLocationId_Negative() {
        User objUser = [select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            
        }
    }
}