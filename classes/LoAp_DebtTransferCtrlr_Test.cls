/***************************************************************************************************
@author         Echo : Dependra Singh
@date           29-Oct-2018
@description    This is Test class used by Bill Transfer object trigger  
Revision(s)   
*******************************************************************************************************/
@isTest 
public class LoAp_DebtTransferCtrlr_Test {
    private static string BILLINGRESPONSEMOCKPOSITIVE = 'GlAp_AddHerokuJobsCtrlrResponse_Positive';
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Aqua';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = 'Meter';    
    private static final String BILL_ITEM_NAME = 'Water bill';
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
    private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
    private static final String AVAIL_BUNDLE_NAME = 'Avail Bundle Name';
    private static final String ZIPCODE = 'WS2 8DE';
    private static final String READFREQUENCY ='Monthly';
    private static final String BILL_NAME = 'Bill';
    private static final String TRANSFER = 'Transfer';
    private static final String STATUS_NEW = 'New';
    private static final String LOCATION_STREET = 'ABC';
    private static final String HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static final String TESTREGION = 'Test Region';
    
    /******************************************************************************
    @author:      Echo: Dependra
    @date:        29-Oct-2018
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
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
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
        
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation(objContract.Id,TRANSFER,STATUS_NEW);
        Database.insert(objBillCalculation);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
    }
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for retrieveTransferReasonDetails() method positive scenario
    *******************************************************************************/ 
    static testmethod void retrieveTransferReasonDetailsValidate(){
        
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        System.runAs(objUser){
            Test.startTest();
            List<List<GLAp_FieldProps>> twoColFormattedList  = LoAp_DebtTransferCtrlr.retrieveTransferReasonDetails();
            Test.stopTest();
            System.assert(twoColFormattedList.size() >0);
        }
    } 
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for retrieveLocationFieldDetails() method positive scenario
    *******************************************************************************/ 
    static testmethod void retrieveLocationFieldDetailsValidate(){
        
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        System.runAs(objUser){
            Test.startTest();
            List<List<GLAp_FieldProps>> twoColFormattedList  = LoAp_DebtTransferCtrlr.retrieveLocationFieldDetails();
            Test.stopTest();
            System.assert(twoColFormattedList.size() >0);
        }
    } 
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for retrieveLocationDetailsValidate() method scenario
    *******************************************************************************/ 
    static testmethod void retrieveLocationDetailsValidate(){
        
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Location__c objLocation = [SELECT Id, Name,Street__c FROM Location__c  LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            Location__c locationObj = LoAp_DebtTransferCtrlr.retrieveLocationDetails(objLocation.Id);
            Test.stopTest();
            System.assert(locationObj.Id != null);
        }
    } 
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for transferDebts method positive scenario
    *******************************************************************************/  
    static testmethod void transferDebts_Positive(){
        String responseCode;
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Location__c objLocation = [SELECT Id, Name FROM Location__c  LIMIT 1];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        List<BillCalculation__c> lstBillCalculation = [SELECT Id, Name,BillingContract__c,Type__c,Status__c,RequestDate__c 
                                                       FROM BillCalculation__c LIMIT 1];
        
        String transferReason = Label.BillTransferReason;
        
        System.runAs(objUser){            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockHttpResponseGenerator_Test(200));
            responseCode = LoAp_DebtTransferCtrlr.transferDebts(objLocation.Id,objContract.Id,transferReason,lstBillCalculation[0].Id);                         
            Test.stopTest(); 
            System.assertEquals(responseCode, Label.GlUt_OK);

        }
    } 
    
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for transferDebts method negative scenario
    *******************************************************************************/  
    static testmethod void transferDebts_Negative(){
        String responseCode;
        Boolean isException = false;
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Location__c objLocation = [SELECT Id, Name FROM Location__c  LIMIT 1];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        List<BillCalculation__c> lstBillCalculation = [SELECT Id, Name,BillingContract__c,Type__c,Status__c,RequestDate__c 
                                                       FROM BillCalculation__c LIMIT 1];
        
        String transferReason = Label.BillTransferReason;
        
        System.runAs(objUser){            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            try{ 
                Test.setMock(HttpCalloutMock.class, new GlUt_MockHttpResponseGenerator_Test(200));
                responseCode = LoAp_DebtTransferCtrlr.transferDebts(objLocation.Id,objContract.Id,transferReason,lstBillCalculation[0].Id);  
            }
            catch (exception e) {
                isException = true;
            }
            System.assertEquals(isException, true);
            Test.stopTest();           
            
        }
    } 
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for createBillCalculationValidate() method scenario
    *******************************************************************************/ 
    static testmethod void createBillCalculationValidate(){
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            Id billCalculationId = LoAp_DebtTransferCtrlr.createBillCalculation(objContract.Id);
            Test.stopTest();
            System.assert(billCalculationId != null);
        }
    } 
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        29-Oct-2018
    @description: Test method for getInfoToDisplayValidate() method scenario
    *******************************************************************************/ 
    static testmethod void getInfoToDisplayValidate(){
        
        LoAp_DebtTransferCtrlr.DebtTransferContainerWrapper objWrapper = new LoAp_DebtTransferCtrlr.DebtTransferContainerWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        Location__c objLocation = [SELECT Id, Name FROM Location__c  LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            objWrapper = LoAp_DebtTransferCtrlr.getInfoToDisplay(objLocation.Id);
            Test.stopTest();
            System.assert(objWrapper.transferReasonList.size() > 0);
            System.assert(objWrapper.locationFieldList.size() > 0);
            System.assert(objWrapper.locationObj != null);
        }
    } 
    
}