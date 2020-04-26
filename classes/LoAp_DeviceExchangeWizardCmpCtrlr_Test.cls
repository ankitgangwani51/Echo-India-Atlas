/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        18-12-2017  
@description: Test Class for LoAp_DeviceExchangeWizardComponentCtrlr
@revision:    Echo: Gopal Gupta/Ankit Gangwani
*******************************************************************************/
@isTest
public class LoAp_DeviceExchangeWizardCmpCtrlr_Test {
    
    //Variable declaration start    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USERNAME 			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USERNAME+ '@unitest.com';
    private static final String ACCOUNT_NAME 		= 'TestDevice';
    private static final String TESTSERVICE_TYPE1 	= 'TestServiceType1'; 
    private static final String TESTSERVICE_TYPE2 	= 'TestServiceType2';
    private static final String TESTSERVICE_TYPE3 	= 'TestServiceType3';
    private static final String TESTSERVICE_TYPE4 	= 'TestServiceType4';
    private static final String LOCATION_NAME 		= 'A99 9AA';   
    private static final String LOCATION_SUB_TYPE 	= 'Detached';
    private static final String STREET 				= 'teststreet';
    private static final String LIBRARIES			= 'Libraries';    
    private static final String DEVICE_TYPE_NAME 	= 'Meter'; 
    private static final String OLDDEVICE_SERIALNO 	= '1234';
    private static final String NEWDEVICE_SERIALNO 	= '6789';
    private static final String YES 				= 'yes';    
    private static final String MEASURED 			= 'Monthly';
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    private static final String DEVICE_SIZE 		= 'TestDeviceSize';
    private static final String MANUFACTURER 		= 'Siemens';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String EXCHANGE_INITIAL 	= 'Initial';
    private static final String EXCHANGE_FINAL 		= 'Final';
    private static final String BUNDLE 				= 'TestBundle';
    private static final String AVAILABLEBUNDLE 	= 'TestAvailableBundle';
    private static final String BUNDLEITEM 			= 'TestBundleItem';
    private static final String WHOLESALER 			= 'TestWholesaler';
    private static final String AVAILABLESERVICES 	= 'TestAvailableService';
    
    @TestSetup
    Static void createTestData(){
        
        //Create User Record        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USERNAME,null);
        Database.insert(objUser);       
        
        //Create Account Record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(USERNAME,objAccount);
        Database.insert(objContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);       
        
        //Create Service Type Record - 1
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType1);
        
