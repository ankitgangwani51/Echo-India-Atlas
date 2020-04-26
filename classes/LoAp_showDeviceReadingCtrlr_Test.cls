/******************************************************************************
@author:      ECHO: Amit K.
@date:        15 DEC 2017
@description: Test Class for LoAp_ShowDeviceReadingCtrlr
*******************************************************************************/

@isTest
public class LoAp_showDeviceReadingCtrlr_Test {
   
    //Variable declaration start    
    private static final String USER_ALIAS = 'standt';
    private static final String USER_EMAIL = '@unitest.com';
    private static final String USER_UTF = 'UTF-8';
    private static final String USER_LNAME= 'UnitTest';
    private static final String USER_LAN_LOCALKEY= 'en_US';
    private static final String USER_TIMEZONEKEY= 'America/Los_Angeles';
    private static final String USER_PHONE = '1234567891';
    private static final String USER_MPHONE = '0111111111';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='TestUser'; 
    private static String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static String ACCOUNT_NAME = 'TestAccount'; 
    private static String CONTRACT_NAME_ONE ='TestContract';
    private static String CONTRACT_NAME_SECOND ='TestContract2';
    private static String DEVICE_NAME = 'TestDevice';
    private static String DEVICE_TYPE ='TestDeviceType';
    private static String SUB_DEVICE_TYPE ='TestSubDevice';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static String SERVICEITEMTYPE ='TestServiceitemtype';
    private static String BUNDLE ='TestBundle';
    private static String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static Integer LIMIT1 =1;
    private static String DEVICE_TYPE_NAME ='Meter';
    private static String NEWDEVICE_SERIALNO ='6789';
    private static String READINGTYPE ='Billable';
    private static String BILLNAME = 'TestBill';
    private static String BILLSERVICETYPENAME = 'TestBillServiceType';
    private static String BILLITEMNAME = 'TestBillItem';
    private static String HEROKUID = 'id123';
    private static Integer VOLUMEUSED = 1000;
    private static Integer BILLAMOUNT = 200;
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser); 
        system.Runas(objUser){
            Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
            Database.insert(objAccount);
            BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_ONE,objAccount);
            BillingContract__c objContract2 = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_SECOND ,objAccount);
            list<BillingContract__c >lstContract = new list<BillingContract__c>(); 
            lstContract.add(objContract);
            lstContract.add(objContract2);
            Database.insert(lstContract);
            
            // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
            DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
            Database.insert(objDeviceSize);
            
            // Create Device Type Record
            DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
            Database.insert(objDeviceType);            Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
            Database.insert(objDevice);
            ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
            Database.insert(objServiceType);
            Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
            Database.insert(objReading);
            Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
            objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
            objLocation.Street__c =STREET ;
            Database.insert(objLocation);
            
            //Create Supply Point Usage Type Record
            SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
            Database.insert(objSupplyPointUsageType);
            
            SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
            objSupplyPoint.Measured__c= True; // AT-3174 
    
            Database.insert(objSupplyPoint);
            Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
            Database.insert(objDivision);
            Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
            Database.insert(objWholesaler);
            AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
            Database.insert(objAvailableService);
            Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
            Database.insert(objService);
            ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
            Database.insert(objServiceItemFamily);
            ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
            Database.insert(objServiceItemType);
            Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
            Database.insert(objBundle);
            AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
            Database.insert(objAvailableBundle);
            BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
            Database.insert(objBundleItem);
            AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
            Database.insert(objAvailableServiceItem); 
            ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
            objServiceItem.StartDate__c = Date.today();
            Database.insert(objServiceItem);
            Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME,objContract);
            Database.insert(objBill);    
            BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICETYPENAME,objBill,HEROKUID);
            objBillServiceType.ServiceType__c = objServiceType.Id;    
            Database.insert(objBillServiceType);
            BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME,objServiceItem,VOLUMEUSED,BILLAMOUNT,objBillServiceType,HEROKUID);
            objBillItem.Reading__c = objReading.Id;
            Database.insert(objBillItem);
        }
        
    }
/*******************************************************************
Purpose: Method to test LoAp_showDeviceReadingCtrlr {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveDeviceReadings_Positive(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        Device__c objDevice =[select id,name from Device__c limit 1];
        System.runAs(objUser){
            List<BlAp_CombinedRecord> returnOptionsList1 = new List<BlAp_CombinedRecord>();
            List<BlAp_CombinedRecord> returnOptionsList2 = new List<BlAp_CombinedRecord>();
            //Run test class in user context
            Test.startTest();
            returnOptionsList1 = LoAp_ShowDeviceReadingCtrlr.retrieveDeviceReadings(objDevice.Id,READINGTYPE);
            returnOptionsList2 = LoAp_ShowDeviceReadingCtrlr.retrieveDeviceReadings(objDevice.Id,'');
            System.assert(returnOptionsList1 != null);
            System.assert(returnOptionsList2 != null);
            Test.stopTest();
            
        }
    }

 /*******************************************************************
Purpose: Method to test LoAp_showDeviceReadingCtrlr {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveDeviceReadings_Negative(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        Device__c objDevice =[select id,name from Device__c limit 1];
        System.runAs(objUser){
            List<BlAp_CombinedRecord> returnOptionsList1 = new List<BlAp_CombinedRecord>();
            //Run test class in user context
            Test.startTest();
            returnOptionsList1 = LoAp_ShowDeviceReadingCtrlr.retrieveDeviceReadings(null,null);
            System.assert(returnOptionsList1 != null);
            Test.stopTest();
            
        }
    }
    /*******************************************************************
Purpose: Method to test LoAp_showDeviceReadingCtrlr {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveReadingFieldPropDetails_Positive(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        Device__c objDevice =[select id,name from Device__c limit 1];
        System.runAs(objUser){
            List<GLAp_FieldProps> returnOptionsList = new List<GLAp_FieldProps>();
            //Run test class in user context
            Test.startTest();
            returnOptionsList = LoAp_ShowDeviceReadingCtrlr.retrieveReadingFieldPropDetails(READINGTYPE);
            System.assert(returnOptionsList != null);
            Test.stopTest();
            
        }
    }
   
     /*******************************************************************
Purpose: Method to test LoAp_showDeviceReadingCtrlr {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveReadingFieldPropDetails_Negative(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        Device__c objDevice =[select id,name from Device__c limit 1];
        System.runAs(objUser){
            List<GLAp_FieldProps> returnOptionsList = new List<GLAp_FieldProps>();
            //Run test class in user context
            Test.startTest();
            returnOptionsList = LoAp_ShowDeviceReadingCtrlr.retrieveReadingFieldPropDetails(null);
            System.assert(returnOptionsList != null);
            Test.stopTest();
            
        }
    }
}