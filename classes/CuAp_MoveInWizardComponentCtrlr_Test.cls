/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        16 Feb 2018
@description: Test Class for CuAp_MoveInWizardComponentCtrlr

*******************************************************************************/
@isTest
public class CuAp_MoveInWizardComponentCtrlr_Test {
    
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
    private static final String ACTUAL_DEVICE_READING	= '120';  
    private static final String DEVICE_SIZE 			= 'TestDeviceSize';
    private static final String MANUFACTURER 			= 'Siemens';
    private static final String MANUFACTURER1 			= 'Kent';
    private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';
    private static final String UNIT_OF_MEASURE 		= 'Metric';
    private static final String NONHOUNSEHOLDACCOUNT 	= 'Non-Household Account';
    private static final String SENDER_EMAIL			= 'neharajput@echo-ms.com';
    
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
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.City__c = CITY;
        objLocation.State__c = STATE;
        objLocation.Street__c = STREET;
        objLocation.Country__c = COUNTRY;
        Database.insert(objLocation);
        
        // Create Location Occupant Record 
        LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount1, objLocation);
        objLocationOccupant.EndDate__c = System.today() - 1;
        Database.insert(objLocationOccupant);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point Record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        List<DeviceSize__c> lstDeviceSize = new List<DeviceSize__c>();
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        lstDeviceSize.add(objDeviceSize);

        // Create Device Size Record - 
        DeviceSize__c objDeviceSize1 = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        lstDeviceSize.add(objDeviceSize1);
        Database.insert(lstDeviceSize);
        
        List<DeviceType__c> lstDeviceType = new List<DeviceType__c>();
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(lstDeviceSize[0],MANUFACTURER,UNIT_OF_MEASURE);
        lstDeviceType.add(objDeviceType);
        
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
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
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
        Database.insert(objReading);
        
        //Create Service Record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        //Create First Service Item Type Record
        List<ServiceItemType__c> lstServiceItemType = new List<ServiceItemType__c>();
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        lstServiceItemType.add(objServiceItemType);
        
        // Create Second Service Item Type Record 
        ServiceItemType__c  objServiceItemType1 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE+'-1',objServiceItemFamily,objDivision,objDeviceType1,objWholesaler);
        lstServiceItemType.add(objServiceItemType1);
        Database.insert(lstServiceItemType);
        
        // Create First Bundle Record
        List<Bundle__c> lstBundle = new List<Bundle__c>();
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        lstBundle.add(objBundle);
        
        // Create Second Bundle Record
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME +'-1',objServiceType);
        lstBundle.add(objBundle1);
        Database.insert(lstBundle);
        
        // Create Available Bundle Record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create First Bundle Item Record
        List<BundleItem__c> lstBundleItem = new List<BundleItem__c>();
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,lstBundle[0],lstServiceItemType[0],objServiceItemFamily);
        lstBundleItem.add(objBundleItem);
        
        //Create Second Bundle Item Record
        BundleItem__c  objBundleItem0 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,lstServiceItemType[1],objServiceItemFamily);
        lstBundleItem.add(objBundleItem0);
        
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
        Database.insert(objContact);
       
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        16 Feb 2018
    @description: Test Method to check Move In Wizard Details in Positive scenario
    *******************************************************************************/
    static testmethod void moveInWizard_Positive(){
        
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
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
                                                                EndDate__c
                                                                FROM LocationOccupant__c LIMIT 1];
        
        List<AvailableService__c> objAvailableService = [SELECT Id,
                                                         ServiceType__c,
                                                         SupplyPoint__c
                                                         FROM AvailableService__c];
        
        List<AvailableBundle__c> objAvailableBundle = [SELECT Id,
                                                       AvailableService__c
                                                       FROM AvailableBundle__c];
        
        List<AvailableServiceItem__c> objAvailableServiceItem = [SELECT Id,
                                                                 AvailableBundle__c,
                                                                 ServiceItemType__c 
                                                                 FROM AvailableServiceItem__c];
        
        List<ServiceItemType__c> objServiceItemType = [SELECT Id FROM ServiceItemType__c];
        
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
        objLocationOccupant.OccupancyType__c = OWNER;
        objLocationOccupant.Primary__c = true;
        objLocationOccupant.ShowOnBill__c = true;
        
        // Added Addition Location Occupant Record in the list to be created
        List<LocationOccupant__c> lstAddLocationOccupant = new List<LocationOccupant__c>();
        LocationOccupant__c  objAddLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objAddLocationOccupant.StartDate__c = System.today() + 1;
        objAddLocationOccupant.EndDate__c = null;
        objAddLocationOccupant.OccupancyType__c = OWNER;
        objAddLocationOccupant.Primary__c = true;
        objAddLocationOccupant.ShowOnBill__c = true;
        lstAddLocationOccupant.add(objAddLocationOccupant);
        
        CuAp_MoveInWizardComponentCtrlr.WizardObject objWizardObject = new CuAp_MoveInWizardComponentCtrlr.WizardObject();
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
        objWizardObject.emailSend					= true;    // AT-3157
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        List<Id> contractId;
        Map<String,Boolean> status = new Map<String,Boolean>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_MoveInWizardComponentCtrlr.wizardStatus(jsonSerializeWizard);
            contractId = CuAp_MoveInWizardComponentCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            System.assert(contractId != null);
            System.assert(status.size() > 0);            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        16 Feb 2018
    @description: Test Method to check Move In Wizard Details in Negative scenario
    *******************************************************************************/
    static testmethod void moveInWizard_Negative(){
        
        User objUser = [Select Id, 
                        Name
                        FROM User
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        
        Location__c objLocation = [SELECT Id,
                                   Street__c,
                                   City__c,
                                   State__c,
                                   PostalCode__c,
                                   Country__c,
                                   NumberofOccupiers__c 
                                   FROM Location__c LIMIT 1];
        
        CuAp_MoveInWizardComponentCtrlr.WizardObject objWizardObject = new CuAp_MoveInWizardComponentCtrlr.WizardObject();
        objWizardObject.accountId 	= objAccount.Id;
        objWizardObject.location 	= objLocation;        
        
        Map<String,Boolean> status = new Map<String,Boolean>();
        Boolean isException;
        List<Id> contractId;
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        System.runAs(objUser){
            try{
                Test.startTest();
                status = CuAp_MoveInWizardComponentCtrlr.wizardStatus(jsonSerializeWizard);
                contractId = CuAp_MoveInWizardComponentCtrlr.moveIn(jsonSerializeWizard);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assertEquals(isException, true);
            System.assertEquals(contractId, null);
        }        
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        16 Feb 2018
    @description: Test Method to check Move In Wizard Details in Negative_Null scenario
    *******************************************************************************/
    static testmethod void moveInWizard_Negative_Null(){
        
        User objUser = [Select Id,
                        Name
                        FROM User
                        WHERE isActive = true AND
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Map<String,Boolean> status = new Map<String,Boolean>();
        Boolean isException;
        List<Id> contractId;
        
        System.runAs(objUser){
            try{
                Test.startTest();
                status = CuAp_MoveInWizardComponentCtrlr.wizardStatus(Null);
                contractId = CuAp_MoveInWizardComponentCtrlr.moveIn(Null);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assertEquals(status.size(), 0);
            System.assertEquals(isException, true);
            System.assertEquals(contractId, null);
        }        
    }
}