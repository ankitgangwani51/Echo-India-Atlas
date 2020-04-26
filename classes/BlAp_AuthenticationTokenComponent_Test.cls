/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        26 October 2017
@description: Test Class for BlAp_AuthenticationTokenComponentCtrlr
*******************************************************************************/

@isTest
//test data creation for BlAp_AuthenticationTokenComponentCtrlr class
Public Class BlAp_AuthenticationTokenComponent_Test{
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME = 'TestUser';
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    
/*******************************************************************
Purpose: method to create test data 
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);   
    }
    
/*******************************************************************
Purpose: Method to test the token(Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void updateToken_Positive(){
        User objuser = [select id from user limit 1];
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        Boolean b;
        system.runas(objUser){
            Test.startTest();
            b = BlAp_AuthenticationTokenComponentCtrlr.updateToken(HEROKUSECURITY);
            system.debug('BlAp_AuthenticationTokenComponent_Test-updateToken_Positive-b= ' + b) ; 
            Test.stopTest();
            system.assertequals(TRUE,b);
        }   
    }
    
/*******************************************************************
Purpose: Method to test the token(Negative Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void updateToken_Negative(){
        User objuser = [select id from user limit 1];
        Boolean b;
        system.runas(objUser){
            try{
                Test.startTest();
                b = BlAp_AuthenticationTokenComponentCtrlr.updateToken(HEROKUSECURITY);
                Test.stopTest();
            }catch(exception e){
                system.assert(e.getmessage()!=null);
            } 
        }   
    }
}