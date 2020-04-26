/******************************************************************************
@author:      Echo: Neha 
@date:        06-04-2018  
@description: Test Class for GlUt_ServiceItemContractFinder
*******************************************************************************/
@isTest
public class GlUt_TaxClassificationContFind_Test {

    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String CONTRACT_NAME = 'Billing Contract';
    private static final String TAX_TYPE = 'Agriculture/Forestry & Fishing'; 
    private static final String ZIP_CODE = 'A99 9AA';    
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';
    private static final String DEVICE_SIZE = '40mm';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = '123456789';
    private static final String WHOLESALER_NAME = 'Wholesale System';
    private static final String SERVICE_NAME = 'S-1442';
    private static final String SERVICE_TYPE_NAME = 'Water Service';
    private static final String BUNDLE = 'Soical Bundle';
    private static final String SERVICE_ITEM_FAMILY_NAME = 'Water Volumetric';
    private static final String SERVICE_ITEM_TYPE = 'Measured Water Volumetric';
    private static final String BUNDLEITEM = 'Social Service';
    private static final String AVAIL_SERVICE_ITEM = 'Vol. Water Service';
    private static final Date FROM_DATE = date.valueOf('2018-01-01');
    private static final String AVAIL_BUNDLE ='TestAvailableBundle';
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06-04-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);

        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        
        // Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);        
        Database.insert(objContract); 
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
 
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        // Create ServiceType Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE_NAME);
        Database.insert(objServiceType);
        
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        // Create AvailableService Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME, objDivision, objServiceType, objSupplyPoint, objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);
                
        // Create TaxClassificationType__c Record
        TaxClassificationType__c objTaxClassificationType = GlUt_FactoryData_Test.createTaxClassificationType(TAX_TYPE);        
        Database.insert(objTaxClassificationType);
        
        // Create TaxClassification__c Record
        TaxClassification__c objTaxClassification = GlUt_FactoryData_Test.createTaxClassification(objAccount, objTaxClassificationType);        
        Database.insert(objTaxClassification);
        
        // Create ServiceItemFamily Record
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY_NAME, objServiceType);
        Database.insert(objServiceItemFamily);	
        
        // Create ServiceItemType Record
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType);         
        
        //Create bundle record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE, objServiceType);
        Database.insert(objBundle); 
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create available bundle record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAIL_BUNDLE, objBundle, objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = FROM_DATE;        
        Database.insert(objServiceItem); 
      
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void retrieveContractIds_Positive(){            
        
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> contractIds = new Set<Id>();  
        TaxClassification__c  objTaxClassification = [SELECT Id FROM TaxClassification__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest(); 
                      
            GlUt_TaxClassificationContractFinder objClass = new GlUt_TaxClassificationContractFinder();
        	contractIds = objClass.retrieveContractIds(objTaxClassification.Id); 
            
            Test.stopTest();          
            system.assert(contractIds.size() > 0);
        }         
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void retrieveContractIds_Negative(){            
        
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Set<Id> contractIds = new Set<Id>();  
        TaxClassification__c objTaxClassification = new TaxClassification__c();
        
        System.runAs(objUser){
            Test.startTest(); 
                   
            GlUt_TaxClassificationContractFinder objClass = new GlUt_TaxClassificationContractFinder();
        	contractIds = objClass.retrieveContractIds(objTaxClassification.Id); 
            
            Test.stopTest(); 
            system.assert(contractIds.size() == 0);
        }  
    }
}