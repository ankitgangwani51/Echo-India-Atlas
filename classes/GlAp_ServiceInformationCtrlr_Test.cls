/******************************************************************************
@author:      Echo: Hasan 
@date:        13-08-2018  
@description: Test Class for GlAp_ServiceInformationCtrlr
*******************************************************************************/
@isTest
public class GlAp_ServiceInformationCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String CONTRACT_NAME ='TestContract';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String HALFYEARLY = 'Half Yearly';
    private static final String YES ='yes';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String MEASURED = 'measured';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final Decimal VOLUME = 55.00;
    private static final String TRADEEFFLUENT = 'Trade Effluent';
    private static final String SEWERAGE = 'Sewerage';
    
/******************************************************************************
@author:      Echo: Hasan 
@date:         13-08-2018  
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);   
        
        BankAccountDetails__c objBankAccountDetails = GlUt_FactoryData_Test.createBankAccountDetails(objAccount);
        Database.insert(objBankAccountDetails);  
        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        objServiceType.Name  = SEWERAGE;
        Database.insert(objServiceType);
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        objServiceType1.Name  = TRADEEFFLUENT;
        Database.insert(objServiceType1);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c objServiceSew= GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objServiceSew);
        
    }
/******************************************************************************
@author:      Echo: Hasan
@date:        13 Aug 2018
@description: Positive Test method having Supply Point Id for getInfoToDisplayForSupplyPoint() method
*******************************************************************************/    
    static testmethod void getInfoToDisplayForSupplyPoint_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME limit 1];
        SupplyPoint__c  objSupplyPoint =  [SELECT Id FROM  SupplyPoint__c LIMIT 1];
        
        //Run test class in user context
        Boolean Isexception;
        system.runas(objUser){
            Test.startTest();
            GlAp_ServiceInformationCtrlr.ContainerWrapper resultContainertest = new GlAp_ServiceInformationCtrlr.ContainerWrapper();
            resultContainertest = GlAp_ServiceInformationCtrlr.getInfoToDisplay(null, objSupplyPoint.Id) ;  
            Test.stopTest();
            
            System.assert(resultContainertest != null);
        }
    }
/******************************************************************************
@author:      Echo: Hasan
@date:        13 Aug 2018
@description: Positive Test method Having Contract Id for getInfoToDisplayForContract() method
*******************************************************************************/ 
    static testmethod void getInfoToDisplayForContract_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME limit 1];
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c LIMIT 1];
        
        //Run test class in user context
        Boolean Isexception;
        system.runas(objUser){
            Test.startTest();
            GlAp_ServiceInformationCtrlr.ContainerWrapper resultContainertest = new GlAp_ServiceInformationCtrlr.ContainerWrapper();
            resultContainertest = GlAp_ServiceInformationCtrlr.getInfoToDisplay(objContract.Id, null) ;  
            Test.stopTest();
            System.assert(resultContainertest != null);
        }
    }
    /******************************************************************************
@author:      Echo: Hasan
@date:        13 Aug 2018
@description: Negative Test method for getInfoToDisplay() method
*******************************************************************************/
    static testmethod void getInfoToDisplay_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME limit 1];
        SupplyPoint__c  objSupplyPoint =  [SELECT Id FROM  SupplyPoint__c LIMIT 1];
        
        //Run test class in user context
        Boolean Isexception;
        system.runas(objUser){
            Test.startTest();
            GlAp_ServiceInformationCtrlr.ContainerWrapper resultContainertest = new GlAp_ServiceInformationCtrlr.ContainerWrapper();
            resultContainertest = GlAp_ServiceInformationCtrlr.getInfoToDisplay(null, null) ;  
            Test.stopTest();
            System.assert(resultContainertest != null);
        }
    }
    
}