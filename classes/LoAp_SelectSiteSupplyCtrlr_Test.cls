/******************************************************************************
@author         Ankit Gangwani
@date           19 March 2019
@description    Test Class For LoAp_SelectSiteSupplyCtrl
*******************************************************************************/
@isTest
public class LoAp_SelectSiteSupplyCtrlr_Test {
    
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String SNAME                   = 'Test Name';
    private static final String LOCATION_NAME           = 'A99 9AA';
    private static final String SP_USAGE_TYPE           = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE         	= 'TestDeviceSize';
    private static final String DEVICE_NAME         	= 'TestDevice';
    private static final String MANUFACTURER        	= 'Siemens';
    private static final String UNIT_OF_MEASURE     	= 'Metric';

    /******************************************************************************
    @author        Ankit Gangwani
    @date          19 March 2019
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
        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);        
        Database.insert(objLocation);
        
        // Create Location Record
        Location__c objLocation2 = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);        
        Database.insert(objLocation2);

        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType2 = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType2);
        
        // Create Supply Point Record
        SupplyPoint__c objSiteSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSiteSupplyPoint.Measured__c = True;
        objSiteSupplyPoint.Description__c = 'Main';
        Database.insert(objSiteSupplyPoint);
        
        // Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation2, objSupplyPointUsageType2);
        objSupplyPoint.Measured__c = True;
        Database.insert(objSupplyPoint);
        
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSiteSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        // Create Site Supply Record
        SiteSupply__c objSiteSupply = GlUt_FactoryData_Test.createSiteSupply(objSiteSupplyPoint, objSupplyPoint);
        Database.insert(objSiteSupply);
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/   
    static testmethod void retreiveSiteSupplyFieldList(){
        List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){            
            try {
                Test.starttest();
                fieldPropList = LoAp_SelectSiteSupplyCtrlr.retreiveSiteSupplyFieldList();
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(fieldPropList.size() > 0);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveServicerecordList_Positive(){
        List<BlAp_CombinedRecord> combinedRecord = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        SupplyPoint__c objSP = [SELECT Id, Description__c FROM SupplyPoint__c WHERE Description__c = 'Main' LIMIT 1];   
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                combinedRecord = LoAp_SelectSiteSupplyCtrlr.retreiveSiteSupplyRecordList(objSP.Id);
                Test.stoptest();             
            } catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinedRecord.size() > 0);
        }
    }  
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/     
    static testmethod void retrieveServicerecordList_Negative(){
        List<BlAp_CombinedRecord> combinedRecord = new List<BlAp_CombinedRecord>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        SupplyPoint__c objSP = new SupplyPoint__c();            
        System.runAs(objUser[0]){
            try {
                Test.starttest();
                combinedRecord = LoAp_SelectSiteSupplyCtrlr.retreiveSiteSupplyRecordList(objSP.Id);
                Test.stoptest();             
            } catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(combinedRecord.size() == 0);
        }
    }  
}