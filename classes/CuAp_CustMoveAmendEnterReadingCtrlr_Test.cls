/******************************************************************************
@author         Ankit Gangwani
@date           17 Sept 2018
@description    Test Class For CuAp_CustMoveAmendEnterReadingCtrlr
*******************************************************************************/
@isTest
public class CuAp_CustMoveAmendEnterReadingCtrlr_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String sName					= 'Test Name';
    private static final String strManufacturer			= 'Siemens';
    private static final String strUnitOfMeasure		= 'Metric';
    private static final String sZipcode				= 'A99 9AA';
    private static final String SP_USAGE_TYPE			= 'SupplyPointUsageType';
    private static final String AVAILABLESERVICES 		= 'TestAvailableServiceItem';
    private static final String WHOLESALER 				= 'TestWholesaler';
    private static final String MEASURED 				= 'Monthly';
    private static final String DUMMYDATA 				= 'Test';
    private static final String LOCATION_SUB_TYPE 		= 'Detached';
    private static final String STREET 					= 'teststreet';
    private static final String SERIAL_NUMBER			= '123456';
    private static final String READING_METHOD			= 'System Estimated';
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          17 Sept 2018 
    @param         -
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){  
       
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        objUser.Email = EMAIL_ADDRESS;
        Database.insert(objUser);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(sName);
        Database.insert(objAccount);
        
        // Create Contrat Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(objAccount);
        Database.insert(objContract);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(sZipcode);
        objLocation.LocationSubType__c = LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(sName);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True;
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(sName);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, strManufacturer, strUnitOfMeasure);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(sName, objDeviceType);
        objDevice.SerialNo__c = SERIAL_NUMBER;
        Database.insert(objDevice);
        
        // Create Supply Point Device Record
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        // Create First Reading Record
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = Date.today().addDays(-40);
        objReading1.ActualDeviceReading__c = '10';
        objReading1.ReadingMethod__c = READING_METHOD;
        Database.insert(objReading1);
        
        // Create Second Reading Record
        Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading2.ReadingDate__c = Date.today().addDays(-30);
        objReading2.ActualDeviceReading__c = '20';
        objReading2.ReadingMethod__c = READING_METHOD;
        Database.insert(objReading2);
        
        // Create Third Reading Record
        Reading__c objReading3 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading3.ReadingDate__c = Date.today().addDays(-20);
        objReading3.ActualDeviceReading__c = '30';
        objReading3.ReadingMethod__c = READING_METHOD;
        Database.insert(objReading3);
        
        // Create Fourth Reading Record
        Reading__c objReading4 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading4.ReadingDate__c = Date.today().addDays(-10);
        objReading4.ActualDeviceReading__c = '40';
        objReading4.ReadingMethod__c = READING_METHOD;
        Database.insert(objReading4);
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          18 Sept 2018 
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveReadingPropDetails(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            List<GlAp_FieldProps> fieldPropList = new List<GlAp_FieldProps>();
            try {                
                Test.starttest();
                fieldPropList = CuAp_CustMoveAmendEnterReadingCtrlr.retrieveReadingPropDetails();
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(fieldPropList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          18 Sept 2018 
    @return        Void   
    *******************************************************************************/     
    static testmethod void getSupplyPointAndDeviceRecords_Positive(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        System.runAs(objUser[0]){
            List<BlAp_CombinedRecord> combinecRecordList = new List<BlAp_CombinedRecord>();
            try {                
                Test.starttest();
                combinecRecordList = CuAp_CustMoveAmendEnterReadingCtrlr.getSupplyPointAndDeviceRecords(objLocation.Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinecRecordList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          18 Sept 2018 
    @return        Void   
    *******************************************************************************/     
    static testmethod void getSupplyPointAndDeviceRecords_Negative(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];        
        System.runAs(objUser[0]){
            List<BlAp_CombinedRecord> combinecRecordList = new List<BlAp_CombinedRecord>();
            try {                
                Test.starttest();
                combinecRecordList = CuAp_CustMoveAmendEnterReadingCtrlr.getSupplyPointAndDeviceRecords(NULL);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinecRecordList.size() == 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          18 Sept 2018 
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveReadingsfieldList(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];        
        System.runAs(objUser[0]){
            List<GlAp_FieldProps> fieldPropList = new List<GlAp_FieldProps>();
            try {                
                Test.starttest();
                fieldPropList = CuAp_CustMoveAmendEnterReadingCtrlr.retrieveReadingsfieldList();
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(fieldPropList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          18 Sept 2018 
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveReadingsRecordList_Positive(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];        
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        System.runAs(objUser[0]){
            List<BlAp_CombinedRecord> combinecRecordList = new List<BlAp_CombinedRecord>();
            try {                
                Test.starttest();
                combinecRecordList = CuAp_CustMoveAmendEnterReadingCtrlr.retrieveReadingsRecordList(objDevice.Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinecRecordList.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          18 Sept 2018 
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveReadingsRecordList_Negative(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];        
        System.runAs(objUser[0]){
            List<BlAp_CombinedRecord> combinecRecordList = new List<BlAp_CombinedRecord>();
            try {                
                Test.starttest();
                combinecRecordList = CuAp_CustMoveAmendEnterReadingCtrlr.retrieveReadingsRecordList(NULL);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinecRecordList.size() == 0);
        }
    }
    
    /******************************************************************************
    @author        Neha R.
    @date          20 Mar 2019 
    @return        Void   
    *******************************************************************************/     
    static testmethod void getallDeviceReading_Positive(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        System.runAs(objUser[0]){
            Map<Id,List<Reading__c>> deviceExistingReding = new Map<Id,List<Reading__c>>();
            try {                
                Test.starttest();
                deviceExistingReding = CuAp_CustMoveAmendEnterReadingCtrlr.getallDeviceReading(objLocation.Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(deviceExistingReding.size() > 0);
        }
    }
    
    
}