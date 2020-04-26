/******************************************************************************
@author:      Echo: Swati Mathur
@date:        05 Apr 2018
@description: Test Class for GlUt_AgreedRateContractFinder
*******************************************************************************/
@isTest
public class GlUt_AgreedRateContractFinder_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static String ACCOUNT_NAME = 'TestAccount';    
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static String LOCATION_NAME ='A99 9AA';
    private static String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static String SERVICE_TYPE ='TestServiceType';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLE_SERVICES ='TestAvailableService';
    private static String SERVICE_ITEM_FAMILY ='TestServiceItemFamily';
    private static String SERVICE_ITEM_TYPE ='TestServiceitemtype';
    private static String AGREED_RATE ='TestAgreedRate';
    private static String BUNDLE ='TestBundle';
    private static String AVAILABLE_BUNDLE ='TestAvailableBundle';
    private static String BUNDLE_ITEM ='TestBundleItem';
    private static String AVAILABLE_SERVICE_ITEM='TestAvailableServiceItem';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String MEASURED = 'Monthly';
    
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method to create dummy data
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        //create Account records
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);       
        
        //create Contract records
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        Database.insert(objContract);
               
        //create ServiceType records
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(SERVICE_TYPE );
        Database.insert(objServiceType);
        
        //create ServiceItemFamily records
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICE_ITEM_FAMILY,objServiceType); 
        Database.insert(objServiceItemFamily);
        
        //create device size records        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize); 
        
        //create device type records
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
       
        //create device records
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        //create reading records
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);         
        
        //create Division records
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //create Wholesaler records
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //create ServiceItemType records
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICE_ITEM_TYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        //create Bundle records
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        //create location records
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //create SupplyPointUsageType records
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //create SupplyPoint records
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174
        Database.insert(objSupplyPoint);
        
        //create AvailableService records
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLE_SERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);  
        
        //create Service records
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint, objAvailableService);
        Database.insert(objService);
        
        //create AvailableBundle records
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLE_BUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
                
        //create BundleItem records
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLE_ITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
            
        //create AvailableServiceItem records
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLE_SERVICE_ITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem);       
        
        //create ServiceItem records
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        Database.insert(objServiceItem);
        
        //create Agreed Rate records
        AgreedRate__c  objAgreedRate = GlUt_FactoryData_Test.createAgreedRate(AGREED_RATE,objServiceItem);
        Database.insert(objAgreedRate);
        
        
    }
    
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method for RetrieveContractIds() method
    *******************************************************************************/    
    static testmethod void retrieveContractIds_positive(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        Set<Id> contractIds = new Set<Id>();  
        String sobjectType;
        
        AgreedRate__c agreedRate =  [SELECT Id FROM AgreedRate__c];
        
        System.runAs(objUser){            
            Test.startTest();
            GlUt_AgreedRateContractFinder obj = new GlUt_AgreedRateContractFinder();
            contractIds = obj.retrieveContractIds(agreedRate.Id);            
            Test.stopTest();
            for(Id id : contractIds){                
                sobjectType = id.getSObjectType().getDescribe().getName();
            }
            System.assertEquals(GlUt_APIConstantsContracts.CONTRACTAPINAME, sobjectType);
        }
    }         
    
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method for retrieveContractIds() method - negative scenario
    *******************************************************************************/    
    static testmethod void retrieveContractIds_negative(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        Set<Id> contractIds = new Set<Id>();
        String sobjectType;
        
        Account objAcc = [SELECT Id FROM Account ];       
        
        System.runAs(objUser){            
            Test.startTest();
            GlUt_AgreedRateContractFinder obj = new GlUt_AgreedRateContractFinder();
            contractIds = obj.retrieveContractIds(objAcc.Id);            
            Test.stopTest();
            
            System.assertEquals(0, contractIds.size());
        }
    }

}