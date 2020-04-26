/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        08 September 2017
@description: Test Class for BlIn_PDFPrepareBillData 
*******************************************************************************/

@isTest
//test data creation for BlIn_PDFPrepareBillData class
Public Class BlIn_PDFPrepareBillData_Test{
    public static final String PDF_TEMPLATE_NAME = 'pdfTemplateName';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='TestUser'; 
    private static String ACCOUNT_NAME = 'TestAccount'; 
    private static String CONTRACT_NAME ='TestContract';
    private static String DEVICE_NAME = 'TestDevice';
    private static String DEVICE_TYPE ='TestDeviceType';
    private static String SUB_DEVICE_TYPE ='TestSubDevice';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static String SERVICEITEMTYPE ='TestServiceitemtype';
    private static String BUNDLE ='TestBundle';
    private static String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String SITESAMPLE ='Testsitesample';
    private static String SAMPLE ='TestSample';
    private static String AGREERATE ='TestAgreeRate';
    private static String BILLNAME = 'testBill';
    private static String BILLSERVICENAME = 'Test Bill Service';
    private static String BILLITEMNAME = 'Test Bill Item';
    private static String PAYMENTPLANNAME = 'Test Payment Plan Type';
    private static Integer VOLUMEUSED = 200;
    private static Integer BILLEDAMOUNT = 67878;
    private static String HEROKUPOSTGRESID = 'Test ID';
    private static Integer PLANAMOUNT = 56557;
    private static Integer NUMBEROFINSTALMENTS =12;     
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final Integer SAMPLE_STRENGTH_NUMBER = 100;
    /*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c con = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME,objAccount); 
        Database.insert(con);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        Device__c objsubDevice = GlUt_FactoryData_Test.CreateDevice(SUB_DEVICE_TYPE ,objDeviceType );
        //Database.insert(objsubDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        //Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        //Database.insert(objReading);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = Date.today();
        Database.insert(objReading1); 
        
        Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading2.ReadingDate__c = Date.today() - 30;
        Database.insert(objReading2);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);

        // Create Main Supply Point
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Sub Supply Point
        SupplyPoint__c  objSubSP = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSubSP.Measured__c= True; // AT-3174 
        Database.insert(objSubSP);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        SupplyPointDevice__c  objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(con,objReading1,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        Database.insert(objServiceItem);
        
        // Commented by Ankit Gangwani for task - AT-2926, 22 June 2018  
        //DeviceRelationship__c  objDeviceRelationship = GlUt_FactoryData_Test.CreateDeviceRelationship(objDevice,objsubDevice);
        //Database.insert(objDeviceRelationship);
        
        SupplyPointRelationship__c objSupplyPointRelationship = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPoint, objSubSP);
        Database.insert(objSupplyPointRelationship);
        
        //Create Discharge Agreement Record
        DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
        Database.insert(objDischargeAgreement);
        
        Sample__c  objSample =GlUt_FactoryData_Test.CreateSample(SAMPLE);
        objSample.DischargeAgreement__c = objDischargeAgreement.Id;
        objSample.CODSampleStrength__c = SAMPLE_STRENGTH_NUMBER;
        objSample.SampleCollectionDate__c = Date.today();
        Database.insert(objSample);
        
        AgreedRate__c  objAgreedRate =GlUt_FactoryData_Test.CreateAgreedRate(AGREERATE,objServiceItem);
        Database.insert(objAgreedRate);
        
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,con);
        objBill.Account__c = objAccount.id; //AT-3174
        Database.insert(objBill);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        Database.insert(objBillItems);
        
        /*PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANNAME);
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,con,PLANAMOUNT);
        Database.insert(objPaymentPlan);*/
        
    }
    
/*******************************************************************
Purpose: Method to test object node added to the XML parent {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void addToXmlDoc_Positive(){
        
        User objUser =[select id,name from user where isActive=true limit 1];
        Bill__c objBill =[Select id from Bill__c limit 1];
        system.runas(objUser){
        Test.startTest();
        BlIn_PDFPrepareBillData objBlInPDFPrepareBillData = new BlIn_PDFPrepareBillData(objBill.id, PDF_TEMPLATE_NAME);
        Test.stopTest();
        system.assertNotEquals(null,objBlInPDFPrepareBillData);
        }

    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        13 Sept 2018
	@description: Method to test addToXmlDoc for BlIn_PDFPrepareBillData In Negative Scenario		
	*******************************************************************************/
    static testmethod void addToXmlDoc_Negative(){
        
        User objUser = [select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            Test.startTest();
            BlIn_PDFPrepareBillData objBlInPDFPrepareBillData = new BlIn_PDFPrepareBillData(NULL, PDF_TEMPLATE_NAME);
            Test.stopTest();
            system.assertNotEquals(null,objBlInPDFPrepareBillData);
        }
    }
}