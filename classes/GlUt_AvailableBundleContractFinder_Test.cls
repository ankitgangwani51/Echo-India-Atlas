/******************************************************************************
@author         Echo: Mohit Tayal
@date           27 July 2018
@description    Contract Finder test class for Available Bundle
@revision(s)        
*******************************************************************************/
@isTest
public class GlUt_AvailableBundleContractFinder_Test {

    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
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
    private static final String BUNDLE ='TestBundle';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
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
            Database.insert(objContract);
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
            //objSupplyPoint.Measured__c=YES ;
            Database.insert(objSupplyPoint);
            Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
            Database.insert(objDivision);
            Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
            Database.insert(objWholesaler);
            AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
            Database.insert(objAvailableService);
            Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
            Database.insert(objService);
            Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
            Database.insert(objBundle);
            AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
            Database.insert(objAvailableBundle); 
        }
    }
   /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           27 July 2018
    @description    positive test scenario for retrieveContractIds method
    *******************************************************************************/ 
    static testmethod void retrieveContractIds_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = [SELECT Id FROM AvailableBundle__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        
        Set<Id> setOfContractIds = new Set<Id>();
        System.runAs(objUser){
            Test.startTest();
            GlUt_AvailableBundleContractFinder objGlUt_AvailableBundleContractFinder = new GlUt_AvailableBundleContractFinder();
            setOfContractIds = objGlUt_AvailableBundleContractFinder.retrieveContractIds(objAvailableBundle.Id);
            Test.stopTest();
            System.assert(!setOfContractIds.isEmpty());
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           27 July 2018
    @description    negative test scenario for retrieveContractIds method
    *******************************************************************************/ 
    static testmethod void retrieveContractIds_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        Set<Id> setOfContractIds = new Set<Id>();
        System.runAs(objUser){
            Test.startTest();
            GlUt_AvailableBundleContractFinder objGlUt_AvailableBundleContractFinder = new GlUt_AvailableBundleContractFinder();
            String contractId = null ;
            setOfContractIds = objGlUt_AvailableBundleContractFinder.retrieveContractIds(contractId);
            Test.stopTest();
            System.assert(setOfContractIds.isEmpty());
        }
    }
}