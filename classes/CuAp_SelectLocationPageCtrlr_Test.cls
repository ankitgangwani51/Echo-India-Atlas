/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        27 September 2017
@description: Test Class for CuAp_SelectLocationPageCtrlr
Revisions(s): 10-Oct-2017 -- Shivangi Gaur -- Updated class to remove hard coding
              and implement other code quality aspects.
              15-Dec-2017 -- Shivangi Gaur -- Incorporated review comments on AT-426 
                                              dated 28-Nov-2017.
              20-Dec-2017 -- Shivangi Gaur -- Added method testForSOQLInjection() to test for 
                                              SOQL injection in main class as per review comments on AT-426 dated 19-12-2017.
              21-Dec-2017 -- Shivangi Gaur -- Incorporated review comments on AT-426 dated 20/Dec/2017.
              08-Mar-2018 MT - Use the field from constant class
*******************************************************************************/

@isTest
public class CuAp_SelectLocationPageCtrlr_Test{

    
    //Variable declaration start
    
    private static String PROFILENAME = 'System Administrator';
    private static String USERNAME = 'TestUser111';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String LOCATIONNAME = 'Test Location';
    private static String STATE = 'Test State';
    private static String POSTCODE = 'WC1B 5BE';
    private static String CITY = 'Test City';
    private static String COUNTRY = 'Test Country';
    private static String NULLVALUE = '';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String TEXTFIELDTYPE = 'text';
    private static String TEXTAREAFIELDTYPE = 'TextArea';
    private static String SOQLINJECTIONTEST = 'abc%\' OR ' + GlUt_APIConstantsLocation.POSTALCODEAPINAME + ' LIKE \'% ';
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

        //Create location data
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATIONNAME);
        objLocation.LocationSubType__c= LOCATION_SUB_TYPE; 
        objLocation.Street__c = STREET;
        objLocation.State__c = STATE;
        objLocation.PostalCode__c = POSTCODE;
        objLocation.City__c = CITY;
        objLocation.Country__c = COUNTRY;
        Database.insert(objLocation);
    }
    
/******************************************************************************
@author:      Shivangi Gaur
@date:        27 September 2017
@description: Test method for retrieveLocationPropDetails() method
*******************************************************************************/
    static testmethod void retrieveLocationPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = CuAp_SelectLocationPageCtrlr.retrieveLocationPropDetails();
            Test.stopTest();
            
            System.assert(lstFieldProps != null);
            System.assertEquals(lstFieldProps[0].isEditable,false);
            System.assertEquals(lstFieldProps[0].fieldType,TEXTAREAFIELDTYPE);
            System.assertEquals(lstFieldProps[1].fieldType,TEXTFIELDTYPE);
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        15 December 2017
@description: Test method for retrieveSearchLocationDetails() method
*******************************************************************************/
    static testmethod void retrieveSearchLocationDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<List<GLAp_FieldProps>> lstFieldDets = CuAp_SelectLocationPageCtrlr.retrieveSearchLocationDetails();
            Test.stopTest();
            
            System.assert(lstFieldDets != null);
            System.assertEquals(lstFieldDets.size(),3);
            System.assertEquals(lstFieldDets[0][0].fieldName,CuAp_Constants.STREETAPINAME);
            System.assertEquals(lstFieldDets[0][1].fieldName,CuAp_Constants.CITYAPINAME);
            System.assertEquals(lstFieldDets[1][0].fieldName,CuAp_Constants.STATEPROVINCEAPINAME);
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        05 October 2017
@description: Test method for queryForLocations() method positive scenario where 
              there is no field with null value while searching
*******************************************************************************/
    static testmethod void queryForLocationsNoNull_Positive(){
        
        //Query user record created in test setup data method
        
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Location__c  objLocation = [Select id, City__c, Street__c, State__c, PostalCode__c, Country__c, AuDPID__c from Location__c limit 1];
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRecord1 = CuAp_SelectLocationPageCtrlr.queryForLocations(objLocation);
            Test.stopTest();
            
            //Asserts to check various properties of List<BlAp_CombinedRecord> received
            System.assertEquals(lstCombinedRecord1[0].uniqueId,objLocation.id);
            System.assertEquals(lstCombinedRecord1[0].objectMap.get(CuAp_Constants.LOCATIONAPINAME).Id,objLocation.id);
        }
    }

/******************************************************************************
@author:      Shivangi Gaur
@date:        05 October 2017
@description: Test method for queryForLocations() method negative scenario where 
              null search is done for all values and there is empty List<BlAp_CombinedRecord>.
*******************************************************************************/
    static testmethod void queryForLocations_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Location__c  objLocation = new Location__c();
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRecordNull = CuAp_SelectLocationPageCtrlr.queryForLocations(objLocation);
            Test.stopTest();
            
            System.assertEquals(lstCombinedRecordNull.isEmpty(),true);
        }
    }

}