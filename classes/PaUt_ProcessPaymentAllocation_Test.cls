/******************************************************************************
@author         Echo: Swati Mathur
@date           16 Feb 2018
@description    Test Class for PaUt_ProcessPaymentAllocation
*******************************************************************************/
@isTest
public class PaUt_ProcessPaymentAllocation_Test {
    
    private static String USER_PROFILE = 'System Administrator';
    private static final String USER_FNAME= 'TestFName';
    private static final String USER_LNAME= 'TestLName';
    private static String USER_NAME = 'TestUser';
    private static String USER_NAME_COMPLETE = USER_NAME+ '@unitest.com'; 
    private static String ACCOUNT_NAME = 'TestAccount';
    private static String ACCOUNT_NAME_1 = 'TestAccount1';    
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';    
    private static String PAYMENT_PLAN_TYPE_NAME = 'Test Payment Plan Type';
    private static String PAYMENT_PLAN_TYPE_NAME_1 = 'Test Payment Plan Type1';
    private static String FREQUENCY = 'Monthly';
    private static Integer MAX_INSTALMENT = 12;
    private static Integer PLAN_AMOUNT = 12345;
    private static Integer NUMBER_OF_INSTALMENTS = 07; 
    private static Integer AMOUNT_OUTSTANDING = 200; 
    private static String PLAN_TYPE = 'Instalment Plan';
    private static String PAYMENT_ALLOCATION_NAME = 'Payment Allocation test';    
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String SP_USAGE_TYPE_1 = 'SupplyPointUsageType1';
    private static final String SP_USAGE_TYPE_2 = 'SupplyPointUsageType2';
    private static String DEVICE_NAME = 'TestDevice';
    private static String DEVICE_NAME_1 = 'TestDevice1';
    private static String DEVICE_NAME_2 = 'TestDevice2';
    private static String DEVICE_TYPE ='TestDeviceType';
    private static String DEVICE_TYPE_1 ='TestDeviceType1';
    private static String DEVICE_TYPE_2 ='TestDeviceType2';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String DEVICE_SIZE_1 = 'TestDeviceSize1';
    private static final String DEVICE_SIZE_2 = 'TestDeviceSize2';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String TEST_SERVICE_TYPE_1 ='TestServiceType1';
    private static String TEST_SERVICE_TYPE_2 ='TestServiceType2';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_NAME_1 ='A88 8AA';
    private static String LOCATION_NAME_2 ='A77 7AA';
    private static String WHOLESALER ='TestWholesaler';    
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String AVAILABLE_SERVICES ='TestAvailableService';
    private static String AVAILABLE_SERVICES_1 ='TestAvailableService1';
    private static String AVAILABLE_SERVICES_2 ='TestAvailableService2';
    private static String SERVICE_ITEM_FAMILY ='TestServiceItemFamily';
    private static String SERVICE_ITEM_FAMILY_1 ='TestServiceItemFamily1';
    private static String SERVICE_ITEM_FAMILY_2 ='TestServiceItemFamily2';
    private static String SERVICE_ITEM_TYPE ='TestServiceitemtype';
    private static String SERVICE_ITEM_TYPE_1 ='TestServiceitemtype1';
    private static String SERVICE_ITEM_TYPE_2 ='TestServiceitemtype2';
    private static String BUNDLE ='TestBundle';
    private static String BUNDLE_1 ='TestBundle1';
    private static String BUNDLE_2 ='TestBundle2';
    private static String AVAILABLE_BUNDLE ='TestAvailableBundle';
    private static String AVAILABLE_BUNDLE_1 ='TestAvailableBundle1';
    private static String AVAILABLE_BUNDLE_2 ='TestAvailableBundle2';
    private static String BUNDLE_ITEM ='TestBundleItem';
    private static String BUNDLE_ITEM_1 ='TestBundleItem1';
    private static String BUNDLE_ITEM_2 ='TestBundleItem2';
    private static String AVAILABLE_SERVICE_ITEM='TestAvailableServiceItem';
    private static String AVAILABLE_SERVICE_ITEM_1='TestAvailableServiceItem1';
    private static String AVAILABLE_SERVICE_ITEM_2='TestAvailableServiceItem2';
    private static String BILL_NAME = 'testBill';
    private static String BILL_SERVICE_NAME = 'Test Bill Service';
    private static String BILL_ITEM_NAME_1 = 'Test Bill Item_1';
    private static String BILL_ITEM_NAME_2 = 'Test Bill Item_2';
    private static String BILL_ITEM_NAME_3 = 'Test Bill Item_3';
    private static String BILL_ITEM_NAME_4 = 'Test Bill Item_4';
    private static String BILL_ITEM_NAME_5 = 'Test Bill Item_5';
    private static String BILL_ITEM_NAME_6 = 'Test Bill Item_6';
    private static String BILL_ITEM_NAME = 'Test Bill Item';
    private static Integer VOLUME_USED = 200;
    private static Integer BILLED_AMOUNT = 67878;
    private static String HEROKU_POSTGRES_ID_1 = 'Test ID_1';
    private static String HEROKU_POSTGRES_ID_2 = 'Test ID_2';
    private static String HEROKU_POSTGRES_ID_3 = 'Test ID_3';
    private static String HEROKU_POSTGRES_ID_4 = 'Test ID_4';
    private static String HEROKU_POSTGRES_ID_5 = 'Test ID_5';
    private static String HEROKU_POSTGRES_ID_6 = 'Test ID_6';
    private static String HEROKU_POSTGRES_ID = 'Test ID';
    private static Boolean onlyoneQuery = False;
    private static User userObj = new User();
    
