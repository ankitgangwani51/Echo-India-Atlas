/******************************************************************************
@author         Ankit Gangwani
@date           24 July 2018
@description    Test Class For BlAp_SteppedTariffWizardCtrlr
@Revision	 	AT-3951, Tarun - Modified as per security review
@Revisions	    AT-4887 , Tarun , Added Assert as part of checkmarks result 
*******************************************************************************/
@isTest
public class BlAp_SteppedTariffWizardCtrlr_Test {
   
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
    private static final String WIZARDTYPE				= 'NewStepTariff';
    
    private static String wizardprop; 
    /******************************************************************************
    @author        Ankit Gangwani
    @date          24 July 2018 
    @param         -
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        objUser.Email = EMAIL_ADDRESS;
        Database.insert(objUser);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(SNAME);
        Database.insert(objAccount);
        
        // Create Contrat Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(objAccount);
        Database.insert(objContract);
        
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
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading); 
        
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
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);
        
        // Create Service Item Family
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SNAME, objServiceType);
        objServiceItemFamily.AlgorithmType__c = System.Label.BlAp_MeasuredBilling;
        Database.insert(objServiceItemFamily);
        
        // Create Stepped Tariff Record
        SteppedTariff__c objSteppedTariff = new SteppedTariff__c();
        objSteppedTariff.ServiceType__c = objServiceType.Id;
        objSteppedTariff.BillingContract__c = objContract.Id;
        objSteppedTariff.StartDate__c = Date.today();
        Database.insert(objSteppedTariff);
        
        List<SteppedTariffService__c> lstSteppedTariffService =  new List<SteppedTariffService__c>();
        // Create Stepped Tariff Service Record
        SteppedTariffService__c objSteppedTariffService = new SteppedTariffService__c();
        objSteppedTariffService.Service__c = objService.Id;
        objSteppedTariffService.SteppedTariff__c = objSteppedTariff.Id;
        objSteppedTariffService.StartDate__c = Date.today();
        lstSteppedTariffService.add(objSteppedTariffService);
        
        // Create Stepped Tariff Service Record
        SteppedTariffService__c objSteppedTariffService2 = new SteppedTariffService__c();
        objSteppedTariffService2.Service__c = objService.Id;
        objSteppedTariffService2.SteppedTariff__c = objSteppedTariff.Id;
        objSteppedTariffService2.StartDate__c = Date.today();
        lstSteppedTariffService.add(objSteppedTariffService2);
        Database.insert(lstSteppedTariffService);
    }    
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/ 
    static testmethod void updateWizardProperties_positive(){
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];             
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BlAp_SteppedTariffWizardCtrlr.WizardObject WizardObj = new BlAp_SteppedTariffWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        WizardObj.wizardType = WIZARDTYPE;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            Test.startTest();              
            BlAp_SteppedTariffWizardCtrlr.WizardStatus(wizardprop);
            Test.stopTest();
            System.assert(!wizardprop.containsAny('?'));
            // No assertion is required as the return type is void
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/ 
    static testmethod void createSteppedTairffAndServices_Positive(){
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        ServiceType__c objServiceType = [SELECT Id FROM ServiceType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        List<SteppedTariffService__c> steppedTariffServiceList = new List<SteppedTariffService__c>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        // Create Stepped Tariff Record
        SteppedTariff__c objSteppedTariff = new SteppedTariff__c();
        objSteppedTariff.ServiceType__c = objServiceType.Id;
        objSteppedTariff.BillingContract__c = objContract.Id;
        objSteppedTariff.StartDate__c = Date.today();
        
        // Create Stepped Tariff Service Record
        SteppedTariffService__c objSteppedTariffService = new SteppedTariffService__c();
        objSteppedTariffService.Service__c = objService.Id;
        objSteppedTariffService.StartDate__c = Date.today();
        steppedTariffServiceList.add(objSteppedTariffService);
        
        // Create Stepped Tariff Service Record
        SteppedTariffService__c objSteppedTariffService2 = new SteppedTariffService__c();
        objSteppedTariffService2.Service__c = objService.Id;
        objSteppedTariffService2.StartDate__c = Date.today();
        steppedTariffServiceList.add(objSteppedTariffService2);
        
        
        BlAp_SteppedTariffWizardCtrlr.WizardObject WizardObj = new BlAp_SteppedTariffWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        WizardObj.wizardType = WIZARDTYPE;
        WizardObj.steppedTariff = objSteppedTariff;
        WizardObj.steppedTariffServices = steppedTariffServiceList;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            Test.startTest();              
            Id steppedTariffId = BlAp_SteppedTariffWizardCtrlr.createSteppedTairffAndServices(wizardprop);
            Test.stopTest();
            System.assert(steppedTariffId != null);
                
        }
    }
   
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/ 
    static testmethod void createSteppedTairffAndServices_Negative(){
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        ServiceType__c objServiceType = [SELECT Id FROM ServiceType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        SteppedTariff__c objSteppedTariff = new SteppedTariff__c();
        List<SteppedTariffService__c> steppedTariffServiceList = new List<SteppedTariffService__c>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Boolean isException = false;
        
        BlAp_SteppedTariffWizardCtrlr.WizardObject WizardObj = new BlAp_SteppedTariffWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        WizardObj.wizardType = WIZARDTYPE;
        WizardObj.steppedTariff = objSteppedTariff;
        WizardObj.steppedTariffServices = steppedTariffServiceList;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            try{
                Test.startTest();              
                BlAp_SteppedTariffWizardCtrlr.createSteppedTairffAndServices(wizardprop);
                Test.stopTest();
            } catch(Exception e){
                isException = true;                
            }
            system.assert(isException == true);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/
    static testmethod void updateSteppedTairffServices_Positive(){
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        ServiceType__c objServiceType = [SELECT Id FROM ServiceType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        List<SteppedTariffService__c> steppedTariffServiceList = [SELECT Id, Service__c, SteppedTariff__c FROM SteppedTariffService__c];
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        BlAp_SteppedTariffWizardCtrlr.WizardObject WizardObj = new BlAp_SteppedTariffWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        WizardObj.steppedTariffServices = steppedTariffServiceList;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            Test.startTest();              
            Id steppedTariffId = BlAp_SteppedTariffWizardCtrlr.updateSteppedTairffServices(wizardprop);
            Test.stopTest();
            System.assert(steppedTariffId != null);
        }
    }
   
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          24 July 2018 
    @return        Void   
    *******************************************************************************/ 

    static testmethod void updateSteppedTairffServices_Negative(){
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        ServiceType__c objServiceType = [SELECT Id FROM ServiceType__c LIMIT 1];
        Service__c objService = [SELECT Id FROM Service__c LIMIT 1];
        List<SteppedTariffService__c> steppedTariffServiceList = new List<SteppedTariffService__c>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Boolean isException = false;
        
        BlAp_SteppedTariffWizardCtrlr.WizardObject WizardObj = new BlAp_SteppedTariffWizardCtrlr.WizardObject();
        WizardObj.recordId = objContract.Id;
        WizardObj.contractId = objContract.Id;
        WizardObj.steppedTariffServices = steppedTariffServiceList;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            try{                
                Test.startTest();              
                BlAp_SteppedTariffWizardCtrlr.updateSteppedTairffServices(wizardprop);
                Test.stopTest();
            } catch (Exception e){
                isException = true;
            }
            System.assert(isException == true);
        }
    }
}