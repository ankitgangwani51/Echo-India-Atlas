/***************************************************************************************************
@author         Neha R.
@date           16 Jan 2019
@description    This is test class for CuAp_SuspendServiceItemCtrlr
Revision(s)   
*******************************************************************************************************/
@isTest
public class CuAp_SuspendServiceItemCtrlr_Test {
    //Variable declaration start
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_FNAME= 'TestFName';
    private static final String USER_LNAME= 'TestLName';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    
    private static String USER_NAME = 'TestUser';
    private static String USERNAMECOMPLETE = USER_NAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount';
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String LOCATION_STREET = 'Test Street';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String BUNDLENAME ='TestBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String SERVICEITEMTYPE = 'TestSrvItemType';  
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';  
    private static String DEVICENAME = 'TestDevice';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String MANUFACTURER1 = 'Kent';
    
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String ALLOWANCETYPENAME 	 	= 'TestAllowanceType';
    private static final String ALLOWANCEPRIORITY 	 	= '1';
    private static final String ALLOWANCETYPE 	 	    = 'Fixed Volume Allowance';
    private static final String SUSPENDED_STARTDATE = String.valueOf(system.today());
    private static final String SUSPENDED_ENDDATE 	= String.valueOf(system.today() + 10);
    private static final String BILL = 'Test Bill'; 
        private static final String BILL_SERVICE_TYPE ='water service' ;
    private static final String BILLITEM ='BI-2210' ;
        private static final Integer VOLUME = 20; 
     private static final Integer BILLED_AMT = 20;
        private static final String HEROKUPOSTGRESID = 'HEROKUPOSTGRESID';
        
    
    
   
    /******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    *******************************************************************/
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c    =BILLING_STREET;
        objContract.BillingCity__c      =BILLING_CITY;
        objContract.BillingState__c     =BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c   =BILLING_COUNTRY;        
        Database.insert(objContract);
        
        //Create Location record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c         =LOCATION_STREET ;
        Database.insert(objLocation);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c =True;  
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);        
     
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create Device record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
        
        //Create Supply Point Device record
        SupplyPointDevice__c  objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        //Create Reading record
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        
        //Create Service Type record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        Database.insert(objServiceType);
        
        //Create service item family record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create Division record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //Create Wholesaler record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create Available Service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Create Service record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);        
        
        //Create Service Item Type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);        
        Database.insert(objServiceItemType);
        
        //Create Bundle Type record
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
	
        //Create Available Bundle record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create Bundle Item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);  
        
        //Create Available Service Item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        Database.insert(objAvailableServiceItem); 
        
        //Create Service Item record
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        Database.insert(objServiceItem);
        
        //Create Bill record
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL,objContract);
        Database.insert(objBill);
        
        //Create Bill Service Type record
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE, objBill, HEROKUPOSTGRESID );
        Database.insert(objBillServiceType);
        
        //Create Bill Item record
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEM, objServiceItem, VOLUME, BILLED_AMT,objBillServiceType, HEROKUPOSTGRESID);
        Database.insert(objBillItem);
        
    }
        
    /*******************************************************************
    Purpose: Test to retrieve field property and details by record Id 
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void retrieveServiceItemDetails_positive(){
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        ServiceItem__c objServiceItem = [SELECT Id FROM ServiceItem__c LIMIT 1];
        CuAp_SuspendServiceItemCtrlr.SuspendSIContainerWrapper wrapperObj = new CuAp_SuspendServiceItemCtrlr.SuspendSIContainerWrapper();   
        System.runAs(objUser){
            Test.startTest();
			wrapperObj = CuAp_SuspendServiceItemCtrlr.retrieveServiceItemDetails(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,objServiceItem.Id);        
            Test.stopTest();
            System.assert(wrapperObj.objServiceItem != null);            
        }
    }  
    
    /*******************************************************************
    Purpose: Test to save record
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void saveServiceItemRecord_positive(){       
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        ServiceItem__c objServiceItem = [SELECT Id FROM ServiceItem__c LIMIT 1];         
        String result;
        System.runAs(objUser){
            Test.startTest();
			result = CuAp_SuspendServiceItemCtrlr.saveServiceItemRecord(objServiceItem.Id, SUSPENDED_STARTDATE, SUSPENDED_ENDDATE);        
            Test.stopTest();
            System.assert(result == Label.GlAp_Success );            
        }
    }  
    
    /*******************************************************************
    Purpose: Test to save record
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void saveServiceItemRecord_error(){       
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];        
        BillItem__c objBillItem = [SELECT Id,EndDate__c FROM BillItem__c LIMIT 1];
        objBillItem.EndDate__c = date.valueOf(SUSPENDED_ENDDATE) + 1;
        database.update(objBillItem);        
        ServiceItem__c objServiceItem = [SELECT Id FROM ServiceItem__c LIMIT 1];         
        String result;
        System.runAs(objUser){
            Test.startTest();
			result = CuAp_SuspendServiceItemCtrlr.saveServiceItemRecord(objServiceItem.Id, SUSPENDED_STARTDATE, SUSPENDED_ENDDATE);        
            Test.stopTest();
            System.assert(result == Label.CuAp_BillExistInSuspensionPeriod);            
        }        
         
    }  
    
}