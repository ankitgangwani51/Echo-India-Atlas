/******************************************************************************
@author         Echo: Vivek Sethi
@date           18 Dec 2018
@description    Test Class for GlUt_RuralTransferHandler
Revision(s)     
*******************************************************************************/
@isTest 
public class GlUt_RuralTransferHandler_Test {
   
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
    

    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           18 Dec 2018
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

        RuralLicense__c objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
        objRuralLicense.BaseEntitlement__c = BASEENTITLEMENT;
        objRuralLicense.InfrastructureCharge__c = objServiceItemType.Id;
        Database.insert(objRuralLicense);
        
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
        
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.RuralEntitlement__c = ruralEntitlementList[0].Id;
        Database.insert(objServiceItem);
        
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           18 Dec 2018
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void createNewServiceItem_transfertype_permanent(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        RuralEntitlement__c  objRuralEntitlementFrom =  [select Id , RemainingVolume__c from RuralEntitlement__c where Active__c =:true and StartDate__c =: system.today() - 20];
        RuralEntitlement__c  objRuralEntitlementTo =  [select Id, RemainingVolume__c from RuralEntitlement__c where Active__c =:true and StartDate__c =: system.today() - 10];
        RuralTransfer__c objRuralTransfer = GlUt_FactoryData_Test.createRuralTransfer(objRuralEntitlementTo , objRuralEntitlementFrom, TRANSFERAMOUNT, TRANSFERTYPE);
        objRuralTransfer.TransferDate__c = system.today();
        System.runAs(testUser) {
            Test.startTest(); 
            insert objRuralTransfer;
            Test.stopTest(); 
            RuralTransfer__c objRuralTransfer1 = [select Id, TransferDate__c from RuralTransfer__c where TransferAmount__c =:TRANSFERAMOUNT and TransferType__c =: TRANSFERTYPE];
            ServiceItem__c  objServiceItem =  [select Id from ServiceItem__c where EndDate__c =:  objRuralTransfer1.TransferDate__c - 1];
            system.assertNotEquals(objServiceItem, null); 
            
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           18 Dec 2018
    @description    Records test (no records returned)
    *******************************************************************************/
    static testmethod void createNewServiceItem_transfertype_temporary(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        RuralEntitlement__c  objRuralEntitlementFrom =  [select Id , RemainingVolume__c from RuralEntitlement__c where Active__c =:true and StartDate__c =: system.today() - 20];
        RuralEntitlement__c  objRuralEntitlementTo =  [select Id, RemainingVolume__c from RuralEntitlement__c where Active__c =:true and StartDate__c =: system.today() - 10];
        RuralTransfer__c objRuralTransfer = GlUt_FactoryData_Test.createRuralTransfer(objRuralEntitlementTo , objRuralEntitlementFrom, TRANSFERAMOUNT, TRANSFERTYPETEMPORARY);
        objRuralTransfer.TransferDate__c = system.today();
        System.runAs(testUser) {
            Test.startTest(); 
            insert objRuralTransfer;
            Test.stopTest(); 
            RuralTransfer__c objRuralTransfer1 = [select Id, TransferDate__c from RuralTransfer__c where TransferAmount__c =:TRANSFERAMOUNT and TransferType__c =: TRANSFERTYPETEMPORARY];
            ServiceItem__c  objServiceItem =  [select Id from ServiceItem__c where EndDate__c =:  objRuralTransfer1.TransferDate__c - 1];
            system.assertNotEquals(objServiceItem, null); 
            
        }  
    } 
    
   /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           18 Dec 2018
    @description    Records test (no records returned)
    *******************************************************************************/
    static testmethod void createNewServiceItem_Negative() {    
        Boolean isException;       
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        RuralEntitlement__c  objRuralEntitlementFrom =  [select Id , RemainingVolume__c from RuralEntitlement__c where Active__c =:true and StartDate__c =: system.today() - 20];
        RuralEntitlement__c  objRuralEntitlementTo =  [select Id, RemainingVolume__c from RuralEntitlement__c where Active__c =:true and StartDate__c =: system.today() - 10];
        RuralTransfer__c objRuralTransfer = GlUt_FactoryData_Test.createRuralTransfer(objRuralEntitlementTo , objRuralEntitlementFrom, INVALIDTRANSFERAMOUNT, TRANSFERTYPETEMPORARY);
        System.runAs(testUser) {
            try{
                Test.startTest(); 
                insert objRuralTransfer;
                Test.stopTest();  
            }catch(exception e) {
                isException = true;
            } 
            system.assertEquals(isException, true);
        }  
    } 
}