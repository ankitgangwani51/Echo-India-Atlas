/******************************************************************************
@author         Echo: Vivek Sethi
@date           03 Jan 2019
@description    Test Class for GlUt_ChannelOpenHandler
Revision(s)     
*******************************************************************************/
@isTest 
public class GlUt_ChannelOpenHandler_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
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
    private static final String DEPOT_NAME        = 'Leads';
    private static final String AREA_NAME         = 'North';
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date            03 Jan 2019
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
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
 
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
        
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        objServiceItemType.StartDate__c = Date.Today();
        objServiceItemType.AvailableToSelectInWizard__c = True;
        Database.insert(objServiceItemType); 
        
        RuralLicense__c objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
        objRuralLicense.BaseEntitlement__c = BASEENTITLEMENT;
        objRuralLicense.InfrastructureCharge__c = objServiceItemType.Id;
        Database.insert(objRuralLicense);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        objLocation.RuralLicense__c = objRuralLicense.Id;
        Database.insert(objLocation);
        
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);        
        Database.insert(objDepot);
        
        RuralChannel__c objRuralChannel = GlUt_FactoryData_Test.createRuralChannel(objArea, objDepot);        
        objRuralChannel.UncontrolledDailyVolume__c = 23.0;
        Database.insert(objRuralChannel);
        
        ChannelOpen__c objChannelOpen = GlUt_FactoryData_Test.createChannelOpen(objRuralChannel);
        objChannelOpen.StartDate__c = system.today() -20;
        objChannelOpen.EndDate__c = system.today() - 1;
        Database.insert(objChannelOpen);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.RuralChannel__c = objRuralChannel.Id;
        objSupplyPoint.RuralOutletBillingType__c = GlUt_Constants.RURALOUTLET_BILLINGTYPE_UNCONTROLLED;
        objSupplyPoint.RecordTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_Constants.RURALOUTLETRECORDTYPE).getRecordTypeId();  
        Database.insert(objSupplyPoint);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
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
    @author         Echo: Vivek Sethi
    @date           03 Jan 2019
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void createRuralGrossConsumptionandValidateOpenChannelPeriod(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        RuralChannel__c  objRuralChannel =  [select Id from RuralChannel__c limit 1];
        ChannelOpen__c objChannelOpen = GlUt_FactoryData_Test.createChannelOpen(objRuralChannel);
       
        System.runAs(testUser) {
            Test.startTest(); 
            Database.insert(objChannelOpen);
            Test.stopTest(); 
            system.assertNotEquals(objChannelOpen, null);
        }  
    } 
    
   /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 Jan 2019
    @description    Records test (no records returned)
    *******************************************************************************/
    
    static testmethod void createRuralGrossConsumptionandValidateOpenChannelPeriod_Update(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
   
        ChannelOpen__c objChannelOpen = [select Id from ChannelOpen__c where EndDate__c =: system.today() - 1 ];
        objChannelOpen.EndDate__c = system.today() + 10;
        System.runAs(testUser) {
            Test.startTest(); 
            Database.update(objChannelOpen);
            Test.stopTest(); 
            RuralGrossConsumption__c objRuralGrossConsumption = [select Id from RuralGrossConsumption__c];
            system.assertNotEquals(objRuralGrossConsumption, null); 
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 Jan 2019
    @description    Records test (no records returned)
    *******************************************************************************/
    
    static testmethod void createRuralGrossConsumptionandValidateOpenChannelPeriod_Negative() {    
        Boolean isException;       
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        RuralChannel__c  objRuralChannel =  [select Id from RuralChannel__c limit 1];
        ChannelOpen__c objChannelOpen = GlUt_FactoryData_Test.createChannelOpen(objRuralChannel);
        objChannelOpen.StartDate__c = system.today() -21;
        String error;
        System.runAs(testUser) {
            try{
                Test.startTest(); 
                Database.insert(objChannelOpen);
                Test.stopTest();  
            }catch(exception e) {
                error = e.getMessage().split(':')[1].split(',')[1];
                isException = true;
            } 
            system.assertEquals(isException, true);
            //Channel Open Period  cannot Overlap
            system.assertEquals(error.deleteWhitespace(), System.Label.GlUt_ChannelOpenPeriodOverlapException.deleteWhitespace());
        }  
    } 
}