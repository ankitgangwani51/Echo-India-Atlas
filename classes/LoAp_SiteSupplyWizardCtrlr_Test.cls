/******************************************************************************
@author         Ankit Gangwani
@date           19 March 2019
@description    Test Class For LoAp_SiteSupplyWizardCtrlr
*******************************************************************************/
@isTest
public class LoAp_SiteSupplyWizardCtrlr_Test {
    
    private static String wizardprop; 
    private static final String USER_PROFILE            = 'System Administrator';
    private static final String USER_NAME               = 'FN123LN123'; 
    private static final String USER_FNAME              = 'FN123';  
    private static final String USER_LNAME              = 'LN123';
    private static final String EMAIL_ADDRESS           = 'ankitgangwani@echo-ms.com';
    private static final String SNAME                   = 'Test Name';
    private static final String LOCATION_NAME           = 'A99 9AA';
    private static final String SP_USAGE_TYPE           = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE         	= 'TestDeviceSize';
    private static final String DEVICE_NAME         	= 'TestDevice';
    private static final String MANUFACTURER        	= 'Siemens';
    private static final String UNIT_OF_MEASURE     	= 'Metric';

    /******************************************************************************
    @author        Ankit Gangwani
    @date          19 March 2019
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
        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);        
        Database.insert(objLocation);
        
        // Create Location Record
        Location__c objLocation2 = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);        
        Database.insert(objLocation2);

        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType2 = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType2);
        
        // Create Supply Point Record
        SupplyPoint__c objSiteSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSiteSupplyPoint.Measured__c = True;
        objSiteSupplyPoint.Description__c = 'Main';
        Database.insert(objSiteSupplyPoint);
        
        // Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation2, objSupplyPointUsageType2);
        objSupplyPoint.Measured__c = True;
        Database.insert(objSupplyPoint);
        
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSiteSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        // Create Site Supply Record
        SiteSupply__c objSiteSupply = GlUt_FactoryData_Test.createSiteSupply(objSiteSupplyPoint, objSupplyPoint);
        objSiteSupply.PercentageSplit__c = 100.00;
        objSiteSupply.StartDate__c = Date.today();
        Database.insert(objSiteSupply);
        
        // Create Site Supply Record
        SiteSupply__c objSiteSupply2 = GlUt_FactoryData_Test.createSiteSupply(objSiteSupplyPoint, objSupplyPoint);
        objSiteSupply2.PercentageSplit__c = 50.00;
        objSiteSupply2.StartDate__c = Date.today();
        Database.insert(objSiteSupply2);
        
        
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/ 
    static testmethod void updateWizardProperties(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<SupplyPoint__c> objSP = [SELECT Id, Description__c FROM SupplyPoint__c WHERE Description__c = 'Main' LIMIT 1];
        LoAp_SiteSupplyWizardCtrlr.WizardObject WizardObj = new LoAp_SiteSupplyWizardCtrlr.WizardObject();
        WizardObj.recordId = objSP[0].Id;
        WizardObj.supplyPointId = objSP[0].Id;
        WizardObj.wizardType = System.Label.LoAp_isAmend;
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            Test.startTest();              
            LoAp_SiteSupplyWizardCtrlr.WizardStatus(wizardprop);
            Test.stopTest();
            System.assert(!wizardprop.containsAny('?'));          
        }
    } 
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/ 
    static testmethod void processSiteSupplies_Positive(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Boolean isException = false;
        List<SupplyPoint__c> objSP = [SELECT Id, Description__c FROM SupplyPoint__c WHERE Description__c = 'Main' LIMIT 1];
        List<SupplyPoint__c> objSS = [SELECT Id, Description__c FROM SupplyPoint__c WHERE Description__c != 'Main' LIMIT 1];
        List<Id> contracts = new List<Id>();
        
        List<SiteSupply__c> siteSupplyToCreateAddRows = new List<SiteSupply__c>();
        SiteSupply__c siteSupp = new SiteSupply__c();
        siteSupp.SiteSupplyPoint__c = objSS[0].Id;
        siteSupp.SupplyPoint__c = objSP[0].Id;
        siteSupp.PercentageSplit__c = 55.50;
        siteSupp.StartDate__c = Date.today();
        siteSupplyToCreateAddRows.add(siteSupp);
           
        List<SiteSupply__c> siteSupplyToAmendCreate = new List<SiteSupply__c>();
        SiteSupply__c existingSS = [SELECT Id, PercentageSplit__c, SiteSupplyPoint__c, SupplyPoint__c, StartDate__c FROM SiteSupply__c LIMIT 1];
        existingSS.PercentageSplit__c = 99.00;
        siteSupplyToAmendCreate.add(existingSS);
        
        SiteSupply__c existingSS2 = [SELECT Id, PercentageSplit__c, SiteSupplyPoint__c, SupplyPoint__c, StartDate__c FROM SiteSupply__c WHERE PercentageSplit__c = 50.00 LIMIT 1];
        existingSS2.StartDate__c = Date.today().addDays(20);
        siteSupplyToAmendCreate.add(existingSS2);
            
        LoAp_SiteSupplyWizardCtrlr.WizardObject WizardObj = new LoAp_SiteSupplyWizardCtrlr.WizardObject();
        WizardObj.recordId = objSP[0].Id;
        WizardObj.supplyPointId = objSP[0].Id;
        WizardObj.wizardType = System.Label.LoAp_isAmend;
        WizardObj.siteSupplyToCreateAddRows = siteSupplyToCreateAddRows;
        WizardObj.siteSupplyToAmendCreate = siteSupplyToAmendCreate;        
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            try{
                Test.startTest();              
                LoAp_SiteSupplyWizardCtrlr.processSiteSupplies(wizardprop);
                Test.stopTest();
            } catch(Exception e){
                isException = true;                
            }
            SiteSupply__c existSS = [SELECT Id, PercentageSplit__c, AmendedBySiteSupply__c FROM SiteSupply__c WHERE PercentageSplit__c = 100.00 LIMIT 1];            
            system.assert(existSS.AmendedBySiteSupply__c != null);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/ 
    static testmethod void processSiteSupplies_Negative(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Boolean isException = false;
        List<SupplyPoint__c> objSP = [SELECT Id, Description__c FROM SupplyPoint__c WHERE Description__c = 'Main' LIMIT 1];
        List<SupplyPoint__c> objSS = [SELECT Id, Description__c FROM SupplyPoint__c WHERE Description__c != 'Main' LIMIT 1];
            
        LoAp_SiteSupplyWizardCtrlr.WizardObject WizardObj = new LoAp_SiteSupplyWizardCtrlr.WizardObject();
        WizardObj.recordId = objSP[0].Id;
        WizardObj.supplyPointId = objSP[0].Id;
        WizardObj.wizardType = System.Label.LoAp_isAmend;
        WizardObj.siteSupplyToCreateAddRows = null;
        WizardObj.siteSupplyToAmendCreate = null;        
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            try{
                Test.startTest();              
                LoAp_SiteSupplyWizardCtrlr.processSiteSupplies(wizardprop);
                Test.stopTest();
            } catch(Exception e){
                isException = true;                
            }         
            System.assert(!wizardprop.containsAny('?'));
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          19 March 2019
    @return        Void   
    *******************************************************************************/ 
    static testmethod void processSiteSupplies_Ended(){
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        Boolean isException = false;
        List<SupplyPoint__c> objSP = [SELECT Id, Description__c FROM SupplyPoint__c WHERE Description__c = 'Main' LIMIT 1];
        List<SiteSupply__c> siteSuppliesToEnded = new List<SiteSupply__c>();
        for(SiteSupply__c ssEnded : [SELECT Id, EndDate__c, Ended__c, StartDate__c FROM SiteSupply__c]){
            ssEnded.EndDate__c = Date.today().addDays(30);
            ssEnded.Ended__c = true;
            siteSuppliesToEnded.add(ssEnded);
        }
        
        LoAp_SiteSupplyWizardCtrlr.WizardObject WizardObj = new LoAp_SiteSupplyWizardCtrlr.WizardObject();
        WizardObj.recordId = objSP[0].Id;
        WizardObj.supplyPointId = objSP[0].Id;
        WizardObj.wizardType = System.Label.LoAp_isEnd;
        WizardObj.siteSuppliesToEnded = siteSuppliesToEnded;        
        
        wizardprop = System.JSON.serialize(WizardObj);

        System.runAs(objUser[0]){
            try{
                Test.startTest();              
                LoAp_SiteSupplyWizardCtrlr.processSiteSupplies(wizardprop);
                Test.stopTest();
            } catch(Exception e){
                isException = true;                
            }
        }
        SiteSupply__c ssEnd = [SELECT Id, Ended__c FROM SiteSupply__c LIMIT 1];
        system.assert(ssEnd.Ended__c == true);
    }
}