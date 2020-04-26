/******************************************************************************
@author:      Echo: Ankit Gangwani 
@date:        12 June 2018
@description: Test Class for LoBt_ScheduledEstimates
@comments:    For this Test Class coverage, we need to schedule a Batch Class first which is GlBt_ScheduleBatchRequest
*******************************************************************************/
@isTest
public class LoBt_ScheduledEstimates_Test {
    
	private static final String USER_PROFILE 				= 'System Administrator';
    private static final String USER_NAME 					= 'TestUser';
    private static final String USERNAMECOMPLETE  			= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 					= 'TestFirstName';
    private static final String USER_LNAME 					= 'TestLastName';
    private static final Boolean IS_USER_NOTIFY 			= true;
    private static final String USER_NOTIFY 				= 'abc@echo-ms.com';
    private static final String ZIP_CODE                	= 'WS2 7PD';
    private static final String SPUTNAME 					= 'Test SP USage Type';
    private static final String ESTIMATE_MODE 				= 'Estimate';
    private static final String ACTUAL_MODE					= 'Actual';
    private static final String FILE_NAME 					= 'InputFile.csv';
    private static final String AREA_NAME					= 'Test Area ';    
    private static final String DEPOT_NAME1 			    = 'Test Depot 1';
    private static final String DEPOT_NAME2 			    = 'Test Depot 2';
    private static final String DEPOT_NAME3					= 'Test Depot 3';
    private static final String DEPOT_NAME4					= 'Test Depot 4';
    private static final String DEPOT_NAME5					= 'Test Depot 5';
    private static final String DEPOT_NAME6					= 'Test Depot 6';
    private static final String DEPOT_NAME7					= 'Test Depot 7';
    private static final String READ_TIME_TABLE_NAME 		= 'Test Read Time Table';
    private static final String READ_TIME_TABLE_FREQUENCY 	= 'Monthly';
    private static final String DEVICE_SIZE_NAME			= '25';
    private static final String DEVICE_MANUFACTURER 		= 'kent';
    private static final String DEVICE_UOFMEASURE			= 'Imperial - UK Gallons';
    private static final String DEVICE_SERIAL_NUMBER		= 'A123';
    private static final String DEVICE_NAME					= 'Test Device';
    private static final String MEASURED					= 'Monthly';
    private static final Date READ_START_DATE 				= Date.valueOf('2018-02-15');
    private static final Date READ_END_DATE 				= Date.valueOf('2018-07-01');
    private static final Date BILL_PERIOD_STARTDATE 		= Date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE 			= Date.valueOf('2018-07-01');
    private static final String SCHEDULED_ESTIMATES			= 'LoBt_ScheduledEstimates';
    private static final String HIGH						= 'High';
    private static final String LOADING						= 'Loading';
    private static final String BILLABLE					= 'Billable';
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        12 June 2018
	@description: Test data setup method
	*******************************************************************************/
    //@TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME; 
        objUser.USERNAME = USER_NOTIFY;
        Database.insert(objUser);
        
