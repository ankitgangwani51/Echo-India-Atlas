/******************************************************************************
@author:      Echo: Swati Mathur
@date:        25 Sept 2018
@description: Test Class for GlUt_CustMoveAmendUtility
*******************************************************************************/
@isTest
Public Class GlUt_CustMoveAmendUtility_Test{
    
    //Variable declaration start
    
    private static String USER_PROFILE		 		= 'System Administrator';
    private static String USER_NAME			 		= 'TestUser'; 
    private static String ACCOUNT_NAME 				= 'TestAccount'; 
    private static String CONTRACT_NAME 			= 'Test Contract';
    private static final String STATE 				= 'Test State';
    private static final String CITY 				= 'Test City';
    private static final String POSTCODE 			= 'WS4 EB6';
    private static final String COUNTRY 			= 'UK';
    private static String ZIPCODE					= 'ws2 8de';
    private static String OPERATOR					= 'Equals';
    private static String PROPERTY					= 'Zip/Postal Code';
    private static final String DEVICE_SIZE 		= 'TestDeviceSize';    
    private static final String DEVICE_NAME 		= 'TestDevice';
    private static final String MANUFACTURER 		= 'Siemens';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String STREET 				= 'teststreet';
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    private static final String MEASURED 			= 'Monthly';
    private static final String AVAILABLESERVICES 	= 'TestAvailableService';
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';
    private static final String BUNDLE              = 'TestBundle';
    private static final String BUNDLEITEM          = 'TestBundleItem';
    private static final String WHOLESALER          = 'TestWholesaler';
    private static final String TEST_SERVICE_TYPE 	= 'TestServiceType';
    private static final String ACTUAL				= 'Actual';
    
    //Variable declaration end
    
    /*******************************************************************
    Purpose: method to create test data used by all USER_NAMEtest methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        con.BillingStreet__c = STREET;
        con.BillingCity__c = CITY;
        con.BillingState__c = STATE;
        con.BillingPostalCode__c = POSTCODE;
        con.BillingCountry__c = COUNTRY;
        Database.insert(con);
        
        //Create location record      
        Location__c  objLocation = GlUt_FactoryData_Test.CreateLocation(ZIPCODE);
        Database.insert(objLocation);
        
        //Create location occupant record    
        LocationOccupant__c objLocationOccupants = GlUt_FactoryData_Test.CreateLocationOccupant(objAccount,objLocation);
        objLocationOccupants.Primary__c = TRUE;
        Database.insert(objLocationOccupants);        
        
        //Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        //Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Insert device record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);        
          
        //Insert list of readings
        List<Reading__c>  objReadingList = new List<Reading__c>();
        for(integer i=0; i<=1; i++){
            Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
            objReading.ReadingType__c = System.Label.CuAp_ReadingReadingTypeMoveIn;
            objReading.ReadingMethod__c = ACTUAL;            
            objReadingList.add(objReading);
        }
        objReadingList[0].ActualDeviceReading__c = '10';
        objReadingList[0].ReadingDate__c = System.today().addDays(-10);
        objReadingList[1].ActualDeviceReading__c = '20';
        objReadingList[1].ReadingDate__c = System.today().addDays(-5);
        Database.insert(objReadingList);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Insert supply point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; 
        Database.insert(objSupplyPoint);
        
        //Insert supply point device record
        SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
                 
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
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
        Service__c  objService = GlUt_FactoryData_Test.createService(con,objReadingList[0],objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle('', objBundle, objAvailableService);
        Database.insert(objAvailableBundle);
        
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem('', objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);
        
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        Database.insert(objServiceItem);
       
	
    }   
    
    /******************************************************************************
    @author:      Ankit Gangwani
    @date:        25-Sep 2018
    @description: Test method for preRequisite() method
    *******************************************************************************/
    static testmethod void preRequisite_Positive_Null_Move_Out_Date(){
        
        //Query user record created in test setup data method
        User objUser =[Select Id,Name from user where isActive = true limit 1];
        Account objAccount =[Select Id,Name from Account LIMIT 1];
        LocationOccupant__c objLocationOccupant =[Select Id,Name from LocationOccupant__c];
        Location__c objLocation =[Select Id,Name from Location__c LIMIT 1];
        List<Reading__c> readingsList =[Select Id ,Name, Device__c, ReadingType__c, ActualDeviceReading__c, ReadingMethod__c, ReadingDate__c from Reading__c];
        BillingContract__c objCon =[Select Id,Name from BillingContract__c LIMIT 1];
        
        Date moveInDate = System.today().addDays(+3);
        Date moveOutDate = NULL;
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            Set<Id> setContractIds = GlUt_CustMoveAmendUtility.preRequisite(objAccount.Id, objLocationOccupant.Id, objLocation.Id, readingsList, 'false', moveInDate, moveOutDate, objCon);
            Test.stopTest();
            System.assert(setContractIds != null);            
        }
    }    
    
    /******************************************************************************
    @author:      Ankit Gangwani
    @date:        26-Sep 2018
    @description: Test method for preRequisite() method
    *******************************************************************************/
    static testmethod void preRequisite_Positive_Null_Move_IN_Date(){
        
        //Query user record created in test setup data method
        User objUser =[Select Id,Name from user where isActive = TRUE LIMIT 1];
        
        Account objAccount =[Select Id,Name from Account LIMIT 1];
        
        LocationOccupant__c objLocationOccupant =[Select Id,Name, StartDate__c, EndDate__c from LocationOccupant__c LIMIT 1];
        objLocationOccupant.EndDate__c = NULL;
        Database.update(objLocationOccupant);
        
        Location__c objLocation =[Select Id,Name from Location__c LIMIT 1];
        List<Reading__c> readingsList =[Select Id ,Name, Device__c, ReadingType__c, ActualDeviceReading__c, ReadingMethod__c, ReadingDate__c from Reading__c];
        BillingContract__c objCon =[Select Id,Name from BillingContract__c LIMIT 1];
        
        Date moveInDate = NULL;
        Date moveOutDate = System.today().addDays(+3);
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            Set<Id> setContractIds = GlUt_CustMoveAmendUtility.preRequisite(objAccount.Id, objLocationOccupant.Id, objLocation.Id, readingsList, 'false', moveInDate, moveOutDate, objCon);
            Test.stopTest();
            System.assert(setContractIds != null); 
            
        }
    }
    
    /******************************************************************************
    @author:      Ankit Gangwani
    @date:        26-Sep 2018
    @description: Test method for preRequisite() method
    *******************************************************************************/
    static testmethod void preRequisite_Positive_Null_Move_IN_Date_1(){        
        //Query user record created in test setup data method
        User objUser =[Select Id,Name from user where isActive = TRUE LIMIT 1];        
        Account objAccount =[Select Id,Name from Account LIMIT 1];        
        LocationOccupant__c objLocationOccupant =[Select Id,Name, StartDate__c, EndDate__c from LocationOccupant__c LIMIT 1];
        objLocationOccupant.EndDate__c = NULL;
        Database.update(objLocationOccupant);
        
        Location__c objLocation =[Select Id,Name from Location__c LIMIT 1];
        List<Reading__c> readingsList =[Select Id ,Name, Device__c, ReadingType__c, ActualDeviceReading__c, ReadingMethod__c, ReadingDate__c from Reading__c];
        BillingContract__c objCon =[Select Id,Name from BillingContract__c LIMIT 1];
        
        Date moveInDate = NULL;
        Date moveOutDate = System.today().adddays(10);
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            Set<Id> setContractIds = GlUt_CustMoveAmendUtility.preRequisite(objAccount.Id, objLocationOccupant.Id, objLocation.Id, readingsList, 'false', moveInDate, moveOutDate, objCon);
            Test.stopTest();
            System.assert(setContractIds != null); 
        }
    }
    
    /******************************************************************************
    @author:      Ankit Gangwani
    @date:        26-Sep 2018
    @description: Test method for preRequisite() method
    *******************************************************************************/
    static testmethod void preRequisite_Positive_Null_Move_OUT_Date_1(){
        
        //Query user record created in test setup data method
        User objUser =[Select Id,Name from user where isActive = TRUE LIMIT 1];
        
        Account objAccount =[Select Id,Name from Account LIMIT 1];
        
        LocationOccupant__c objLocationOccupant = [Select Id, 
                                                   Name,
                                                   StartDate__c,
                                                   EndDate__c
                                                   from LocationOccupant__c
                                                   LIMIT 1];
        objLocationOccupant.EndDate__c = NULL;
        Database.update(objLocationOccupant);
        
        Location__c objLocation =[Select Id,Name from Location__c];
        List<Reading__c> readingsList =[Select Id ,Name, Device__c, ReadingType__c, ActualDeviceReading__c, ReadingMethod__c, ReadingDate__c from Reading__c];
        BillingContract__c objCon =[Select Id,Name from BillingContract__c];
        
        Date moveInDate = System.today();
        Date moveOutDate = NULL;
        //Run test class in user context
        system.runas(objUser){            
            Test.startTest();
            Set<Id> setContractIds = GlUt_CustMoveAmendUtility.preRequisite(objAccount.Id, objLocationOccupant.Id, objLocation.Id, readingsList, 'false', moveInDate, moveOutDate, objCon);
            Test.stopTest();
            System.assert(setContractIds != null); 
        }
    }
    
    /******************************************************************************
    @author:      Swati Mathur
    @date:        25-Sep 2018
    @description: Test method for preRequisite() method
    *******************************************************************************/
    static testmethod void preRequisite_deleteRecordScenario(){
        
        //Query user record created in test setup data method
        User objUser =[Select Id,Name from user where isActive = true limit 1];
        Account objAccount =[Select Id,Name from Account];
        LocationOccupant__c objLocationOccupant =[Select Id,Name from LocationOccupant__c];
        Location__c objLocation =[Select Id,Name from Location__c];
        List<Reading__c> readingsList =[Select Id ,Name, Device__c, ReadingType__c, ActualDeviceReading__c, ReadingMethod__c, ReadingDate__c from Reading__c];
        BillingContract__c objCon =[Select Id,Name from BillingContract__c];
        
        Date moveInDate = System.today().addDays(-15);
        Date moveOutDate = System.today().addDays(+5);
        //Run test class in user context
        system.runAs(objUser){
            
            Test.startTest();
            Set<Id> setContractIds = GlUt_CustMoveAmendUtility.preRequisite(objAccount.Id, objLocationOccupant.Id, objLocation.Id, readingsList, 'true', moveInDate, moveOutDate, objCon);
            Test.stopTest();
            System.assert(setContractIds != null); 
            
        }
    }

}