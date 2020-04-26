/******************************************************************************
@author:      Echo: Neha R.
@date:        01-02-2018  
@description: Test Class for PyAp_BillPaymentHistoryCtrlr
*******************************************************************************/
@isTest
public class PyAp_BillPaymentHistoryCtrlr_Test {

    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String BILL_ITEM_NAME = 'BillItem_Test';
    private static final Integer USED_VOLUME = 50;
    private static final Integer BILLED_AMOUNT = 150;
    private static final String HEROKU_POSTGRESID = 'XYZ';
    private static final String BILL_SERVICE_TYPE_NAME = 'BillServiceType_Test';
    private static final String BILL_NAME = 'Test_Bill';
    private static final String CONTRACT_NAME = 'Test_Contract';
    private static final String ACCOUNT_NAME = 'Test_Account';
    private static final String AVAIL_SERVICE_ITEM = 'AvailableServiceItem_Test';
    private static final String BUNDLE_ITEM = 'Test_BundleItem';
    private static final String BUNDLE_NAME = 'Bundle_Test';
    private static final String SERVICE_TYPE = 'Service_Type';    
    private static final String SERVICE_ITEM_FAMILY = 'Service_Item_Family';
    private static final String SERVICE_ITEM_TYPE = 'Service_Item_Type';
    private static final String WHOLESALER = 'abc';
    private static final String DEVICE_TYPE = 'small Meter';
	private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
	private static final String AVAIL_SERVICE = 'WATER';
	private static final String ZIPCODE = 'WS2 8DE';	
	private static final String	DEVICE_NAME = 'Meter';		
	private static final String	PAYMENT_PLAN_TYPE = 'New Payment Plan';
	private static final Integer PLAN_AMOUNT = 50;
	private static final Integer NO_OF_INSTALLMENT = 12;
	private static final String	PAYMENT_ALLOCATION = 'Payment Allocation'; 
	private static final decimal ALLOCATION_AMOUNT = 50;
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';
    private static final String INVALID_BILL_ID = 'ABC';
    private static final String INVALID_PAYMENT_ID = 'ABC';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String PAYMENT_FREQ = 'Monthly';
    private static final Integer MAX_INSTALLMENT = 12;
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    	 
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);       
          
        // Create ServiceType Record            
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE);
        Database.insert(objServiceType);
                
        // Create ServiceItemFamily Record            
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);
        Database.insert(objServiceItemFamily);
        
        // Create Division Record            
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);        
        
        // Create Wholesaler Record            
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);    
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create ServiceItemType Record            
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType);
        
        // Create Bundle Record            
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType);
        Database.insert(objBundle);
       
        // Create BundleItem Record            
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);	

		// Create Location Record            
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        Database.insert(objLocation);
		
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
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);
        
		// Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
		
		// Create Contract Record            
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
		
		// Create Device Record            
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        Database.insert(objDevice); 
		
		// Create Reading Record            
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading); 
  
		// Create Service Record            
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);  
  
        // Create ServiceItem Record            
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = Date.today();        
        Database.insert(objServiceItem);         
          
        // Create Bill Record            
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME, objContract);
        Database.insert(objBill);
        
        // Create BillServiceType Record            
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE_NAME, objBill, HEROKU_POSTGRESID);
        Database.insert(objBillServiceType);         
          
        // Create BillItem Record            
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME, objServiceItem, USED_VOLUME , BILLED_AMOUNT , objBillServiceType , HEROKU_POSTGRESID);
        objBillItem.Bill__c = objBill.id;
        Database.insert(objBillItem);         
            
		// Create Payment Record            
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        Database.insert(objPayment);
		
		// Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE, PAYMENT_FREQ, MAX_INSTALLMENT);
        Database.insert(objPaymentPlanType);
			
		// Create PaymentPlan Record            
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract, PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
		
		// Create Instalment Record            
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        Database.insert(objInstalment);
			
		// Create PaymentAllocation Record            
        PaymentAllocation__c objPaymentAllocation = GlUt_FactoryData_Test.createPaymentAllocation(PAYMENT_ALLOCATION, ALLOCATION_AMOUNT, objBillItem, objInstalment, objPayment);
        Database.insert(objPaymentAllocation); 
    }
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Payment field Details in POSITIVE scenario
	*******************************************************************************/
    static testmethod void retrievePaymentFieldPropDetails_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<GLAp_FieldProps> paymentProps = new List<GLAp_FieldProps>();
        
        System.runAs(objUser){
            Test.startTest();
            paymentProps = PyAp_BillPaymentHistoryCtrlr.retrievePaymentFieldPropDetails();           
            Test.stopTest();
        }
        
        System.assert(paymentProps != null);
    }
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Payment field Details in POSITIVE scenario
	*******************************************************************************/
    static testmethod void retrievePaymentRecords_Positive()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        Bill__c objBill = [SELECT Id FROM Bill__c LIMIT 1];
            
        System.runAs(objUser){
            Test.startTest();
            combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrievePaymentRecords(objBill.Id);           
            Test.stopTest();
        }        
        System.assert(combineRecordList != null);  
    }
    
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Payment field Details in Negative scenario
	*******************************************************************************/
    static testmethod void retrievePaymentRecords_Negative()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        Bill__c objBill = new Bill__c();
        boolean isException;
            
        System.runAs(objUser){
            try{
            	Test.startTest();
            	combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrievePaymentRecords(objBill.Id);           
            	Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assert(combineRecordList.isEmpty() == true);                
        System.assert(combineRecordList.size() == 0);
        
        List<Bill__c> ListBill = [select Id from bill__c where id = :objBill.Id];
        System.assert(ListBill.size() == 0);
    }
    
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Payment field Details in Negative scenario
	*******************************************************************************/
    static testmethod void retrievePaymentRecordsInValidVal_Negative()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        boolean isException;
                    
        System.runAs(objUser){
            try{
            	Test.startTest();
            	combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrievePaymentRecords(INVALID_BILL_ID);           
            	Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        System.assert(combineRecordList.isEmpty() == true);  
        System.assert(combineRecordList.size() == 0);
        List<Bill__c> BillList= [SELECT Id FROM bill__c WHERE id = :INVALID_BILL_ID ];
        System.assert(BillList.size() == 0);
    }
   
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Payment field Details in POSITIVE scenario
	*******************************************************************************/
    static testmethod void retrieveBillItmPropDetails_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<GLAp_FieldProps> billProps = new List<GLAp_FieldProps>();
        
        System.runAs(objUser){
            Test.startTest();
            billProps = PyAp_BillPaymentHistoryCtrlr.retrieveBillItmPropDetails();           
            Test.stopTest();
        }        
        System.assert(billProps != null);
    }
    
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Bill Items Details in POSITIVE scenario
	*******************************************************************************/
    static testmethod void retrieveBillItems_Positive()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>(); 
        
        Bill__c objBill = [SELECT Id FROM Bill__c LIMIT 1];
        Payment__c objPayment =  [SELECT id FROM Payment__c LIMIT 1];
            
        System.runAs(objUser){
            Test.startTest();
            combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrieveBillItems(objPayment.Id, objBill.Id);           
            Test.stopTest();
        }
        System.assert(combineRecordList != null);  
    }
   
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Bill Items Details in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void retrieveBillItemsNullBillID_Negative()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>(); 
        Boolean isException;
        
        Bill__c objBill = new Bill__c();
        Payment__c objPayment =  [select id from Payment__c limit 1];
            
        System.runAs(objUser){
            try{
            	Test.startTest();
            	combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrieveBillItems(objPayment.Id, objBill.Id);  
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            
        }        
        system.assert(combineRecordList.isEmpty() == true);
        System.assert(combineRecordList.size() == 0);  
        
        List<Bill__c> BillList= [SELECT id FROM bill__c WHERE id = :objBill.Id];
        System.assert(BillList.size() == 0);

    }
   
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Bill Items Details in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void retrieveBillItemsNullPaymentID_Negative()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>(); 
        Boolean isException;
        
        Bill__c objBill = [SELECT Id FROM Bill__c LIMIT 1];
        Payment__c objPayment = new Payment__c();
            
        System.runAs(objUser){
            try{
            	Test.startTest();
            	combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrieveBillItems(objPayment.Id, objBill.Id);           
            	Test.stopTest();
            }catch(Exception e)
            {
                isException = true;
            }
        } 
        
        List<Payment__c> paymentList= [SELECT id FROM Payment__c WHERE id = :objPayment.Id];
        System.assert(paymentList.size() == 0); 
        
        system.assert(combineRecordList.isEmpty() == true);
        System.assert(combineRecordList.size() == 0); 
        
    }
    
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Bill Items Details in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void retrieveBillItemsInvalidBillID_Negative()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>(); 
        Boolean isException;    
        
        Payment__c objPayment =  [SELECT Id FROM Payment__c LIMIT 1];
            
        System.runAs(objUser){
            try{
            	Test.startTest();
            	combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrieveBillItems(objPayment.Id, INVALID_BILL_ID);           
            	Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        
        List<Bill__c> listBill =  [SELECT Id FROM Bill__c WHERE id = :INVALID_BILL_ID LIMIT 1];        
        system.assert(listBill.size() == 0);
        
        system.assert(combineRecordList.isEmpty() == true);
        System.assert(combineRecordList.size() == 0); 
        
    }
   
    /******************************************************************************
	@author:      Echo: Neha R.
	@date:        01-02-2018  
	@description: Test Method to check retrieve Bill Items Details in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void retrieveBillItemsInvalidPaymentID_Negative()
    {
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>(); 

        Boolean isException;
        
        Bill__c objBill = new Bill__c();  
            
        System.runAs(objUser){
            try{
            	Test.startTest();
            	combineRecordList = PyAp_BillPaymentHistoryCtrlr.retrieveBillItems(INVALID_PAYMENT_ID, objBill.Id);           
            	Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }
        List<Payment__c> paymentList= [SELECT Id FROM Payment__c WHERE Id = :INVALID_PAYMENT_ID];
        System.assert(paymentList.size() == 0);
        
        system.assert(combineRecordList.isEmpty() == true);
        System.assert(combineRecordList.size() == 0);  
    }
}