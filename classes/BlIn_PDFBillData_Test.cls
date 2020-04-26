/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        25 September 2017
@description: Test Class for BlIn_PDFBillData 
@revision:    MT - made changes as per the review comments of 21/12/2017
*******************************************************************************/

@isTest
//test data creation for BlIn_PDFBillData class
public class BlIn_PDFBillData_Test{
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
    //private static final String GROSSCONSUMPTION    = 'GrossConsumption__c';  AT-2159
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
    private static final String CONTRACT            = 'BillingContract__c';
    private static final String TESTNAME            = 'Name';
    private static final String TESTDEVICEREFERENCE = 'Device__c';
    private static final String POSITIVETEST        = 'PositiveTest';
    private static final String NEGATIVETEST        = 'NegativeTest';
    private static final String SP_USAGE_TYPE       = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE         = 'TestDeviceSize';
    private static final String MANUFACTURER        = 'Siemens';
    private static final String UNIT_OF_MEASURE     = 'Metric';
    
    /*******************************************************************
    @author:      Accenture: Sucharu Gupta
    @date:        25 September 2017
    @param:       N/A
    @return:      void
    @description: method to create test data used by all test methods
    @revision:    MT - created supply point device record and reading record
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
        Database.insert(objBill);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        Database.insert(objBillItems);
        
    }
    
/*******************************************************************
@author:      Accenture: Sucharu Gupta
@date:        25 September 2017
@param:       N/A
@return:      void
@description: Testing the scenario for adding the child details if the 
              child name is present in the xml
@revision:    MT - Make a call to addChildRecordTestData method to create the test data
********************************************************************/
 
      static testmethod void addChildRecord_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        List<BlIn_PDFBillData.XMLRecord> objXMLRecords = addChildRecordTestData(POSITIVETEST);
    
