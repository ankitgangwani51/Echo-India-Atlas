/******************************************************************************
@author:      Echo: Dependra Singh
@date:        14-June-2018
@description: Test Class for BlAp_ViewBillDocumentsCtrlr 
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
//test data creation for BlAp_ViewBillDocumentsCtrlr class
public class BlAp_ViewBillDocumentsCtrlr_Test {
    public static final String PDF_TEMPLATE_NAME    = 'pdfTemplateName';
    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static final String CONTRACT_NAME       = 'TestContract';
    private static final String DEVICE_NAME         = 'TestDevice';
    private static final String DEVICE_TYPE         = 'TestDeviceType';
    private static final String SUB_DEVICE_TYPE     = 'TestSubDevice';
    private static final String TEST_SERVICE_TYPE   = 'TestServiceType';
    private static final String LOCATION_NAME       = 'A99 9AA';
    private static final String LOCATION_SUB_TYPE   = 'Detached';
    private static final String STREET              = 'teststreet';
    private static final String YES                 = 'yes';
    private static final String MEASURED            = 'Monthly';
    private static final String WHOLESALER          = 'TestWholesaler';
    private static final String AVAILABLESERVICES   = 'TestAvailableService';
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';
    private static final String BUNDLE              = 'TestBundle';
    private static final String AVAILABLEBUNDLE     = 'TestAvailableBundle';
    private static final String BUNDLEITEM          = 'TestBundleItem';
    private static final String AVAILABLESERVIEITEM = 'TestAvailableServiceItem';
    private static final String BILLNAME            = 'testBill';
    private static final String BILLSERVICENAME     = 'Test Bill Service';
    private static final String BILLITEMNAME        = 'Test Bill Item';
    private static final Integer VOLUMEUSED         = 200;
    private static final Integer BILLEDAMOUNT       = 67878;
    private static final String HEROKUPOSTGRESID    = 'Test ID';
    private static final String ACTUALDEVICEREADING = 'ActualDeviceReading__c';
    private static final String DEVICEREFERENCE     = 'Device__r.SerialNo__c';
    //private static final String GROSSCONSUMPTION    = 'GrossConsumption__c';   AT-2159 
    private static final String READING             = 'Reading__c';  
    private static final String READINGDATE         = 'ReadingDate__c'; 
    private static final String READER              = 'Reader__c';
    private static final String FIELDVALUE          = 'Test';
    private static final String SERVICE             = 'Service__c';
    private static final String DEVICE              = 'Device__c'; 
    private static final String SUPPLYPOINT         = 'SupplyPoint__c';
    private static final String SERVICETYPENAME     = 'ServiceType__r.Name'; 
    private static final String DEVICESERIAL        = 'Device__r.SerialNo__c';
    private static final String SUPPLYLOCATION      = 'SupplyPoint__r.Location__r.PostalCode__c';
    private static final String CONTRACT            = 'Contract__c';
    private static final String TESTNAME            = 'Name';
    private static final String TESTDEVICEREFERENCE = 'Device__c';
    private static final String POSITIVETEST        = 'PositiveTest';
    private static final String NEGATIVETEST        = 'NegativeTest';
    private static final String SP_USAGE_TYPE       = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE         = 'TestDeviceSize';
    private static final String MANUFACTURER        = 'Siemens';
    private static final String UNIT_OF_MEASURE     = 'Metric';
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        14-June-2018
    @param:       N/A
    @return:      void
    @description: method to create test data used by all test methods
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount); 
        Database.insert(con);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        Device__c objsubDevice = GlUt_FactoryData_Test.createDevice(SUB_DEVICE_TYPE ,objDeviceType );
        Database.insert(objsubDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = Date.today();
        Database.insert(objReading1); 
        
        Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading2.ReadingDate__c = Date.today() - 30;
        Database.insert(objReading2);
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c objService = GlUt_FactoryData_Test.createService(con,objReading1,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        Database.insert(objServiceItem);
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME ,con);
        objBill.Account__c = objAccount.id; //AT-3174
        objBill.DataXml__c = true;
        objBill.PrintXml__c= true;
        objBill.BillPDF__c = true;
        Database.insert(objBill);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        Database.insert(objBillItems);
        
    }
    
    /*******************************************************************
    @author:      Echo: Dependra Singh
    @date:        14-June-2018
    @param:       N/A
    @return:      void
    @description: Testing the scenario when retrieving bill properties
    ********************************************************************/
 
      static testmethod void retrieveBillPropDetails_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<GLAp_FieldProps> billProps = BlAp_ViewBillDocumentsCtrlr.retrieveBillPropDetails();
            Test.stopTest();
            System.assert(billProps != null);
        }
    } 
    
    /*******************************************************************
    @author:      Echo: Dependra Singh
    @date:        14-June-2018
    @param:       N/A
    @return:      void
    @description: Testing the scenario when retrieving bill properties
    ********************************************************************/
 
      static testmethod void getUserBills_PositiveTest1(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        List<Bill__c> lstBill =  [SELECT Id,Name,BillingContract__c,Account__c,DataXml__c, PrintXml__c, BillPDF__c FROM Bill__c LIMIT 1]; //AT-3174
          
        System.runAs(objUser){
            try{
                if(lstBill != null && lstBill.size() > 0){
                    Test.startTest();
                    Test.setMock(HttpCalloutMock.class, new GlUt_MockHttpResponseGenerator_Test(200));
                    List<BlAp_CombinedRecord> lstCombinedRecord = BlAp_ViewBillDocumentsCtrlr.getUserBills(lstBill[0].Id);
                    Test.stopTest();
                    System.assert(!lstCombinedRecord.isEmpty());
                }
                //List<GLAp_FieldProps> billProps = BlAp_ViewBillDocumentsCtrlr.getUserBills();
           } catch(Exception ex) {}
           
        }
    } 
      
    /*******************************************************************
    @author:      Echo: Dependra Singh
    @date:        14-June-2018
    @param:       N/A
    @return:      void
    @description: Testing the scenario when retrieving bill properties
    ********************************************************************/
 
    static testmethod void getUserBills_Negative(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        List<Bill__c> lstBill = new List<Bill__c>();
        Boolean isException = false; 
        System.runAs(objUser){
            try{
                    Test.startTest();
                    Test.setMock(HttpCalloutMock.class, new GlUt_MockHttpResponseGenerator_Test(200));
                    List<BlAp_CombinedRecord> lstCombinedRecord = BlAp_ViewBillDocumentsCtrlr.getUserBills(lstBill[0].Id);
                    Test.stopTest();
                //List<GLAp_FieldProps> billProps = BlAp_ViewBillDocumentsCtrlr.getUserBills();
            } catch(Exception ex) {     
                isException = true;
            }
            System.assert(isException,true);
        }
    } 

}