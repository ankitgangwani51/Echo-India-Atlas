/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        05 September 2017
@description: Test Class for BlAp_GeneratePDFComponentCtrlr
Revision(s)   21-12-2017 - Shivangi Gaur - Updated class name as per naming convention.
@Revisions		 AT-3984 . Tarun, Changed the name of class as per security review changes 
*******************************************************************************/

@isTest
//test data creation for CuAp_ContactRecordTypeCtrlr_Test class
Public Class CuAp_HHContactOverrideCmpCtrlr_Test {
    
    //Variable declaration
    
    private static String USERPROFILE ='System Administrator';
    private static String USERNAME ='TestUser322'; 
    private static String RECORDTYPELABEL ='Household Contact';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String TESTRCTYPEID = '123454678798098';
    
    //End variable declaration    
    
/*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE ,USERNAME ,null);
        Database.insert(objUser); 
    }
    
/*******************************************************************
Purpose: Method to test getRecTypeName method positive scenario.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void getRecTypeName_Positive(){
        User objuser = [select id from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        Id recTypeIdHH = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RECORDTYPELABEL).getRecordTypeId();
        
        System.runAs(objuser){
            
            Test.startTest();            
            String recTypeName = CuAp_HHContactOverrideComponentCtrlr.getRecTypeName(recTypeIdHH);            
            Test.stopTest();
            
            System.assertEquals(recTypeName,RECORDTYPELABEL);
        }
    }
/*******************************************************************
Purpose: Method to test getRecTypeName method negative scenario.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void getRecTypeName_Negative(){
        User objuser = [select id from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        System.runAs(objuser){
            
            Test.startTest();
            try{
                String recTypeName = CuAp_HHContactOverrideComponentCtrlr.getRecTypeName(TESTRCTYPEID);
            }
            catch(Exception ex){
                isException = true;
            }           
            Test.stopTest();
            
            System.assertEquals(isException,true);
        }
    }   
}