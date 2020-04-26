/******************************************************************************
@author:      Echo: Swati Mathur
@date:        05 Apr 2018
@description: Test Class for GlUt_ManualAmendmentContractFinder
*******************************************************************************/
@isTest
public class GlUt_ManualAmendmentContractFinder_Test {
    
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String BILLING_STREET ='Test Street';
    private static final String BILLING_CITY = 'Test City';
    private static final String BILLING_STATE = 'Test State';
    private static final String BILLING_POSTCODE ='0000000';
    private static final String BILLING_COUNTRY ='Test Country';
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String SUB_DEVICE_TYPE ='TestSubDevice';
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
    private static final String BILLNAME = 'testBill';
    private static final String HEROKUPOSTGRESID = 'Test ID';
    private static final String BILLITEMNAME = 'Test Bill Item';
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final String FINALBILL = 'true';
    private static final String FINALBILLFALSE = 'false';
    private static final String BILLDATE = string.valueOf(System.Today());
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String TAXCLASSIFICATIONTYP_NAME = 'TestTaxClassificationType';
    private static final String AGREEDSAMPLESTRENGTH_NAME = 'TestAgreedSampleStrength';
    private static final String AGREEDVOLUME_NAME = 'TestAgreedVolume';
    private static final Decimal PERCENTAGE_DISC_AMOUNT = 5.0;
    private static final Date START_DATE           = date.valueOf('2018-02-01');
    private static final Date END_DATE            = date.valueOf('2019-02-28');
    private static final String DISCOUNT_NAME          = 'Discount Type - 1';    
    private static final String DISCOUNT_TYPE         = 'Percentage';
    private static final String AMENDMENTREASON      = 'Reading Amendment';
    private static final String AMOUNT                 = '100';
    private static final String TAXAMOUNT             = '10';
    private static final String DISCOUNTAMOUNT          = '10';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    
    @TestSetup
    static void createTestData(){
        
            User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
            objUser.FirstName = USER_FNAME;
            objUser.LastName = USER_LNAME;
            Database.insert(objUser);
            
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
            
            // Create Device Size Record 
            DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
            Database.insert(objDeviceSize);
            
            // Create Device Type Record
            DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
            Database.insert(objDeviceType);
                        
            Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
            Database.insert(objDevice);
            Device__c objsubDevice = GlUt_FactoryData_Test.CreateDevice(SUB_DEVICE_TYPE ,objDeviceType );
            Database.insert(objsubDevice);
            ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
            Database.insert(objServiceType);
            Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
            Database.insert(objReading);
            Reading__c  objReadingSecond = GlUt_FactoryData_Test.CreateReading(objsubDevice);
            Database.insert(objReadingSecond);
            Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
            objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
            objLocation.Street__c =STREET ;
            Database.insert(objLocation);
            
            //Create Supply Point Usage Type Record
            SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
            Database.insert(objSupplyPointUsageType);
            
            SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
            objSupplyPoint.Measured__c= True; // AT-3174 

            Database.insert(objSupplyPoint);
            Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
            Database.insert(objDivision);
            Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
            Database.insert(objWholesaler);
            AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
            Database.insert(objAvailableService);
            Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
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
            Database.insert(objServiceItem);            
            Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,objContract);
            objBill.Account__c = objAccount.id; //AT-3174
            Database.insert(objBill);
            BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
            Database.insert(objBillServiceType);
            BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
            Database.insert(objBillItems);                     
            
            ManualAmendment__c objManualAmendment = GlUt_FactoryData_Test.createManualAmendment(objBillItems);
            Database.insert(objManualAmendment);
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
        
        ManualAmendment__c objManualAmendment = [SELECT Id FROM ManualAmendment__c ];       
        
        System.runAs(objUser){            
            Test.startTest();
            GlUt_ManualAmendmentContractFinder obj = new GlUt_ManualAmendmentContractFinder();
            contractIds = obj.retrieveContractIds(objManualAmendment.Id);            
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
            GlUt_ManualAmendmentContractFinder obj = new GlUt_ManualAmendmentContractFinder();
            contractIds = obj.retrieveContractIds(objAcc.Id);            
            Test.stopTest();
            
            System.assertEquals(0, contractIds.size());
        }
    }

}