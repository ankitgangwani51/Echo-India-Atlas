/***************************************************************************************************
@author         Echo : Dependra Singh
@date           05-July-2018
@description    This is test class for GlUt_ServiceItemHandler
Revision(s)   
Comments by Dependra Singh
// Please incorporate the changes as mentioned below whenever you are updating it.
// (1)- When doing test setup , kindly make the list to insert same type of sobject.:For Example -: DeviceType__c ect.
// (2)- If test class is for trigger, Kinldy test bulkified scenario.
*******************************************************************************************************/
@isTest
public class GlUt_ServiceItemHandler_Test {
    //Variable declaration start
    
    private static String USER_PROFILE = 'System Administrator';
    private static final String USER_FNAME= 'TestFName';
    private static final String USER_LNAME= 'TestLName';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    
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
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String BUNDLENAME ='TestBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String SERVICEITEMTYPE = 'TestSrvItemType';  
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';  
    private static String DEVICENAME = 'TestDevice';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String MANUFACTURER1 = 'Kent';
    
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String ALLOWANCETYPENAME 	 	= 'TestAllowanceType';
    private static final String ALLOWANCEPRIORITY 	 	= '1';
    private static final String ALLOWANCETYPE 	 	    = 'Fixed Volume Allowance';
    
    /******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    *******************************************************************/
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
        
        // Create Device Size Record - 
        DeviceSize__c objDeviceSize1 = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize1);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);

        // Create Device Type Record
        DeviceType__c  objDeviceType1 = GlUt_FactoryData_Test.createDeviceType(objDeviceSize1,MANUFACTURER1,UNIT_OF_MEASURE);
        Database.insert(objDeviceType1);
       
        //Create device record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
        
        
        //Create Supply Point record
        SupplyPointDevice__c  objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
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
        //objServiceItemType.DeviceType__c =objDeviceType.id; -- AT-3174
        Database.insert(objServiceItemType);
		
		// Create New Service Item Type
		ServiceItemType__c  objServiceItemType1 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE+'-1',objServiceItemFamily,objDivision,objDeviceType1,objWholesaler);
        //objServiceItemType1.DeviceType__c =objDeviceType.id; -- AT-3174
        Database.insert(objServiceItemType1);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
		
		Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME +'-1',objServiceType);
        Database.insert(objBundle1);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        BundleItem__c  objBundleItem0 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType1,objServiceItemFamily);
        Database.insert(objBundleItem0);
        
		//Create New  bundle item record
        BundleItem__c  objBundleItem1 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM+'-1',objBundle1,objServiceItemType1,objServiceItemFamily);
        Database.insert(objBundleItem1);
		
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        Database.insert(objAvailableServiceItem); 
        
        AllowanceType__c objAllowanceType = GlUt_FactoryData_Test.createAllowanceType(ALLOWANCETYPENAME, objServiceItemFamily, objSupplyPointUsageType, ALLOWANCEPRIORITY, ALLOWANCETYPE, True);
        Database.insert(objAllowanceType);
        
    }
        
    /*******************************************************************
    Purpose: Test bulk Insert for Available Bundle(Scenario when both Service Item Family and service item type exist.)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void createSupplyPointAllowance_Positive(){
        
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        AvailableServiceItem__c  objAvailableServiceItem = [SELECT Id FROM AvailableServiceItem__c LIMIT 1];
        ServiceItemType__c objServiceItemType = [SELECT Id FROM ServiceItemType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        
        System.runAs(objUser){
            Test.startTest();
            Database.insert(objServiceItem);
            Test.stopTest();
            System.assert([SELECT count() FROM SupplyPointAllowance__c] != null);            
        }
    }  
    
    /*******************************************************************
    Purpose: Test bulk Insert for Available Bundle(Scenario when both Service Item Family and service item type exist.)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void createSupplyPointAllowance_Negative(){       
        
        Boolean isException = false;
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        AvailableServiceItem__c  objAvailableServiceItem = [SELECT Id FROM AvailableServiceItem__c LIMIT 1];
        ServiceItemType__c objServiceItemType = [SELECT Id FROM ServiceItemType__c LIMIT 1];
        Service__c objService = new Service__c();
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        
        System.runAs(objUser){
            try{
                Test.startTest();
                Database.insert(objServiceItem);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            System.assert(isException,true);
            
        }     
    }  
    
    /*******************************************************************
    Purpose: Test bulk Insert for Available Bundle(Scenario when both Service Item Family and service item type exist.)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void createDuplicateServiceItem_positive(){
        
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        AvailableServiceItem__c  objAvailableServiceItem = [SELECT Id FROM AvailableServiceItem__c LIMIT 1];
        ServiceItemType__c objServiceItemType = [SELECT Id FROM ServiceItemType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        Database.insert(objServiceItem);
        objServiceItem.SuspendEndDate__c = system.today() + 10;
        Database.update(objServiceItem);
        objServiceItem.SuspendEndDate__c = system.today() + 7;        
        System.runAs(objUser){
            Test.startTest();
            Database.update(objServiceItem);
            Test.stopTest();
                        
        }
    } 
    
}