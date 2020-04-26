/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        06 October 2017
@description: Test Class for GlAp_LightningDataAccess
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
//test data creation for GlAp_LightningDataAccess class
public class GlAp_LightningDataAccess_Test{
   
    private static final String HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME = 'TestUser'; 
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String BILL_NAME ='TestBill';
    private static final String OBJECTAPINAME = 'Account';
    private static final String OBJECTAPINAME1 = 'Account1';
    private static final String SFIELDSETNAME2 = GlUt_NamespacePrefix.getNamespacePrefix()+'Dummy_FieldSet2';
    private static final String SFIELDSETNAME = GlUt_NamespacePrefix.getNamespacePrefix()+'Dummy_FieldSet';
    private static final String WHERECLAUSE = 'where name=\'TestAccount\'';
    private static final String QUERYSTRING = 'select id,name from account';
    private static final String JSONSTRINGTOUPDATE ='{"id":"objAccount.id"}';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String NAMEFIELD = 'Name';
    private static final String TESTNAMEFIELD = 'Name1';
    private static final String OWNERSTRING = 'Owner';
    private static final String EXCMSG = 'Update failed';
    private static final String JSONPART1 = '{"id":"';
    private static final String JSONPART2 = '"}';
    private static final String CUSREFFIELD = GlUt_APIConstantsContracts.CUSTOMERAPINAME;
    private static final String CONTRACTAPINAME = GlUt_APIConstantsContracts.CONTRACTAPINAME ;
    private static final String FIELDTYPETEXT = 'text';
    
/*******************************************************************
Purpose: method to create test data used by all USER_NAMEtest methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    static void createTestData(){
       
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation();
        Database.insert(objBillCalculation);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_ONE,objAccount);
        Database.insert(objContract);
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME,objContract);
        Database.insert(objBill);

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getFieldSetFields(){
       
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser){
            Test.startTest();
            List<String>fieldSetFields = GlAp_LightningDataAccess.getFieldSetFields(OBJECTAPINAME,SFIELDSETNAME);
            Test.stopTest();
            system.assert(fieldSetFields!=null);
            system.assert(fieldSetFields.size()==3);
            system.assert(fieldSetFields[0] == NAMEFIELD);           
        }  

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getFieldSetFields_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
        
            Test.startTest();
            try{
                List<String>fieldSetFields = GlAp_LightningDataAccess.getFieldSetFields(OBJECTAPINAME,SFIELDSETNAME2);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
           
        }   

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getObjectsFieldPropertiesByFieldSetName(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps>lstFieldProp =GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(OBJECTAPINAME,SFIELDSETNAME);
            Test.stopTest();
            system.assert(lstFieldProp!=null);
            system.assert(lstFieldProp.size()==3);
            system.assert(lstFieldProp[0].fieldName== NAMEFIELD);
            
        }

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getObjectsFieldPropertiesByFieldSetName_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        
        boolean isException = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            try{
                List<GlAp_FieldProps>lstFieldProp =GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(OBJECTAPINAME,SFIELDSETNAME2);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
        }   

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getObjectsFieldProperties(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser){
            
            List<String>fieldNames = new List<String>();
            fieldNames.add(NAMEFIELD);
            Test.startTest();
            List<GLAp_FieldProps> ObjectsFieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(OBJECTAPINAME,fieldNames);
            Test.stopTest();
            
            System.assert(ObjectsFieldProperties!=null);
            System.assert(ObjectsFieldProperties[0].isFLSVisible);
            
        } 

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getObjectsFieldProperties_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        
        boolean isException = false;
        
        System.runAs(objUser){
            List<String>fieldNames = new List<String>();
            fieldNames.add(TESTNAMEFIELD);
            Test.startTest();
            try{
                List<GLAp_FieldProps> ObjectsFieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(OBJECTAPINAME,fieldNames);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
            
        }   

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getFilteredRecordsByFieldList(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        
        System.runAs(objUser){
            List<String>fieldNames = new List<String>();
            fieldNames.add(NAMEFIELD);
            Test.startTest(); 
            List<sObject>FilteredRecordsByFieldList = GlAp_LightningDataAccess.getFilteredRecordsByFieldList(OBJECTAPINAME,fieldNames,WHERECLAUSE);
            Test.stopTest();
            
            System.assert(FilteredRecordsByFieldList!=null);
            System.assertEquals(FilteredRecordsByFieldList[0].id,objAccount.id);
            
        }   

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getFilteredRecordsByFieldList_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser){
            
            List<String>fieldNames = new List<String>();
            Test.startTest(); 
            List<sObject>FilteredRecordsByFieldList = GlAp_LightningDataAccess.getFilteredRecordsByFieldList(OBJECTAPINAME1,fieldNames,WHERECLAUSE);
            Test.stopTest();
            
            System.assertEquals(FilteredRecordsByFieldList.isEmpty(),true);
            
        }   

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getRecordsByFieldList_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
            List<String>fieldNames = new List<String>();
            fieldNames.add(TESTNAMEFIELD);
            Test.startTest(); 
            List<sObject>RecordsByFieldList = GlAp_LightningDataAccess.getRecordsByFieldList(OBJECTAPINAME1,fieldNames);
            Test.stopTest();
            
            System.assertEquals(RecordsByFieldList.isEmpty(),true);
        }  

    }
    /*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getRecordByIdAndFieldList(){
       
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        
        System.runAs(objUser){
            
            List<String>fieldNames = new List<String>();
            fieldNames.add(NAMEFIELD);
            String sID = objAccount.id;
            
            Test.startTest(); 
            sObject objsObject = GlAp_LightningDataAccess.getRecordByIdAndFieldList(OBJECTAPINAME,sID,fieldNames);
            Test.stopTest();
            
            System.assertEquals(objsObject.id,objAccount.id);         
           
        }   

    }
    /*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getRecordByIdAndFieldList_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        
        System.runAs(objUser){
            List<String>fieldNames = new List<String>();
            Boolean isException;
            fieldNames.add(TESTNAMEFIELD);
            String sId = objAccount.id;
            
            try{
                Test.startTest(); 
                sObject objsObject = GlAp_LightningDataAccess.getRecordByIdAndFieldList(OBJECTAPINAME1,sId,fieldNames);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
        }

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_updateObjectRecord(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            String response = GlAp_LightningDataAccess.updateObjectRecord(objAccount);
            Test.stopTest();
            
            System.assert(response!='');
            //As per controller class, response returned is null if update has taken successfully, hence asserting for null response
            System.assertEquals(response, null);
            
        }  

    }
    /*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_updateObjectRecord_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;

        System.runAs(objUser){
            Test.startTest();
            try{
                String response = GlAp_LightningDataAccess.updateObjectRecord(null);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
            
        }  

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_retrieveListOfRecordsByQueryString(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account accObj = [Select id, Name from Account limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            List<sObject>lstOfsObject = GlAp_LightningDataAccess.retrieveListOfRecordsByQueryString(QUERYSTRING);
            Test.stopTest();
            
            System.assert(lstOfsObject!=null);
            System.assert(lstOfsObject.size()==1);
            System.assertEquals(lstOfsObject[0].Id,accObj.id);
            
        } 

    }
    
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_retrieveListOfRecordsByQueryString_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        
        boolean isException = false;
        System.runAs(objUser){
        
            Test.startTest();
            try{
                List<sObject>lstOfsObject = GlAp_LightningDataAccess.retrieveListOfRecordsByQueryString(null);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
            
        }   

    }
    
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_getRecordsByFieldSetName(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        
        System.runAs(objUser){
            
            Test.startTest(); 
            List<sObject>lstofsOjectret = GlAp_LightningDataAccess.getRecordsByFieldSetName(OBJECTAPINAME,SFIELDSETNAME);
            Test.stopTest();
            
            System.assert(lstofsOjectret!=null);
            System.assert(lstofsOjectret.size()==1);
            System.assertEquals(lstofsOjectret[0].id,objAccount.id);
            
        }  

    }
    
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_getRecordsByFieldSetName_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
            
            Test.startTest(); 
            try{
                List<sObject>lstofsOjectret = GlAp_LightningDataAccess.getRecordsByFieldSetName(OBJECTAPINAME,SFIELDSETNAME2);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
            
        }  

    }
    
/*******************************************************************
Purpose: Method to test the most recent bill Id (Negative Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getObjectsFieldPropertiesByFieldSetNameFor2ColForm_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        List<List<GlAp_FieldProps>> lstFieldPropret = new List<List<GlAp_FieldProps>>();
        
        System.runAs(objUser){
            
            List<String>fieldNames = new List<String>();
            Test.startTest();
            try{ 
                lstFieldPropret = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(OBJECTAPINAME1,SFIELDSETNAME2);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assert(lstFieldPropret.size() == 0);
        }  
    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getObjectsFieldPropertiesByFieldSetNameFor2ColForm_Positive(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
       
        System.runAs(objUser){
            
            List<String>fieldNames = new List<String>();
            Test.startTest();
            List<List<GlAp_FieldProps>>lstFieldPropret= GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(OBJECTAPINAME,SFIELDSETNAME);
            Test.stopTest();
            
            System.assertEquals(lstFieldPropret.size(),2);
            System.assertEquals(lstFieldPropret[0][0].fieldType,FIELDTYPETEXT);
            System.assertEquals(lstFieldPropret[0][0].fieldName,NAMEFIELD);
            
        }   

    }    
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getRecordByIdAndFieldSetName(){
       
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        
        System.runAs(objUser){
            
            String sID = objAccount.id;
            Test.startTest();
            sObject objsObjectret = GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(OBJECTAPINAME,sID,SFIELDSETNAME);
            Test.stopTest();
            
            System.assert(objsObjectret!=null);
            System.assertEquals(objsObjectret.id,objAccount.id);
           
        }   

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_getRecordByIdAndFieldSetName_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
            
            String sID = objAccount.id;
            Test.startTest();
            try{
                sObject objsObjectret = GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(OBJECTAPINAME,sID,SFIELDSETNAME2);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true); 
           
        }   

    }
    
    /*******************************************************************
Purpose: Method to test the most recent bill Id (negative Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_getRelatedRecordsByFieldSetName(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        
        System.runAs(objUser){
            
            List<String>fieldNames = new List<String>();
            String sID = objAccount.id;
            Test.startTest();
            List<sObject>lstOfContract = GlAp_LightningDataAccess.getRelatedRecordsByFieldSetName(sID,CUSREFFIELD,Null,CONTRACTAPINAME,null);
            Test.stopTest();
            
            system.assertEquals(lstOfContract.size() , 1);        
           
        } 

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void GlApLightningDataAccess_getRelatedRecordsByFieldSetName_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [select id,name from account limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
            List<String>fieldNames = new List<String>();
            fieldNames.add(NAMEFIELD);
            String sID = objAccount.id;
            Test.startTest();
            
            try{
                List<sObject>lstOfContract = GlAp_LightningDataAccess.getRelatedRecordsByFieldSetName(sID,OWNERSTRING,Null,OBJECTAPINAME,SFIELDSETNAME2);
            }
            catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
        }

    }
    
/*******************************************************************
Purpose: Method to test the most recent bill Id (Positive Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_updateObjectwithjsonPositive(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, Name from Account limit 1];
        System.runAs(objUser){
            String JSONSTRINGTOUPDATETEST = JSONPART1+objAccount.id+JSONPART2;
            Test.startTest(); 
            String responseOfUpdate = GlAp_LightningDataAccess.updateObject(OBJECTAPINAME,JSONSTRINGTOUPDATETEST);
            Test.stopTest();
            
            //As per controller class, response returned is null if update has taken successfully, hence asserting for null response
            System.assertEquals(responseOfUpdate, null);           
        }   

    }
/*******************************************************************
Purpose: Method to test the most recent bill Id (Negative Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_updateObjectwithjsonNegative(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        Account objAccount = [Select id, Name from Account limit 1];
        System.runAs(objUser){           
            
            Test.startTest(); 
            try{
                String responseOfUpdate = GlAp_LightningDataAccess.updateObject(OBJECTAPINAME,JSONSTRINGTOUPDATE);                       
            }
            catch(Exception ex){                
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
            
            //As per controller class, response returned will be exception String if DML exception thrown, hence asserting for not null response            
            //System.assertNotEquals(responseOfUpdate, null);  
            
        }

    }   
/*******************************************************************
Purpose: Method to test the most recent bill Id (Negative Scenario)
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGlApLightningDataAccess_updateObjectwithjson_Neg(){
        
        User objuser = [select id from user where username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
       
            Test.startTest(); 
            try{
                String responseOfUpdate = GlAp_LightningDataAccess.updateObject(null,JSONSTRINGTOUPDATE );
            }
            catch(Exception ex){                
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);           
        } 

    }

}