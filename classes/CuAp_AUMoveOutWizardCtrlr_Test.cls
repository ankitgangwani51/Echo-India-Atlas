/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        14 Nov 2018
@description: Test Class for CuAp_AUMoveOutWizardCtrlr
*******************************************************************************/
@isTest
public class CuAp_AUMoveOutWizardCtrlr_Test { 
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String ACCOUNT_NAME_HH			= 'HH Account';
    private static final String ACCOUNT_NAME_NHH		= 'NHH Account';
    private static final String STREET		 			= 'Test Street';
    private static final String CITY 					= 'Test City';
    private static final String STATE				 	= 'Test State';
    private static final String POSTAL_CODE 			= '0000000';
    private static final String COUNTRY 				= 'Test Country';
    private static final String LOCATION_NAME 			= 'A99 9AA';
    private static final String LOCATION_SUB_TYPE 		= 'Detached';
    private static final String LOCATION_STREET 		= 'Test Street';
    private static final String DEVICENAME 				= 'TestDevice';
    private static final String SYSTEM_ESTIMATED 		= 'System Estimated';
    private static final String CUSTOMER_READING 		= 'Customer Reading';
    private static final String MOVE_OUT			 	= 'Move Out';
    private static final String REGULAR 				= 'Regular';
    private static final String OWNER    				= 'Owner';  
    private static final String ACTUAL_DEVICE_READING	= '120';  
    private static final String DEVICE_SIZE 			= 'TestDeviceSize';
    private static final String MANUFACTURER 			= 'Siemens';
    private static final String UNIT_OF_MEASURE 		= 'Metric';
    private static final String NONHOUNSEHOLDACCOUNT 	= 'Non-Household Account';
    private static final String HOUNSEHOLDACCOUNT 		= 'Household Account';
    private static final Integer NO_OF_OCCUPIERS		=  1;
    private static final String SP_USAGE_TYPE			= 'SupplyPointUsageType';
    private static final String MEASURED 				='Yes';
    private static final String READFREQUENCY_M 		= 'Monthly'; 
    private static final String SENDER_EMAIL			= 'neharajput@echo-ms.com';
    private static final String TEST_SERVICE_TYPE 		= 'TestServiceType';
    private static final String SERVICEITEMFAMILY 		= 'TestServiceItemFamily';
    private static final String WHOLESALER 				= 'TestWholesaler';
    private static final String AVAILABLESERVICES 		= 'TestAvailableService';
    private static final String BUNDLENAME  			= 'TestBundle';
    private static final String BUNDLEITEM 				= 'TestBundleItem';
    private static final String AVAILABLESERVIEITEM		= 'TestAvailableServiceItem';
    private static final String DEVICETYPE 				= 'TestDeviceType';
    private static final String SERVICEITEMTYPE 		= 'TestSrvItemType';  

