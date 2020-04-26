/******************************************************************************
@author         Echo: Tarun Gupta
@date           20 Dec 2018
@description    Test Class for GlUt_RuralLicenseHandler
*******************************************************************************/
@isTest 
public class GlUt_RuralLicenseHandler_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String STAGING_TABLE = 'ReadingUpload__c';
    private static String TEST_SERVICE_TYPE ='TestServiceType';   
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String BUNDLENAME ='TestBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String SERVICEITEMTYPE = 'TestSrvItemType';  
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';  
    private static String ACCOUNTNAME = 'TestAccount'; 
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static String DEVICENAME = 'TestDevice';  
    private static INTEGER BASEENTITLEMENT = 100;
    private static INTEGER PERMANENTTRANSFERIN = 50;
    private static INTEGER PERMANENTTRANSFEROUT = 20;
    private static DECIMAL REMAININGVOLUMETO = 200;
    private static DECIMAL REMAININGVOLUMEFROM = 500;
    private static DECIMAL TRANSFERAMOUNT = 50;
    private static STRING TRANSFERTYPE = 'Permanent';   
    private static STRING TRANSFERTYPETEMPORARY = 'Temporary';
    private static DECIMAL INVALIDTRANSFERAMOUNT = 150;
    private static final Id RuralOutletRecTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_APIConstantsSupplyPoint.RECORDTYPEOUTLETTYPE).getRecordTypeId(); 
    

    /******************************************************************************
    @author         Echo: Tarun Gupta
	@date           20 Dec 2018
    @description    Test data setup
    *******************************************************************************/
    @TestSetup
    static void createTestData() {
        
        User testUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        testUser.FirstName = USER_FIRST_NAME;
        testUser.LastName = USER_LAST_NAME;
        insert testUser;

        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        Database.insert(objContract);

        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.RecordTypeId = RuralOutletRecTypeId;
        Database.insert(objSupplyPoint);

        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
        
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
                
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        Database.insert(objServiceType);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
                
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
                
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        objServiceItemType.StartDate__c = Date.Today();
        objServiceItemType.AvailableToSelectInWizard__c = True;
        Database.insert(objServiceItemType); 
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
        
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        Database.insert(objServiceItem);
		
        RuralLicense__c objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
        objRuralLicense.BaseEntitlement__c = BASEENTITLEMENT;
        objRuralLicense.InfrastructureCharge__c = objServiceItemType.Id;
        Database.insert(objRuralLicense);
        
        RuralLicense__c objRuralLicense2 = GlUt_FactoryData_Test.createRuralLicense();
        objRuralLicense2.Status__c = Label.BlAp_RuralLicenseStatusActive;
        objRuralLicense2.BaseEntitlement__c = BASEENTITLEMENT;
        objRuralLicense2.InfrastructureCharge__c = objServiceItemType.Id;
        Database.insert(objRuralLicense2);
        
        List<RuralEntitlement__c> ruralEntitlementList = new List<RuralEntitlement__c>();
        RuralEntitlement__c objRuralEntitlementTo = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        objRuralEntitlementTo.StartDate__c = system.today() - 20;
        objRuralEntitlementTo.Active__c = true;
        objRuralEntitlementTo.PermanentTransfersIn__c = PERMANENTTRANSFERIN;
        objRuralEntitlementTo.PermanentTransfersOut__c = PERMANENTTRANSFEROUT;
        objRuralEntitlementTo.SeasonalAllocation__c = BASEENTITLEMENT ;
        objRuralEntitlementTo.RuralLicense__c = objRuralLicense.Id;
        ruralEntitlementList.add(objRuralEntitlementTo);
        
        RuralEntitlement__c objRuralEntitlementFrom = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        objRuralEntitlementFrom.StartDate__c = system.today() - 10;
        objRuralEntitlementFrom.Active__c = true;
        objRuralEntitlementFrom.PermanentTransfersIn__c =   PERMANENTTRANSFERIN;
        objRuralEntitlementFrom.PermanentTransfersOut__c = PERMANENTTRANSFEROUT;
        objRuralEntitlementFrom.SeasonalAllocation__c = 100;
        objRuralEntitlementFrom.RuralLicense__c = objRuralLicense.Id;
        ruralEntitlementList.add(objRuralEntitlementFrom);
        Database.insert(ruralEntitlementList);
        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
	@date           20 Dec 2018
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void checkLicenseStatusBeforeUpdate_Negative_Exception(){  
        Boolean isException = false;
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        RuralLicense__c objLicense = [SELECT Id,Name,StartDate__c,Status__c FROM RuralLicense__c  LIMIT 1]; 
        
        Location__c objLocation = [SELECT Id,Name,RuralLicense__c FROM Location__c LIMIT 1]; 
        objLocation.RuralLicense__c = objLicense.Id;
        update objLocation;
        objLicense.Status__c = Label.BlAp_RuralLicenseStatusActive;
        
        System.runAs(testUser) {
            Test.startTest(); 
            try{ 
                update objLicense;
            }
            catch (exception e) {
                isException = true;
            }
            System.assertEquals(isException, true);
            Test.stopTest(); 
        }  
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
	@date           20 Dec 2018
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void checkLicenseStatusActivate_Positive(){  
        Boolean isException = false;
        
        User testUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNTNAME LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c FROM BillingContract__c WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        RuralLicense__c objLicense = [SELECT Id,Name,StartDate__c,Status__c FROM RuralLicense__c  LIMIT 1]; 
        
        Location__c objLocation = [SELECT Id,Name,RuralLicense__c FROM Location__c LIMIT 1]; 
        objLocation.RuralLicense__c = objLicense.Id;
        update objLocation;
        objLicense.Status__c = Label.BlAp_RuralLicenseStatusActive;
        objLicense.BillingContract__c = objContract.Id;
        objLicense.BaseEntitlement__c = 100;
        
        System.runAs(testUser) {
            Test.startTest(); 
            update objLicense;
            Test.stopTest(); 
        }  
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
	@date           20 Dec 2018
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void checkLicenseStatusCancel_Positive(){  
        Boolean isException = false;
        
        User testUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNTNAME LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c FROM BillingContract__c WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        RuralLicense__c objLicense = [SELECT Id,Name,StartDate__c,Status__c FROM RuralLicense__c WHERE Status__c =: Label.BlAp_RuralLicenseStatusActive LIMIT 1]; 
        objLicense.Status__c = Label.BlAp_RuralLicenseStatusCancel;
        objLicense.BillingContract__c = objContract.Id;
        objLicense.BaseEntitlement__c = 100;
        objLicense.CancelledDate__c = system.today();
        
        Location__c objLocation = [SELECT Id,Name,RuralLicense__c FROM Location__c LIMIT 1]; 
        objLocation.RuralLicense__c = objLicense.Id;
        update objLocation;
        
        System.runAs(testUser) {
            Test.startTest(); 
            update objLicense;
            Test.stopTest(); 
        }  
    }
}