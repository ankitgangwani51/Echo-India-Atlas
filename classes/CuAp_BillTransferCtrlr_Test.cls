/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        14 Aug 2018
@description: Test Class for CuAp_BillTransferCtrlr
*******************************************************************************/
@isTest
Private class CuAp_BillTransferCtrlr_Test {
    
    private static string BILLINGRESPONSEMOCKPOSITIVE = 'GlUt_Mock_createBilling_Response_Positive';
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';

	private static String PAYMENT_METHOD_TYPE1 = 'Payment Card';
    private static String PAYMENT_METHOD_TYPE2 = 'Giro Slips';
    private static String PAYMENT_METHOD_TYPE3 = 'Direct Debit';
    private static String PLAN_NAME = 'DD FORTNIGHTLY';
    private static String PAY_FREQ = 'Monthly';
    private static Integer NUM_OF_INSTAL = 3;
    private static String PLAN_NAME2 = Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan;
    private static String PAY_FREQ2 = 'Monthly';
    private static Integer NUM_OF_INSTAL2 = 1;
    private static String PLAN_NAME3 = 'BUDGET PLAN';
    private static String PAY_FREQ3 = 'Fortnightly';
    private static Integer NUM_OF_INSTAL3 = 4;
    private static String PLAN_NAME4 = 'BUDGET PLAN';
    private static String PAY_FREQ4 = 'Weekly';
    private static Integer NUM_OF_INSTAL4 = 4;
    private static String AVAIL_PAY_DAY_NAME = 'APD Monday';
    private static String DAY_OF_MONTH = '2';
    private static String DAY_OF_WEEK = 'Monday';
    private static String ACCOUNT_NAME = 'Test Account';
    private static String ACCOUNT_NAME1 = 'Test Account1';
    private static String ACCOUNT_NAME2 = 'Test Account2';
    private static String ACCOUNT_NAME3 = 'Test Account3';
    private static String CONTACT_NAME = 'Test Contact';
    private static Double AMOUNT = 100.0;
    private static String MONTHLY = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    
    private static final String PDF_TEMPLATE_NAME = 'pdfTemplateName';
    private static final String CONTRACT_NAME ='TestContract';
    private static final String CONTRACT_NAME2 ='TestContract2';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String BILLNAME = 'testBill';
    private static final String BILLNAME1 = 'testBill1';
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
    private static final String XMLBILLDETAIL = '<objectApiName>'+GlUt_NamespacePrefix.getNamespacePrefix()+'Bill__c</objectApiName><field><apiName>Name</apiName><value>testBill</value></field>';
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
    private static final String HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static final String PASS = 'OK';
    private static final String TRANSFER = 'Transfer';
    private static final String STATUS_NEW = 'New';
    private static final String TESTREGION = 'Test Region';
    
    
        
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        14 Aug 2018
    @description: Test method to create test data
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
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
        
        //Insert account record
        Account objAccount2 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);
        //objAccount2.Email__c = ACCEMAIL;
        //objAccount2.Fax = ACCFAX;
        //objAccount2.Website = ACCWEBSITE;
        //objAccount2.DateofBirth__c = DOB;  
        Database.insert(objAccount2);
        
        //Insert contract record
        BillingContract__c con2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2,objAccount2);
        con2.BillingStreet__c = STREET;
        con2.BillingCity__c = CITY;
        con2.BillingState__c = STATE;
        con2.BillingPostalCode__c = POSTCODE;
        con2.BillingCountry__c = COUNTRY;
        con2.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        Database.insert(con2);
        
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
        objBill1.BillType__c = Label.CuAp_NormalBillType;
        objBill1.BillDate__c = system.today().addDays(-37);
        objBill1.HerokuPostgresId__c = 'id1234';
        //objBill1.TotalAmountOutstanding__c = 10.00;
        listBills.add(objBill1) ;
        
        Database.insert(listBills);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICETYPE, objBill1, 'id123');
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEM, objServiceItem, VOLUMEUSED, BILLEDAMOUNT, objBillServiceType, 'id123');
        objBillItem.Bill__c = objBill1.Id;
        objBillItem.Reading__c = objReadingList[1].Id;
        objBillItem.NetBilledAmount__c = BILLEDAMOUNT;
        Database.insert(objBillItem);
        
        system.debug('objBill1***'+ objBill1);
        
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation(con.Id,TRANSFER,STATUS_NEW);
        Database.insert(objBillCalculation);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;

        
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getContractDetails() method
    @revision:    08-Mar-2018 MT - Use the field from constant class
    *******************************************************************************/
    
    static testmethod void retrieveBillFieldDetails_Positive(){               
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
       List<GLAp_FieldProps> listFieldProps = new List<GLAp_FieldProps>(); 
        
        System.runAs(objUser[0]){
            Test.starttest();
            listFieldProps = CuAp_BillTransferCtrlr.retrieveBillFieldDetails();                         
            Test.stoptest();
            
            if(!listFieldProps.isEmpty()){
                
                System.assert(listFieldProps.size() > 0);
            }
                        
        }
    } 
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getContractDetails() method
    @revision:    08-Mar-2018 MT - Use the field from constant class
    *******************************************************************************/
    
    static testmethod void getUnpaidBills_Positive(){ 
        
        List<BlAp_CombinedRecord> listRecords = new List<BlAp_CombinedRecord>();
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Account objAccount = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   		  Name,
                                   		  CurrentPaymentPlanType__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
       
        
        System.runAs(objUser[0]){
            Test.starttest();
            listRecords = CuAp_BillTransferCtrlr.getUnpaidBills(objContract.Id);                         
            Test.stoptest();
            
            if(!listRecords.isEmpty()){
                
                System.assert(listRecords.size() > 0);
            }
                        
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getContractDetails() method
    @revision:    08-Mar-2018 MT - Use the field from constant class
    *******************************************************************************/
    
    static testmethod void getAccountIdDetails_Positive(){ 
        
        String accountId;
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Account objAccount = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select  Id,
                                                  Name,
                                                  AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        
        
        System.runAs(objUser[0]){
            Test.starttest();
            accountId = CuAp_BillTransferCtrlr.getAccountIdDetails(objContract.Id);                         
            Test.stoptest();
            
            system.debug('accountId***'+ accountId);
            system.debug('accountIdlength***'+ accountId.length());
            
            System.assertEquals(accountId.length(), 18);
            
            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getContractDetails() method
    @revision:    08-Mar-2018 MT - Use the field from constant class
    *******************************************************************************/
    
    static testmethod void retrieveTransferReasonDetails_Positive(){
        
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        System.runAs(objUser[0]){
            Test.starttest();
            twoColFormattedList = CuAp_BillTransferCtrlr.retrieveTransferReasonDetails();                         
            Test.stoptest();
            
            if(!twoColFormattedList.isEmpty()){
                
                System.assert(twoColFormattedList.size() > 0);
            }
                        
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getContractDetails() method
    @revision:    08-Mar-2018 MT - Use the field from constant class
    *******************************************************************************/
    
    static testmethod void transferBills_Positive(){ 
        
        String responseCode;
        List<Id> selectedBillIds = new List<Id>();
        String contractToTransferId;
        String contractId;
        String transferReason = Label.BillTransferReason;
            
        List<User> objUser = [SELECT Id,Name,FirstName,LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        contractToTransferId = String.valueOf(objContract.Id);
        
        Account objAccount2 = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME2 LIMIT 1];
        BillingContract__c objContract2 = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount2.id  LIMIT 1];
        contractId = String.valueOf(objContract2.Id);
        List<Bill__c> listBills = [SELECT Id,Name FROM Bill__c
                                   WHERE BillingContract__c = :objContract.id];
        List<BillCalculation__c> lstBillCalculation = [SELECT Id, Name,BillingContract__c,Type__c,Status__c,RequestDate__c FROM BillCalculation__c LIMIT 1];
        if(!listBills.isEmpty()){
            for(Bill__c objBill : listBills){
                selectedBillIds.add(objBill.Id);
            }
        }
        System.runAs(objUser[0]){
            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));
            responseCode = CuAp_BillTransferCtrlr.transferBills(selectedBillIds,contractToTransferId,contractId,transferReason,lstBillCalculation[0].Id);                         
            Test.stopTest();           
            
            system.debug('responseCode***'+ responseCode);
            
            System.assertEquals(responseCode, PASS);
            
            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for createBillCalculationValidate() method scenario
    *******************************************************************************/ 
    static testmethod void createBillCalculationValidate(){
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            Id billCalculationId = CuAp_BillTransferCtrlr.createBillCalculation(objContract.Id);
            Test.stopTest();
            System.assert(billCalculationId != null);
        }
    } 
    
}