/******************************************************************************
@author:      Echo: Swati Mathur 
@date:        11-06-2018  
@description: Test Class for LoBt_SweepUpEstimatesHelper
*******************************************************************************/
@isTest
public class LoBt_SweepUpEstimatesHelper_Test {
    
	private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'TestFirstName';
    private static final String USER_LNAME = 'TestLastName';    
    private static final String BATCH_CLASS_NAME = 'LoBt_SweepUpEstimates';
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
    private static final String READTIMETABLE1 = 'Read TimeTable 2';
    private static final String READTIMETABLE2 = 'Read TimeTable 3';
    private static final Integer DAILYUSAGE_START = 6;
    private static final Integer DAILYUSAGE_END = 20;
    private static final Integer ACCEPTPERCENTAGE_BELOW = 20;
    private static final Integer ACCEPTPERCENTAGE_ABOVE = 70;
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    private static final String BRQ_STATUS_INIT = 'Initialised';
    private static final String BRQ_STATUS_COMPLETE= 'Completed';
        
    /******************************************************************************
	@author:      Echo: Swati
	@date:        11-06-2018  
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
        List<ReadTimetable__c> lstReadTimetable = new List<ReadTimetable__c>();
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE,MONTHLY);        
        lstReadTimetable.add(objReadTimetable);    
        
        ReadTimetable__c objReadTimetable1 = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE1,MONTHLY);        
        lstReadTimetable.add(objReadTimetable1);    
        
        ReadTimetable__c objReadTimetable2 = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE2,MONTHLY);        
        lstReadTimetable.add(objReadTimetable2);
        Database.insert(lstReadTimetable);    
        
        // Create ReadTimetableThresholds Record       
        ReadTimetableThresholds__c objReadTimetableThresholds = GlUt_FactoryData_Test.createReadTimetableThresholds(objReadTimetable, DAILYUSAGE_START, DAILYUSAGE_END, ACCEPTPERCENTAGE_BELOW, ACCEPTPERCENTAGE_ABOVE);        
        Database.insert(objReadTimetableThresholds);
        
        // Create Book Record
        List<Book__c> lstBook = new List<Book__c>();
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable);    
        objBook.ReadFrequency__c = MONTHLY;
        lstBook.add(objBook);
        
        Book__c objBook1 = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable1); 
        objBook1.ReadFrequency__c = MONTHLY;
        lstBook.add(objBook1);
        
        Book__c objBook2 = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable2);   
        objBook2.ReadFrequency__c = MONTHLY;
        lstBook.add(objBook2);
        Database.insert(lstBook);
        
        // Create ReadPeriod Record
        List<ReadPeriod__c> lstReadPeriod = new List<ReadPeriod__c>(); 
        ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimetable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        lstReadPeriod.add(objReadPeriod); 
         
        ReadPeriod__c objReadPeriod1 = GlUt_FactoryData_Test.createReadPeriod(objReadTimetable1, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        lstReadPeriod.add(objReadPeriod1); 
        
        ReadPeriod__c objReadPeriod2 = GlUt_FactoryData_Test.createReadPeriod(objReadTimetable2, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        lstReadPeriod.add(objReadPeriod2);
        Database.insert(lstReadPeriod);
            
        // Create ReadingMode Record
        List<ReadingMode__c> lstReadingMode = new List<ReadingMode__c>();
        ReadingMode__c objReadingMode = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);
        objReadingMode.EstimateDate__c =  date.valueOf('2018-05-01');
        lstReadingMode.add(objReadingMode);
        
        ReadingMode__c objReadingMode1 = GlUt_FactoryData_Test.createReadingMode(objReadPeriod1, objBook1, objDepot, objArea);
        objReadingMode1.EstimateDate__c =  date.valueOf('2018-05-02');
        lstReadingMode.add(objReadingMode1);
        
        ReadingMode__c objReadingMode2 = GlUt_FactoryData_Test.createReadingMode(objReadPeriod2, objBook2, objDepot, objArea);
        objReadingMode2.EstimateDate__c =  date.valueOf('2018-05-03');
        lstReadingMode.add(objReadingMode2);
        Database.insert(lstReadingMode);
        
        // Create Schedule Read Record 
        ScheduledRead__c objScheduledRead = GlUt_FactoryData_Test.createScheduledRead(objReadPeriod2);
        Database.insert(objScheduledRead);

        //Create Location record
        List<Location__c> lstLocation = new List<Location__c>();
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        lstLocation.add(objLocation);
        
        Location__c objLocationNew = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        lstLocation.add(objLocationNew);
        
        Location__c objLocationSchedRead = GlUt_FactoryData_Test.createLocation(ZIPCODE); 
        lstLocation.add(objLocationSchedRead);
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
        
        SupplyPoint__c objSupplyPointNew = GlUt_FactoryData_Test.createSupplyPoint(objLocationSchedRead,objSupplyPointUsageType);
		objSupplyPointNew.Measured__c = True; // AT-3174 

        objSupplyPointNew.Book__c = objBook1.Id;
        objSupplyPointNew.Depot__c = objDepot.Id;  
        lstSupplyPoint.add(objSupplyPointNew);        
       
        SupplyPoint__c objSupplyPointSchedRead = GlUt_FactoryData_Test.createSupplyPoint(objLocationNew,objSupplyPointUsageType);
		objSupplyPointSchedRead.Measured__c = True; // AT-3174 
 
        objSupplyPointSchedRead.Book__c = objBook2.Id;
        objSupplyPointSchedRead.Depot__c = objDepot.Id;
        lstSupplyPoint.add(objSupplyPointSchedRead);
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
        objDevice1.Digit__c = 3;
        lstDevice.add(objDevice1);
        
        Device__c objDeviceNew = GlUt_FactoryData_Test.createDevice(DEVICE_NAME2, objDeviceType);  
        objDeviceNew.SerialNo__c = '3105003';
        lstDevice.add(objDeviceNew); 
        Database.insert(lstDevice);
        
        // Create SupplyPointDevice Record
        List<SupplyPointDevice__c> lstSPD = new List<SupplyPointDevice__c>();
        SupplyPointDevice__c objSupplyPointDevice1 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice1,objSupplyPoint); 
        objSupplyPointDevice1.InstallationDate__c = Date.valueOf('2018-01-01');        
        lstSPD.add(objSupplyPointDevice1);        

        SupplyPointDevice__c objSupplyPointDeviceNew = GlUt_FactoryData_Test.createSupplyPointDevices(objDeviceNew,objSupplyPointNew); 
        objSupplyPointDeviceNew.InstallationDate__c = Date.valueOf('2018-01-01');       
        lstSPD.add(objSupplyPointDeviceNew);
        Database.insert(lstSPD);        
                
        // Create Reading Record
        List<Reading__c> lstReading = new List<Reading__c>();
	    Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice1);
        objReading1.ActualDeviceReading__c = '230'; 
        objReading1.ReadingDate__c = date.valueOf('2018-02-02');
        lstReading.add(objReading1);
        
        Reading__c objReadingDevice3 = GlUt_FactoryData_Test.createReading(objDeviceNew);
        objReadingDevice3.ActualDeviceReading__c = '230'; 
        objReadingDevice3.ReadingDate__c = date.valueOf('2018-02-02');
        lstReading.add(objReadingDevice3);
        Database.insert(lstReading);     
        
        //create ADU record
        List<AverageDailyUsage__c> lstADU = new List<AverageDailyUsage__c>();
        AverageDailyUsage__c objAverageDailyUse = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice1); 
        objAverageDailyUse.AverageDailyUsage__c=900;
        objAverageDailyUse.StartDate__c = Date.valueOf('2018-03-28');
        objAverageDailyUse.EndDate__c = Date.valueOf('2018-05-05');
        lstADU.add(objAverageDailyUse);         
        
        AverageDailyUsage__c objAverageDailyUse1 = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDeviceNew); 
        objAverageDailyUse1.AverageDailyUsage__c= 7;
        objAverageDailyUse1.StartDate__c = Date.valueOf('2018-03-01');
        objAverageDailyUse1.EndDate__c = Date.valueOf('2018-05-05');
        lstADU.add(objAverageDailyUse1);
        Database.insert(lstADU); 
        
        // Create Batch Process Record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS_NAME);
        objBatchProcess.Operation__c = 'Export';
        objBatchProcess.BatchSize__c = 100;
        Database.insert(objBatchProcess);
        
        //create BatchRequestQueue record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Status__c = BRQ_STATUS_INIT;
        Database.insert(objBatchRequestQueue);
    }
    
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        11-06-2018   
	@description: Test Method for scheduledSweepUp Method
	*******************************************************************************/
    static testmethod void scheduledSweepUp_positive(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USER_NOTIFY LIMIT 1];
        
