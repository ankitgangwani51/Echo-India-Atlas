/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        14 June 2018
@description: Test Class for BlBt_BillDataTransferXMLExtract 
*******************************************************************************/
@isTest
public class BlBt_BillDataTransferXMLExtract_Test {

    private static final String PDF_TEMPLATE_NAME = 'pdfTemplateName';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestXmlExtractUser'; 
    private static final String ACCOUNT_NAME = 'TestAccount_BlBt_BillDataTransferXMLExtract'; 
    private static final String CONTRACT_NAME ='TestContract';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'Test Street';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String BILLNAME = 'testBill';
    private static final String USERNAMECOMPLETE = USER_NAME+ '@unitest.com';
    private static final String ACCEMAIL = 'test78887@abc.com';
    private static final String ACCFAX = '8888777767';
    private static final String ACCVAT = '786654';
    private static final String ACCWEBSITE = 'www.testAcc988.com';
    private static final String STATE = 'Test State';
    private static final String CITY = 'Test City';
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';
    private static final String BUNDLE              = 'TestBundle';
    private static final String BUNDLEITEM          = 'TestBundleItem';
    private static final String BILLSERVICETYPE = 'testBillServiceType';
    private static final String BILLITEM = 'testBillItem';
    private static final Integer VOLUMEUSED = 100;
    private static final Integer BILLEDAMOUNT = 567;
    private static final String POSTCODE = 'WS4 EB6';
    private static final String COUNTRY = 'UK';
    private static final String XMLTEMPNAME = '<pdfTemplateName>pdfTemplateName</pdfTemplateName>';
    private static final String XMLBILLDETAIL = '<objectApiName>'+GlUt_NamespacePrefix.getNamespacePrefix()+'Bill__c</objectApiName><field><apiName>Name</apiName><value>testBill</value></field>';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String BATCHCLASS = 'BlBt_BillDataTransferXMLExtract';
    private static final String BATCHREQQUEUEINITIALISEDSTATUS = 'Initialised';
    private static final String TESTREGION = 'Test Region';
    
   
    /*******************************************************************
    @author: Echo: Mohit Tayal
    @date:   14 June 2018
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/    
    @testSetup
    static void createTestData(){
        
        //Insert user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        //objUser.UserPermissionsSFContentUser = true;
        Database.insert(objUser);
        Database.update(objUser);
        
        //Insert account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount.Email__c = ACCEMAIL;
        objAccount.Fax = ACCFAX;
        objAccount.Website = ACCWEBSITE;
        Database.insert(objAccount);
        
        //Insert contract record
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        con.BillingStreet__c = STREET;
        con.BillingCity__c = CITY;
        con.BillingState__c = STATE;
        con.BillingPostalCode__c = POSTCODE;
        con.BillingCountry__c = COUNTRY;
        Database.insert(con);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Insert device record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        //Insert service type record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        //Insert list of readings
        List<Reading__c>  objReadingList = new List<Reading__c>();
        for(integer i=0; i<=1; i++){
            Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
            objReadingList.add(objReading);
        }
        objReadingList[0].ReadingDate__c = System.today().addDays(-10);
        objReadingList[1].ReadingDate__c = System.today().addDays(-5);
        Database.insert(objReadingList);
        
        //Insert location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        objLocation.Inactive__c = true;
        objLocation.InactiveDate__c = System.today();
        Database.insert(objLocation);

        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Insert supply point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        //Insert supply point device record
        SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
        
        //Insert division record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        //Insert wholesaler record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Insert available service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Insert service record
        Service__c  objService = GlUt_FactoryData_Test.createService(con,objReadingList[0],objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
             
        //Insert bill record
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME ,con);
        objBill.StartDate__c = system.today().addDays(-10);
        objBill.EndDate__c =system.today().addDays(-5);
        objBill.Account__c = objAccount.id; //AT-3174
        objBill.DataXml__c = false;
        objBill.BillType__c = BlBt_Constants.BILL_TYPE_NORMAL;
        Database.insert(objBill);
      
        /*** AT-3166 **/
   
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle('', objBundle, objAvailableService);
        Database.insert(objAvailableBundle);
        
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem('', objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);
              
        DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
        Database.insert(objDischargeAgreement);   
        
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.DischargeAgreement__c = objDischargeAgreement.Id;
        Database.insert(objServiceItem);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICETYPE, objBill, 'id123');
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEM, objServiceItem, VOLUMEUSED, BILLEDAMOUNT, objBillServiceType, 'id123');
        objBillItem.Bill__c = objBill.Id;
        objBillItem.Reading__c = objReadingList[1].Id;
        Database.insert(objBillItem);  
       /** AT-3166 **  ENDS*/
        
     	
        AWSBucketSettings__c objCustomSetting = new AWSBucketSettings__c(
        Name = GlUt_AWSConstants.ECHODATATRANSFERXMLS3BUCKET, DistributionURL__c = BlBt_Constants.DISTRIBUTIONURL , Endpoint__c = BlBt_Constants.ENDPOINT , Region__c =  BlBt_Constants.REGION);
        Database.insert(objCustomSetting);
        

        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCHCLASS);
        Database.insert(objBatchProcess);
        
        
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.BatchProcess__c = objBatchProcess.Id;
        objBatchRequestQueue.Status__c = BATCHREQQUEUEINITIALISEDSTATUS;
        Database.insert(objBatchRequestQueue);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;

   } 
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        14 June 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for execute
    ********************************************************************/
    static testmethod void execute_PositiveTest(){
        User objUser = [SELECT Id,UserPermissionsSFContentUser FROM User WHERE IsActive = True AND Username =: USERNAMECOMPLETE LIMIT 1];
        system.debug('objUser-----'+objUser);
        BatchRequestQueue__c objBatchRequestQueue = [SELECT Id, Status__c FROM BatchRequestQueue__c LIMIT 1];
        System.runAs(objUser){
            Test.setMock(HttpCalloutMock.class, new BlBt_MockHttpBillDataTransferXML_Test());
            Test.startTest();
            
            BlBt_BillDataTransferXMLExtract objBillDataTransferXMLExtract = new BlBt_BillDataTransferXMLExtract();
            objBillDataTransferXMLExtract.initialise(objBatchRequestQueue);
            Database.executeBatch(new BlBt_BillDataTransferXMLExtract(), 200);            
            Test.stopTest();
            System.assertEquals(objBatchRequestQueue.Status__c,BlBt_Constants.BRQCOMPLETEDSTATUS);
            
            
        }
    }   
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        14 June 2018
    @param:       N/A
    @return:      void
    @description: Negative Test scenario for execute
    ********************************************************************/
    static testmethod void execute_NegativeTest(){
        User objUser = [SELECT Id,UserPermissionsSFContentUser FROM User WHERE IsActive = True AND Username =: USERNAMECOMPLETE LIMIT 1];
        system.debug('objUser-----'+objUser);
        BatchRequestQueue__c objBatchRequestQueue = new BatchRequestQueue__c();
        System.runAs(objUser){
            Test.setMock(HttpCalloutMock.class, new BlBt_MockHttpBillDataTransferXML_Test());
            Test.startTest();
            
            BlBt_BillDataTransferXMLExtract objBillDataTransferXMLExtract = new BlBt_BillDataTransferXMLExtract();
            objBillDataTransferXMLExtract.initialise(objBatchRequestQueue);
            Database.executeBatch(new BlBt_BillDataTransferXMLExtract(), 200);            
            Test.stopTest();
            System.assert(objBatchRequestQueue.Status__c == null);
        }
    }   
}