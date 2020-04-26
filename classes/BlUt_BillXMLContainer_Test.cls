/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        15 June 2018
@description: Test Class for BlUt_BillXMLContainer 
*******************************************************************************/
@isTest
public class BlUt_BillXMLContainer_Test {

    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME ='TestContract';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'Test Street';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String BILLNAME = 'testBill';
    private static final String BILLNAME1 = 'testBill1';
    private static final String USERNAMECOMPLETE = USER_NAME+ '@unitest.com';
    private static final String ACCEMAIL = 'test78887@abc.com';
    private static final String ACCFAX = '8888777767';
    private static final String ACCWEBSITE = 'www.testAcc988.com';
    private static final String STATE = 'Test State';
    private static final String CITY = 'Test City';
    private static final String POSTCODE = 'WS4 EB6';
    private static final String COUNTRY = 'UK';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String PAYMENTPLANTYPE_NAME = 'TestPaymentPlanType';
    private static final String YEARLY              = 'Yearly';
    private static final Integer MAXNUMOFINSTALMENTS = 12;
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';
    private static final String BUNDLE              = 'TestBundle';
    private static final String BUNDLEITEM          = 'TestBundleItem';
    private static final String BILLSERVICETYPE = 'testBillServiceType';
    private static final String BILLITEM = 'testBillItem';
    private static final Integer VOLUMEUSED = 100;
    private static final Integer BILLEDAMOUNT = 567;
    private static final String BILLMESSAGE = 'testBillMessage';
    private static final String PDFTEMPLATENAME = 'testbill_data_xslt8.zip';
    private static final String XSLTDOCUMENTNAME = 'testbill_data_xslt7.xslt';
    private static final String BILLINGEVENT = 'Normal';
    private static final String TEMPLATESETTINGTYPE = 'Bill PDF';
    private static final String PENDING = 'Pending';
    private static String PAYMENT_METHOD_TYPE = 'Payment Card'; 
    private static String PAYMENTPLANTYPE = 'Pay In Full';
    private static String SERVICEMESSAGENAME = 'testServiceMessageName';
    private static final String ALLOWANCETYPENAME       = 'TestAllowanceType';
    private static final String ALLOWANCEPRIORITY       = '1';
    private static final String ALLOWANCETYPE           = 'Fixed Volume Allowance';
    private static final String SIAGREEDVOLUMENAME      = 'TestSIAgreedVolumeName';
    private static final Integer SIAGREEDVOLUME         = 50;
    private static final String SUPPLYPOINTALLOWANCENAME = 'TestSupplyPointAllowanceName';
    private static final String VOLUMEALTERATIONITEMNAME = 'TestVolumeAlterationItemName';
    private static final Decimal ALLOWANCEAPPLIED        = 5.0;
    private static final Decimal ALLOWANCEAVAILABLE      = 5.0;
    private static final Integer VOLUMEALTERATIONITEMORDER = 10;
    private static final Date  DOB = system.today() - 300;   
    private static final String XMLSTRUCTURE = '<?xml version="1.0" encoding="UTF-8"?><Bills></Bills>';
    private static final String XMLDATA = '<BillItem ServiceType="TestServiceType" ServiceItem="TestServiceitemtype">';
    
