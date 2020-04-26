/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        08 September 2017
@description: Test Class for BlIn_ExecutePDFGeneration
Revision(s):  Shivangi Gaur -- 10-Jan-2018 -- Incorporated review comments on AT-444 
                                              dated 04-Jan-2018
*******************************************************************************/
@isTest
//test data creation for BlIn_ExecutePDFGeneration class
public class BlIn_ExecutePDFGeneration_Test{
 
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static final string TESTPDF = 'Test PDF';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String BILLNAME = 'testBill';
    private static final String CONTRACT_NAME ='TestContract';
    private static final String ACCEMAIL = 'test78887@abc.com';
    private static final String ACCFAX = '8888777767';
    private static final String ACCVAT = '786654';
    private static final String ACCWEBSITE = 'www.testAcc988.com';
    private static final String STATE = 'Test State';
    private static final String CITY = 'Test City';
    private static final String POSTCODE = 'WS4 EB6';
    private static final String COUNTRY = 'UK';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String TESTREGION = 'Test Region';
    
    private static string authToken ='AHSHGHSGSCSDS#$@CS';
    private static final String BILLINGRESPONSEMOCKPOSITIVE = 'GlUt_MockTransferXMLResponseContainer';
    private static final String BILLINGRESPONSEMOCKNEGATIVE = 'GlUt_MockTransferXMLResponseContainerNegative';
   
/*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    static void createTestData(){
        
        //Insert user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);
        
        //Insert custom setting data for heroku security
        HerokuSecurity__c  herSecurity = GlUt_FactoryData_Test.createHerokuSecurity(authToken );
        Database.insert(herSecurity );
            
        //Insert account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount.Email__c = ACCEMAIL;
        objAccount.Fax = ACCFAX;
        objAccount.Website = ACCWEBSITE;
        Database.insert(objAccount);
        BillTemplate__c objBillTemplate = GlUt_FactoryData_Test.createBillTemplate(TESTPDF);
        objBillTemplate.FileName__c = TESTPDF;
        DataBase.insert(objBillTemplate);
        //Insert contract record
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        con.BillingStreet__c = STREET;
        con.BillingCity__c = CITY;
        con.BillingState__c = STATE;
        con.BillingPostalCode__c = POSTCODE;
        con.BillingCountry__c = COUNTRY;
        con.BillTemplate__c = objBillTemplate.id;
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
        
        //Insert Supply Point Usage Type Record
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
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint
                                                                                                ,objWholesaler);
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
        
        AWSBucketSettings__c objCustomSetting = new AWSBucketSettings__c(
            Name = GlUt_AWSConstants.ECHODATATRANSFERXMLS3BUCKET, DistributionURL__c = 'https://d29bzvld9lg0l9.cloudfront.net', Endpoint__c = 'https://echo-data-transfer-xml.s3.amazonaws.com', Region__c = 'eu-west-1');
        Database.insert(objCustomSetting);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
        
        
    }
    
/*******************************************************************
Purpose: Method to test HEROKU callout to generate a PDF {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/   
    static testMethod void executePDF_Positive(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Bill__c objBill =[Select id from Bill__c limit 1];
        System.runAs(objUser){
            try {
                Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));
                String pdfId = BlIn_ExecutePDFGeneration.ExecutePDF(objBill.Id);
                Test.stopTest();
                
                system.assert(objBill.Id!=null);
                system.assert(pdfId != null);
            } catch(Exception ex) {}
        }
        
    }

/*******************************************************************
Purpose: Method to test HEROKU callout to generate a PDF {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testMethod void executePDF_Negative(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Bill__c objBill =[Select id from Bill__c limit 1];
        boolean isException = false;
        String pdfIdRespErr;
        System.runAs(objUser){
            
            try{
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKNEGATIVE));
                pdfIdRespErr = BlIn_ExecutePDFGeneration.executePDF(objBill.Id);
                Test.stopTest();    
            }
            catch(exception e){
                isException = true;
                system.assert(e.getmessage()!=null);    
            }
            System.assertEquals(pdfIdRespErr.contains('The pdf generation request returned an error'),TRUE);
        }
    }
/*******************************************************************
Purpose: Method to test HEROKU callout to generate a PDF {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/   
    static testMethod void executePDFNull_Negative(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Bill__c objBill =[Select id from Bill__c limit 1];
        boolean isException = false;
        Id pdfIdRespErr;
        System.runAs(objUser){
            try{
                
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKNEGATIVE));
                pdfIdRespErr = BlIn_ExecutePDFGeneration.executePDF(null);
                Test.stopTest();
                
            }
            catch(exception e){
                isException = true;
                system.assert(e.getmessage()!=null);    
            }
            
            System.assertEquals(pdfIdRespErr,null);
        }
    }
}