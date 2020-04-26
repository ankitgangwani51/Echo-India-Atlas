/******************************************************************************
@author:      Echo: Swati Mathur 
@date:        07-06-2018  
@description: Test Class for LoBt_ExportRequestedReadings
*******************************************************************************/
@isTest
public class LoBt_ExportRequestedReadings_Test {
    
	private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'TestFirstName';
    private static final String USER_LNAME = 'TestLastName';
    private static final String FILE_NAME = 'InputFile.csv';
    private static final String BATCH_CLASS_NAME = 'LoBt_ExportRequestedReadings';
    private static final Boolean IS_USER_NOTIFY = true;
    private static final String USER_NOTIFY = 'abc@echo-ms.com';
    private static final String CONTENT_TYPE = 'csv'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Kent';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME1 = 'First Device';
    private static final String DEVICE_NAME2 = 'Second Device';
    private static final String RELATED_LIST = 'RelatedListDetails';
    private static final String SUPPLYPOINTUSAGE = 'Supply Point usages';
    private static final String ZIPCODE = 'WS2 8DE';
    private static final String MEASURED = 'Yes';
    private static final String MONTHLY = 'Monthly';
    private static final String AREA_NAME = 'Test Area';
	private static final String DEPOT_NAME = 'Test Depot'; 
    private static final String READTIMETABLE = 'Read TimeTable';
    private static final Integer DAILYUSAGE_START = 6;
    private static final Integer DAILYUSAGE_END = 20;
    private static final Integer ACCEPTPERCENTAGE_BELOW = 20;
    private static final Integer ACCEPTPERCENTAGE_ABOVE = 70;
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLE_SERVICES ='TestAvailableService';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String ACCOUNT_NAME = 'TestAccount'; 
    private static String CONTRACT_NAME ='TestContract';
    private static String READFREQ = 'Monthly';
    private static final String BRQ_STATUS_INIT = 'Initialised';
    private static final String BRQ_STATUS_EXPORTED = 'Exported';    
    private static final String HIGH = 'High';
    private static final String EXPORT_OPERATION = 'Export';
    private static final String STATUS_NEW = 'New';
    
    
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        08-06-2018   
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME; 
        objUser.USERNAME = USER_NOTIFY;
        Database.insert(objUser);		
       
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);
		objDepot .Area__c = objArea.Id;        
        Database.insert(objDepot);
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE,MONTHLY);        
        Database.insert(objReadTimetable);        
        
        // Create ReadTimetableThresholds Record       
        ReadTimetableThresholds__c objReadTimetableThresholds = GlUt_FactoryData_Test.createReadTimetableThresholds(objReadTimetable, DAILYUSAGE_START, DAILYUSAGE_END, ACCEPTPERCENTAGE_BELOW, ACCEPTPERCENTAGE_ABOVE);        
        Database.insert(objReadTimetableThresholds);
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable);      
        objBook.ReadFrequency__c = MONTHLY;
        Database.insert(objBook);
        
        // Create ReadPeriod Record 
        ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimetable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        Database.insert(objReadPeriod);            
            
        // Create ReadingMode Record
        ReadingMode__c objReadingMode = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);
        objReadingMode.EstimateDate__c =  date.valueOf('2018-05-01');
        Database.insert(objReadingMode);

        //Create Location record
        List<Location__c> lstLocation = new List<Location__c>();
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        lstLocation.add(objLocation);    
        
        Location__c objLocation2 = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        lstLocation.add(objLocation2);
        Database.insert(lstLocation);
        
        // Create SupplyPointUsageType Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SUPPLYPOINTUSAGE);        
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        List<SupplyPoint__c> lstSupplyPoint = new List<SupplyPoint__c>();
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation,objSupplyPointUsageType);
		objSupplyPoint.Measured__c = True; // AT-3174 
  
        objSupplyPoint.Book__c = objBook.Id;
        objSupplyPoint.Depot__c = objDepot.Id;  
        lstSupplyPoint.add(objSupplyPoint);
        
        SupplyPoint__c objSupplyPoint2 = GlUt_FactoryData_Test.createSupplyPoint(objLocation2,objSupplyPointUsageType);
		objSupplyPoint2.Measured__c = True; // AT-3174 
 
        objSupplyPoint2.Book__c = objBook.Id;
        objSupplyPoint2.Depot__c = objDepot.Id;  
        lstSupplyPoint.add(objSupplyPoint2);
        Database.insert(lstSupplyPoint);         
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        List<Device__c> lstDevice = new List<Device__c>();
        Device__c objDevice1 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME1, objDeviceType);  
        objDevice1.SerialNo__c = '3105001';
        lstDevice.add(objDevice1);        
       
        Device__c objDevice2 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME2, objDeviceType);  
        objDevice2.SerialNo__c = '3105002';
        lstDevice.add(objDevice2);
        Database.insert(lstDevice);
        
        // Create SupplyPointDevice Record
        List<SupplyPointDevice__c> lstSPD = new List<SupplyPointDevice__c>();
        SupplyPointDevice__c objSupplyPointDevice1 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice1,objSupplyPoint); 
        objSupplyPointDevice1.InstallationDate__c = Date.valueOf('2018-01-01');        
        lstSPD.add(objSupplyPointDevice1); 
       
        SupplyPointDevice__c objSupplyPointDevice2 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice2,objSupplyPoint2); 
        objSupplyPointDevice2.InstallationDate__c = Date.valueOf('2018-01-01');       
        lstSPD.add(objSupplyPointDevice2);
        Database.insert(lstSPD);
        
        // Create Reading Record
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice1);
        objReading1.ActualDeviceReading__c = '230'; 
        objReading1.ReadingMethod__c = 'Actual';
        objReading1.ReadingDate__c = date.valueOf('2018-02-02');
        Database.insert(objReading1);
        
        //create ADU record
        AverageDailyUsage__c objAverageDailyUse = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice1); 
        objAverageDailyUse.AverageDailyUsage__c=7;
        objAverageDailyUse.StartDate__c = Date.valueOf('2018-03-01');
        objAverageDailyUse.EndDate__c = Date.valueOf('2018-04-28');
        Database.insert(objAverageDailyUse);          
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
		
		Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLE_SERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME,objAccount);
		Database.insert(objContract);
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading1,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        //create Reading Request record 
        List<ReadingRequest__c> lstRR = new List<ReadingRequest__c>();
        ReadingRequest__c objReadingRequest1 = GlUt_FactoryData_Test.createReadingRequest(objSupplyPoint);
        objReadingRequest1.Status__c = STATUS_NEW;
        objReadingRequest1.ReadbyDate__c = Date.valueOf('2018-03-15');
        lstRR.add(objReadingRequest1);
        
        ReadingRequest__c objReadingRequest2 = GlUt_FactoryData_Test.createReadingRequest(objSupplyPoint);
        objReadingRequest2.SupplyPoint__c = null;
        objReadingRequest2.Status__c = STATUS_NEW;
        objReadingRequest2.ReadbyDate__c = Date.valueOf('2018-03-15');
        lstRR.add(objReadingRequest2);
        Database.insert(lstRR);
        
        // Create Batch Process Record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS_NAME);
        objBatchProcess.Operation__c = EXPORT_OPERATION;
        objBatchProcess.BatchSize__c = 100;
        Database.insert(objBatchProcess);
    }  
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        08-06-2018   
	@description: Test Method 
	*******************************************************************************/
    static testmethod void runBatchClass(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USER_NOTIFY LIMIT 1];
        BatchProcess__c objBatchProcess = [SELECT Id,Name 
                                           FROM BatchProcess__c LIMIT 1];
        List<ReadingRequest__c> lstRequest =[Select Id, Name, CreatedDate From ReadingRequest__c LIMIT 5];
        system.debug('reding request=='+lstRequest);
        System.runAs(objUser){
			BatchRequestQueue__c objBatchReqQueue = new BatchRequestQueue__c();
            objBatchReqQueue.BatchProcess__c = objBatchProcess.Id;
            objBatchReqQueue.Priority__c = HIGH;
            objBatchReqQueue.SendEmailNotification__c = True;
            objBatchReqQueue.Status__c = BRQ_STATUS_INIT;
            objBatchReqQueue.NotificationUser__c = UserInfo.getUserId();                      
            Insert objBatchReqQueue;
            Test.startTest();           
            LoBt_ExportRequestedReadings obj = new LoBt_ExportRequestedReadings();
            obj.Initialise(objBatchReqQueue);
            DataBase.executeBatch(obj);            
            Test.stopTest(); 
            ReadingRequest__c objReadingRequest = [SELECT Id,Status__c FROM ReadingRequest__c LIMIT 1];
            System.assertEquals(BRQ_STATUS_EXPORTED, objReadingRequest.Status__c);
            
        } 
    }
}