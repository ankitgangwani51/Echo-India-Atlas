/******************************************************************************
@author:      Echo: Neha 
@date:        27-06-2018  
@description: Test Class for LoAp_LeakRecordingCtrlr_Test
*******************************************************************************/
@isTest  
public class LoAp_LeakRecordingCtrlr_Test {   
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String LOCATION_NAME = 'A99 9AA'; 
    private static final String ACCOUNT_NAME2 = 'TEST_ACCOUNT2';
    private static final String LOCATION_NAME2 = 'A99 9AB'; 
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY_M = 'Monthly'; 
    private static final String DEVICE_SERIALNO 	= '1234';
    private static final String DEVICE_SERIALNO2 	= '1235';  
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String CONTACT_NAME = 'test1';
    private static final String CONTACT_NAME2 = 'test2';
    private static final Boolean isException;
  
	/******************************************************************************
	@author:      Echo: Neha
	@date:        29-01-2018  
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
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
               
        // Create Account Record
        Account objAccountMain = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccountMain);
                
        //Create Contract Record
        BillingContract__c objContractMain = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccountMain);
        Database.insert(objContractMain);                
        
        // Create Location Record
        Location__c objLocationMain = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocationMain);
        
        // Create Location Occupant Record
        LocationOccupant__c objLocationOccupantMain = GlUt_FactoryData_Test.createLocationOccupant(objAccountMain, objLocationMain);        
        Database.insert(objLocationOccupantMain);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPointMain = GlUt_FactoryData_Test.createSupplyPoint(objLocationMain, objSupplyPointUsageType);
        objSupplyPointMain.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPointMain);
        
        // Create Device Record
        Device__c  objDeviceMain = GlUt_FactoryData_Test.CreateDevice(DEVICE_SERIALNO , objDeviceType);        
        objDeviceMain.SerialNo__c = DEVICE_SERIALNO;
        Database.insert(objDeviceMain);
        
        // Create Supply Point Device
        SupplyPointDevice__c  objSPDMain = GlUt_FactoryData_Test.createSupplyPointDevices(objDeviceMain , objSupplyPointMain);              
        Database.insert(objSPDMain);    
             
        // Create Reading Record
        Reading__c objReadingMain = GlUt_FactoryData_Test.createReading(objDeviceMain);   
        objReadingMain.ActualDeviceReading__c = '015';
        objReadingMain.ReadingDate__c = system.today();
        Database.insert(objReadingMain);  
        
        // Create Account Record
        Account objAccountSub = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);        
        Database.insert(objAccountSub);
                
        //Create Contract Record
        BillingContract__c objContractSub = GlUt_FactoryData_Test.createContract(CONTACT_NAME2,objAccountSub);
        Database.insert(objContractSub);                
        
        // Create Location Record
        Location__c objLocationSub = GlUt_FactoryData_Test.createLocation(LOCATION_NAME2);
        Database.insert(objLocationSub);
        
        // Create Location Occupant Record
        LocationOccupant__c objLocationOccupantSub = GlUt_FactoryData_Test.createLocationOccupant(objAccountSub, objLocationSub);        
        Database.insert(objLocationOccupantSub);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPointSub = GlUt_FactoryData_Test.createSupplyPoint(objLocationSub, objSupplyPointUsageType);
        objSupplyPointSub.Measured__c = TRUE; // AT-3174
        Database.insert(objSupplyPointSub);
        
        // Create Device Record
        Device__c  objDeviceSub = GlUt_FactoryData_Test.CreateDevice(DEVICE_SERIALNO2 , objDeviceType);        
        objDeviceSub.SerialNo__c = DEVICE_SERIALNO2;
        Database.insert(objDeviceSub);
        
        // Create Supply Point Device
        SupplyPointDevice__c  objSPDSub = GlUt_FactoryData_Test.createSupplyPointDevices(objDeviceSub , objSupplyPointSub);              
        Database.insert(objSPDSub);    
             
        // Create Reading Record
        Reading__c objReadingSub = GlUt_FactoryData_Test.createReading(objDeviceSub);
        objReadingSub.ActualDeviceReading__c = '10';
        objReadingSub.ReadingDate__c = system.today();
        Database.insert(objReadingSub);  
        
        // Create SupplyPointRelationship
        SupplyPointRelationship__c objSPR = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPointMain, objSupplyPointSub);
        objSPR.StartDate__c = system.today() - 10;
        Database.insert(objSPR);
                     
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        29-01-2018  
	@description: method for insert  a new record
	*******************************************************************************/
    static testmethod void updateLeakReading_Positive()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        String recordStatus;
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c,SubSupply__c,StartDate__c,EndDate__c FROM SupplyPointRelationship__c LIMIT 1];
        
        Reading__c mainDeviceReading = [SELECT Id
                                       FROM Reading__c 
                                       WHERE Device__c IN (SELECT Device__c
                                                                    FROM SupplyPointDevice__c
                                                                    WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                                                    AND Active__c = true) LIMIT 1]; 
        
        Reading__c objReading = [SELECT Id FROM Reading__c WHERE Id = :mainDeviceReading.Id LIMIT 1];
        System.runAs(objUser){
            Test.startTest(); 
            LoAp_LeakRecordingCtrlr.ContainerWrapper resultContainer;
        	resultContainer = LoAp_LeakRecordingCtrlr.updateLeakReading(mainDeviceReading.Id, GlUt_APIConstantsReading.READINGAPINAME, '5');            
            Test.stopTest();            
            system.assert( resultContainer.message == Label.GuAp_RecordSuccessfullyUpdatedMsg);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        29-01-2018  
	@description: method for insert  a new record
	*******************************************************************************/
    static testmethod void updateLeakReading_negative()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        String recordStatus;
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c,SubSupply__c,StartDate__c,EndDate__c FROM SupplyPointRelationship__c LIMIT 1];
        Reading__c mainDeviceReading = [SELECT Id
                                       FROM Reading__c 
                                       WHERE Device__c IN (SELECT Device__c
                                                                    FROM SupplyPointDevice__c
                                                                    WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                                                    AND Active__c = true) LIMIT 1]; 
        
        Reading__c objReading = [SELECT Id FROM Reading__c WHERE Id = :mainDeviceReading.Id LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            LoAp_LeakRecordingCtrlr.ContainerWrapper resultContainer;
        	resultContainer = LoAp_LeakRecordingCtrlr.updateLeakReading(mainDeviceReading.Id, GlUt_APIConstantsReading.READINGAPINAME, '15');
            Test.stopTest();            
            system.assert( resultContainer.message == Label.GuAp_NoRecordUpdated + ' ' + Label.GlUt_EffDeviceReadingInvalid);
        }
    }
    /******************************************************************************
	@author:      Echo: Amit K.
	@date:        14-11-2018  
	@description: method to check the reading Status i.e. Invalid or valid
	*******************************************************************************/
    static testmethod void getReadingStatus_positive()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        String recordStatus;
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c,SubSupply__c,StartDate__c,EndDate__c FROM SupplyPointRelationship__c LIMIT 1];
        Reading__c mainDeviceReading = [SELECT Id
                                       FROM Reading__c 
                                       WHERE Device__c IN (SELECT Device__c
                                                                    FROM SupplyPointDevice__c
                                                                    WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                                                    AND Active__c = true) LIMIT 1]; 
        
        Reading__c objReading = [SELECT Id FROM Reading__c WHERE Id = :mainDeviceReading.Id LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            Boolean status = true;
            status = LoAp_LeakRecordingCtrlr.getReadingStatus(objReading.Id);
            Test.stopTest();            
            system.assert(status == true);
        }
    }
        	    
}