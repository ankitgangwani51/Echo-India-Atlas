/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        28 September 2017
@description: Test Class for BlAp_CombinedRecord 
@Revisions : 29 Dec 2017 - Made changes to test class to cover all variables
*******************************************************************************/

@isTest
//test data creation for BlAp_CombinedRecord class
public Class BlAp_CombinedRecord_Test{
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='TestUser';    
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static final String UNIQUE_ID= 'uniqueId';
    private static final String ID_MAP= 'Id';
    private static final String VALUE_MAP= 'value';
       
/*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
    }
    
/*******************************************************************
Purpose: Method to test BlAp_CombinedRecord class
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void combinedRecord_Positive(){
        User objUser =[SELECT id,name FROM user WHERE isActive=true AND LastName = :USER_LNAME limit 1];
        BlAp_CombinedRecord objBlAp_CombinedRecord = new BlAp_CombinedRecord();
        System.runAs(objUser){
            Test.startTest();
            
            //isSelected
            objBlAp_CombinedRecord.isSelected = true;
            
            //uniqueId
            objBlAp_CombinedRecord.uniqueId = UNIQUE_ID;
            string uniqueId =objBlAp_CombinedRecord.uniqueId;
            
            //checkboxId
            string checkboxId = objBlAp_CombinedRecord.checkboxId;
            
            //objectMap
            Map<string, sObject> objectMap = new Map<string, sObject>();
            objectMap.put(objUser.Id, objUser);
            objBlAp_CombinedRecord.objectMap = objectMap ;
            
            // transformFieldMap
            Map<string, string> mapInnerTransformField = new Map<string, string>();            
            mapInnerTransformField.put(ID_MAP,VALUE_MAP);
            Map<string,  Map<string, string>> mapTransformField = new Map<string,  Map<string, string>>();
            mapTransformField.put(objUser.Id, mapInnerTransformField);
            objBlAp_CombinedRecord.transformFieldMap = mapTransformField;
            
            // readOnlyFields
            Map<string, boolean> readOnlyFields = new Map<string, boolean>();
            readOnlyFields.put(objUser.ID,true);
            objBlAp_CombinedRecord.readOnlyFields = readOnlyFields;            
            
            Test.stopTest();
            
            System.assertEquals(objBlAp_CombinedRecord.isSelected, true);            
            System.assertEquals(objBlAp_CombinedRecord.uniqueId, uniqueId);            
            System.assert(checkboxId.contains(uniqueId));
            System.assertEquals(BlAp_Constants.ADDCHECKBOX + uniqueId, checkboxId);            
            System.assertEquals( objBlAp_CombinedRecord.transformFieldMap.get(objUser.Id).get(ID_MAP),VALUE_MAP);
            System.assertEquals( objBlAp_CombinedRecord.objectMap.get(objUser.Id),objUser);
            System.assertEquals( objBlAp_CombinedRecord.readOnlyFields.get(objUser.Id),true);
            
        }
    }
}