        System.runAs(objUser){			
            Test.startTest();           
            List<Id> lstReadPeriodIds = LoBt_SweepUpEstimatesHelper.scheduledSweepUp();
            Test.stopTest();
            
            System.assertNotEquals(lstReadPeriodIds, null);
        } 
    }
    
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        11-06-2018   
	@description: Test Method for updateBRQ Method
	*******************************************************************************/
    static testmethod void updateBRQ_positive(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME = :USER_NOTIFY LIMIT 1];
        
        list<BatchRequestQueue__c> listObjBRQ = [SELECT Id,Name,Status__c 
                                       FROM BatchRequestQueue__c 
                                       WHERE Status__c = :BRQ_STATUS_INIT LIMIT 1];	//Checkmarx: Bulkify
        
        System.runAs(objUser){			
            Test.startTest();       
            list<BatchRequestQueue__c> listBRQ = LoBt_SweepUpEstimatesHelper.updateBRQ(listObjBRQ, BRQ_STATUS_COMPLETE);
            Test.stopTest();
            for(BatchRequestQueue__c brq : listBRQ) { 	//Checkmarx: Bulkify
                System.assertEquals(brq.Status__c, BRQ_STATUS_COMPLETE); 
            }
        }
    }    
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        11-06-2018   
	@description: Test Method for updateBRQ Method
	*******************************************************************************/
    static testmethod void createBatchError_positive(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME = :USER_NOTIFY LIMIT 1];
        
        BatchRequestQueue__c objBRQ = [SELECT Id,Name 
                                       FROM BatchRequestQueue__c LIMIT 1];
        
        System.runAs(objUser){			
            Test.startTest();           
            BatchError__c objBatchError = LoBt_SweepUpEstimatesHelper.createBatchError(objBRQ);
            Test.stopTest();
            
            System.assertNotEquals(objBatchError, null);
        } 
    }
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        11-06-2018   
	@description: Test Method for updateBRQ Method
	*******************************************************************************/
    static testmethod void updateReadPeriods_positive(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME = :USER_NOTIFY LIMIT 1];
        
        List<ReadPeriod__c> lstReadPeriods = [SELECT Id,Name FROM ReadPeriod__c];
        Set<Id> setPeriodsToEstimate = new Set<Id>();
        for(ReadPeriod__c rp : lstReadPeriods){
            setPeriodsToEstimate.add(rp.Id);
        }
                
        System.runAs(objUser){			
            Test.startTest();           
            List<ReadPeriod__c> lstUpdatedReadPeriods = LoBt_SweepUpEstimatesHelper.updateReadPeriods(setPeriodsToEstimate);
            Test.stopTest();
            
            System.assertEquals(lstUpdatedReadPeriods[0].SweepUpComplete__c, true);
        } 
    }
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        11-06-2018   
	@description: Test Method for executeMainLogic Method
	*******************************************************************************/
    static testmethod void executeMainLogic_positive(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME = :USER_NOTIFY LIMIT 1]; 
        
        Set<Id> setPeriodsToEstimate = new Set<Id>();
        List<Id> lstReadPeriodIds = LoBt_SweepUpEstimatesHelper.scheduledSweepUp();
        setPeriodsToEstimate.addAll(lstReadPeriodIds);
        
        List<Id> lstBookIds = new List<Id>();
        List<Book__c> lstBooks = [SELECT Id,Name
                                  FROM Book__c];
        for(Book__c b :lstBooks){
            lstBookIds.add(b.Id);
        }        
        List<SupplyPoint__c> SPsToEstimate = [SELECT Id,
                                              Name,
                                              Book__c,
                                              Book__r.ReadTimetable__c,
                                              ExcludeFromEstimation__c 
                                              FROM SupplyPoint__c
                                              WHERE Book__c IN : lstBookIds];
        
        Map<Id, List<SupplyPoint__c>> BookId2SupplyPointListMap = new Map<Id, List<SupplyPoint__c>>();
        LoBt_SweepUpEstimatesHelper.ContainerWrapper wrapper = new LoBt_SweepUpEstimatesHelper.ContainerWrapper();
        
        System.runAs(objUser){
            Test.startTest(); 
            wrapper = LoBt_SweepUpEstimatesHelper.executeMainLogic(SPsToEstimate, setPeriodsToEstimate, lstBookIds, BookId2SupplyPointListMap);
            Test.stopTest();
            
            System.assertNotEquals(wrapper.readingsToInsert, null);           
        } 
    }
        
}