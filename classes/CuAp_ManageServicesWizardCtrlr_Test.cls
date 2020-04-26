@isTest
public class CuAp_ManageServicesWizardCtrlr_Test {

    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String SNAME                   = 'Test Name';
    private static final String strManufacturer         = 'Siemens';
    private static final String strUnitOfMeasure        = 'Metric';
    private static final String LOCATION_NAME           = 'A99 9AA';
    private static final String SP_USAGE_TYPE           = 'SupplyPointUsageType';
    private static final String AVAILABLESERVICES       = 'TestAvailableServiceItem';
    private static final String WHOLESALER              = 'TestWholesaler';
    private static final String MEASURED                = 'Monthly';  
    private static final String CITYNAME				= 'London';
    private static final String READINGMETHOD			= 'Actual';
    private static final String READINGTYPE				= 'Regular';
    private static final String READINGSOURCE			= 'Customer Reading';
    private static final String SERVICETRANSFERSTART    = 'Service Transfer Start';
    private static final String SERVICETRANSFEREND      = 'Service Transfer End';
    private static final String BUNDLE_NAME 			= 'Test Bundle';
    
    private static String wizardprop; 
    private static String readingProp; 
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          17 August 2018
    @param         -
    @return        Void   
    @description   Test data setup method
	@revesion	   Change By Dependra Singh- 25-02-2019- Salesforce Limit Analysis
    *******************************************************************************/
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        objUser.Email = EMAIL_ADDRESS;
        Database.insert(objUser);
        
       
        List<Account> lstAccount = new List<Account>();
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(SNAME);
        lstAccount.add(objAccount);
        
        // Create Account Record
        Account objAccount2 = GlUt_FactoryData_Test.createAccount(SNAME);
        lstAccount.add(objAccount2);
        Database.insert(lstAccount);
        
        List<BillingContract__c> lstBillingContract = new List<BillingContract__c>();
        // Create Contrat Record
        BillingContract__c objContract1 = GlUt_FactoryData_Test.createContract(lstAccount[0]);
        lstBillingContract.add(objContract1);
        
        // Create Contrat Record
        BillingContract__c objContract2 = GlUt_FactoryData_Test.createContract(lstAccount[1]);
        objContract2.BillingCity__c = CITYNAME;
        lstBillingContract.add(objContract2);
        Database.insert(lstBillingContract);       
        
        // Create Service Type Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SNAME);
        Database.insert(objServiceType);
        
