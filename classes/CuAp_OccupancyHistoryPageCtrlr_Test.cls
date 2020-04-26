@isTest
public class CuAp_OccupancyHistoryPageCtrlr_Test {

    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String CONTRACT_NAME_THIRD ='TestContract3';
    private static final String CONTRACT_NAME_FOURTH ='TestContract4';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES1 ='TestAvailableService1';
    private static final String AVAILABLESERVICES2 ='TestAvailableService2';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String BUNDLE ='TestBundle';
    private static final String BUNDLECHANGE ='TestBundleChange';
    private static final String BUNDLESAMESUPPLYPOINT ='TestBundleSameSupplyPoint';
    private static final String BUNDLECHANGESOCIAL ='TestBundleChangeSocial';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
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
            
            Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
            objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
            objLocation.Street__c =STREET ;
            Database.insert(objLocation);
            
            BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_ONE,objAccount);
            objContract.HouseholdBilling__c = objLocation.Id;
            Database.insert(objContract);
            
            List<LocationOccupant__c> lstLocationOccupant = new List<LocationOccupant__c>();
            LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            objLocationOccupant.ShowOnBill__c = True;
            lstLocationOccupant.add(objLocationOccupant);
            
            LocationOccupant__c  objLocationOccupant1 = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            objLocationOccupant1.ShowOnBill__c = True;
            objLocationOccupant1.StartDate__c = system.today() - 10;
            objLocationOccupant1.EndDate__c = null;
            lstLocationOccupant.add(objLocationOccupant1);
            
            LocationOccupant__c  objLocationOccupant2 = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            objLocationOccupant2.ShowOnBill__c = True;
            objLocationOccupant2.StartDate__c = system.today() - 10;
            objLocationOccupant2.EndDate__c = system.today() + 1;
            lstLocationOccupant.add(objLocationOccupant2);
            Database.insert(lstLocationOccupant);
            
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
            AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES1 ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
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
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    positive test scenario for retrieveContractIds method
    *******************************************************************************/ 
    static testmethod void retrieveLocationListFieldProps_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProps = CuAp_OccupancyHistoryPageCtrlr.retrieveLocationListFieldProps();
            Test.stopTest();
            System.assert(!lstFieldProps.isEmpty());
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    positive test scenario for retrieveAvailaleService method
    *******************************************************************************/
    static testmethod void retrieveLocationListRecords_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [SELECT Id FROM Account  WHERE Name = :ACCOUNT_NAME LIMIT 1];
        System.runAs(objUser){
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            Test.startTest();
            records = CuAp_OccupancyHistoryPageCtrlr.retrieveLocationListRecords(objAccount.Id);
            Test.stopTest();
            System.assert(!records.isEmpty());
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    negative test scenario for retrieveAvailaleService method 
    *******************************************************************************/
    static testmethod void retrieveLocationListRecords_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [SELECT Id FROM Account  WHERE Name = :ACCOUNT_NAME LIMIT 1];
        System.runAs(objUser){
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            Test.startTest();
            records = CuAp_OccupancyHistoryPageCtrlr.retrieveLocationListRecords(null);
            Test.stopTest();
            System.assert(records == Null);
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    positive test scenario for retrieveAvailaleService method
    *******************************************************************************/
    static testmethod void retrieveOccupantsListFieldProps_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProps = CuAp_OccupancyHistoryPageCtrlr.retrieveOccupantsListFieldProps();
            Test.stopTest();
            System.assert(!lstFieldProps.isEmpty());
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    positive test scenario for retrieveAvailaleService method
    *******************************************************************************/
    static testmethod void retrieveOccupantsListRecords_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [SELECT Id FROM Account  WHERE Name = :ACCOUNT_NAME LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME LIMIT 1];
        LocationOccupant__c objLocationOccupant = [SELECT Id, EndDate__c FROM LocationOccupant__c  WHERE Location__c = :objLocation.Id  AND Account__c = :objAccount.Id ORDER BY StartDate__c DESC LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> records = CuAp_OccupancyHistoryPageCtrlr.retrieveOccupantsListRecords(objLocation.id,objAccount.Id);
            objLocationOccupant.EndDate__c = null;
            Database.update(objLocationOccupant);
            List<BlAp_CombinedRecord> records2 = CuAp_OccupancyHistoryPageCtrlr.retrieveOccupantsListRecords(objLocation.id,objAccount.Id);
            Test.stopTest();
            System.assert(!records.isEmpty());
            System.assert(!records2.isEmpty());
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    negative test scenario for retrieveAvailaleService method
    *******************************************************************************/
    static testmethod void retrieveOccupantsListRecords_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            Test.startTest();
            records = CuAp_OccupancyHistoryPageCtrlr.retrieveOccupantsListRecords(null, null);
            Test.stopTest();
            System.assert(records == Null);
        }
    }
}