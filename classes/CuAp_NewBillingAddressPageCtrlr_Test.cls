/******************************************************************************
@author:      Echo: Dependra Singh
@date:        24 November 2017
@description: Test Class for CuAp_NewBillingAddressPageCtrlr
Revision(s):  
*******************************************************************************/
@isTest
Public Class CuAp_NewBillingAddressPageCtrlr_Test{
    
    //Variable declaration start
    private static String USER_PROFILE = 'System Administrator';
    private static final String USER_FNAME= 'TestFName';
    private static final String USER_LNAME= 'TestLName';
    private static final String ACTIVE = 'Active';
    private static String USER_NAME = 'TestUser';
    private static String USERNAMECOMPLETE = USER_NAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount';
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String LOCATION_STREET = 'Test Street';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String BUNDLENAME ='TestBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String DEVICETYPE ='TestDeviceType';
    private static String SERVICEITEMTYPE = 'TestSrvItemType';  
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';  
    private static String DEVICENAME = 'TestDevice';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String TEST_SERVICE_TYPE_NEW ='TestServiceTypeNew';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        
        Database.insert(objContract);
        //update objContract;
        //Create Location record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =LOCATION_STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create device record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
        
        //Create reading record
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        
        //Create service record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        Database.insert(objServiceType);
        
        //Create service item family record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create service record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //Create service record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Create service record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        
        //Create service item type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create new service Type 
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE_NEW);
        Database.insert(objServiceType1);
        
        // Create new Bundle
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType1);
        Database.insert(objBundle1);
        
        //Create Default Available Bundle
        AvailableBundle__c objDefAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle1,objAvailableService);
        objDefAvailableBundle.Default__c = True;
        Database.insert(objDefAvailableBundle);
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem);
        
    }
    
    /******************************************************************************
@author:      Dependra Singh
@date:        24 November 2017
@description: Test method for retrieveContractBillingDetails() method, Positive Test
              In positive scenario we are passing location id and account id to the method.
*******************************************************************************/
    static testmethod void retrieveContractBillingDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        List<Account> accountList = [Select Id FROM Account LIMIT 1];                                      
        BillingContract__c objContract;                             
        
        List<Location__c> locationList =[SELECT Id,
                                        LocationSubType__c, 
                                        Street__c,
                                        LocationType__c,
                                        PostalCode__c FROM Location__c 
                                        LIMIT 1 ] ;                                                                                             
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            if(accountList != null && accountList.size() >0)
                objContract = CuAp_NewBillingAddressPageCtrlr.retrieveContractBillingDetails(locationList[0].id,accountList[0].id);
            Test.stopTest();
            System.assert(objContract != null);
        }
    }
    /******************************************************************************
    @author:      Dependra Singh
    @date:        24 November 2017
    @description: Test method for retrieveContractBillingDetails() method, Negative Test
                  In negative scenario, instead of passing account id we are passsing location id and same for location. 
    *******************************************************************************/    
    static testmethod void retrieveContractBillingDetails_Negative(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        BillingContract__c objContract;
        List<Location__c> locationList =[ SELECT Id,
                                        LocationSubType__c, 
                                        Street__c,
                                        LocationType__c,
                                        PostalCode__c FROM Location__c 
                                        LIMIT 1] ;
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            objContract = CuAp_NewBillingAddressPageCtrlr.retrieveContractBillingDetails(objUser.id,locationList[0].id);
            Test.stopTest();
            System.assert(objContract == null);
        }
    }
}