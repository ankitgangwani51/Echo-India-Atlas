/******************************************************************************
@author:      Echo: Neha 
@date:        15-02-2018  
@description: Test Class for GlUt_BillItemHandler
*******************************************************************************/

@isTest 
public class GlUt_BillItemHandler_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String DEVICE_SIZE1 = 'TestDeviceSize1';
    private static final String MANUFACTURER = 'Aqua';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String	DEVICE_NAME = 'Meter';    
    private static final String	DEVICE_NAME1 = 'Meter1';  
    private static final String	BILL_ITEM_NAME = 'Water bill';
    private static final String	BILL_ITEM_NAME2 = 'Sewerage bill';
    private static final Integer USED_VOLUME = 50;	
    private static final Integer BILL_AMT = 100;
    private static final String HEROKU_PASTGRES_ID = 'Heroku Pastgress';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String CONTRACT_NAME = 'Con00021';
    private static final String SERVICE_TYPE = 'Water';
    private static final String BUNDLE_NAME = 'Water Bundle';
    private static final String SERVICE_ITEM_FAMILY = 'Service_Item_Family';
    private static final String WHOLESALER = 'abc';    
    private static final String BUNDLE_ITEM = 'Test_BundleItem';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';   
    private static final String AVAIL_SERVICE = 'WATER';
    private static final String AVAIL_SERVICE_ITEM = 'AvailableServiceItem_Test';
    private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
    private static final String AVAIL_BUNDLE_NAME = 'Avail Bundle Name';
    private static final String ZIPCODE = 'WS2 8DE';
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';
    private static final String BILL_NAME = 'Bill';
    private static final String BILL_SERVICE_TYPE = 'Payment';
    private static final Date START_DATE = system.today() - 65;
    private static final String PLAN_NAME = 'Monthly plan';
    private static final String PAYMENT_FREQ ='Monthly';
    private static final Integer NO_OF_INSTALMENT = 5;
    
    
    private static final String TOP_UP_DEVICE_ID;
    
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        15-02-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Contract Record            
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);                   
        
        // Create Location Record            
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        Database.insert(objLocation);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        objDeviceType.Multiplier__c = 5;
        Database.insert(objDeviceType);
        
        // Create Device Record            
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        objDevice.Digit__c = 5;
        Database.insert(objDevice);
        
        // Create Reading Record 
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);   
        objReading.ActualDeviceReading__c = '00000';
        objReading.ReadingDate__c = system.today();
        Database.insert(objReading); 
        
        // Create ServiceType Record            
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE);
        Database.insert(objServiceType);
        
        // Create Bundle Record            
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType);
        Database.insert(objBundle);
        
        // Create ServiceItemFamily Record            
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);
        Database.insert(objServiceItemFamily);
        
        // Create Division Record            
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record            
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler); 
        
        // Create ServiceItemType Record            
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, 
                                                                                            objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType);
        
        // Create BundleItem Record            
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record            
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174
        Database.insert(objSupplyPoint);
        
        // Create AvailableService Record            
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE, objDivision, objServiceType, objSupplyPoint, objWholesaler );
        Database.insert(objAvailableService);		
        
        // Create AvailableBundle Record            
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLE_BUNDLE, objBundle, objAvailableService );
        Database.insert(objAvailableBundle);
        
        // Create AvailableServiceItem Record            
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_BUNDLE_NAME, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        // Create Service Record            
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);
        
        // Create ServiceItem Record            
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        Database.insert(objServiceItem);
        
        // Create Bill Record            
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME, objContract);
        Database.insert(objBill);
        
        // Create BillServiceType Record            
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE, objBill, HEROKU_PASTGRES_ID);
        Database.insert(objBillServiceType); 
        
        // Create Payment Record            
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);           
        Database.insert(objPayment);  
        
        // Create PaymentPlanType__c Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME, PAYMENT_FREQ, NO_OF_INSTALMENT);           
        Database.insert(objPaymentPlanType);
        
         // Create PaymentPlan__c Record            
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract, BILL_AMT);           
        Database.insert(objPaymentPlan);
        
        // Create Instalment Record            
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);           
        Database.insert(objInstalment);                
    } 
    /******************************************************************************
	@author:      Echo: Neha
	@date:        15-02-2018  
	@description: Method for insert  a new record
	*******************************************************************************/
    static testmethod void insertBillItem()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
    
        BillItem__c objBillItem = new BillItem__c();
        objBillItem = createBillItem();
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objBillItem);            
            Test.stopTest();
        }          
        system.assert(objBillItem.id != null);        
    }
   
    /******************************************************************************
	@author:      Echo: Neha
	@date:        15-02-2018  
	@description: Method for update exiting record
	*******************************************************************************/
    static testmethod void updateBillItem(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        BillingContract__c objContract = [SELECT id FROM BillingContract__c LIMIT 1];   
        Instalment__c objInstalment = [SELECT id FROM Instalment__c LIMIT 1]; 
        Payment__c objPayment = [SELECT id FROM Payment__c LIMIT 1]; 
        
        BillItem__c objBillItem = new BillItem__c();
        
        objBillItem = createBillItem();
        
        Database.insert(objBillItem);
        
        // Create PaymentAllocationQueue Record            
        PaymentAllocationQueue__c objPaymentAllocationQueue = GlUt_FactoryData_Test.createPaymentAllocationQueue(objBillItem, objInstalment, objPayment);
        objPaymentAllocationQueue.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_PROCESSSED;
        Database.insert(objPaymentAllocationQueue); 
        
        // Create ManualAmendment Record            
        ManualAmendment__c objManualAmendment = GlUt_FactoryData_Test.createManualAmendment(objBillItem);
        Database.insert(objManualAmendment); 
        
        System.runAs(objUser){
            Test.startTest(); 
            objBillItem.ManualAmendment__c = objManualAmendment.id;
            objBillItem.StartDate__c = system.today();
            update objBillItem;
            Test.stopTest();
        }
        
        system.assert(objBillItem.StartDate__c == system.today());
    }
    /******************************************************************************
	@author:      Echo: Neha
	@date:        15-02-2018  
	@description: Method for Delete a new record
	*******************************************************************************/
    static testmethod void deleteBillItem()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
    
        BillItem__c objBillItem = new BillItem__c();
        objBillItem = createBillItem();
        Database.insert(objBillItem);
       
        System.runAs(objUser){
            Test.startTest();             
            Database.delete(objBillItem.Id);         
            Test.stopTest();
        }
        
        List<BillItem__c> listBillItem = [SELECT Id FROM BillItem__c];
        system.assert (listBillItem.size() == 0 );
    }
        
    /******************************************************************************
	@author:      Echo: Neha
	@date:        16-02-2018  
	@description: Internal Method for BillItem object
	*******************************************************************************/
    private static BillItem__c createBillItem() 
    {   
     	Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        Reading__c objReading = [SELECT Id FROM Reading__c LIMIT 1];
        ServiceItem__c objServiceItem = [SELECT Id FROM ServiceItem__c LIMIT 1];        
        BillServiceType__c objBillServiceType = [SELECT Id FROM BillServiceType__c LIMIT 1];  
        
        // Create Bill Item Record
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME2, objServiceItem, USED_VOLUME, BILL_AMT, objBillServiceType, HEROKU_PASTGRES_ID);
        objBillItem.TopUpDeviceId__c = objDevice.Id;
        objBillItem.TopUpId__c = objReading.Id;
        objBillItem.Reading__c = objReading.Id;
        objBillItem.TopUpValue__c = 100;
                
        return objBillItem;
	}
   
}