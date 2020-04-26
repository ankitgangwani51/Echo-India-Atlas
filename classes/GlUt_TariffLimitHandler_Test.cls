/******************************************************************************
@author:      Echo: Neha 
@date:        16-0-2018 
@description: Test Class for GlUt_TariffLimitHandler

Comments by Dependra Singh
// Please incorporate the changes as mentioned below whenever you are updating it.
// (1)- When doing test setup , kindly make the list to insert same type of sobject.:For Example -: Account ect.
// (2)- For hardcoded values , kindly use final string
// (3)- If test class is for trigger, Kinldy test bulkified scenario.
*******************************************************************************/
@isTest
public class GlUt_TariffLimitHandler_Test {

    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME1 = 'TEST_ACCOUNT1';  // AT-3827
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String TARIFFLIMIT_STATUS = 'Approved';
    private static final String GROUP_TYPE_NAME = 'Water Company' ;
    private static final String GROUP_NAME = 'AWS';
    private static final String CONTACT_NAME = 'Testing Contract';
    private static final String WHOLESALER = 'wholesaler';
    private static final String TESTSERVICE_TYPE ='water service';
    private static final String AVAILABLESERVICES = 'avail service';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String READFREQUENCY_M = 'Monthly';
    private static final String ZIP_CODE = 'A99 9AA';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric'; 
    private static final String DEVICE_SERIALNO = '1234';
    private static final String AVAIL_SERVICE_ITEM = 'Avail Service';
    private static final String BUNDLE_NAME = 'Tariff Bundle';
    private static final String BUNDLE_ITEM = 'Item 1';
    private static final String SERVICE_ITEM_TYPE = 'Service item type';
    private static final String SERVICE_ITEM_FAMILY = 'Service Item Family';
    private static final String AVAIL_BUNDLE = 'Avail Bundle';

    private static final Date   TARIFFLIMIT_STARTDATE1 = system.today() - 30;
    private static final Date   TARIFFLIMIT_STARTDATE2 = system.today() - 40; 
    private static final Date   FUTURE_DATE1 = system.today() + 30;
    private static final Date   FUTURE_DATE2 = system.today() + 40;
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        16-0-2018  
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
        
        // Create Account Record  AT-3827
        Account objAccount1 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME1);        
        Database.insert(objAccount1);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);               
        Database.insert(objContract); 

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
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create Service Type Record 
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE);
        Database.insert(objServiceType);
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record 
        Service__c  objService = GlUt_FactoryData_Test.createService(objContract, objReading , objServiceType, objSupplyPoint, objAvailableService);
        objService.SupplyPoint__c = objSupplyPoint.Id;      
        Database.insert(objService);
        
        // Create Bundle Record 
        Bundle__c  objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType); 
        objBundle.TariffLimit__c = true;
        Database.insert(objBundle);
       
        // Create ServiceItemFamily Record 
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);        
        Database.insert(objServiceItemFamily);        
        
        // Create ServiceItemType Record 
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);        
        Database.insert(objServiceItemType);  
        
        // Create BundleItem Record 
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle,objServiceItemType,objServiceItemFamily);        
        Database.insert(objBundleItem);  
        
        // Create AvailableBundle Record 
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAIL_BUNDLE, objBundle,objAvailableService);        
        Database.insert(objAvailableBundle);
                
        // Create AvailableServiceItem Record 
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);     
        objAvailableServiceItem.ServiceItemType__c = objServiceItemType.Id;
        objAvailableServiceItem.StartDate__c= system.today() - 30;
        Database.insert(objAvailableServiceItem);  
        
        // Create ServiceItem Record 
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);     
        objServiceItem.StartDate__c= system.today() - 30;
        Database.insert(objServiceItem);       
        
        // Create GroupType Record
        GroupType__c objGroupType = GlUt_FactoryData_Test.createGroupType(GROUP_TYPE_NAME);        
        Database.insert(objGroupType); 
        
        //Create TariffLimits Record
        TariffLimits__c objCustomSetting = new TariffLimits__c(Name = 'Tariff Limit', GroupType__c = String.valueOf(objGroupType.Id));
        Database.insert(objCustomSetting);  
        
        // Create TariffLimit Record
        TariffLimit__c objTariffLimit = GlUt_FactoryData_Test.createTariffLimit(objAccount, TARIFFLIMIT_STARTDATE1, TARIFFLIMIT_STATUS);  
        objTariffLimit.EndDate__c = FUTURE_DATE1;
        Database.insert(objTariffLimit);  
        
        // Create Group Record
        Group__c objGroup = GlUt_FactoryData_Test.createGroup(GROUP_NAME);  
		objGroup.GroupType__c = objGroupType.Id;
        objGroup.TariffLimit__c = objTariffLimit.Id;
        Database.insert(objGroup);  
        
        //Create Group Item Record
        GroupItem__c objGroupItem = GlUt_FactoryData_Test.createGroupItem(objServiceItem); 
        objGroupItem.Group__c = objGroup.id;
        Database.insert(objGroupItem);
            
          
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        16-0-2018   
	@description: method for insert  a new Tariff Limit record
	*******************************************************************************/
    static testmethod void InsertTL()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Boolean sException;
        // Create TariffLimit Record
        TariffLimit__c objTariffLimit = GlUt_FactoryData_Test.createTariffLimit(objAccount, TARIFFLIMIT_STARTDATE2, TARIFFLIMIT_STATUS);        
        objTariffLimit.EndDate__c = FUTURE_DATE2;
        
        System.runAs(objUser){
            try{
                Test.startTest();             
                Database.insert(objTariffLimit);          
                Test.stopTest(); 
            }catch(Exception  e){
                sException = true;               
            }            
            system.assert(sException == true);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        16-0-2018   
	@description: method for insert  a new Tariff Limit record
	*******************************************************************************/
    static testmethod void UpdateTL()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Boolean sException;
        ServiceItem__c objServiceItem = [SELECT Id FROM ServiceItem__c LIMIT 1];
        TariffLimit__c objTariffLimit = [SELECT Id,EndDate__c,StartDate__c FROM TariffLimit__c LIMIT 1]; 
        objTariffLimit.EndDate__c = FUTURE_DATE2;
        objTariffLimit.StartDate__c = TARIFFLIMIT_STARTDATE2;
        
        System.runAs(objUser){
            try{
                Test.startTest();             
                Database.update(objTariffLimit);          
                Test.stopTest(); 
            }catch(Exception  e){     
                sException = true;
            }
            
            //List<ServiceItem__c> serviceItemList = [SELECT Id FROM ServiceItem__c WHERE Id != :objServiceItem.Id];
            //system.assert(serviceItemList.size() > 0);
        }
    }
}