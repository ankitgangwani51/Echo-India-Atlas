/******************************************************************************
@author:      Echo: Neha 
@date:        14 Nov 2018
@description: Test Class for CuAp_AUMoveInWizardCtrlr
*******************************************************************************/

@isTest
public class CuAp_AUMoveInWizardCtrlr_Test {
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String ACCOUNT_NAME 			= 'TestAccount';
    private static final String ACCOUNT_NAME_2 			= 'Test Account 2';
    private static final String STREET		 			= 'Test Street';
    private static final String CITY 					= 'Test City';
    private static final String STATE				 	= 'Test State';
    private static final String POSTAL_CODE 			= '0000000';
    private static final String COUNTRY 				= 'Test Country';
    private static final String LOCATION_NAME 			= 'A99 9AA';
    private static final String LOCATION_SUB_TYPE 		= 'Detached';
    private static final String LOCATION_STREET 		= 'Test Street';
    private static final String YES 					= 'yes';
    private static final String MEASURED 				= 'Monthly';
    private static final String WHOLESALER 				= 'TestWholesaler';
    private static final String AVAILABLESERVICES 		= 'TestAvailableService';
    private static final String BUNDLENAME  			= 'TestBundle';
    private static final String BUNDLEITEM 				= 'TestBundleItem';
    private static final String AVAILABLESERVIEITEM		= 'TestAvailableServiceItem';
    private static final String DEVICETYPE 				= 'TestDeviceType';
    private static final String SERVICEITEMTYPE 		= 'TestSrvItemType';  
    private static final String SERVICEITEMFAMILY 		= 'TestServiceItemFamily';  
    private static final String DEVICENAME 				= 'TestDevice';
    private static final String TEST_SERVICE_TYPE 		= 'TestServiceType';
    private static final String MANUAL_ESTIMATED 		= 'Manual Estimated';
    private static final String CUSTOMER_READING 		= 'Customer Reading';
    private static final String MOVE_IN			 		= 'Move In';
    private static final String REGULAR 				= 'Regular';
    private static final String OWNER    				= 'Owner';  
    private static final String TENANT    				= 'Tenant'; 
    private static final String ACTUAL_DEVICE_READING	= '120';  
    private static final String DEVICE_SIZE 			= 'TestDeviceSize';
    private static final String MANUFACTURER 			= 'Siemens';
    private static final String MANUFACTURER1 			= 'Kent';
    private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';
    private static final String UNIT_OF_MEASURE 		= 'Metric';
    private static final String NONHOUNSEHOLDACCOUNT 	= 'Non-Household Account';
    private static final String SENDER_EMAIL			= 'neharajput@echo-ms.com';
    private static final String BILL_ITEM  = 'Bill ITEM';
    private static final String BILL  = 'BIll no';
    private static final String BILL_SERVICE_TYPE  = 'BILL SERVICE TYPE';
    private static final String HEROKU_ID  = '907dda54187e40859b6a4725f9e4522b';
    private static final Integer BILL_VOLUMEUSED  = 20;
    private static final Integer BILLED_AMT  = 20;
    
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          16 Feb 2018
    @return        Void   
    @description   Test data setup method
	@revesion	   Change By Dependra Singh- 25-02-2019- Salesforce Limit Analysis
    *******************************************************************************/ 
    @TestSetup
    Static void createTestData(){
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        List<Account> lstAccount = new List<Account>();        
        //Create First Account Record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        lstAccount.add(objAccount);
        //Database.insert(objAccount);
            
        //Create Second Account Record
        Account objAccount1 = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME_2);     
        lstAccount.add(objAccount1);
        Database.insert(lstAccount);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',lstAccount[0]);
        objContract.BillingStreet__c     = STREET;
        objContract.BillingCity__c       = CITY;
        objContract.BillingState__c      = STATE;
        objContract.BillingPostalCode__c = POSTAL_CODE;
        objContract.BillingCountry__c    = COUNTRY;
        Database.insert(objContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c = LOCATION_SUB_TYPE ; 
        objLocation.City__c            = CITY;
        objLocation.State__c           = STATE;
        objLocation.Street__c          = STREET;
        objLocation.Country__c         = COUNTRY;
        Database.insert(objLocation);
        
        // Create Location Occupant Record 
        LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(lstAccount[1], objLocation);
        objLocationOccupant.EndDate__c   =  null;  // System.today() - 1;
        objLocationOccupant.StartDate__c = System.today() - 30;
        Database.insert(objLocationOccupant);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point Record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c      = True; 
        Database.insert(objSupplyPoint);
        
        List<DeviceSize__c> lstDeviceSize = new List<DeviceSize__c>();
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        lstDeviceSize.add(objDeviceSize);
        //Database.insert(objDeviceSize);
        
        // Create Device Size Record - 
        DeviceSize__c objDeviceSize1 = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        lstDeviceSize.add(objDeviceSize1);
        Database.insert(lstDeviceSize);
        
        List<DeviceType__c> lstDeviceType = new List<DeviceType__c>();
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(lstDeviceSize[0],MANUFACTURER,UNIT_OF_MEASURE);
        lstDeviceType.add(objDeviceType);
        //Database.insert(objDeviceType);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType1 = GlUt_FactoryData_Test.createDeviceType(lstDeviceSize[1],MANUFACTURER1,UNIT_OF_MEASURE);
        lstDeviceType.add(objDeviceType1);
        Database.insert(lstDeviceType);
        
        //Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME,lstDeviceType[0]);
        objDevice.Digit__c = 3;
        Database.insert(objDevice);
        
        //Create Supply Point Record
        SupplyPointDevice__c  objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        //Create Service Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        Database.insert(objServiceType);
        
        //Create Service Item Family Record
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ActualDeviceReading__c = '100';
        objReading.ReadingDate__c= system.today();
        Database.insert(objReading);
        
        //Create Service Record
        Service__c  objService = GlUt_FactoryData_Test.createService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);        
        Database.insert(objService);

