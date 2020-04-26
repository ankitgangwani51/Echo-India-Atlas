/******************************************************************************
@author         Ankit Gangwani
@date           19 March 2019
@description    Test Class For LoAp_ManageSiteSupplyCtrlr
*******************************************************************************/
@isTest
public class LoAp_ManageSiteSupplyCtrlr_Test {
    
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
    static testmethod void getAddressFromLocation_Positive(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        LoAp_ManageSiteSupplyCtrlr.AddressWrapper addressWrap = new LoAp_ManageSiteSupplyCtrlr.AddressWrapper();       
        List<Location__c> objLocation = [SELECT Id FROM Location__c LIMIT 1];
        System.runAs(objUser[0]){            
            try {
                Test.starttest();
                addressWrap = LoAp_ManageSiteSupplyCtrlr.getAddressFromLocation(objLocation[0].Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(addressWrap.locationId != null);
            System.assert(addressWrap.address != null);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/   
    static testmethod void getAddressFromLocation_Negative(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        LoAp_ManageSiteSupplyCtrlr.AddressWrapper addressWrap = new LoAp_ManageSiteSupplyCtrlr.AddressWrapper();       
        Location__c objLocation = new Location__c();
        System.runAs(objUser[0]){            
            try {
                Test.starttest();
                addressWrap = LoAp_ManageSiteSupplyCtrlr.getAddressFromLocation(objLocation.Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(addressWrap.locationId == null);
            System.assert(addressWrap.address == null);
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/   
    static testmethod void AddMoreRows(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        LoAp_ManageSiteSupplyCtrlr.SiteSupplyWrapper SiteSupplyWrap = new LoAp_ManageSiteSupplyCtrlr.SiteSupplyWrapper();       
        List<Location__c> objLocation = [SELECT Id FROM Location__c LIMIT 1];
        System.runAs(objUser[0]){            
            try {
                Test.starttest();
                SiteSupplyWrap = LoAp_ManageSiteSupplyCtrlr.AddMoreRows(String.valueOf(Date.today()));
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(SiteSupplyWrap.objSupplyPoint != null);
            System.assert(SiteSupplyWrap.recordIdType == System.Label.LoAp_SiteSupplyExternal);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/   
    static testmethod void retreiveSiteSupplyRecordList_Positive(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<LoAp_ManageSiteSupplyCtrlr.SiteSupplyWrapper> SiteSupplyWrap = new List<LoAp_ManageSiteSupplyCtrlr.SiteSupplyWrapper>();       
        List<SupplyPoint__c> objSP = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        System.runAs(objUser[0]){            
            try {
                Test.starttest();
                SiteSupplyWrap = LoAp_ManageSiteSupplyCtrlr.retreiveSiteSupplyRecordList(objSP[0].Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(SiteSupplyWrap.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/   
    static testmethod void retreiveSiteSupplyRecordList_Negative(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<LoAp_ManageSiteSupplyCtrlr.SiteSupplyWrapper> SiteSupplyWrap = new List<LoAp_ManageSiteSupplyCtrlr.SiteSupplyWrapper>();       
        SupplyPoint__c objSP = new SupplyPoint__c();
        System.runAs(objUser[0]){            
            try {
                Test.starttest();
                SiteSupplyWrap = LoAp_ManageSiteSupplyCtrlr.retreiveSiteSupplyRecordList(objSP.Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(SiteSupplyWrap.size() == 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/   
    static testmethod void updateInvalidSiteSupply_Positive(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<SiteSupply__c> objSSP = [SELECT Id FROM SiteSupply__c LIMIT 1];
        System.runAs(objUser[0]){            
            try {
                Test.starttest();
                LoAp_ManageSiteSupplyCtrlr.updateInvalidSiteSupply(objSSP[0].Id);
                Test.stoptest();                
            } catch(Exception ex) {    
                system.debug('exception caught in test context:: ' + ex);
            }
            SiteSupply__c objSS = [SELECT Id, Invalid__c FROM SiteSupply__c LIMIT 1];
            System.debug('objSS Pos = '+objSS);
            System.assert(objSS.Invalid__c,true);            
        }
    }
}