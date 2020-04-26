/******************************************************************************
@author:      Echo: Swati Mathur
@date:        05 Apr 2018
@description: Test Class for GlUt_DiscountContractFinder
*******************************************************************************/
@isTest
public class GlUt_DiscountContractFinder_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static String USER_FNAME= 'FN123';
    private static String USER_LNAME= 'LN123';
    private static String ACCOUNT_NAME = 'TestAccount';    
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static String DEVICE_NAME = 'TestDevice';
    private static String DEVICE_SIZE = 'TestDeviceSize';
    private static String SERVICE_TYPE ='TestServiceType';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLE_SERVICES ='TestAvailableService';
    private static String SERVICE_ITEM_FAMILY ='TestServiceItemFamily';
    private static String SERVICE_ITEM_TYPE ='TestServiceitemtype';
    private static String MANUFACTURER = 'Siemens';
    private static String UNIT_OF_MEASURE = 'Metric';
    private static String DISCOUNT_NAME = 'Discount Type - 1';    
    private static String DISCOUNT_TYPE = 'Percentage';  
    private static Decimal PERCENTAGE_DISC_AMOUNT = 5.0;
    private static Date START_DATE = date.valueOf('2018-02-01');
    private static Date END_DATE = date.valueOf('2018-02-28');
   
    
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method to create dummy data
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        //create Account records
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);       
        
        //create Contract records
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        Database.insert(objContract);
               
        //create ServiceType records
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(SERVICE_TYPE );
        Database.insert(objServiceType);
        
        //create ServiceItemFamily records
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICE_ITEM_FAMILY,objServiceType); 
        Database.insert(objServiceItemFamily);
        
        //create device size records        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize); 
        
        //create device type records
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
       
        //create device records
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        //create reading records
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);         
        
        //create Division records
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //create Wholesaler records
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //create ServiceItemType records
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICE_ITEM_TYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);        
        
        // Create Discount Type Record
        DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(DISCOUNT_NAME, START_DATE, END_DATE, DISCOUNT_TYPE, PERCENTAGE_DISC_AMOUNT);
        Database.insert(objDiscountType); 
        
        // Create Discount Record
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);
        Database.insert(objDiscount);  
        
    }
    
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method for retrieveContractIds() method
    *******************************************************************************/    
    static testmethod void retrieveContractIds_positive(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        Set<Id> contractIds = new Set<Id>();  
        String sobjectType;
        
        Discount__c objDisc = [SELECT Id FROM Discount__c ];       
        
        System.runAs(objUser){            
            Test.startTest();
            GlUt_DiscountContractFinder obj = new GlUt_DiscountContractFinder();
            contractIds = obj.retrieveContractIds(objDisc.Id);            
            Test.stopTest();           
            
            for(Id id : contractIds){                
                sobjectType = id.getSObjectType().getDescribe().getName();
            }
            System.assertEquals(GlUt_APIConstantsContracts.CONTRACTAPINAME, sobjectType);
        }
    }         
    
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method for retrieveContractIds() method - negative scenario
    *******************************************************************************/    
    static testmethod void retrieveContractIds_negative(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        Set<Id> contractIds = new Set<Id>();
        String sobjectType;
        
        Account objAcc = [SELECT Id FROM Account ];       
        
        System.runAs(objUser){            
            Test.startTest();
            GlUt_DiscountContractFinder obj = new GlUt_DiscountContractFinder();
            contractIds = obj.retrieveContractIds(objAcc.Id);            
            Test.stopTest();
            
            System.assertEquals(0, contractIds.size());
        }
    }

}