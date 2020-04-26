/******************************************************************************
@author:      Gopal Gupta
@date:        08 Feb 2018
@description: Test Class for BlUt_ADUCalculation
@revesion     Updated By Echo: Dependra Singh - 13-03-2018, Added new method for Meta data types.
*******************************************************************************/
@isTest
public class BlUt_ADUCalculation_Test {
    
    // variables
    private static string ACCOUNTNAME1 = 'Test1 Account1';
    private static string ACCOUNTNAME2 = 'Test2 Account2';
    private static string CONTRACTNAME = 'Test Contract';
    private static string TESTDEVICETYPE = 'TestDeviceType';
    private static string TESTSUBDEVICE =    'TestsubDevice';
    private static string TESTSERVICETYPE ='TestServiceType';
    private static string LOCATION= 'A99 9AA';
    private static string LOCATION_NAME = 'WS2 8DE';
    private static string DETACHED = 'Detached';
    private static string CUSTOMERNAME = 'Test customer';
    private static string STRTEST ='test';
    private static string MEASURED= 'Monthly';
    private static string YES = 'yes';
    private static string DEVICENAME= 'TestDeviceName';
    private static string DEVICESIZENAME= 'TestDeviceSizeName';
    private static User DUMMYUSER;
    private static string ACTUALREADING = '8977543356';
    private static string ACTUALREADING1 = '8977543357';
    private static string ACTUALREADING2 = '8977543360';
    private static string ACTUALDEVICEREADING = '8933213345';
    private static integer AVERAGEDAILYUSAGE = 10; 
    private static integer LISTSIZE = 2;
    private static integer LISTSTART = 0;
    private static integer DAILYSIZE = 1;
    private static String PROFILENAME = 'System Administrator';
    private static String USERNAME = 'TestUser788';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static Integer maxDMLstatements = 50;
    private static Integer maxQueries       = 70;
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static String HOUNSEHOLDACCOUNT ='Household Account';
    private static String NONHOUNSEHOLDACCOUNT ='Non-Household Account';
    private static String SERIAL_NO1 = '458';
    private static String SERIAL_NO2 = '369';
    private static Id accHHRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(HOUNSEHOLDACCOUNT).getRecordTypeId();
    private static Id accNHHRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(NONHOUNSEHOLDACCOUNT).getRecordTypeId();
    private static String HOUSEHOLD = 'Household';
    private static String NONHOUSEHOLD = 'Non-Household';
    private static String AVAIL_SERVICE1 = 'Avail_service for fixed';
    private static String AVAIL_SERVICE2 = 'Avail_service for percentage';
    private static String SYSTEM_ESTIMATED = 'System Estimated';
    private static String SERVICE_TYPE = 'water';    
    private static String WHOLESALER = 'wholesaler';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/    
    @TestSetup
    Static void createTestData(){  
        
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        
        //Create hh account record
        List<Account> accountList = new List<Account>();
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME1);
        objAccount.RecordTypeId = accHHRecordTypeId;
        accountList.add(objAccount);
        
