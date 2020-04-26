/******************************************************************************
@author:      Echo: Neha 
@date:        05-06-2018  
@description: Test Class for LoAp_NewReadingImportCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class LoAp_NewReadingImportCtrlr_Test {
    
	private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'neha';
    private static final String USER_LNAME = 'rajput';
    private static final String FILE_NAME = 'InputFile.csv';
    private static final String BATCH_CLASS_NAME = 'LoBt_ReadingImport';
    private static final String INVALID_DATA_JOB = 'test_invalid_data';
    private static final Boolean IS_USER_NOTIFY = true;
    private static final String USER_NOTIFY = 'neharajput@echo-ms.com';
    private static final String CONTENT_TYPE = 'csv'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Kent';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME1 = 'First Device';
    private static final String DEVICE_NAME2 = 'Second Device'; 
    private static final String DEVICE_NAME3 = 'Third Device';
    private static final String DEVICE_NAME4 = 'Forth Device';
    private static final String DEVICE_NAME5 = 'Fifth Device';
    private static final String DEVICE_NAME6 = 'Sixth Device';
    private static final String DEVICE_NAME7 = 'Seventh Device';
    private static final String RELATED_LIST = 'RelatedListDetails';
    private static final String SUPPLYPOINTUSAGE = 'Supply Point usages';
    private static final String ZIPCODE = 'WS2 8DE';
    private static final Boolean MEASURED = true;   // AT-3174
    private static final String MONTHLY = 'Monthly';
    private static final String AREA_NAME = 'Test Area';
	private static final String DEPOT_NAME = 'Test Depot'; 
    private static final String READTIMETABLE = 'Read TimeTable';
    private static final Integer DAILYUSAGE_START = 6;
    private static final Integer DAILYUSAGE_END = 20;
    private static final Integer ACCEPTPERCENTAGE_BELOW = 20;
    private static final Integer ACCEPTPERCENTAGE_ABOVE = 70;    
    private static final String SKIPCODE1 = 'Forgot to take';
    private static final String SKIPCODE2 = 'estimated Reading';
    private static final String SKIPCODE3 = 'Actual Reading';
    private static final Boolean CREATE_ERROR = true;
    private static final Boolean CREATE_ESTIMATE = true; 
    private static final Boolean NO_ERROR = false;
    private static final Boolean NO_ESTIMATE = false;
    private static final String DEVICE_READING = '230';
    private static final String DEVICE_READING1 = '240';
    private static final String BATCH_OPERATION = 'Import';
    private static final String METER_SERIALNO1 = '3105001';
    private static final String METER_SERIALNO2 = '3105002';
    private static final String METER_SERIALNO3 = '3105003';
    private static final String METER_SERIALNO4 = '3105004';
    private static final String METER_SERIALNO5 = '3105005';
    private static final String METER_SERIALNO6 = '3105006';
    private static final String METER_SERIALNO7 = '3105007';
    private static final Date SP_INSTAL_DATE =  Date.valueOf('2018-01-01');
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    private static final Date ADU_STARTDATE = date.valueOf('2018-03-28');
    private static final Date ADU_ENDDATE = date.valueOf('2018-04-28');
    private static final Date ADU_STARTDATE1 = date.valueOf('2018-03-01');
    private static final Date ADU_ENDDATE1 = date.valueOf('2018-05-05');
    private static final String FILEDATA1 = 'a0T0Y000003W1lKUAS,2018-02-03,800,Customer Reading,Actual,,number of fields mismatch,Kent,51,15263,true,5550,,Potential of snakes,' + '\n' + 
                                        	'a0T0Y000003W1lKUAS,2018-25-25,400,Customer Reading,Actual,,date invalid,Kent,51,15263,false,5550,,,Potential of snakes,true' + '\n' + 
                                            'a0T0Y000003W1lKUAS,2018-25-25,400,Customer Reading,Actual,,walkorder invalid,Kent,51,15263,false,ABC,ABC,,Potential of snakes,true' + '\n' + 
                                            'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Billable value invalid,Kent,51,15263,ABC,555ABC,,,Potential of snakes,true' + '\n' + 
                                            'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Billable value invalid,Kent,51,15263,ABC,555,,,Potential of snakes,true' + '\n' +
                                            'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Billable value invalid,Kent,51,15263,true,555,,,Potential of snakes,true\r' + '\n' +
                                            'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Tripped invalid,Kent,51,15263,true,5550,,,Potential of snakes,abc' ; 
        
    /******************************************************************************
	@author:      Echo: Neha
	@date:        04-04-2018  
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
      
		// Create SkipCode Records
		List<SkipCode__c> skipcodeList = new List<SkipCode__c>();
		SkipCode__c objSkipCode1 = GlUt_FactoryData_Test.createSkipCode(SKIPCODE1, NO_ERROR, CREATE_ESTIMATE);  
        skipcodeList.add(objSkipCode1);
               
		SkipCode__c objSkipCode2 = GlUt_FactoryData_Test.createSkipCode(SKIPCODE2, NO_ERROR, CREATE_ESTIMATE);        
        skipcodeList.add(objSkipCode2);
        
		SkipCode__c objSkipCode3 = GlUt_FactoryData_Test.createSkipCode(SKIPCODE3, CREATE_ERROR, NO_ESTIMATE);        
        skipcodeList.add(objSkipCode3);
        Database.insert(skipcodeList);        
       
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
        Database.insert(objReadingMode);
        
        // Create SupplyPointUsageType Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SUPPLYPOINTUSAGE);        
        Database.insert(objSupplyPointUsageType);
        
        // Create Batch Process Record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS_NAME);
        objBatchProcess.Operation__c = BATCH_OPERATION;
        Database.insert(objBatchProcess);

        //Create Location Records
        List<Location__c> locationList = new List<Location__c>();
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);
		locationList.add(objLocation);
       
        Location__c objLocationNew = GlUt_FactoryData_Test.createLocation(ZIPCODE);  
        locationList.add(objLocationNew);
        
        Location__c objLocationNew2 = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        locationList.add(objLocationNew2);
        
        Location__c objLocationNew3 = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        locationList.add(objLocationNew3);
       
        Location__c objLocationNew4 = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        locationList.add(objLocationNew4);
        
        Location__c objLocationNew5 = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        locationList.add(objLocationNew5);
        
        Database.insert(locationList);
        
        // Create SupplyPoint Records
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(locationList[0],objSupplyPointUsageType);
		objSupplyPoint.Measured__c = True; // AT-3174 
        objSupplyPoint.Book__c = objBook.Id;
        objSupplyPoint.Depot__c = objDepot.Id;  
        supplyPointList.add(objSupplyPoint);
        
        SupplyPoint__c objSupplyPointNew = GlUt_FactoryData_Test.createSupplyPoint(locationList[1],objSupplyPointUsageType);
		objSupplyPointNew.Measured__c = MEASURED;  
   
        objSupplyPointNew.Book__c = objBook.Id;
        objSupplyPointNew.Depot__c = objDepot.Id;  
        supplyPointList.add(objSupplyPointNew);
        
        SupplyPoint__c objSupplyPointNew2 = GlUt_FactoryData_Test.createSupplyPoint(locationList[2],objSupplyPointUsageType);
		objSupplyPointNew2.Measured__c = MEASURED;

        objSupplyPointNew2.Book__c = objBook.Id;
        objSupplyPointNew2.Depot__c = objDepot.Id;  
        supplyPointList.add(objSupplyPointNew2);
       
        SupplyPoint__c objSupplyPointNew3 = GlUt_FactoryData_Test.createSupplyPoint(locationList[3],objSupplyPointUsageType);
		objSupplyPointNew3.Measured__c = MEASURED;
   
        objSupplyPointNew3.Book__c = objBook.Id;
        objSupplyPointNew3.Depot__c = objDepot.Id;  
        supplyPointList.add(objSupplyPointNew3);
        
        SupplyPoint__c objSupplyPointNew4 = GlUt_FactoryData_Test.createSupplyPoint(locationList[4],objSupplyPointUsageType);
		objSupplyPointNew4.Measured__c = MEASURED;

        objSupplyPointNew4.Book__c = objBook.Id;
        objSupplyPointNew4.Depot__c = objDepot.Id;  
        supplyPointList.add(objSupplyPointNew4);
        
        SupplyPoint__c objSupplyPointNew5 = GlUt_FactoryData_Test.createSupplyPoint(locationList[5],objSupplyPointUsageType);
		objSupplyPointNew5.Measured__c = MEASURED;
  
        objSupplyPointNew5.Book__c = objBook.Id;
        objSupplyPointNew5.Depot__c = objDepot.Id;  
        supplyPointList.add(objSupplyPointNew5);        
        Database.insert(supplyPointList);        
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Records
        List<Device__c> deviceList = new List<Device__c>();
        
        Device__c objDevice1 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME1, objDeviceType);  
        objDevice1.SerialNo__c = METER_SERIALNO1;
        deviceList.add(objDevice1);
        
        Device__c objDevice2 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME2, objDeviceType);  
        objDevice2.SerialNo__c = METER_SERIALNO2;
        deviceList.add(objDevice2); 
        
        Device__c objDevice3 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME3, objDeviceType);  
        objDevice3.SerialNo__c = METER_SERIALNO3;
        deviceList.add(objDevice3); 
        
        Device__c objDevice4 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME4, objDeviceType);  
        objDevice4.SerialNo__c = METER_SERIALNO4;
        deviceList.add(objDevice4); 

        Device__c objDevice5 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME5, objDeviceType);  
        objDevice5.SerialNo__c = METER_SERIALNO5;
        deviceList.add(objDevice5);
        
        Device__c objDevice6 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME6, objDeviceType);  
        objDevice6.SerialNo__c = METER_SERIALNO6;
        deviceList.add(objDevice6);
        
        Device__c objDevice7 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME7, objDeviceType);  
        objDevice7.SerialNo__c = METER_SERIALNO7;
        deviceList.add(objDevice7);
        
        Database.insert(deviceList);
        
        // Create SupplyPointDevice Records
        List<SupplyPointDevice__c> supplyPointDeviceList = new List<SupplyPointDevice__c>();
        
        SupplyPointDevice__c objSupplyPointDevice1 = GlUt_FactoryData_Test.createSupplyPointDevices(deviceList[0],supplyPointList[0]); 
        objSupplyPointDevice1.InstallationDate__c = SP_INSTAL_DATE;   //Date.valueOf('2018-01-01');
        objSupplyPointDevice1.RemovalDate__c = SP_INSTAL_DATE + 31;   // Date.valueOf('2018-02-01');
        supplyPointDeviceList.add(objSupplyPointDevice1);
       
        SupplyPointDevice__c objSupplyPointDevice2 = GlUt_FactoryData_Test.createSupplyPointDevices(deviceList[1],supplyPointList[0]); 
        objSupplyPointDevice2.InstallationDate__c = SP_INSTAL_DATE + 32; // Date.valueOf('2018-02-02');       
        supplyPointDeviceList.add(objSupplyPointDevice2);
        
        SupplyPointDevice__c objSupplyPointDevice3 = GlUt_FactoryData_Test.createSupplyPointDevices(deviceList[2],supplyPointList[1]); 
        objSupplyPointDevice3.InstallationDate__c = SP_INSTAL_DATE;     //Date.valueOf('2018-01-01');      
        supplyPointDeviceList.add(objSupplyPointDevice3);

        SupplyPointDevice__c objSupplyPointDevice4 = GlUt_FactoryData_Test.createSupplyPointDevices(deviceList[3],supplyPointList[2]); 
        objSupplyPointDevice4.InstallationDate__c = SP_INSTAL_DATE;   //Date.valueOf('2018-01-01');     
        supplyPointDeviceList.add(objSupplyPointDevice4);
        
        SupplyPointDevice__c objSupplyPointDevice5 = GlUt_FactoryData_Test.createSupplyPointDevices(deviceList[4],supplyPointList[3]); 
        objSupplyPointDevice5.InstallationDate__c = SP_INSTAL_DATE;       
        supplyPointDeviceList.add(objSupplyPointDevice5);
        
        SupplyPointDevice__c objSupplyPointDevice6 = GlUt_FactoryData_Test.createSupplyPointDevices(deviceList[5],supplyPointList[4]); 
        objSupplyPointDevice6.InstallationDate__c = SP_INSTAL_DATE;       
        supplyPointDeviceList.add(objSupplyPointDevice6);
       
        SupplyPointDevice__c objSupplyPointDevice7 = GlUt_FactoryData_Test.createSupplyPointDevices(deviceList[6],supplyPointList[5]); 
        objSupplyPointDevice7.InstallationDate__c = SP_INSTAL_DATE + 32; //Date.valueOf('2018-02-02');       
        supplyPointDeviceList.add(objSupplyPointDevice7);
        
        Database.insert(supplyPointDeviceList);
                
        // Create Reading Records
        List<Reading__c> readingList = new List<Reading__c>();
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(deviceList[1]);
        objReading1.ActualDeviceReading__c = DEVICE_READING; 
        objReading1.ReadingDate__c = SP_INSTAL_DATE + 32; //date.valueOf('2018-02-02');
        readingList.add(objReading1);
        
        Reading__c objReadingDevice3 = GlUt_FactoryData_Test.createReading(deviceList[2]);
        objReadingDevice3.ActualDeviceReading__c = DEVICE_READING; 
        objReadingDevice3.ReadingDate__c = SP_INSTAL_DATE + 32 ;  //date.valueOf('2018-02-02');
        readingList.add(objReadingDevice3);
        
        Reading__c objReadingDevice7 = GlUt_FactoryData_Test.createReading(deviceList[6]);
        objReadingDevice7.ActualDeviceReading__c = DEVICE_READING1; 
        objReadingDevice7.ReadingDate__c = SP_INSTAL_DATE + 32;  //date.valueOf('2018-02-02');
        readingList.add(objReadingDevice7);
        Database.insert(readingList);
                
        //create ADU records
        List<AverageDailyUsage__c> averageDailyUsageList = new List<AverageDailyUsage__c>();
        AverageDailyUsage__c objAverageDailyUse = GlUt_FactoryData_Test.createAvgDailyUses(supplyPointDeviceList[1]); 
        objAverageDailyUse.AverageDailyUsage__c=7;
        objAverageDailyUse.StartDate__c = ADU_STARTDATE;
        objAverageDailyUse.EndDate__c = ADU_ENDDATE;
        averageDailyUsageList.add(objAverageDailyUse); 
        
        AverageDailyUsage__c objAverageDailyUse1 = GlUt_FactoryData_Test.createAvgDailyUses(supplyPointDeviceList[6]); 
        objAverageDailyUse1.AverageDailyUsage__c= 7;
        objAverageDailyUse1.StartDate__c = ADU_STARTDATE1;  // Date.valueOf('2018-03-01');
        objAverageDailyUse1.EndDate__c = ADU_ENDDATE1;      // Date.valueOf('2018-05-05');
        averageDailyUsageList.add(objAverageDailyUse1);
        Database.insert(averageDailyUsageList); 
              
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void activeNotifyUserList_Positive(){
        setEnvironmentSettingData();
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USER_NOTIFY LIMIT 1];
        List<User> userList = new List<User>();
        System.runAs(objUser){
            Test.startTest();           
            userList = LoAp_NewReadingImportCtrlr.activeNotifyUserList();
            Test.stopTest();          
        }           
        System.assert (userList.size() > 0);
    }  
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void saveDetails_InvalidData(){
        setEnvironmentSettingData();
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USER_NOTIFY LIMIT 1];
                
        System.runAs(objUser){
            Test.startTest();
           /* String filedata = 'a0T0Y000003W1lKUAS,2018-02-03,800,Customer Reading,Actual,,number of fields mismatch,Kent,51,15263,true,5550,,' + '\n' + 
                              'a0T0Y000003W1lKUAS,2018-25-25,400,Customer Reading,Actual,,date invalid,Kent,51,15263,false,5550,,,true' + '\n' + 
                			  'a0T0Y000003W1lKUAS,2018-25-25,400,Customer Reading,Actual,,walkorder invalid,Kent,51,15263,false,ABC,ABC,,true' + '\n' + 
                              'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Billable value invalid,Kent,51,15263,ABC,555ABC,,,true' + '\n' + 
                			  'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Billable value invalid,Kent,51,15263,ABC,555,,,true' + '\n' +
                              'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Billable value invalid,Kent,51,15263,true,555,,,true\r' + '\n' +
                              'a0T0Y000003W1lKUAS,2018-03-03,800,Customer Reading,Actual,,Tripped invalid,Kent,51,15263,true,5550,,,abc' ; */
                      
            String filecontent = EncodingUtil.base64Encode(blob.valueOf(FILEDATA1));
            
            LoAp_NewReadingImportCtrlr.saveDetails(INVALID_DATA_JOB, IS_USER_NOTIFY, objUser.Id, FILE_NAME, filecontent, CONTENT_TYPE);
            Test.stopTest();   
            BatchRequestQueue__c objBRQ = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
            System.assert(objBRQ != null);
        } 
    }  
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void saveDetails_ReadingUploadData(){
        setEnvironmentSettingData();
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USER_NOTIFY LIMIT 1];
        ReadPeriod__c objReadPeriod = [SELECT Id FROM ReadPeriod__c LIMIT 1 ];
        ReadTimetable__c objReadTimetable = [SELECT Id FROM ReadTimetable__c LIMIT 1 ];
        System.runAs(objUser){
            Test.startTest();
            String filedata = '0001862394,2018-03-21,201,Company Reading,Manual Estimated,Meter book test1,Manufacture not valid,Aqua,3105001,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' + 
                              '0001862394,2018-03-22,202,Company Reading,Manual Estimated,Meter book test2,Serial not valid,Kent,3305001,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' +
                              '0001862394,2018-03-23,203,Company Reading,Manual Estimated,Meter book test3,Manufacture blank,,3105001,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' +
                              '0001862394,2018-03-24,204,Company Reading,Manual Estimated,Meter book test4,SerialNo blank,Kent,,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' +
                              '0001862394,2018-03-25,205,Company Reading,Manual Estimated,Meter book test5,Period Id not valid,Aqua,3105001,,TRUE,123,,,Potential of snakes,FALSE' + '\n' +
                              '0001862394,2018-03-26,206,Company Reading,Manual Estimated,Meter book test6,serial no have more blanks,Kent,  ,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' +
                              '0001862394,2018-03-27,207,Company Reading,Manual Estimated,Meter book test7,Manuf not in picklist,neha,3105001,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' +
                              '0001862394,2018-03-28,208,read source,Manual Estimated,Meter book test8,invalid read source,Kent,3105001,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' +
                              '0001862394,2018-03-29,209,Company Reading,read method,Meter book test9,invalid read method,Kent,3105001,,TRUE,123,' + objReadPeriod.Id + ',,Potential of snakes,FALSE' + '\n' +
                              'a0T0Y000003W1XPUA0,2018-03-03,210,Company Reading,Actual,Meter book test10,no active SP,Kent,3105001,Forgot to take,true,501,' + objReadPeriod.Id + ',,Potential of snakes,true' + '\n' +
                              'a0T0Y000003W1lKUAS,2018-04-04,211,Company Reading,Actual,Meter book test11,reading less then previous and tripped false,Kent,3105003,Forgot to take,true,501,' + objReadPeriod.Id + ',,Potential of snakes,false' + '\n' +
                              'a0T0Y000003W1lKUAS,2018-04-04,250,Company Reading,Actual,Meter book test12,throushold error,Kent,3105002,Forgot to take,true,501,' + objReadPeriod.Id + ',,Potential of snakes,false' + '\n' +
                              'a0T0Y000003WAeqUAG,2018-04-04,260,Company Reading,Actual,Meter book test13,no billable reading so record create,Kent,0406001,,true,501,' + objReadPeriod.Id + ',,Potential of snakes,false' + '\n' +
                              'a0T0Y000003WAfFUAW,2018-02-02,150,Company Reading,Actual,Meter book test14,No billable reading,Kent,3105004,Forgot to take,true,501,' + objReadPeriod.Id + ',,Potential of snakes,false' + '\n' +
                			  'a0T0Y000003WAfFUAW,2018-02-02,150,Company Reading,Actual,Meter book test15,No billable reading,Kent,3105005,estimated Reading,true,501,' + objReadPeriod.Id + ',,Potential of snakes,false' + '\n' +                			  
                			  'a0T0Y000003WAfFUAW,2018-02-02,150,Company Reading,Actual,Meter book test16,No billable reading,Kent,3105006,Actual Reading,true,501,' + objReadPeriod.Id + ',,Potential of snakes,false' + '\n' +
                              'a0T0Y000003WAfFUAW,2018-04-01,640,Company Reading,Actual,Meter book test17,valid reading,Kent,3105007,estimated Reading,true,501,' + objReadPeriod.Id + ',' + objReadTimetable.Id +',Potential of snakes,false' + '\n' +
                              'a0T0Y000003WAfFUAW,,640,Company Reading,Actual,Meter book test18,valid reading,Kent,3105007,estimated Reading,true,501,' + objReadPeriod.Id + ',' + objReadTimetable.Id +',Potential of snakes,false' + '\n' +
                			  'a0T0Y000003WAfFUAW,,,Company Reading,Actual,Meter book test19,valid reading,Kent,3105007,estimated Reading,true,501,' + objReadPeriod.Id + ',' + objReadTimetable.Id +',Potential of snakes,false' + '\n' +
               				  'a0T0Y000003WAfFUAW,,,Company Reading,Actual,Meter book test20,valid reading,Kent,3105007,,true,501,' + objReadPeriod.Id + ',' + objReadTimetable.Id +',Potential of snakes,false' + '\n' +
                			  'a0T0Y000003WAfFUAW,2018-04-01,640,,Actual,Meter book test21,valid reading,Kent,3105007,estimated Reading,true,501,' + objReadPeriod.Id + ',' + objReadTimetable.Id +',Potential of snakes,false' + '\n' +
                			  'a0T0Y000003WAfFUAW,2018-04-01,500,Company Reading,Actual,Meter book test22,valid reading,Kent,3105007,estimated Reading,true,501,' + objReadPeriod.Id + ',' + objReadTimetable.Id +',Potential of snakes,false' + '\n' +
                			  'a0T0Y000003WAfFUAW,2018-04-01,640,Company Reading,,Meter book test23,valid reading,Kent,3105007,estimated Reading,true,501,' + objReadPeriod.Id + ',' + objReadTimetable.Id +',Potential of snakes,false' ;
                      
            String filecontent = EncodingUtil.base64Encode(blob.valueOf(filedata));
            
            LoAp_NewReadingImportCtrlr.saveDetails(INVALID_DATA_JOB, IS_USER_NOTIFY, objUser.Id, FILE_NAME, filecontent, CONTENT_TYPE);
            Test.stopTest();      
            BatchRequestQueue__c objBRQ = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
            System.assert(objBRQ != null);
        } 
    }    
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Enviroment Setting Custom meta data type Data
    *******************************************************************************/ 
    private static void setEnvironmentSettingData(){
        GlUt_CustomMetaDataUtility.setMetadata(GlUt_Constants.ENVIROMENTSETTINGBOOKIMPORTQUERY,(List<EnvironmentSettings__mdt>) JSON.deserialize( 
            '[{"' + GlUt_Constants.BOOKIMPORTAPINAME + '":"' + GlUt_Constants.BOOKIMPORTVALUE + '"}]',List<EnvironmentSettings__mdt>.class )); 
    }
}