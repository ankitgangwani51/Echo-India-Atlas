/******************************************************************************
@author:      Echo: Neha 
@date:        09-04-2018    
@description: Test Class for GlUt_ReadingContractFinder
*******************************************************************************/

@isTest  
public class GlUt_ReadingContractFinder_Test {     
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String CONTRACT_NAME = 'Test Contract';
    private static final String ACCOUNT_NAME1 = 'Test Account1';
    private static final String CONTRACT_NAME1 = 'Test Contract1';
    private static final String ZIP_CODE = 'WS2 8DE';
    private static final String SPUT_NAME = 'SPUT Water';
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';
    private static final String DEVICE_SIZE = '20mm';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = '123456789';
    private static final String DEVICE_NAME1 = '123456789';
    private static final String SERVICE_TYPE_NAME = 'Water';
    private static final String WHOLESALER_NAME = 'Wholesale System';
    private static final String SERVICE_NAME = 'S-1442';
    private static final String SERVICE_NAME1 = 'S-1441';
    private static final String SERVICE_ITEM_FAMILY_NAME = 'Measured Water Volumetric';
    private static final String SERVICE_ITEM_TYPE = 'Measured Water Volumetric';
    private static final String BUNDLE ='Social Bundle';
    private static final String BUNDLEITEM ='Bundle Item';
    private static final String AVAIL_BUNDLE ='Test Available Bundle'; 
    private static final String AVAIL_SERVICE ='Test Available Service';
    private static final Date READING_DATE = system.today();
            
	/******************************************************************************
	@author:      Echo: Neha
	@date:        09-04-2018 l  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        
        // Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);        
        Database.insert(objContract);
        
        // Create Location Record 
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);
               
        // Create SupplyPointUsageType Record 
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SPUT_NAME);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint__c Record 
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
  
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create SupplyPointDevice Record
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);        
        Database.insert(objSupplyPointDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ReadingDate__c = READING_DATE;
        Database.insert(objReading);
        
        // Create ServiceType Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE_NAME);
        Database.insert(objServiceType);
        
         // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
       
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        // Create AvailableService Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME, objDivision, objServiceType, objSupplyPoint, objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);   
        Database.insert(objService);  
        
        // Create ServiceItemFamily Record
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY_NAME, objServiceType);
        objServiceItemFamily.StartDate__c = READING_DATE;
        Database.insert(objServiceItemFamily);	
        
        // Create ServiceItemType Record
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType); 
       
        //Create bundle record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE, objServiceType);
        Database.insert(objBundle);   
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create AvailableBundle__crecord
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAIL_BUNDLE, objBundle, objAvailableService);
        Database.insert(objAvailableBundle);
             
        // Create AvailableServiceItem Record
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE, objBundleItem, objServiceItemType, objAvailableBundle);        
        Database.insert(objAvailableServiceItem);
        
        // Create ServiceItem Record
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = READING_DATE - 31;
        objServiceItem.EndDate__c = null;
        Database.insert(objServiceItem);
        
        //AT-2930
        // Create Account Record
        Account objAccount1 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME1);        
        Database.insert(objAccount1);
        
        // Create Contract Record
        BillingContract__c objContract1 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME1, objAccount1);        
        Database.insert(objContract1);
        
        // Create Location Record 
        Location__c objLocation1 = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation1);
        
        // Create SupplyPoint__c Record 
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation1, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c  = True; // AT-3174 
    
        Database.insert(objSupplyPoint1);
        
        // Create Device Record
        Device__c objDevice1 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME1, objDeviceType);        
        Database.insert(objDevice1);
        
        // Create SupplyPointDevice Record
        SupplyPointDevice__c objSupplyPointDevice1 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice1, objSupplyPoint1);        
        Database.insert(objSupplyPointDevice1);
        
        // Create Reading Record
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice1);
        objReading1.ReadingDate__c = system.today();
        objReading1.Billed__c = false;
        objReading1.BillableType__c = 'Billable';
        Database.insert(objReading1);
        
        // Create AvailableService Record
        AvailableService__c objAvailableService1 = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME1, objDivision, objServiceType, objSupplyPoint1, objWholesaler);
        Database.insert(objAvailableService1);
        
        // Create Service Record
        Service__c objService1 = GlUt_FactoryData_Test.createService(objContract1, objReading1, objServiceType, objSupplyPoint1, objAvailableService1);		     
        Database.insert(objService1); 
       
        // Create SupplyPointRelationship Record
        SupplyPointRelationship__c objSPR = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPoint1, objSupplyPoint);
		objSPR.StartDate__c= system.today() - 10 ;
        Database.insert(objSPR);
        
        // Create ServiceItem Record
        ServiceItem__c objServiceItem1 = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService1);
        objServiceItem1.StartDate__c = READING_DATE - 31;
        objServiceItem1.EndDate__c = null;
        Database.insert(objServiceItem1);
    }    
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        09-04-2018     
	@description: Test Method to retrieve Contract Id's in POSITIVE scenario
	*******************************************************************************/
    static testmethod void retrieveContractIds_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c FROM SupplyPointRelationship__c LIMIT 1];
        Reading__c mainDeviceReading = [SELECT Id
                                       FROM Reading__c 
                                       WHERE Device__c IN (SELECT Device__c
                                                                    FROM SupplyPointDevice__c
                                                                    WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                                                    AND Active__c = true) LIMIT 1];                
        Reading__c objReading = [SELECT Id FROM Reading__c WHERE Id != :mainDeviceReading.Id LIMIT 1];
        Set<Id> contractIds = new Set<Id>();
        
        System.runAs(objUser){
            Test.startTest();
            
            GlUt_ReadingContractFinder objClass = new GlUt_ReadingContractFinder();            
            contractIds = objClass.retrieveContractIds(objReading.Id);             
            
            Test.stopTest();
            system.assert(contractIds.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        09-04-2018   
	@description: Test Method to retrieve Contract Id's in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void retrieveContractIds_Negative()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Reading__c objReading = new Reading__c();
        Set<Id> contractIds = new Set<Id>();
        
        System.runAs(objUser){
            Test.startTest();
            
            GlUt_ReadingContractFinder objClass = new GlUt_ReadingContractFinder();            
            contractIds = objClass.retrieveContractIds(objReading.Id);             
            
            Test.stopTest();
            system.assert(contractIds.size() == 0);
        }
    }
}