    /*******************************************************************
    @author:      Echo: Mohit Tayal
    @date:        15 June 2018
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    
    @testSetup
    static void createTestData(){
        
        //Insert user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser);
        
        //Insert account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount.Email__c = ACCEMAIL;
        objAccount.Fax = ACCFAX;
        objAccount.Website = ACCWEBSITE;
        objAccount.DateofBirth__c = DOB;  
        Database.insert(objAccount);
        
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME, YEARLY, MAXNUMOFINSTALMENTS);
        objPaymentPlanType.SystemDefault__c = True; 
        objPaymentPlanType.PlanType__c = PAYMENTPLANTYPE;
        Database.insert(objPaymentPlanType);
        
        PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE;
        Database.insert(objPaymentMethodType);
        
        PaymentMethod__c objPaymentMethod = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType,objPaymentPlanType);
        objPaymentMethod.Default__c = True;
        Database.insert(objPaymentMethod);
        
        //Insert contract record
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        con.BillingStreet__c = STREET;
        con.BillingCity__c = CITY;
        con.BillingState__c = STATE;
        con.BillingPostalCode__c = POSTCODE;
        con.BillingCountry__c = COUNTRY;
        con.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
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

        LocationOccupant__c objLocationOccupants = GlUt_FactoryData_Test.CreateLocationOccupant(objAccount,objLocation);
        Database.insert(objLocationOccupants);
        
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
        
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        Database.insert(objServiceItem);
        
        BillEvent__c objBillEvent = GlUt_FactoryData_Test.createBillEvent(con, BILLINGEVENT);
        objBillEvent.Status__c = PENDING;
        Database.insert(objBillEvent);
        
        //Insert bill record
        List<Bill__c> listBills = new list<Bill__c>() ;
        Bill__c objBill1 = GlUt_FactoryData_Test.createBill(BILLNAME1 ,con);
        objBill1.StartDate__c = system.today().addDays(-40);
        objBill1.EndDate__c =system.today().addDays(-35);
        objBill1.Account__c = objAccount.id; //AT-3174
        objBill1.DataXml__c = true;
        objBill1.BillDate__c = system.today().addDays(-37);
        objBill1.HerokuPostgresId__c = 'id1234';
        listBills.add(objBill1) ;
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME ,con);
        objBill.StartDate__c = system.today().addDays(-10);
        objBill.EndDate__c =system.today().addDays(-5);
        objBill.Account__c = objAccount.id; //AT-3174
        objBill.DataXml__c = false;
        objBill.BillEvent__c = objBillEvent.Id;   //AT-3166
        objBill.BillDate__c = system.today().addDays(-7);
        listBills.add(objBill) ;
        Database.insert(listBills);
        
        /*for(Bill__c billObj : listBills){     //AT-3166  commented 
            if(billObj.DataXml__c == False)
                billObj.BillEvent__c = objBillEvent.Id;
        }
        
        Database.update(listBills);*/

        TemplateMapping__c objTemplateMapping = GlUt_FactoryData_Test.createTemplateMapping(PDFTEMPLATENAME,XSLTDOCUMENTNAME);
        Database.insert(objTemplateMapping);
        
        TemplateSetting__c objTemplateSetting = GlUt_FactoryData_Test.createTemplateSetting(objTemplateMapping,BILLINGEVENT, TEMPLATESETTINGTYPE);
        Database.insert(objTemplateSetting);
        
        BillMessage__c objBillMessage = GlUt_FactoryData_Test.createBillMessage(BILLMESSAGE);
        Database.insert(objBillMessage);
        
