/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        14 Nov 2018
@description: Test Class for CuAp_AUCustMoveAmendWizardCtrlr
*******************************************************************************/
@isTest
public class CuAp_AUCustMoveAmendWizardCtrlr_Test {
    
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
    private static final String MOVE_OUT			 	= 'Move Out';
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
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi
	@date:        14 Nov 2018
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    @TestSetup
    Static void createTestData(){
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create First Account Record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Second Account Record
        Account objAccount1 = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME_2);         
        Database.insert(objAccount1);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c = STREET;
        objContract.BillingCity__c = CITY;
        objContract.BillingState__c = STATE;
        objContract.BillingPostalCode__c = POSTAL_CODE;
        objContract.BillingCountry__c = COUNTRY;
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
        objLocationOccupant.StartDate__c = System.today() - 10;
        objLocationOccupant.OccupancyType__c = TENANT;
        Database.insert(objLocationOccupant);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point Record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Size Record - 
        DeviceSize__c objDeviceSize1 = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize1);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType1 = GlUt_FactoryData_Test.createDeviceType(objDeviceSize1,MANUFACTURER1,UNIT_OF_MEASURE);
        Database.insert(objDeviceType1);
        
        //Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
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
        objReading.ReadingDate__c = system.today() - 10;
        Database.insert(objReading);
        
        //Create Service Record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        objService.OccupancyType__c = TENANT;
        Database.insert(objService);
        
        //Create First Service Item Type Record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        //objServiceItemType.DeviceType__c =objDeviceType.id; --AT-3174
        Database.insert(objServiceItemType);
        
        // Create Second Service Item Type Record 
        ServiceItemType__c  objServiceItemType1 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE+'-1',objServiceItemFamily,objDivision,objDeviceType1,objWholesaler);
        //objServiceItemType1.DeviceType__c =objDeviceType.id; --AT-3174
        Database.insert(objServiceItemType1);
        
        // Create First Bundle Record
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
        
        // Create Second Bundle Record
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME +'-1',objServiceType);
        Database.insert(objBundle1);
        
        // Create Available Bundle Record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create First Bundle Item Record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create Second Bundle Item Record
        BundleItem__c  objBundleItem0 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType1,objServiceItemFamily);
        Database.insert(objBundleItem0);
        
        // Create Third Bundle Item Record
        BundleItem__c  objBundleItem1 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM+'-1',objBundle1,objServiceItemType1,objServiceItemFamily);
        Database.insert(objBundleItem1);
        
        // Create First Available Service Item Record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        Database.insert(objAvailableServiceItem); 
        
        //Create Second Available Service Item Record
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM+'-1',objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem1.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem1.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem1.EndDate__c =Date.newInstance(2019, 12, 9);
        Database.insert(objAvailableServiceItem1); 
        
        //Create First Service Item Record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c =  system.today(); //Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = null;  //Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem);
        
        //Create Second Service Item Record
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType1,objService);
        objServiceItem1.StartDate__c = system.today() - 5;   // Date.newInstance(2016, 12, 9);
        objServiceItem1.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem1);
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        14 Nov 2018
    @description: Test Method to check Move In Wizard Details in Positive scenario
    *******************************************************************************/
    static testmethod void AUmoveInWizard_Positive(){
        
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
        
        List<ServiceItemType__c> objServiceItemType = [SELECT Id 
                                                       FROM ServiceItemType__c];
        
        Device__c objDevice = [SELECT Id 
                               FROM Device__c LIMIT 1];
        
        //Added reading record in the moveInReading list to be created
        List<Reading__c> objMoveInReading = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading.ReadingDate__c = System.today();
        objReading.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading.ReadingSource__c = CUSTOMER_READING;
        objReading.ReadingType__c = MOVE_IN;
        objReading.BillableType__c = 'Billable';
        objMoveInReading.add(objReading);
        
        //Added reading record in the currentReading list to be created
        List<Reading__c> objCurrentReading = new List<Reading__c>();
        Reading__c  objReading1 = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading1.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading1.ReadingDate__c = System.today() + 1;
        objReading1.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading1.ReadingSource__c = CUSTOMER_READING;
        objReading1.ReadingType__c = REGULAR;
        objCurrentReading.add(objReading1);        
        
        // Added Location Occupant Record to locationOccupantToMoveIn
        LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objLocationOccupant.StartDate__c = System.today();
        objLocationOccupant.EndDate__c = System.today() + 5;
        objLocationOccupant.OccupancyType__c = TENANT;
        objLocationOccupant.Primary__c = true;
        objLocationOccupant.ShowOnBill__c = true;
        database.insert(objLocationOccupant);
        
        // Added Addition Location Occupant Record in the list to be created
        List<LocationOccupant__c> lstAddLocationOccupant = new List<LocationOccupant__c>();
        LocationOccupant__c  objAddLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objAddLocationOccupant.StartDate__c = System.today() + 1;
        objAddLocationOccupant.EndDate__c = null;
        objAddLocationOccupant.OccupancyType__c = TENANT;
        objAddLocationOccupant.Primary__c = true;
        objAddLocationOccupant.ShowOnBill__c = true;
        lstAddLocationOccupant.add(objAddLocationOccupant);
        
        CuAp_AUCustMoveAmendWizardCtrlr.WizardObject objWizardObject = new CuAp_AUCustMoveAmendWizardCtrlr.WizardObject();
        objWizardObject.recordId					= objAccount.Id;
        objWizardObject.accountId 					= objAccount.Id;
        objWizardObject.selectedLocOcc 			    = objLocationOccupant;
        objWizardObject.selectedLocOcc.Id 		    = objLocationOccupant.Id;
        objWizardObject.locationId					= objLocation.Id;
        objWizardObject.newReadingsLists 			= objMoveInReading;   //  objCurrentReading;
        objWizardObject.deleteRecord 		     	= 'false';
        objWizardObject.moveInDate 					= System.today();
        objWizardObject.moveOutDate 				= System.today() + 1;
        objWizardObject.prevOcc 				    = true;
        objWizardObject.subsequentOcc 				= true;
      
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        List<Id> contractId = new List<Id>();
        Map<String,Boolean> status = new Map<String,Boolean>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUCustMoveAmendWizardCtrlr.wizardStatus(jsonSerializeWizard);
            contractId = CuAp_AUCustMoveAmendWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            System.assert(contractId != null);                
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        15 Nov 2018
    @description: Test Method to check Move In Wizard Details 
    *******************************************************************************/
    static testmethod void AUmoveInWizard_Positive2(){
        
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
        
        List<ServiceItemType__c> objServiceItemType = [SELECT Id 
                                                       FROM ServiceItemType__c];
        
        Device__c objDevice = [SELECT Id 
                               FROM Device__c LIMIT 1];
        
        //Added reading record in the moveInReading list to be created
        List<Reading__c> objMoveInReading = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading.ReadingDate__c = System.today();
        objReading.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading.ReadingSource__c = CUSTOMER_READING;
        objReading.ReadingType__c = MOVE_IN;
        objReading.BillableType__c = 'Billable';
        objMoveInReading.add(objReading);
        
        //Added reading record in the currentReading list to be created
        List<Reading__c> objCurrentReading = new List<Reading__c>();
        Reading__c  objReading1 = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading1.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading1.ReadingDate__c = System.today() + 1;
        objReading1.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading1.ReadingSource__c = CUSTOMER_READING;
        objReading1.ReadingType__c = REGULAR;
        objCurrentReading.add(objReading1);        
        
        // Added Location Occupant Record to locationOccupantToMoveIn
        LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objLocationOccupant.StartDate__c = System.today() + 1;
        objLocationOccupant.EndDate__c = System.today() + 5;
        objLocationOccupant.OccupancyType__c = TENANT;
        objLocationOccupant.Primary__c = true;
        objLocationOccupant.ShowOnBill__c = true;
        database.insert(objLocationOccupant);
        
        // Added Addition Location Occupant Record in the list to be created
        List<LocationOccupant__c> lstAddLocationOccupant = new List<LocationOccupant__c>();
        LocationOccupant__c  objAddLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objAddLocationOccupant.StartDate__c = System.today() + 1;
        objAddLocationOccupant.EndDate__c = null;
        objAddLocationOccupant.OccupancyType__c = TENANT;
        objAddLocationOccupant.Primary__c = true;
        objAddLocationOccupant.ShowOnBill__c = true;
        lstAddLocationOccupant.add(objAddLocationOccupant);
        
        CuAp_AUCustMoveAmendWizardCtrlr.WizardObject objWizardObject = new CuAp_AUCustMoveAmendWizardCtrlr.WizardObject();
        objWizardObject.recordId					= objAccount.Id;
        objWizardObject.accountId 					= objAccount.Id;
        objWizardObject.selectedLocOcc 			    = objLocationOccupant;
        objWizardObject.selectedLocOcc.Id 		    = objLocationOccupant.Id;
        objWizardObject.locationId					= objLocation.Id;
        objWizardObject.newReadingsLists 			= objMoveInReading;   //  objCurrentReading;
        objWizardObject.deleteRecord 		     	= 'true';
        objWizardObject.moveInDate 					= System.today();
        objWizardObject.moveOutDate 				= System.today() + 1;
        objWizardObject.prevOcc 				    = true;
        objWizardObject.subsequentOcc 				= true;

        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        List<Id> contractId = new List<Id>();
        Map<String,Boolean> status = new Map<String,Boolean>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUCustMoveAmendWizardCtrlr.wizardStatus(jsonSerializeWizard);
            contractId = CuAp_AUCustMoveAmendWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            System.assert(contractId != null);                
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        14 Nov 2018
    @description: Test Method to check Move In Wizard Details in Positive scenario
    *******************************************************************************/
    static testmethod void AUmoveInWizard_Positive3(){
        
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
        
        List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();
        for(ServiceItemType__c objSIT:[SELECT Id,Owner__c,Tenant__c 
                                       FROM ServiceItemType__c]){
        	objSIT.Owner__c = true;
            objSIT.Tenant__c = true;
            serviceItemTypeList.add(objSIT);                   
        }
        database.update(serviceItemTypeList); 
        
        List<Service__c> serviceList = new List<Service__c>();
        for(Service__c objService: [SELECT OccupancyType__c FROM Service__c]){
            objService.OccupancyType__c = Label.CuAp_AUMoveInOccTypeOwner;
            serviceList.add(objService);
        }
        database.update(serviceList);
        
        Device__c objDevice = [SELECT Id 
                               FROM Device__c LIMIT 1];
        
        //Added reading record in the moveInReading list to be created
        List<Reading__c> objMoveInReading = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading.ReadingDate__c = System.today();
        objReading.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading.ReadingSource__c = CUSTOMER_READING;
        objReading.ReadingType__c = MOVE_IN;
        objReading.BillableType__c = 'Billable';
        objMoveInReading.add(objReading);
        
        //Added reading record in the currentReading list to be created
        List<Reading__c> objCurrentReading = new List<Reading__c>();
        Reading__c  objReading1 = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading1.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading1.ReadingDate__c = System.today() + 1;
        objReading1.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading1.ReadingSource__c = CUSTOMER_READING;
        objReading1.ReadingType__c = REGULAR;
        objCurrentReading.add(objReading1);        
        
        // Added Location Occupant Record to locationOccupantToMoveIn
        LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objLocationOccupant.StartDate__c = System.today();
        objLocationOccupant.EndDate__c = System.today() + 5;
        objLocationOccupant.OccupancyType__c = TENANT;
        objLocationOccupant.Primary__c = true;
        objLocationOccupant.ShowOnBill__c = true;
        database.insert(objLocationOccupant);
        
        // Added Addition Location Occupant Record in the list to be created
        List<LocationOccupant__c> lstAddLocationOccupant = new List<LocationOccupant__c>();
        LocationOccupant__c  objAddLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objAddLocationOccupant.StartDate__c = System.today() + 1;
        objAddLocationOccupant.EndDate__c = null;
        objAddLocationOccupant.OccupancyType__c = TENANT;
        objAddLocationOccupant.Primary__c = true;
        objAddLocationOccupant.ShowOnBill__c = true;
        lstAddLocationOccupant.add(objAddLocationOccupant);
        
        CuAp_AUCustMoveAmendWizardCtrlr.WizardObject objWizardObject = new CuAp_AUCustMoveAmendWizardCtrlr.WizardObject();
        objWizardObject.recordId					= objAccount.Id;
        objWizardObject.accountId 					= objAccount.Id;
        objWizardObject.selectedLocOcc 			    = objLocationOccupant;
        objWizardObject.selectedLocOcc.Id 		    = objLocationOccupant.Id;
        objWizardObject.locationId					= objLocation.Id;
        objWizardObject.newReadingsLists 			= objMoveInReading;   //  objCurrentReading;
        objWizardObject.deleteRecord 		     	= 'false';
        objWizardObject.moveInDate 					= System.today();
        objWizardObject.moveOutDate 				= System.today() + 1;
        objWizardObject.prevOcc 				    = false;
        objWizardObject.subsequentOcc 				= true;
      
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        List<Id> contractId = new List<Id>();
        Map<String,Boolean> status = new Map<String,Boolean>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUCustMoveAmendWizardCtrlr.wizardStatus(jsonSerializeWizard);
            contractId = CuAp_AUCustMoveAmendWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            System.assert(contractId != null);                
        }
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        14 Nov 2018
    @description: Test Method to check Move In Wizard Details in Positive scenario
    *******************************************************************************/
    static testmethod void AUmoveInWizard_Positive4(){
        
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
        
        List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();
        for(ServiceItemType__c objSIT:[SELECT Id,Owner__c,Tenant__c 
                                       FROM ServiceItemType__c]){
        	objSIT.Owner__c = true;
            objSIT.Tenant__c = true;
            serviceItemTypeList.add(objSIT);                   
        }
        database.update(serviceItemTypeList); 
        
        List<Service__c> serviceList = new List<Service__c>();
        for(Service__c objService: [SELECT OccupancyType__c FROM Service__c]){
            objService.OccupancyType__c = Label.CuAp_AUMoveInOccTypeOwner;
            serviceList.add(objService);
        }
        database.update(serviceList);
        
        Device__c objDevice = [SELECT Id 
                               FROM Device__c LIMIT 1];
        
        //Added reading record in the moveInReading list to be created
        List<Reading__c> objMoveInReading = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading.ReadingDate__c = System.today();
        objReading.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading.ReadingSource__c = CUSTOMER_READING;
        objReading.ReadingType__c = MOVE_OUT;
        objReading.BillableType__c = 'Billable';
        objMoveInReading.add(objReading);
        
        //Added reading record in the currentReading list to be created
        List<Reading__c> objCurrentReading = new List<Reading__c>();
        Reading__c  objReading1 = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading1.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading1.ReadingDate__c = System.today() + 1;
        objReading1.ReadingMethod__c = MANUAL_ESTIMATED;
        objReading1.ReadingSource__c = CUSTOMER_READING;
        objReading1.ReadingType__c = REGULAR;
        objCurrentReading.add(objReading1);        
        
        // Added Location Occupant Record to locationOccupantToMoveIn
        LocationOccupant__c  objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objLocationOccupant.StartDate__c = System.today();
        objLocationOccupant.EndDate__c = System.today() + 5;
        objLocationOccupant.OccupancyType__c = TENANT;
        objLocationOccupant.Primary__c = true;
        objLocationOccupant.ShowOnBill__c = true;
        database.insert(objLocationOccupant);
        
        // Added Addition Location Occupant Record in the list to be created
        List<LocationOccupant__c> lstAddLocationOccupant = new List<LocationOccupant__c>();
        LocationOccupant__c  objAddLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);
        objAddLocationOccupant.StartDate__c = System.today() + 1;
        objAddLocationOccupant.EndDate__c = null;
        objAddLocationOccupant.OccupancyType__c = TENANT;
        objAddLocationOccupant.Primary__c = true;
        objAddLocationOccupant.ShowOnBill__c = true;
        lstAddLocationOccupant.add(objAddLocationOccupant);
        
        CuAp_AUCustMoveAmendWizardCtrlr.WizardObject objWizardObject = new CuAp_AUCustMoveAmendWizardCtrlr.WizardObject();
        objWizardObject.recordId					= objAccount.Id;
        objWizardObject.accountId 					= objAccount.Id;
        objWizardObject.selectedLocOcc 			    = objLocationOccupant;
        objWizardObject.selectedLocOcc.Id 		    = objLocationOccupant.Id;
        objWizardObject.locationId					= objLocation.Id;
        objWizardObject.newReadingsLists 			= objMoveInReading;   //  objCurrentReading;
        objWizardObject.deleteRecord 		     	= 'false';
        objWizardObject.moveInDate 					= null;
        objWizardObject.moveOutDate 				= System.today();
        objWizardObject.prevOcc 				    = false;
        objWizardObject.subsequentOcc 				= false;
      
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        List<Id> contractId = new List<Id>();
        Map<String,Boolean> status = new Map<String,Boolean>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUCustMoveAmendWizardCtrlr.wizardStatus(jsonSerializeWizard);
            contractId = CuAp_AUCustMoveAmendWizardCtrlr.moveIn(jsonSerializeWizard);
            Test.stopTest();            
            System.assert(contractId != null);                
        }
    }
    
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        14 Nov 2018
    @description: Test Method to check Move In Wizard Details in Negative scenario
    *******************************************************************************/
    static testmethod void AUmoveInWizard_Negative(){
        
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
        
        CuAp_AUCustMoveAmendWizardCtrlr.WizardObject objWizardObject = new CuAp_AUCustMoveAmendWizardCtrlr.WizardObject();
        objWizardObject.accountId 	= objAccount.Id;
        objWizardObject.location 	= objLocation;        
        
        Map<String,Boolean> status = new Map<String,Boolean>();
        Boolean isException;
        List<Id> contractId = new List<Id>();
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        System.runAs(objUser){
            try{
                Test.startTest();
                status = CuAp_AUCustMoveAmendWizardCtrlr.wizardStatus(jsonSerializeWizard);
                contractId = CuAp_AUCustMoveAmendWizardCtrlr.moveIn(jsonSerializeWizard);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assertEquals(isException, true);
            System.assertEquals(contractId.isEmpty(), true);
        }        
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        14 Nov 2018
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
        List<Id> contractId = new List<Id>();
        
        System.runAs(objUser){
            try{
                Test.startTest();
                status = CuAp_AUCustMoveAmendWizardCtrlr.wizardStatus(Null);
                contractId = CuAp_AUCustMoveAmendWizardCtrlr.moveIn(Null);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assertEquals(status.size(), 0);
            System.assertEquals(isException, true);
            System.assertEquals(contractId.isEmpty(), true);
        }        
    }
}