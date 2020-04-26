/****************************************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        27 September 2017
@description: Test Class for GlUt_ObjectUpdater
Revision(s):  28-09-2017 - Shivangi Gaur - Removed hardcoding from test methods
                                           and implemented other code quality related aspects.
              15-12-2017 - Shivangi Gaur - Incorporated review comments on AT-457 dated 29-11-2017.
              20-12-2017 - Shivangi Gaur - Incorporated review comments on AT-457 dated 19-12-2017.
              08-Mar-2018 MT - Use the field from constant class
              20-Apr-2018 - Swati Mathur - Modified test class following main class changes
****************************************************************************************************/

@isTest
Public Class GlUt_ObjectUpdater_Test{
    
    
    //Variable declaration start    
    private static String PROFILENAME = 'System Administrator';
    private static String USERNAME = 'TestUser444';
    private static String CONFIRSTNAME = 'Test';
    private static String CONLASTNAME = 'Contact 101'; 
    private static String PASSWORDFIELD = GlUt_APIConstantsAccount.CONSIDERATIONPASSWORDAPINAME.toLowerCase();
    private static String PASSWORDDATA = 'New Password';
    private static String CONTACTOBJECTNAME = 'Contact';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String DUMMYFIELD = 'Test Field'; 
    private static String DUMMYDATA = 'Test Data'; 
    //Variable declaration end

/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        27 September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        
        //Create contact record
        Contact objCon = GlUt_FactoryData_Test.CreateContact(CONFIRSTNAME,CONLASTNAME);
        objCon.ConsiderationPassword__c = PASSWORDDATA;
        Database.insert(objCon);
    }    

/******************************************************************************
@author:      Shivangi Gaur
@date:        27 September 2017
@description: Test method for getSObject() method to get the SObject details.
*******************************************************************************/
    static testmethod void getSObject_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select Id, Name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Query contact record created in test setup data method
        //Contact conObj = [Select id, ConsiderationPassword__c from Contact limit 1];
        GlUt_ObjectUpdater objUpdate = new GlUt_ObjectUpdater(CONTACTOBJECTNAME);       
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();             
            SObject conNew = objUpdate.getSObject();            
            Test.stopTest();
            
            System.assertEquals(conNew.getSObjectType().getDescribe().getName(), CONTACTOBJECTNAME);
            
        }       
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        20 December 2017
@description: Test method for getSObject() method negative scenario.
*******************************************************************************/
    static testmethod void getSObject_Negative(){
        
        boolean isException = false;
        SObject conNew ;
        //Query user record created in test setup data method
        User objUser = [Select Id, Name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();            
            try{
                GlUt_ObjectUpdater objUpdate = new GlUt_ObjectUpdater(null); 
                conNew = objUpdate.getSObject();
            }
            catch(Exception exc){
                isException = true;
            }            
            Test.stopTest();
            
            System.assertEquals(conNew, null);
            
        }       
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        27 September 2017
@description: Test method for addField() method positive scenario where field 
              holds certain value and is available in objectString.
*******************************************************************************/
    static testmethod void addField_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        GlUt_ObjectUpdater objUpdate = new GlUt_ObjectUpdater(CONTACTOBJECTNAME);
                
        //Run test class in user context
        System.runAs(objUser){            
            Test.startTest();  
            objUpdate.addField(PASSWORDFIELD, PASSWORDDATA);
            String objStr1 = objUpdate.objectString;
            Test.stopTest();
            System.assert(String.isNotBlank(objStr1)); 
        }       
        
    }

}