    /******************************************************************************
    @author        Swati Mathur
    @date          15 Feb 2018
    @param         -
    @return        Void   
    @description   Setup Method for Initialize Data for Unit Testing
    *******************************************************************************/
    @testSetup
    static void createTestData(){
        
        System.debug('Total Number of SOQL Queries before any data: ' +  Limits.getQueries());
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        System.debug('Total Number of SOQL Queries in User: ' +  Limits.getQueries());
        
        List<Account> lstAcc = new List<Account>();
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        lstAcc.add(objAccount);
        
        System.debug('Total Number of SOQL Queries in Acc: ' +  Limits.getQueries());
        
        Account objAccount1 = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME_1);
        lstAcc.add(objAccount1);
        Database.insert(lstAcc);   
        
        System.debug('Total Number of SOQL Queries in Acc1: ' +  Limits.getQueries());
        
        List<BillingContract__c> lstCon = new List<BillingContract__c>();
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        lstCon.add(objContract);
        
        BillingContract__c objContract1 = GlUt_FactoryData_Test.CreateContract(' ',objAccount1);
        objContract1.BillingStreet__c=BILLING_STREET;
        objContract1.BillingCity__c=BILLING_CITY;
        objContract1.BillingState__c=BILLING_STATE;
        objContract1.BillingPostalCode__c=BILLING_POSTCODE;
        objContract1.BillingCountry__c=BILLING_COUNTRY;
        lstCon.add(objContract1);
        Database.insert(lstCon);
        
        System.debug('Total Number of SOQL Queries in Contract: ' +  Limits.getQueries());
        
