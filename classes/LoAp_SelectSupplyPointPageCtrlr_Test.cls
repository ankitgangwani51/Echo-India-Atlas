/******************************************************************************
@author         Ankit Gangwani
@date           13 Feb 2018
@description    Test Class For LoAp_SelectSupplyPointCtrlr
*******************************************************************************/
@isTest
public class LoAp_SelectSupplyPointPageCtrlr_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String ACCOUNT_NAME 			= 'TestAccount'; 
    private static final String CONTRACT_NAME 		 	= 'TestContract';
    private static final String DEVICE_TYPE_NAME 		= 'Meter';
    private static final String DEVICE_NAME 			= '123456789';
    private static final String SERVICE_TYPE_WATER 		= 'Water';
    private static final String SERVICE_TYPE_SEWERAGE 	= 'Sewerage';    
    private static final String LOCATION_NAME 			= 'A99 9AA';
    private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';    
    private static final String MEASURED 				= 'Yes';
    private static final String READFREQUENCY 			= 'Monthly';    
    private static final String SERVICE_NAME 			= 'S-1442';
    private static final String WHOLESALER_NAME			= 'Wholesale System';
    private static final String INVALID_SUPPLY_POINT	= 'ABC';
    private static final String INVALID_LOCATION		= 'ABC';
    private static final String SERVICE_ITEM_FAMILYNAME = 'Measured Water Volumetric';
    private static final String SERVICE_ITEM_TYPE 		= 'Measured Water Volumetric';
    private static final String AVAILABLEBUNDLE 		= 'TestAvailableBundle';
    private static final String BUNDLEITEM 				= 'TestBundleItem';
    private static final String BUNDLE 					= 'TestBundle';
    private static final String AVAILABLESERVIEITEM		= 'TestAvailableServiceItem';
    private static final String DEVICE_SIZE 			= 'TestDeviceSize';
    private static final String MANUFACTURER 			= 'Siemens';
    private static final String UNIT_OF_MEASURE 		= 'Metric';
    private static final Date START_DATE 		 	 	= date.valueOf('2018-02-01');
    private static final Date END_DATE 		 			= date.valueOf('2018-02-28');
    
    /*****************************************************************************
    @author        Ankit Gangwani 
    @date          13 Feb 2018
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){ 
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME); 
        Database.insert(objAccount);
        
        // Create Contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        Database.insert(objContract);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        // Create ServiceType Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE_WATER);
        Database.insert(objServiceType);
        
        // Create ServiceType Record
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE_SEWERAGE);
        Database.insert(objServiceType1);        
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
   
        Database.insert(objSupplyPoint);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c = True; // AT-3174 
 
        Database.insert(objSupplyPoint1);
        
        // Create Supply Point Device Record
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);        
        Database.insert(objSupplyPointDevice);
         
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        // Create Available Service Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Available Service Record
        AvailableService__c objAvailableService1 = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME,objDivision,objServiceType1,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService1);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Feb 2018
    @description: Test Method to check retrieve Supply Point field Details in POSITIVE scenario
    *******************************************************************************/
    static testmethod void getSupplyPointFieldProps_Positive()
    {            
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<GLAp_FieldProps> supplyPointFieldPorps = new List<GLAp_FieldProps>();
        
        System.runAs(objUser){
            Test.startTest();
            supplyPointFieldPorps = LoAp_SelectSupplyPointPageCtrlr.getSupplyPointFieldProps();
            Test.stopTest();
        }
        System.assert(supplyPointFieldPorps != null);
    }
    
    /*****************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Feb 2018
    @description: Test Method to check retrieve Supply Point Record Details in POSITIVE scenario
    *******************************************************************************/
    static testmethod void getAvailableServicesOnSupplyPoint_Positive()
    {
        User objUser = [SELECT Id, Name FROM User WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<Id> lstIds = new List<Id>();        
        SupplyPoint__c objSupplyPoint = [SELECT Id from SupplyPoint__c LIMIT 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            lstIds = LoAp_SelectSupplyPointPageCtrlr.getAvailableServicesOnSupplyPoint(objSupplyPoint.Id);
            Test.stopTest();
        }        
        System.assert(lstIds != null);  
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Feb 2018
    @description: Test Method to check retrieve Supply Point Record Details in Negative scenario
    *******************************************************************************/
    static testmethod void getAvailableServicesOnSupplyPoint_Negative()
    {
        User objUser = [SELECT Id, Name FROM User WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<Id> lstIds = new List<Id>();        
        SupplyPoint__c objSupplyPoint = new SupplyPoint__c();
        
        System.runAs(objUser){
            Test.startTest();
            lstIds = LoAp_SelectSupplyPointPageCtrlr.getAvailableServicesOnSupplyPoint(objSupplyPoint.Id);
            Test.stopTest();
        }        
        System.assert(lstIds.size() == 0);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Feb 2018
    @description: Test Method to check retrieve Supply Point Record Details in Invalid/Negative scenario
    *******************************************************************************/
    static testmethod void getAvailableServicesOnSupplyPoint_InvalidSupplyPointNegative()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<Id> lstIds = new List<Id>();                
        Boolean isException;
        
        System.runAs(objUser){
            try{
                Test.startTest();
                lstIds = LoAp_SelectSupplyPointPageCtrlr.getAvailableServicesOnSupplyPoint(INVALID_SUPPLY_POINT);           
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }        
        System.assert(lstIds.size() == 0);
        System.assertEquals(lstIds.isEmpty(),true,'Negative scenario passed');   
    }
    
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Feb 2018
    @description: Test Method to check retrieve Location Record Details in POSITIVE scenario
    *******************************************************************************/
    static testmethod void getSupplyPointsOnLocation_Positive()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        Boolean isException;
        
        System.runAs(objUser){
            Test.startTest();
            combineRecordList = LoAp_SelectSupplyPointPageCtrlr.getSupplyPointsOnLocation(objLocation.Id);
            Test.stopTest();
        }        
        System.assert(combineRecordList != null);  
    }
    
    
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Feb 2018
    @description: Test Method to check retrieve Location Record Details in Negative scenario
    *******************************************************************************/
    static testmethod void getSupplyPointsOnLocation_Negative()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        Location__c objLocation = new Location__c();
        Boolean isException;
        
        System.runAs(objUser){
            Test.startTest();
            combineRecordList = LoAp_SelectSupplyPointPageCtrlr.getSupplyPointsOnLocation(objLocation.Id);
            Test.stopTest();
        }        
        System.assert(combineRecordList.size() == 0);  
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Feb 2018
    @description: Test Method to check retrieve Location Record Details in Invalid/Negative scenario
    *******************************************************************************/
    static testmethod void getSupplyPointsOnLocation_InvalidLocationNegative()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();                
        Boolean isException;
        
        System.runAs(objUser){
            try{
                Test.startTest();
                combineRecordList = LoAp_SelectSupplyPointPageCtrlr.getSupplyPointsOnLocation(INVALID_LOCATION);      
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }          
        
        System.assert(combineRecordList.size() == 0);  
        System.assertEquals(combineRecordList.isEmpty(), true, 'Negative scenario passed');
    }
}