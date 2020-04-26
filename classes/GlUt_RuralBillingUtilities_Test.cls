/******************************************************************************
@author         Echo: Vivek Sethi
@date           03 Jan 2019
@description    Test Class for GlUt_RuralBillingUtilities
Revision(s)     
*******************************************************************************/
@isTest 
public class GlUt_RuralBillingUtilities_Test {
   
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
        objRuralLicense.Status__c = Label.BlAp_RuralLicenseStatusActive;
        objRuralLicense.BillingContract__c = objContract.Id;
        Database.insert(objRuralLicense);
        
        RuralLicense__c objRuralLicense1 = GlUt_FactoryData_Test.createRuralLicense();
        objRuralLicense1.BaseEntitlement__c = BASEENTITLEMENT;
        objRuralLicense1.InfrastructureCharge__c = objServiceItemType.Id;
       
        Database.insert(objRuralLicense1);
        
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
        objRuralEntitlementFrom.Active__c = false;
        objRuralEntitlementFrom.PermanentTransfersIn__c =   PERMANENTTRANSFERIN;
        objRuralEntitlementFrom.PermanentTransfersOut__c = PERMANENTTRANSFEROUT;
        objRuralEntitlementFrom.SeasonalAllocation__c = 100;
        objRuralEntitlementFrom.RuralLicense__c = objRuralLicense.Id;
        ruralEntitlementList.add(objRuralEntitlementFrom);
        Database.insert(ruralEntitlementList);
        
