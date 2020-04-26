/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        27 September 2017
@description: Test Class for GlUt_CentralDispatcher
*******************************************************************************/
@isTest
public class GlUt_CentralDispatcher_Test{

    private static string USERPROFILENAME = 'System Administrator';
    private static string USERNAME = 'TestUser';
    private static string MANAGERID = Null;
    private static string SOBJECTTYPE = 'Account';
    private static string DUMMYOBJECT = 'DUMMYOBJECT';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        27 September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){

        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILENAME, USERNAME, MANAGERID);
        Database.insert(objUser);

        GlUt_DisableAutomation__c automationSetting = GlUt_FactoryData_Test.createAutomationSetting();
        automationSetting.AccountTriggers__c = False;
        Database.insert(automationSetting);

    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        27 September 2017
@description: To test mainEntry method positive scenario
*******************************************************************************/    
    static testmethod void mainEntry_Positive(){
        GlUt_TriggerHandlerObj inputParam = new GlUt_TriggerHandlerObj ();
        inputParam.triggerObject = SOBJECTTYPE;
        inputParam.isBefore = true;
        inputParam.isInsert = true;

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Run test class in user context
        System.runAs(objUser){            
            Test.startTest();        
            GlUt_CentralDispatcher.mainEntry(inputParam);        
            Test.stopTest();

            System.assertEquals(inputParam.triggerObject, SOBJECTTYPE);
        }
    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        06 -Oct 2017
@description: To test mainEntry method negative scenario
*******************************************************************************/    
    static testmethod void mainEntry_Negative(){
        GlUt_TriggerHandlerObj inputParam = new GlUt_TriggerHandlerObj ();
        inputParam.triggerObject = DUMMYOBJECT;
        inputParam.isBefore = true;
        inputParam.isInsert = true;

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            GlUt_CentralDispatcher.mainEntry(inputParam);
            Test.stopTest();
            System.assertNotEquals(inputParam.TriggerObject, SOBJECTTYPE);
        }
    }
}