        // Create Device Size Record
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(SNAME);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, strManufacturer, strUnitOfMeasure);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(SNAME, objDeviceType);
        Database.insert(objDevice);
        
        List<Reading__c> lstReading = new  List<Reading__c>();
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ReadingDate__c = date.today() - 30;
        objReading.ActualDeviceReading__c = '50';
        objReading.ReadingMethod__c = READINGMETHOD;
        objReading.ReadingSource__c = READINGSOURCE;
        objReading.ReadingType__c = READINGTYPE;
        lstReading.add(objReading); 
        
        // Create Reading Record
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = date.today();
        objReading1.ActualDeviceReading__c = '60';
        objReading1.ReadingMethod__c = READINGMETHOD;
        objReading1.ReadingSource__c = READINGSOURCE;
        objReading1.ReadingType__c = SERVICETRANSFERSTART;
        lstReading.add(objReading1); 
        
        // Create Reading Record
        Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading2.ReadingDate__c = date.today();
        objReading2.ActualDeviceReading__c = '60';
        objReading2.ReadingMethod__c = READINGMETHOD;
        objReading2.ReadingSource__c = READINGSOURCE;
        objReading2.ReadingType__c = SERVICETRANSFEREND;
        lstReading.add(objReading2); 
        Database.insert(lstReading);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(lstBillingContract[0], objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);
        
        // Create Service Item Family
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SNAME, objServiceType);
        objServiceItemFamily.AlgorithmType__c = System.Label.BlAp_MeasuredBilling;
        Database.insert(objServiceItemFamily);
        
        // Create Bundle Record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType);
        Database.insert(objBundle);
        
        // Create Service Item Type Record
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(BUNDLE_NAME, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
        Database.insert(objServiceItemType);
        
        // Create Bundle Item Record
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_NAME, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem);
        
        // Create Available Bundle
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(BUNDLE_NAME, objBundle, objAvailableService);
        Database.insert(objAvailableBundle);
        
        // Create Available Service Item Record
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(BUNDLE_NAME, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);
        
        // Create Service Item
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = Date.today().addDays(-30);
        //objServiceItem.EndDate__c = null;
        Database.insert(objServiceItem);
        
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevice);
    }    
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 August 2018
    @return        Void   
    *******************************************************************************/ 
    static testmethod void updateWizardProperties_positive(){
        
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE BillingCity__c=:CITYNAME LIMIT 1];             
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        CuAp_ManageServicesWizardCtrlr.WizardObject WizardObj = new CuAp_ManageServicesWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            Test.startTest();              
            CuAp_ManageServicesWizardCtrlr.WizardStatus(wizardprop);
            Test.stopTest();
            System.assert(!wizardprop.containsAny('?'));
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 August 2018
    @return        Void   
    *******************************************************************************/ 
    static testmethod void createReadins_positive(){
        
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE BillingCity__c =:CITYNAME LIMIT 1];             
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<Reading__c> newReadings = new List<Reading__c>();
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ActualDeviceReading__c = '60';
        objReading1.ReadingMethod__c = READINGMETHOD;
        objReading1.ReadingType__c = SERVICETRANSFERSTART;
        objReading1.ReadingSource__c = READINGSOURCE;
        objReading1.ReadingDate__c = Date.today();
        newReadings.add(objReading1);
        
        Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading2.ActualDeviceReading__c = '60';
        objReading2.ReadingMethod__c = READINGMETHOD;
        objReading2.ReadingType__c = SERVICETRANSFEREND;
        objReading2.ReadingSource__c = READINGSOURCE;
        objReading2.ReadingDate__c = Date.today();
        newReadings.add(objReading2);
        
        CuAp_ManageServicesWizardCtrlr.WizardObject WizardObj = new CuAp_ManageServicesWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        WizardObj.effectiveDate = Date.today();
        WizardObj.newReadings = newReadings;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            try {
            Test.startTest();              
            List<Reading__c> readingLists = CuAp_ManageServicesWizardCtrlr.processingReadings(wizardprop);
            Test.stopTest();
            System.assert(readingLists.size() == 2);
            }
            catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }            
        }     
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 August 2018
    @return        Void   
    *******************************************************************************/ 
    static testmethod void createReadins_negative(){
        
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE BillingCity__c =:CITYNAME LIMIT 1];             
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        CuAp_ManageServicesWizardCtrlr.WizardObject WizardObj = new CuAp_ManageServicesWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        WizardObj.effectiveDate = Date.today();
        WizardObj.newReadings = null;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            try {
                Test.startTest();              
                List<Reading__c> readingLists = CuAp_ManageServicesWizardCtrlr.processingReadings(wizardprop);
                Test.stopTest();
                System.assert(readingLists.size() == 0);
            }
            catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }            
        }     
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 August 2018
    @return        Void   
    *******************************************************************************/ 
    static testmethod void processingServices_positive(){
        
        BillingContract__c objContract1 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c !=:CITYNAME LIMIT 1];    
        BillingContract__c objContract2 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c =:CITYNAME LIMIT 1];    
        List<Reading__c> readingList = [SELECT Id FROM Reading__c];
        List<Service__c> serviceList = [SELECT Id, ServiceStartDate__c, ServiceEndDate__c FROM Service__c];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        CuAp_ManageServicesWizardCtrlr.WizardObject WizardObj = new CuAp_ManageServicesWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract2.Id;
        WizardObj.contractId = objContract2.Id;
        WizardObj.effectiveDate = Date.today();
        WizardObj.serviceTransfers = serviceList;
        
        wizardprop = System.JSON.serialize(WizardObj);
        String readingsJSON = JSON.serialize(readingList);

        System.runAs(objUser[0]){
            try {
                Test.startTest();              
                Id contract = CuAp_ManageServicesWizardCtrlr.processingServices(wizardprop, readingsJSON);
                Test.stopTest();
                System.assert(contract != null);
            }
            catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }            
        }     
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 August 2018
    @return        Void   
    *******************************************************************************/ 
    static testmethod void processingServices_negative(){
        
        BillingContract__c objContract1 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c !=:CITYNAME LIMIT 1];    
        BillingContract__c objContract2 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c =:CITYNAME LIMIT 1];    
        List<Reading__c> readingList = [SELECT Id FROM Reading__c];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        CuAp_ManageServicesWizardCtrlr.WizardObject WizardObj = new CuAp_ManageServicesWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract2.Id;
        WizardObj.contractId = objContract2.Id;
        WizardObj.effectiveDate = Date.today();
        WizardObj.serviceTransfers = null;
        
        wizardprop = System.JSON.serialize(WizardObj);
        String readingsJSON = JSON.serialize(readingList);

        System.runAs(objUser[0]){
            try {
                Test.startTest();              
                Id contract = CuAp_ManageServicesWizardCtrlr.processingServices(wizardprop, readingsJSON);
                Test.stopTest();
                System.assert(contract == null);
            }
            catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }            
        }     
    }
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 August 2018
    @return        Void   
    *******************************************************************************/ 
    static testmethod void processingAvailableServices_positive(){
        
        BillingContract__c objContract1 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c !=:CITYNAME LIMIT 1];    
        BillingContract__c objContract2 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c =:CITYNAME LIMIT 1];    
        List<Reading__c> readingList = [SELECT Id FROM Reading__c];
        List<AvailableService__c> availableServiceLists = [SELECT Id FROM AvailableService__c];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<Service__c> sericeList = [SELECT Id, AvailableService__c, ServiceStartDate__c, ServiceEndDate__c FROM service__c];
        System.debug('sericeList = '+sericeList);
        CuAp_ManageServicesWizardCtrlr.WizardObject WizardObj = new CuAp_ManageServicesWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract2.Id;
        WizardObj.contractId = objContract2.Id;
        WizardObj.effectiveDate = Date.today().addDays(-15);
        WizardObj.availableServiceTransfers = availableServiceLists;
        WizardObj.serviceTransfers = null;
        
        wizardprop = System.JSON.serialize(WizardObj);
        String readingsJSON = JSON.serialize(readingList);

        System.runAs(objUser[0]){
            try {
                Test.startTest();              
                Id contract = CuAp_ManageServicesWizardCtrlr.processingAvailableServices(wizardprop, readingsJSON);
                Test.stopTest();
                System.debug('contract in test class = '+contract);
                System.assert(contract != null);
            }
            catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }            
        }     
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          17 August 2018
    @return        Void   
    *******************************************************************************/ 
    static testmethod void processingAvailableServices_negative(){
        
        BillingContract__c objContract1 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c !=:CITYNAME LIMIT 1];    
        BillingContract__c objContract2 = [SELECT Id FROM BillingContract__c WHERE BillingCity__c =:CITYNAME LIMIT 1];    
        List<Reading__c> readingList = [SELECT Id FROM Reading__c];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        CuAp_ManageServicesWizardCtrlr.WizardObject WizardObj = new CuAp_ManageServicesWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract2.Id;
        WizardObj.contractId = objContract2.Id;
        WizardObj.effectiveDate = Date.today();
        WizardObj.availableServiceTransfers = null;
        
        wizardprop = System.JSON.serialize(WizardObj);
        String readingsJSON = JSON.serialize(readingList);

        System.runAs(objUser[0]){
            try {
                Test.startTest();              
                Id contract = CuAp_ManageServicesWizardCtrlr.processingAvailableServices(wizardprop, readingsJSON);
                Test.stopTest();
                System.assert(contract == null);
            }
            catch(Exception ex) {  
                system.debug('exception caught in test context:: ' + ex);
            }            
        }     
    }
}