/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        13 September 2017
@description: Test Class for CuAp_HHAccountOverrideComponentCtrlr
Revision(s):  10-10-2017 - Shivangi Gaur - Asserts moved after Test.stopTest().
              13-12-2017 - Shivangi Gaur - Updated test methods as per latest changes 
                                           done to CuAp_AccountRecordTypeController class.
              21-12-2017 - Shivangi Gaur - Updated class name as per naming standards.
@Revisions	   AT-3981 ,Tarun, Security review changes , modified classname
*******************************************************************************/

@isTest
Public Class CuAp_HHAccountOverrideCmpCtrlr_Test{

 //Variable declaration
 
    private static String USERPROFILE ='System Administrator';
    private static String USERNAME ='TestUser334'; 
    private static String HOUNSEHOLDACCOUNT ='Household Account';
    private static String HOUNSEHOLDCONTACT ='Household Contact';
    private static String NONHOUNSEHOLDACCOUNT ='Non-Household Account';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String TESTRCTYPE = 'Test RC Type';
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
 //End variable declaration
    
/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        13 September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE,USERNAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);       
        
    }
    
/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        13 September 2017
@description: Test method for fetchRecordTypeValues methods
*******************************************************************************/
    static testmethod void fetchRecordTypeValues_Positive(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];  
        
        boolean isHousehold = false;
        
        System.runAs(objUser[0]){
            
            Test.startTest();
            list<RecordType>lstOfRecordType=CuAp_HHAccountOverrideComponentCtrlr.fetchRecordTypeValues();
            Test.stopTest();
            
            System.assert(lstOfRecordType.size()>0);
            for(RecordType recType : lstOfRecordType){
                if(recType.Name == HOUNSEHOLDACCOUNT){
                    isHousehold = true;
                }
            }
            System.assertEquals(isHousehold,true);
        }
    }   
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        13 December 2017
@description: Test method for getRecTypeId methods positive scenario.
*******************************************************************************/
    static testmethod void getRecTypeId_Positive(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];  
        
        System.runAs(objUser[0]){
            
            Test.startTest();
            Id recordTypeIdContact = CuAp_HHAccountOverrideComponentCtrlr.getRecTypeId(HOUNSEHOLDACCOUNT);
            Id recordTypeIdAccount = CuAp_HHAccountOverrideComponentCtrlr.getRecTypeId(NONHOUNSEHOLDACCOUNT);
            Test.stopTest();
            
            System.assert(recordTypeIdContact !=null);
            System.assert(recordTypeIdAccount!=null);
            
        }
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        13 December 2017
@description: Test method for getRecTypeId methods negative scenario.
*******************************************************************************/
    static testmethod void getRecTypeId_Negative(){
        
        User objUser =[SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE limit 1];
        Id rcTypeIdTest;
        boolean isException = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            try{
                rcTypeIdTest = CuAp_HHAccountOverrideComponentCtrlr.getRecTypeId(TESTRCTYPE);
            }
            catch(Exception ex){
                isException = true;
            }
            
            Test.stopTest();
            
            System.assertEquals(rcTypeIdTest,null);
            //System.assertEquals(isException,true);
            
        }
    }   
}