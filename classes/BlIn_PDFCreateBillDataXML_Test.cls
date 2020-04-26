/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        06 September 2017
@description: Test Class for BlIn_PDFCreateBillDataXML
Revision(s):  Updated method createXML_Positive().
              Shivangi Gaur -- 22-Dec-2017 -- Incorporated review comments on AT-442 
                                              dated 21-Dec-2017.
              Shivangi Gaur -- 05-Jan-2018 -- Incorporated review comments on AT-442 
                                              dated 03-Jan-2018.
*******************************************************************************/
@isTest
//test data creation for BlIn_PDFCreateBillDataXML  class
public class BlIn_PDFCreateBillDataXML_Test{
    
    private static final String PDF_TEMPLATE_NAME = 'pdfTemplateName';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String ACCOUNT_NAME = 'TestAccount'; 
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
    private static final String POSTCODE = 'WS4 EB6';
    private static final String COUNTRY = 'UK';
    private static final String XMLTEMPNAME = '<pdfTemplateName>pdfTemplateName</pdfTemplateName>';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
   
   /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    
    @TestSetup
    static void createTestData(){
        
        //Insert user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser);
        
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
        objSupplyPoint.Measured__c = TRUE ;
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
        Database.insert(objBill);
    }
    
    /******************************************************************
    Purpose: Method to test addToXmlDoc() positive scenario.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void createXML_Positive(){
        
        User objUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Bill__c objBill =[Select id, Name from Bill__c limit 1];
        String XMLBILLDETAIL = (objBill == Null) ? '' : '<objectApiName>'+GlUt_NamespacePrefix.getNamespacePrefix()+'Bill__c</objectApiName><field><apiName>Name</apiName><value>' +objBill.Name +'</value></field>';
        
        System.runAs(objUser){
            
            Test.startTest();
            BlIn_PDFPrepareBillData objBlInPDFPrepareBillData = new BlIn_PDFPrepareBillData(objBill.id,PDF_TEMPLATE_NAME);
            BlIn_PDFCreateBillDataXML objBlIn_PDFCreateBillDataXML = new BlIn_PDFCreateBillDataXML(objBlInPDFPrepareBillData.billData);
            Test.stopTest();
            System.assertNotEquals(null,objBlIn_PDFCreateBillDataXML);
            //Asserts to check properties of XML generated
            System.assertEquals(objBlIn_PDFCreateBillDataXML.XMLDocument.toXMLString().contains(XMLTEMPNAME),true);
            System.assertEquals(objBlIn_PDFCreateBillDataXML.XMLDocument.toXMLString().contains(XMLBILLDETAIL),true);
        }
    }
/*******************************************************************
Purpose: Method to test addToXmlDoc() positive scenario negative scenario 
         where XML record is not created.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void createXML_Negative(){
        
        User objUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Bill__c objBill =[Select id from Bill__c limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            try{
                BlIn_PDFPrepareBillData objBlInPDFPrepareBillData = new BlIn_PDFPrepareBillData(objBill.id,null);
                BlIn_PDFCreateBillDataXML objBlIn_PDFCreateBillDataXML = new BlIn_PDFCreateBillDataXML(objBlInPDFPrepareBillData.billData);
            }
            catch(Exception exc){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(true,isException);
        }
    }
/*******************************************************************
Purpose: Method to test addToXmlDoc() positive scenario negative scenario 
         where BlIn_PDFPrepareBillData is not passed/ is null.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void createXMLWithNullParameters_Negative(){
        
        User objUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            try{
                BlIn_PDFCreateBillDataXML objBlIn_PDFCreateBillDataXML = new BlIn_PDFCreateBillDataXML(null);
            }
            catch(Exception exc){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(true,isException);
        }
    }


}