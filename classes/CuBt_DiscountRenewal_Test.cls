/******************************************************************************
@author         Echo : Ankit Gangwani
@date           04 Dec 2018
@description    Batch Class For CuBt_DiscountRenewal 
*******************************************************************************/
@isTest
public class CuBt_DiscountRenewal_Test {
    
    private static final String USER_PROFILE 			='System Administrator';
    private static final String USER_NAME 				='FN123LN123'; 
    private static final String USER_FNAME				= 'FN123';	
    private static final String USER_LNAME				= 'LN123';
    private static final String ACCOUNT_NAME            = 'TestAccount';
    private static final String sName					= 'Test';
    private static final String SERVICEITEMFAMILY 		= 'TestServiceItemFamily';
    private static final String WHOLESALER 				= 'TestWholesaler';
    private static final String DEVICE_SIZE 			= 'TestDeviceSize';
    private static final String MANUFACTURER 			= 'Siemens';
    private static final String UNIT_OF_MEASURE 		= 'Metric';
    private static final String AVAILABLESERVIEITEM		= 'TestAvailableServiceItem';
    private static final String SERVICEITEMTYPE 		= 'TestSrvItemType'; 
    private static final String STREET		 			= 'Test Street';
    private static final String CITY 					= 'Test City';
    private static final String STATE				 	= 'Test State';
    private static final String COUNTRY 				= 'Test Country';
    private static final String LOCATION_NAME 			= 'A99 9AA';
    private static final String LOCATION_SUB_TYPE 		= 'Detached';
    private static final String MEASURED 				= 'Monthly';
    private static final String AVAILABLESERVICES 		= 'TestAvailableService';
    private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';
    private static final String BUNDLENAME  			= 'TestBundle';
    private static final String BUNDLEITEM 				= 'TestBundleItem';
    private static final String recordTypeId 			= Schema.SObjectType.DiscountType__c.getRecordTypeInfosByName().get(System.Label.CuAp_BillToBillDiscount).getRecordTypeId();
    
    private class BRQParameters_JSON {
        private List<Id> discountTypeID = new List<Id>();
    }
    
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          04 Dec 2018   
    @param         -
    @return        Void   
    @description   Setup Method for Unit Testing
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        //Create account
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Concession
        Concession__c objConcession = new Concession__c();
        objConcession.Validated__c = TRUE;
        objConcession.Account__c = objAccount.Id;
        objConcession.ConsentDate__c = Date.today().addDays(-35);
        Database.insert(objConcession);
        
        //Create Contract
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        Database.insert(objContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.City__c = CITY;
        objLocation.State__c = STATE;
        objLocation.Street__c = STREET;
        objLocation.Country__c = COUNTRY;
        Database.insert(objLocation);
        
        //Create Service Type
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(sName);
        Database.insert(objServiceType);
        
        //Create Service Item Family Record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point Record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        
        // Create First Bundle Record
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
        
        //Create First Service Item Type Record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        //Create First Bundle Item Record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Available Bundle Record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        // Create First Available Service Item Record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        Database.insert(objAvailableServiceItem); 
        
        //Create Service Record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,null,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        //Create First Service Item Record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem);
        
        //Create Next Financial year Discount Type
        DiscountType__c newDiscountType = GlUt_FactoryData_Test.createDiscountType(sName, Date.today().addMonths(10), Date.today().addMonths(12), null, null);
        newDiscountType.DiscountPerDay__c = 12.00;        
        Database.insert(newDiscountType);
        
        //Create Discount Type
        DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(sName, Date.today(), Date.today().addDays(10), null, null);
        objDiscountType.RecordTypeId = recordTypeId;
        objDiscountType.DiscountPerDay__c = 10.00;
        objDiscountType.DiscountType__c = newDiscountType.Id;
        Database.insert(objDiscountType);
        
        //Create Discount Type Item
        DiscountTypeitem__c objDiscountTypeItem = GlUt_FactoryData_Test.createDiscountTypeitem(objDiscountType, objServiceItemType);
        Database.insert(objDiscountTypeItem);
        
        //Cretae Discount
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);
        objDiscount.BaseDailyDiscountAmount__c = 17.50;
        objDiscount.Concession__c = objConcession.Id;
        objDiscount.EndDate__c = null;
        objDiscount.StartDate__c = Date.today();
        Database.insert(objDiscount);     
        
        BRQParameters_JSON brqObj = new  BRQParameters_JSON();
        brqObj.discountTypeID.add(objDiscountType.Id);
        
        //Create BatchRequestQueue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Parameters__c = JSON.serialize(brqObj);
        Database.insert(objBatchRequestQueue);
    }
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          04 Dec 2018
    @return        Void   
    @description   Method To test Renewal of Concessions Discount
    *******************************************************************************/     
    static testmethod void TestRenewalDiscount_Positive(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BatchRequestQueue__c BatchRequestQueue = [select Id , Parameters__c from BatchRequestQueue__c limit 1]; 
        
        System.runAs(objUser[0]){
            try{
                Test.starttest();
                CuBt_DiscountRenewal discountRenew = new CuBt_DiscountRenewal();
                discountRenew.Initialise(BatchRequestQueue);
                DataBase.executeBatch(discountRenew);
                Test.stoptest();
            }catch (exception e){
                GlUt_Logger.logException(e);
            } finally {   
                GlUt_Logger.writeLogsToDatabase();
            }
            List<Discount__c> discounts = [SELECT Id FROM Discount__c];            
            System.assert(discounts.size() == 2);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          04 Dec 2018
    @return        Void   
    @description   Method To test Renewal of Concessions Discount
    *******************************************************************************/     
    static testmethod void TestRenewalDiscount_Negative(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BatchRequestQueue__c BatchRequestQueue = [select Id , Parameters__c from BatchRequestQueue__c limit 1]; 
        BatchRequestQueue.Parameters__c = null;
        update BatchRequestQueue;
        
        System.runAs(objUser[0]){
            try{
                Test.starttest();
                CuBt_DiscountRenewal discountRenew = new CuBt_DiscountRenewal();
                discountRenew.Initialise(BatchRequestQueue);
                DataBase.executeBatch(discountRenew);
                Test.stoptest();
            }catch (exception e){
                GlUt_Logger.logException(e);
            } finally {   
                GlUt_Logger.writeLogsToDatabase();
            }
            List<Discount__c> discounts = [SELECT Id FROM Discount__c];            
            System.assert(discounts.size() == 1);
        }
    }
    
     /******************************************************************************
    @author        Ankit Gangwani
    @date          04 Dec 2018
    @return        Void   
    @description   Method To test Renewal of Concessions Discount
    *******************************************************************************/     
    static testmethod void TestRenewalDiscount_Negative2(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BatchRequestQueue__c BatchRequestQueue = [select Id , Parameters__c from BatchRequestQueue__c limit 1]; 
        BatchRequestQueue.Parameters__c = '';
        update BatchRequestQueue;
        
        System.runAs(objUser[0]){
            try{
                Test.starttest();
                CuBt_DiscountRenewal discountRenew = new CuBt_DiscountRenewal();
                discountRenew.Initialise(BatchRequestQueue);
                DataBase.executeBatch(discountRenew);
                Test.stoptest();
            }catch (exception e){
                GlUt_Logger.logException(e);
            } finally {   
                GlUt_Logger.writeLogsToDatabase();
            }
            List<Discount__c> discounts = [SELECT Id FROM Discount__c];            
            System.assert(discounts.size() == 1);
        }
    }
}