        //Create First Service Item Type Record
        List<ServiceItemType__c> lstServiceItemType = new List<ServiceItemType__c>();
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,lstDeviceType[0],objWholesaler);
        objServiceItemType.StartDate__c = system.today() - 5;
        objServiceItemType.EndDate__c = null;  
        lstServiceItemType.add(objServiceItemType);
       // objServiceItemType.Landlord__c= true;
        //Database.insert(objServiceItemType);
        
        // Create Second Service Item Type Record 
        ServiceItemType__c  objServiceItemType1 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE+'-1',objServiceItemFamily,objDivision,lstDeviceType[1],objWholesaler);        
        objServiceItemType1.StartDate__c = system.today() - 5;
        objServiceItemType1.EndDate__c = null; 
        lstServiceItemType.add(objServiceItemType1);
        Database.insert(lstServiceItemType);
        
         
        // Create First Bundle Record
        List<Bundle__c> lstBundle = new List<Bundle__c>();
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        lstBundle.add(objBundle);
        //Database.insert(objBundle);
        
        // Create Second Bundle Record
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME +'-1',objServiceType);
        lstBundle.add(objBundle1);
        Database.insert(lstBundle);
        
        // Create Available Bundle Record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,lstBundle[0],objAvailableService);
        Database.insert(objAvailableBundle);
        
        
        //Create First Bundle Item Record
        List<BundleItem__c> lstBundleItem = new List<BundleItem__c>();
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,lstBundle[0],lstServiceItemType[0],objServiceItemFamily);
        lstBundleItem.add(objBundleItem);
        //Database.insert(objBundleItem);
        
        //Create Second Bundle Item Record
        BundleItem__c  objBundleItem0 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,lstServiceItemType[1],objServiceItemFamily);
        lstBundleItem.add(objBundleItem0);
        //Database.insert(objBundleItem0);
        
        // Create Third Bundle Item Record
        BundleItem__c  objBundleItem1 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM+'-1',lstBundle[1],lstServiceItemType[1],objServiceItemFamily);
        lstBundleItem.add(objBundleItem1);
        Database.insert(lstBundleItem);
       
       
        // Create First Available Service Item Record
        List<AvailableServiceItem__c> lstAvailableServiceItem = new List<AvailableServiceItem__c>();
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,lstBundleItem[0],lstServiceItemType[0],objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = lstServiceItemType[0].id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        lstAvailableServiceItem.add(objAvailableServiceItem);
        //Database.insert(objAvailableServiceItem); 
        
        //Create Second Available Service Item Record
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM+'-1',lstBundleItem[0],lstServiceItemType[0],objAvailableBundle);
        objAvailableServiceItem1.ServiceItemType__c = lstServiceItemType[0].id;
        objAvailableServiceItem1.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem1.EndDate__c =Date.newInstance(2019, 12, 9);
        lstAvailableServiceItem.add(objAvailableServiceItem1);
        Database.insert(lstAvailableServiceItem); 
        
        //Create First Service Item Record
        List<ServiceItem__c> lstServiceItem = new List<ServiceItem__c>();
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(lstAvailableServiceItem[0],lstServiceItemType[0],objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        lstServiceItem.add(objServiceItem);
        // Database.insert(objServiceItem);
        
        //Create Second Service Item Record
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.CreateServiceItem(lstAvailableServiceItem[0],lstServiceItemType[1],objService);
        objServiceItem1.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem1.EndDate__c = Null; //Date.newInstance(2019, 12, 9);
        lstServiceItem.add(objServiceItem1);
        Database.insert(lstServiceItem);
        
        //Custom Setting
        ConfigureTemplate__c  objConfigureTemplate = GlUt_FactoryData_Test.createConfigureTemplate(SENDER_EMAIL);       
        Database.insert(objConfigureTemplate);
       
        // Contact Record
        Contact  objContact = GlUt_FactoryData_Test.createContact(USER_FNAME,USER_LNAME);
        objContact.Email = SENDER_EMAIL;
        objContact.AccountId = lstAccount[0].Id;
        Database.insert(objContact);
        
        // Create Bill Record 
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL, objContract);             
        Database.insert(objBill);
        
        // Create BillServiceType Record 
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE, objBill, HEROKU_ID);             
        Database.insert(objBillServiceType); 
        
        // Create Bill Item Record 
        BillItem__c  objBillItem = GlUt_FactoryData_Test.createBillItem(BILL_ITEM, lstServiceItem[0], BILL_VOLUMEUSED, BILLED_AMT, objBillServiceType, HEROKU_ID );             
        Database.insert(objBillItem);     
        
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        
    @description: 
    *******************************************************************************/
    static testmethod void TenentExistMoveInTenant(){
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        LocationOccupant__c objLocationOccupant = [SELECT OccupancyType__c FROM LocationOccupant__c LIMIT 1];
        objLocationOccupant.OccupancyType__c = TENANT;
        Database.update(objLocationOccupant);
        
        List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();
        for(ServiceItemType__c objServiceItemType : [SELECT Tenant__c FROM ServiceItemType__c LIMIT 10] ){
            objServiceItemType.Tenant__c = true;
            serviceItemTypeList.add(objServiceItemType);
        }
        Database.update(serviceItemTypeList);
        
        CuAp_AUMoveInWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveInWizardCtrlr.WizardObject();
        objWizardObject = wizardObject(TENANT);        
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);       
        Map<String,Boolean> status = new Map<String,Boolean>();
        Map<String, String> mapObject2Id = new Map<String, String>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUMoveInWizardCtrlr.wizardStatus(jsonSerializeWizard);  
            //mapObject2Id = CuAp_AUMoveInWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            //system.assert(mapObject2Id.get('contractId') != null);        
            system.assertNotEquals(status,null);              
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        
    @description: 
    *******************************************************************************/
    static testmethod void landlordExistMoveInTenant(){
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        LocationOccupant__c objLocationOccupant = [SELECT OccupancyType__c FROM LocationOccupant__c LIMIT 1];
        objLocationOccupant.OccupancyType__c = OWNER;
        Database.update(objLocationOccupant);
        
        List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();
        for(ServiceItemType__c objServiceItemType : [SELECT Tenant__c FROM ServiceItemType__c]){
            objServiceItemType.Landlord__c = true;
            serviceItemTypeList.add(objServiceItemType);
        }
        Database.update(serviceItemTypeList);
        
        CuAp_AUMoveInWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveInWizardCtrlr.WizardObject();
        objWizardObject = wizardObject(TENANT);        
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);       
        Map<String,Boolean> status = new Map<String,Boolean>();
        Map<String, String> mapObject2Id = new Map<String, String>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUMoveInWizardCtrlr.wizardStatus(jsonSerializeWizard);  
            mapObject2Id = CuAp_AUMoveInWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            system.assert(mapObject2Id.get('contractId') != null);           
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        
    @description: 
    *******************************************************************************/
    static testmethod void ownerExistMoveInTenant(){
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        LocationOccupant__c objLocationOccupant = [SELECT OccupancyType__c FROM LocationOccupant__c LIMIT 1];
        objLocationOccupant.OccupancyType__c = OWNER;
        Database.update(objLocationOccupant);
        
        List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();
        for(ServiceItemType__c objServiceItemType : [SELECT Tenant__c FROM ServiceItemType__c]){
            objServiceItemType.Owner__c = true;
            serviceItemTypeList.add(objServiceItemType);
        }
        Database.update(serviceItemTypeList);
        
        CuAp_AUMoveInWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveInWizardCtrlr.WizardObject();
        objWizardObject = wizardObject(TENANT);        
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);       
        Map<String,Boolean> status = new Map<String,Boolean>();
        Map<String, String> mapObject2Id = new Map<String, String>();
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUMoveInWizardCtrlr.wizardStatus(jsonSerializeWizard);  
            mapObject2Id = CuAp_AUMoveInWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            system.assert(mapObject2Id.get('contractId') != null);           
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        
    @description: 
    *******************************************************************************/
    static testmethod void moveIn_Owner(){
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        LocationOccupant__c objLocationOccupant = [SELECT OccupancyType__c,EndDate__c FROM LocationOccupant__c LIMIT 1];
        objLocationOccupant.OccupancyType__c = OWNER;
        objLocationOccupant.EndDate__c = null;        
        Database.update(objLocationOccupant);
        
        List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();
        for(ServiceItemType__c objServiceItemType : [SELECT Tenant__c FROM ServiceItemType__c]){
            objServiceItemType.Landlord__c = true;
            serviceItemTypeList.add(objServiceItemType);
        }
        Database.update(serviceItemTypeList);
        
        CuAp_AUMoveInWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveInWizardCtrlr.WizardObject();
        objWizardObject = wizardObject(OWNER);        
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);       
        Map<String,Boolean> status = new Map<String,Boolean>();
        Map<String, String> mapObject2Id = new Map<String, String>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUMoveInWizardCtrlr.wizardStatus(jsonSerializeWizard);  
            mapObject2Id = CuAp_AUMoveInWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest(); 
            system.assert(mapObject2Id.get('contractId') != null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        14 Nov 2018
    @description: Test Method to check Move In Wizard Details in Negative scenario
    *******************************************************************************/
    static testmethod void moveIn_Negative(){
        User objUser = [Select Id, 
                        Name
                        FROM User
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        LocationOccupant__c objLocationOccupant = [SELECT OccupancyType__c FROM LocationOccupant__c LIMIT 1];
        objLocationOccupant.OccupancyType__c = OWNER;
        Database.update(objLocationOccupant);
        
        CuAp_AUMoveInWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveInWizardCtrlr.WizardObject();
        objWizardObject = wizardObject(OWNER);   
        objWizardObject.selectedOccType = 'null';
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);       
        Map<String,Boolean> status = new Map<String,Boolean>();
        Map<String, String> mapObject2Id = new Map<String, String>();       
        Boolean isException = false;
        System.runAs(objUser){
            try{
                Test.startTest();
                status = CuAp_AUMoveInWizardCtrlr.wizardStatus(jsonSerializeWizard);  
            	mapObject2Id = CuAp_AUMoveInWizardCtrlr.moveIn(jsonSerializeWizard);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assertEquals(isException, true);
        }        
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        
    @description: 
    *******************************************************************************/
    private static CuAp_AUMoveInWizardCtrlr.WizardObject wizardObject(String occType){      
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Location__c objLocation = [SELECT Id,
                                   Street__c,
                                   City__c,
                                   State__c,
                                   PostalCode__c,
                                   Country__c,
                                   NumberofOccupiers__c
                                   FROM Location__c LIMIT 1];
        
        List<LocationOccupant__c> objMoveOutLocationOccupant = [SELECT Id,
                                                                StartDate__c,
                                                                EndDate__c,
                                                                OccupancyType__c
                                                                FROM LocationOccupant__c LIMIT 1];
        
        List<AvailableService__c> objAvailableService = [SELECT Id,
                                                         ServiceType__c,
                                                         SupplyPoint__c
                                                         FROM AvailableService__c LIMIT 1];
        
        List<AvailableBundle__c> objAvailableBundle = [SELECT Id,
                                                       AvailableService__c
                                                       FROM AvailableBundle__c LIMIT 1];
        
        List<AvailableServiceItem__c> objAvailableServiceItem = [SELECT Id,
                                                                 AvailableBundle__c,
                                                                 ServiceItemType__c 
                                                                 FROM AvailableServiceItem__c LIMIT 2];
        
        List<ServiceItemType__c> objServiceItemType = [SELECT Id FROM ServiceItemType__c LIMIT 2];
        
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        
        //Added reading record in the moveInReading list to be created
        List<Reading__c> objMoveInReading = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading.ReadingDate__c = System.today();
        objReading.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading.ReadingSource__c = CUSTOMER_READING;
        objReading.ReadingType__c = MOVE_IN;
        objMoveInReading.add(objReading);
        
        // Added Location Occupant Record to locationOccupantToMoveIn
        LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objLocationOccupant.StartDate__c = System.today() + 1;
        objLocationOccupant.EndDate__c = System.today() + 5;
        objLocationOccupant.OccupancyType__c = occType;
        objLocationOccupant.Primary__c = true;
        objLocationOccupant.ShowOnBill__c = true;
        
        // Added Addition Location Occupant Record in the list to be created
        List<LocationOccupant__c> lstAddLocationOccupant = new List<LocationOccupant__c>();
        LocationOccupant__c  objAddLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objAddLocationOccupant.StartDate__c = System.today() + 1;
        objAddLocationOccupant.EndDate__c = null;
        objAddLocationOccupant.OccupancyType__c = occType;
        objAddLocationOccupant.Primary__c = true;
        objAddLocationOccupant.ShowOnBill__c = true;
        lstAddLocationOccupant.add(objAddLocationOccupant);
        
        CuAp_AUMoveInWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveInWizardCtrlr.WizardObject();
        objWizardObject.recordId					= objAccount.Id;
        objWizardObject.accountId 					= objAccount.Id;
        objWizardObject.location 					= objLocation;
        objWizardObject.locationId					= objLocation.Id;
        objWizardObject.moveInDate 					= System.today();
        objWizardObject.moveOutDate 				= System.today() + 1;
        objWizardObject.locationOccupantToMoveIn 	= objLocationOccupant;
        objWizardObject.locationOccupantsToMoveOut 	= objMoveOutLocationOccupant;
        objWizardObject.additionalLocationOccupants = lstAddLocationOccupant;
        objWizardObject.selectedServices 			= objAvailableService;
        objWizardObject.availableBundles 			= objAvailableBundle;
        objWizardObject.selectedServiceItems		= objAvailableServiceItem;
        objWizardObject.selectedSundryItems 		= objServiceItemType;
        objWizardObject.moveInReadings 				= objMoveInReading;
        objWizardObject.emailSend					= true;    
        objWizardObject.selectedOccType				= occType;
        /*Id contractId;
        @TestVisible private Boolean emailSend;
        @TestVisible private String selectedOccType;
        @TestVisible private Decimal creditAmountToTransfer;
        @TestVisible private Decimal creditAmountOnContract;
        @TestVisible private Decimal debtOnLocation;      
        @TestVisible private Id wizBillCalculationId;*/
        
        return objWizardObject;
    }

}