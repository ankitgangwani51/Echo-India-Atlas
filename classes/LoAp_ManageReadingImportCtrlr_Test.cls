/******************************************************************************
@author         Ankit Gangwani
@date           05 June 2018
@description    Test Class For LoAp_ManageReadingImportCtrlr
*******************************************************************************/
@isTest
public class LoAp_ManageReadingImportCtrlr_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String OVERRIDE_VALUE          = '100';
    private static final String ZIP_CODE                = 'WS2 7PD';
    private static final String SPUTNAME                = 'Test SP USage Type';
    private static final String DEVICE_SIZE_NAME        = '25';
    private static final String DEVICE_MANUFACTURER     = 'kent';
    private static final String DEVICE_UOFMEASURE       = 'Imperial - UK Gallons';
    private static final String DEVICE_SERIAL_NUMBER    = 'A123';
    private static final String DEVICE_NAME             = 'Test Device';
    private static final String DEPOT_NAME              = 'Test Depot';
    private static final String MEASURED				= 'Monthly';
    private static final String REGULAR					= 'Regular';
    private static final String REJECTIONREASON			= 'Test Rejection Reason';
    private static final String CUSTOMERREADING			= 'Customer Reading';
    private static final String ACTUAL					= 'Actual';
    private static final String DEVICEREFERENCE			= 'Test Device Reference';
    private static final String BILLABLE				= 'Billable';
    private static final String OVERRIDELABEL			= 'Override';    
    private static final String ACCEPTLABEL				= 'Accept';   
    private static final String READFREQUENCY_M 		= 'Monthly'; 
    private static final String READTIMETABLE_NAME	    = 'RTT1';
    private static final Integer DAILYUSAGE_START 		= 6;
    private static final Integer DAILYUSAGE_END 		= 500;
    private static final Integer ACCEPTPERCENTAGE_BELOW = 20;
    private static final Integer ACCEPTPERCENTAGE_ABOVE = 70;  
    private static final String FOUR_WEEKLY 			= 'Four weekly';

    /******************************************************************************
    @author        Ankit Gangwani
    @date          05 June 2018 
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
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);

        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SPUTNAME);
        Database.insert(objSupplyPointUsageType);
            
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);
        Database.insert(objDepot);
        
         // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE_NAME, READFREQUENCY_M);        
        Database.insert(objReadTimetable);
        
        // Create ReadTimetableThresholds Record       
        ReadTimetableThresholds__c objReadTimetableThresholds = GlUt_FactoryData_Test.createReadTimetableThresholds(objReadTimetable, DAILYUSAGE_START, DAILYUSAGE_END, ACCEPTPERCENTAGE_BELOW, ACCEPTPERCENTAGE_ABOVE);        
        Database.insert(objReadTimetableThresholds);
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot,objReadTimetable) ; 
        objBook.ReadFrequency__c = FOUR_WEEKLY;
        objBook.BudgetResetMonth__c = 'April;September;November';
        Database.insert(objBook);
        
        // Create Supply Point Record
        SupplyPoint__c objSP = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSP.Depot__c = objDepot.Id;
        objSP.Measured__c = True; // AT-3174 
        objSP.Book__c = objBook.Id;
        Database.insert(objSP);
        
        // Create Device Size Record
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE_NAME);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, DEVICE_MANUFACTURER, DEVICE_UOFMEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice.SerialNo__c = DEVICE_SERIAL_NUMBER;
        Database.insert(objDevice);
        
        // Create Read Period Record
        ReadPeriod__c objReadPeriod = new ReadPeriod__c();
        objReadPeriod.ReadStart__c = System.today();
        objReadPeriod.ReadEnd__c = System.today() + 1;
        Database.insert(objReadPeriod);
        
        // Create Reading Mode Record
        ReadingMode__c objReadingMode = new ReadingMode__c();
        objReadingMode.ReadPeriod__c = objReadPeriod.Id;
        objReadingMode.Depot__c = objDepot.Id;
        Database.insert(objReadingMode);
        
        // Create Reading Upload Record
        ReadingUpload__c objReadingUpload = new ReadingUpload__c();
        objReadingUpload.Billable__c = true;
        objReadingUpload.ReadingType__c = REGULAR;
        objReadingUpload.ReadPeriodId__c = objReadPeriod.Id;
        objReadingUpload.RejectionReason__c = REJECTIONREASON;
        objReadingUpload.ReadSource__c = CUSTOMERREADING;
        objReadingUpload.ReadingMethod__c = ACTUAL;
        objReadingUpload.ReadingValue__c = '730';  
        objReadingUpload.ReadingDate__c = System.today();
        objReadingUpload.DeviceReference__c = DEVICEREFERENCE;
        objReadingUpload.Manufacturer__c = DEVICE_MANUFACTURER;
        objReadingUpload.SerialNumber__c = DEVICE_SERIAL_NUMBER;
        Database.insert(objReadingUpload);
        
        // Create Reading Record
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ActualDeviceReading__c = '10';
        objReading1.ReadingDate__c = System.today() - 50;
        objReading1.BillableType__c = BILLABLE;
        Database.insert(objReading1);
        
         // Create Reading Record
        Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading2.ActualDeviceReading__c = '20';
        objReading2.ReadingDate__c = System.today() - 40;
        objReading2.BillableType__c = BILLABLE;
        Database.insert(objReading2);
        
         // Create Reading Record
        Reading__c objReading3 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading3.ActualDeviceReading__c = '30';
        objReading3.ReadingDate__c = System.today() - 30;
        objReading3.BillableType__c = BILLABLE;
        Database.insert(objReading3);
        
         // Create Reading Record
        Reading__c objReading4 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading4.ActualDeviceReading__c = '40';
        objReading4.ReadingDate__c = System.today() - 20;
        objReading4.BillableType__c = BILLABLE;
        Database.insert(objReading4);
        
        // Create SPD
        SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSP);
        Database.insert(objSPD);
        
        // Create ADU
        AverageDailyUsage__c objADU = GlUt_FactoryData_Test.createAvgDailyUses(objSPD);
        objADU.StartDate__c = system.today() - 50;
        Database.insert(objADU);
        
        
            
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveReadingUploadFields(){
        
        List<List<GLAp_FieldProps>> fieldPropList = new List<List<GLAp_FieldProps>>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            fieldPropList = LoAp_ManageReadingImportCtrlr.retrieveReadingUploadFields();
            Test.stoptest();
            System.assert(fieldPropList.size() > 0);
        }
    }  
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void saveOverride_Positive(){
        
        String isSuccess ;
        Boolean highReading = true;
        List<SupplyPoint__c> spList = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c LIMIT 1];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<SupplyPointDevice__c> supplyPointDeviceList  = [SELECT Id FROM SupplyPointDevice__c LIMIT 1];
        
        
        List<ReadingUpload__c> readingUploadList = [SELECT Id,
                                                    SerialNumber__c,
                                                    Manufacturer__c,
                                                    ReadPeriodId__c,
                                                    DeviceReference__c,
                                                    ReadingDate__c,
                                                    ReadingValue__c ,
                                                    ReadingMethod__c,
                                                    ReadSource__c,
                                                    RejectionReason__c,
                                                    ReadingType__c,
                                                    Billable__c
                                                    FROM ReadingUpload__c LIMIT 1];        
        
        System.runAs(objUser[0]){
            Test.starttest();
            isSuccess = LoAp_ManageReadingImportCtrlr.saveReadingRecord(JSON.serialize(readingUploadList[0]), OVERRIDE_VALUE, deviceList[0].Id, readingUploadList[0].Id, spList[0].Id, OVERRIDELABEL , highReading ,  supplyPointDeviceList[0].Id, true);
            Test.stoptest();    
            System.assertEquals(isSuccess, GlUt_Constants.NOERROR);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void saveOverride_Incorrect_ReadingUploadId(){
        
        String isSuccess ;
        Boolean highReading = false;
        List<SupplyPointDevice__c> supplyPointDeviceList  = [SELECT Id FROM SupplyPointDevice__c LIMIT 1];
        List<SupplyPoint__c> spList = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c LIMIT 1];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<ReadingUpload__c> readingUploadList = [SELECT Id,
                                                    SerialNumber__c,
                                                    Manufacturer__c,
                                                    ReadPeriodId__c,
                                                    DeviceReference__c,
                                                    ReadingDate__c,
                                                    ReadingValue__c ,
                                                    ReadingMethod__c,
                                                    ReadSource__c,
                                                    RejectionReason__c,
                                                    ReadingType__c,
                                                    Billable__c
                                                    FROM ReadingUpload__c LIMIT 1];        
        
        System.runAs(objUser[0]){            
            try{
                Test.starttest();
                isSuccess = LoAp_ManageReadingImportCtrlr.saveReadingRecord(JSON.serialize(readingUploadList[0]), OVERRIDE_VALUE, deviceList[0].Id, NULL, spList[0].Id, OVERRIDELABEL,highReading,  supplyPointDeviceList[0].Id, true); 
                Test.stoptest();    
            }catch(Exception ex) {
                isSuccess = GlUt_Constants.ERROR;
                system.debug('exception caught in test context:: ' + ex);                                
            }
            System.assertEquals(isSuccess, GlUt_Constants.ERROR);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void saveOverride_Negative(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Boolean isException = false;
        String isSuccess ;
        Boolean highReading = true;
        List<SupplyPointDevice__c> supplyPointDeviceList  = [SELECT Id FROM SupplyPointDevice__c LIMIT 1];
        List<SupplyPoint__c> spList = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c LIMIT 1];
        List<ReadingUpload__c> readingUploadList = [SELECT Id,
                                                    SerialNumber__c,
                                                    Manufacturer__c,
                                                    ReadPeriodId__c,
                                                    DeviceReference__c,
                                                    ReadingDate__c,
                                                    ReadingValue__c ,
                                                    ReadingMethod__c,
                                                    ReadSource__c,
                                                    RejectionReason__c,
                                                    ReadingType__c,
                                                    Billable__c
                                                    FROM ReadingUpload__c LIMIT 1]; 
        System.runAs(objUser[0]){
            try{
                Test.startTest();
                isSuccess = LoAp_ManageReadingImportCtrlr.saveReadingRecord(JSON.serialize(readingUploadList[0]), 'test', deviceList[0].Id, null, spList[0].Id, OVERRIDELABEL , highReading,  supplyPointDeviceList[0].Id, true);     
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }        
        System.assertEquals(isException, true);
       
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void saveAccept_Positive(){
        
        String isSuccess ;
        Boolean highReading = true;
        List<SupplyPointDevice__c> supplyPointDeviceList  = [SELECT Id FROM SupplyPointDevice__c LIMIT 1];
        List<SupplyPoint__c> spList = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c LIMIT 1];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<ReadingUpload__c> readingUploadList = [SELECT Id,
                                                    SerialNumber__c,
                                                    Manufacturer__c,
                                                    ReadPeriodId__c,
                                                    DeviceReference__c,
                                                    ReadingDate__c,
                                                    ReadingValue__c,
                                                    ReadingMethod__c,
                                                    ReadSource__c,
                                                    RejectionReason__c,
                                                    ReadingType__c,
                                                    Billable__c
                                                    FROM ReadingUpload__c LIMIT 1];        
        
        System.runAs(objUser[0]){
            Test.starttest();
            isSuccess = LoAp_ManageReadingImportCtrlr.saveReadingRecord(JSON.serialize(readingUploadList[0]), OVERRIDE_VALUE, deviceList[0].Id, readingUploadList[0].Id, spList[0].Id, ACCEPTLABEL ,highReading , supplyPointDeviceList[0].Id, true);   
            Test.stoptest();    
            System.assertEquals(isSuccess, GlUt_Constants.NOERROR);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void saveAmendPrevious_Positive(){
        Boolean highReading = true;
        Map<String,String> mapOfAmend = new Map<String,String>();
        List<SupplyPoint__c> spList = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c LIMIT 1];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<SupplyPointDevice__c> supplyPointDeviceList  = [SELECT Id FROM SupplyPointDevice__c LIMIT 1];
        List<ReadingUpload__c> readingUploadList = [SELECT Id,
                                                    SerialNumber__c,
                                                    Manufacturer__c,
                                                    ReadPeriodId__c,
                                                    DeviceReference__c,
                                                    ReadingDate__c,
                                                    ReadingValue__c ,
                                                    ReadingMethod__c,
                                                    ReadSource__c,
                                                    RejectionReason__c,
                                                    ReadingType__c,
                                                    Billable__c
                                                    FROM ReadingUpload__c LIMIT 1]; 
        
        List<Reading__c> objReading = [SELECT Id, ReadingDate__c, ActualDeviceReading__c FROM Reading__c WHERE ActualDeviceReading__c = '0000000010'];
        
        System.runAs(objUser[0]){
            Test.starttest();
            mapOfAmend = LoAp_ManageReadingImportCtrlr.saveAmendPrevious(JSON.serialize(readingUploadList[0]), 
                                                                         OVERRIDE_VALUE, 
                                                                         deviceList[0].Id, 
                                                                         readingUploadList[0].Id, 
                                                                         spList[0].Id, 
                                                                         GlUt_APIConstantsReading.AMENDEDBYREADINGAPINAME, 
                                                                         JSON.serialize(objReading[0]),
                                                                         highReading,
                                                                         supplyPointDeviceList[0].Id,
                                                                         true);
            Test.stoptest();    
            System.assert(mapOfAmend.size() > 0);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void saveRequestRead_Positive(){
        
        Boolean isSuccess = false;
        List<SupplyPoint__c> spList = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        System.runAs(objUser[0]){
            Test.starttest();
            isSuccess = LoAp_ManageReadingImportCtrlr.saveRequestRead(String.valueOf(System.today()), spList[0].Id);
            Test.stoptest();    
            System.assertEquals(isSuccess, true);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void saveRequestRead_No_SP(){
        
        Boolean isSuccess = false;
        List<SupplyPoint__c> spList = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        System.runAs(objUser[0]){
            Test.starttest();
            isSuccess = LoAp_ManageReadingImportCtrlr.saveRequestRead(String.valueOf('test'), null);
            Test.stoptest();    
            System.assertEquals(isSuccess, false);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void getReadingUploadDetails_Positive(){
        Map<String,String> getReadingUploadDetails = new Map<String,String>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<ReadingUpload__c> readingUploadList = [SELECT Id,
                                                    SerialNumber__c,
                                                    Manufacturer__c,
                                                    ReadPeriodId__c,
                                                    DeviceReference__c,
                                                    ReadingDate__c,
                                                    ReadingValue__c ,
                                                    ReadingMethod__c,
                                                    ReadSource__c,
                                                    RejectionReason__c,
                                                    ReadingType__c,
                                                    Billable__c
                                                    FROM ReadingUpload__c LIMIT 1]; 
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                getReadingUploadDetails = LoAp_ManageReadingImportCtrlr.getReadingUploadDetails(readingUploadList[0].Id);
                Test.stoptest();    
                System.assert(getReadingUploadDetails.size() > 0);
            } catch(Exception ex) {}
        }
    } 
}