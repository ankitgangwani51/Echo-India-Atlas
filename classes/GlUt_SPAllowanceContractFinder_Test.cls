/******************************************************************************
@author         Echo: Mohit Tayal
@date           06 July 2018
@description    Contract Finder test class for Supply Point Allowance
                (Due to the Class Name character limit issue - changing the Supply Point to SP in the Class Name)
@revision(s)        
*******************************************************************************/
@isTest
public class GlUt_SPAllowanceContractFinder_Test {

    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String BUNDLE ='TestBundle';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final Integer LIMIT1 =1;
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String ALLOWANCETYPENAME 	 	= 'TestAllowanceType';
    private static final String ALLOWANCEPRIORITY 	 	= '1';
    private static final String ALLOWANCETYPE 	 	    = 'Fixed Volume Allowance';
    private static final String SUPPLYPOINTALLOWANCENAME = 'TestSupplyPointAllowanceName';
    
    /*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/   
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser); 
        System.runAs(objUser){
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
            Database.insert(objDeviceType);
                        
            Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
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

            // Create Main Supply Point
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
            Database.insert(objServiceItem);
            
            AllowanceType__c objAllowanceType = GlUt_FactoryData_Test.createAllowanceType(ALLOWANCETYPENAME, objServiceItemFamily, objSupplyPointUsageType, ALLOWANCEPRIORITY, ALLOWANCETYPE, True);
            Database.insert(objAllowanceType);

            SupplyPointAllowance__c objSupplyPointAllowance = GlUt_FactoryData_Test.createSupplyPointAllowance(SUPPLYPOINTALLOWANCENAME, objServiceItem, objAllowanceType, TRUE, objSupplyPoint);
            Database.insert(objSupplyPointAllowance);
        }
    }
   /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           06 July 2018
    @description    positive test scenario for retrieveContractIds method
    *******************************************************************************/
    static testmethod void retrieveContractIds_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        ServiceItemType__c  objServiceItemType = [SELECT Id FROM ServiceItemType__c  WHERE NAME = :SERVICEITEMTYPE LIMIT 1];
        ServiceItem__c  objServiceItem = [SELECT Id FROM ServiceItem__c WHERE ServiceItemType__c = :objServiceItemType.Id LIMIT 1];
        ServiceType__c objServiceType = [SELECT Id FROM ServiceType__c WHERE Name = :TEST_SERVICE_TYPE LIMIT 1];
        ServiceItemFamily__c objServiceItemFamily = [SELECT Id FROM ServiceItemFamily__c WHERE ServiceType__c = :objServiceType.Id LIMIT 1];
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c WHERE Name = :SP_USAGE_TYPE LIMIT 1];
        AllowanceType__c objAllowanceType = [SELECT Id FROM AllowanceType__c WHERE SupplyPointUsageType__c = :objSupplyPointUsageType.Id AND ServiceItemFamily__c = :objServiceItemFamily.Id LIMIT 1];
        SupplyPointAllowance__c objSupplyPointAllowance = [SELECT Id FROM SupplyPointAllowance__c WHERE ServiceItem__c = :objServiceItem.Id AND AllowanceType__c = :objAllowanceType.Id LIMIT 1];
        Set<Id> setOfContractIds = new Set<Id>();
        System.runAs(objUser){
            Test.startTest();
            GlUt_SupplyPointAllowanceContractFinder objGlUt_SupplyPointAllowanceContractFinder = new GlUt_SupplyPointAllowanceContractFinder();
            setOfContractIds = objGlUt_SupplyPointAllowanceContractFinder.retrieveContractIds(objSupplyPointAllowance.Id);
            Test.stopTest();
            System.assert(!setOfContractIds.isEmpty());
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           06 July 2018
    @description    negative test scenario for retrieveContractIds method
    *******************************************************************************/
    static testmethod void retrieveContractIds_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        Set<Id> setOfContractIds = new Set<Id>();
        System.runAs(objUser){
            Test.startTest();
            GlUt_SupplyPointAllowanceContractFinder objGlUt_SupplyPointAllowanceContractFinder = new GlUt_SupplyPointAllowanceContractFinder();
            String invalidId = null;
            setOfContractIds = objGlUt_SupplyPointAllowanceContractFinder.retrieveContractIds(invalidId);
            Test.stopTest();
            System.assert(setOfContractIds.isEmpty());
        }
    }
}