/******************************************************************************
@author         Vivek Sethi
@date          08 June 2018
@description    Test Class For LoBt_ExportBooks
*******************************************************************************/
@isTest
public class LoBt_ExportBooks_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String TEST_DEPOT   			= 'Test Depot';
    private static final String AVAIL_SERVICE     	    = 'WATER';
    private static final String WHOLESALER        	    = 'abc';
    private static final Integer DAILYUSAGE_START 		= 6;
    private static final Integer DAILYUSAGE_END 		= 250;
    private static final Integer ACCEPTPERCENTAGE_BELOW = 20;
    private static final Integer ACCEPTPERCENTAGE_ABOVE = 70;    
    private static final String LOCATION_NAME 			= 'A99 9AA';
    private static final String AREA_NAME 				= 'Test Area';
    private static final String READTIMETABLE 			= 'Read TimeTable';
    private static final String TEST_READ_TIMETABLE	    = 'Test Read Timetable';
    private static final String ACCOUNT_NAME            = 'TestAccount';
    private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';  
    private static final String  DEVICE_NAME       		= 'Meter';    
    private static final String YES 					='yes';
    private static final String MEASURED 				= 'Monthly';
    private static final String MONTHLY  			    = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    private static final String DEVICE_SIZE      		= 'TestDeviceSize';
    private static final String MANUFACTURER            = 'Siemens';
    private static final String UNIT_OF_MEASURE         = 'Metric';
    private static final String SERVICE_TYPE            = 'Service_Type';    
    private static final Date READ_START_DATE 			= date.valueOf('2018-02-15');
    private static final Date READ_END_DATE 			=  system.today() + 20; 
    private static final Date READING_END_DATE 			=  system.today() + 10; 
    private static final Date BILL_PERIOD_STARTDATE	 	= date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE 		= system.today() + 20;
    
    private class BRQParameters_JSON {
        private List<Id> booksToExport = new  List<Id>();
        private String periodID;
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           08 June 2018
    @return         Void   
    @description    Test data setup method
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){ 
  
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
    
        //Create account
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Contract
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        Database.insert(objContract);
        
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        //Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(TEST_DEPOT);
        Database.insert(objDepot);
        
        //Create Read Timetable Record
        ReadTimetable__c objReadTimeTable = GlUt_FactoryData_Test.createReadTimetable(TEST_READ_TIMETABLE,MONTHLY);
        Database.insert(objReadTimeTable);
        
        //Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot,objReadTimeTable);
        objBook.ReadFrequency__c = MEASURED;
        Database.insert(objBook);
        
        // Create ReadPeriod Record 
        ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimeTable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        Database.insert(objReadPeriod);   
        
         // Create ReadingMode Record
        ReadingMode__c objReadingMode = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);
        Database.insert(objReadingMode);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Book__c   = objBook.Id;  
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
    
        
        //create Reading Request record createReadingRequest
        ReadingRequest__c objReadingRequest = GlUt_FactoryData_Test.createReadingRequest(objSupplyPoint);
        objReadingRequest.Status__c= LoBt_Constants.READINGREQUESTNEWSTATUS;
        Database.insert(objReadingRequest);
        
        // Create ServiceType Record            
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE);
        Database.insert(objServiceType);
        
        // Create Division Record            
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);   
        
        // Create Wholesaler Record            
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);   
        
        // Create AvailableService Record            
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE, objDivision, objServiceType, objSupplyPoint, objWholesaler );
        Database.insert(objAvailableService);   
        
        BRQParameters_JSON brqObj = new  BRQParameters_JSON();
        brqObj.booksToExport.add(objBook.Id);        
        brqObj.periodID =  objReadPeriod.Id;
        
        //Create BatchRequestQueue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Parameters__c = JSON.serialize(brqObj);
        Database.insert(objBatchRequestQueue);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record            
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        Database.insert(objDevice); 
        
        // Create SupplyPointDevice Record
        SupplyPointDevice__c  objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        objSPD.InstallationDate__c = system.today();
        Database.insert(objSPD);
        
        // Create Reading Record            
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ReadingMethod__c = LoBt_Constants.READINGMETHOD;
        objReading.ReadingDate__c  =  READING_END_DATE;
        objReading.BillableType__c = GlUt_Constants.BILLABLE;
        Database.insert(objReading);  
        
        // Create Service Record            
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService); 
      
        //create ADU record
        AverageDailyUsage__c objAverageDailyUse = GlUt_FactoryData_Test.createAvgDailyUses(objSPD); 
        Database.insert(objAverageDailyUse);    
        
        // Create ReadTimetableThresholds Record       
        ReadTimetableThresholds__c objReadTimetableThresholds = GlUt_FactoryData_Test.createReadTimetableThresholds(objReadTimeTable, DAILYUSAGE_START, DAILYUSAGE_END, ACCEPTPERCENTAGE_BELOW, ACCEPTPERCENTAGE_ABOVE);        
        Database.insert(objReadTimetableThresholds);
        
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           08 June 2018
	@description:   Test Method to check LoBt_ExportBooks Batch class
	*******************************************************************************/
    static testmethod void LoBt_ExportBooks_Positive() {
        setEnvironmentSettingData();
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        BatchRequestQueue__c BatchRequestQueue = [select Id , Parameters__c from BatchRequestQueue__c limit 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            LoBt_ExportBooks obj = new LoBt_ExportBooks();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
            List<SupplyPoint__c> supplyPointList = [Select Id from SupplyPoint__c limit 1];
            List<ReadingRequest__c> lstReadingRequest = [select Status__c from ReadingRequest__c where SupplyPoint__c =:supplyPointList[0].Id];
            system.assertEquals(lstReadingRequest[0].Status__c, LoBt_Constants.READINGREQUESTEXPORTEDSTATUS);
        
            List<BatchRequestQueue__c> BatchRequestQueue1 = [select Id , Status__c  from BatchRequestQueue__c limit 1];
            system.assertEquals(BatchRequestQueue1[0].Status__c, LoBt_Constants.BRQSTATUS);
        }
    }
    /******************************************************************************
	@author         Vivek Sethi
	@date           08 June 2018
	@description:   Test Method to check LoBt_ExportBooks Batch class Negative Scenario
	*******************************************************************************/
    static testmethod void LoBt_ExportBooks_Negative() {
        setEnvironmentSettingData();
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                LoBt_ExportBooks obj = new LoBt_ExportBooks();
                LoPr_BookExportParameters.parse(null);
                DataBase.executeBatch(obj);
            }
            catch(Exception e)
            {
                isException = true;            
            }
            Test.stopTest();
         
        }
        System.assert(isException == true);
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