/******************************************************************************
@author         Echo: Swati Mathur
@date           16 Aug 2018
@description    Test class for CuAp_ManageServiceEffectiveDateCtrlr
@revision(s)        
*******************************************************************************/
@isTest
public class CuAp_ManageServiceEffectiveDtCtrlr_Test {
    
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES1 ='TestAvailableService1';
    private static final String AVAILABLESERVICES2 ='TestAvailableService2';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);         
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_ONE,objAccount);
        Database.insert(objContract);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Main Supply Point
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True;
        Database.insert(objSupplyPoint);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        List<AvailableService__c> lstAvailableService = new List<AvailableService__c>();
        AvailableService__c  objAvailableService1 = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES1 ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        lstAvailableService.add(objAvailableService1);
        AvailableService__c  objAvailableService2 = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES2 ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        lstAvailableService.add(objAvailableService2);
        Database.insert(lstAvailableService);
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService1);
        Database.insert(objService);
            
        }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           16 Aug 2018
    @description    positive test scenario for retrieveServiceFromAvailServices method
    *******************************************************************************/ 
    static testmethod void retrieveServiceFromAvailServices_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];        
        List<AvailableService__c> availableServiceTransfers = [Select Id from AvailableService__c];
        
        System.runAs(objUser){            
            Test.startTest();
            List<Service__c> serviceList = CuAp_ManageServiceEffectiveDateCtrlr.retrieveServiceFromAvailServices(availableServiceTransfers);
            Test.stopTest();  
            System.assert(!serviceList.isEmpty());
        }
    }    
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           16 Aug 2018
    @description    negative test scenario for retrieveServiceFromAvailServices method
    *******************************************************************************/ 
    static testmethod void retrieveServiceFromAvailServices_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        List<AvailableService__c> availableServiceTransfers = [Select Id from AvailableService__c WHERE Name = :AVAILABLESERVICES2];
        System.runAs(objUser){
            
            Test.startTest();
            List<Service__c> serviceList = CuAp_ManageServiceEffectiveDateCtrlr.retrieveServiceFromAvailServices(availableServiceTransfers);
            Test.stopTest();
            System.assertEquals(serviceList, null);
        }
    }    
    

}