        List<PaymentPlanType__c> lstPPT = new List<PaymentPlanType__c>();
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE_NAME, FREQUENCY, MAX_INSTALMENT);
        objPaymentPlanType.PlanType__c = PLAN_TYPE;
        lstPPT.add(objPaymentPlanType);
        
        PaymentPlanType__c objPaymentPlanType1 = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE_NAME_1, FREQUENCY, MAX_INSTALMENT);
        objPaymentPlanType1.PlanType__c = PLAN_TYPE;
        lstPPT.add(objPaymentPlanType1);
        Database.insert(lstPPT);
        
        System.debug('Total Number of SOQL Queries in PPT: ' +  Limits.getQueries());
        
        List<PaymentPlan__c> lstPP = new List<PaymentPlan__c>();
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLAN_AMOUNT);
        lstPP.add(objPaymentPlan);
        
        PaymentPlan__c objPaymentPlan1 = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType1,objContract1,PLAN_AMOUNT);
        lstPP.add(objPaymentPlan1);
        Database.insert(lstPP);
        
        System.debug('Total Number of SOQL Queries in PP : ' +  Limits.getQueries());
        
        List<Instalment__c> lstInst = new List<Instalment__c>();
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        objInstalment.InstalmentAmountDue__c= AMOUNT_OUTSTANDING;
        objInstalment.InstalmentDueDate__c= System.today();     
        lstInst.add(objInstalment);        
                
        Instalment__c objInstalment1 = GlUt_FactoryData_Test.createInstalment(objPaymentPlan1);
        objInstalment1.InstalmentAmountDue__c= AMOUNT_OUTSTANDING;
        objInstalment1.InstalmentDueDate__c= System.today();        
        lstInst.add(objInstalment1); 
        
        Instalment__c objInstalment2 = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        objInstalment2.InstalmentAmountDue__c= AMOUNT_OUTSTANDING;
        lstInst.add(objInstalment2);         
        Database.insert(lstInst); 
        
        System.debug('Total Number of SOQL Queries in Instalment: ' +  Limits.getQueries());
        
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILL_NAME ,objContract);
        objBill.Account__c = objAccount.id; //AT-3174
        objBill.BillingContract__c = objContract.id;
        Database.insert(objBill);        
        
        System.debug('Total Number of SOQL Queries in Bill: ' +  Limits.getQueries());
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_NAME, objBill, HEROKU_POSTGRES_ID);
        Database.insert(objBillServiceType);
        
        System.debug('Total Number of SOQL Queries in Bill Serv Type: ' +  Limits.getQueries());
        
        //create device size records
        List<DeviceSize__c> lstDeviceSize = new List<DeviceSize__c> ();
        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        lstDeviceSize.add(objDeviceSize);   
        
        DeviceSize__c objDeviceSize1 = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE_1);
        lstDeviceSize.add(objDeviceSize1);  
        
        DeviceSize__c objDeviceSize2 = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE_2);
        lstDeviceSize.add(objDeviceSize2);  
        
        Database.insert(lstDeviceSize);
        
        System.debug('Total Number of SOQL Queries in device size: ' +  Limits.getQueries());
        
        //create device type records
        List<DeviceType__c> lstDeviceType = new List<DeviceType__c> ();
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        lstDeviceType.add(objDeviceType);
        
        DeviceType__c  objDeviceType1 = GlUt_FactoryData_Test.createDeviceType(objDeviceSize1,MANUFACTURER,UNIT_OF_MEASURE);
        lstDeviceType.add(objDeviceType1);
        
        DeviceType__c  objDeviceType2 = GlUt_FactoryData_Test.createDeviceType(objDeviceSize2,MANUFACTURER,UNIT_OF_MEASURE);
        lstDeviceType.add(objDeviceType2);
        
        Database.insert(lstDeviceType); 
        
        System.debug('Total Number of SOQL Queries in device type: ' +  Limits.getQueries());
        
        //create device records
        List<Device__c> lstDevice = new List<Device__c> ();
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        lstDevice.add(objDevice);
        
        Device__c objDevice1 = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME_1 ,objDeviceType1 );
        lstDevice.add(objDevice1);
        
        Device__c objDevice2 = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME_2 ,objDeviceType2 );
        lstDevice.add(objDevice2);
        
        Database.insert(lstDevice);
        
        System.debug('Total Number of SOQL Queries in device: ' +  Limits.getQueries());
        
        //create reading records
        List<Reading__c> lstReading = new List<Reading__c> ();
        
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        lstReading.add(objReading); 
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice1);
        lstReading.add(objReading1); 
        
        Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice2);
        lstReading.add(objReading2);
        
        Database.insert(lstReading);
        
        System.debug('Total Number of SOQL Queries in reading: ' +  Limits.getQueries());
        
        //create location records
        List<Location__c> lstLocation = new List<Location__c> ();
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        lstLocation.add(objLocation);
        
        Location__c objLocation1 = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME_1);
        lstLocation.add(objLocation1);
        
        Location__c objLocation2 = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME_2);
        lstLocation.add(objLocation2);
        
        Database.insert(lstLocation);
        
        System.debug('Total Number of SOQL Queries in Location: ' +  Limits.getQueries());
        
        //create SupplyPointUsageType records
        List<SupplyPointUsageType__c> lstSupplyPointUsageType = new List<SupplyPointUsageType__c> ();
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        lstSupplyPointUsageType.add(objSupplyPointUsageType);
        
        SupplyPointUsageType__c objSupplyPointUsageType1 = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE_1);
        lstSupplyPointUsageType.add(objSupplyPointUsageType1);
        
        SupplyPointUsageType__c objSupplyPointUsageType2 = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE_2);
        lstSupplyPointUsageType.add(objSupplyPointUsageType2);
        
        Database.insert(lstSupplyPointUsageType);
        
        System.debug('Total Number of SOQL Queries in SP usage type: ' +  Limits.getQueries());
        
        //create SupplyPoint records
        List<SupplyPoint__c> lstSupplyPoint = new List<SupplyPoint__c> ();
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174
     	objSupplyPoint.Location__c = objLocation.Id;
        lstSupplyPoint.add(objSupplyPoint);
        
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation1, objSupplyPointUsageType1);
        objSupplyPoint1.Measured__c= True; // AT-3174
  
        lstSupplyPoint.add(objSupplyPoint1);
        
        SupplyPoint__c  objSupplyPoint2 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation2, objSupplyPointUsageType2);
        objSupplyPoint2.Measured__c= True; // AT-3174
 
        lstSupplyPoint.add(objSupplyPoint2);
        
        Database.insert(lstSupplyPoint);
        
        System.debug('Total Number of SOQL Queries in SP: ' +  Limits.getQueries());
        
        //create SupplyPointDevice records
        List<SupplyPointDevice__c> lstSupplyPointDevice = new List<SupplyPointDevice__c> ();
        
        SupplyPointDevice__c  objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        lstSupplyPointDevice.add(objSPD);
        
        SupplyPointDevice__c  objSPD1 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice1,objSupplyPoint1);
        lstSupplyPointDevice.add(objSPD1);
        
        SupplyPointDevice__c  objSPD2 = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice2,objSupplyPoint2);
        lstSupplyPointDevice.add(objSPD2);
        
        Database.insert(lstSupplyPointDevice);
        
        System.debug('Total Number of SOQL Queries in SPD: ' +  Limits.getQueries());
        
        //create Division records
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //create Wholesaler records
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //create ServiceType records
        List<ServiceType__c> lstServiceType = new List<ServiceType__c> ();
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        lstServiceType.add(objServiceType);
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE_1 );
        lstServiceType.add(objServiceType1);
        
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE_2 );
        lstServiceType.add(objServiceType2);
        
        Database.insert(lstServiceType);
        
        System.debug('Total Number of SOQL Queries in ST: ' +  Limits.getQueries());
        
        //create AvailableService records
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLE_SERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);  
        
        System.debug('Total Number of SOQL Queries in AS: ' +  Limits.getQueries());
        
        //create Service records
        List<Service__c> lstService = new List<Service__c>();
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint, objAvailableService);
        lstService.add(objService);
        
        Service__c  objService1 = GlUt_FactoryData_Test.CreateService(objContract,objReading1,objServiceType1,objSupplyPoint1, objAvailableService);
        lstService.add(objService1);
        
        Service__c  objService2 = GlUt_FactoryData_Test.CreateService(objContract,objReading2,objServiceType2,objSupplyPoint2, objAvailableService);
        lstService.add(objService2);
        Database.insert(lstService);
        
        System.debug('Total Number of SOQL Queries in Service: ' +  Limits.getQueries());
        
        //create ServiceItemFamily records
        List<ServiceItemFamily__c> lstServItemFamily = new List<ServiceItemFamily__c>();
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICE_ITEM_FAMILY,objServiceType); 
        objServiceItemFamily.PaymentPostCategory__c = '1';
        objServiceItemFamily.PaymentPostPriority__c = '1';
        lstServItemFamily.add(objServiceItemFamily);
        
        ServiceItemFamily__c  objServiceItemFamily1 = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICE_ITEM_FAMILY_1,objServiceType1); 
        objServiceItemFamily1.PaymentPostCategory__c = '2';
        objServiceItemFamily1.PaymentPostPriority__c = '2';
        lstServItemFamily.add(objServiceItemFamily1);
        
        ServiceItemFamily__c  objServiceItemFamily2 = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICE_ITEM_FAMILY_2,objServiceType2); 
        objServiceItemFamily2.PaymentPostCategory__c = '2';
        objServiceItemFamily2.PaymentPostPriority__c = '1';
        lstServItemFamily.add(objServiceItemFamily2);
        Database.insert(lstServItemFamily);
        
        System.debug('Total Number of SOQL Queries in SIF: ' +  Limits.getQueries());
            
        
        //create ServiceItemType records
        List<ServiceItemType__c> lstServiceItemType = new List<ServiceItemType__c>();
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICE_ITEM_TYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        lstServiceItemType.add(objServiceItemType);
        
        ServiceItemType__c  objServiceItemType1 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICE_ITEM_TYPE_1,objServiceItemFamily1,objDivision,objDeviceType1,objWholesaler);
        lstServiceItemType.add(objServiceItemType1);
        
        ServiceItemType__c  objServiceItemType2 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICE_ITEM_TYPE_2,objServiceItemFamily2,objDivision,objDeviceType2,objWholesaler);
        lstServiceItemType.add(objServiceItemType2);
        Database.insert(lstServiceItemType);
        
        System.debug('Total Number of SOQL Queries in SIT: ' +  Limits.getQueries());
        
        //create Bundle records
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);           
        
        System.debug('Total Number of SOQL Queries in Bundle__c: ' +  Limits.getQueries());
        
        //create AvailableBundle records
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLE_BUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        System.debug('Total Number of SOQL Queries in AvailableBundle__c: ' +  Limits.getQueries());
                
        //create BundleItem records
        List<BundleItem__c> lstBundleItem = new List<BundleItem__c>();
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLE_ITEM,objBundle,objServiceItemType,objServiceItemFamily);
        lstBundleItem.add(objBundleItem);
        
        BundleItem__c  objBundleItem1 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLE_ITEM_1,objBundle,objServiceItemType1,objServiceItemFamily1);
        lstBundleItem.add(objBundleItem1);
        
        BundleItem__c  objBundleItem2 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLE_ITEM_2,objBundle,objServiceItemType1,objServiceItemFamily2);
        lstBundleItem.add(objBundleItem2);
        Database.insert(lstBundleItem);
        
        System.debug('Total Number of SOQL Queries in BundleItem__c: ' +  Limits.getQueries());
        
        //create AvailableServiceItem records
        List<AvailableServiceItem__c> lstAvailServItem = new List<AvailableServiceItem__c>();
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLE_SERVICE_ITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        lstAvailServItem.add(objAvailableServiceItem);       
        
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLE_SERVICE_ITEM_1,objBundleItem1,objServiceItemType1,objAvailableBundle);
        lstAvailServItem.add(objAvailableServiceItem1);     
        
        AvailableServiceItem__c  objAvailableServiceItem2 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLE_SERVICE_ITEM_2,objBundleItem2,objServiceItemType2,objAvailableBundle);
        lstAvailServItem.add(objAvailableServiceItem2);      
        Database.insert(lstAvailServItem);    
        
        System.debug('Total Number of SOQL Queries in ASI: ' +  Limits.getQueries());
        
        //create ServiceItem records
        List<ServiceItem__c> lstServItem = new List<ServiceItem__c>();
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        lstServItem.add(objServiceItem);
        
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem1,objServiceItemType1,objService1);
        lstServItem.add(objServiceItem1);        
        
        ServiceItem__c  objServiceItem2 = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem2,objServiceItemType2,objService2);
        lstServItem.add(objServiceItem2);
        Database.insert(lstServItem);
        
        System.debug('Total Number of SOQL Queries in SI: ' +  Limits.getQueries());
        
        //create BillItem records        
        List<BillItem__c> lstBillItem = new List<BillItem__c>();
        BillItem__c objBillItem1 = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME_1, objServiceItem , VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID_1);
        objBillItem1.NetBilledAmount__c= 101;
        objBillItem1.SupplyPoint__c = objSupplyPoint.Id;
        
        lstBillItem.add(objBillItem1);
        //Database.insert(objBillItem1);
        
        System.debug('Total Number of SOQL Queries in BI: ' +  Limits.getQueries());
        
        /*BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME, objServiceItem1 , VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID);
        objBillItem.NetBilledAmount__c= 102;
        objBillItem.BillItem__c= objBillItem1.Id;
        lstBillItem.add(objBillItem);*/
        
        BillItem__c objBillItem2 = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME_2, objServiceItem, VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID_2);
        objBillItem2.NetBilledAmount__c= 103;
        objBillItem2.Bill__c= objBill.Id;
        lstBillItem.add(objBillItem2); 
        
        BillItem__c objBillItem3 = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME_3, objServiceItem , VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID_3);
        objBillItem3.NetBilledAmount__c= 104;
        objBillItem3.Bill__c= objBill.Id;
        lstBillItem.add(objBillItem3); 
        
       /* BillItem__c objBillItem4 = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME_4, objServiceItem , VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID_4);
        objBillItem4.NetBilledAmount__c= 105;
        objBillItem4.Bill__c= objBill.Id;
        objBillItem4.BillItem__c= objBillItem1.Id;
        lstBillItem.add(objBillItem4);*/
        
        BillItem__c objBillItem5 = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME_5, objServiceItem1 , VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID_5);
        objBillItem5.NetBilledAmount__c= 106;
        objBillItem5.Bill__c= objBill.Id;
        lstBillItem.add(objBillItem5);
        
        BillItem__c objBillItem6 = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME_6, objServiceItem2 , VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID_6);
        objBillItem6.NetBilledAmount__c= 107;
        objBillItem6.Bill__c= objBill.Id;
        lstBillItem.add(objBillItem6);   
        Database.insert(lstBillItem);    
        
        System.debug('Total Number of SOQL Queries in Bill Item: ' +  Limits.getQueries());
        
        //Create Payment record
        List<Payment__c> lstPayment = new List<Payment__c>();
        Payment__c objPayment= GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        objPayment.InstalmentAmountUnallocated__c = 10;
        
        lstPayment.add(objPayment); 
        
        //Create Payment record - to cover scenario of line 254
        Payment__c objPayment1= GlUt_FactoryData_Test.createPayment(objAccount1, objContract1);
        objPayment1.Amount__c = 1000;
        lstPayment.add(objPayment1);
        Database.insert(lstPayment); 
        
        System.debug('Total Number of SOQL Queries in Payment: ' +  Limits.getQueries());
        
        //Create Payment Allocation record
        PaymentAllocation__c objPaymentAllocation= GlUt_FactoryData_Test.createPaymentAllocation(PAYMENT_ALLOCATION_NAME, 100.00, objBillItem1, objInstalment, objPayment);
        Database.insert(objPaymentAllocation);    
        
        System.debug('Total Number of SOQL Queries in Payment Alloc: ' +  Limits.getQueries());
    }    
    
    static void getData(){
        if(userObj != Null)
            userObj = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
    }

    /******************************************************************************
    @author        Swati Mathur
    @date          16 Feb 2018
    @param         
    @return        Void   
    @description   
    *******************************************************************************/
    static testmethod void processInstalment_test()
    {
        
        system.debug('processInstalment_test***');
        getData();
        List<PaymentAllocationQueue__c> paymentAllocationQList = [SELECT id,name,Instalment__c,Instalment__r.InstalmentAmountOutstanding__c,Operation__c FROM PaymentAllocationQueue__c ];
        Map<Id, String> instalmentIdMap = new Map<Id, String>();
        for(PaymentAllocationQueue__c objPaymentAllocationQ : paymentAllocationQList) {
            
            String operation = objPaymentAllocationQ.Operation__c == null ? GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_INSERT : objPaymentAllocationQ.Operation__c;        
                        
            if(objPaymentAllocationQ.Instalment__c != null && objPaymentAllocationQ.Instalment__r.InstalmentAmountOutstanding__c > 0 && operation == GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_UPDATE
               && (instalmentIdMap.keySet() == null || instalmentIdMap.keySet().isEmpty() || !instalmentIdMap.containsKey(objPaymentAllocationQ.Instalment__c))) {
                   instalmentIdMap.put(objPaymentAllocationQ.Instalment__c, operation);
               }
        }
        
        System.runAs(userObj){
            Test.startTest();
            PaUt_ProcessPaymentAllocation.processInstalment(instalmentIdMap);
            Test.stopTest();           
        }
    }
     
    /******************************************************************************
    @author        Swati Mathur
    @date          16 Feb 2018
    @param         
    @return        Void   
    @description   
    *******************************************************************************/
    static testmethod void processBill_test()
    {
        system.debug('processBill_test ***');
        getData();
        List<PaymentAllocationQueue__c> paymentAllocationList = [SELECT id,name,BillItem__c,BillItem__r.AmountOutstanding__c,Operation__c FROM PaymentAllocationQueue__c ];
        
        Map<Id, String> billItemIdMap = new Map<Id, String>();
        for(PaymentAllocationQueue__c objPaymentAllocationQ : paymentAllocationList) {
            String operation = objPaymentAllocationQ.Operation__c == null ? GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_INSERT : objPaymentAllocationQ.Operation__c;
            
            if(objPaymentAllocationQ.BillItem__c != null && objPaymentAllocationQ.BillItem__r.AmountOutstanding__c > 0 
               && (billItemIdMap.keySet() == null || billItemIdMap.keySet().isEmpty() || !billItemIdMap.containsKey(objPaymentAllocationQ.BillItem__c))) {  
                   billItemIdMap.put(objPaymentAllocationQ.BillItem__c, operation);
               }
        }
                
        System.runAs(userObj){
            Test.startTest();
            PaUt_ProcessPaymentAllocation.processBill(billItemIdMap);
            Test.stopTest();   
        }
    }
}