/******************************************************************************
@author:      Echo: Vivek Sethi 
@date:        30-08-2018  
@description: Test Class for GlAp_AddHerokuJobsCtrlr
*******************************************************************************/
@isTest 
public class GlAp_HerokuBatchJobsCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static final Date TODATE  = System.today();
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
        
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
        
    } 
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to getJobTypeValues
    *******************************************************************************/
    static testmethod void getHerokuJobsFields()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
       
        List<GLAp_FieldProps> herokuJobsFieldsList = new List<GLAp_FieldProps>();
        System.runAs(objUser){
            Test.startTest(); 
            herokuJobsFieldsList = GlAp_HerokuBatchJobsCtrlr.getHerokuJobsFields();
            Test.stopTest();
            system.assertNotEquals(herokuJobsFieldsList ,Null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to calloutToHerokuPUT
    *******************************************************************************/
    static testmethod void GlAp_HerokuBatchJobsCtrlr()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_HerokuBatchJobsCtrlr.ResponseHandler responsehandler = new  GlAp_HerokuBatchJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlAp_MockHerokuBatchJobsCtrlr_Test (200));
            responsehandler  = GlAp_HerokuBatchJobsCtrlr.getHerokuJobsRecords();
            Test.stopTest();
            system.assertNotEquals(responsehandler ,Null);
        }
    }
    
     /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to GlAp_HerokuBatchJobsCtrlr
    *******************************************************************************/
    static testmethod void GlAp_HerokuBatchJobsCtrlr_deleteHerokuJob()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_HerokuBatchJobsCtrlr.ResponseHandler responsehandler = new  GlAp_HerokuBatchJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlAp_MockHerokuBatchJobsCtrlr_Test (200));
            responsehandler  = GlAp_HerokuBatchJobsCtrlr.deleteHerokuJob(105);
            Test.stopTest();
            system.assertNotEquals(responsehandler ,Null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to GlAp_HerokuBatchJobsCtrlr
    *******************************************************************************/
    static testmethod void GlAp_HerokuBatchJobsCtrlr_deleteHerokuJob_Error()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_HerokuBatchJobsCtrlr.ResponseHandler responsehandler = new  GlAp_HerokuBatchJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlAp_MockHerokuBatchJobsCtrlr_Test (300));
            responsehandler  = GlAp_HerokuBatchJobsCtrlr.deleteHerokuJob(105);
            Test.stopTest();
            system.assertNotEquals(responsehandler ,Null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to getHerokuJobStatusFields
    *******************************************************************************/
    static testmethod void getHerokuJobStatusFields()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<GLAp_FieldProps> fieldPropsList = new List<GLAp_FieldProps>();
        System.runAs(objUser){
            Test.startTest(); 
            fieldPropsList  = GlAp_HerokuBatchJobsCtrlr.getHerokuJobStatusFields();
            Test.stopTest();
            system.assertNotEquals(fieldPropsList ,Null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to getSfdcBaseUrl
    *******************************************************************************/
    static testmethod void getSfdcBaseUrl()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        String getSfdcBaseUrlString;
        System.runAs(objUser){
            Test.startTest(); 
            getSfdcBaseUrlString  = GlAp_HerokuBatchJobsCtrlr.getSfdcBaseUrl();
            Test.stopTest();
            system.assertNotEquals(getSfdcBaseUrlString ,Null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi 
    @date:        30-08-2018 
    @description: Method to getHerokuJobStatusRecords
    *******************************************************************************/
    static testmethod void getHerokuJobStatusRecords()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        GlAp_HerokuBatchJobsCtrlr.ResponseHandler responsehandler = new  GlAp_HerokuBatchJobsCtrlr.ResponseHandler();
       
        System.runAs(objUser){
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new GlAp_MockHerokuBatchJobsCtrlr_Test (200));
            responsehandler  = GlAp_HerokuBatchJobsCtrlr.getHerokuJobStatusRecords(String.valueOf(TODATE - 30) , String.valueOf(TODATE));
            Test.stopTest();
            system.assertNotEquals(responsehandler ,Null);
        }
    }
    
    
}