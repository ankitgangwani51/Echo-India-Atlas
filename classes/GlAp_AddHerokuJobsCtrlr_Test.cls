/******************************************************************************
@author:      Echo: Vivek Sethi 
@date:        30-08-2018  
@description: Test Class for GlAp_AddHerokuJobsCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
@Revisions	  05/03/19 Tarun , Fixed consdev test class deployment failures.
*******************************************************************************/

@isTest 
public class GlAp_AddHerokuJobsCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACTIVETAB = 'Immediate'; 
    private static final String ACTIVETAB1 = 'Test'; 
    private static final String CRONEXPRESSION = '0 0 12 1/1 * ? *'; 
    private static final String JOBTYPE= 'Batch Request'; 
    private static final String JOBTYPE1= 'Accruals';
    private static final Integer HEROKUID = 12321; 
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static final Date TODATE  = System.today();
    private static final STRING ADDHEROKUJOBRESPONSEPOSITIVE = 'GlAp_AddHerokuJobsCtrlrResponse_Positive';
    private static final STRING ADDHEROKUJOBRESPONSENEGATIVE = 'GlAp_AddHerokuJobsCtrlrResponse_Negative';
    private static final String TESTREGION = 'Test Region';
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
        
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
    } 
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to getJobTypeValues
    *******************************************************************************/
    static testmethod void getJobTypeValues()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
       
        List<String> getJobTypeValue = new List<String>();
        System.runAs(objUser){
            Test.startTest(); 
            getJobTypeValue = GlAp_AddHerokuJobsCtrlr.getJobTypeValues();
            Test.stopTest();
            System.assert(getJobTypeValue.size() > 0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPUT
    *******************************************************************************/
    static testmethod void calloutToHerokuPUT_ActiveTabImmediate()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_AddHerokuJobsCtrlr.ResponseHandler responsehandler = new  GlAp_AddHerokuJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(ADDHEROKUJOBRESPONSEPOSITIVE));
            responsehandler  = GlAp_AddHerokuJobsCtrlr.calloutToHerokuPUT(ACTIVETAB,CRONEXPRESSION,JOBTYPE,HEROKUID);
            Test.stopTest();
            system.assertEquals(responsehandler.isSuccess , true);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPUT
    *******************************************************************************/
    static testmethod void calloutToHerokuPUT()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_AddHerokuJobsCtrlr.ResponseHandler responsehandler = new  GlAp_AddHerokuJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(ADDHEROKUJOBRESPONSEPOSITIVE));
            responsehandler  = GlAp_AddHerokuJobsCtrlr.calloutToHerokuPUT(ACTIVETAB1,CRONEXPRESSION,JOBTYPE,HEROKUID);
            Test.stopTest();
            system.assertEquals(responsehandler.isSuccess , true);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPUT
    *******************************************************************************/
    static testmethod void calloutToHerokuPUT_Error()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_AddHerokuJobsCtrlr.ResponseHandler responsehandler = new  GlAp_AddHerokuJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(ADDHEROKUJOBRESPONSENEGATIVE));
            responsehandler  = GlAp_AddHerokuJobsCtrlr.calloutToHerokuPUT(ACTIVETAB,CRONEXPRESSION,JOBTYPE,HEROKUID);
            Test.stopTest();
            system.assertEquals(responsehandler.isSuccess , false);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPOST
    *******************************************************************************/
    static testmethod void calloutToHerokuPOST_ActiveTabImmediate()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_AddHerokuJobsCtrlr.ResponseHandler responsehandler = new  GlAp_AddHerokuJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(ADDHEROKUJOBRESPONSEPOSITIVE));
            responsehandler  = GlAp_AddHerokuJobsCtrlr.calloutToHerokuPOST(ACTIVETAB,CRONEXPRESSION,JOBTYPE1,String.valueOf(TODATE));
            Test.stopTest();
            system.assertEquals(responsehandler.isSuccess , true);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPOST
    *******************************************************************************/
    static testmethod void calloutToHerokuPOSTjobTypeAccruals()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_AddHerokuJobsCtrlr.ResponseHandler responsehandler = new  GlAp_AddHerokuJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(ADDHEROKUJOBRESPONSEPOSITIVE));
            responsehandler  = GlAp_AddHerokuJobsCtrlr.calloutToHerokuPOST(ACTIVETAB1,CRONEXPRESSION,JOBTYPE,String.valueOf(TODATE));
            Test.stopTest();
            system.assertEquals(responsehandler.isSuccess , true);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPOST
    *******************************************************************************/
    static testmethod void calloutToHerokuPOSTjobTypeAccruals1()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_AddHerokuJobsCtrlr.ResponseHandler responsehandler = new  GlAp_AddHerokuJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(ADDHEROKUJOBRESPONSEPOSITIVE));
            responsehandler  = GlAp_AddHerokuJobsCtrlr.calloutToHerokuPOST(ACTIVETAB,CRONEXPRESSION,JOBTYPE,String.valueOf(TODATE));
            Test.stopTest();
            system.assertEquals(responsehandler.isSuccess , true);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPOST
    *******************************************************************************/
    static testmethod void calloutToHerokuPOSTjobTypeAccruals_Error()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_AddHerokuJobsCtrlr.ResponseHandler responsehandler = new  GlAp_AddHerokuJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(ADDHEROKUJOBRESPONSENEGATIVE));
            responsehandler  = GlAp_AddHerokuJobsCtrlr.calloutToHerokuPOST(ACTIVETAB1,CRONEXPRESSION,JOBTYPE,String.valueOf(TODATE));
            Test.stopTest();
            system.assertEquals(responsehandler.isSuccess , false);
        }
    }
    
}