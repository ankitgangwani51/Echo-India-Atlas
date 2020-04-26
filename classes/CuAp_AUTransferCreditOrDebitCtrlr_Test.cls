/******************************************************************************
@author         Echo: Tarun Gupta
@date           11 Mar 2019
@description    Test class for CuAp_AUTransferCreditOrDebitCtrlr
*******************************************************************************/
@isTest
public class CuAp_AUTransferCreditOrDebitCtrlr_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String LOCATION_NAME 		= 'A99 9AA';   
    private static final String LOCATION_SUB_TYPE 	= 'Detached';
    private static final String STREET 				= 'teststreet';
    private static final String TESTSERVICE_TYPE1 	= 'TestServiceType1'; 
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    
    private static final String DEVICE_SIZE 		= '10mm';
    private static final String MANUFACTURER 		= 'Kent';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String SERIALNO = '0801';
    private static final String WHOLESALER 			= 'TestWholesaler';
    private static final String AVAILABLESERVICES 	= 'TestAvailableService';
    private static final String SERVICE_ITEM_FAMILY = 'Service_Item_Family';
    private static final String BUNDLE_ITEM = 'Test_BundleItem';
    private static final String BUNDLE_NAME = 'Bundle_Test';
    private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
    private static final String AVAIL_SERVICE_ITEM = 'AvailableServiceItem_Test';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);          
        Database.insert(objBalance);
        
        // Create Contract for Refund Paymet           
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);       
        
        //Create Service Type Record - 1
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType1);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point  - Remove Device
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c = true;
        Database.insert(objSupplyPoint1);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record - old device for Remove Device Scenario
        Device__c  objDevice = GlUt_FactoryData_Test.CreateDevice(SERIALNO , objDeviceType);        
        Database.insert(objDevice);
        
        // Create Supply Point Device Record - Exchage
        SupplyPointDevice__c  objSupplyPointDeviceExchange = GlUt_FactoryData_Test.CreateSupplyPointDevices(objDevice , objSupplyPoint1);        
        Database.insert(objSupplyPointDeviceExchange);
        
         // Create Supply Point Device Service Record - Exchange
        SupplyPointDeviceService__c  objSupplyPointDeviceServiceExchange = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objSupplyPointDeviceExchange , objServiceType1);        
        Database.insert(objSupplyPointDeviceServiceExchange);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Available Service Record - Remove - Water (Existing Available Service Where Available Service Item gets ended with removal date and last bundle change date is set)
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType1,objSupplyPoint1,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record - Remove Device - (Existing Services)
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        objService.OccupancyType__c = Label.CuAp_AUMoveInOccTypeOwner;
        Database.insert(objService);
        
        // Create ServiceItemFamily Record            
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType1);
        Database.insert(objServiceItemFamily);
        
        // Create ServiceItemType Record            
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType);
        
        // Create Bundle Record            
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType1);
        Database.insert(objBundle);
        
        // Create BundleItem Record            
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);	
        
        // Create AvailableBundle Record            
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLE_BUNDLE, objBundle, objAvailableService );
        Database.insert(objAvailableBundle);
        
        // Create AvailableServiceItem Record            
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);
                
        // Create ServiceItem Record            
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = Date.today().addDays(-10);
        Database.insert(objServiceItem);
        
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        11 Mar 2019
	@description: Positive method of retrieveCreditAndDebitAmount 
	*******************************************************************************/
    static testmethod void retrieveCreditAndDebitAmount(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [Select Id,Name FROM Location__c WHERE Street__c =: STREET limit 1];
        Boolean isException = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                CuAp_AUTransferCreditOrDebitCtrlr.WrapCreditAndDebitDetails objWrap = new CuAp_AUTransferCreditOrDebitCtrlr.WrapCreditAndDebitDetails();
                objWrap = CuAp_AUTransferCreditOrDebitCtrlr.retrieveCreditAndDebitAmount(objLocation.Id, String.valueOf(Date.today()), Label.CuAp_AUMoveInOccTypeOwner);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
        }          
    }
}