        RuralGrossConsumption__c  objRuralGrossConsumption = GlUt_FactoryData_Test.createRuralGrossConsumption(ruralEntitlementList[0],objSupplyPoint);
        objRuralGrossConsumption.Reading__c =  objReading.Id;
        Database.insert(objRuralGrossConsumption);
        
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 Jan 2019
    @description    isActiveRuralLicense_positive scenario
   *******************************************************************************/
    static testmethod void isActiveRuralLicense_positive(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
         
        RuralLicense__c objRuralLicense = [select Id from RuralLicense__c where Status__c =: Label.BlAp_RuralLicenseStatusActive limit 1];
        Boolean isRuralLicenseActive;
        System.runAs(testUser) {
            Test.startTest(); 
            isRuralLicenseActive = GlUt_RuralBillingUtilities.isActiveRuralLicense(objRuralLicense.Id);
            Test.stopTest(); 
            system.assertEquals(isRuralLicenseActive, true);
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 Jan 2019
    @description    isActiveRuralLicense negative scenario
   *******************************************************************************/
    static testmethod void isActiveRuralLicense_negative(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
         
        RuralLicense__c objRuralLicense = [select Id from RuralLicense__c where Status__c !=: Label.BlAp_RuralLicenseStatusActive limit 1];
        Boolean isRuralLicenseActive;
        System.runAs(testUser) {
            Test.startTest(); 
            isRuralLicenseActive = GlUt_RuralBillingUtilities.isActiveRuralLicense(objRuralLicense.Id);
            Test.stopTest(); 
            system.assertEquals(isRuralLicenseActive, false);
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 Jan 2019
    @description    getActiveRuralEntitlement positive scenario
   *******************************************************************************/
    static testmethod void getActiveRuralEntitlement(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> ruralEntitlementSet = new Set<Id>(); 
        for(RuralEntitlement__c objruralEntitlement : [select Id from RuralEntitlement__c]) {
            ruralEntitlementSet.add(objruralEntitlement.Id);
        }
        List<RuralEntitlement__c> ruralEntitlementList;
        System.runAs(testUser) {
            Test.startTest(); 
            ruralEntitlementList = GlUt_RuralBillingUtilities.getActiveRuralEntitlement(ruralEntitlementSet);
            Test.stopTest(); 
            system.assertNotEquals(ruralEntitlementList.isEmpty(), NULL);
        }  
    } 
    
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           03 Jan 2019
	@description    getRuralChannel  
	*******************************************************************************/
    static testmethod void getRuralChannel(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> ruralChannelSet = new Set<Id>(); 
        for(RuralChannel__c objruralChannel :  [select Id from RuralChannel__c]) {
            ruralChannelSet.add(objruralChannel.Id);
        }
        List<RuralChannel__c> ruralChannelList;
        System.runAs(testUser) {
            Test.startTest(); 
            ruralChannelList = GlUt_RuralBillingUtilities.getRuralChannel(ruralChannelSet);
            Test.stopTest(); 
            system.assertNotEquals(ruralChannelList.isEmpty(), NULL);
        }  
    } 
    
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           03 Jan 2019
	@description    fetchSupplyPoint  
	*******************************************************************************/
    static testmethod void fetchSupplyPoint(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> ruralChannelSet = new Set<Id>(); 
        for(RuralChannel__c objruralChannel :  [select Id from RuralChannel__c]) {
            ruralChannelSet.add(objruralChannel.Id);
        }
        
        List<String> queryFields = new List<String>();
        queryFields.add(GlUt_APIConstantsSupplyPoint.RURALCHANNELAPINAME);
        queryFields.add(GlUt_APIConstantsSupplyPoint.RURALLICENCEAPINAME);
        Id supplyPointRecordTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_Constants.RURALOUTLETRECORDTYPE).getRecordTypeId();
        List<RuralChannel__c> ruralChannelList;
        System.runAs(testUser) {
            Test.startTest(); 
            List<SupplyPoint__c> supplyPointList = GlUt_RuralBillingUtilities.fetchSupplyPoint(queryFields,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,ruralChannelSet,GlUt_APIConstantsSupplyPoint.RURALCHANNELAPINAME,GlUt_APIConstantsSupplyPoint.RURALOUTLETBILLINGTYPEAPINAME,GlUt_Constants.RURALOUTLET_BILLINGTYPE_UNCONTROLLED,supplyPointRecordTypeId);
            Test.stopTest(); 
            system.assertNotEquals(supplyPointList.isEmpty(), NULL);
        }  
    } 
    
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           03 Jan 2019
	@description    getMapOfRuralLicenceHavingEntitlementId  
	*******************************************************************************/
    static testmethod void getMapOfRuralLicenceHavingEntitlementId(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> ruralLicenseSet = new Set<Id>(); 
        Map<Id,Id> mapOfRuralLicenceId2RuralEntitlementId = new Map<Id,Id>();
        for(RuralLicense__c objruralLicense :  [select Id from RuralLicense__c]) {
            ruralLicenseSet.add(objruralLicense.Id);
        }
        
        System.runAs(testUser) {
            Test.startTest(); 
            mapOfRuralLicenceId2RuralEntitlementId = GlUt_RuralBillingUtilities.getMapOfRuralLicenceHavingEntitlementId(ruralLicenseSet);
            Test.stopTest(); 
            system.assertNotEquals(mapOfRuralLicenceId2RuralEntitlementId.isEmpty(), NULL);
        }  
    } 
    
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           03 Jan 2019
	@description    getRuralGrossConsumptionFromReading  
	*******************************************************************************/
    static testmethod void getRuralGrossConsumptionFromReading(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> readingSet = new Set<Id>(); 
        List<RuralGrossConsumption__c> ruralGrossConsumptionList = new List<RuralGrossConsumption__c>();
        for(Reading__c objReading :  [select Id from Reading__c]) {
            readingSet.add(objReading.Id);
        }
        
        System.runAs(testUser) {
            Test.startTest(); 
            ruralGrossConsumptionList = GlUt_RuralBillingUtilities.getRuralGrossConsumptionFromReading(readingSet);
            Test.stopTest(); 
            system.assertNotEquals(ruralGrossConsumptionList.isEmpty(), NULL);
        }  
    } 
        
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           03 Jan 2019
	@description    getRuralEntitlementFromContractIds  
	*******************************************************************************/
    static testmethod void getRuralEntitlementFromContractIds(){            
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> billingContractSet = new Set<Id>(); 
        List<RuralEntitlement__c> ruralEntitlementList = new List<RuralEntitlement__c>();
        for(BillingContract__c objBillingContract :  [select Id from BillingContract__c]) {
            billingContractSet.add(objBillingContract.Id);
        }
        
        System.runAs(testUser) {
            Test.startTest(); 
            ruralEntitlementList = GlUt_RuralBillingUtilities.getRuralEntitlementFromContractIds(billingContractSet);
            Test.stopTest(); 
            system.assertNotEquals(ruralEntitlementList.isEmpty(), NULL);
        }  
    } 
}