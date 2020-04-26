/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        03 January 2018
@description: Test Class for CuAp_MoveOutReadingsPageCtrlr
Revisions(s): Shivangi Gaur -- 09-Jan-2018 -- Incorporated review comments on AT-1445 dated 08-Jan-2018.
*******************************************************************************/

@isTest
public class CuAp_MoveOutReadingsPageCtrlr_Test{
    
    //Variable declaration start
    
    private static final String PROFILENAME = 'System Administrator';
    private static final String USERNAME = 'TestUser111';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String LOCATIONNAME = 'Test Location';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String YES ='yes';
    private static final String ACCOUNTNAME = 'TestAccount';
    private static final String MEASURED = 'Monthly';    
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String READ_METHOD ='Actual';
    private static final Decimal AVGUSAGE = 200.0;
    private static final String NEWSERVTYP = 'Water Service';
    private static final String POSTCODENEW = 'A99 6AA';
    private static final String REFERENCEDATATYPE = 'reference';
    private static final String TEXTDATATYPE = 'text';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    //Variable declaration end

/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        03 January 2018
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 

        //Create account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount); 
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create device record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        //Create reading record
        Reading__c  objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ReadingMethod__c = READ_METHOD;
        objReading.ReadingDate__c = system.today();
        Database.insert(objReading);
        
        //Create location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create supply point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c=true ; //AT-3174
        Database.insert(objSupplyPoint);
        
        //Create service type record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        //Create supply point device record
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice ,objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        //Create supply point device service record
        SupplyPointDeviceService__c objSupplyPointDeviceService = GlUt_FactoryData_Test.createSupplyPointDeviceService(objSupplyPointDevice , objServiceType);
        Database.insert(objSupplyPointDeviceService);
        
    }
    
/******************************************************************************
@author:      Shivangi Gaur
@date:        03 January 2018
@description: Test method for retrieveReadingAndDevice() method positive scenario with 
              location id and move out date being passed while calling controller method.
*******************************************************************************/
    static testmethod void retrieveReadingAndDevice_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        //Query location record
        Location__c locObj = [Select id from Location__c limit 1];
        
        String todayDate = String.valueOf(System.today().addDays(5));
        SupplyPointDevice__c spdObj = [Select id from SupplyPointDevice__c limit 1];
        
        //Create average daily usage for the supply point device record
        AverageDailyUsage__c avgDailyUsage = GlUt_FactoryData_Test.createAvgDailyUses(spdObj);
        Database.insert(avgDailyUsage);   
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRec = CuAp_MoveOutReadingsPageCtrlr.retrieveReadingAndDevice(locObj.id,todayDate);
            Test.stopTest();
            system.debug('lstCombinedRec-----------'+ lstCombinedRec);
            //Asserts to check for properties of List<BlAp_CombinedRecord> received
            System.assertNotEquals(lstCombinedRec,null);
            System.assertEquals(lstCombinedRec[0].uniqueId,spdObj.id);
            System.assertEquals(lstCombinedRec[0].objectMap.get(GlUt_Constants.SUPPLYPOINTDEVICE).Id,spdObj.id);
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        03 January 2018
@description: Test method for retrieveReadingAndDevice() method with 
              location id of a new location is being passed while calling controller method.
*******************************************************************************/
    static testmethod void retrieveReadingAndDevice_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        //Query location record
        Location__c locObj = [Select id from Location__c limit 1];
        
        String todayDate = String.valueOf(System.today());
        //Query supply point device record
        SupplyPointDevice__c spdObj = [Select id from SupplyPointDevice__c limit 1];
        
        //Create service type for new supply point device service to be created for suplly point device
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(NEWSERVTYP);
        Database.insert(objServiceType);
        
        //Create new supply point device service record
        SupplyPointDeviceService__c objSupplyPointDeviceService = GlUt_FactoryData_Test.createSupplyPointDeviceService(spdObj,objServiceType);
        Database.insert(objSupplyPointDeviceService);
        
        //Create new location record with no supply point, supply point device, device, readings attached to test for negative scenario
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(POSTCODENEW);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            //Retrieve data for location with more than 1 supply point device service associated to related supply point device
            List<BlAp_CombinedRecord> lstCombinedRec = CuAp_MoveOutReadingsPageCtrlr.retrieveReadingAndDevice(locObj.id,todayDate);
            //Retrieve data for location with no data associated
            List<BlAp_CombinedRecord> lstCombinedRecNegative = CuAp_MoveOutReadingsPageCtrlr.retrieveReadingAndDevice(objLocation.id,todayDate);
            Test.stopTest();
            system.debug('lstCombinedRec-----------'+ lstCombinedRec);
            //Asserts to check for properties of List<BlAp_CombinedRecord> received
            System.assertNotEquals(lstCombinedRec,null);
            System.assertEquals(lstCombinedRec[0].uniqueId,spdObj.id);
            System.assertEquals(lstCombinedRec[0].objectMap.get(GlUt_Constants.SUPPLYPOINTDEVICE).Id,spdObj.id);
            System.assertEquals(lstCombinedRecNegative.isEmpty(),true);
            
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        03 January 2018
@description: Test method for retrieveSupFieldPropDetails() method positive scenario where 
              field properties of list of fields defined in controller class are fetched successfully.
*******************************************************************************/
    static testmethod void retrieveSupFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        //Query location record
        Location__c locObj = [Select id from Location__c limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = CuAp_MoveOutReadingsPageCtrlr.retrieveSupFieldPropDetails();
            Test.stopTest();
            
            //Asserts to check properties of List<GLAp_FieldProps> received
            System.assertNotEquals(lstFieldProps,null);
            System.assertEquals(lstFieldProps[0].isEditable,false);
            System.assertEquals(lstFieldProps[0].fieldType,REFERENCEDATATYPE);
            System.assertEquals(lstFieldProps[1].isEditable,false);
            System.assertEquals(lstFieldProps[1].fieldType,TEXTDATATYPE);
        }       
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        03 January 2018
@description: Test method for queryForLocations() method negative scenario where 
              null search is done for all values and there is empty List<BlAp_CombinedRecord>.
*******************************************************************************/
    static testmethod void retrieveSupFieldPropDetails_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        
        //Make field lists of main class to null to text for exception/ negative scenario
        CuAp_MoveOutReadingsPageCtrlr.spdFields = null;
        CuAp_MoveOutReadingsPageCtrlr.spdsFields = null;
        CuAp_MoveOutReadingsPageCtrlr.devFields = null;
        CuAp_MoveOutReadingsPageCtrlr.supFields = null;
        CuAp_MoveOutReadingsPageCtrlr.readFields = null;
        CuAp_MoveOutReadingsPageCtrlr.currReadFields = null;
    //  CuAp_MoveOutReadingsPageCtrlr.listSPDevice = null;
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            try{
                List<GLAp_FieldProps> lstFieldProps = CuAp_MoveOutReadingsPageCtrlr.retrieveSupFieldPropDetails();
            }
            catch(Exception exc){
                isException = true;
                System.assertNotEquals(exc.getMessage(),null);
            }
            Test.stopTest();
            
            //Assert to check exception has occurred
       //     System.assertEquals(isException,true);
        }
    }
}