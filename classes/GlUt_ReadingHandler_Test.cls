/******************************************************************************
@author:      Accenture: Manish Singh
@date:        07 September 2017
@description: Test Class for GlUt_ReadingHandler
Revision(s):  Shivangi Gaur - 23-10-2017 - Updated test methods with data for Actual Device Reading.
              Shivangi Gaur - 24-10-2017 - Updated test methods with data for Actual Device Reading.
              Shivangi Gaur - 16-11-2017 - Updated test data setup method to have 1 active SPD per SP.
              Shivangi Gaur - 07-12-2017 - Incorporated review comments provided on AT-458 dated 05/12/2017.
*******************************************************************************/
@isTest
Public Class GlUt_ReadingHandler_Test{
    
    private static final String ACCOUNTNAME1        	= 'Test1 Account1';
    private static final String ACCOUNTNAME2        	= 'Test2 Account2';
    private static final String CONTRACTNAME        	= 'Test Contract';   
    private static final String LOCATION            	= 'A99 9AA';
    private static final String DETACHED            	= 'Detached';
    private static final String CUSTOMERNAME        	= 'Test customer';
    private static final String STRTEST             	= 'test';   
    private static final String DEVICENAME          	= 'TestDeviceName';   
    private static final String OLDACTUALREADING    	= '60';    
    private static final String ACTUALDEVICEREADING 	= '70'; 
    private static final Integer AVERAGEDAILYUSAGE  	= 10; 
    private static final Integer READINGDAYS        	= 12;
    private static final Integer LISTSIZE           	= 3; 
    private static final Integer LISTSTART          	= 0;   
    private static final String PROFILENAME         	= 'System Administrator';
    private static final String USERNAME            	= 'TestUser788';
    private static final String USERNAMECOMPLETE    	= USERNAME+ '@unitest.com';
    private static final Integer maxDMLstatements   	= 50;
    private static final Integer maxQueries         	= 70;
    private static final String SP_USAGE_TYPE       	= 'SupplyPointUsageType';
    private static final String DEVICE_SIZE         	= 'TestDeviceSize';
    private static final String MANUFACTURER        	= 'Siemens';
    private static final String UNIT_OF_MEASURE     	= 'Metric';
    private static final String HOUNSEHOLDACCOUNT   	= 'Household Account';
    private static final String NONHOUNSEHOLDACCOUNT 	='Non-Household Account';
    private static final String CONTACT_NAME2       	= 'test2';
    private static final String ACCOUNT_NAME2      		= 'TEST_ACCOUNT2';
    private static final String LOCATION_NAME2      	= 'A99 9AB';   
    private static final String DEVICE_SERIALNO2 		= '1235';
    private static final Integer DEVICE_DIGIT	    	= 5; 
    private static final String SUB_METER_READING		= '15'; 
    private static final String ACTUAL	            	= 'Actual' ;
    private static final String AREA	            	= 'North' ;
    private static final String DEPOT					= 'Leads' ;
    private static final String RURALOUTLETBILLINGTYPE	= 'Metered';
    private static final string INITAIL_ACTUALREADING 	= '0';
    private static final Date INSTALLATION_DATE 		= Date.today()-30;
    private static final Date DADU_STARTDATE 			= Date.today()-30;
    private static final String REGIONNAME 			    = 'AU';
    private static final Boolean IS_AU                  = true;
    private static final Boolean IS_UK					= false;    
    private static final Boolean IS_US					= false; 
        
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){  
        
        Id accHHRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(HOUNSEHOLDACCOUNT).getRecordTypeId();
        Id accNHHRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(NONHOUNSEHOLDACCOUNT).getRecordTypeId();
                
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        
        List<Account> accountList = new List<Account>();       
        //HH account record
        Account objAccountHH = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME1);
        objAccountHH.RecordTypeId = accHHRecordTypeId;
        accountList.add(objAccountHH);        
        //NHH account record
        Account objAccountNHH = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME2);
        objAccountNHH.RecordTypeId = accNHHRecordTypeId;
        accountList.add(objAccountNHH);
        //Account Record SUB
        Account objAccountSub = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);        
        accountList.add(objAccountSub);
        //Insert Account
        Database.insert(accountList);
        
        List<BillingContract__c> billingContractList = new List<BillingContract__c>();
        //HH BillingContract record
        BillingContract__c objContractHH = GlUt_FactoryData_Test.createContract(CONTRACTNAME, accountList[0]);
        billingContractList.add(objContractHH);
        //NHH BillingContract record
        BillingContract__c objContractNHH = GlUt_FactoryData_Test.createContract(CONTRACTNAME, accountList[1]);
        billingContractList.add(objContractNHH);
        //BillingContract record SUB
        BillingContract__c objContractSub = GlUt_FactoryData_Test.createContract(CONTACT_NAME2, accountList[2]);
        billingContractList.add(objContractSub);
        //Insert Billing Contract
        Database.insert(billingContractList);
            
        // Create Rural License Record
        RuralLicense__c  objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
        Database.insert(objRuralLicense);
        
        //Create Rural Entitlement Record    
    	RuralEntitlement__c objRuralEntitlement = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        objRuralEntitlement.Active__c = true;
        Database.insert(objRuralEntitlement);
          
        List<Location__c> locationList = new List<Location__c>();
        //location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION);
        objLocation.LocationSubType__c = DETACHED ; 
        objLocation.Street__c = STRTEST ;
        objLocation.RuralLicense__c = objRuralLicense.Id;         
        locationList.add(objLocation);
        //Location Record SUB       
        Location__c objLocationSub = GlUt_FactoryData_Test.createLocation(LOCATION_NAME2);
        objLocationSub.RuralLicense__c= objRuralLicense.Id;
        locationList.add(objLocationSub);
        //Insert Location Record
        Database.insert(locationList); 
        
        List<Location__c> locationUpdateList = new List<Location__c>();
        for(Location__c objLoc: locationList){
            objLoc.VoidStartDate__c = null;
            objLoc.VoidEndDate__c = INSTALLATION_DATE;
            locationUpdateList.add(objLoc);
        }
        database.upsert(locationUpdateList);
        
        List<LocationOccupant__c> LocationOccupantList = new List<LocationOccupant__c>();
        //active location occupant record
        LocationOccupant__c locOccHHObj = GlUt_FactoryData_Test.createLocationOccupant(accountList[0], locationList[0]);
        locOccHHObj.StartDate__c = System.today()-10;
        locOccHHObj.EndDate__c = null;
        locOccHHObj.Primary__c = true;
        LocationOccupantList.add(locOccHHObj);
        //location occupant record
        LocationOccupant__c locOccNHHObj = GlUt_FactoryData_Test.createLocationOccupant(accountList[1], locationList[0]);
        locOccNHHObj.StartDate__c = System.today()-10;
        locOccNHHObj.EndDate__c = null;
        LocationOccupantList.add(locOccNHHObj);
        //location Occupant Record SUB
        LocationOccupant__c objLocationOccupantSub = GlUt_FactoryData_Test.createLocationOccupant(accountList[2], locationList[1]);        
        LocationOccupantList.add(objLocationOccupantSub);
        //Insert occupant records
        Database.insert(LocationOccupantList);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create device records
        list<Device__c > listDevice = new list<Device__c >();
        for(integer i=LISTSTART ; i<LISTSIZE; i++){
            Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICENAME,objDeviceType);
            objDevice.SerialNo__c = objDevice.SerialNo__c+i;
            objDevice.Digit__c = DEVICE_DIGIT;
            listDevice.add(objDevice );
        }
        //Device Record SUB
        Device__c  objDeviceSub = GlUt_FactoryData_Test.CreateDevice(DEVICE_SERIALNO2 , objDeviceType);        
        objDeviceSub.SerialNo__c = DEVICE_SERIALNO2;
        listDevice.add(objDeviceSub);
        // Insert Device Records
        Database.insert(listDevice);
        
        //Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA);
        Database.insert(objArea);
        
        //Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT);
        Database.insert(objDepot);
                   
    	//Create Rural Channel Record    
    	RuralChannel__c objRuralChannel = GlUt_FactoryData_Test.createRuralChannel(objArea,objDepot);
        Database.insert(objRuralChannel);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
                       
        //Create supply point records
        list<SupplyPoint__c > listSupplyPoint = new list<SupplyPoint__c >();
        SupplyPoint__c objSupplyPointMain;
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
            objSupplyPoint.Measured__c = True; // AT-3174 
            objSupplyPoint.RecordTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_Constants.RURALOUTLETRECORDTYPE).getRecordTypeId(); // rural billing updates
            objSupplyPoint.RuralChannel__c = objRuralChannel.Id;
            objSupplyPoint.RuralOutLetBillingType__c = RURALOUTLETBILLINGTYPE;
            listSupplyPoint.add(objSupplyPoint);
            objSupplyPointMain = objSupplyPoint;
        }  
        //Supply point record SUB             
        SupplyPoint__c objSupplyPointSub = GlUt_FactoryData_Test.createSupplyPoint(locationList[1], objSupplyPointUsageType);
        objSupplyPointSub.Measured__c = true; // AT-3174 
        objSupplyPointSub.RecordTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_Constants.RURALOUTLETRECORDTYPE).getRecordTypeId(); // rural billing updates
        objSupplyPointSub.RuralChannel__c = objRuralChannel.Id;  
        objSupplyPointSub.RuralOutLetBillingType__c = RURALOUTLETBILLINGTYPE;
        listSupplyPoint.add(objSupplyPointSub);
        //Insert Supply Point record
        Database.insert(listSupplyPoint);       
        
        //Create reading and supply point device records
        list<Reading__c> listReading = new list<Reading__c>();
        list<SupplyPointDevice__c > listSupplyPointDevice = new list<SupplyPointDevice__c >();
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(listDevice[i], listSupplyPoint[i] );
            listSupplyPointDevice.add(objSPD);
            Reading__c  objReading = GlUt_FactoryData_Test.createReading(listDevice[i]);
            objReading.ActualDeviceReading__c = INITAIL_ACTUALREADING;
            objReading.ReadingDate__c = INSTALLATION_DATE; 
            objReading.BillableType__c = GlUt_Constants.BILLABLE;  
            objReading.ReadingMethod__c = GlUt_Constants.ACTUAL;
            listReading.add(objReading);
        }    
        //Supply Point Device SUB
        SupplyPointDevice__c objSPDSub = GlUt_FactoryData_Test.createSupplyPointDevices(listDevice[LISTSIZE], listSupplyPoint[LISTSIZE]);     
        listSupplyPointDevice.add(objSPDSub);
        //Reading record SUB
        Reading__c objReadingSub = GlUt_FactoryData_Test.createReading(objDeviceSub);
        objReadingSub.ActualDeviceReading__c = '10';
        objReadingSub.ReadingDate__c = system.today()-10;
        objReadingSub.Billed__c = true;
        objReadingSub.BillableType__c = GlUt_Constants.BILLABLE;    //'Billable';
        objReadingSub.ReadingMethod__c = GlUt_Constants.ACTUAL;
        listReading.add(objReadingSub);
        
        //Insert Supply Point Device Records
        Database.insert(listSupplyPointDevice);
        //Insert Reading Records
        Database.insert(listReading);
        
        //Create Default Average Daily Usage records 
        DefaultAverageDailyUsage__c objDfltAvgDailyUsage = new DefaultAverageDailyUsage__c();
        objDfltAvgDailyUsage.DeviceSize__c = objDeviceSize.Id;
        objDfltAvgDailyUsage.SupplyPointUsageType__c = objSupplyPointUsageType.Id;
        objDfltAvgDailyUsage.NumberofOccupiers__c = 1;
        objDfltAvgDailyUsage.AverageDailyUsage__c = AVERAGEDAILYUSAGE;
        objDfltAvgDailyUsage.StartDate__c = DADU_STARTDATE;
        Database.insert(objDfltAvgDailyUsage);
               
        // Create SupplyPointRelationship
        SupplyPointRelationship__c objSPR = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPointMain, objSupplyPointSub);
        objSPR.StartDate__c = system.today() - 10;
        Database.insert(objSPR);
        
        //Custom setting Region
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(REGIONNAME, IS_AU, IS_UK, IS_US );
        Database.insert(objRegion);
    }
   
    /*******************************************************************
    Purpose: Bulk testing Method to insert average daily uses records while 
             new reading is captured.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calAvgDailyUses_Bulk(){
        User dummyUser = [SELECT Id,Name
                          FROM user 
                          WHERE isActive=true 
                          AND username =: USERNAMECOMPLETE LIMIT 1];
        
        system.runAs(dummyUser){
            List<Device__c> listDevice = new List<Device__c>([SELECT Id FROM Device__c]); 
            List<Reading__c> listReading = new List<Reading__c>();           
            for(Integer i=LISTSTART; i<LISTSIZE; i++){
                Reading__c  objReading = GlUt_FactoryData_Test.createReading(listDevice[i]);
                objReading.ActualDeviceReading__c = ACTUALDEVICEREADING;
                objReading.ReadingDate__c = Date.today() + READINGDAYS;
                objReading.ReadingMethod__c = GlUt_Constants.ACTUAL;
                listReading.add(objReading);
            }            
            Test.startTest();
            Database.insert(listReading);            
            //Asserts to check limits
            System.assert( Limits.getDMLStatements() < maxDMLstatements, 'Fewer than ' + maxDMLstatements + ' DML statements should have been executed : ' + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < maxQueries      , 'Fewer than ' + maxQueries + ' SOQL statements should have been executed : ' + Limits.getQueries()  );
            Test.StopTest();         
        }
    }
    
    /*******************************************************************
    Purpose: Method to insert average daily uses records while new reading is captured.
             {Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calAvgDailyUses_Positive(){
        User dummyUser = [SELECT Id,Name
                          FROM user 
                          WHERE isActive=true 
                          AND username =: USERNAMECOMPLETE LIMIT 1];
        
        system.runAs(dummyUser){            
            Device__c device = [SELECT Id FROM Device__c LIMIT 1];
           
            // ENTER A BILLABLE-ACTUAL READING
            Reading__c  objReading = GlUt_FactoryData_Test.createReading(device);
            objReading.ActualDeviceReading__c= ACTUALDEVICEREADING;
            objReading.ReadingDate__c = Date.today() + READINGDAYS; 
            objReading.ReadingMethod__c = GlUt_Constants.ACTUAL;
            
            Test.startTest();
            Database.insert(objReading);            
            list<AverageDailyUsage__c> listDailyUse = [SELECT Id 
                                                       FROM AverageDailyUsage__c  
                                                       WHERE StartDate__c =: objReading.ReadingDate__c + 1];
            system.assert(listDailyUse.size() == 1);
            Test.StopTest();
        }
    }

    /*******************************************************************
    Purpose: Method to insert average daily uses records while new reading is captured.
             {Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void calAvgDailyUses_Negative(){
        User dummyUser = [SELECT Id,Name
                          FROM user 
                          WHERE isActive=true 
                          AND username =: USERNAMECOMPLETE LIMIT 1];
        
        system.runAs(dummyUser){            
            Device__c device = [SELECT Id FROM Device__c LIMIT 1];
            
            List<SupplyPointDevice__c> lstSPD = [SELECT id FROM SupplyPointDevice__c WHERE Device__c =: device.id];
            //deleting SPD so that there is no active SPD under the device to test negative scenario
            delete lstSPD;
            
            Reading__c  objReading = GlUt_FactoryData_Test.createReading(device );
            objReading.ActualDeviceReading__c= actualDeviceReading;
            objReading.ReadingDate__c = Date.today() + READINGDAYS; 
            objReading.ReadingMethod__c = GlUt_Constants.ACTUAL;
            Test.startTest();            
            Database.insert(objReading);
            Test.StopTest();
            
            list<AverageDailyUsage__c> listDailyUse = [SELECT Id FROM AverageDailyUsage__c ];
            system.assertEquals(listDailyUse.size(), 0); 
        }
    }
   
    /*******************************************************************
    Purpose: Method to insert average daily uses records while new reading is captured.
             {Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertMainSupplyReading(){
        User dummyUser = [SELECT Id,Name
                          FROM user 
                          WHERE isActive=true 
                          AND username =: USERNAMECOMPLETE LIMIT 1];
        
        system.runAs(dummyUser){  
           SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c FROM SupplyPointRelationship__c LIMIT 1];
           SupplyPointDevice__c objSPD = [SELECT Device__c
                                          FROM SupplyPointDevice__c
                                          WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                             AND Active__c = true LIMIT 1]; 
            
            // Create Reading Record
            Reading__c objReading = new Reading__c();
            objReading.Device__c = objSPD.Device__c;
            objReading.ActualDeviceReading__c = ACTUALDEVICEREADING;
            objReading.ReadingDate__c = system.today();
            objReading.Billed__c = false;
            objReading.BillableType__c = GlUt_Constants.BILLABLE;
            objReading.ReadingMethod__c = ACTUAL;
            
            Test.startTest();
            Database.insert(objReading);
            Test.StopTest();
            
            list<AverageDailyUsage__c> listDailyUse = [Select Id from AverageDailyUsage__c where SupplyPointDevice__c =: objSPD.Id and StartDate__c =: system.today() + 1  ];
            system.assert(listDailyUse.size() > 0);
            
        }
    }
   
    /*******************************************************************
    Purpose: Method to insert average daily uses records while new reading is captured.
             {Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertSubSupplyReading(){
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        system.runAs(dummyUser){  
            SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c,SubSupply__c FROM SupplyPointRelationship__c LIMIT 1];
            /* Main device reading */ 
            SupplyPointDevice__c objSPDMain = [SELECT Device__c
                                               FROM SupplyPointDevice__c
                                               WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                               AND Active__c = true LIMIT 1]; 
            List<Reading__c> mainReadingList = new List<Reading__c>();
            // Create Reading Record MAIN        
            Reading__c objReadingMain1 = new Reading__c();
            objReadingMain1.Device__c = objSPDMain.Device__c;
            objReadingMain1.ActualDeviceReading__c = OLDACTUALREADING;  //'60';
            objReadingMain1.ReadingDate__c = system.today() - 1;
            objReadingMain1.Billed__c = false;
            objReadingMain1.BillableType__c = GlUt_Constants.NONBILLABLE;
            objReadingMain1.ReadingMethod__c = ACTUAL;            
            mainReadingList.add(objReadingMain1);
           
            Reading__c objReadingMain = new Reading__c();
            objReadingMain.Device__c = objSPDMain.Device__c;
            objReadingMain.ActualDeviceReading__c = ACTUALDEVICEREADING;  //'70';
            objReadingMain.ReadingDate__c = system.today();
            objReadingMain.Billed__c = false;
            objReadingMain.BillableType__c = GlUt_Constants.NONBILLABLE;
            objReadingMain.ReadingMethod__c = ACTUAL;  
            mainReadingList.add(objReadingMain);
            
            Database.insert(mainReadingList);
            
            mainReadingList[0].AmendedByReading__c = mainReadingList[1].Id;
            Database.update(mainReadingList[0]);
            
            SupplyPointDevice__c objSPD = [SELECT Id,Device__c
                                           FROM SupplyPointDevice__c
                                           WHERE SupplyPoint__c =: objSPR.SubSupply__c
                                           AND Active__c = true LIMIT 1]; 
            // Create Reading Record
            Reading__c objReading = new Reading__c();
            objReading.Device__c = objSPD.Device__c;
            objReading.ActualDeviceReading__c = SUB_METER_READING; 
            objReading.ReadingDate__c = system.today();
            objReading.Billed__c = false;
            objReading.ReadingMethod__c = ACTUAL;
            objReading.BillableType__c = GlUt_Constants.BILLABLE;  
            
            Test.startTest();
            Database.insert(objReading);
            Test.StopTest();           
            list<AverageDailyUsage__c> listDailyUse = [Select Id from AverageDailyUsage__c where SupplyPointDevice__c =: objSPD.Id and StartDate__c =: system.today() + 1  ];
            system.assert(listDailyUse.size() > 0);
        }
    }    
}