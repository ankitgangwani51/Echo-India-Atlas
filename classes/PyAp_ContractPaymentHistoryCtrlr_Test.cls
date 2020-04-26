/******************************************************************************
@author:      Echo : Vivek Sethi
@date:        08 Feb 2018
@description: Test Class for PyAp_ContractPaymentHistoryCtrlr
*******************************************************************************/
@isTest  
public class PyAp_ContractPaymentHistoryCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String PAYMENTMETHOD = 'Test';
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String BILLNAME = 'testBill';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String SUB_DEVICE_TYPE ='TestSubDevice';
    private static final String INVALID_BILL_ID = 'ABC';
    private static final String INVALID_PAYMENT_ID = 'ABC';
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
    private static final Integer LIMIT1 =1;
    private static final String TESTNAME ='test';
    private static final String TESTAMOUNT ='100';
    private static final String TESTID ='1';
    private static final String BILLSERVICENAME = 'Test Bill Service';
    private static final String HEROKUPOSTGRESID = 'Test ID';
    private static final String BILLITEMNAME = 'Test Bill Item';
    private static final String FINALBILL = 'true';
    private static final String FINALBILLFALSE = 'false';
    private static final String BILLDATE = string.valueOf(System.Today());
    private static final String	PAYMENT_PLAN_TYPE = 'New Payment Plan';
    private static final String	PAYMENT_ALLOCATION = 'Payment Allocation';
    private static final String YEARLY = 'Yearly';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final Integer PLAN_AMOUNT = 50;
    private static final Integer NO_OF_INSTALLMENT = 12;
    private static final Integer RATE = 100;
    private static final Integer BAND1 = 10;
    private static final Integer BAND2 = 50;
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final Decimal ALLOCATION_AMOUNT = 50;
    
   /*******************************************************************
Purpose: method to create test data used by all USER_NAME test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    static void createTestData()
    {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        // Create Account Record  
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        // Create Contract Record  
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(ACCOUNT_NAME, objAccount);        
        Database.insert(objContract);  
        // Create Payment Record  
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        Database.insert(objPayment);
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        // Create Device Record  
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        // Create subdevice record
        Device__c objsubDevice = GlUt_FactoryData_Test.CreateDevice(SUB_DEVICE_TYPE ,objDeviceType );
        Database.insert(objsubDevice);
        // Create ServiceType Record  
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        // Create Reading Record  
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        // Create Reading Record  
        Reading__c  objReadingSecond = GlUt_FactoryData_Test.CreateReading(objsubDevice);
        Database.insert(objReadingSecond);
        // Create Location Record  
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        // Create SupplyPointUsage Record  
        SupplyPointUsageType__c  objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(TESTNAME);
        Database.insert(objSupplyPointUsageType);
        // Create SupplyPoint Record  
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174
  
        objSupplyPoint.SupplyPointUsageType__c = objSupplyPointUsageType.Id;
        Database.insert(objSupplyPoint);
        
        SupplyPoint__c  objSubSP = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSubSP.Measured__c= True; // AT-3174
 
        Database.insert(objSubSP);
        
        
        // Create Division Record  
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        // Create Wholesaler Record  
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        // Create AvailableService Record  
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        // Create Service Record  
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint, objAvailableService);
        Database.insert(objService);
        // Create ServiceItem Record  
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        // Create ServiceItemType Record  
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        // Create Bundle Record  
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        // Create AvailableBundle Record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        // Create BundleItem Record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        // Create AvailableServiceItem Record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        // Create ServiceItem Record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.today();
        Database.insert(objServiceItem);
        
        // Commented by Ankit Gangwani for task - AT-2926, 22 June 2018
        // Create DeviceRelationship Record   
        //DeviceRelationship__c  objDeviceRelationship = GlUt_FactoryData_Test.CreateDeviceRelationship(objDevice,objsubDevice);
        //objDeviceRelationship.MainSupply__c= objSupplyPoint.id;
        //Database.insert(objDeviceRelationship);
        
        SupplyPointRelationship__c objSupplyPointRelationship = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPoint, objSubSP);
        Database.insert(objSupplyPointRelationship);
        
        //Create DischargeAgreement Record
        DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
        Database.insert(objDischargeAgreement);         
        // Create SiteArea Record
        // Create Sample Record
        Sample__c  objSample =GlUt_FactoryData_Test.createSample(SAMPLE );
        objSample.CODSampleStrength__c = 10.0;
        objSample.DischargeAgreement__c = objDischargeAgreement.Id;
        objSample.SSSampleStrength__c = 10.0;
        objSample.SampleCollectionDate__c = system.today();
        Database.insert(objSample);
        // Create AgreedRate Record
        AgreedRate__c  objAgreedRate =GlUt_FactoryData_Test.CreateAgreedRate(AGREERATE,objServiceItem);
        Database.insert(objAgreedRate);
        // Create Rate Record
        Rate__c  objRate = GlUt_FactoryData_Test.createRate(objServiceItemType,RATE);
        Database.insert(objRate);
        // Create RateBand Record
        RateBand__c  objRateBand = GlUt_FactoryData_Test.createRateBand(objRate,BAND1,BAND2);
        Database.insert(objRateBand);
        // Create Bill Record
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,objContract);
        objBill.Account__c = objAccount.id; //AT-3174
        Database.insert(objBill);
        // Create BillServiceType Record
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        // Create BillItem Record
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        objBillItems.Bill__c = objBill.Id;
        Database.insert(objBillItems);
        // Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE,YEARLY,NO_OF_INSTALLMENT);
        Database.insert(objPaymentPlanType);
        // Create PaymentPlan Record            
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract,PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
        // Create Instalment Record            
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        Database.insert(objInstalment);
        // Create PaymentAllocation Record 
        PaymentAllocation__c objPaymentAllocation = GlUt_FactoryData_Test.createPaymentAllocation(PAYMENT_ALLOCATION, ALLOCATION_AMOUNT, objBillItems, objInstalment, objPayment);
        Database.insert(objPaymentAllocation); 
    }
    
    /*******************************************************************
Purpose: Method to test scenario for retrievePaymentFieldPropDetails method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrievePaymentFieldPropDetails_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<GLAp_FieldProps>  fldPropList = new List<GLAp_FieldProps>();  
        System.runAs(objUser){
            Test.startTest();
            fldPropList = PyAp_ContractPaymentHistoryCtrlr.retrievePaymentFieldPropDetails();
            Test.stopTest();
        }
        System.assert(fldPropList.size() > 0);
    }
    
    /*******************************************************************
Purpose: Method to test scenario for retrieveBillPropDetails method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveBillPropDetails_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<GLAp_FieldProps>  fldPropList = new List<GLAp_FieldProps>();  
        System.runAs(objUser){
            Test.startTest();
            fldPropList = PyAp_ContractPaymentHistoryCtrlr.retrieveBillPropDetails();
            Test.stopTest();
        }
        System.assert(fldPropList.size() > 0); 
    }
    
    /*******************************************************************
Purpose: Method to test scenario for retrieveBillItmPropDetails method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    
    static testmethod void retrieveBillItmPropDetails_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<GLAp_FieldProps>  fldPropList = new List<GLAp_FieldProps>();  
        System.runAs(objUser){
            Test.startTest();
            fldPropList = PyAp_ContractPaymentHistoryCtrlr.retrieveBillItmPropDetails();
            Test.stopTest();
        }
        System.assert(fldPropList.size() > 0);
    }
    
    /******************************************************************
Purpose: Method to test positive scenario for retrievePaymentRecords method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrievePaymentRecords_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        BillingContract__c objContract = [select Id from BillingContract__c limit 1];
        
        List<BlAp_CombinedRecord> paymentList = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            Test.startTest();
            paymentList = PyAp_ContractPaymentHistoryCtrlr.retrievePaymentRecords(objContract.Id);
            Test.stopTest();
        }
        System.assert(paymentList.size() > 0);
    }
    
    /*******************************************************************
Purpose: Method to test negative scenario for retrievePaymentRecords method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrievePaymentRecordsNullValue_Negative()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        BillingContract__c objContract = new BillingContract__c();
        boolean isException;
        List<BlAp_CombinedRecord> paymentList = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            try{
                Test.startTest();
                paymentList = PyAp_ContractPaymentHistoryCtrlr.retrievePaymentRecords(objContract.Id);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }            
        }
        System.assert(paymentList.isEmpty() == true);
    }
    
    /*******************************************************************
Purpose: Method to test negative scenario for retrievePaymentRecords method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrievePaymentRecordsInvalidValue_Negative()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        boolean isException;
        List<BlAp_CombinedRecord> paymentList = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            try{
                Test.startTest();
                paymentList = PyAp_ContractPaymentHistoryCtrlr.retrievePaymentRecords(INVALID_PAYMENT_ID);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assert(paymentList.isEmpty() == true);
    }    
    /*******************************************************************
Purpose: Method to test positive scenario for retrieveBills method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveBills_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        Payment__c objPay = [select Id from Payment__c limit 1];
        
        List<BlAp_CombinedRecord> billsList = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            Test.startTest();
            billsList = PyAp_ContractPaymentHistoryCtrlr.retrieveBills(objPay.Id);
            Test.stopTest();
        }
        System.assert(billsList.size() > 0);
    }
    
    /*******************************************************************
Purpose: Method to test negative scenario for retrieveBills method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveBillsInvalidPaymentID_Negative()
    {            
        User objUser =[select id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<BlAp_CombinedRecord> billsList = new List<BlAp_CombinedRecord>();
        boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                billsList = PyAp_ContractPaymentHistoryCtrlr.retrieveBills(INVALID_BILL_ID);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assert(isException == true);
    }
    
    /*******************************************************************
Purpose: Method to test positive scenario for retrieveBillItems method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retrieveBillItems_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        Payment__c objPay = [select Id from Payment__c limit 1];
        Bill__c    objBill = [select Id from Bill__c limit 1];
        List<BlAp_CombinedRecord> billsItemList = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            Test.startTest();
            billsItemList = PyAp_ContractPaymentHistoryCtrlr.retrieveBillItems(objPay.Id,objBill.Id);
            Test.stopTest();
        }
        System.assert(billsItemList.size() > 0);
    }
    
    /******************************************************************************
Purpose: Method to test  negative scenario for retrieveBillItems method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
******************************************************************************/
    static testmethod void retrieveBillItemsNullBillID_Negative()
    {
        User objUser =[select id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<BlAp_CombinedRecord> CombineRecordList = new List<BlAp_CombinedRecord>(); 
        
        Bill__c objBill = new Bill__c();
        Payment__c objPayment =  [select id from Payment__c limit 1];
        boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                CombineRecordList = PyAp_ContractPaymentHistoryCtrlr.retrieveBillItems(objPayment.Id, objBill.Id);           
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assert(CombineRecordList.isEmpty() == true); 
    }
    /******************************************************************************
Purpose: Method to test  negative scenario for retrieveBillItems method
Parameters: N/A 
Returns: voId
Throws [Exceptions]: N/A
******************************************************************************/
    static testmethod voId retrieveBillItemsNullPaymentID_Negative()
    {
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<BlAp_CombinedRecord> CombineRecordList = new List<BlAp_CombinedRecord>(); 
        boolean isException;
        Bill__c objBill = [select Id from Bill__c limit 1];
        Payment__c objPayment = new Payment__c();
        
        System.runAs(objUser){
            try{
                Test.startTest();
                CombineRecordList = PyAp_ContractPaymentHistoryCtrlr.retrieveBillItems(objPayment.Id, objBill.Id);           
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assert(CombineRecordList.isEmpty() == true); 
    }
    
    /******************************************************************************
Purpose: Method to test  negative scenario for retrieveBillItems method
Parameters: N/A 
Returns: voId
Throws [Exceptions]: N/A
*******************************************************************************/
    static testmethod void retrieveBillItemsInvalidBillId_Negative()
    {
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<BlAp_CombinedRecord> CombineRecordList = new List<BlAp_CombinedRecord>(); 
        Payment__c objPayment =  [select id from Payment__c limit 1];
        boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                CombineRecordList = PyAp_ContractPaymentHistoryCtrlr.retrieveBillItems(objPayment.Id, INVALID_BILL_ID);           
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assert(CombineRecordList.isEmpty() == true);  
    }
   
    /******************************************************************************
Purpose: Method to test  negative scenario for retrieveBillItems method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
******************************************************************************/
    static testmethod void retrieveBillItemsInvalidPaymentID_Negative()
    {
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<BlAp_CombinedRecord> CombineRecordList = new List<BlAp_CombinedRecord>(); 
        Bill__c objBill = new Bill__c();
        boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                CombineRecordList = PyAp_ContractPaymentHistoryCtrlr.retrieveBillItems(INVALID_PAYMENT_ID, objBill.Id);           
                Test.stopTest();
            }catch(exception e)
            {
                isException = true; 
            }
        }
        System.assert(CombineRecordList.isEmpty() == true);   
    }
}