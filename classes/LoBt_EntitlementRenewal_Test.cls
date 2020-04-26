/******************************************************************************
@author         Echo: Vivek Sethi
@date           12 March 2019
@description    Test Class for LoBt_EntitlementRenewal
Revision(s)     
*******************************************************************************/
@isTest 
public class LoBt_EntitlementRenewal_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String BATCH_CLASS = 'LoBt_EntitlementRenewal';
    private static final String STAGING_TABLE = 'ReadingUpload__c';
    private static final String INVALIDID  = 'a211v000002iyaOAAQ';
    private static final String SName  = 'Test';
    private static final Integer SEASONALLOCATION = 21;
    private static final Date RENEWALDATE = system.today();
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
    private static final Integer BATCH_SIZE 		= 200 ;
    private static final String BATCHCLASS 			= 'LoBt_EntitlementRenewal' ;
    private static final String BATCHREQQUEUEINITIALISEDSTATUS = 'Initialised' ;
    

    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           12 March 2019
    @description    Test data setup
    *******************************************************************************/
    @TestSetup
    static void createTestData() {
        
        User testUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        testUser.FirstName = USER_FIRST_NAME;
        testUser.LastName = USER_LAST_NAME;
        insert testUser;
       
        List<BatchProcess__c> batchProcesses = new List<BatchProcess__c>();
        BatchProcess__c batchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS);
        batchProcess.Name = 'TestProcess';
        batchProcess.Operation__c = GlUt_Constants.BATCHPROCESSOPERATION;
        batchProcess.StagingTable__c = STAGING_TABLE;
        batchProcesses.add(batchProcess);
        insert batchProcesses;
        
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
        RuralEntitlement__c objRuralEntitlementExpired = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        objRuralEntitlementExpired.StartDate__c = system.today() - 20;
        objRuralEntitlementExpired.Active__c = true;
        objRuralEntitlementExpired.PermanentTransfersIn__c = PERMANENTTRANSFERIN;
        objRuralEntitlementExpired.PermanentTransfersOut__c = PERMANENTTRANSFEROUT;
        objRuralEntitlementExpired.SeasonalAllocation__c = BASEENTITLEMENT ;
        objRuralEntitlementExpired.RuralLicense__c = objRuralLicense.Id;
        ruralEntitlementList.add(objRuralEntitlementExpired);
        
        RuralEntitlement__c objRuralEntitlement = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        objRuralEntitlement.StartDate__c = system.today() + 20;
        objRuralEntitlement.Active__c = true;
        objRuralEntitlement.PermanentTransfersIn__c =   PERMANENTTRANSFERIN;
        objRuralEntitlement.PermanentTransfersOut__c = PERMANENTTRANSFEROUT;
        objRuralEntitlement.SeasonalAllocation__c = 100;
        objRuralEntitlement.RuralLicense__c = objRuralLicense.Id;
        ruralEntitlementList.add(objRuralEntitlement);
        Database.insert(ruralEntitlementList);
        
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.RuralEntitlement__c = ruralEntitlementList[0].Id;
        Database.insert(objServiceItem);

    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           12 March 2019
    @description    Records test (records returned)
   *******************************************************************************/
    static testmethod void createDefaultBatchRequest_Positive(){            
        BatchProcess__c batchProcess = [select Id from BatchProcess__c limit 1];
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest(); 
            //Creating BRQ Record
            Boolean recordBRQCreated = LoAp_EntitlementRenewalCtrlr.createDefaultBatchRequest(String.valueOf(RENEWALDATE),SEASONALLOCATION,batchProcess.Id); 
            system.assert(recordBRQCreated == TRUE);
            
            BatchRequestQueue__c objBatchRequestQueue = [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE Type__c  =:  LoBt_Constants.ENTITLEMENTRENEWAL LIMIT 1] ;
           
            LoBt_EntitlementRenewal entitlementRenewalJob  = new LoBt_EntitlementRenewal() ;
            entitlementRenewalJob.Initialise(objBatchRequestQueue) ;
            Database.executeBatch(entitlementRenewalJob, BATCH_SIZE) ;
            Test.stopTest(); 

            RuralEntitlement__c  objRuralEntitlementInactive =  [select Id, BaseVolume__c from RuralEntitlement__c where Active__c =:false LIMIT 1];
            system.assertNotEquals(objRuralEntitlementInactive, null); 
        }  
    } 
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           12 March 2019
    @description    Records test (no records returned)
    *******************************************************************************/
    static testmethod void createDefaultBatchRequest_Negative() {    
        Boolean isException;    
        BatchProcess__c batchProcess = [select Id from BatchProcess__c limit 1];
        User testUser = [select Id, 
                         Name 
                         from User 
                         where isActive = true 
                         and Username = :USERNAMECOMPLETE LIMIT 1];
        
        System.runAs(testUser) {
            try{
                Test.startTest(); 
                Boolean recordBRQCreated = LoAp_EntitlementRenewalCtrlr.createDefaultBatchRequest(String.valueOf(RENEWALDATE),SEASONALLOCATION,batchProcess.Id); 
                
                BatchRequestQueue__c objBatchRequestQueue = [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE Type__c  =:  LoBt_Constants.ENTITLEMENTRENEWAL LIMIT 1] ;
                
                LoBt_EntitlementRenewal entitlementRenewalJob  = new LoBt_EntitlementRenewal() ;
                entitlementRenewalJob.Initialise(objBatchRequestQueue) ;
                Database.executeBatch(entitlementRenewalJob, BATCH_SIZE) ;
                Test.stopTest();  
            }catch(exception e) {
                isException = true;
            } 
            
            //Error to fetch the records which are already renewed
            BatchError__c  batchError  = [SELECT Id , ErrorDetails__c from BatchError__c  LIMIT 1]; 
            system.assertEquals(batchError.ErrorDetails__c.contains(LoBt_Constants.ENTITLEMENTRENEWEDERROR),True);                                       
            
        }  
    } 
}