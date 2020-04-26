/******************************************************************************
@author         Dependra Singh
@date           16 July 2018
@description    Batch Class For Renewal process for stepped 
*******************************************************************************/
@isTest
public class BlBt_SteppedRenewalProcess_Test {
    
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestXmlExtractUser'; 
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME ='TestContract';
    private static final String STATE = 'Test State';
    private static final String CITY = 'Test City';
    private static final String POSTCODE = 'WS4 EB6';
    private static final String COUNTRY = 'UK'; 
    private static final String STREET = 'Test Street';
    private static final String USERNAMECOMPLETE = USER_NAME+ '@unitest.com';
    private static final String ACCEMAIL = 'test78887@abc.com';
    private static final String ACCFAX = '8888777767';
    private static final String ACCVAT = '786654';
    private static final String ACCWEBSITE = 'www.testAcc988.com';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String BILLNAME = 'testBill';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    
    /******************************************************************
    @author: Echo: Dependra Singh
    @date:   17 July 2018
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
        
    @testSetup
    static void createTestData(){
        
        //Insert user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser);
        
        //Insert account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount.Email__c = ACCEMAIL;
        objAccount.Fax = ACCFAX;
        objAccount.Website = ACCWEBSITE;
        Database.insert(objAccount);
        
        //Insert contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        objContract.BillingStreet__c = STREET;
        objContract.BillingCity__c = CITY;
        objContract.BillingState__c = STATE;
        objContract.BillingPostalCode__c = POSTCODE;
        objContract.BillingCountry__c = COUNTRY;
        Database.insert(objContract);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Insert device record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        //Insert service type record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        //Insert list of readings
        List<Reading__c>  objReadingList = new List<Reading__c>();
        for(integer i=0; i<=1; i++){
            Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
            objReadingList.add(objReading);
        }
        objReadingList[0].ReadingDate__c = System.today().addDays(-10);
        objReadingList[1].ReadingDate__c = System.today().addDays(-5);
        Database.insert(objReadingList);
        
        //Insert location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        objLocation.Inactive__c = true;
        objLocation.InactiveDate__c = System.today();
        Database.insert(objLocation);
        
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Insert supply point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        //Insert supply point device record
        SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
        
        //Insert division record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        //Insert wholesaler record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Insert available service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Insert service record
        Service__c  objService = GlUt_FactoryData_Test.createService(objContract,objReadingList[0],objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        List<SteppedTariff__c>  steppedTariffList = new List<SteppedTariff__c>();
        for(integer i=0; i<=200; i++){
            SteppedTariff__c objSteppedTariff = GlUt_FactoryData_Test.createSteppedTariff(objContract,objServiceType);
            objSteppedTariff.StartDate__c = system.today().addDays(-i);
            objSteppedTariff.EndDate__c = system.today().addDays(i+1);
            steppedTariffList.add(objSteppedTariff);
        }
        if(!steppedTariffList.isEmpty()){
            insert steppedTariffList;
        }
    }
    
    /*******************************************************************
    @author:      ECHO:Dependra Singh
    @date:        17 July 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for execute
    ********************************************************************/
      static testmethod void execute_PositiveTest(){
        User objUser = [SELECT Id FROM User WHERE IsActive = True AND Username =: USERNAMECOMPLETE LIMIT 1];
        List<SteppedTariff__c> steppedTariffList = [Select Id, Name, StartDate__c, EndDate__c from SteppedTariff__c LIMIT 200];
		Service__c objService = [Select Id,ServiceType__c,SupplyPoint__c,AvailableService__c,BillingContract__c from Service__c LIMIT 1];
        List<SteppedTariffService__c>  steppedTariffServicesList = new List<SteppedTariffService__c>();
        for(integer i=0; i < 200; i++){
              if(steppedTariffList[i] != null){
                  SteppedTariffService__c objSteppedTariffService = GlUt_FactoryData_Test.createSteppedTariffService(steppedTariffList[i],objService);
                  objSteppedTariffService.StartDate__c = steppedTariffList[i].StartDate__c;
                  // objSteppedTariffService.EndDate__c = steppedTariffList[i].EndDate__c;
                  steppedTariffServicesList.add(objSteppedTariffService);
              }
          }
          if(!steppedTariffServicesList.isEmpty()){
              insert steppedTariffServicesList;
          }
          System.runAs(objUser){
              Test.startTest();
              SchedulableContext SC;
              BlBt_SteppedRenewalProcess objSteppedRenwal = new BlBt_SteppedRenewalProcess();
              objSteppedRenwal.execute(SC);
              Test.stopTest();
              
              List<SteppedTariff__c> lstStepTariff = [Select Id, Name from SteppedTariff__c LIMIT 1];
              system.assert(lstStepTariff.size() > 0);
          }
    }
    /*******************************************************************
    @author:      ECHO:Dependra Singh
    @date:        17 July 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for execute
    ********************************************************************/
      static testmethod void execute_NegativeTest(){
          User objUser = [SELECT Id FROM User WHERE IsActive = True AND Username =: USERNAMECOMPLETE LIMIT 1];
          System.runAs(objUser){
            Test.startTest();
            SchedulableContext SC;
            BlBt_SteppedRenewalProcess objSteppedRenwal = new BlBt_SteppedRenewalProcess();
            objSteppedRenwal.execute(SC);
            Test.stopTest();
            
            List<SteppedTariffService__c> lstStepTariffService = [Select Id, Name from SteppedTariffService__c LIMIT 1];
            system.assert(lstStepTariffService.size() == 0);
        }
    }
}