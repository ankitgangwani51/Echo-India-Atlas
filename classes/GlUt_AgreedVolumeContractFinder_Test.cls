/******************************************************************************
@author:      Echo: Swati Mathur
@date:        05 Apr 2018
@description: Test Class for GlUt_AgreedVolumeContractFinder
*******************************************************************************/
@isTest
public class GlUt_AgreedVolumeContractFinder_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';    
    private static String LOCATION_NAME ='A99 9AA';
    private static String ACCOUNT_NAME = 'TestAccount';    
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static String DEVICE_NAME = 'TestDevice';
    private static String DEVICE_SIZE = 'TestDeviceSize';
    private static String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static String SERVICE_TYPE ='TestServiceType';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLE_SERVICES ='TestAvailableService';
    private static String AGREEDVOLUME_NAME = 'TestAgreedVolume';
    private static String MANUFACTURER = 'Siemens';
    private static String UNIT_OF_MEASURE = 'Metric';
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';   //AT-3147
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';     //AT-3147   
    private static final String BUNDLE              = 'TestBundle';              // AT-3147
    private static final String AVAILABLEBUNDLE     = 'TestAvailableBundle';     // AT-3147
    private static final String BUNDLEITEM          = 'TestBundleItem';          // AT-3147
    private static final String AVAILABLESERVIEITEM = 'TestAvailableServiceItem';  // AT-3147
    private static final String MEASURED			= 'Monthly';

    
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
        
        //create location records
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //create DischargeAgreement records
        DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
        Database.insert(objDischargeAgreement); 
        
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
        List<Service__c> lstService = new List<Service__c>();
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint, objAvailableService);
      //  objService.DischargeAgreement__c = objDischargeAgreement.Id;    //AT-3147  Commented
        Database.insert(objService);
        
        //AT-3147
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //AT-3147 Created Service Item Type
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
          
        //AT-3147 Created Bundle
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        //AT-3147 Created AvailableBundle
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //AT-3147 Created BundleItem
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //AT-3147 Created AvailableServiceItem      
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        //AT-3147 Created Service Item 
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.DischargeAgreement__c = objDischargeAgreement.Id; 
        objServiceItem.StartDate__c = system.today();
        Database.insert(objServiceItem); 
        
        //create AgreedVolume record
        AgreedVolume__c objAgreedVolume = GlUt_FactoryData_Test.createAgreedVolume(AGREEDVOLUME_NAME,objDischargeAgreement);
        Database.insert(objAgreedVolume);
        
        
    }
    
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method for retrieveContractIds() method - positive scenario
    *******************************************************************************/    
    static testmethod void retrieveContractIds_positive(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        Set<Id> contractIds = new Set<Id>();
        String sobjectType;
        
        AgreedVolume__c objAgreedVolume = [SELECT Id FROM AgreedVolume__c ];       
        
        System.runAs(objUser){            
            Test.startTest();
            GlUt_AgreedVolumeContractFinder obj = new GlUt_AgreedVolumeContractFinder();
            contractIds = obj.retrieveContractIds(objAgreedVolume.Id);            
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
            GlUt_AgreedVolumeContractFinder obj = new GlUt_AgreedVolumeContractFinder();
            contractIds = obj.retrieveContractIds(objAcc.Id);            
            Test.stopTest();
            
            System.assertEquals(0, contractIds.size());
        }
    }

}