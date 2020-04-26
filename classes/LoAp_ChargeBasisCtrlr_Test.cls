/******************************************************************************
@author         Ankit Gangwani
@date           25 Sept 2018
@description    Test Class For LoAp_ChargeBasisCtrlr_Test
*******************************************************************************/
@isTest
public class LoAp_ChargeBasisCtrlr_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String sName                   = 'Test Name';
    private static final String strManufacturer         = 'Siemens';
    private static final String strUnitOfMeasure        = 'Metric';
    private static final String LOCATION_NAME           = 'A99 9AA';
    private static final String SP_USAGE_TYPE           = 'SupplyPointUsageType';
    private static final String AVAILABLESERVICES       = 'TestAvailableServiceItem';
    private static final String WHOLESALER              = 'TestWholesaler';
    private static final String MEASURED                = 'Monthly';
    private static final String WIZARDTYPE              = 'NewStepTariff';
    private static final String DUMMYDATA           	= ' TEST';
    private static final String sZipcode				= 'WS2 7PD';
    
    
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          25 Sept 2018 
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
        Account objAccount = GlUt_FactoryData_Test.createAccount(sName);
        Database.insert(objAccount);
        
        // Create Contrat Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(objAccount);
        Database.insert(objContract);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(sZipcode);
        Database.insert(objLocation);
        
        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(sName);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; 
        Database.insert(objSupplyPoint);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesalers = GlUt_FactoryData_Test.createWholesaler(sName);
        Database.insert(objWholesalers);
                
        // Create Service Type Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(sName);
        Database.insert(objServiceType);
            
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Available Service Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(sName, objDivision, objServiceType, objSupplyPoint, objWholesalers);
        Database.insert(objAvailableService);
            
        // Create Charge Basis Record
        ChargeBasis__c objChargeBasis = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        objChargeBasis.StartDate__c = Date.today();
        objChargeBasis.Amount__c = 100.00;
        Database.insert(objChargeBasis);
    }    
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          25 Sept 2018 
    @return        Void   
	@description   This method is used to get the fields from Supply Point, Available Service and Charge Basis Objects
    *******************************************************************************/     
    static testmethod void getChargeBasisFields(){

        List<GlAp_FieldProps> addFieldProp = new List<GlAp_FieldProps>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                addFieldProp = LoAp_ChargeBasisCtrlr.getChargeBasisFields();
                Test.stoptest();                
            } catch(Exception ex) {
                system.debug('exception caught in test context:: ' + ex);                                
            }
            System.assert(addFieldProp.size() > 0);
        }        
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          25 Sept 2018 
    @return        Void   
	@description   This method is used to get all the records from Charge Basis Object based on Location Id (Positive)
    *******************************************************************************/   
    static testmethod void getChargeBasisRecords_Positive(){
        List<BlAp_CombinedRecord> activeSPDeviceList = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                activeSPDeviceList = LoAp_ChargeBasisCtrlr.getChargeBasisRecords(objLocation.Id);
                Test.stoptest();                
            } catch(Exception ex) {
                system.debug('exception caught in test context:: ' + ex);                                
            }
            System.assert(activeSPDeviceList.size() > 0);
        }   
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          25 Sept 2018 
    @return        Void   
	@description   This method is used to get all the records from Charge Basis Object based on Location Id (Negative)
    *******************************************************************************/   
    static testmethod void getChargeBasisRecords_Negative(){
        List<BlAp_CombinedRecord> activeSPDeviceList = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                activeSPDeviceList = LoAp_ChargeBasisCtrlr.getChargeBasisRecords(NULL);
                Test.stoptest();                
            } catch(Exception ex) {
                system.debug('exception caught in test context:: ' + ex);                                
            }
            System.assert(activeSPDeviceList.size() == 0);
        }   
    }
}