        //Create Service Type Record - 2
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE2);
        Database.insert(objServiceType2);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point Device - 1 Record
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c = True; // AT-3174 
        objSupplyPoint1.SpecialInstructions__c = LIBRARIES;
        Database.insert(objSupplyPoint1);
        
        //Create Supply Point Device - 2 Record
        SupplyPoint__c  objSupplyPoint2 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint2);
     
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record - 1
        Device__c  objOldDevice = GlUt_FactoryData_Test.CreateDevice(OLDDEVICE_SERIALNO , objDeviceType);        
        objOldDevice.SerialNo__c = OLDDEVICE_SERIALNO;
        Database.insert(objOldDevice);
        
        // Create Device Record - 2
        Device__c  objNewDevice = GlUt_FactoryData_Test.CreateDevice(NEWDEVICE_SERIALNO , objDeviceType);        
        objNewDevice.SerialNo__c = NEWDEVICE_SERIALNO;
        Database.insert(objNewDevice); 
        
        // Create Supply Point Device Record
        SupplyPointDevice__c  objOldSupplyPointDevice = GlUt_FactoryData_Test.CreateSupplyPointDevices(objOldDevice , objSupplyPoint1);        
        Database.insert(objOldSupplyPointDevice);
        
        // Create Supply Point Device Service Record - 1
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService1 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType1);        
        Database.insert(objOldSupplyPointDeviceService1);
        
        // Create Supply Point Device Service Record - 2
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService2 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType2);        
        Database.insert(objOldSupplyPointDeviceService2); 
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objOldDevice);
        Database.insert(objReading);
        
        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType1,objSupplyPoint1,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record - 1
        Service__c  objOldService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService1);
        
        // Create Service Record - 2
        Service__c  objOldService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService2);
        
        // Create Service Record - 3
        Service__c  objNewService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint2, objAvailableService);
        Database.insert(objNewService1);
        
        // Create Service Record - 4
        Service__c  objNewService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint2, objAvailableService);
        Database.insert(objNewService2);
        
        // Create Bundle Record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType1 );
        Database.insert(objBundle);
        
        // Create Available Bundle Record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);        
    }
    
    /******************************************************************************
    @author:    	Echo: Ankit Gangwani
    @date:      	19 Feb 2018
    @description: 	Test method for Device Wizard - New Device Positive scenario
    *******************************************************************************/  
    static testmethod void DeviceWizard_NewDevice_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name 
                        FROM User 
                        WHERE isActive=TRUE AND 
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        // locationId && recordId
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];  
        
        //newDeviceId
        Device__c objNewDevice = [SELECT Id 
                                  FROM Device__c 
                                  WHERE SerialNo__c =:NEWDEVICE_SERIALNO LIMIT 1];
        
        //newSPDServices
        SupplyPointDevice__c objOldSPD = [SELECT Id, 
                                          Device__c, 
                                          SupplyPoint__c 
                                          FROM SupplyPointDevice__c 
                                          WHERE Device__r.SerialNo__c =:OLDDEVICE_SERIALNO LIMIT 1];
        
        //newSPDServices
        List<ServiceType__c> listSType = [SELECT Id FROM ServiceType__c];
        
        //newSPDServices
        List<SupplyPointDeviceService__c> listSPDS = new List<SupplyPointDeviceService__c>();
        listSPDS.add(GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSPD , listSType[0]));
        listSPDS.add(GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSPD , listSType[1]));
        
        //availabeBundle
        List<AvailableBundle__c> listAvailableBundles = [SELECT Id FROM AvailableBundle__c];
        
        //initialReading
        Reading__c objInitialReading = GlUt_FactoryData_Test.CreateReading(objNewDevice);
        objInitialReading.ReadingDate__c = System.today();   
        objInitialReading.ReadingType__c = EXCHANGE_INITIAL;
        
        //selectedSupplyPointAdded
        List<SupplyPoint__c> listSupplyPoint1 = [SELECT Id 
                                                 FROM SupplyPoint__c 
                                                 WHERE SpecialInstructions__c = :LIBRARIES LIMIT 1];
        
        //spDeviceToBeAdded
        List<SupplyPoint__c> listSupplyPoint2 = [SELECT Id 
                                                 FROM SupplyPoint__c 
                                                 WHERE SpecialInstructions__c != :LIBRARIES LIMIT 1];
        
        //spDeviceToBeAdded
        SupplyPointDevice__c objNewSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objNewDevice, listSupplyPoint2[0]);
        objNewSupplyPointDevice.InstallationDate__c = Date.today();
 
        LoAp_DeviceExchangeWizardCmpCtrlr.WizardObject objWizardObject = new LoAp_DeviceExchangeWizardCmpCtrlr.WizardObject();
        objWizardObject.recordId 					= objLocation.Id;
        objWizardObject.locationId 					= objLocation.Id;
        objWizardObject.newDeviceId 				= objNewDevice.Id; 
        objWizardObject.newSPDServices 				= listSPDS;
        objWizardObject.initialReading				= objInitialReading;
        objWizardObject.availabeBundle 				= listAvailableBundles; 
        objWizardObject.spDeviceToBeAdded 			= objNewSupplyPointDevice;
        objWizardObject.wizardType 					= System.Label.LoAp_NewDevice;    
        objWizardObject.selectedSupplyPointAdded 	= listSupplyPoint1[0];
        
        String jsonString = JSON.serialize(objWizardObject);
        System.debug('JSON String ** DeviceWizard_NewDevice_Positive ** = '+jsonString);
        
        // Run test class in user context
        System.runAs(objUser){ 
            Test.startTest();
            LoAp_DeviceExchangeWizardCmpCtrlr.WizardStatus(jsonString);
            ID locationId = LoAp_DeviceExchangeWizardCmpCtrlr.ManageDevice(jsonString);
            Test.stopTest();     

            //System.assertEquals(objLocation.Id, locationId);
            
            // Check if only initial reading inserted with one existing reading 
            System.assertEquals(2, [Select count() From Reading__c]);
            
            // Supply Point Device record should be inserted for the new device added to the supply point
            System.assertEquals(1, [Select count() From SupplyPointDevice__c Where Device__c = :objNewDevice.Id And SupplyPoint__c = :listSupplyPoint2[0].Id]);            
            
            // get the ID of Supply Point Device
            Id spdId = [Select Id From SupplyPointDevice__c Where Device__c = :objNewDevice.Id And SupplyPoint__c = :listSupplyPoint2[0].Id][0].Id;
            
            // Supply Point Device Services should be inserted for the new device added
            System.assertEquals(2, [Select count() From SupplyPointDeviceService__c Where SupplyPointDevice__c = :spdId]);
        }
    }
    
    /******************************************************************************
    @author:    	Echo: Ankit Gangwani
    @date:      	19 Feb 2018
    @description: 	Test method for Device Wizard - Remove Device Positive scenario
    *******************************************************************************/   
    static testmethod void DeviceWizard_RemoveDevice_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name 
                        FROM User 
                        WHERE isActive=TRUE AND 
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        // locationId && recordId
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];  
        
        
        //supplyPointDevice
        SupplyPointDevice__c objOldSPD = [SELECT Id, 
                                          Device__c, 
                                          SupplyPoint__c 
                                          FROM SupplyPointDevice__c 
                                          WHERE Device__r.SerialNo__c =:OLDDEVICE_SERIALNO LIMIT 1];
        
        //selectedSupplyPointRemoved
        List<SupplyPoint__c> listSupplyPoint1 = [SELECT Id 
                                                 FROM SupplyPoint__c 
                                                 WHERE SpecialInstructions__c = :LIBRARIES LIMIT 1];
        
        //availabeBundle
        List<AvailableBundle__c> listAvailableBundles = [SELECT Id FROM AvailableBundle__c];
        
        //finalReading
        Device__c objNewDevice = [SELECT Id 
                                  FROM Device__c 
                                  WHERE SerialNo__c =:NEWDEVICE_SERIALNO LIMIT 1];
        
        
        //finalReading
        Reading__c objFinalReading = GlUt_FactoryData_Test.CreateReading(objNewDevice);
        objFinalReading.ReadingDate__c = System.today();   
        objFinalReading.ReadingType__c = EXCHANGE_FINAL;
        
        //amendReadings
        List<Reading__c> objAmendReadings = [SELECT Id FROM Reading__c];
        
        LoAp_DeviceExchangeWizardCmpCtrlr.WizardObject objWizardObject = new LoAp_DeviceExchangeWizardCmpCtrlr.WizardObject();
        objWizardObject.recordId 					= objLocation.Id;
        objWizardObject.locationId 					= objLocation.Id;
        objWizardObject.supplyPointDevice			= objOldSPD;
        objWizardObject.selectedSupplyPointRemoved  = listSupplyPoint1[0];
        objWizardObject.availabeBundle				= listAvailableBundles;
        objWizardObject.finalReading 				= objFinalReading;
        objWizardObject.amendReadings				= objAmendReadings;
        objWizardObject.wizardType 					= System.Label.LoAp_RemoveDevice; 
        
        String jsonString = JSON.serialize(objWizardObject);
        System.debug('JSON String ** DeviceWizard_RemoveDevice_Positive ** = '+jsonString);
        
        // Run test class in user context
        System.runAs(objUser){ 
            Test.startTest();
            LoAp_DeviceExchangeWizardCmpCtrlr.WizardStatus(jsonString);
            ID locationId = LoAp_DeviceExchangeWizardCmpCtrlr.ManageDevice(jsonString);
            Test.stopTest();   
            
            //System.assertEquals(objLocation.Id, locationId);  
            
            // Check if only final reading inserted with one existing reading 
            System.assertEquals(2, [Select count() From Reading__c]);
            
        }
    }
    
    /******************************************************************************
    @author:    	Echo: Ankit Gangwani
    @date:      	19 Feb 2018
    @description: 	Test method for Device Wizard - Exchange Device Positive scenario
    *******************************************************************************/  
    static testmethod void DeviceWizard_ExchangeDevice_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name 
                        FROM User 
                        WHERE isActive=TRUE AND 
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        // locationId && recordId
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];  
        
        //supplyPointDevice
        SupplyPointDevice__c objOldSPD = [SELECT Id, 
                                          Device__c, 
                                          SupplyPoint__c 
                                          FROM SupplyPointDevice__c 
                                          WHERE Device__r.SerialNo__c =:OLDDEVICE_SERIALNO LIMIT 1];
        
        //selectedSupplyPointRemoved
        List<SupplyPoint__c> listSupplyPoint1 = [SELECT Id 
                                                 FROM SupplyPoint__c 
                                                 WHERE SpecialInstructions__c = :LIBRARIES LIMIT 1];
        
        //spDeviceToBeAdded
        List<SupplyPoint__c> listSupplyPoint2 = [SELECT Id 
                                                 FROM SupplyPoint__c 
                                                 WHERE SpecialInstructions__c != :LIBRARIES LIMIT 1];
        
        //initialReading
        Device__c objNewDevice = [SELECT Id 
                                  FROM Device__c 
                                  WHERE SerialNo__c =:NEWDEVICE_SERIALNO LIMIT 1];
                
        //initialReading
        Reading__c objInitialReading = GlUt_FactoryData_Test.CreateReading(objNewDevice);
        objInitialReading.ReadingDate__c = System.today();   
        objInitialReading.ReadingType__c = EXCHANGE_INITIAL;
        
        //finalReading
        Device__c objOldDevice = [SELECT Id 
                                  FROM Device__c 
                                  WHERE SerialNo__c =:OLDDEVICE_SERIALNO LIMIT 1];
        
        
        //finalReading
        Reading__c objFinalReading = GlUt_FactoryData_Test.CreateReading(objOldDevice);
        objFinalReading.ReadingDate__c = System.today();   
        objFinalReading.ReadingType__c = EXCHANGE_FINAL;
        
        //spDeviceToBeAdded
        SupplyPointDevice__c objNewSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objNewDevice, listSupplyPoint2[0]);
        objNewSupplyPointDevice.InstallationDate__c = Date.today();
        
        //amendReadings
        List<Reading__c> objAmendReadings = [SELECT Id FROM Reading__c];
        
        //newSPDServices
        List<ServiceType__c> listSType = [SELECT Id FROM ServiceType__c];
        List<SupplyPointDeviceService__c> listSPDS = new List<SupplyPointDeviceService__c>();
        listSPDS.add(GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSPD , listSType[0]));
        listSPDS.add(GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSPD , listSType[1]));
        
        LoAp_DeviceExchangeWizardCmpCtrlr.WizardObject objWizardObject = new LoAp_DeviceExchangeWizardCmpCtrlr.WizardObject();
        objWizardObject.recordId 					= objLocation.Id;
        objWizardObject.locationId 					= objLocation.Id;
        objWizardObject.supplyPointDevice			= objOldSPD;
        objWizardObject.selectedSupplyPointRemoved  = listSupplyPoint1[0];
        objWizardObject.selectedSupplyPointAdded    = listSupplyPoint2[0];
        objWizardObject.spDeviceToBeAdded			= objNewSupplyPointDevice;
        objWizardObject.initialReading			  	= objInitialReading;
        objWizardObject.finalReading 				= objFinalReading;
        objWizardObject.amendReadings 				= objAmendReadings;
        objWizardObject.newSPDServices 				= listSPDS;
        objWizardObject.wizardType 					= System.Label.LoAp_ExchangeDevice;
        
        String jsonString = JSON.serialize(objWizardObject);
        System.debug('JSON String ** DeviceWizard_RemoveDevice_Positive ** = '+jsonString);
        
        // Run test class in user context
        System.runAs(objUser){ 
            Test.startTest();
            LoAp_DeviceExchangeWizardCmpCtrlr.WizardStatus(jsonString);
            ID locationId = LoAp_DeviceExchangeWizardCmpCtrlr.ManageDevice(jsonString);
            Test.stopTest();    
            
            //System.assertEquals(objLocation.Id, locationId);
            
            // check if initial and final readings are inserted with one existing reading 
            System.assertEquals(3, [Select count() From Reading__c]);
            
            // suuply point device record should be created for the new device added on the supply point
            System.assertEquals(1, [Select count() From SupplyPointDevice__c Where Device__c = :objNewDevice.Id And SupplyPoint__c = :listSupplyPoint2[0].Id]);
            
            // supply point services should be created for the new device added
            Id spdId = [Select Id From SupplyPointDevice__c Where Device__c = :objNewDevice.Id And SupplyPoint__c = :listSupplyPoint2[0].Id][0].Id;
            System.assertEquals(2, [Select count() From SupplyPointDeviceService__c Where SupplyPointDevice__c = :spdId]);
            
        }
    }
    
    /******************************************************************************
    @author:    	Echo: Ankit Gangwani
    @date:      	19 Feb 2018
    @description: 	Test method for Device Wizard Negative scenario
    *******************************************************************************/
    static testmethod void deviceExchange_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name
                        FROM User
                        WHERE isActive=TRUE AND
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        //Run test class in user context
        ID locationId;
        System.runAs(objUser){ 
            Test.startTest();
            try{
                locationId = LoAp_DeviceExchangeWizardCmpCtrlr.ManageDevice('');
            } catch(Exception e){
                System.debug('Exception message = ' + e.getMessage());
            }
            Test.stopTest();
            System.assertEquals(locationId, null);
        }
    }
    
    
}