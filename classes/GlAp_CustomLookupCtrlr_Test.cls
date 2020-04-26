/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        10 November 2017
@description: Test Class for GlAp_CustomLookUpCtrlr
*******************************************************************************/
@isTest
Public Class GlAp_CustomLookupCtrlr_Test{
    
    //Variable declaration start
    private static String  USERPROFILENAME = 'System Administrator';
    private static String  USERNAME        = 'TestUser';
    private static String  MANAGERID       =  Null;
    private static String  ACCNAME         = 'Demo';
    private static String  SRCHNAME        = 'Dem';
    private static String  OBJECTNAME      = 'Account';
    private static String  FLDAPITEXT      = 'Id,Name';
    private static Integer RLIMIT          =  6;
    private static String  FLDAPISRCH      = 'Name';
    private static String  FLDAPIFLTEXT    = 'RecordType.Name';
    private static String  FLDAPIFLVAL     = 'Household Account';
    private static String  RecTypeName     = 'Household Account';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    //Variable declaration end
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        10 November 2017
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILENAME, USERNAME , MANAGERID);
        Database.insert(objUser);
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecTypeName).getRecordTypeId();
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCNAME);
        objAccount.recordtypeid = RecordTypeIdAccount;
        Database.insert(objAccount);
        
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        10 November 2017
    @description: Test method for searchDB method
    *******************************************************************************/            
    static testmethod void searchDB_Positive(){
        //Query user record created in test setup data method
        User objUser = [SELECT Id FROM User WHERE isActive = true AND UserName =: USERNAMECOMPLETE LIMIT 1];
        
        
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            String jsonStr = GlAp_CustomLookupCtrlr.searchDB(OBJECTNAME, FLDAPITEXT , RLIMIT , FLDAPISRCH , SRCHNAME, FLDAPIFLTEXT, FLDAPIFLVAL, null, null);       
            List<sObject> sObjList = (List<sObject>)JSON.deserialize(jsonStr,List<sObject>.class);
            Test.stopTest();            
            System.assertEquals(1,sObjList.size());
            System.assertEquals('Demo',sObjList.get(0).get('Name'));
        }
    }
    
    /******************************************************************************
    @author:      Echo: Gopal Gupta
    @date:        12 December 2017
    @description: Test method for searchDB method
    *******************************************************************************/            
    static testmethod void searchDB_Negative(){
        //Query user record created in test setup data method
        User objUser = [SELECT Id FROM User WHERE isActive = true AND UserName =: USERNAMECOMPLETE LIMIT 1];
        
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            String jsonStr = GlAp_CustomLookupCtrlr.searchDB(OBJECTNAME, FLDAPITEXT , RLIMIT , FLDAPISRCH , SRCHNAME+'123', FLDAPIFLTEXT, FLDAPIFLVAL, null, null);       
            List<sObject> sObjList = (List<sObject>)JSON.deserialize(jsonStr,List<sObject>.class);
            Test.stopTest();            
            System.assertEquals(0,sObjList.size());
        }
    }
}