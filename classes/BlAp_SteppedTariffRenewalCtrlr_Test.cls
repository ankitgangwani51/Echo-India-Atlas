/******************************************************************************
@author         Ankit Gangwani
@date           24 July 2018
@description    Test Class For BlAp_SteppedTariffRenewalCtrlr
*******************************************************************************/
@isTest
public class BlAp_SteppedTariffRenewalCtrlr_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String SNAME                   = 'Test Name';
    private static final String strManufacturer         = 'Siemens';
    private static final String strUnitOfMeasure        = 'Metric';
    private static final String LOCATION_NAME           = 'A99 9AA';
    private static final String SP_USAGE_TYPE           = 'SupplyPointUsageType';
    private static final String AVAILABLESERVICES       = 'TestAvailableServiceItem';
    private static final String WHOLESALER              = 'TestWholesaler';
    private static final String MEASURED                = 'Monthly';
    private static final String DUMMYDATA               = 'TEST';
    
    
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
    }    
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/    
    static testmethod void retrieveServicesOnContract_Positive(){

        List<ServiceType__c> serviceTypeLists = new List<ServiceType__c>();        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BillingContract__c objContract =  [SELECT Id  FROM BillingContract__c];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                serviceTypeLists = BlAp_SteppedTariffRenewalCtrlr.retrieveServicesOnContract(objContract.Id);
                Test.stoptest();                
            } catch(Exception ex) {                
            }
            System.assert(serviceTypeLists.size() > 0);
        }
    }
    
   /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/   
    static testmethod void retrieveSteppedTariffFields_Positive(){

        List<List<GlAp_FieldProps>> fieldPropList = new List<List<GlAp_FieldProps>>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BillingContract__c objContract =  [SELECT Id  FROM BillingContract__c];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                fieldPropList = BlAp_SteppedTariffRenewalCtrlr.retrieveSteppedTariffFields(objContract.Id);
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
    static testmethod void retrieveServicesOnContract_Negative(){

        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<ServiceType__c> serviceTypeLists = new List<ServiceType__c>();
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                serviceTypeLists = BlAp_SteppedTariffRenewalCtrlr.retrieveServicesOnContract(DUMMYDATA);
                Test.stoptest();                
            } catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(serviceTypeLists.size() == 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/  
    static testmethod void retreiveSiteSupplyFieldList(){
        List<List<GlAp_FieldProps>> fieldPropLists = new List<List<GlAp_FieldProps>>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                fieldPropLists = BlAp_SteppedTariffRenewalCtrlr.retrieveSteppedTariffFields(DUMMYDATA);
                Test.stoptest();                
            } catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(fieldPropLists.size() == 0);
        }
    }

}