/******************************************************************************
@author         Echo: Swati Mathur
@date           16 Aug 2018
@description    Test class for CuAp_ManageServiceReadingsCtrlr     
*******************************************************************************/
@isTest
public class CuAp_ManageServiceReadingsCtrlr_Test {
    
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE = 'TestServiceType';
    private static final String TEST_SERVICE_TYPE_1 = 'TestServiceType1';
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
    private static final String EFFECTIVEDATE = '2019-01-01';
    private static final Date READING_DATE = date.valueOf('2018-02-15');
    
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
        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        List<ServiceType__c> lstobjServiceType = new List<ServiceType__c>();
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        lstobjServiceType.add(objServiceType);        
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE_1 );
        lstobjServiceType.add(objServiceType1);  
        Database.insert(lstobjServiceType);
        
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ReadingDate__c = READING_DATE;
        Database.insert(objReading);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True;
        Database.insert(objSupplyPoint);
        
        SupplyPointDevice__c  objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        List<AvailableService__c> lstAvailableService = new List<AvailableService__c>();
        AvailableService__c  objAvailableService1 = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES1 ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        lstAvailableService.add(objAvailableService1);
        
        AvailableService__c  objAvailableService2 = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES2 ,objDivision,objServiceType1,objSupplyPoint,objWholesaler);
        lstAvailableService.add(objAvailableService2);
        Database.insert(lstAvailableService);
        
        List<Service__c> lstobjService = new List<Service__c>();
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService1);
        lstobjService.add(objService);
        
        Service__c  objService1 = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType1,objSupplyPoint,objAvailableService1);
        lstobjService.add(objService1);
        Database.insert(lstobjService);
            
        }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           16 Aug 2018
    @description    positive test scenario for fieldProp method
    *******************************************************************************/ 
    static testmethod void fieldProp_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];        
        
        System.runAs(objUser){            
            Test.startTest();
            List<GLAp_FieldProps> fldPropList = CuAp_ManageServiceReadingsCtrlr.fieldProp();
            Test.stopTest();  
            System.assertNotEquals(fldPropList.size(), 0);
        }
    }    
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           16 Aug 2018
    @description    positive test scenario for retrieveSPAndReadingByContract method
    *******************************************************************************/ 
    static testmethod void retrieveSPAndReadingByContract_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        List<Service__c> serviceTransfers = [Select Id,ServiceType__c,SupplyPoint__c from Service__c];
        System.runAs(objUser){            
            Test.startTest();
            List<BlAp_CombinedRecord> combinedList = CuAp_ManageServiceReadingsCtrlr.retrieveSPAndReadingByContract(serviceTransfers,EFFECTIVEDATE);
            Test.stopTest();  
            System.assertNotEquals(combinedList, null);
        }
    } 
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           16 Aug 2018
    @description    negative test scenario for retrieveSPAndReadingByContract method
    *******************************************************************************/ 
    static testmethod void retrieveSPAndReadingByContract_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        List<Service__c> serviceTransfers = new List<Service__c>();
        System.runAs(objUser){            
            Test.startTest();
            List<BlAp_CombinedRecord> combinedList = CuAp_ManageServiceReadingsCtrlr.retrieveSPAndReadingByContract(serviceTransfers,EFFECTIVEDATE);
            Test.stopTest(); 
            System.assertEquals(combinedList, null);
            
        }
    } 
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           16 Aug 2018
    @description    positive test scenario for retrieveSPAndReadingByContract method
    *******************************************************************************/ 
    static testmethod void retrieveSPAndReadingBySP_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        List<AvailableService__c> availableServiceTransfers = [Select Id,ServiceType__c,SupplyPoint__c from AvailableService__c ];
        
        System.runAs(objUser){            
            Test.startTest();
            List<BlAp_CombinedRecord> combinedList = CuAp_ManageServiceReadingsCtrlr.retrieveSPAndReadingBySP(availableServiceTransfers, EFFECTIVEDATE);
            Test.stopTest();  
            System.assertNotEquals(combinedList, null);
        }        
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           16 Aug 2018
    @description    negative test scenario for retrieveSPAndReadingByContract method
    *******************************************************************************/ 
    static testmethod void retrieveSPAndReadingBySP_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        List<AvailableService__c> availableServiceTransfers = new List<AvailableService__c>();
        
        System.runAs(objUser){            
            Test.startTest();
            List<BlAp_CombinedRecord> combinedList = CuAp_ManageServiceReadingsCtrlr.retrieveSPAndReadingBySP(availableServiceTransfers, EFFECTIVEDATE);
            Test.stopTest(); 
            System.assertEquals(combinedList, null);            
        }        
    }

}