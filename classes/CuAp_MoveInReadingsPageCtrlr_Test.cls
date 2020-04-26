/******************************************************************************
@author:      Accenture: Manish Singh
@date:        03 January 2018
@description: Test Class for CuAp_MoveInReadingsPageCtrlr
Revisions(s): Shivangi Gaur -- 09-Jan-2018 -- Incorporated review comments on AT-1020 
                                              dated 08-Jan-2018.
			  04/12/18 - TG , AT-3872 , removed current read functionality
*******************************************************************************/
@isTest
private class CuAp_MoveInReadingsPageCtrlr_Test {
    
    //Variable declaration start
    
    private static final String PROFILENAME ='System Administrator';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'test street';
    private static final String YES ='yes';
    private static final String ACCOUNTNAME = 'TestAccount';
    private static final String USERNAME = 'TestUser111';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String MEASURED = 'Monthly';    
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String READ_METHOD ='Actual'; 
    private static final String WHOLESALER ='TestWholesaler';
    private static final String BUNDLENAME ='TestBundle';
    private static final String REFERENCEDATATYPE = 'reference';
    private static final String TEXTDATATYPE = 'text';
    private static final Decimal AVGUSAGE = 200.0;
    private static final String NEWSERVTYP = 'Water Service';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    //Variable declaration end
    
    /******************************************************************************
    @author:      Accenture: Manish Singh
    @date:        03 Jan 2018
    @description: Test method for createTestData() method
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
        objReading.ReadingDate__c = System.today().addDays(-4);
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
        objSupplyPoint.Measured__c= True; // AT-3174 
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
        
        //Create division record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        //Create wholesaler record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create available service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Create bundle record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
        
        //Create available bundle record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
    }

/******************************************************************************
@author:      Manish Singh
@date:        03 January 2018
@description: Test method for retrieveSupFieldPropDetails() method positive scenario where 
              field properties of list of fields defined in controller class are fetched successfully.
*******************************************************************************/
   static testmethod void retrieveSupFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        System.runAs(objUser){
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = CuAp_MoveInReadingsPageCtrlr.retrieveSupFieldPropDetails();
            Test.stopTest();

            //Assert to check properties of List<GLAp_FieldProps> received
            System.assertNotEquals(lstFieldProps,null);
            System.assertEquals(lstFieldProps[0].isEditable,false);
            System.assertEquals(lstFieldProps[0].fieldType,REFERENCEDATATYPE);
            System.assertEquals(lstFieldProps[1].isEditable,false);
            System.assertEquals(lstFieldProps[1].fieldType,TEXTDATATYPE);
        }
   
   }
/******************************************************************************
@author:      Manish Singh
@date:        04 January 2018
@description: Test method for retrieveSupFieldPropDetails() method negative scenario where 
              the list of fields whose field properties are to be retrieved is null.
*******************************************************************************/
   static testmethod void retrieveSupFieldPropDetails_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        CuAp_MoveInReadingsPageCtrlr.spdFields = null;
        CuAp_MoveInReadingsPageCtrlr.spdsFields = null;
        CuAp_MoveInReadingsPageCtrlr.devFields = null;
        CuAp_MoveInReadingsPageCtrlr.supFields = null;
        CuAp_MoveInReadingsPageCtrlr.readFields = null;
        CuAp_MoveInReadingsPageCtrlr.currReadFields = null;
        CuAp_MoveInReadingsPageCtrlr.bundleFields = null;
        CuAp_MoveInReadingsPageCtrlr.availableServiceFields = null;
        CuAp_MoveInReadingsPageCtrlr.estimateReadingFields = null;
        CuAp_MoveInReadingsPageCtrlr.listSPDevice = null;
        System.runAs(objUser){
            
            List<GLAp_FieldProps> lstFieldProps;
            Test.startTest();
            
            try{
                lstFieldProps = CuAp_MoveInReadingsPageCtrlr.retrieveSupFieldPropDetails();
            }
            catch(Exception exc){
                isException = true;
            }
            Test.stopTest();
            
            //Assert to check exception has occurred
            System.assertEquals(lstFieldProps,null);
        }
   
   }
/******************************************************************************
@author:      Manish Singh
@date:        03 January 2018
@description: Test method for retrieveReadingAndDevice() method positive scenario with 
              list of bundle id and move in date being passed while calling controller method.
*******************************************************************************/
   static testmethod void retrieveReadingAndDevice_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        SupplyPointDevice__c spdObj = [Select id from SupplyPointDevice__c limit 1];
        //Create list of bundle ids
        List<String> listBundleId = new List<String>();
        for(AvailableBundle__c bundle : [select Id from AvailableBundle__c]  ){
            listBundleId.add(bundle.Id);
        }
        String todayDate = String.valueOf(System.today().addDays(5));
        //Create average daily usage record for supply point device
        AverageDailyUsage__c avgDailyUsage = GlUt_FactoryData_Test.createAvgDailyUses(spdObj);
        Database.insert(avgDailyUsage); 
       
        //Create service type record to create new supply point device service record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(NEWSERVTYP);
        Database.insert(objServiceType);
        //Create new supply point device service record
        SupplyPointDeviceService__c objSupplyPointDeviceService = GlUt_FactoryData_Test.createSupplyPointDeviceService(spdObj,objServiceType);
        Database.insert(objSupplyPointDeviceService);
        
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> lstRecords = CuAp_MoveInReadingsPageCtrlr.retrieveReadingAndDevice(listBundleId, todayDate );
            //Assert to check properties of List<BlAp_CombinedRecord> received
            System.assertNotEquals(lstRecords,null);
            System.assertEquals(lstRecords[0].uniqueId,spdObj.id);
            System.assertEquals(lstRecords[0].objectMap.get(GlUt_Constants.SUPPLYPOINTDEVICE).Id,spdObj.id);
            Test.stopTest();
        }
   
   }
/******************************************************************************
@author:      Manish Singh
@date:        04 January 2018
@description: Test method for retrieveReadingAndDevice() method negative scenario where 
              no list of bundle id is passed while calling the controller method.
*******************************************************************************/
   static testmethod void retrieveReadingAndDevice_Negative(){
       
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String todayDate = String.valueOf(System.today().addDays(5));
        boolean isException = false;
        
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            try{
                List<BlAp_CombinedRecord> lstRecords = CuAp_MoveInReadingsPageCtrlr.retrieveReadingAndDevice(null, todayDate );
            }
            catch(Exception exc){
                isException = true;
            }
            Test.stopTest();

            //Assert to check exception has occurred
            System.assertEquals(isException,true);
        }
   
   }   

}