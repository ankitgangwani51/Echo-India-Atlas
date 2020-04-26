/******************************************************************************
@author         Ankit Gangwani
@date           12 Feb 2018
@description    Test Class For CuAp_ManageDiscountsCtrlr
*******************************************************************************/
@isTest
public class CuAp_ManageDiscountsCtrlr_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String ACCOUNT_NAME 			= 'TestAccount'; 
    private static final String CONTRACT_NAME 		 	= 'TestContract';
    private static final String DEVICE_TYPE_NAME 		= 'Meter';
    private static final String DEVICE_NAME 			= '123456789';
    private static final String DISCOUNT_NAME 	     	= 'Discount Type - 1';    
    private static final String DISCOUNT_TYPE 	 	 	= 'Percentage';    
    private static final String SERVICE_TYPE_NAME 		= 'Water';
    private static final String LOCATION_NAME 			= 'A99 9AA';
    private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';    
    private static final String MEASURED 				= 'Yes';
    private static final String READFREQUENCY 			='Monthly';    
    private static final String SERVICE_NAME 			= 'S-1442';
    private static final String WHOLESALER_NAME			= 'Wholesale System';
    private static final String BUNDLE 					= 'TestBundle';
    private static final String SERVICE_ITEM_FAMILYNAME = 'Measured Water Volumetric';
    private static final String SERVICE_ITEM_TYPE 		= 'Measured Water Volumetric';
    private static final String AVAILABLEBUNDLE 		= 'TestAvailableBundle';
    private static final String BUNDLEITEM 				= 'TestBundleItem';
    private static final String AVAILABLESERVIEITEM		= 'TestAvailableServiceItem';
    private static final String INVALID_CONTRACT_ID 	= 'ABC';
    private static final String INVALID_DISCOUNT_ID 	= 'ABC';
    private static final Decimal PERCENTAGE_DISC_AMOUNT = 5.0;
    private static final String DEVICE_SIZE				= 'TestDeviceSize';
    private static final String MANUFACTURER 			= 'Siemens';
    private static final String UNIT_OF_MEASURE 		= 'Metric';
    private static final Date START_DATE 		 	 	= date.valueOf('2018-02-01');
    private static final Date END_DATE 		 			= date.valueOf('2018-02-28');
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          12 Feb 2018
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){ 
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME); 
        Database.insert(objAccount);
        
        // Create Contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        Database.insert(objContract);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        // Create ServiceType Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE_NAME);
        Database.insert(objServiceType);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        // Create AvailableService Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService); 
        
        //Create bundle record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        // Create ServiceItemFamily Record
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILYNAME,objServiceType);
        Database.insert(objServiceItemFamily); 
        
        // Create erviceItemType Record
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType); 
        
        //Create Bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create available bundle record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = START_DATE;
        objServiceItem.EndDate__c = END_DATE;
        Database.insert(objServiceItem);
        
        // Create Discount Type Record
        DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(DISCOUNT_NAME, START_DATE, END_DATE, DISCOUNT_TYPE, PERCENTAGE_DISC_AMOUNT);
        Database.insert(objDiscountType); 
        
        // Create Discount Record
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);
        Database.insert(objDiscount);   
        
        // Create Discount Type Item Record
        DiscountTypeitem__c objDiscountTypeItem = GlUt_FactoryData_Test.createDiscountTypeitem(objDiscountType, objServiceItemType);
        Database.insert(objDiscountTypeItem);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Discount field Details in POSITIVE scenario
    *******************************************************************************/
    static testmethod void retrieveDiscountFieldPropDetails_Positive()
    {            
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<GLAp_FieldProps> discountProps = new List<GLAp_FieldProps>();
        
        System.runAs(objUser){
            Test.startTest();
            discountProps = CuAp_ManageDiscountsCtrlr.retrieveDiscountPropDetails();
            Test.stopTest();
        }
        System.assert(discountProps != null);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Discount field Details in POSITIVE scenario
    *******************************************************************************/
    static testmethod void retrieveDiscountRecords_Positive()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        BillingContract__c objContract = [select Id from BillingContract__c limit 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            combineRecordList = CuAp_ManageDiscountsCtrlr.retrieveDiscountTypeRecords(objContract.Id);
            Test.stopTest();
        }        
        System.assert(combineRecordList != null);  
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Discount field Details in Negative scenario
    *******************************************************************************/
    static testmethod void retrieveDiscountRecords_Negative()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        BillingContract__c objContract = new BillingContract__c();
        boolean isException;
        
        System.runAs(objUser){            
            Test.startTest();
            combineRecordList = CuAp_ManageDiscountsCtrlr.retrieveDiscountTypeRecords(objContract.Id);           
            Test.stopTest();            
        }        
        System.assert(combineRecordList.size() == 0);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Discount field Details in Invalid Negative scenario
    *******************************************************************************/
    static testmethod void retrieveDiscountRecordsInValidVal_Negative()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        boolean isException;
        
        System.runAs(objUser){
            try{
                Test.startTest();
                combineRecordList = CuAp_ManageDiscountsCtrlr.retrieveDiscountTypeRecords(INVALID_CONTRACT_ID);           
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }        
        System.assert(combineRecordList.size() == 0);
        System.assertEquals(combineRecordList.isEmpty(),true,'Negative scenario passed');   
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Bill Item field Details in POSITIVE scenario
    *******************************************************************************/
    static testmethod void retrieveBillItemsFieldPropDetails_Positive()
    {            
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<GLAp_FieldProps> billItemsProps = new List<GLAp_FieldProps>();
        
        System.runAs(objUser){
            Test.startTest();
            billItemsProps = CuAp_ManageDiscountsCtrlr.retrieveBillItemsfieldList();
            Test.stopTest();
        }
        System.assert(billItemsProps != null);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Bill Item field Details in POSITIVE scenario
    *******************************************************************************/
    static testmethod void retrieveBillItemRecords_Positive()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        Discount__c objDiscount = [select Id from Discount__c limit 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            combineRecordList = CuAp_ManageDiscountsCtrlr.retrieveBillItemsrecordList(objDiscount.Id);
            Test.stopTest();
        }        
        System.assert(combineRecordList != null);  
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Bill Item field Details in Negative scenario
    *******************************************************************************/
    static testmethod void retrieveBillItemRecords_Negative()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        Discount__c objDiscount = new Discount__c();
        boolean isException;
        
        System.runAs(objUser){            
            Test.startTest();
            combineRecordList = CuAp_ManageDiscountsCtrlr.retrieveDiscountTypeRecords(objDiscount.Id);           
            Test.stopTest();            
        }        
        System.assert(combineRecordList.size() == 0);
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        12 Feb 2018
    @description: Test Method to check retrieve Bill Item field Details in Invalid Negative scenario
    *******************************************************************************/
    static testmethod void retrieveBillItemRecordsInValidVal_Negative()
    {
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<BlAp_CombinedRecord> combineRecordList = new List<BlAp_CombinedRecord>();        
        boolean isException;
        
        System.runAs(objUser){
            try{
                Test.startTest();
                combineRecordList = CuAp_ManageDiscountsCtrlr.retrieveDiscountTypeRecords(INVALID_DISCOUNT_ID);           
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
        }        
        System.assert(combineRecordList.size() == 0);
        System.assertEquals(combineRecordList.isEmpty(),true,'Negative scenario passed');   
    }
}