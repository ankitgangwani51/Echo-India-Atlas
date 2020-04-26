/******************************************************************************
@author         Echo: Tarun Gupta
@date           12 Mar 2019
@description    Test class for CuAp_BillingActionsCtrlr
*******************************************************************************/
@isTest
public class CuAp_BillingActionsCtrlr_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String LOCATION_NAME 		= 'A99 9AA';   
    private static final String LOCATION_SUB_TYPE 	= 'Detached';
    private static final String STREET 				= 'teststreet';
    private static final String TESTSERVICE_TYPE1 	= 'TestServiceType1'; 
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    
    private static final String DEVICE_SIZE 		= '10mm';
    private static final String MANUFACTURER 		= 'Kent';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String SERIALNO = '0801';
    private static final String WHOLESALER 			= 'TestWholesaler';
    private static final String AVAILABLESERVICES 	= 'TestAvailableService';
    private static final String SERVICE_ITEM_FAMILY = 'Service_Item_Family';
    private static final String BUNDLE_ITEM = 'Test_BundleItem';
    private static final String BUNDLE_NAME = 'Bundle_Test';
    private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
    private static final String AVAIL_SERVICE_ITEM = 'AvailableServiceItem_Test';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount.RecordTypeId = GlUt_RecordTypeUtilities.getRecordTypeMap().get(GlUt_Constants.NHH_ACCOUNT_RECORDTYPE_NAME).Id;
        Database.insert(objAccount);
        
        // Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);          
        Database.insert(objBalance);
        
        // Create Contract for Refund Paymet           
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
        
        // Create Rural License Record            
        RuralLicense__c objLicense = GlUt_FactoryData_Test.createRuralLicense();
        objLicense.BillingContract__c = objContract.Id;
        objLicense.StartDate__c = system.today();
        objLicense.Status__c = Label.BlAp_RuralLicenseStatusActive;
        Database.insert(objLicense);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        objLocation.RuralLicense__c = objLicense.Id;
        Database.insert(objLocation);  
        
        //Create Service Type Record - 1
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType1);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point  - Remove Device
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c = true;
        Database.insert(objSupplyPoint1);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record - old device for Remove Device Scenario
        Device__c  objDevice = GlUt_FactoryData_Test.CreateDevice(SERIALNO , objDeviceType);        
        Database.insert(objDevice);
        
        // Create Supply Point Device Record - Exchage
        SupplyPointDevice__c  objSupplyPointDeviceExchange = GlUt_FactoryData_Test.CreateSupplyPointDevices(objDevice , objSupplyPoint1);        
        Database.insert(objSupplyPointDeviceExchange);
        
         // Create Supply Point Device Service Record - Exchange
        SupplyPointDeviceService__c  objSupplyPointDeviceServiceExchange = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objSupplyPointDeviceExchange , objServiceType1);        
        Database.insert(objSupplyPointDeviceServiceExchange);
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Mar 2019
	@description: Positive method of isNHHAccount 
	*******************************************************************************/
    static testmethod void isNHHAccount_Positive(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME limit 1];
        Boolean isException = false;
        Boolean isNHH = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                isNHH = CuAp_BillingActionsCtrlr.isNHHAccount(objAccount.Id);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            System.assertEquals(isNHH, true);
        }          
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Mar 2019
	@description: Positive method of statusOfRuralLicense 
	*******************************************************************************/
    static testmethod void statusOfRuralLicense_Positive(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        RuralLicense__c objLicense = [Select Id FROM RuralLicense__c limit 1];
        Boolean isException = false;
        Boolean isActive = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                isActive = CuAp_BillingActionsCtrlr.statusOfRuralLicense(objLicense.Id);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            System.assertEquals(isActive, true);
        }          
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Mar 2019
	@description: Positive method of isActiveSPD 
	*******************************************************************************/
   /* static testmethod void isActiveSPD_Positive(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        SupplyPoint__c objSP = [Select Id FROM SupplyPoint__c limit 1];
        Boolean isException = false;
        Boolean isActiveSPD = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                isActiveSPD = CuAp_BillingActionsCtrlr.isActiveSPD(objSP.Id);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            System.assertEquals(isActiveSPD, true);
        }          
    }*/
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Mar 2019
	@description: Negative method of isActiveSPD 
	*******************************************************************************/
    /*static testmethod void isActiveSPD_Negative(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = false;
        Boolean isActiveSPD = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                isActiveSPD = CuAp_BillingActionsCtrlr.isActiveSPD(null);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            System.assertEquals(isActiveSPD, false);
        }          
    }*/
}