/***************************************************************************************************
@author         Echo : Tarun Gupta
@date           20-Dec-2018
@description    This is Test class used by License Transfer object trigger  
Revision(s)   
*******************************************************************************************************/
@isTest 
public class BlAp_LicenseTransferCtrlr_Test {
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
    private static final String ACCOUNT_NAME2 = 'Test Account2';
    private static final String CONTRACT_NAME = 'Con00021';
    private static final String CONTRACT_NAME2 = 'Con000212';
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
    private static List<string> ruralLicenseFieldsForData;
    private static String BILL_ITEM_NAME_1 = 'Test Bill Item_1';
    private static Integer VOLUME_USED = 200;
    private static Integer BILLED_AMOUNT = 67878;
    private static String HEROKU_POSTGRES_ID_1 = 'Test ID_1';
    private static String BILL_SERVICE_TYPE ='TestServicetype';
    private static final String TESTREGION = 'Test Region';
    
    static{
    ruralLicenseFieldsForData = new List<String>();
        ruralLicenseFieldsForData.add('Id');
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSECONTRACTAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSESTARTDATEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSESTATUSAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEALLOCATEBANKAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEBUNDLEENTITLEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSECANCELDATEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSETRANSFERDATEAPINAME);
        //ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSETRANSFERTOLICENSEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEINFRACHARGEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSELOADREFERENCEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEOUTLETCHARGEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSETOTALOUTLETAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSETOTALCHARGEOUTLETAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEBASEENTITLEAPINAME);
    }
    
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
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
        
        // Create Account2 Record            
        Account objAccount2 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);
        Database.insert(objAccount2);
        
        // Create Contract Record            
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract); 
        
        // Create Contract Record            
        BillingContract__c objContract2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2, objAccount2);
        Database.insert(objContract2); 
        
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
        
        // Create Rural License Record            
        RuralLicense__c objLicense = GlUt_FactoryData_Test.createRuralLicense();
        objLicense.BillingContract__c = objContract.Id;
        objLicense.StartDate__c = system.today();
        objLicense.OutletCharge__c = objServiceItemType.Id;
        Database.insert(objLicense);
        
        RuralEntitlement__c objRuralEntitlement = GlUt_FactoryData_Test.createRuralEntitlement(objLicense);
        objRuralEntitlement.Active__c = true;
        objRuralEntitlement.SeasonalAllocation__c = 100;
        objRuralEntitlement.StartDate__c = objLicense.StartDate__c;
        objRuralEntitlement.RuralLicense__c = objLicense.Id;
        Database.insert(objRuralEntitlement);
        
        // Create Location Record            
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        objLocation.RuralLicense__c = objLicense.Id;
        Database.insert(objLocation);
        
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
        objServiceItem.StartDate__c = System.today().addMonths(-1);
        objServiceItem.RuralEntitlement__c = objRuralEntitlement.Id; 
        Database.insert(objServiceItem);
        
        // Create Bill Record            
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME, objContract);
        Database.insert(objBill);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE,objBill,HEROKU_POSTGRES_ID_1);
        Database.insert(objBillServiceType);                          
        
        BillItem__c objBillItem1 = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME_1, objServiceItem , VOLUME_USED ,BILLED_AMOUNT, objBillServiceType, HEROKU_POSTGRES_ID_1);
        objBillItem1.NetBilledAmount__c= 101;
        Database.insert(objBillItem1);
        
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation(objContract.Id,TRANSFER,STATUS_NEW);
        Database.insert(objBillCalculation);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
    @description: Test method for retrieveTransferDateDetails() method positive scenario
    *******************************************************************************/ 
    static testmethod void retrieveTransferDateDetailsValidate(){
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        List<List<GLAp_FieldProps>> twoColFormattedList = new List<List<GLAp_FieldProps>>();
        System.runAs(objUser){
            Test.startTest();
            twoColFormattedList  = BlAp_LicenseTransferCtrlr.retrieveTransferDateDetails();
            Test.stopTest();
        }
        System.assert(twoColFormattedList.size() >0);
    } 
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
    @description: Test method for retrieveRuralLicenseFieldDetails() method positive scenario
    *******************************************************************************/ 
    static testmethod void retrieveRuralLicenseFieldDetailsValidate(){
        
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        List<List<GLAp_FieldProps>> twoColFormattedList = new List<List<GLAp_FieldProps>>();
        System.runAs(objUser){
            Test.startTest();
            twoColFormattedList  = BlAp_LicenseTransferCtrlr.retrieveRuralLicenseFieldDetails();
            Test.stopTest();
            System.assert(twoColFormattedList.size() >0);
        }
    } 
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
    @description: Test method for retrieveRuralLicenseDetails() method scenario
    *******************************************************************************/ 
    static testmethod void retrieveRuralLicenseDetailsValidate(){
        
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        RuralLicense__c objLicense = [SELECT Id, Name,StartDate__c FROM RuralLicense__c  LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            RuralLicense__c objRuralLicense = BlAp_LicenseTransferCtrlr.retrieveRuralLicenseDetails(objLicense.Id,ruralLicenseFieldsForData);
            Test.stopTest();
            System.assert(objRuralLicense.Id != null);
        }
    } 
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
    @description: Test method for doLicenseTransfer() method scenario
    *******************************************************************************/ 
    static testmethod void doLicenseTransfer_Positive(){
        String transferDate = String.valueOf(system.today());
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        RuralLicense__c objLicense = [SELECT Id, Name,StartDate__c FROM RuralLicense__c  LIMIT 1];
        
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME2 LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        BlAp_LicenseTransferCtrlr.transferLicenserWrapper objWrapper = new BlAp_LicenseTransferCtrlr.transferLicenserWrapper();
        System.runAs(objUser){
            Test.startTest();
            objWrapper = BlAp_LicenseTransferCtrlr.doLicenseTransfer(objLicense.Id, objContract.Id, transferDate);
            Test.stopTest();
            System.assert(objWrapper.newBillCalculationId != null);
            System.assert(objWrapper.newRuralLicenseId != null);
        }
        
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
    @description: Test method for callHerokuTotransferLicense method positive scenario
    *******************************************************************************/  
    static testmethod void callHerokuTotransferLicense_Positive(){
        String responseCode;
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        RuralLicense__c objLicense = [SELECT Id, Name,StartDate__c FROM RuralLicense__c  LIMIT 1];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME2 LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        List<BillCalculation__c> lstBillCalculation = [SELECT Id, Name,BillingContract__c,Type__c,Status__c,RequestDate__c 
                                                       FROM BillCalculation__c LIMIT 1];
        
        System.runAs(objUser){            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockHttpResponseGenerator_Test(200));
            responseCode = BlAp_LicenseTransferCtrlr.callHerokuTotransferLicense(objLicense.Id,objContract.Id,objLicense.Id,lstBillCalculation[0].Id);                         
            Test.stopTest(); 
            System.assertEquals(responseCode, Label.GlUt_OK);

        }
    } 
    
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
    @description: Test method for callHerokuTotransferLicense method negative scenario
    *******************************************************************************/  
    static testmethod void callHerokuTotransferLicense_Negative(){
        String responseCode;
        Boolean isException = false;
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        RuralLicense__c objLicense = [SELECT Id, Name,StartDate__c FROM RuralLicense__c  LIMIT 1];
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME2 LIMIT 1];
        BillingContract__c objContract = [Select  Id,Name,AccountName__c
                                          FROM BillingContract__c 
                                          WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        List<BillCalculation__c> lstBillCalculation = [SELECT Id, Name,BillingContract__c,Type__c,Status__c,RequestDate__c 
                                                       FROM BillCalculation__c LIMIT 1];
        System.runAs(objUser){            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            try{ 
                Test.setMock(HttpCalloutMock.class, new GlUt_MockHttpResponseGenerator_Test(200));
                responseCode = BlAp_LicenseTransferCtrlr.callHerokuTotransferLicense(objLicense.Id,objContract.Id,objLicense.Id,lstBillCalculation[0].Id);
            }
            catch (exception e) {
                isException = true;
            }
            Test.stopTest();           
            System.assertEquals(isException, true);
            
        }
    } 
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
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
            Id billCalculationId = BlAp_LicenseTransferCtrlr.createBillCalculation(objContract.Id);
            
            Test.stopTest();
            System.assert(billCalculationId != null);
        }
    } 
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        20-Dec-2018
    @description: Test method for getInfoToDisplayValidate() method scenario
    *******************************************************************************/ 
    static testmethod void getInfoToDisplayValidate(){
        
        BlAp_LicenseTransferCtrlr.LicenseTransferContainerWrapper objWrapper = new BlAp_LicenseTransferCtrlr.LicenseTransferContainerWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1]; 
        RuralLicense__c objLicense = [SELECT Id, Name,StartDate__c FROM RuralLicense__c  LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            objWrapper = BlAp_LicenseTransferCtrlr.getInfoToDisplay(objLicense.Id);
            Test.stopTest();
        }
        System.assert(objWrapper.transferDateList.size() > 0);
        System.assert(objWrapper.currentContractFieldList.size() > 0);
        System.assert(objWrapper.ruralLicenseObj != null);
        
    } 
    
}