    /******************************************************************************
    @author        Ankit Gangwani 
    @date          14 Nov 2018
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
        
        // Get the Record Type Id for House Hold & Non-House Hold Accounts
        Id recordTypeIdHH = CuAp_HHAccountOverrideComponentCtrlr.getRecTypeId(HOUNSEHOLDACCOUNT);
        Id recordTypeIdNHH = CuAp_HHAccountOverrideComponentCtrlr.getRecTypeId(NONHOUNSEHOLDACCOUNT);
        
        List<Account> lstAccount = new List<Account>();
        //Create House Hold Account Record
        Account objAccountHH = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME_HH);
        objAccountHH.RecordTypeId = recordTypeIdHH;
        lstAccount.add(objAccountHH);  
        
        //Create Non House Hold Account Record
        Account objAccountNHH = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME_NHH);
        objAccountNHH.RecordTypeId = recordTypeIdNHH;
        lstAccount.add(objAccountNHH);
        Database.insert(lstAccount);
        
        List<BillingContract__c> lstBillingContract = new List<BillingContract__c>();
        //Create Contract Record - NHH
        BillingContract__c objContractNHH = GlUt_FactoryData_Test.CreateContract(' ',lstAccount[1]);
        objContractNHH.BillingStreet__c = STREET;
        objContractNHH.BillingCity__c = CITY;
        objContractNHH.BillingState__c = STATE;
        objContractNHH.BillingPostalCode__c = POSTAL_CODE;
        objContractNHH.BillingCountry__c = COUNTRY;
        lstBillingContract.add(objContractNHH);
        
        //Create Contract Record - HH
        BillingContract__c objContractHH = GlUt_FactoryData_Test.CreateContract(' ',lstAccount[0]);
        objContractHH.BillingStreet__c = STREET;
        objContractHH.BillingCity__c = CITY;
        objContractHH.BillingState__c = STATE;
        objContractHH.BillingPostalCode__c = POSTAL_CODE;
        objContractHH.BillingCountry__c = COUNTRY;
        lstBillingContract.add(objContractHH);
        Database.insert(lstBillingContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.City__c = CITY;
        objLocation.State__c = STATE;
        objLocation.Street__c = STREET;
        objLocation.Country__c = COUNTRY;
        Database.insert(objLocation);
        
        List<LocationOccupant__c> lstLocationOccupant = new List<LocationOccupant__c>();
        // Create Location Occupant Record - HH
        LocationOccupant__c  objLocationOccupantHH = GlUt_FactoryData_Test.createLocationOccupant(lstAccount[1], objLocation);
        objLocationOccupantHH.EndDate__c = System.today() - 1;
        lstLocationOccupant.add(objLocationOccupantHH);
        
        // Create Location Occupant Record - NHH
        LocationOccupant__c  objLocationOccupantNHH = GlUt_FactoryData_Test.createLocationOccupant(lstAccount[0], objLocation);
        objLocationOccupantNHH.EndDate__c = System.today() - 1;
        lstLocationOccupant.add(objLocationOccupantNHH);
        Database.insert(lstLocationOccupant);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        objDevice.Digit__c = 3;
        Database.insert(objDevice);
        
        //Create Supply Point Usage Type Record At-3158
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record       AT-3158 
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        //Custom Setting  AT-3158
        ConfigureTemplate__c  objConfigureTemplate = GlUt_FactoryData_Test.createConfigureTemplate(SENDER_EMAIL);       
        Database.insert(objConfigureTemplate);
       
        // Contact Record AT-3158
        Contact  objContact = GlUt_FactoryData_Test.createContact(USER_FNAME,USER_LNAME);
        objContact.Email = SENDER_EMAIL;
        Database.insert(objContact);
       //------------------- 
        
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
        Service__c  objService = GlUt_FactoryData_Test.createService(lstBillingContract[1],objReading,objServiceType,objSupplyPoint,objAvailableService);        
        Database.insert(objService);
        
        List<ServiceItemType__c> lstServiceItemType = new List<ServiceItemType__c>();
        //Create First Service Item Type Record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        objServiceItemType.StartDate__c = system.today() - 5;
        objServiceItemType.EndDate__c = null;  
        objServiceItemType.Owner__c = true;
        lstServiceItemType.add(objServiceItemType);
        
        // Create Second Service Item Type Record 
        ServiceItemType__c  objServiceItemType1 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE+'-1',objServiceItemFamily,objDivision,objDeviceType,objWholesaler);        
        objServiceItemType1.StartDate__c = system.today() - 5;
        objServiceItemType1.EndDate__c = null; 
        lstServiceItemType.add(objServiceItemType1);
        Database.insert(lstServiceItemType);
        
        List<Bundle__c> lstBundle = new List<Bundle__c>();
        // Create First Bundle Record
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        lstBundle.add(objBundle);
        
        // Create Second Bundle Record
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME +'-1',objServiceType);
        lstBundle.add(objBundle1);
        Database.insert(lstBundle);
        
        // Create Available Bundle Record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,lstBundle[0],objAvailableService);
        Database.insert(objAvailableBundle);
        
        List<BundleItem__c> lstBundleItem = new List<BundleItem__c>();
        //Create First Bundle Item Record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,lstBundle[0],lstServiceItemType[0],objServiceItemFamily);
        lstBundleItem.add(objBundleItem);
        
        //Create Second Bundle Item Record
        BundleItem__c  objBundleItem0 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,lstBundle[0],lstServiceItemType[1],objServiceItemFamily);
        lstBundleItem.add(objBundleItem0);
        
        // Create Third Bundle Item Record
        BundleItem__c  objBundleItem1 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM+'-1',lstBundle[1],lstServiceItemType[1],objServiceItemFamily);
        lstBundleItem.add(objBundleItem1);
        Database.insert(lstBundleItem);
        
        List<AvailableServiceItem__c> lstAvailableServiceItem = new List<AvailableServiceItem__c>();
        // Create First Available Service Item Record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,lstBundleItem[0],
                                                                                                            lstServiceItemType[0],objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = lstServiceItemType[0].id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        lstAvailableServiceItem.add(objAvailableServiceItem); 
        
        //Create Second Available Service Item Record
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM+'-1',
                                                                                                             lstBundleItem[0],lstServiceItemType[0],
                                                                                                             objAvailableBundle);
        objAvailableServiceItem1.ServiceItemType__c = lstServiceItemType[0].id;
        objAvailableServiceItem1.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem1.EndDate__c =Date.newInstance(2019, 12, 9);
        lstAvailableServiceItem.add(objAvailableServiceItem1); 
        Database.insert(lstAvailableServiceItem);
        
        List<ServiceItem__c> lstServiceItem = new List<ServiceItem__c>();
        //Create First Service Item Record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(lstAvailableServiceItem[0],lstServiceItemType[0],objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        lstServiceItem.add(objServiceItem);
        
        //Create Second Service Item Record
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.CreateServiceItem(lstAvailableServiceItem[1],lstServiceItemType[1],objService);
        objServiceItem1.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem1.EndDate__c = null; //Date.newInstance(2019, 12, 9);
        lstServiceItem.add(objServiceItem1);
        Database.insert(lstServiceItem);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        14 Nov 2018
    @description: Test Method to check Move Out for Non-House Hold Accounts in Positive scenario
	*******************************************************************************/
    static testmethod void moveOutWizard_NHH_Positive(){
        
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Account objAccount = [SELECT Id 
                              FROM Account
                              WHERE Name = 'NHH Account'
                              LIMIT 1];
        
        
        BillingContract__c objContract = [SELECT Id,
                                   BillingStreet__c,
                                   BillingCity__c,
                                   BillingState__c, 
                                   BillingPostalCode__c,
                                   BillingCountry__c
                                   FROM BillingContract__c LIMIT 1];
        
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
                                                                FROM LocationOccupant__c
                                                                WHERE Account__c = :objAccount.Id LIMIT 1];
        
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        
        //Added reading record in the moveInReading list to be created
        List<Reading__c> objMoveOutReading = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading.ReadingDate__c = System.today();
        objReading.ReadingMethod__c = SYSTEM_ESTIMATED;
        objReading.ReadingSource__c = CUSTOMER_READING;
        objReading.ReadingType__c = MOVE_OUT;
        objMoveOutReading.add(objReading);
        