        List<Area__c> areaList = new List<Area__c>();
        for(Integer area=0;area<7;area++){
            Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME + String.valueOf(area));
            areaList.add(objArea);
        }        
        insert areaList;
        
        List<Depot__c> depotLists = new List<Depot__c>();
        // Create Depot1 Record
        Depot__c objDepot1 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME1);
        objDepot1.Area__c = areaList[0].Id;
        depotLists.add(objDepot1);
        
        // Create Depot2 Record
        Depot__c objDepot2 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME2);
        objDepot2.Area__c = areaList[0].Id;        
        depotLists.add(objDepot2);
        
        Depot__c objDepot3 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME3);
        objDepot3.Area__c = areaList[3].Id;
        depotLists.add(objDepot3);
        
        Depot__c objDepot4 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME4);
        depotLists.add(objDepot4);
        
        Depot__c objDepot5 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME5);
        depotLists.add(objDepot5);
        
        Depot__c objDepot6 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME6); 
        depotLists.add(objDepot6);
        
        Depot__c objDepot7 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME7);
        objDepot7.Area__c = areaList[5].Id;
        depotLists.add(objDepot7);
        
        Database.insert(depotLists);
        // Create Read Time Table Record
        ReadTimeTable__c objReadTimeTable = GlUt_FactoryData_Test.createReadTimetable(READ_TIME_TABLE_NAME, READ_TIME_TABLE_FREQUENCY);
        Database.insert(objReadTimeTable);
        
        List<Book__c> bookLists = new List<Book__c>();
        // Create Book Record
        Book__c objBook1 = GlUt_FactoryData_Test.createBook(objDepot1, objReadTimeTable);
        objBook1.ReadFrequency__c = MEASURED;
        bookLists.add(objBook1);
        
        // Create Book Record
        Book__c objBook2 = GlUt_FactoryData_Test.createBook(objDepot2, objReadTimeTable);
        objBook2.ReadFrequency__c = MEASURED;
        bookLists.add(objBook2);
        
        // Create Book Record
        Book__c objBook3 = GlUt_FactoryData_Test.createBook(objDepot3, objReadTimeTable);
        objBook3.ReadFrequency__c = MEASURED;
        objBook3.ReadFrequency__c = MEASURED;
        bookLists.add(objBook3);
        
        // Create Book Record
        Book__c objBook4 = GlUt_FactoryData_Test.createBook(objDepot4, objReadTimeTable);
        objBook4.ReadFrequency__c = MEASURED;
        bookLists.add(objBook4);
        
        // Create Book Record
        Book__c objBook5 = GlUt_FactoryData_Test.createBook(objDepot6, objReadTimeTable);
        objBook5.ReadFrequency__c = MEASURED;
        bookLists.add(objBook5);
        Database.insert(bookLists);
        List<ReadPeriod__c> readPeriodList = new List<ReadPeriod__c>();
        for(Integer rp=0;rp<4;rp++){
            ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimeTable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
            readPeriodList.add(objReadPeriod);
        }        
        insert readPeriodList;        
       
        // Create Schedule Read
        ScheduledRead__c objScheduleRead = GlUt_FactoryData_Test.createScheduledRead(readPeriodList[1]);
        Database.insert(objScheduleRead);
        
        List<ReadingMode__c> readingModeList = new List<ReadingMode__c>();
        
        // Create Reading Mode Record associated with Area Estimated with Period 1
        ReadingMode__c objReadingModeAreaE = new ReadingMode__c();
        objReadingModeAreaE.Area__c = areaList[0].Id;
        objReadingModeAreaE.ReadPeriod__c = readPeriodList[0].Id;
        objReadingModeAreaE.EstimateDate__c = System.today();
        objReadingModeAreaE.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeAreaE);
        
        // Create Reading Mode Record associated with Book Estimated with Period 1
        ReadingMode__c objReadingModeBookE = new ReadingMode__c();
        objReadingModeBookE.Book__c = objBook1.Id;
        objReadingModeBookE.ReadPeriod__c = readPeriodList[0].Id;
        objReadingModeBookE.EstimateDate__c = System.today();
        objReadingModeBookE.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeBookE);
        
        // Create Reading Mode Record associated with Depot Estimated with Period 1
        ReadingMode__c objReadingModeDepotE = new ReadingMode__c();
        objReadingModeDepotE.Depot__c = objDepot1.Id;
        objReadingModeDepotE.ReadPeriod__c = readPeriodList[0].Id;
        objReadingModeDepotE.EstimateDate__c = System.today();
        objReadingModeDepotE.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeDepotE);
        
        // Create Reading Mode Record associated with Depot Actual with Period 1
        ReadingMode__c objReadingModeDepotA = new ReadingMode__c();
        objReadingModeDepotA.Depot__c = objDepot2.Id;
        objReadingModeDepotA.ReadPeriod__c = readPeriodList[0].Id;
        objReadingModeDepotA.EstimateDate__c = System.today();
        objReadingModeDepotA.Mode__c = ACTUAL_MODE;
        readingModeList.add(objReadingModeDepotA);        
        
        // Create Reading Mode Record associated with Area Actual with Period 1
        ReadingMode__c objReadingModeAreaA = new ReadingMode__c();
        objReadingModeAreaA.Area__c = areaList[2].Id;
        objReadingModeAreaA.ReadPeriod__c = readPeriodList[0].Id;
        objReadingModeAreaA.EstimateDate__c = System.today();
        objReadingModeAreaA.Mode__c = ACTUAL_MODE;
        readingModeList.add(objReadingModeAreaA);        
        
        // Create Reading Mode Record associated with Book Actual with Period 1
        ReadingMode__c objReadingModeBookA = new ReadingMode__c();
        objReadingModeBookA.Book__c = objBook2.Id;
        objReadingModeBookA.ReadPeriod__c = readPeriodList[0].Id;
        objReadingModeBookA.EstimateDate__c = System.today();
        objReadingModeBookA.Mode__c = ACTUAL_MODE;
        readingModeList.add(objReadingModeBookA); 
        
        // Create Reading Mode Record associated with Book Estimated with Period 2
        ReadingMode__c objReadingModeBookEP2 = new ReadingMode__c();
        objReadingModeBookEP2.Book__c = objBook3.Id;
        objReadingModeBookEP2.ReadPeriod__c = readPeriodList[1].Id;
        objReadingModeBookEP2.EstimateDate__c = System.today();
        objReadingModeBookEP2.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeBookEP2);
        
        // Create Reading Mode Record associated with Depot Estimated with Period 2
        ReadingMode__c objReadingModeDepotEP2 = new ReadingMode__c();
        objReadingModeDepotEP2.Depot__c = objDepot3.Id;
        objReadingModeDepotEP2.ReadPeriod__c = readPeriodList[1].Id;
        objReadingModeDepotEP2.EstimateDate__c = System.today();
        objReadingModeDepotEP2.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeDepotEP2);
        
        // Create Reading Mode Record associated with Area 4 Estimated with Period 2
        ReadingMode__c objReadingModeAreaEP2 = new ReadingMode__c();
        objReadingModeAreaEP2.Area__c = areaList[3].Id;
        objReadingModeAreaEP2.ReadPeriod__c = readPeriodList[1].Id;
        objReadingModeAreaEP2.EstimateDate__c = System.today();
        objReadingModeAreaEP2.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeAreaEP2);
        
        // Create Reading Mode Record associated with Area 5 Estimated with Period 3
        ReadingMode__c objReadingModeAreaEP3 = new ReadingMode__c();
        objReadingModeAreaEP3.Area__c = areaList[4].Id;
        objReadingModeAreaEP3.ReadPeriod__c = readPeriodList[2].Id;
        objReadingModeAreaEP3.EstimateDate__c = System.today();
        objReadingModeAreaEP3.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeAreaEP3);
        
        // Create Reading Mode Record associated with Depot 4 Estimated with Period 3
        ReadingMode__c objReadingModeDepotEP3 = new ReadingMode__c();
        objReadingModeDepotEP3.Depot__c = objDepot4.Id;
        objReadingModeDepotEP3.ReadPeriod__c = readPeriodList[2].Id;
        objReadingModeDepotEP3.EstimateDate__c = System.today();
        objReadingModeDepotEP3.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeDepotEP3);
        
        // Create Reading Mode Record associated with Book 4 Estimated with Period 3
        ReadingMode__c objReadingModeBookEP3 = new ReadingMode__c();
        objReadingModeBookEP3.Book__c = objBook4.Id;
        objReadingModeBookEP3.ReadPeriod__c = readPeriodList[2].Id;
        objReadingModeBookEP3.EstimateDate__c = System.today();
        objReadingModeBookEP3.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeBookEP3);
        
        // Create Reading Mode Record associated with Depot 5 Estimated with Period 3
        ReadingMode__c objReadingModeDepot5EP3 = new ReadingMode__c();
        objReadingModeDepot5EP3.Depot__c = objDepot5.Id;
        objReadingModeDepot5EP3.ReadPeriod__c = readPeriodList[2].Id;
        objReadingModeDepot5EP3.EstimateDate__c = System.today();
        objReadingModeDepot5EP3.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeDepot5EP3);
        
        // Create Reading Mode record associated with Depot 6 Estimated with Period 4
        ReadingMode__c objReadingModeDepot6EP4 = new ReadingMode__c();
        objReadingModeDepot6EP4.Depot__c = objDepot6.Id;
        objReadingModeDepot6EP4.ReadPeriod__c = readPeriodList[3].Id;
        objReadingModeDepot6EP4.EstimateDate__c = System.today();
        objReadingModeDepot6EP4.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeDepot6EP4);
        
        // Create Reading Mode record associated with Book 5 Estimated with Period 4
        ReadingMode__c objReadingModeBook5EP4 = new ReadingMode__c();
        objReadingModeBook5EP4.Book__c = objBook5.Id;
        objReadingModeBook5EP4.ReadPeriod__c = readPeriodList[3].Id;
        objReadingModeBook5EP4.EstimateDate__c = System.today();
        objReadingModeBook5EP4.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeBook5EP4);
        
        // Create Reading Mode record associated with Area 6 Estimated with Period 4
        ReadingMode__c objReadingModeArea6EP4 = new ReadingMode__c();
        objReadingModeArea6EP4.Area__c = areaList[5].Id;
        objReadingModeArea6EP4.ReadPeriod__c = readPeriodList[3].Id;
        objReadingModeArea6EP4.EstimateDate__c = System.today();
        objReadingModeArea6EP4.Mode__c = ESTIMATE_MODE;
        readingModeList.add(objReadingModeArea6EP4);
        
        Database.insert(readingModeList);        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);

        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SPUTNAME);
        Database.insert(objSupplyPointUsageType);
        
        List<SupplyPoint__c> supplyPointLists = new List<SupplyPoint__c>();
        
        // Create Supply Point Record associated with Depot which is associated with Area and that Area associated with Estimated Reading Mode
        // Condition - If the Depot-->Area is at Estimate level check with Book/Depot is at Actual level
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Depot__c = objDepot2.Id;
        objSupplyPoint.Measured__c = True; // AT-3174 
    
        supplyPointLists.add(objSupplyPoint);
        
        /*// Create Supply Point Record associated with Depot 1(Estimated) and Book 2(Actual) to exclude this Supply Point
        // Condition - If the Depot is at Estimate level check with Book at Actual level
        SupplyPoint__c objSupplyPoint2 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.Depot__c = objDepot1.Id;
        objSupplyPoint2.Book__c = objBook2.Id;
        objSupplyPoint2.Measured__c = 'Yes';
        supplyPointLists.add(objSupplyPoint2);*/ 
        
        // Created Supplt Point Record associated with Book 3
        // Condition - If the schedule read exist for the Current Read Period 2 (Book)
        SupplyPoint__c objSupplyPoint3 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint3.Book__c = objBook3.Id;
        objSupplyPoint3.Measured__c = True; // AT-3174 
     
        supplyPointLists.add(objSupplyPoint3);
        
        // Created Supplt Point Record associated with Depot 3
        // Condition - If the schedule read exist for the Current Read Period 2 (Depot)
        SupplyPoint__c objSupplyPoint4 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint4.Depot__c = objDepot3.Id;
        objSupplyPoint4.Measured__c = True; // AT-3174 
   
        supplyPointLists.add(objSupplyPoint4);
        
        // Created Supplt Point Record associated with Depot 3 and that Depot is associated with Area #
        // Condition - If the schedule read exist for the Current Read Period 2 (Depot-->Area)
        SupplyPoint__c objSupplyPoint5 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint5.Depot__c = objDepot3.Id;
  
        objSupplyPoint5.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint5);
        
        // Create Supply Point Record associated with Book and That Book is associated with Estimated Reading mode with Period 1
        // Condition - Check if there is already billable reading exist with current period
        SupplyPoint__c objSupplyPoint6 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint6.Book__c = objBook1.Id;
 
        objSupplyPoint6.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint6);
        
        // Create Supply Point Record associated with Depot and That Depot is associated with Estimated Reading mode with Period 1
        // Condition - Check if there is already billable reading exist with current period
        SupplyPoint__c objSupplyPoint7 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint7.Depot__c = objDepot1.Id;

        objSupplyPoint7.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint7);
        
        // Create Supply Point Record associated with Depot-->Area and That Area is associated with Estimated Reading mode with Period 1
        // Condition - Check if there is already billable reading exist with current period
        SupplyPoint__c objSupplyPoint8 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint8.Depot__c = objDepot1.Id;
    
        objSupplyPoint8.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint8);
        
        // Create Supply Point Record associated with Depot and That Depot is associated with Estimated Reading mode with Period 3
        // Condition - Check if there is already billable reading exist with current period
        SupplyPoint__c objSupplyPoint9 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint9.Depot__c = objDepot4.Id;
 
        objSupplyPoint9.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint9);
        
        // Create Supply Point Record associated with Book and That Book is associated with Estimated Reading mode with Period 3
        // Condition - Check if there is already billable reading exist with current period
        SupplyPoint__c objSupplyPoint10 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint10.Book__c = objBook4.Id;
 
        objSupplyPoint10.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint10);
        
        // Create Supply Point Record associated with Exclude From Estimation 
        // Condition - Exclude the Sp if exclude from estimation is true
        SupplyPoint__c objSupplyPoint11 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);        
        objSupplyPoint11.ExcludeFromEstimation__c = true;
        objSupplyPoint11.Depot__c = objDepot5.Id;

        objSupplyPoint11.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint11);
        
        // Create Supply Point Record associated with Depot 6 with correct record
        SupplyPoint__c objSupplyPoint12 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);                
        objSupplyPoint12.Depot__c = objDepot6.Id;
    
        objSupplyPoint12.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint12);
        
        // Create Supply Point Record associated with Depot 6 with correct record
        SupplyPoint__c objSupplyPoint13 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);                
        objSupplyPoint13.Depot__c = objDepot7.Id;
    
        objSupplyPoint13.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint13);
        
        // Create Supply Point Record associated with Depot 6 with correct record
        SupplyPoint__c objSupplyPoint14 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);                
        objSupplyPoint14.Book__c = objBook5.Id;

        objSupplyPoint14.Measured__c = True; // AT-3174 
        supplyPointLists.add(objSupplyPoint14);
        Database.insert(supplyPointLists);
        
        // Create Device Size Record
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE_NAME);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, DEVICE_MANUFACTURER, DEVICE_UOFMEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice.SerialNo__c = DEVICE_SERIAL_NUMBER;
        objDevice.Digit__c = 2;
        Database.insert(objDevice);
        
        // Create Supply Point Device
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        // Create Device Record
        Device__c objDevice9 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice9.SerialNo__c = 'B123';
        objDevice9.Digit__c = 2;
        Database.insert(objDevice9);
        
        // Create Supply Point Device
        SupplyPointDevice__c objSupplyPointDevice9 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice9, objSupplyPoint9);
        Database.insert(objSupplyPointDevice9);
        
        // Create Device Record
        Device__c objDevice10 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice10.SerialNo__c = 'C123';
        objDevice10.Digit__c = 2;
        Database.insert(objDevice10);
        
        // Create Supply Point Device
        SupplyPointDevice__c objSupplyPointDevice10 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice10, objSupplyPoint10);
        Database.insert(objSupplyPointDevice10);
        
        // Create Device Record
        Device__c objDevice11 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice11.SerialNo__c = 'D123';
        objDevice11.Digit__c = 2;
        Database.insert(objDevice11);
        
        // Create Supply Point Device
        SupplyPointDevice__c objSupplyPointDevice11 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice11, objSupplyPoint11);
        Database.insert(objSupplyPointDevice11);
        
        // Create Device Record
        Device__c objDevice12 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice12.SerialNo__c = 'E123';
        objDevice12.Digit__c = 2;
        Database.insert(objDevice12);
        
        // Create Supply Point Device
        SupplyPointDevice__c objSupplyPointDevice12 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice12, objSupplyPoint12);
        Database.insert(objSupplyPointDevice12);
        
        // Create Device Record
        Device__c objDevice13 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice13.SerialNo__c = 'F123';
        objDevice13.Digit__c = 5;
        Database.insert(objDevice13);
        
        // Create Supply Point Device
        SupplyPointDevice__c objSupplyPointDevice13 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice13, objSupplyPoint13);
        Database.insert(objSupplyPointDevice13);
        
        // Create Device Record
        Device__c objDevice14 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice14.SerialNo__c = 'G123';
        objDevice14.Digit__c = 2;
        Database.insert(objDevice14);
        
        // Create Supply Point Device
        SupplyPointDevice__c objSupplyPointDevice14 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice14, objSupplyPoint14);
        Database.insert(objSupplyPointDevice14);
               
        List<AverageDailyUsage__c> aduList = new List<AverageDailyUsage__c>();
        // Create Average Daily Use
        AverageDailyUsage__c objAverageDailyUse = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice);
        objAverageDailyUse.StartDate__c = Date.valueOf('2018-06-01');
        objAverageDailyUse.EndDate__c = Date.valueOf('2018-06-20');
        objAverageDailyUse.AverageDailyUsage__c = 11.00; 
        aduList.add(objAverageDailyUse);
        
        // Create Average Daily Use
        AverageDailyUsage__c objAverageDailyUse12 = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice12);
        objAverageDailyUse12.StartDate__c = Date.valueOf('2018-06-01');
        objAverageDailyUse12.EndDate__c = Date.valueOf('2018-06-20');
        objAverageDailyUse12.AverageDailyUsage__c = 12.00; 
        aduList.add(objAverageDailyUse12);
        
        AverageDailyUsage__c objAverageDailyUse13 = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice13);
        objAverageDailyUse13.StartDate__c = Date.valueOf('2018-06-01');
        objAverageDailyUse13.EndDate__c = Date.valueOf('2018-06-20');
        objAverageDailyUse13.AverageDailyUsage__c = 12.00; 
        aduList.add(objAverageDailyUse13);
        
        AverageDailyUsage__c objAverageDailyUse14 = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice14);
        objAverageDailyUse14.StartDate__c = Date.valueOf('2018-06-01');
        objAverageDailyUse14.EndDate__c = Date.valueOf('2018-06-20');
        objAverageDailyUse14.AverageDailyUsage__c = 12.00; 
        aduList.add(objAverageDailyUse14);
        insert aduList;
        
        List<Reading__c> readingList = new List<Reading__c>();
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.BillableType__c = BILLABLE;
        objReading.ReadingDate__c = Date.valueOf('2018-06-11');
        objReading.ActualDeviceReading__c = '50';
        readingList.add(objReading);
        
        // Create Reading Record
        Reading__c objReading9 = GlUt_FactoryData_Test.createReading(objDevice9);
        objReading9.BillableType__c = BILLABLE;
        objReading9.ReadingDate__c = Date.valueOf('2018-06-11');
        objReading9.ActualDeviceReading__c = '50';
        readingList.add(objReading9);
        
        // Create Reading Record
        Reading__c objReading10 = GlUt_FactoryData_Test.createReading(objDevice10);
        objReading10.BillableType__c = BILLABLE;
        objReading10.ReadingDate__c = Date.valueOf('2018-06-11');
        objReading10.ActualDeviceReading__c = '50';
        readingList.add(objReading10);
        
        // Create Reading Record
        Reading__c objReading11 = GlUt_FactoryData_Test.createReading(objDevice11);
        objReading11.BillableType__c = BILLABLE;
        objReading11.ReadingDate__c = Date.valueOf('2017-06-11');
        objReading11.ActualDeviceReading__c = '50';
        readingList.add(objReading11);
        
        // Create Reading Record
        Reading__c objReading12 = GlUt_FactoryData_Test.createReading(objDevice12);
        objReading12.BillableType__c = BILLABLE;
        objReading12.ReadingDate__c = Date.valueOf('2017-06-11');
        objReading12.ActualDeviceReading__c = '50';
        readingList.add(objReading12);
        
        Reading__c objReading13 = GlUt_FactoryData_Test.createReading(objDevice13);
        objReading13.BillableType__c = BILLABLE;
        objReading13.ReadingDate__c = Date.valueOf('2017-06-11');
        objReading13.ActualDeviceReading__c = '500';
        readingList.add(objReading13);
        
        Reading__c objReading14 = GlUt_FactoryData_Test.createReading(objDevice14);
        objReading14.BillableType__c = BILLABLE;
        objReading14.ReadingDate__c = Date.valueOf('2017-06-11');
        objReading14.ActualDeviceReading__c = '50';
        readingList.add(objReading14);
       
        Database.insert(readingList);
        
        // Create Batch Process Record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(SCHEDULED_ESTIMATES);
        Database.insert(objBatchProcess);
        
    }
    
    /******************************************************************************
	@author:      Echo: Swati Mathur 
    @date:        12 June 2018 
	@description: Test Method
	*******************************************************************************/
    static testmethod void fireBatchwithScheduleClass(){
        // Calling createTestDate from here because we need to get the CRON details from the org, SeeAllData=true implemented in this test class
        createTestData();
        setEnvironmentSettingData();
        Integer hours = Datetime.now().addHours(1).hour();
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USER_NOTIFY LIMIT 1];       
        BatchRequestQueue__c objBatchReqQueue = new BatchRequestQueue__c();
        //objBatchReqQueue.BatchProcess__c = batchProcessList[0].Id;
        objBatchReqQueue.Priority__c = HIGH;
        objBatchReqQueue.SendEmailNotification__c = True;
        objBatchReqQueue.Status__c = LOADING;
        objBatchReqQueue.NotificationUser__c = UserInfo.getUserId();
        objBatchReqQueue.Parameters__c = '';
        insert objBatchReqQueue;
        
        System.runAs(objUser){
            
            Test.startTest();   
            
        	GlBt_ScheduleBatchRequest myBatchObject = new GlBt_ScheduleBatchRequest(SCHEDULED_ESTIMATES);
            LoBt_ScheduledEstimates myBatch = new LoBt_ScheduledEstimates();
            myBatch.Initialise(objBatchReqQueue);
            Database.executeBatch(myBatch);
            Test.stopTest();  
            System.assert(objBatchReqQueue.Id != null);
        } 
    }
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        14 Mar 2019
    @description: Enviroment Setting Custom meta data type Data
    *******************************************************************************/ 
    private static void setEnvironmentSettingData(){
        GlUt_CustomMetaDataUtility.setMetadata(GlUt_Constants.ENVIROMENTSETTINGEXPORTLIBRARYQUERY,(List<EnvironmentSettings__mdt>) JSON.deserialize( 
            '[{"' + GlUt_Constants.EXPORTBOOKLIBRARYAPINAME + '":"' + GlUt_Constants.EXPORTBOOKLIBRARYVALUE + '"}]', 
            List<EnvironmentSettings__mdt>.class)); 
    }
}