        System.runAs(objUser){
            Test.startTest();
            BlIn_PDFBillData objPDF = new BlIn_PDFBillData();
            Boolean b = objPDF.addChildRecord(objXMLRecords[0],objXMLRecords[1]);
            Test.stopTest();
            System.assertEquals(True,b);
        }
    } 
    
    /*******************************************************************
    @author:      Accenture: Sucharu Gupta
    @date:        25 September 2017
    @param:       N/A
    @return:      void
    @description: Testing the scenario for adding the child details if the 
                  child name is not present in the xml
    @revision:    MT - Make a call to addChildRecordTestData method to create the test data
    ********************************************************************/
 
    static testmethod void addChildRecord_NegativeTest(){
        User objUser =[SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        List<BlIn_PDFBillData.XMLRecord> objXMLRecords = addChildRecordTestData(NEGATIVETEST);
                
        System.runAs(objUser){
            Test.startTest();
            BlIn_PDFBillData objPDF = new BlIn_PDFBillData();
            Boolean b = objPDF.addChildRecord(objXMLRecords[0],objXMLRecords[1]);
            Test.stopTest();
            System.assertNotEquals(False,b);
        }
    }
    
/*******************************************************************
@author:      Echo: Mohit Tayal
@date:        29 December 2017
@param:       Accepts the string to determine whether to create data for positive
              or negative scenario.
@return:      Returns the xml and the record to add in the xml
@description: Creating the test data for the positive and negative scenario
              of addChildRecord method
********************************************************************/    
    
    static List<BlIn_PDFBillData.XMLRecord> addChildRecordTestData(String testcase){
        
        Service__c  objService = [SELECT Id, Name FROM Service__c LIMIT 1 ];
        Reading__c  objReading = [SELECT Id FROM Reading__c LIMIT 1 ];
        
        // Parent Record Data
        
        Set<String> idFields1 = new Set<String>{};
        //Set<String> xmlFields1 = new Set<String>{ACTUALDEVICEREADING,DEVICEREFERENCE,GROSSCONSUMPTION, READING,READINGDATE,READER}; AT-2159
        Set<String> xmlFields1 = new Set<String>{ACTUALDEVICEREADING,DEVICEREFERENCE,READING,READINGDATE,READER};
        Map<String, String> fieldMap1 = new Map<String, String>();
        fieldMap1.put(READER, FIELDVALUE);
        fieldMap1.put(SERVICE, objService.Name);
        Set<Id> parentIds1 = new Set<Id>{objReading.Id};
        
        //Record To Add Data
        
        Set<String> idFields2 = new Set<String>{DEVICE,SUPPLYPOINT};
        Set<String> xmlFields2 = new Set<String>{SERVICETYPENAME,DEVICESERIAL, SUPPLYLOCATION};
        Map<String, String> fieldMap2 = new Map<String, String>();
        fieldMap2.put(SERVICETYPENAME,FIELDVALUE);
        Set<Id> parentIds2 = new Set<Id>{objReading.Id, objService.Id};
        
        BlIn_PDFBillData.XMLObject objXML2 = new BlIn_PDFBillData.XMLObject(SERVICE,CONTRACT,CONTRACT,idFields2, xmlFields2);
        
        BlIn_PDFBillData.XMLRecord objXMLRecord2 = new BlIn_PDFBillData.XMLRecord(objXML2);
        
        List<BlIn_PDFBillData.XMLRecord> xmlLst2 = new List<BlIn_PDFBillData.XMLRecord>();
        xmlLst2.add(objXMLRecord2);
        
        Map<String,List<BlIn_PDFBillData.XMLRecord>> objectListMap2 = new Map<String,List<BlIn_PDFBillData.XMLRecord>>();
        objectListMap2.put(TESTNAME, xmlLst2);
        
        objXMLRecord2.name = objXML2.name;
        objXMLRecord2.parentName = objXML2.parentName;
        objXMLRecord2.fieldMap = fieldMap2;
        objXMLRecord2.parentIds = parentIds2;
        objXMLRecord2.objectListMap = objectListMap2;
        objXMLRecord2.parentLookup = objReading.Id;
        
        //End of Child XML Record
        
        BlIn_PDFBillData.XMLObject objXML1 = new BlIn_PDFBillData.XMLObject(READING,SERVICE,TESTDEVICEREFERENCE, idFields1, xmlFields1);
        
        BlIn_PDFBillData.XMLRecord objXMLRecord1 = new BlIn_PDFBillData.XMLRecord(objXML1);
        
        List<BlIn_PDFBillData.XMLRecord> xmlLst1 = new List<BlIn_PDFBillData.XMLRecord>();
        xmlLst1.add(objXMLRecord1);
        
        Map<String,List<BlIn_PDFBillData.XMLRecord>> objectListMap1 = new Map<String,List<BlIn_PDFBillData.XMLRecord>>();
        if (testcase == NEGATIVETEST){
            objectListMap1.put(READING, xmlLst2);
        } else{
            objectListMap1.put(SERVICE, xmlLst1); 
        }
        objXMLRecord1.name = objXML1.name;
        objXMLRecord1.parentName = objXML1.parentName;
        objXMLRecord1.fieldMap = fieldMap1;
        objXMLRecord1.parentIds = parentIds1;
        objXMLRecord1.objectListMap = objectListMap1;
        
        List<BlIn_PDFBillData.XMLRecord> objXMLRecords = new List<BlIn_PDFBillData.XMLRecord>();
        objXMLRecords.add(objXMLRecord1);
        objXMLRecords.add(objXMLRecord2);
        return objXMLRecords;
    }
    
    /*******************************************************************
    @author:      Accenture: Sucharu Gupta
    @date:        25 September 2017
    @param:       N/A
    @return:      void 
    @description: Method to test record's parent in the XML data structure
                  is correct or not
    ********************************************************************/
 
    static testmethod void addChildRecord_Test(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Set<String> idFields1 = new Set<String>();
        Set<String> xmlFields1 = new Set<String>();
        Map<String, String> fieldMap1 = new Map<String, String>();
        Set<Id> parentIds1 = new Set<Id>();
        
        //Adding child Xml Record
        
        Set<String> idFields2 = new Set<String>();
        Set<String> xmlFields2 = new Set<String>();
        Map<String, String> fieldMap2 = new Map<String, String>();
        Set<Id> parentIds2 = new Set<Id>();
        
        BlIn_PDFBillData.XMLObject objXML2 = new BlIn_PDFBillData.XMLObject(SERVICE,CONTRACT,CONTRACT, idFields2, xmlFields2);
        
        BlIn_PDFBillData.XMLRecord objXMLRecord2 = new BlIn_PDFBillData.XMLRecord(objXML2);
        
        List<BlIn_PDFBillData.XMLRecord> xmlLst2 = new List<BlIn_PDFBillData.XMLRecord>();
        
        Map<String,List<BlIn_PDFBillData.XMLRecord>> objectListMap2 = new Map<String,List<BlIn_PDFBillData.XMLRecord>>();
        
        objXMLRecord2.name = objXML2.name;
        objXMLRecord2.parentName = objXML2.parentName;
        objXMLRecord2.fieldMap = fieldMap2;
        objXMLRecord2.parentIds = parentIds2;
        objXMLRecord2.objectListMap = objectListMap2;
        
        //End of Child XML Record
        
        BlIn_PDFBillData.XMLObject objXML1 = new BlIn_PDFBillData.XMLObject(READING,SERVICE, TESTDEVICEREFERENCE, idFields1, xmlFields1);
        
        BlIn_PDFBillData.XMLRecord objXMLRecord1 = new BlIn_PDFBillData.XMLRecord(objXML1);
        
        List<BlIn_PDFBillData.XMLRecord> xmlLst1 = new List<BlIn_PDFBillData.XMLRecord>();
        
        Map<String,List<BlIn_PDFBillData.XMLRecord>> objectListMap1 = new Map<String,List<BlIn_PDFBillData.XMLRecord>>();
        objXMLRecord1.name = objXML1.name;
        objXMLRecord1.parentName = objXML1.parentName;
        objXMLRecord1.fieldMap = fieldMap1;
        objXMLRecord1.parentIds = parentIds1;
        objXMLRecord1.objectListMap = objectListMap1;
        
        System.runAs(objUser){
            Test.startTest();
            BlIn_PDFBillData objPDF = new BlIn_PDFBillData();
            Boolean b = objPDF.addChildRecord(objXMLRecord1,objXMLRecord2);
            Test.stopTest();
            System.assertEquals(False,b);
        }
    }

    /*******************************************************************
    @author:      Accenture: Sucharu Gupta
    @date:        25 September 2017
    @param:       N/A
    @return:      void
    @description: Method to test object node added to the XML parent {Positive scenario}
    @revision:    MT - Change the method name from addObjectRecord_PositiveTest 
                  to BlIn_PDFPrepareBillData_PositiveTest as this is calling the 
                  constructor of this BlIn_PDFPrepareBillData class  
    ********************************************************************/
    static testmethod void BlIn_PDFPrepareBillData_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Bill__c objBill = [SELECT Id FROM Bill__c LIMIT 1];
        System.runAs(objUser){
        Test.startTest();
        BlIn_PDFPrepareBillData objBlInPDFPrepareBillData = new BlIn_PDFPrepareBillData(objBill.Id, PDF_TEMPLATE_NAME);
        Test.stopTest();
        System.assertNotEquals(null,objBlInPDFPrepareBillData);
        System.assert(objBlInPDFPrepareBillData.billData != null); 
        System.assert(objBlInPDFPrepareBillData.billData.XMLObjectRecords.size() > 0);
        }
    }
    
    /*******************************************************************
    @author:      Accenture: Sucharu Gupta
    @date:        25 September 2017
    @param:       N/A
    @return:      void
    @description: Method to test object node added to the XML parent {Negative scenario}
    ********************************************************************/
 
    static testmethod void addObjectRecord_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Set<String> idFields1 = new Set<String>();
        Set<String> xmlFields1 = new Set<String>();
        Map<String, String> fieldMap1 = new Map<String, String>();
        Set<Id> parentIds1 = new Set<Id>();
        
        //Adding child Xml Record
        
        Set<String> idFields2 = new set<String>();
        Set<String> xmlFields2 = new Set<String>();
        Map<String, String> fieldMap2 = new Map<String, String>();
        Set<Id> parentIds2 = new Set<Id>();
        
        BlIn_PDFBillData.XMLObject objXML2 = new BlIn_PDFBillData.XMLObject(SERVICE,CONTRACT,CONTRACT, idFields2, xmlFields2);
        
        BlIn_PDFBillData.XMLRecord objXMLRecord2 = new BlIn_PDFBillData.XMLRecord(objXML2);
        
        List<BlIn_PDFBillData.XMLRecord> xmlLst2 = new List<BlIn_PDFBillData.XMLRecord>();
        
        Map<String,List<BlIn_PDFBillData.XMLRecord>> objectListMap2 = new Map<String,List<BlIn_PDFBillData.XMLRecord>>();
        
        objXMLRecord2.name = objXML2.name;
        objXMLRecord2.parentName = objXML2.parentName;
        objXMLRecord2.fieldMap = fieldMap2;
        objXMLRecord2.parentIds = parentIds2;
        objXMLRecord2.objectListMap = objectListMap2;
        
        //End of Child XML Record
        
        BlIn_PDFBillData.XMLObject objXML1 = new BlIn_PDFBillData.XMLObject(READING,SERVICE,TESTDEVICEREFERENCE, idFields1, xmlFields1);
        
        BlIn_PDFBillData.XMLRecord objXMLRecord1 = new BlIn_PDFBillData.XMLRecord(objXML1);
        
        List<BlIn_PDFBillData.XMLRecord> xmlLst1 = new List<BlIn_PDFBillData.XMLRecord>();
        
        Map<String,List<BlIn_PDFBillData.XMLRecord>> objectListMap1 = new Map<String,List<BlIn_PDFBillData.XMLRecord>>();
        objXMLRecord1.name = objXML1.name;
        objXMLRecord1.parentName = objXML1.parentName;
        objXMLRecord1.fieldMap = fieldMap1;
        objXMLRecord1.parentIds = parentIds1;
        objXMLRecord1.objectListMap = objectListMap1;
        
        System.runAs(objUser){
            Test.startTest();
            BlIn_PDFBillData objPDF = new BlIn_PDFBillData();
            Boolean b = objPDF.addObjectRecord(objXMLRecord2);
            Test.stopTest();
            System.assertNotEquals(True,b);
        }
    }

}