        ContractBillMessage__c objContractBillMessage = GlUt_FactoryData_Test.createContractBillMessage(objBillMessage, con);
        Database.insert(objContractBillMessage);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICETYPE, objBill, 'id123');
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEM, objServiceItem, VOLUMEUSED, BILLEDAMOUNT, objBillServiceType, 'id123');
        objBillItem.Bill__c = objBill.Id;
        objBillItem.Reading__c = objReadingList[1].Id;
        Database.insert(objBillItem);
        
      //  Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,con);
      //  Database.insert(objPayment);    // AT-3166 Commented code to avoid SOQL query limit breach
        
        ServiceMessage__c objServiceMessage = GlUt_FactoryData_Test.createServiceMessage(SERVICEMESSAGENAME,objServiceType);
        Database.insert(objServiceMessage);
        
        PaymentPlan__c objPaymentPlan = [SELECT Id FROM PaymentPlan__c WHERE BillingContract__c  = :con.id AND PaymentPlanType__c = :objPaymentPlanType.Id];
        
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        Database.insert(objInstalment); 
            
        AverageDailyUsage__c objAvgDailyUses = GlUt_FactoryData_Test.createAvgDailyUses(objSPD);
        Database.insert(objAvgDailyUses); 
        
        AllowanceType__c objAllowanceType = GlUt_FactoryData_Test.createAllowanceType(ALLOWANCETYPENAME, objServiceItemFamily, objSupplyPointUsageType, ALLOWANCEPRIORITY, ALLOWANCETYPE, True);
        Database.insert(objAllowanceType);
        
        SIAgreedVolume__c objSIAgreedVolume = GlUt_FactoryData_Test.createSIAgreedVolume(SIAGREEDVOLUMENAME, objServiceItem, SIAGREEDVOLUME);
        Database.insert(objSIAgreedVolume);
        
        SupplyPointAllowance__c objSupplyPointAllowance = GlUt_FactoryData_Test.createSupplyPointAllowance(SUPPLYPOINTALLOWANCENAME, objServiceItem, objAllowanceType, TRUE, objSupplyPoint);
        Database.insert(objSupplyPointAllowance);
        
        VolumeAlterationItem__c objVolumeAlterationItem = GlUt_FactoryData_Test.createVolumeAlterationItem(VOLUMEALTERATIONITEMNAME, objBillItem, VOLUMEALTERATIONITEMORDER, ALLOWANCEAPPLIED, ALLOWANCEAVAILABLE, objSIAgreedVolume, objSupplyPointAllowance);
        Database.insert(objVolumeAlterationItem);
        
        RuralLicense__c objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
        objRuralLicense.BillingContract__c = con.Id;
        Database.insert(objRuralLicense);
        
        RuralEntitlement__c objRuralEntitlement = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        objRuralEntitlement.RuralLicense__c=objRuralLicense.Id;
        objRuralEntitlement.Active__c=true;
        Database.insert(objRuralEntitlement);  

    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        15 June 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for constructor of BlUt_BillXMLContainer
    ********************************************************************/
    static testmethod void BlUt_BillXMLContainer_PositiveTest(){
        User objUser = [SELECT Id FROM User WHERE IsActive = True AND Username =: USERNAMECOMPLETE LIMIT 1];
        String queryString = String.format('SELECT {0} FROM {1}' , new List<String> {'Id, ' + String.join(BlUt_BillXMLContainer.billFieldList , ',') , GlUt_APIConstantsBill.BILLAPINAME  
                                                                                    +' WHERE ' + GlUt_APIConstantsBill.DATAXMLAPINAME +  ' = false'
                                                                                    +' ORDER By BillDate__c Desc limit 1'});
        List<Bill__c> lstBills = Database.query(queryString);
        System.runAs(objUser){
            Test.startTest();
            //BlUt_BillXMLContainer dataTransferXmlExt = new BlUt_BillXMLContainer(lstBills); // AT-4098
            BlUt_BillXMLContainer dataTransferXmlExt = new BlUt_BillXMLContainer(); 
            String xmlString = dataTransferXmlExt.getDataTransferXmlString(lstBills) ;
            Test.stopTest();
            system.assertNotEquals(xmlString, Null);
      
        }
    }
    
    /*******************************************************************
    @author:      ECHO: Ankit Gangwani
    @date:        06 Sept 2018
    @param:       N/A
    @return:      void
    @description: Negative Test scenario for constructor of BlUt_BillXMLContainer
    ********************************************************************/
    static testmethod void BlUt_BillXMLContainer_NegativeTest(){
        User objUser = [SELECT Id FROM User WHERE IsActive = True AND Username =: USERNAMECOMPLETE LIMIT 1];
        List<Bill__c> lstBills = new List<Bill__c>();
        System.runAs(objUser){
            Test.startTest();
            //BlUt_BillXMLContainer dataTransferXmlExt = new BlUt_BillXMLContainer(lstBills);
            BlUt_BillXMLContainer dataTransferXmlExt = new BlUt_BillXMLContainer(); 
            String xmlString = dataTransferXmlExt.getDataTransferXmlString(lstBills) ;
            Test.stopTest();
            //System.assertEquals(XMLSTRUCTURE, dataTransferXmlExt.XML);
            System.assertEquals(XMLSTRUCTURE, xmlString);
        }
    }
}