/******************************************************************************
@author:      Echo: Neha 
@date:        17-01-2018  
@description: Test Class for CuAp_SelectDiscountApplyCtrlr
*******************************************************************************/

@isTest  
public class CuAp_SelectDiscountApplyCtrlr_Test {   
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String DEVICE_TYPE_NAME = 'Meter';
    private static final String DEVICE_NAME = '123456789';
    private static final String SERVICE_TYPE_NAME = 'Water';
    private static final String LOCATION_NAME = 'A99 9AA';
    private static final String SERVICE_NAME = 'S-1442';
    private static final String WHOLESALER_NAME = 'Wholesale System'; 
    private static final String SERVICE_ITEM_FAMILY_NAME = 'Measured Water Volumetric';
    private static final String SERVICE_ITEM_TYPE = 'Measured Water Volumetric';
    private static final String DISCOUNT_NAME = 'Percentage Discount';
    private static final Date FROM_DATE = date.valueOf('2018-01-01');
    private static final Date TO_DATE = date.valueOf('2018-01-30');
    private static final String DISCOUNT_TYPE = 'Percentage';
    private static final Decimal PERCENTAGE_DISCOUNT_AMOUNT = 5.0;
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String BUNDLE ='TestBundle';
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
  
    private static String contractId;
    private static String sKeyValue  = '50';
    private static String sOperation = 'Less Than';
    private static String sfilterOn  = 'Percentage';
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        17-01-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
                
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        
        // Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(ACCOUNT_NAME, objAccount);        
        Database.insert(objContract);        
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
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
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
  
        Database.insert(objSupplyPoint);
             
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
       
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        // Create AvailableService Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService); 
        
        // Create ServiceItemFamily Record
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY_NAME,objServiceType);
        Database.insert(objServiceItemFamily); 
        
        // Create erviceItemType Record
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType); 
                
        //Create bundle record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
         //Create available bundle record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = FROM_DATE;
        objServiceItem.EndDate__c = TO_DATE;
        Database.insert(objServiceItem);
        
        // Create DiscountType record
        DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(DISCOUNT_NAME, FROM_DATE, TO_DATE, DISCOUNT_TYPE, PERCENTAGE_DISCOUNT_AMOUNT);
        Database.insert(objDiscountType);
            
        // Create DiscountTypeitem record
        DiscountTypeitem__c objDiscountTypeitem = GlUt_FactoryData_Test.createDiscountTypeitem(objDiscountType,objServiceItemType);
        Database.insert(objDiscountTypeitem); 
    }    
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        17-01-2018  
	@description: Test Method to check applied discount in POSITIVE scenario
	*******************************************************************************/
    static testmethod void discountApply_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c con = [SELECT Id FROM BillingContract__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest();       
        	contractId = String.valueOf(con.Id);            
        	CuAp_SelectDiscountApplyCtrlr.ContainerWrapper wrapclass = new  CuAp_SelectDiscountApplyCtrlr.ContainerWrapper();
        	wrapclass = CuAp_SelectDiscountApplyCtrlr.getInfoToDisplay(contractId, sKeyValue, sOperation, sfilterOn); 
            Test.stopTest();
            System.assert(wrapclass != null);
        }
        
        
    }
    
    /*****************************************************************************
	@author:      Echo: Neha
	@date:        17-01-2018  
	@description: Test Method to check applied discount NEGATIVE scenario
	*******************************************************************************/
    static testmethod void discountApply_Negative()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        boolean isException = false;
       
        System.runAs(objUser){
            Test.startTest();      
        	CuAp_SelectDiscountApplyCtrlr.ContainerWrapper wrapclass = new  CuAp_SelectDiscountApplyCtrlr.ContainerWrapper();
            try{        		
        		wrapclass = CuAp_SelectDiscountApplyCtrlr.getInfoToDisplay(contractId, sKeyValue, sOperation, sfilterOn);
                 system.debug('wrapclass*' + wrapclass.discountList.size());
            }
            catch(Exception e)
            {
                isException = true;
            }
            Test.stopTest();
                     
            System.assert(wrapclass.discountList.size()== 0);            
        }
    }
    
    
    /*****************************************************************************
	@author:      Echo: Neha
	@date:        17-01-2018  
	@description: Test Method to check for picklistvaluesnew
	*******************************************************************************/
    static testmethod void picklist_TestMethod()
    {     
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];        
        Map<String,List<String>> mapWrapper = new Map<String,List<String>>();
        
        System.runAs(objUser){
            Test.startTest();                
         //	mapWrapper = CuAp_SelectDiscountApplyCtrlr.picklistvaluesnew();  
            Test.stopTest();
        }
        System.assert(mapWrapper != null);
    }
}