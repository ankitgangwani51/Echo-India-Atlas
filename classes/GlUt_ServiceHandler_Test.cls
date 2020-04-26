/******************************************************************************
@author:      Echo: Vivek Sethi 
@date:        24-07-2018  
@description: Test Class for GlUt_ServiceHandler
*******************************************************************************/
@isTest 
public class GlUt_ServiceHandler_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String CONTRACT_NAME ='TestContract';
    private static final String BILL_NAME = 'Test_Bill';
    private static final String BILL_ITEM_NAME = 'BillItem_Test';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String AVAIL_SERVICE_ITEM 		= 'AvailableServiceItem_Test';
    private static final String BUNDLE_NAME 			= 'Bundle_Test';
    private static final String SERVICE_ITEM_FAMILY 	= 'Service_Item_Family';
    private static final String BUNDLE_ITEM 			= 'Test_BundleItem';
    private static final Integer USED_VOLUME 			 = 50;
    private static final Integer BILLED_AMOUNT 			 = 150;
    private static final String HEROKU_POSTGRESID 		 = 'XYZ';
    private static final String BILL_SERVICE_TYPE_NAME   = 'BillServiceType_Test';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
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
    private static final Decimal VOLUMEUPDATED = 50.00;
    private static final String TRADEEFFLUENT = 'Trade Effluent';
    private static final String SEWERAGE = 'Sewerage';
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:         24-07-2018  
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
       
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLE_BUNDLE, objBundle, objAvailableService );
        Database.insert(objAvailableBundle);	
       
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);	
        
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);
   
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME, objContract);
        Database.insert(objBill);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE_NAME, objBill, HEROKU_POSTGRESID);
        Database.insert(objBillServiceType);  
    }    
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        24-07-2018  
	@description: Method for inserting a new TE record with Sewerage record existing
	*******************************************************************************/
    static testmethod void volumePercentage_TEPositive()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c LIMIT 1];
        Reading__c objReading = [SELECT Id FROM  Reading__c LIMIT 1];
        ServiceType__c  objServiceType =  [SELECT Id FROM  ServiceType__c  WHERE Name  =: TRADEEFFLUENT LIMIT 1];
        SupplyPoint__c  objSupplyPoint =  [SELECT Id FROM  SupplyPoint__c LIMIT 1];
        AvailableService__c  objAvailableService = [SELECT Id FROM  AvailableService__c LIMIT 1];
        
        //Inserting Sewerage Type Service in Advance
        ServiceType__c  objServiceTypeSew =  [SELECT Id FROM  ServiceType__c  WHERE Name  =: SEWERAGE LIMIT 1];
        Service__c objServiceSew= GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceTypeSew,objSupplyPoint,objAvailableService);
        objServiceSew.VolumePercentage__c = VOLUME;
        Database.insert(objServiceSew);
    
        //Creating new TE service
        Service__c  objService = new Service__c();
        objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        objService.VolumePercentage__c = VOLUME;
     
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objService);
    
            Service__c  objServiceEffluent =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: TRADEEFFLUENT LIMIT 1]; 
            Service__c  objServiceSewerage =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: SEWERAGE LIMIT 1]; 
            system.assertEquals(objServiceEffluent.VolumePercentage__c + objServiceSewerage.VolumePercentage__c, 100);
            Test.stopTest();
        }   
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:         24-07-2018  
	@description: Method for inserting  a new Sewerage record with TE record existing
	*******************************************************************************/
    static testmethod void volumePercentage_SewPositive()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c LIMIT 1];
        Reading__c objReading = [SELECT Id FROM  Reading__c LIMIT 1];
        ServiceType__c  objServiceType =  [SELECT Id FROM  ServiceType__c  WHERE Name  =:  SEWERAGE  LIMIT 1];
        SupplyPoint__c  objSupplyPoint =  [SELECT Id FROM  SupplyPoint__c LIMIT 1];
        AvailableService__c  objAvailableService = [SELECT Id FROM  AvailableService__c LIMIT 1];
        
        //Inserting TE Type Service in Advance
        ServiceType__c  objServiceTypeTE=  [SELECT Id FROM  ServiceType__c  WHERE Name  =: TRADEEFFLUENT LIMIT 1];
        Service__c objServiceTE= GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceTypeTE,objSupplyPoint,objAvailableService);
        objServiceTE.VolumePercentage__c = VOLUME;
        Database.insert(objServiceTE);
        
        //Creating new sewerage service
        Service__c  objService = new Service__c();
        objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        objService.VolumePercentage__c = VOLUME;
        
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objService);
            
            Service__c  objServiceEffluent =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: TRADEEFFLUENT LIMIT 1]; 
            Service__c  objServiceSewerage =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: SEWERAGE LIMIT 1]; 
            system.assertEquals(objServiceEffluent.VolumePercentage__c + objServiceSewerage.VolumePercentage__c, 100);
            Test.stopTest();
        }    
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:         24-07-2018  
	@description: Method for inserting  a new Sewerage record along with TE record
	*******************************************************************************/
    static testmethod void volumePercentage_SewTEPositive()
    {   
        List<Service__c> serviceList = new List<Service__c>();
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c LIMIT 1];
        Reading__c objReading = [SELECT Id FROM  Reading__c LIMIT 1];
        ServiceType__c  objServiceType =  [SELECT Id FROM  ServiceType__c  WHERE Name  =:  SEWERAGE  LIMIT 1];
        SupplyPoint__c  objSupplyPoint =  [SELECT Id FROM  SupplyPoint__c LIMIT 1];
        AvailableService__c  objAvailableService = [SELECT Id FROM  AvailableService__c LIMIT 1];
        
        //Inserting TE Type Service
        ServiceType__c  objServiceTypeTE=  [SELECT Id FROM  ServiceType__c  WHERE Name  =: TRADEEFFLUENT LIMIT 1];
        Service__c objServiceTE= GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceTypeTE,objSupplyPoint,objAvailableService);
        //objServiceTE.VolumePercentage__c = VOLUME;
        serviceList.add(objServiceTE);
        
        //Creating new sewerage service
        Service__c  objService = new Service__c();
        objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        //objService.VolumePercentage__c = VOLUME;
        serviceList.add(objService);
        
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(serviceList);   //inserting both the records at once
            
            Service__c  objServiceEffluent =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: TRADEEFFLUENT LIMIT 1]; 
            Service__c  objServiceSewerage =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: SEWERAGE LIMIT 1]; 
            system.assertEquals(objServiceEffluent.VolumePercentage__c + objServiceSewerage.VolumePercentage__c, 100);
            
            objServiceEffluent.VolumePercentage__c = VOLUME + 20;  //Updating its value again;
            Database.update(objServiceEffluent);
            
 			Service__c  objServiceEffluent1 =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: TRADEEFFLUENT LIMIT 1]; 
            Service__c  objServiceSewerage1 =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: SEWERAGE LIMIT 1]; 
            system.assertEquals(objServiceEffluent1.VolumePercentage__c + objServiceSewerage1.VolumePercentage__c, 100); 
            
            Test.stopTest();
        }   
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi   AT-3454
	@date:        18-09-2018  
	@description: Method for Updating a new record to check volumePercentageAmendments
	*******************************************************************************/
    static testmethod void volumePercentageAmendments_Positive()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BillingContract__c objContract = [SELECT Id FROM  BillingContract__c LIMIT 1];
        Reading__c objReading = [SELECT Id FROM  Reading__c LIMIT 1];
        ServiceType__c  objServiceType =  [SELECT Id FROM  ServiceType__c  WHERE Name  =: TRADEEFFLUENT LIMIT 1];
        SupplyPoint__c  objSupplyPoint =  [SELECT Id FROM  SupplyPoint__c LIMIT 1];
        AvailableService__c  objAvailableService = [SELECT Id FROM  AvailableService__c LIMIT 1];
        BillServiceType__c objBillServiceType = [SELECT Id from BillServiceType__c LIMIT 1];
        AvailableServiceItem__c objAvailableServiceItem  = [SELECT Id from AvailableServiceItem__c LIMIT 1];
        ServiceItemType__c objServiceItemType = [SELECT Id FROM  ServiceItemType__c LIMIT 1];
        Bill__c objBill = [SELECT Id FROM  Bill__c LIMIT 1];
        
        //Inserting Sewerage Type Service in Advance
        ServiceType__c  objServiceTypeSew =  [SELECT Id FROM  ServiceType__c  WHERE Name  =: SEWERAGE LIMIT 1];
        Service__c objServiceSew= GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceTypeSew,objSupplyPoint,objAvailableService);
        objServiceSew.VolumePercentage__c = VOLUME;
        Database.insert(objServiceSew);
        
      	//Creating Service Item
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objServiceSew) ;
		objServiceItem.StartDate__c = Date.Today() ;
		objServiceItem.EndDate__c = Date.Today().addMonths(10) ;
		Database.insert(objServiceItem) ;

        //Creating Bill Item
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME, objServiceItem, USED_VOLUME , BILLED_AMOUNT , objBillServiceType , HEROKU_POSTGRESID);
        objBillItem.Bill__c = objBill.id;
        Database.insert(objBillItem); 
        
        //Updating Sewerage Type Service
        Service__c  objServiceSewerage =  [SELECT Id, VolumePercentage__c FROM  Service__c  WHERE ServiceType__r.Name  =: SEWERAGE LIMIT 1]; 
        objServiceSewerage.VolumePercentage__c = VOLUMEUPDATED;

        System.runAs(objUser){
            Test.startTest();             
            Database.upsert(objServiceSewerage);
            // Checking for its New Service Item
            ServiceItem__c objServiceItem1 = 	[SELECT Id FROM ServiceItem__c WHERE AmendedByServiceItem__c = NULL];
            system.assertNotEquals(objServiceItem1.Id,null);            
            Test.stopTest();
        }   

    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:         24-07-2018  
	@description: Method for inserting  a new Sewerage record with TE record existing negative scenario
	*******************************************************************************/
    static testmethod void volumePercentage_Negative()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BillingContract__c objContract = new BillingContract__c();
        Reading__c objReading = [SELECT Id FROM  Reading__c LIMIT 1];
        ServiceType__c  objServiceType =  [SELECT Id FROM  ServiceType__c  WHERE Name  =:  SEWERAGE  LIMIT 1];
        SupplyPoint__c  objSupplyPoint =  [SELECT Id FROM  SupplyPoint__c LIMIT 1];
        AvailableService__c  objAvailableService = [SELECT Id FROM  AvailableService__c LIMIT 1];
        
        //Creating new sewerage service without contract
        Service__c  objService = new Service__c();
        objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        objService.VolumePercentage__c = VOLUME;
        
        Boolean isException;
        System.runAs(objUser){
            Test.startTest(); 
            try{            
                Database.insert(objService);
            }
            catch(exception e){
                isException = true;
            }
            
            system.assertEquals(isException, true);
            Test.stopTest();
        }  

    }
}