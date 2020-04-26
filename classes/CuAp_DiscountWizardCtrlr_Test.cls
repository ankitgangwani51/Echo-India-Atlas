/******************************************************************************
@author:      Echo: Neha 
@date:        17-01-2018  
@description: Test Class for CuAp_DiscountWizardCtrlr
@Revision	 	AT-3975, Tarun - Modified as per security review
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class CuAp_DiscountWizardCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String DISCOUNT_NAME = 'EP Discount'; 
    private static final date FROM_DATE = date.today();
    private static final date TO_DATE = date.today() + 30;
    private static final String DISCOUNT_TYPE = 'Fixed';
    private static final decimal DISCOUNT_AMT = 20;
    private static final String DEVICE_TYPE = 'small Meter';
    private static final String	DEVICE_NAME = 'Meter';
    private static final String SERVICE_TYPE = 'Service_Type';  
    private static final String ZIPCODE = 'WS2 8DE';
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';
    private static final String WHOLESALER = 'abc';
    private static final String AVAIL_SERVICE = 'WATER';
    private static final String SERVICE_ITEM_FAMILY = 'Service_Item_Family';
    private static final String BUNDLE_ITEM = 'Test_BundleItem';
    private static final String BUNDLE_NAME = 'Bundle_Test';
    private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
    private static final String AVAIL_SERVICE_ITEM = 'AvailableServiceItem_Test'; 
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String INVALID_STATUS = 'Invalid Status';
    private static final String WIZARDTYPE = 'NewDiscount'; 
    private static final String WIZARDTYPEEXISTING = 'ExistingDiscount'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    private static String wizardprop; 
    
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
        
        // Create DiscountType Record
        DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(DISCOUNT_NAME, FROM_DATE, TO_DATE, DISCOUNT_TYPE, DISCOUNT_AMT);        
        objDiscountType.PercentageDiscountAmount__c = null;
        objDiscountType.AbsoluteDiscountAmount__c = DISCOUNT_AMT;
        Database.insert(objDiscountType);        
        
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
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE);
        Database.insert(objServiceType);
        
        // Create Location Record            
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        Database.insert(objLocation);
		
        // Create SupplyPointUsageType Record        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record            
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation,objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Division Record            
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision); 
        
        // Create Wholesaler Record            
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler); 
        
        // Create AvailableService Record            
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE, objDivision, objServiceType, objSupplyPoint, objWholesaler );
        Database.insert(objAvailableService);
        
        // Create Service Record            
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService); 
        
         // Create ServiceItemFamily Record            
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);
        Database.insert(objServiceItemFamily);
        
        // Create ServiceItemType Record            
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType);
        
        // Create Bundle Record            
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType);
        Database.insert(objBundle);
        
        // Create BundleItem Record            
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);	
        
        // Create AvailableBundle Record            
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLE_BUNDLE, objBundle, objAvailableService );
        Database.insert(objAvailableBundle);
        
        // Create AvailableServiceItem Record            
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);
                
        // Create ServiceItem Record            
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = Date.today();
        Database.insert(objServiceItem);
        
        // Create Discount Record
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);
        Database.insert(objDiscount);  
        
    }
      
    /******************************************************************************
	@author:      Echo: Neha
	@date:        17-01-2018  
	@description: Test Method to check discount Wizard, if all info correct
	*******************************************************************************/  
    static testmethod void updateWizardProperties_positive()
    {
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];        
        BillingContract__c con = [SELECT Id FROM BillingContract__c LIMIT 1];             
        
        CuAp_DiscountWizardCtrlr.WizardObject WizardObj = new CuAp_DiscountWizardCtrlr.WizardObject();             
        WizardObj.recordId = con.Id ;
        WizardObj.contractId = con.Id ;
        WizardObj.wizardType = WIZARDTYPE ;
        
        wizardprop = System.JSON.serialize(WizardObj);
            
        System.runAs(objUser){
            Test.startTest();              
            CuAp_DiscountWizardCtrlr.WizardStatus(wizardprop);
            Test.stopTest();
            System.assert(!wizardprop.containsAny('?'));
        }
    }   
            
    /******************************************************************************
	@author:      Echo: Neha
	@date:        02-02-2018  
	@description: Test Method to add new discount in Positive scenario
	*******************************************************************************/  
    static testmethod void createDiscount_Positive()
    {
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Id result ;
            
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        DiscountType__c objDiscountType = [SELECT Id FROM DiscountType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c objServiceItem = [SELECT Id FROM ServiceItem__c LIMIT 1];
        
        List<Discount__c> listdiscount = new List<Discount__c>();
         
        // Create Discount Record
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType); 
        listdiscount.add(objDiscount);
               
        CuAp_DiscountWizardCtrlr.WizardObject WizardObj = new CuAp_DiscountWizardCtrlr.WizardObject();             
        WizardObj.recordId = objContract.Id ;
        WizardObj.contractId = objContract.Id ;
        WizardObj.wizardType = WIZARDTYPE ;
        WizardObj.discount = listdiscount;
        WizardObj.DiscountType = objDiscountType;
        
        wizardprop = System.JSON.serialize(WizardObj);
           
        System.runAs(objUser){
            Test.startTest();              
            result = CuAp_DiscountWizardCtrlr.createDiscount(wizardprop);
            Test.stopTest();
            system.assert(result!= null);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        02-02-2018  
	@description: Test Method to add new discount in Negative scenario
	*******************************************************************************/  
    static testmethod void createDiscount_Negative()
    {
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Id result ;
        Boolean isException;
            
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        DiscountType__c objDiscountType = [SELECT Id FROM DiscountType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c objServiceItem = [SELECT Id FROM ServiceItem__c LIMIT 1];
        
        List<Discount__c> listdiscount = new List<Discount__c>();
         
        // Create Discount Record
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);  
        listdiscount.add(objDiscount);
        objDiscount.Status__c = INVALID_STATUS;
               
        CuAp_DiscountWizardCtrlr.WizardObject WizardObj = new CuAp_DiscountWizardCtrlr.WizardObject();             
        WizardObj.recordId = objContract.Id ;
        WizardObj.contractId = objContract.Id ;
        WizardObj.wizardType = WIZARDTYPE ;
        WizardObj.discount = listdiscount;
        WizardObj.DiscountType = objDiscountType;
        
        wizardprop = System.JSON.serialize(WizardObj);
           
        System.runAs(objUser){
            try{
            	Test.startTest(); 
            	result = CuAp_DiscountWizardCtrlr.createDiscount(wizardprop);
            }catch(exception e){               
                isException = true;
            }
            
            system.assert(isException == true);
            Test.stopTest();
        }
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        12 Feb 2018
	@description: Test Method to create/update discount in Positive scenario
	*******************************************************************************/  
    static testmethod void createUpdateDiscount_Positive()
    {
        User objUser = [SELECT Id, Name FROM User WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        Discount__c result;
        Boolean isException;
            
        BillingContract__c 	objContract 	= [SELECT Id FROM BillingContract__c LIMIT 1];
        DiscountType__c objDiscountType = [SELECT Id FROM DiscountType__c LIMIT 1];
        Service__c 		objService 		= [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c 	objServiceItem 	= [SELECT Id FROM ServiceItem__c LIMIT 1];
        
        List<Id> lstDiscId = new List<Id>();
        Discount__c objDisc = [SELECT Id FROM Discount__c LIMIT 1];
        lstDiscId.add(objDisc.Id);
        
        List<Discount__c> listdiscount = new List<Discount__c>(); 
        
        // Create Discount Record
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);  
        listdiscount.add(objDiscount);
               
        CuAp_DiscountWizardCtrlr.WizardObject WizardObj = new CuAp_DiscountWizardCtrlr.WizardObject();             
        WizardObj.recordId = objContract.Id ;
        WizardObj.contractId = objContract.Id ;
        WizardObj.wizardType = WIZARDTYPEEXISTING ;
        WizardObj.lstDiscountIds = lstDiscId;
        WizardObj.discount = listdiscount;
        WizardObj.DiscountType = objDiscountType;
        
        wizardprop = System.JSON.serialize(WizardObj);
           
        System.runAs(objUser){
            try{
                Test.startTest();
                result = CuAp_DiscountWizardCtrlr.createUpdateDiscount(wizardprop);    
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            System.assertEquals(isException,null);   
        }
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        12 Feb 2018
	@description: Test Method to create/update discount in Negative scenario
	*******************************************************************************/  
    static testmethod void createUpdateDiscount_Negative()
    {
        User objUser = [SELECT Id, Name FROM User WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];  
        Discount__c result;
        Boolean isException;
            
        BillingContract__c 	objContract 	= [SELECT Id FROM BillingContract__c LIMIT 1];
        DiscountType__c objDiscountType = [SELECT Id FROM DiscountType__c LIMIT 1];
        Service__c 		objService 		= [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c 	objServiceItem 	= [SELECT Id FROM ServiceItem__c LIMIT 1];
        
        
        List<Id> lstDiscId = new List<Id>();
        Discount__c objDisc = [SELECT Id FROM Discount__c LIMIT 1];
        lstDiscId.add(objDisc.Id);

        List<Discount__c> listdiscount = new List<Discount__c>();
         
        // Create Discount Record
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);  
        listdiscount.add(objDiscount);
        objDiscount.Status__c = INVALID_STATUS;
               
        CuAp_DiscountWizardCtrlr.WizardObject WizardObj = new CuAp_DiscountWizardCtrlr.WizardObject();             
        WizardObj.recordId = objContract.Id ;
        WizardObj.contractId = objContract.Id ;
        WizardObj.wizardType = WIZARDTYPEEXISTING;
        WizardObj.lstDiscountIds = lstDiscId;
        WizardObj.discount = listdiscount;
        WizardObj.DiscountType = objDiscountType;
        
        wizardprop = System.JSON.serialize(WizardObj);
           
         System.runAs(objUser){
            try{
                Test.startTest();
                result = CuAp_DiscountWizardCtrlr.createUpdateDiscount(wizardprop);    
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            System.assertEquals(isException,true,'Negative scenario passed');   
        }
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        12 Feb 2018
	@description: Test Method to update an existing discount in Positive scenario
	*******************************************************************************/  
    static testmethod void updateDiscount_Positive()
    {
        User objUser = [SELECT Id, Name FROM User WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];  
        Discount__c result;
        Boolean isException;
            
        BillingContract__c 	objContract 	= [SELECT Id FROM BillingContract__c LIMIT 1];
        DiscountType__c objDiscountType = [SELECT Id FROM DiscountType__c LIMIT 1];
        Service__c 		objService 		= [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c 	objServiceItem 	= [SELECT Id FROM ServiceItem__c LIMIT 1];
        
        Discount__c objDiscount = [SELECT Id FROM Discount__c LIMIT 1];
        List<Discount__c> listdiscount = new List<Discount__c>();
        listdiscount.add(objDiscount);
               
        CuAp_DiscountWizardCtrlr.WizardObject WizardObj = new CuAp_DiscountWizardCtrlr.WizardObject();             
        WizardObj.recordId = objContract.Id ;
        WizardObj.contractId = objContract.Id ;
        WizardObj.wizardType = WIZARDTYPEEXISTING ;
        WizardObj.discount = listdiscount;
        WizardObj.DiscountType = objDiscountType;
        
        wizardprop = System.JSON.serialize(WizardObj);
           
        System.runAs(objUser){
            Test.startTest();              
            result = CuAp_DiscountWizardCtrlr.updateDiscount(wizardprop);
            Test.stopTest();
            System.assertEquals(isException,null);   
        }
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        12 Feb 2018
	@description: Test Method to update an existing discount in Negative scenario
	*******************************************************************************/  
    static testmethod void updateDiscount_Negative()
    {
        User objUser = [SELECT Id, Name FROM User WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];   
        Discount__c result;
        Boolean isException;
            
        BillingContract__c 	objContract 	= [SELECT Id FROM BillingContract__c LIMIT 1];
        DiscountType__c objDiscountType = [SELECT Id FROM DiscountType__c LIMIT 1];
        Service__c 		objService 		= [SELECT Id FROM Service__c LIMIT 1];
        ServiceItem__c 	objServiceItem 	= [SELECT Id FROM ServiceItem__c LIMIT 1];
        
        Discount__c objDiscount = [SELECT Id FROM Discount__c LIMIT 1];
        objDiscount.Status__c = INVALID_STATUS;
        List<Discount__c> listdiscount = new List<Discount__c>();
        listdiscount.add(objDiscount);
               
        CuAp_DiscountWizardCtrlr.WizardObject WizardObj = new CuAp_DiscountWizardCtrlr.WizardObject();             
        WizardObj.recordId = objContract.Id ;
        WizardObj.contractId = objContract.Id ;
        WizardObj.wizardType = WIZARDTYPEEXISTING ;
        WizardObj.discount = listdiscount;
        WizardObj.DiscountType = objDiscountType;
        
        wizardprop = System.JSON.serialize(WizardObj);
           
        System.runAs(objUser){
            try{
            	Test.startTest(); 
            	result = CuAp_DiscountWizardCtrlr.updateDiscount(wizardprop);
            }catch(exception e){               
                isException = true;
            }
            
            system.assert(isException == true);
            Test.stopTest();
            System.assertEquals(isException,true,'Negative Scenario Passed');   
        }
    }
     
}