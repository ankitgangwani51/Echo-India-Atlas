/****************************************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        29 September 2017
@description: Test Class for GlUt_TriggerHandlerBase
Revision(s):  Shivangi Gaur -- 03/Oct/2017 -- Added method MainEntry_Positive().
              Shivangi Gaur -- 07/Dec/2017 -- Incorporated review comments on AT-459 dated 30/Nov/2017.
              Shivangi Gaur -- 13/Dec/2017 -- Incorporated review comments on AT-459 dated 12/Dec/2017.
****************************************************************************************************/

@isTest
Public Class GlUt_TriggerHandlerBase_Test{
    
    //Variable declaration start
    
    private static String PROFILENAME = 'System Administrator';
    private static String USERNAME = 'TestUser';
    private static String ACCOUNTOBJECTNAME = 'Account';
    private static String EXCEPTIONMESSAGE = 'Error Not Implemented';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    
    //Variable declaration end

/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        29 September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 
        
    }
    
/******************************************************************************
@author:      Shivangi Gaur
@date:        29 September 2017
@description: Test method for InProgressEntry() method positive scenario.
*******************************************************************************/
    static testmethod void inProgressEntry_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            GlUt_TriggerHandlerObj triggerObj = new GlUt_TriggerHandlerObj ();
            triggerObj.triggerObject = GlUt_Constants.OBJSPDEVICESERVICE;
            GlUt_TriggerHandlerBase objUpdate = new GlUt_TriggerHandlerBase();
            objUpdate.inProgressEntry(triggerObj);
            
            Test.stopTest();
            System.assertEquals(GlUt_CentralDispatcher.activeFunction,objUpdate);
            
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        07 December 2017
@description: Test method for InProgressEntry() method negative scenario.
*******************************************************************************/
    static testmethod void inProgressEntry_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        boolean isException = false;
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            GlUt_TriggerHandlerObj triggerObj = new GlUt_TriggerHandlerObj ();
            triggerObj.triggerObject = null;
            GlUt_TriggerHandlerBase objUpdate = new GlUt_TriggerHandlerBase();
            try{
                objUpdate.inProgressEntry(triggerObj);
            }
            catch(Exception exc){
                isException = true;
            }
            
            Test.stopTest();
            System.assertEquals(isException,true);
            
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        03 October 2017
@description: Test method for MainEntry() method
*******************************************************************************/
    static testmethod void mainEntry_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            GlUt_TriggerHandlerObj triggerObj = new GlUt_TriggerHandlerObj ();
            triggerObj.triggerObject = GlUt_Constants.OBJSPDEVICESERVICE;
            GlUt_TriggerHandlerBase objUpdate = new GlUt_TriggerHandlerBase();
            try{
                objUpdate.mainEntry(triggerObj);
            }
            catch(exception ex){
                System.assertEquals(ex.getMessage(), EXCEPTIONMESSAGE);
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
        }
    }
}