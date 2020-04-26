/******************************************************************************
@author:      Echo: Neha 
@date:        12-10-2018  
@description: Test Class for LoAp_ServicesBilledRecordListCtrlr
*******************************************************************************/
@isTest  
public class LoAp_ServicesBilledRecordListCtrlr_Test {   
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String LOCATION_NAME = 'A99 9AA';        
    private static final String READFREQUENCY_M = 'Monthly';     
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';       
    private static final String TESTSERVICE_TYPE1 ='water service';
    private static final String DEVICE_SERIALNO 	= '1234';
    private static final String DEVICE_SERIALNO_NEW = '1235';
    private static final String AVAILABLESERVICES = 'avail service';    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';    
    private static final String WHOLESALER = 'wholesaler';
    private static final String CONTACT_NAME = 'TEST Contract';
    private static final String AVAIL_SERVICE_ITEM = 'AVAIL SERVICE ITEM';
    private static final String BUNDLE = 'social bundle';
    private static final String AVAIL_BUNDLE = 'test bundle';
    private static final String BUNDLE_ITEM = 'BUNDLE ITEM';   
    private static final String ACTUAL_READING  = '015';
    private static final String SERVICE_ITEM_FAMILY  = 'SERVICE ITEM FAMILY';
    private static final String SERVICE_ITEM_TYPE  = 'SERVICE ITEM TYPE';
    private static final String BILL_ITEM  = 'Bill ITEM';
    private static final String BILL  = 'BIll no';
    private static final String BILL_SERVICE_TYPE  = 'BILL SERVICE TYPE';
    private static final String HEROKU_ID  = '907dda54187e40859b6a4725f9e4522b';
    private static final Integer BILL_VOLUMEUSED  = 20;
    private static final Integer BILLED_AMT  = 20;
    
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
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
                      
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);            
        Database.insert(objContract); 

        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        // Create Location Occupant Record
        LocationOccupant__c objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);        
        Database.insert(objLocationOccupant);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; 
      
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c  objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_SERIALNO , objDeviceType);        
        objDevice.SerialNo__c = DEVICE_SERIALNO;
        Database.insert(objDevice);
        
        // Create SPD Record
        SupplyPointDevice__c  objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice , objSupplyPoint); 
        Database.insert(objSupplyPointDevice);
    
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_READING;        
        Database.insert(objReading);
        
        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create Service Type Record 
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType);  
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record 
        Service__c  objService = GlUt_FactoryData_Test.createService(objContract, objReading , objServiceType, objSupplyPoint, objAvailableService);
        objService.SupplyPoint__c = objSupplyPoint.Id;      
        Database.insert(objService);
        
        // Create Bundle Record 
        Bundle__c  objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE, objServiceType);           
        Database.insert(objBundle);
        
        // Create AvailableBundle Record 
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAIL_BUNDLE, objBundle, objAvailableService);             
        Database.insert(objAvailableBundle);
      
        // Create ServiceItemFamily Record 
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);             
        Database.insert(objServiceItemFamily);
      
  		// Create ServiceItemType Record 
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE, objServiceItemFamily, objDivision,objDeviceType,objWholesaler );             
        Database.insert(objServiceItemType);
        
        // Create BundleItem Record 
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);             
        Database.insert(objBundleItem);        
  
         // Create AvailableServiceItem Record 
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem , objServiceItemType, objAvailableBundle);          
        Database.insert(objAvailableServiceItem);
        
        // Create Service Item Record 
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);             
        Database.insert(objServiceItem);        
        
        // Create Bill Record 
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL, objContract);             
        Database.insert(objBill);
        
        // Create BillServiceType Record 
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE, objBill, HEROKU_ID);             
        Database.insert(objBillServiceType); 
        
        // Create Bill Item Record 
        BillItem__c  objBillItem = GlUt_FactoryData_Test.createBillItem(BILL_ITEM, objServiceItem, BILL_VOLUMEUSED, BILLED_AMT, objBillServiceType, HEROKU_ID );             
        Database.insert(objBillItem);
        
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        12-10-2018 
	@description: method for 
	*******************************************************************************/
    static testmethod void retrieveServiceBilledFieldSetList_Test()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];                
        System.runAs(objUser){
            Test.startTest();      
            List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        	fldPropList = LoAp_ServicesBilledRecordListCtrlr.retrieveServiceBilledFieldSetList();          
            Test.stopTest();            
            system.assert(fldPropList.size() > 0 );           
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        12-10-2018  
	@description: method for 
	*******************************************************************************/
    static testmethod void retrieveServiceBilledFieldRecords_Positive()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Reading__c objReading = [SELECT Id FROM Reading__c LIMIT 1];
        System.runAs(objUser){            
            Test.startTest();             
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        	records = LoAp_ServicesBilledRecordListCtrlr.retrieveServiceBilledFieldRecords(objReading.Id);          
            Test.stopTest(); 
            system.assert( records.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        12-10-2018  
	@description: method for 
	*******************************************************************************/
    static testmethod void retrieveServiceBilledFieldRecords_Positive2()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];        
        Reading__c objReading = [SELECT Id FROM Reading__c LIMIT 1];
        BillItem__c objBillItem = [SELECT Id,Reading__c  FROM BillItem__c LIMIT 1];
        objBillItem.Reading__c = objReading.Id;
        database.update(objBillItem);        
        System.runAs(objUser){            
            Test.startTest();             
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        	records = LoAp_ServicesBilledRecordListCtrlr.retrieveServiceBilledFieldRecords(objReading.Id);          
            Test.stopTest(); 
            system.assert( records.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        12-10-2018  
	@description: method for 
	*******************************************************************************/
    static testmethod void retrieveServiceBilledFieldRecords_Negative()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        DeviceType__c objDeviceType = [SELECT Id FROM DeviceType__c LIMIT 1];
        
        // Create New Device Record
        Device__c  objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_SERIALNO_NEW , objDeviceType);        
        objDevice.SerialNo__c = DEVICE_SERIALNO_NEW;
        Database.insert(objDevice);

        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ActualDeviceReading__c = ACTUAL_READING;
        Database.insert(objReading);        
       
        System.runAs(objUser){            
            Test.startTest();             
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        	records = LoAp_ServicesBilledRecordListCtrlr.retrieveServiceBilledFieldRecords(objReading.Id);          
            Test.stopTest(); 
            system.assert( records.size() == 0);
        }
    }
        	    
}