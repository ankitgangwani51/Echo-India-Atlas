/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        07 Feb 2019
@description: AT-5173 , Test Class for BlBt_DHHSInvoiceExport
*******************************************************************************/
@isTest
public class BlBt_DHHSInvoiceExport_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String LOADING 			= 'Loading';
    private static final String PENDING				= 'Pending';
    private static final String PAYMENTPLANNAME 	= 'Test Payment Plan Type';
    private static final String FREQUENCY 			= 'Monthly';
    private static final Integer MAXINSTLLMNT 		= 12;
    private static final Integer PLANAMOUNT 		= 56557;
    private static final String PLANTYP 			= 'Instalment Plan';
    private static final String BILLNAME 			= 'testBill';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static Decimal AMOUNT 					= 100.0;
    private static final Date INSTALMENT_DUE_DATE	 	= system.today();
    private static final Integer INSTALMENT_AMOUNT_DUE  = 50;
    private static final Integer SUM_OF_ALLOCATED_PAY   = 10;
    private static final String BILLITEMNAME1 = 'Test Bill Item';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String AVAILABLESERVIEITEM1='TestAvailableServiceItem1';
    private static final String BUNDLE ='TestBundle';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final String HEROKUPOSTGRESID1 = 'Test ID 1';
    private static final String BILLSERVICENAME = 'Test Bill Service';
    private static final Decimal DISCOUNTAMOUNT = 100.00;
    private static final Decimal TAXAMOUNT  = 20.00; 
    private static final Integer AUTHORITYID = 222;
    private static final String AUTHORITYName ='Test AuthorityName';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        objBalance.BalanceSnapshot__c = AMOUNT;
        Database.insert(objBalance);
        
        // Create BT Record
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        objBalanceTransaction.BillAmount__c = AMOUNT; 
        objBalanceTransaction.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill').getRecordTypeId(); // AT-3275
        Database.insert(objBalanceTransaction);
        
        // Create Contract for Refund Paymet           
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        objContract.OwnedBy__c = Label.BlAp_ContractOwnedByDHHS;
        objContract.Balance__c = objBalance.Id;
        objContract.BillingCity__c = 'TEST City';
        objContract.BillingStreet__c = 'Test Street';
        objContract.BillingPostalCode__c = 'Ws2 7PD';
        Database.insert(objContract);
        
        //Insert bill record
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME ,objContract);
        objBill.StartDate__c = system.today().addDays(-10);
        objBill.EndDate__c =system.today().addDays(-5);
        objBill.Account__c = objAccount.id; 
        objBill.BillPDF__c = true;
        Database.insert(objBill);
        
        // Update Bill on BT Record
        objBalanceTransaction.Bill__c = objBill.Id;
        Database.update(objBalanceTransaction);
        
        // Create Device Size Record
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
        objReadingList[1].Billed__c = true;
        Database.insert(objReadingList);
        
        //Insert location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Insert Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Insert supply point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Location__c = objLocation.Id;
        objSupplyPoint.Measured__c= True ; 
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
        Service__c  objService = GlUt_FactoryData_Test.createService(objContract,objReadingList[0],objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        // Create Bank Account Details Record        
        BankAccountDetails__c objBankAccountDetails = GlUt_FactoryData_Test.createBankAccountDetails(objAccount);
        Database.insert(objBankAccountDetails); 
        
        // Create Payment Plan Type Record
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANNAME, FREQUENCY, MAXINSTLLMNT);      
        objPaymentPlanType.PlanType__c = PLANTYP;        
        Database.insert(objPaymentPlanType);
        
        // Create Payment Plan Record
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLANAMOUNT);
        Database.insert(objPaymentPlan);
        
        // Create Instalment Record            
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);      
        objInstalment.InstalmentDueDate__c     = INSTALMENT_DUE_DATE;
        objInstalment.InstalmentAmountDue__c   = INSTALMENT_AMOUNT_DUE;
        objInstalment.SumofAllocatedPayment__c = SUM_OF_ALLOCATED_PAY;
        Database.insert(objInstalment);
        
        // Create Direct Debit Requests Record
        DirectDebitRequest__c objDirectDebitRequest = GlUt_FactoryData_Test.createDirectDebitRequest(objContract, objInstalment);
        objDirectDebitRequest.Status__c = PENDING;
        objDirectDebitRequest.BankAccountDetails__c = objBankAccountDetails.Id;
        Database.insert(objDirectDebitRequest);
        
        //Create Batch Request Queue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Status__c = LOADING;
        Database.insert(objBatchRequestQueue);
        
        // Create Bill Export Record
        BillExport__c objBillExport =  GlUt_FactoryData_Test.createBillExport(objBill,objContract,Label.BlAp_BillExportStatusPending);
        objBillExport.Type__c = Label.BlAp_BillExportTypeDHHS;
        Database.insert(objBillExport);
        
        // Create DHHS custom setting Record
        DHHS__c objDHHS = GlUt_FactoryData_Test.createDHHSCustomSetting(AUTHORITYID,AUTHORITYNAME);
        Database.insert(objDHHS);
        
        // Create SIF Record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        // Create SIT Record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        // Create Bundle Record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        // Create AB Record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        // Create BI Record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily); 
        Database.insert(objBundleItem);
        
        // Create ASI Record
        List<AvailableServiceItem__c> listASI = new List<AvailableServiceItem__c>();
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        listASI.add(objAvailableServiceItem);
        
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM1,objBundleItem,objServiceItemType,objAvailableBundle);
        listASI.add(objAvailableServiceItem1);
        Database.insert(listASI);
        
        // Create SI Record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        Database.insert(objServiceItem);
        
        // Create BST Record
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID1);
        Database.insert(objBillServiceType);
        
        // Create BI Record
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME1, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID1);
        objBillItem.TotalDiscountAmount__c = DISCOUNTAMOUNT;
        objBillItem.TotalTaxAmount__c = TAXAMOUNT;
        objBillItem.Bill__c = objBill.Id;
        Database.insert(objBillItem);
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        07 Feb 2019
	@description: Positive method of DHHSInvoiceExport 
	*******************************************************************************/
    static testmethod void DHHSInvoiceExport_Positive(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id,Name,BatchProcess__c FROM BatchRequestQueue__c LIMIT 1];
        Boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                BlBt_DHHSInvoiceExport objDHHSExport = new BlBt_DHHSInvoiceExport();
                objDHHSExport.Initialise(objBatchReqQueue);
                Database.executeBatch(objDHHSExport);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            List<ContentDocumentLink> conLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:objBatchReqQueue.Id];
            system.assertEquals(conLink.size(), 2);
        }          
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        07 Feb 2019
	@description: Negative method of DHHSInvoiceExport 
	*******************************************************************************/
    static testmethod void DHHSInvoiceExport_Negative(){            
        
        List<BillExport__c> listBillExport = [SELECT Id,Name FROM BillExport__c LIMIT 1];
        Database.delete(listBillExport);
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        BatchRequestQueue__c objBatchReqQueue = [SELECT Id,Name,BatchProcess__c FROM BatchRequestQueue__c LIMIT 1];
        Boolean isException = false;
        BlBt_DHHSInvoiceExport objDHHSExport = new BlBt_DHHSInvoiceExport();
        System.runAs(objUser){
            Test.startTest();
            try{
                objDHHSExport.Initialise(objBatchReqQueue);
                Database.executeBatch(objDHHSExport);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assert(objDHHSExport.numberOfRecordsProcessed == 0);
            List<ContentDocumentLink> conLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:objBatchReqQueue.Id];
            system.assertEquals(conLink.size(), 2);
        }          
    }
}