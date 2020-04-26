/******************************************************************************
@author:      ECHO: Mohit Tayal
@date:        07 DEC 2017
@description: Test Class for LoAp_SearchDevicePageCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
public class LoAp_SearchDevicePageCtrlr_Test {
    
   //Variable declaration start    
    private static String USER_PROFILE = 'System Administrator';
    private static String USERNAME = 'TestUser';
    private static String USERNAMECOMPLETE  = USERNAME+ '@unitest.com';
    private static String TESTSERVICE_TYPE1 = 'TestServiceType1';
    private static String TESTSERVICE_TYPE2 = 'TestServiceType2';
    private static String TESTSERVICE_TYPE3 = 'TestServiceType3';
    private static String TESTSERVICE_TYPE4 = 'TestServiceType4';
    private static String LOCATION_NAME = 'A99 9AA';  
    private static String ACCOUNT_NAME = 'TestDevice';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String DEVICE_TYPE_NAME = 'Meter';
    private static String OLDDEVICE_SERIALNO = '1234';
    private static String NEWDEVICE_SERIALNO = '6789';
    private static String NEWDEVICE_SERIALNO2 = '546';
    private static String YES = 'yes';
    //private static String TRUE ='true';
    private static String MEASURED = 'Monthly';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String WHOLESALER_NAME = 'Test Wholesaler';
    private static final String AVAILABLE_SERVICE_NAME = 'Test Available Service';
    
    
    //Variable declaration end

/******************************************************************************
@author:      ECHO: Mohit Tayal
@date:        07 DEC 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USERNAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(USERNAME,objAccount);
        Database.insert(objContract);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1 );
        Database.insert(objServiceType1);
        
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE2 );
        Database.insert(objServiceType2);
        
        ServiceType__c objServiceType3 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE3 );
        Database.insert(objServiceType3);
        
        ServiceType__c objServiceType4 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE4 );
        Database.insert(objServiceType4);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c= True; // AT-3174 
  
        Database.insert(objSupplyPoint1);
        
        /*SupplyPoint__c  objSupplyPoint2 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.Measured__c=YES ;
        objSupplyPoint2.ReadFrequency__c = MEASURED;
        Database.insert(objSupplyPoint2);*/
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);      
      
        //Old device details
        Device__c  objOldDevice = GlUt_FactoryData_Test.CreateDevice(OLDDEVICE_SERIALNO , objDeviceType); 
        objOldDevice.SerialNo__c = OLDDEVICE_SERIALNO;
        Database.insert(objOldDevice);
        
        SupplyPointDevice__c  objOldSupplyPointDevice = GlUt_FactoryData_Test.CreateSupplyPointDevices(objOldDevice , objSupplyPoint1);        
        Database.insert(objOldSupplyPointDevice); 
        
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService1 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType1);        
        Database.insert(objOldSupplyPointDeviceService1);
        
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService2 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType2);        
        Database.insert(objOldSupplyPointDeviceService2);  
        
        Reading__c objReading = new Reading__c();
        
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        //AvailableService__c objAvailableService = new AvailableService__c();
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLE_SERVICE_NAME, objDivision, objServiceType1, objSupplyPoint1, objWholesaler);
        objAvailableService.Active__c = TRUE;
        Database.insert(objAvailableService);
        
        Service__c  objOldService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService1);
        
        Service__c  objOldService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService2);
        //End of Old device details
        
        //New device details
        Device__c  objNewDevice1 = GlUt_FactoryData_Test.CreateDevice(NEWDEVICE_SERIALNO , objDeviceType);      
        objNewDevice1.SerialNo__c = NewDEVICE_SERIALNO;
        Database.insert(objNewDevice1);
                
        SupplyPointDevice__c  objNewSupplyPointDevice1 = GlUt_FactoryData_Test.CreateSupplyPointDevices(objNewDevice1 , objSupplyPoint1); 
        objNewSupplyPointDevice1.RemovalDate__c = objNewSupplyPointDevice1.InstallationDate__c + 5;
        Database.insert(objNewSupplyPointDevice1);
        
        Service__c  objNewService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        Database.insert(objNewService1);
        
        Service__c  objNewService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint1, objAvailableService);
        Database.insert(objNewService2);
        
        Reading__c objNewReading = GlUt_FactoryData_Test.CreateReading(objNewDevice1);
        Database.insert(objNewReading); 
        //End of First New device details
        
        //New Device Details 2
        Device__c  objNewDevice2 = GlUt_FactoryData_Test.CreateDevice(NEWDEVICE_SERIALNO2 , objDeviceType);      
        objNewDevice2.SerialNo__c = NEWDEVICE_SERIALNO2;
        Database.insert(objNewDevice2);
               
        /*SupplyPointDevice__c  objNewSupplyPointDevice2 = GlUt_FactoryData_Test.CreateSupplyPointDevices(objNewDevice2 , objSupplyPoint2); 
        objNewSupplyPointDevice2.RemovalDate__c = objNewSupplyPointDevice2.InstallationDate__c + 5;
        Database.insert(objNewSupplyPointDevice2);*/
        
        /*Service__c  objNewService3 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType3, objSupplyPoint2, objAvailableService);
        Database.insert(objNewService3);
        
        Service__c  objNewService4 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType4, objSupplyPoint2, objAvailableService);
        Database.insert(objNewService4);*/
        //End of Second New device details
       
    }
    