        //Create nhh account record
        Account objAccount1 = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME2);
        objAccount1.RecordTypeId = accNHHRecordTypeId;
        accountList.add(objAccount1);
        
        if(!accountList.IsEmpty())
            insert accountList;
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACTNAME ,objAccount);
        Database.insert(objContract);
        
        BillingContract__c objContract1 = GlUt_FactoryData_Test.createContract(CONTRACTNAME ,objAccount1);
        Database.insert(objContract1);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);

        List<Location__c> locationList = new List<Location__c>();
        //Create location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION);
        objLocation.LocationSubType__c=DETACHED ; 
        objLocation.Street__c =STRTEST ;
        objLocation.NumberOfOccupiers__c = 1;
        objLocation.LocationType__c= HOUSEHOLD;
        locationList.add(objLocation);
        
        //Create location record
        Location__c objLocation1 = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation1.LocationSubType__c=DETACHED ; 
        objLocation1.Street__c =STRTEST ;
        objLocation1.LocationType__c= NONHOUSEHOLD;
        locationList.add(objLocation1);
        
        if(!locationList.isEmpty())
            insert locationList;
        
       /* //Create active location occupant record
        LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        locOccObj.StartDate__c = System.today()-10;
        locOccObj.EndDate__c = null;
        locOccObj.Primary__c = true;
        Database.insert(locOccObj);
        
        LocationOccupant__c locOccObj1 = GlUt_FactoryData_Test.createLocationOccupant(objAccount1, objLocation1);
        locOccObj1.StartDate__c = System.today()-10;
        locOccObj1.EndDate__c = null;
        locOccObj.Primary__c = true;
        Database.insert(locOccObj1);*/
        
        //Create device records
        list<Device__c > listDevice = new list<Device__c >();
            for(integer i=LISTSTART ; i<LISTSIZE; i++){
                Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICENAME,objDeviceType);
                if(i==0)
                    objDevice.SerialNo__c = SERIAL_NO1;
                else
                    objDevice.SerialNo__c = SERIAL_NO2;
                objDevice.Digit__c = 10;
                listDevice.add(objDevice );
            }
        Database.insert(listDevice);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create supply point records
        list<SupplyPoint__c > listSupplyPoint = new list<SupplyPoint__c >();
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            SupplyPoint__c  objSupplyPoint = new SupplyPoint__c();
            
            if(i == 0){
                objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
            }
            else{
                objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation1, objSupplyPointUsageType);               
            }
            
            objSupplyPoint.Measured__c= True; // AT-3174 

            listSupplyPoint.add(objSupplyPoint);
        }
        
        Database.insert(listSupplyPoint);
        
        //Create reading and supply point device records
        list<Reading__c> listReading = new list<Reading__c>();
        list<SupplyPointDevice__c > listSupplyPointDevice = new list<SupplyPointDevice__c >();
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(listDevice[i], listSupplyPoint[i] );
                      
            objSPD.RemovalDate__c = null;
            objSPD.InstallationDate__c = System.today() - 2;
            listSupplyPointDevice.add(objSPD);            
            Reading__c  objReading = GlUt_FactoryData_Test.createReading(listDevice[i]);
            objReading.ActualDeviceReading__c= ACTUALREADING;
            objReading.ReadingDate__c = Date.today() - 365;
            listReading.add(objReading);            
        }
        Database.insert(listSupplyPointDevice);
        Database.insert(listReading);
        
        list<DefaultAverageDailyUsage__c> defaultAverageDailyUsageList = new list<DefaultAverageDailyUsage__c>();
        //Create Default Average Daily Usage records 
        DefaultAverageDailyUsage__c objDfltAvgDailyUsage = new DefaultAverageDailyUsage__c();
        objDfltAvgDailyUsage.DeviceSize__c = objDeviceSize.Id;
        objDfltAvgDailyUsage.SupplyPointUsageType__c = objSupplyPointUsageType.Id;        
        objDfltAvgDailyUsage.AverageDailyUsage__c = AVERAGEDAILYUSAGE;
        objDfltAvgDailyUsage.StartDate__c = Date.today();
        defaultAverageDailyUsageList.add(objDfltAvgDailyUsage);
        
        DefaultAverageDailyUsage__c objDfltAvgDailyUsage2 = new DefaultAverageDailyUsage__c();
        objDfltAvgDailyUsage2.DeviceSize__c = objDeviceSize.Id;       
        objDfltAvgDailyUsage2.NumberofOccupiers__c = 1;
        objDfltAvgDailyUsage2.AverageDailyUsage__c = AVERAGEDAILYUSAGE;
        objDfltAvgDailyUsage2.StartDate__c = Date.today();
        defaultAverageDailyUsageList.add(objDfltAvgDailyUsage2);
        
        DefaultAverageDailyUsage__c objDfltAvgDailyUsage1 = new DefaultAverageDailyUsage__c();
        objDfltAvgDailyUsage1.DeviceSize__c = objDeviceSize.Id;
        objDfltAvgDailyUsage1.AverageDailyUsage__c = AVERAGEDAILYUSAGE;
        objDfltAvgDailyUsage1.StartDate__c = Date.today() - 10 ;
        defaultAverageDailyUsageList.add(objDfltAvgDailyUsage1);
        
        if(!defaultAverageDailyUsageList.isEmpty())
            insert defaultAverageDailyUsageList;
       

         // Create ServiceType
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE) ;
        Database.insert(objServiceType);
        
        // Create Division
        Division__c objDivision = GlUt_FactoryData_Test.createDivision() ;
        Database.insert(objDivision);
        
        // Create Wholesaler
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER) ;
        Database.insert(objWholesaler);
        
        List<AvailableService__c> lstAvailableService= new List<AvailableService__c>();
        // Create Available Services
        AvailableService__c objAvailableService1 =  GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE1,objDivision,objServiceType, listSupplyPoint[0], objWholesaler) ;
        lstAvailableService.add(objAvailableService1);
        // Create Available Services
        AvailableService__c objAvailableService2 =  GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE2,objDivision,objServiceType, listSupplyPoint[1], objWholesaler) ;
        lstAvailableService.add(objAvailableService2);
        Database.insert(lstAvailableService);
                  
        List<Service__c> lstService= new List<Service__c>();
        // Create Services
        Service__c objService1  =  GlUt_FactoryData_Test.createService(objContract,listReading[0], objServiceType, listSupplyPoint[0], lstAvailableService[0]) ;
        lstService.add(objService1);
        // Create Services
        Service__c objService2  =  GlUt_FactoryData_Test.createService(objContract,listReading[1], objServiceType, listSupplyPoint[1], lstAvailableService[1]) ;
        lstService.add(objService2);
        Database.insert(lstService);      
        
    }
    
    /*******************************************************************
    Purpose: Method to insert average daily uses records while movein
             reading is captured in HH{Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calculateADU_PositiveHH(){
       setRollingDailyUsageSetting(); // Added By Echo: Dependra Singh - 12-03-2018-Meta data type fix 
       User dummyUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
       
        system.runAs(dummyUser){
            Set<Id> deviceIdSet = new Set<Id> ();            
            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
            List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE SerialNo__c = :SERIAL_NO1 ];
            List<Reading__c> readingList = [SELECT Id, Device__c, ReadingDate__c FROM Reading__c];
            Account objAccount = [SELECT id FROM Account WHERE RecordTypeId =: accHHRecordTypeId LIMIT 1];
            Location__c objLocation = [SELECT id FROM Location__c WHERE LocationType__c =: HOUSEHOLD LIMIT 1]; 
            
            // create Location Occupant record
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            locOccObj.StartDate__c = System.today() - 10;
            locOccObj.EndDate__c = null;
            locOccObj.Primary__c = true;
            Database.insert(locOccObj); 
            
            for (Device__c device : deviceList) {
                deviceIdSet.add(device.Id);
            }
            
            for(Reading__c reading: readingList){
                deviceIdMap.put(reading.Device__c,reading.ReadingDate__c);
            }
                 
            
            List<AverageDailyUsage__c > listOldADU = [SELECT id FROM AverageDailyUsage__c  ]; 
                        
            Reading__c  objReading = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading.ActualDeviceReading__c= ACTUALREADING1;
            objReading.ReadingDate__c = Date.today();
            objReading.ReadingType__c = GlUt_Constants.MOVEIN ;                
            insert objReading;
         
            Test.startTest();          
            BlUt_ADUCalculation.calculateADU(deviceIdMap,null);
            Test.StopTest();
            
            list<AverageDailyUsage__c > listDailyUse = [SELECT Id,StartDate__c, EndDate__c,SupplyPointDevice__c FROM AverageDailyUsage__c  WHERE ID IN: listOldADU];
           
            for( AverageDailyUsage__c  adu: listDailyUse){
                system.assert(adu.EndDate__c != Date.today() - 1); 
            } 
        }
    }
        
        
    /*******************************************************************
    Purpose: Method to insert regular reading in HH property
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calculateADU_HHPositiveRegular(){
       setRollingDailyUsageSetting(); // Added By Echo: Dependra Singh - 12-03-2018-Meta data type fix 
       User dummyUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
       
        system.runAs(dummyUser){
            Set<Id> deviceIdSet = new Set<Id> ();                                 
            List<AverageDailyUsage__c > listMoveInADU = new List<AverageDailyUsage__c>();
            
            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
            List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE SerialNo__c = :SERIAL_NO1 ];
            List<Reading__c> readingList = [SELECT Id, Device__c, ReadingDate__c FROM Reading__c];
            Account objAccount = [SELECT id FROM Account WHERE RecordTypeId =: accHHRecordTypeId LIMIT 1];
            Location__c objLocation = [SELECT id FROM Location__c WHERE LocationType__c =: HOUSEHOLD LIMIT 1];
            
            // create Location Occupant record
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            locOccObj.StartDate__c = System.today() - 10;
            locOccObj.EndDate__c = null;
            locOccObj.Primary__c = true;
            Database.insert(locOccObj);   
            
            objLocation.VoidEndDate__c = locOccObj.StartDate__c - 1;
            objLocation.VoidStartDate__c = null;
            Database.update(objLocation);
            
            for (Device__c device : deviceList) {
                deviceIdSet.add(device.Id); 
            }
            
            for(Reading__c reading: readingList){
                deviceIdMap.put(reading.Device__c,reading.ReadingDate__c);
            }
                       
            for(SupplyPointDevice__c objSPD : [SELECT Id FROM SupplyPointDevice__c WHERE Device__c In: deviceIdSet AND RemovalDate__c = null]){                
                AverageDailyUsage__c objADU = GlUt_FactoryData_Test.createAvgDailyUses(objSPD);
                objADU.StartDate__c = System.today() - 30; 
                listMoveInADU.add(objADU); 
            }
            if(!listMoveInADU.isEmpty())
            	Database.insert(listMoveInADU);           
           
            // two Actual reading            
            Reading__c  objReading1 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading1.ActualDeviceReading__c= ACTUALREADING1;
            objReading1.ReadingDate__c = Date.today() - 10;
            objReading1.ReadingType__c = GlUt_Constants.MOVEIN ;
            objReading1.ReadingMethod__c = GlUt_Constants.ACTUAL;                
            insert objReading1;
            
            Reading__c objReading2 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading2.ActualDeviceReading__c= ACTUALREADING2;
            objReading2.ReadingDate__c = Date.today() - 1;
            objReading2.ReadingType__c = GlUt_Constants.REGULAR ;
            objReading2.ReadingMethod__c = GlUt_Constants.ACTUAL;                
            insert objReading2;
            
            Test.startTest();              
            BlUt_ADUCalculation.calculateADU(deviceIdMap,null);            
            Test.StopTest();
            
            list<AverageDailyUsage__c> listDailyUse = [SELECT Id,StartDate__c, EndDate__c,SupplyPointDevice__c FROM AverageDailyUsage__c ];            
            system.assert(listDailyUse.size() > 0);  
        }
    }
    
    /*******************************************************************
    Purpose: Method to insert leak reading in HH{Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calculateADU_PositiveLeak(){
        setRollingDailyUsageSetting(); // Added By Echo: Dependra Singh - 12-03-2018-Meta data type fix  
       User dummyUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
       
        system.runAs(dummyUser){           
            Set<Id> deviceIdSet = new Set<Id> ();         
            List<AverageDailyUsage__c> listMoveInADU = new List<AverageDailyUsage__c>();
            List<Reading__c> readingList = [SELECT Id, Device__c, ReadingDate__c FROM Reading__c];
            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
            List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE SerialNo__c = :SERIAL_NO1 ];
            Account objAccount = [SELECT id FROM Account WHERE RecordTypeId =: accHHRecordTypeId LIMIT 1];
            Location__c objLocation = [SELECT id FROM Location__c WHERE LocationType__c =: HOUSEHOLD LIMIT 1];
            
            // create Location Occupant record
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            locOccObj.StartDate__c = System.today() - 10;
            locOccObj.EndDate__c = null;
            locOccObj.Primary__c = true;
            Database.insert(locOccObj);    
            
            objLocation.VoidStartDate__c = null;    // AT-3827
            database.update(objLocation);   // AT-3827
            
            for (Device__c device : deviceList) {
                deviceIdSet.add(device.Id); 
            }    
            
            for(Reading__c reading: readingList){
                deviceIdMap.put(reading.Device__c,reading.ReadingDate__c);
            }
            
            for(SupplyPointDevice__c objSPD:[SELECT Id FROM SupplyPointDevice__c WHERE Device__c In: deviceIdSet AND RemovalDate__c = null LIMIT 1]){                
                AverageDailyUsage__c objADU = GlUt_FactoryData_Test.createAvgDailyUses(objSPD);
                objADU.StartDate__c = System.today() - 30; 
                listMoveInADU.add(objADU); 
            }
            if(!listMoveInADU.isEmpty()) 
           		Database.insert(listMoveInADU); 
           
            // old Actual reading
            Reading__c  objReading1 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading1.ActualDeviceReading__c= ACTUALREADING1;
            objReading1.ReadingDate__c = Date.today() - 10;
            objReading1.ReadingType__c = GlUt_Constants.MOVEIN ;
            objReading1.ReadingMethod__c = GlUt_Constants.ACTUAL;                
            insert objReading1;            
            
            // Leak reading
            Reading__c  objReading2 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading2.ActualDeviceReading__c= ACTUALREADING2;
            objReading2.EffectiveDeviceReading__c= ACTUALREADING1 + 50;
            objReading2.ReadingDate__c = Date.today() - 1;
            objReading2.ReadingMethod__c = GlUt_Constants.ACTUAL; 
            objReading2.Tripped__c = true;  
            objReading2.Leak__c = true;
            insert objReading2;
            
            Test.startTest();          
            BlUt_ADUCalculation.calculateADU(deviceIdMap,null);
            Test.StopTest();
            
            list<AverageDailyUsage__c > listDailyUse = [SELECT Id,StartDate__c, EndDate__c,SupplyPointDevice__c FROM AverageDailyUsage__c ];            
            system.assert(listDailyUse.size() > 0); 
        }
    }
    
    /*******************************************************************
    Purpose: Method to No dadu exist in system HH{Negative scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/  
    static testmethod void calculateADU_HHNegative(){
         setRollingDailyUsageSetting(); // Added By Echo: Dependra Singh - 12-03-2018-Meta data type fix 
       User dummyUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
       
        system.runAs(dummyUser){
            Set<Id> deviceIdSet = new Set<Id> ();
            
            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
            List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE SerialNo__c = :SERIAL_NO1 ];
            List<Reading__c> readingList = [SELECT Id, Device__c, ReadingDate__c FROM Reading__c];
            Account objAccount = [SELECT id FROM Account WHERE RecordTypeId =: accHHRecordTypeId LIMIT 1];
            Location__c objLocation = [SELECT id FROM Location__c WHERE LocationType__c =: HOUSEHOLD LIMIT 1];
            
            // create Location Occupant record
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            locOccObj.StartDate__c = System.today() - 10;
            locOccObj.EndDate__c = null;
            locOccObj.Primary__c = true;
            Database.insert(locOccObj);  
            
            objLocation.VoidStartDate__c = null;    // AT-3827
            database.update(objLocation);	 // AT-3827
            
            for (Device__c device : deviceList) {
                deviceIdSet.add(device.Id);
            }    
            
            /*for(Reading__c reading: readingList){
                deviceIdMap.put(reading.Device__c,reading.ReadingDate__c);
            }*/
           
            // Actual reading
            Reading__c  objReading1 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading1.ActualDeviceReading__c= ACTUALREADING1;
            objReading1.ReadingDate__c = Date.today() - 30;
            objReading1.ReadingType__c = GlUt_Constants.REGULAR ;
            objReading1.ReadingMethod__c = GlUt_Constants.ACTUAL;                 
            insert objReading1;            
                       
            Test.startTest();            
            BlUt_ADUCalculation.calculateADU(deviceIdMap,null);
            Test.StopTest();
            
            list<AverageDailyUsage__c> listDailyUse = [SELECT Id,StartDate__c, EndDate__c,SupplyPointDevice__c FROM AverageDailyUsage__c ];
            System.debug('listDailyUse = '+listDailyUse);
            system.assert(listDailyUse.size() == 0); 
        }
    }
    
    /*******************************************************************
    Purpose: Method to insert average daily uses records while movein
             reading is captured in NHH{Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calculateADU_PositiveNHH(){
          setRollingDailyUsageSetting(); // Added By Echo: Dependra Singh - 12-03-2018-Meta data type fix
       User dummyUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        
        system.runAs(dummyUser){
            Set<Id> deviceIdSet = new Set<Id> ();
            
            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
            List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE SerialNo__c = :SERIAL_NO2];
            List<Reading__c> readingList = [SELECT Id, Device__c, ReadingDate__c FROM Reading__c];
            Account objAccount = [SELECT id FROM Account WHERE RecordTypeId =: accNHHRecordTypeId LIMIT 1];
            Location__c objLocation = [SELECT id FROM Location__c WHERE LocationType__c =: NONHOUSEHOLD LIMIT 1];
            
            // create Location Occupant record
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            locOccObj.StartDate__c = System.today() - 10;
            locOccObj.EndDate__c = null;
            locOccObj.Primary__c = true;
            Database.insert(locOccObj); 
            
            objLocation.VoidStartDate__c = null;    // AT-3827
            database.update(objLocation);
                        
            for (Device__c device : deviceList) {
                deviceIdSet.add(device.Id);
            }
            
            for(Reading__c reading: readingList){
                deviceIdMap.put(reading.Device__c,reading.ReadingDate__c);
            }
            
            List<AverageDailyUsage__c> listOldADU = [SELECT id FROM AverageDailyUsage__c ]; 
                        
            Reading__c  objReading1 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading1.ActualDeviceReading__c= ACTUALREADING1;
            objReading1.ReadingType__c = GlUt_Constants.MOVEIN ;
            objReading1.ReadingDate__c = Date.today();   
            insert objReading1;
            
            Test.startTest();
            BlUt_ADUCalculation.calculateADU(deviceIdMap,null);
            Test.StopTest();
            
            list<AverageDailyUsage__c> listDailyUse = [SELECT Id,StartDate__c, EndDate__c,SupplyPointDevice__c FROM AverageDailyUsage__c WHERE ID IN: listOldADU];         
            for( AverageDailyUsage__c adu: listDailyUse){
                system.assert(adu.EndDate__c != Date.today() - 1); 
            } 
        }
    }
 
    /*******************************************************************
    Purpose: Method to insert average daily uses records while new reading is captured in NHH
             {Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calculateADU_PositiveMoveOut(){
       setRollingDailyUsageSetting(); // Added By Echo: Dependra Singh - 12-03-2018-Meta data type fix
       User dummyUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];       
        system.runAs(dummyUser){ 
            Set<Id> deviceIdSet = new Set<Id> ();
            List<AverageDailyUsage__c> listMoveInADU = new List<AverageDailyUsage__c>();   
            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
            List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE SerialNo__c = :SERIAL_NO2];
            List<Reading__c> readingList = [SELECT Id, Device__c, ReadingDate__c FROM Reading__c];
            Account objAccount = [SELECT id FROM Account WHERE RecordTypeId =: accNHHRecordTypeId LIMIT 1];
            Location__c objLocation = [SELECT id FROM Location__c WHERE LocationType__c =: NONHOUSEHOLD LIMIT 1];
            
            // create Location Occupant record
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            locOccObj.StartDate__c = System.today() - 10;
            locOccObj.EndDate__c = null;
            locOccObj.Primary__c = true;
            Database.insert(locOccObj); 
            
            for (Device__c device : deviceList) {
                deviceIdSet.add(device.Id); 
            }
            
            for(Reading__c reading: readingList){
                deviceIdMap.put(reading.Device__c,reading.ReadingDate__c);
            }
            
            for(SupplyPointDevice__c objSPD:[SELECT Id FROM SupplyPointDevice__c WHERE Device__c In: deviceIdSet AND RemovalDate__c = null LIMIT 1]){                
                AverageDailyUsage__c objADU = GlUt_FactoryData_Test.createAvgDailyUses(objSPD);
                objADU.StartDate__c = System.today() - 30; 
                listMoveInADU.add(objADU); 
            }
            if(!listMoveInADU.isEmpty())
            	Database.insert(listMoveInADU);  
                        
            Reading__c  objReading1 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading1.ActualDeviceReading__c= ACTUALREADING1;
            objReading1.ReadingType__c = GlUt_Constants.MOVEOUT ;
            objReading1.ReadingDate__c = Date.today() - 1;  
            insert objReading1;
            
            List<Location__c> listLoc = [SELECT Id,VoidStartDate__c FROM Location__c];
            List<Location__c> listVoidLoc = new List<Location__c>();            
            for(Location__c loc: listLoc){
                loc.VoidStartDate__c =  Date.today();
                listVoidLoc.add(loc);
            } 
            Database.update(listVoidLoc);
            
            Test.startTest();           
            BlUt_ADUCalculation.calculateADU(deviceIdMap,null);                      
            Test.StopTest();            
         
            AverageDailyUsage__c dailyUse = [SELECT Id,StartDate__c, EndDate__c,SupplyPointDevice__c,AverageDailyUsage__c FROM AverageDailyUsage__c WHERE StartDate__c =: Date.today() - 1 LIMIT 1];  // AT-3877
            system.assert(dailyUse.AverageDailyUsage__c == 0);
               
        }
    }
    
    /******************************************************************
    Purpose: Method to estimated reading NHH{Negative scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    static testmethod void calculateADU_NHHNegative(){
        setRollingDailyUsageSetting(); // Added By Echo: Dependra Singh - 12-03-2018-Meta data type fix
        User dummyUser = [SELECT id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(dummyUser){
            Set<Id> deviceIdSet = new Set<Id> ();
            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
            List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE SerialNo__c = :SERIAL_NO2 ];
            List<Reading__c> readingList = [SELECT Id, Device__c, ReadingDate__c FROM Reading__c];
            Account objAccount = [SELECT id FROM Account WHERE RecordTypeId =: accNHHRecordTypeId LIMIT 1];
            Location__c objLocation = [SELECT id FROM Location__c WHERE LocationType__c =: NONHOUSEHOLD LIMIT 1];
            
            // create Location Occupant record
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
            locOccObj.StartDate__c = System.today() - 10;
            locOccObj.EndDate__c = null;
            locOccObj.Primary__c = true;
            Database.insert(locOccObj);   
            objLocation.VoidStartDate__c = null;    // AT-3827
            database.update(objLocation);   // AT-3827
            for (Device__c device : deviceList) {
                deviceIdSet.add(device.Id);
            } 
            List<AverageDailyUsage__c> listoldADU = [SELECT id FROM AverageDailyUsage__c ];
            // estimated reading
            Reading__c  objReading1 = GlUt_FactoryData_Test.createReading(deviceList[0]);
            objReading1.ActualDeviceReading__c= ACTUALREADING1;
            objReading1.ReadingDate__c = Date.today() - 30;
            objReading1.ReadingType__c = GlUt_Constants.REGULAR ;
            objReading1.ReadingMethod__c = GlUt_Constants.ACTUAL;                 
            insert objReading1;            
            
            Test.startTest();            
            BlUt_ADUCalculation.calculateADU(deviceIdMap,null);
            Test.StopTest();
            
            list<AverageDailyUsage__c> listDailyUse = [SELECT Id,StartDate__c, EndDate__c,SupplyPointDevice__c FROM AverageDailyUsage__c WHERE ID NOT IN :listoldADU ];
            system.assert(listDailyUse.size() == 0); 
            
        }
    }
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        13 Mar 2019
    @description: Rolling Daily Usage Setting Custom meta data type Data
    *******************************************************************************/ 
    private static void setRollingDailyUsageSetting(){
        GlUt_CustomMetaDataUtility.setMetadata(GlUt_Constants.ROLLINGDAILYUSAGEQUERY,(List<RollingDailyUsage__mdt>) JSON.deserialize( 
            '[{"' + GlUt_Constants.USEROLLINGAVERAGEAPINAME + '":"' + GlUt_Constants.USEROLLINGAVERAGEAPINAMEVALUE + '"}]',List<RollingDailyUsage__mdt>.class )); 
    }
}