        CuAp_AUMoveOutWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveOutWizardCtrlr.WizardObject();
        objWizardObject.accountId 					= objAccount.Id;
        objWizardObject.location 					= objLocation;
        objWizardObject.locationId					= objLocation.Id;        
        objWizardObject.moveOutDate 				= System.today();
        objWizardObject.locationOccupantsToMoveOut 	= objMoveOutLocationOccupant;
        objWizardObject.moveOutReadings 			= objMoveOutReading;
        objWizardObject.newBillingAddress           = objContract;
        objWizardObject.emailSend					= true;    // AT-3158
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        Id contractId;
        Map<String,Boolean> status = new Map<String,Boolean>();
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUMoveOutWizardCtrlr.wizardStatus(jsonSerializeWizard);
            contractId = CuAp_AUMoveOutWizardCtrlr.moveOut(jsonSerializeWizard);
            Test.stopTest();            
            System.assert(contractId != null);
            System.assert(status.size() > 0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        17 Feb 2018
    @description: Test Method to check Move Out for House Hold Accounts in Positive scenario
    *******************************************************************************/
    static testmethod void moveOutWizard_HH_Positive(){
        
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Account objAccount = [SELECT Id 
                              FROM Account
                              WHERE Name = 'HH Account'
                              LIMIT 1];
        
        
        BillingContract__c objContract = [SELECT Id,
                                   BillingStreet__c,
                                   BillingCity__c,
                                   BillingState__c, 
                                   BillingPostalCode__c,
                                   BillingCountry__c
                                   FROM BillingContract__c LIMIT 1];
        
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
                                                                FROM LocationOccupant__c
                                                                WHERE Account__c = :objAccount.Id LIMIT 1];
        
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        
        //Added reading record in the moveInReading list to be created
        List<Reading__c> objMoveOutReading = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_DEVICE_READING;
        objReading.ReadingDate__c = System.today();
        objReading.ReadingMethod__c = SYSTEM_ESTIMATED;
        objReading.ReadingSource__c = CUSTOMER_READING;
        objReading.ReadingType__c = MOVE_OUT;
        objMoveOutReading.add(objReading);
        
        CuAp_AUMoveOutWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveOutWizardCtrlr.WizardObject();
        objWizardObject.accountId 					= objAccount.Id;
        objWizardObject.location 					= objLocation;
        objWizardObject.locationId					= objLocation.Id;        
        objWizardObject.moveOutDate 				= System.today();
        objWizardObject.locationOccupantsToMoveOut 	= objMoveOutLocationOccupant;
        objWizardObject.moveOutReadings 			= objMoveOutReading;
        objWizardObject.newBillingAddress           = objContract;
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        Id contractId;
        Map<String,Boolean> status = new Map<String,Boolean>();
        System.debug('jsonSerializeWizard = '+jsonSerializeWizard);
        
        System.runAs(objUser){
            Test.startTest();            
            status = CuAp_AUMoveOutWizardCtrlr.wizardStatus(jsonSerializeWizard);
            System.debug('status = '+status);
            
            contractId = CuAp_AUMoveOutWizardCtrlr.moveOut(jsonSerializeWizard);
            System.debug('contractId = '+contractId);
            Test.stopTest();            
            //System.assert(contractId != null);
            //System.assert(status.size() > 0);            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        17 Feb 2018
    @description: Test Method to check Move Out Wizard in Negative scenario
    *******************************************************************************/
    static testmethod void moveOutWizard_Negative(){
        
        User objUser = [Select Id, 
                        Name 
                        FROM User 
                        WHERE isActive = true AND 
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        CuAp_AUMoveOutWizardCtrlr.WizardObject objWizardObject = new CuAp_AUMoveOutWizardCtrlr.WizardObject();
        objWizardObject.location = Null;
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        Map<String,Boolean> status = new Map<String,Boolean>();
        Boolean isException;
        Id contractId;
        
        System.runAs(objUser){            
            try{
                Test.startTest();
                status = CuAp_AUMoveOutWizardCtrlr.wizardStatus(jsonSerializeWizard);
                contractId = CuAp_AUMoveOutWizardCtrlr.moveOut(jsonSerializeWizard);
                Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
            System.assert(contractId == null);
            System.assert(status.size() > 0);            
        }        
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        17 Feb 2018
    @description: Test Method to check Move Out Wizard in Negative/Null scenario
    *******************************************************************************/
    static testmethod void moveInWizard_Negative_Null(){
        
        User objUser = [Select Id,
                        Name
                        FROM User
                        WHERE isActive = true AND
                        USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Map<String,Boolean> status = new Map<String,Boolean>();
        Boolean isException;
        Id contractId;
        
        System.runAs(objUser){
            try{
                Test.startTest();
                status = CuAp_AUMoveOutWizardCtrlr.wizardStatus(Null);
                contractId = CuAp_AUMoveOutWizardCtrlr.moveOut(Null);
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