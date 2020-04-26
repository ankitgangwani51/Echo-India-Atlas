/******************************************************************************
@author         Ankit Gangwani
@date           24 July 2018
@description    Test Class For BlAp_SteppedTariffAmendmentCtrlr
*******************************************************************************/
@isTest
public class BlAp_SteppedTariffAmendmentCtrlr_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String SNAME					= 'Test Name';
    private static final String strManufacturer			= 'Siemens';
    private static final String strUnitOfMeasure		= 'Metric';
    private static final String LOCATION_NAME			= 'A99 9AA';
    private static final String SP_USAGE_TYPE			= 'SupplyPointUsageType';
    private static final String AVAILABLESERVICES 		= 'TestAvailableServiceItem';
    private static final String WHOLESALER 				= 'TestWholesaler';
    private static final String MEASURED 				= 'Monthly';
    private static final String DUMMYDATA 				= 'Test';
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          24 July 2018 
    @param         -
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){  
       
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        objUser.Email = EMAIL_ADDRESS;
        Database.insert(objUser);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(SNAME);
        Database.insert(objAccount);
        
        // Create Contrat Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(objAccount);
        Database.insert(objContract);
        
        // Create Service Type Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SNAME);
        Database.insert(objServiceType);
        
        // Create Device Size Record
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(SNAME);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, strManufacturer, strUnitOfMeasure);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(SNAME, objDeviceType);
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading); 
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        Database.insert(objLocation);

        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174       
        Database.insert(objSupplyPoint);
        
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);
        
        // Create Service Item Family
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SNAME, objServiceType);
        objServiceItemFamily.AlgorithmType__c = System.Label.BlAp_MeasuredBilling;
        Database.insert(objServiceItemFamily);
        
        SteppedTariff__c objSteppedTariff = new SteppedTariff__c();
        objSteppedTariff.BillingContract__c = objContract.Id;
        objSteppedTariff.ServiceType__c = objServiceType.Id;
        objSteppedTariff.StartDate__c = Date.today();
        Database.insert(objSteppedTariff);
        
        SteppedTariffService__c objSteppedTariffService = new SteppedTariffService__c();
        objSteppedTariffService.Service__c = objService.Id;
        objSteppedTariffService.SteppedTariff__c = objSteppedTariff.Id;
        objSteppedTariffService.StartDate__c = Date.today();
        Database.insert(objSteppedTariffService);
        
        SteppedTariffService__c objSteppedTariffService2 = new SteppedTariffService__c();
        objSteppedTariffService2.Service__c = objService.Id;
        objSteppedTariffService2.SteppedTariff__c = objSteppedTariff.Id;
        objSteppedTariffService2.StartDate__c = Date.today();
        Database.insert(objSteppedTariffService2);
        
    }    
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveSteppedTariffFields(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            List<GlAp_FieldProps> fieldPropList = new List<GlAp_FieldProps>();
            try {                
                Test.starttest();
                fieldPropList = BlAp_SteppedTariffAmendmentCtrlr.retrieveSteppedTariffFields();
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(fieldPropList.size() > 0);
        }

    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/   
    static testmethod void retrieveSteppedTariffRecords_Positive(){

        List<BlAp_CombinedRecord> combinedRecord = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BillingContract__c objContract =  [SELECT Id  FROM BillingContract__c];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                combinedRecord = BlAp_SteppedTariffAmendmentCtrlr.retrieveSteppedTariffRecords(objContract.Id);
                Test.stoptest();                
            } catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinedRecord.size() > 0);
        }

    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/   
    static testmethod void retrieveSteppedTariffRecords_Negative(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<BlAp_CombinedRecord> combinedRecord = new List<BlAp_CombinedRecord>();
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                combinedRecord = BlAp_SteppedTariffAmendmentCtrlr.retrieveSteppedTariffRecords(DUMMYDATA);
                Test.stoptest();                
            } catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinedRecord.size() == 0);
        }

    }
}