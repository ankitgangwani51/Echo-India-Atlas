/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        17 Feb 2018
@description: Test Class for CuAp_MoveOutWizardComponentCtrlr
@Revisions	   AT-3981 ,Tarun, Security review changes , modified classname
@description: Test Class for GlUt_ServiceHandler
Comments by Dependra Singh
// Please incorporate the changes as mentioned below whenever you are updating it.
// (1)- When doing test setup , kindly make the list to insert same type of sobject.:For Example -: BillingContract__c ect.
*******************************************************************************/
@isTest
public class CuAp_MoveOutWizardComponentCtrlr_Test { 
    
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
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 Feb 2018
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
        
        //Create Contract Record - NHH
        BillingContract__c objContractNHH = GlUt_FactoryData_Test.CreateContract(' ',lstAccount[1]);
        objContractNHH.BillingStreet__c = STREET;
        objContractNHH.BillingCity__c = CITY;
        objContractNHH.BillingState__c = STATE;
        objContractNHH.BillingPostalCode__c = POSTAL_CODE;
        objContractNHH.BillingCountry__c = COUNTRY;
        Database.insert(objContractNHH);
        
        //Create Contract Record - HH
        BillingContract__c objContractHH = GlUt_FactoryData_Test.CreateContract(' ',lstAccount[0]);
        objContractHH.BillingStreet__c = STREET;
        objContractHH.BillingCity__c = CITY;
        objContractHH.BillingState__c = STATE;
        objContractHH.BillingPostalCode__c = POSTAL_CODE;
        objContractHH.BillingCountry__c = COUNTRY;
        Database.insert(objContractHH);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.City__c = CITY;
        objLocation.State__c = STATE;
        objLocation.Street__c = STREET;
        objLocation.Country__c = COUNTRY;
        Database.insert(objLocation);
        
        // Create Location Occupant Record - HH
        LocationOccupant__c  objLocationOccupantHH = GlUt_FactoryData_Test.createLocationOccupant(lstAccount[1], objLocation);
        objLocationOccupantHH.EndDate__c = System.today() - 1;
        Database.insert(objLocationOccupantHH);
        
        // Create Location Occupant Record - NHH
        LocationOccupant__c  objLocationOccupantNHH = GlUt_FactoryData_Test.createLocationOccupant(lstAccount[0], objLocation);
        objLocationOccupantNHH.EndDate__c = System.today() - 1;
        Database.insert(objLocationOccupantNHH);
        
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
        SupplyPoint__c objSupplyPointMain = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPointMain.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPointMain);
        
        //Custom Setting  AT-3158
        ConfigureTemplate__c  objConfigureTemplate = GlUt_FactoryData_Test.createConfigureTemplate(SENDER_EMAIL);       
        Database.insert(objConfigureTemplate);
       
        // Contact Record AT-3158
        Contact  objContact = GlUt_FactoryData_Test.createContact(USER_FNAME,USER_LNAME);
        objContact.Email = SENDER_EMAIL;
        Database.insert(objContact);
        
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        17 Feb 2018
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
        
        CuAp_MoveOutWizardComponentCtrlr.WizardObject objWizardObject = new CuAp_MoveOutWizardComponentCtrlr.WizardObject();
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
            status = CuAp_MoveOutWizardComponentCtrlr.wizardStatus(jsonSerializeWizard);
            contractId = CuAp_MoveOutWizardComponentCtrlr.moveOut(jsonSerializeWizard);
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
        
        CuAp_MoveOutWizardComponentCtrlr.WizardObject objWizardObject = new CuAp_MoveOutWizardComponentCtrlr.WizardObject();
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
            status = CuAp_MoveOutWizardComponentCtrlr.wizardStatus(jsonSerializeWizard);
            System.debug('status = '+status);
            
            contractId = CuAp_MoveOutWizardComponentCtrlr.moveOut(jsonSerializeWizard);
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
        
        CuAp_MoveOutWizardComponentCtrlr.WizardObject objWizardObject = new CuAp_MoveOutWizardComponentCtrlr.WizardObject();
        objWizardObject.location = Null;
        
        String jsonSerializeWizard = JSON.serialize(objWizardObject);
        Map<String,Boolean> status = new Map<String,Boolean>();
        Boolean isException;
        Id contractId;
        
        System.runAs(objUser){            
            try{
                Test.startTest();
                status = CuAp_MoveOutWizardComponentCtrlr.wizardStatus(jsonSerializeWizard);
                contractId = CuAp_MoveOutWizardComponentCtrlr.moveOut(jsonSerializeWizard);
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
                status = CuAp_MoveOutWizardComponentCtrlr.wizardStatus(Null);
                contractId = CuAp_MoveOutWizardComponentCtrlr.moveOut(Null);
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