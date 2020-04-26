/******************************************************************************
@author:      Echo: Ankit Gangwani
@date:        22 Jan 2019
@description: Test Class for BlBt_FinalBillsWriteOff
*******************************************************************************/
@isTest 
public class BlBt_FinalBillsWriteOff_Test {
    
    private static final String USER_PROFILE 				= 'System Administrator';
    private static final String USER_NAME 					= 'TestUser';
    private static final String USERNAMECOMPLETE  			= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 					= 'First_User_Name';
    private static final String USER_LNAME 					= 'Last_User_Name'; 
    private static final String SNAME						= 'Test Account';
    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final String FINALBILL = 'true';
    private static final String FINALBILLFALSE = 'false';
    private static final String BILLDATE = string.valueOf(System.Today());
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String SUB_DEVICE_TYPE ='TestSubDevice';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String BUNDLE ='TestBundle';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String SITESAMPLE ='Testsitesample';
    private static final String SAMPLE ='TestSample';
    private static final String AGREERATE ='TestAgreeRate';
    private static final String BILLSERVICENAME = 'Test Bill Service';
    private static final String BILLNAME = 'testBill';
    private static final String HEROKUPOSTGRESID = 'Test ID';
    private static final String BILLITEMNAME = 'Test Bill Item';
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    
    private static final String BILLINGRESPONSEMOCKPOSITIVE = 'GlUt_MockFinalBillWriteOff';
    private static final String BILLINGRESPONSEMOCKNEGATIVE = 'GlUt_MockFinalBillWriteOffNegative';
    
    
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
	@date:        22 Jan 2019 
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        //Create Batch Request Queue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Status__c = 'Loading';
        Database.insert(objBatchRequestQueue);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(SNAME);
        Database.insert(objAccount);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(objAccount);
        Database.insert(objContract);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        // Create Service Type Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        // Create Reading Record
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        // Create Service Item Family Record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        // Create Service Item Type Record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        // Create Bundle Record
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        // Create Available Bundle Record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        // Create Bundle Item Record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        // Create Available Service Item Record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        // Create Service Item Record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        Database.insert(objServiceItem);     
        
        // Create Bill Record
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,objContract);
        objBill.Account__c = objAccount.id; 
        objBill.FinalBill__c = TRUE;
        objBill.DoNotPrint__c = FALSE;
        Database.insert(objBill);
        
        // Create Bill Service Type Record
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        
        // Create Bill Item Record
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        objBillItems.NetBilledAmount__c = 3.50;
        objBillItems.AmountPaid__c = 1.50;
        Database.insert(objBillItems); 
        
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
       
    } 
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
	@date:        22 Jan 2019
    @description: Method to execute FinalBillsWrite Off batch in start scenario
    *******************************************************************************/
    static testmethod void writeOffBatch_start(){      
        setFinalBillData();// Added By Echo: Dependra Singh
        User objUser = [SELECT Id FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        List<Bill__c> bills = [SELECT Id, FinalBill__c, DoNotPrint__c, TotalAmountOutstanding__c FROM Bill__c];
        Database.BatchableContext bc;
        System.runAs(objUser){
            Test.startTest();
            BlBt_FinalBillsWriteOff writeOffBatch = new BlBt_FinalBillsWriteOff();
            writeOffBatch.Initialise(objBatchReqQueue);
            writeOffBatch.start(bc);            
            Test.stopTest();
            System.assert(writeOffBatch.batchRequestQueue != null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
	@date:        22 Jan 2019
    @description: Method to execute FinalBillsWrite Off batch in execute Positive scenario
    *******************************************************************************/
    static testmethod void writeOffBatch_executePositive() {      
        setFinalBillData();// Added By Echo: Dependra Singh
        User objUser = [SELECT Id FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        List<Bill__c> bills = [SELECT Id, FinalBill__c, DoNotPrint__c, TotalAmountOutstanding__c FROM Bill__c];
        Database.BatchableContext bc;
        System.runAs(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));// assert are required.
            BlBt_FinalBillsWriteOff writeOffBatch = new BlBt_FinalBillsWriteOff();
            writeOffBatch.Initialise(objBatchReqQueue);            
            writeOffBatch.execute(bc, bills);
            Test.stopTest();            
        }
        
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
	@date:        22 Jan 2019
    @description: Method to execute FinalBillsWrite Off batch in execute Negative scenario
    *******************************************************************************/
    static testmethod void writeOffBatch_executeNegative(){   
        setFinalBillData();// Added By Echo: Dependra Singh
        User objUser = [SELECT Id FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        List<Bill__c> bills = [SELECT Id, FinalBill__c, DoNotPrint__c, TotalAmountOutstanding__c FROM Bill__c];
        Database.BatchableContext bc;
        System.runAs(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKNEGATIVE));
            BlBt_FinalBillsWriteOff writeOffBatch = new BlBt_FinalBillsWriteOff();
            writeOffBatch.Initialise(objBatchReqQueue);            
            writeOffBatch.execute(bc, bills);
            Test.stopTest();
        }
        
    }
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
	@date:        22 Jan 2019
    @description: Method to execute FinalBillsWrite Off batch in finish scenario
    *******************************************************************************/
    static testmethod void writeOffBatch_finish(){        
        setFinalBillData();// Added By Echo: Dependra Singh
        User objUser = [SELECT Id FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id FROM BatchRequestQueue__c LIMIT 1];
        Database.BatchableContext bc;
        System.runAs(objUser){
            Test.startTest();
            BlBt_FinalBillsWriteOff writeOffBatch = new BlBt_FinalBillsWriteOff();
            writeOffBatch.Initialise(objBatchReqQueue);            
            writeOffBatch.finish(bc);
            Test.stopTest();
        }
    } 
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Final Bill Custom meta data type Data
    *******************************************************************************/ 
    private static void setFinalBillData(){
        GlUt_CustomMetaDataUtility.setMetadata(GlUt_Constants.FINALBILLQUERY,(List<FinalBill__mdt>) JSON.deserialize( 
            '[{"' + GlUt_Constants.DONOTPRINTAPINAME + '":"' + GlUt_Constants.DONOTPRINTVALUE + '"}]', 
            List<FinalBill__mdt>.class)); 
    }
}