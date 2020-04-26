/******************************************************************************
@author         Echo: Swati Mathur
@date           15 Feb 2018
@description    Test Class for PaBt_ProcessPayAllocQueueBatch
@Revisions	    AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class PaBt_ProcessPayAllocQueueBatch_Test {
    
    private static String USERPROFILE = 'System Administrator';
    private static final String USERFNAME= 'TestFName';
    private static final String USERLNAME= 'TestLName';
    private static String USERNAME = 'TestUser';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount';    
    private static String PAYMENTALLOCATIONNAME = 'TestPaymentAllocation';
    private static String BILLINGSTREET ='Test Street';
    private static String BILLINGCITY = 'Test City';
    private static String BILLINGSTATE = 'Test State';
    private static String BILLINGPOSTCODE ='0000000';
    private static String BILLINGCOUNTRY ='Test Country';
    private static String PAYMENTPLANTYPENAME = 'Test Payment Plan Type1';
    private static String FREQUENCY = 'Monthly';
    private static Integer MAXINSTALMENT = 12;
    private static Integer PLANAMOUNT = 12345;
    private static Integer NUMBEROFINSTALMENTS = 07; 
    private static Integer AMOUNTOUTSTANDING = 200; 
    private static String PLANTYPE = 'Instalment Plan';
    private static final String SPUSAGETYPE = 'SupplyPointUsageType';
    private static String DEVICENAME = 'TestDevice';
    private static String DEVICETYPE ='TestDeviceType';
    private static final String DEVICESIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNITOFMEASURE = 'Metric';
    private static String TESTSERVICETYPE ='TestServiceType';
    private static String LOCATIONNAME ='A99 9AA';
    private static String WHOLESALER ='TestWholesaler';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static String SERVICEITEMTYPE ='TestServiceitemtype';
    private static String BUNDLE ='TestBundle';
    private static String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String BILLNAME = 'testBill';
    private static String BILLSERVICENAME = 'Test Bill Service';
    private static String BILLITEMNAME = 'Test Bill Item';
    private static Integer VOLUMEUSED = 200;
    private static Integer BILLEDAMOUNT = 67878;
    private static String HEROKUPOSTGRESID = 'Test ID';
       
    /******************************************************************************
    @author        Swati Mathur
    @date          15 Feb 2018
    @param         -
    @return        Void   
    @description   Setup Method for Initialize Data for Unit Testing
    *******************************************************************************/ 
    @testSetup
    static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE,USERNAME,null);
        objUser.FirstName = USERFNAME;
        objUser.LastName = USERLNAME;
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLINGSTREET;
        objContract.BillingCity__c=BILLINGCITY;
        objContract.BillingState__c=BILLINGSTATE;
        objContract.BillingPostalCode__c=BILLINGPOSTCODE;
        objContract.BillingCountry__c=BILLINGCOUNTRY;
        Database.insert(objContract); 
        
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPENAME, FREQUENCY, MAXINSTALMENT);
        objPaymentPlanType.PlanType__c = PLANTYPE;
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLANAMOUNT);
        Database.insert(objPaymentPlan);
         
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        objInstalment.InstalmentAmountDue__c= AMOUNTOUTSTANDING;         
        objInstalment.InstalmentDueDate__c= System.today();        
        Database.insert(objInstalment);
       
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,objContract);
        objBill.Account__c = objAccount.id; //AT-3174
        Database.insert(objBill);
       
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
       
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICESIZE);
        Database.insert(objDeviceSize);        
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNITOFMEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
                
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading); 
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATIONNAME);
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SPUSAGETYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174
   
        Database.insert(objSupplyPoint);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        SupplyPointDevice__c  objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICETYPE );
        Database.insert(objServiceType);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint, objAvailableService);
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
        objServiceItem.StartDate__c = Date.today();
        Database.insert(objServiceItem);
        
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        objBillItem.NetBilledAmount__c= AMOUNTOUTSTANDING;
        Database.insert(objBillItem);         
        
        Payment__c objPayment= GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        Database.insert(objPayment); 
        
        PaymentAllocation__c objPaymentAllocation= GlUt_FactoryData_Test.createPaymentAllocation(PAYMENTALLOCATIONNAME, 100.00, objBillItem, objInstalment, objPayment);
        Database.insert(objPaymentAllocation);    
        
    }    

    /******************************************************************************
    @author        Swati Mathur
    @date          15 Feb 2018
    @param         
    @return        Void   
    @description   Method to Run PaBt_ProcessPayAllocQueueBatch Schedule job 
    *******************************************************************************/
    static testmethod void runScheduleJob()
    {
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        
        System.runAs(objUser){
            PaBt_ProcessPayAllocQueueBatch batchObject = new PaBt_ProcessPayAllocQueueBatch();            
            String SchedulerName  = 'Process PayAllocQueue Batch';
            String sCronExp = '0 1 * * * ? *';
            
            Test.startTest();
            Database.executeBatch(batchObject);
            String jobID = System.schedule(SchedulerName, sCronExp, batchObject);            
            Test.stopTest();   
            System.assert(jobID != null);
        }
    }
}