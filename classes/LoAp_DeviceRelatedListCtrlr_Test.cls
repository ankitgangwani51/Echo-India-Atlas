/******************************************************************************
@author         Echo: Mohit Tayal
@date           16 Feb 2018
@description    Test Class for LoAp_DeviceRelatedListCtrlr

@revision(s)        
*******************************************************************************/

@isTest
public class LoAp_DeviceRelatedListCtrlr_Test {

    //Variable declaration start    
    private static String USER_PROFILE = 'System Administrator';
    private static String USERNAME = 'TestUser';
    private static String USERNAMECOMPLETE  = USERNAME+ '@unitest.com';
    private static String TESTSERVICE_TYPE1 = 'TestServiceType1';
    private static String TESTSERVICE_TYPE2 = 'TestServiceType2';
    private static String TESTSERVICE_TYPE3 = 'TestServiceType3';
    private static String TESTSERVICE_TYPE4 = 'TestServiceType4';
    private static String LOCATION_NAME = 'A99 9AA';  
    private static String ACCOUNT_NAME = 'TestDevice';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String DEVICE_TYPE_NAME = 'Meter';
    private static String OLDDEVICE_SERIALNO = '1234';
    private static String NEWDEVICE_SERIALNO = '6789';
    private static String NEWDEVICE_SERIALNO2 = '546';
    private static String YES = 'yes';
    //private static String TRUE ='true';
    private static String MEASURED = 'Monthly';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    
    //Variable declaration end

/******************************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 Feb 2018
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USERNAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(USERNAME,objAccount);
        Database.insert(objContract);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1 );
        Database.insert(objServiceType1);
        
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE2 );
        Database.insert(objServiceType2);
        
        ServiceType__c objServiceType3 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE3 );
        Database.insert(objServiceType3);
        
        ServiceType__c objServiceType4 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE4 );
        Database.insert(objServiceType4);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint1);
        
        SupplyPoint__c  objSupplyPoint2 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint2);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);      
      
        //Old device details
        Device__c  objOldDevice = GlUt_FactoryData_Test.CreateDevice(OLDDEVICE_SERIALNO , objDeviceType); 
        objOldDevice.SerialNo__c = OLDDEVICE_SERIALNO;
        Database.insert(objOldDevice);
        
        SupplyPointDevice__c  objOldSupplyPointDevice = GlUt_FactoryData_Test.CreateSupplyPointDevices(objOldDevice , objSupplyPoint1);        
        Database.insert(objOldSupplyPointDevice); 
        
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService1 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType1);        
        Database.insert(objOldSupplyPointDeviceService1);
        
        SupplyPointDeviceService__c  objOldSupplyPointDeviceService2 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objOldSupplyPointDevice , objServiceType2);        
        Database.insert(objOldSupplyPointDeviceService2);  
        
        Reading__c objReading = new Reading__c();
        
        AvailableService__c objAvailableService = new AvailableService__c();
        
        Service__c  objOldService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService1);
        
        Service__c  objOldService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint1, objAvailableService);
        Database.insert(objOldService2);
        //End of Old device details
        
        //New device details
        Device__c  objNewDevice1 = GlUt_FactoryData_Test.CreateDevice(NEWDEVICE_SERIALNO , objDeviceType);      
        objNewDevice1.SerialNo__c = NewDEVICE_SERIALNO;
        Database.insert(objNewDevice1);
                
        SupplyPointDevice__c  objNewSupplyPointDevice1 = GlUt_FactoryData_Test.CreateSupplyPointDevices(objNewDevice1 , objSupplyPoint1); 
        objNewSupplyPointDevice1.RemovalDate__c = objNewSupplyPointDevice1.InstallationDate__c + 5;
        Database.insert(objNewSupplyPointDevice1);
        
        Service__c  objNewService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        Database.insert(objNewService1);
        
        Service__c  objNewService2 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType2, objSupplyPoint1, objAvailableService);
        Database.insert(objNewService2);
        
        Reading__c objNewReading = GlUt_FactoryData_Test.CreateReading(objNewDevice1);
        Database.insert(objNewReading); 
        //End of First New device details
        
        //New Device Details 2
        Device__c  objNewDevice2 = GlUt_FactoryData_Test.CreateDevice(NEWDEVICE_SERIALNO2 , objDeviceType);      
        objNewDevice2.SerialNo__c = NEWDEVICE_SERIALNO2;
        Database.insert(objNewDevice2);
                
        SupplyPointDevice__c  objNewSupplyPointDevice2 = GlUt_FactoryData_Test.CreateSupplyPointDevices(objNewDevice2 , objSupplyPoint2); 
        objNewSupplyPointDevice2.RemovalDate__c = objNewSupplyPointDevice2.InstallationDate__c + 5;
        Database.insert(objNewSupplyPointDevice2);
        
        Service__c  objNewService3 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType3, objSupplyPoint2, objAvailableService);
        Database.insert(objNewService3);
        
        Service__c  objNewService4 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType4, objSupplyPoint2, objAvailableService);
        Database.insert(objNewService4);
        //End of Second New device details
    }
    
/******************************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 Feb 2018
@description: Test method for retrieveDeviceFieldPropDetails method
*******************************************************************************/
    static testmethod void RetrieveDeviceFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        //Run test class in user context
        System.runAs(objUser){           
            Test.startTest();
            List<GLAp_FieldProps> listFieldProps  = LoAp_DeviceRelatedListCtrlr.retrieveFieldPropDetails();
            Test.stopTest();
            System.assert(listFieldProps != null);
        }
    }
    
/******************************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 Feb 2018
@description: Test method for retrieveDeviceFieldPropDetails method
*******************************************************************************/
    /*static testmethod void RetrieveDeviceFieldPropDetails_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        //Run test class in user context
        System.runAs(objUser){           
            Test.startTest();
            List<GLAp_FieldProps> listFieldProps  = LoAp_DeviceRelatedListCtrlr.retrieveDeviceFieldPropDetails();
            Test.stopTest();
            System.assert(listFieldProps != null);
        }
    }*/
    
/******************************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 Feb 2018
@description: Test method for RetrieveDeviceRecords() method
*******************************************************************************/
    static testmethod void RetrieveDeviceRecords_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        List<Location__c> objLocation = [SELECT Id,Name FROM Location__c WHERE PostalCode__c =: LOCATION_NAME LIMIT 1];
        
        List<Device__c> objDevice = [SELECT Id FROM Device__c WHERE DeviceType__r.Manufacturer__c =: MANUFACTURER AND Device__c.SerialNo__c =: OLDDEVICE_SERIALNO LIMIT 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            
            List<BlAp_CombinedRecord> listCombinedRecord = LoAp_DeviceRelatedListCtrlr.retrieveRecords(objLocation.get(0).Id);
            
            Test.stopTest();
            
            System.assert(listCombinedRecord != null);
            
        }
    }
}