/******************************************************************************
@author:      ECHO: Mohit Tayal
@date:        07 DEC 2017
@description: Test method for queryForLocations() method
*******************************************************************************/
    static testmethod void queryForDevice_Positive(){
        
        List<List<GlAp_FieldProps>> listOutputFields = new List<List<GlAp_FieldProps>>();
        List<List<GlAp_FieldProps>> listInputFields = new List<List<GlAp_FieldProps>>();
        //Query user record created in test setup data method
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        List<Location__c> objLocation = [SELECT Id,Name FROM Location__c WHERE PostalCode__c =: LOCATION_NAME LIMIT 1];
        
        List<Device__c> objDevice = [SELECT Id FROM Device__c WHERE DeviceType__r.Manufacturer__c =: MANUFACTURER AND Device__c.SerialNo__c =: OLDDEVICE_SERIALNO LIMIT 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            
            //LoAp_SearchDevicePageCtrlr.DeviceDetails returnOptionsList1 = LoAp_SearchDevicePageCtrlr.queryForDevice(MANUFACTURER, NewDEVICE_SERIALNO, objDevice.get(0).Id, objLocation.get(0).Id);
            //LoAp_SearchDevicePageCtrlr.DeviceDetails returnOptionsList2 = LoAp_SearchDevicePageCtrlr.queryForDevice(MANUFACTURER, OLDDEVICE_SERIALNO, objDevice.get(0).Id, objLocation.get(0).Id);
            //LoAp_SearchDevicePageCtrlr.DeviceDetails returnOptionsList3 = LoAp_SearchDevicePageCtrlr.queryForDevice(MANUFACTURER, NEWDEVICE_SERIALNO2, objDevice.get(0).Id, objLocation.get(0).Id);
            //LoAp_SearchDevicePageCtrlr.DeviceDetails returnOptionsList4 = LoAp_SearchDevicePageCtrlr.queryForDevice('', '', '', objLocation.get(0).Id);
            listOutputFields = LoAp_SearchDevicePageCtrlr.retrieveDeviceFields('output');
            listInputFields = LoAp_SearchDevicePageCtrlr.retrieveDeviceFields('input');
            LoAp_SearchDevicePageCtrlr.retrieveDeviceFields(Null);
            LoAp_SearchDevicePageCtrlr.retrieveInitialFields('output');
            LoAp_SearchDevicePageCtrlr.retrieveInitialFields('input');
            LoAp_SearchDevicePageCtrlr.retrieveInitialFields(Null);
            
            Test.stopTest();
            System.assert(listOutputFields.size() > 0 );
            System.assert(listInputFields.size() > 0 );
            //System.assert(returnOptionsList1 != null);
            //System.assert(returnOptionsList2 != null);
            //System.assert(returnOptionsList3 != null);
            //System.assert(returnOptionsList4 != null);
            
            //System.assert(lstCombinedRecord5 != null);
        }
    }

}