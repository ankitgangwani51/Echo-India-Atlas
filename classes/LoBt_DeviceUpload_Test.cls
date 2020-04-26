/******************************************************************************
@author        Amit K.
@date          06 Feb 2019
@description   Test Class For LoBt_DeviceUpload
*******************************************************************************/
@isTest
public class LoBt_DeviceUpload_Test {
    
    //Variable declaration start    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USERNAME 			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USERNAME+ '@unitest.com';
    private static final String ACCOUNT_NAME 		= 'TestDevice';
    private static final String TESTSERVICE_TYPE1 	= 'TestServiceType1'; 
    private static final String TESTSERVICE_TYPE2 	= 'TestServiceType2';
    private static final String TESTSERVICE_TYPE3 	= 'TestServiceType3';
    private static final String TESTSERVICE_TYPE4 	= 'TestServiceType4';
    private static final String LOCATION_NAME 		= 'A99 9AA';   
    private static final String LOCATION_SUB_TYPE 	= 'Detached';
    private static final String STREET 				= 'teststreet';
    private static final String LIBRARIES			= 'Libraries';    
    private static final String DEVICE_TYPE_NAME 	= 'Meter'; 
    private static final String OLDDEVICE_SERIALNO 	= '0801001';
    private static final String NEWDEVICE_SERIALNO 	= '176565';
    private static final String OLDDEVICE_SERIALNO_EXCHANGE = '0801';
    private static final String NEWDEVICE_SERIALNO_EXCHANGE = '17236';
    private static final String YES 				= 'yes';    
    private static final String MEASURED 			= 'Monthly';
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    private static final String DEVICE_SIZE 		= '10mm';
    private static final String MANUFACTURER 		= 'Kent';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String BUNDLE 				= 'TestBundle';
    private static final String AVAILABLEBUNDLE 	= 'TestAvailableBundle';
    private static final String BUNDLEITEM 			= 'TestBundleItem';
    private static final String WHOLESALER 			= 'TestWholesaler';
    private static final String AVAILABLESERVICES 	= 'TestAvailableService';
    private static final String READTIMETABLE = 'Read TimeTable';
    private static final String MONTHLY = 'Monthly';
    private static final String DEPOT_NAME = 'Test Depot'; 
    private static final String AREA_NAME = 'Test Area';
    private static final String INITIAL_READING = '200';
    private static final String FINAL_READING = '100';
    private static final String CATEGORY_NEW = 'N';
    private static final String CATEGORY_EXCHANGE = 'E';
    private static final String CATEGORY_REMOVE = 'R';
    private static final String TESTBUNDLE2 = 'TestBundle2';
    private static final Decimal WALKORDER = 10.00;
    private static final Decimal DIGITS = 3;
    /******************************************************************************
	@author         Amit K.
	@date           06 Feb 2019
    @return         Void   
    @description    Test data setup method
    *******************************************************************************/
    @TestSetup
    Static void createTestData(){
        
        //Create User Record        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USERNAME,null);
        Database.insert(objUser);       
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
         // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);
        objDepot.Area__c = objArea.Id;        
        Database.insert(objDepot);
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE,MONTHLY);        
        Database.insert(objReadTimetable);
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable);        
        Database.insert(objBook);
            
        //Create Account Record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(USERNAME,objAccount);
        Database.insert(objContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);       
        
        //Create Service Type Record - 1
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType1);
        
        //Create Service Type Record - 2
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE2);
        Database.insert(objServiceType2);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point  - Remove Device
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c = True; 
        objSupplyPoint1.SpecialInstructions__c = LIBRARIES;
        Database.insert(objSupplyPoint1);
        
        //Create Supply Point  - New Device
        SupplyPoint__c  objSupplyPoint2 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint2);
        
        //Create Supply Point  - Exchange Device
        SupplyPoint__c  objSupplyPoint3 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint3.Measured__c = True;
        Database.insert(objSupplyPoint3);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record - old device for Remove Device Scenario
        Device__c  objOldDevice = GlUt_FactoryData_Test.CreateDevice(OLDDEVICE_SERIALNO , objDeviceType);        
        objOldDevice.SerialNo__c = OLDDEVICE_SERIALNO;
        Database.insert(objOldDevice);
        
         // Create Device Record - Old Device for Exchange Device Scenario
        Device__c  objOldDevice2 = GlUt_FactoryData_Test.CreateDevice(OLDDEVICE_SERIALNO_EXCHANGE , objDeviceType);        
        objOldDevice2.SerialNo__c = OLDDEVICE_SERIALNO_EXCHANGE;
        Database.insert(objOldDevice2);
        
        
        // Create Supply Point Device Record - Exchage
        SupplyPointDevice__c  objOldSupplyPointDeviceExchange = GlUt_FactoryData_Test.CreateSupplyPointDevices(objOldDevice2 , objSupplyPoint3);        
        Database.insert(objOldSupplyPointDeviceExchange);
        
        // Create Supply Point Device Record - Remove
        SupplyPointDevice__c  objOldSupplyPointDevice = GlUt_FactoryData_Test.CreateSupplyPointDevices(objOldDevice , objSupplyPoint1);        
        Database.insert(objOldSupplyPointDevice);
        
         // Create Supply Point Device Service Record - Exchange
        SupplyPointDeviceService__c  objOldSupplyPointDeviceServiceExchange = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDeviceExchange , objServiceType1);        
        Database.insert(objOldSupplyPointDeviceServiceExchange);
        
        // Create Supply Point Device Service Record - Remove 1
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService1 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType1);        
        Database.insert(objOldSupplyPointDeviceService1);
        
        // Create Supply Point Device Service Record - Remove 2
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService2 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType2);        
        Database.insert(objOldSupplyPointDeviceService2); 
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objOldDevice);
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
        
        // Create Available Service Record - Remove - Sewerage (Existing Available Service Where Available Service Item gets ended with removal date and last bundle change date is set)
        AvailableService__c  objAvailableService2 = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType2,objSupplyPoint1,objWholesaler);
        Database.insert(objAvailableService2);
        
        // Create Available Service Record - New Device - Water (Existing Available Service Where AB gets created)
        AvailableService__c  objAvailableService3 = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType1,objSupplyPoint2,objWholesaler);
        Database.insert(objAvailableService3);
        
        // Create Available Service Record - New Device - Sewerage (Existing Available Service Where AB gets created)
        AvailableService__c  objAvailableService4 = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType2,objSupplyPoint2,objWholesaler);
        Database.insert(objAvailableService4);
        
        // Create Service Record - Remove Device - (Existing Services)
        Service__c  objOldService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService1);
        
        // Create Service Record - Remove Device -(Existing Services)
        Service__c  objOldService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService2);
        
        // Create Service Record - New Device - (Existing Services)
        Service__c  objNewService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint2, objAvailableService3);
        Database.insert(objNewService1);
        
        // Create Service Record - New Device -(Existing Services)
        Service__c  objNewService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint2, objAvailableService4);
        Database.insert(objNewService2);
        
        // Create Bundle Record - Water Bundle
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType1 );
        Database.insert(objBundle);
        
        // Create Bundle Record - Sewerage Bundle.
        Bundle__c objBundle2 = GlUt_FactoryData_Test.createBundle(TESTBUNDLE2,objServiceType2 );
        Database.insert(objBundle2);
        
        // Create Available Bundle Record - Water - Remove (Existing bundle where last bundle change date is set)
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle); 
        
        // Create Available Bundle Record - Sewerage - Remove (Existing bundle where last bundle change date is set)
        AvailableBundle__c  objAvailableBundle2 = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle2,objAvailableService2);
        Database.insert(objAvailableBundle2); 
        
     
        //Device Upload - Remove Device
        List<DeviceUploadStaging__c> deviceUploadList = new List<DeviceUploadStaging__c>();
        DeviceUploadStaging__c  objDeviceUploadStagingRemove = GlUt_FactoryData_Test.createDeviceUpload(objBook.Id, objSupplyPoint1.Id,objLocation.Id,objServiceType1.Id,objServiceType2.Id,objBundle.Name,objBundle2.Name);
        objDeviceUploadStagingRemove.CurrentManufacturer__c = MANUFACTURER;
        objDeviceUploadStagingRemove.CurrentSerialNumber__c = OLDDEVICE_SERIALNO;
        objDeviceUploadStagingRemove.RemovalDate__c = system.today();
        objDeviceUploadStagingRemove.Catagory__c = CATEGORY_REMOVE;
        objDeviceUploadStagingRemove.WalkOrder__c = WALKORDER;
        objDeviceUploadStagingRemove.FinalReading__c = FINAL_READING;
        deviceUploadList.add(objDeviceUploadStagingRemove);
        //Device Upload - New Device
        DeviceUploadStaging__c  objDeviceUploadStagingNew = GlUt_FactoryData_Test.createDeviceUpload(objBook.Id, objSupplyPoint2.Id,objLocation.Id,objServiceType1.Id,objServiceType2.Id,objBundle.Name,objBundle2.Name);
        objDeviceUploadStagingNew.Catagory__c = CATEGORY_NEW;
        objDeviceUploadStagingNew.InitialReading__c = INITIAL_READING;
        objDeviceUploadStagingNew.InstallationDate__c = System.Today();
        objDeviceUploadStagingNew.InitialReadingDate__c = System.Today() + 10;
        objDeviceUploadStagingNew.NewDeviceSerialNumber__c = NEWDEVICE_SERIALNO;
        objDeviceUploadStagingNew.NewDeviceManufacturer__c = MANUFACTURER;
        objDeviceUploadStagingNew.NewDeviceSize__c = DEVICE_SIZE;
        objDeviceUploadStagingNew.Digits__c = DIGITS;
        objDeviceUploadStagingNew.LocationNo__c = objLocation.Id;
        deviceUploadList.add(objDeviceUploadStagingNew);
        //Device Upload - Exchange Device
        DeviceUploadStaging__c  objDeviceUploadStagingExchange = GlUt_FactoryData_Test.createDeviceUpload(objBook.Id, objSupplyPoint3.Id,objLocation.Id,objServiceType1.Id,objServiceType2.Id,'','');
        objDeviceUploadStagingExchange.CurrentManufacturer__c = MANUFACTURER;
        objDeviceUploadStagingExchange.CurrentSerialNumber__c = OLDDEVICE_SERIALNO_EXCHANGE;
        objDeviceUploadStagingExchange.RemovalDate__c = system.today();
        objDeviceUploadStagingExchange.Catagory__c = CATEGORY_EXCHANGE;
        objDeviceUploadStagingExchange.NewDeviceSerialNumber__c = NEWDEVICE_SERIALNO_EXCHANGE;
        objDeviceUploadStagingExchange.NewDeviceManufacturer__c = MANUFACTURER;
        objDeviceUploadStagingExchange.NewDeviceSize__c = DEVICE_SIZE;
        objDeviceUploadStagingExchange.InitialReading__c = INITIAL_READING;
        objDeviceUploadStagingExchange.FinalReading__c = FINAL_READING;
        objDeviceUploadStagingExchange.InstallationDate__c =  System.Today() + 10;
        objDeviceUploadStagingExchange.InitialReadingDate__c = System.Today() +11;
        objDeviceUploadStagingExchange.Digits__c = DIGITS;
        deviceUploadList.add(objDeviceUploadStagingExchange);
        Database.insert(deviceUploadList); 
        //Create BatchRequestQueue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        Database.insert(objBatchRequestQueue);
    
        
    }
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        06 Feb 2018
    @description: Device Upload method postitive scenario Without any batch errors
    *******************************************************************************/ 
    static testmethod void DeviceUpload_Positive(){
        setEnvironmentSettingData();// Added By Echo: Dependra Singh - 12-03-2018
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name 
                        FROM User 
                        WHERE isActive=TRUE AND 
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        BatchRequestQueue__c BatchRequestQueue = [select Id  from BatchRequestQueue__c limit 1]; 
        
        // Run test class in user context
        System.runAs(objUser){ 
            Test.startTest();
            LoBt_DeviceUpload obj = new LoBt_DeviceUpload();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest(); 
            List<BatchError__c> batchErrorList = [Select id from BatchError__c Limit 10];
            System.assert(batchErrorList.isEmpty());
        }
    }
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        06 Feb 2018
    @description: Device Upload method negative scenario With batch errors
    *******************************************************************************/ 
    static testmethod void DeviceUpload_Negative(){
        setEnvironmentSettingData();// Added By Echo: Dependra Singh - 12-03-2018
        boolean isException;
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name 
                        FROM User 
                        WHERE isActive=TRUE AND 
                        Username =: USERNAMECOMPLETE LIMIT 1];
        List<DeviceUploadStaging__c> deviceUploadStagingList = [Select Id,Service1AvailableBundle__c,Service2AvailableBundle__c from DeviceUploadStaging__c Limit 3];
        
        for(DeviceUploadStaging__c deviceUpload: deviceUploadStagingList){
            deviceUpload.Service1AvailableBundle__c = '';
            deviceUpload.Service2AvailableBundle__c = '';
        }
        update deviceUploadStagingList;
        BatchRequestQueue__c BatchRequestQueue = [select Id,Parameters__c, Status__c  from BatchRequestQueue__c limit 1]; 
        
        // Run test class in user context
        System.runAs(objUser){ 
            Test.startTest();
            LoBt_DeviceUpload obj = new LoBt_DeviceUpload();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
            BatchRequestQueue__c BatchRequestQueue1 = [select Id , Parameters__c, Status__c from BatchRequestQueue__c limit 1]; 
            system.assert(BatchRequestQueue1.Status__c != LoAp_Constants.LOADING);
        }
    }
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Final Bill Custom meta data type Data
    *******************************************************************************/ 
    private static void setEnvironmentSettingData(){
        GlUt_CustomMetaDataUtility.setMetadata(GlUt_Constants.ENVIROMENTSETTINGDEVICEUPLOADQUERY,(List<EnvironmentSettings__mdt>) JSON.deserialize( 
            '[{"' + GlUt_Constants.DEVICEUPLOADLIBRARYAPINAME + '":"' + GlUt_Constants.DEVICEUPLOADLIBRARYVALUE + '"}]', 
            List<EnvironmentSettings__mdt>.class)); 
    }
}