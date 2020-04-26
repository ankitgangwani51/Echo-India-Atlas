/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        18 Dec 2017
@description: Test Class for CuAp_AgreedRatePageCtrlr 
*******************************************************************************/

@isTest
//test data creation for CuAp_AgreedRatePageCtrlr  class
Public Class CuAp_AgreedRatePageCtrlr_Test{

      private static final String USER_ALIAS = 'standt';
      private static final String USER_EMAIL = '@unitest.com';
      private static final String USER_UTF = 'UTF-8';
      private static final String USER_LNAME= 'UnitTest';
      private static final String USER_LAN_LOCALKEY= 'en_US';
      private static final String USER_TIMEZONEKEY= 'America/Los_Angeles';
      private static final String USER_PHONE = '1234567891';
      private static final String USER_MPHONE = '0111111111';
      private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    
      private static String USER_PROFILE ='System Administrator';
      private static String USER_NAME ='TestUser'; 
      private static String ACCOUNT_NAME = 'TestAccount'; 
      private static String CONTRACT_NAME_ONE ='TestContract';
      private static String CONTRACT_NAME_SECOND ='TestContract2';
      private static String DEVICE_NAME = 'TestDevice';
      private static String DEVICE_TYPE ='TestDeviceType';
      private static String SUB_DEVICE_TYPE ='TestSubDevice';
      private static String TEST_SERVICE_TYPE ='TestServiceType';
      private static String LOCATION_NAME ='A99 9AA';
      private static String LOCATION_SUB_TYPE = 'Detached';
      private static String STREET = 'teststreet';
      private static String YES ='yes';
      private static String MEASURED = 'Monthly';
      private static String WHOLESALER ='TestWholesaler';
      private static String AVAILABLESERVICES ='TestAvailableService';
      private static String SERVICEITEMFAMILY ='TestServiceItemFamily';
      private static String SERVICEITEMTYPE ='TestServiceitemtype';
      private static String BUNDLE ='TestBundle';
      private static String AVAILABLEBUNDLE ='TestAvailableBundle';
      private static String BUNDLEITEM ='TestBundleItem';
      private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
      private static String SITESAMPLE ='Testsitesample';
      private static String SAMPLE ='TestSample';
      private static String AGREERATE ='TestAgreeRate';
      private static Integer LIMIT1 =1;
      private static String USERNAMECOMPLETE = USER_NAME + '@unitest.com';    
      private static final String DEVICE_SIZE = 'TestDeviceSize';
      private static final String MANUFACTURER = 'Siemens';
      private static final String UNIT_OF_MEASURE = 'Metric';
      private static final String COURTSUMMONS = 'Court Summons Issued';
      private static final Integer SAMPLE_STRENGTH_NUMBER = 100;
    
 
/*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser); 
        system.Runas(objUser){
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation();
        Database.insert(objBillCalculation);
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_ONE,objAccount);
        BillingContract__c objContract2 = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_SECOND ,objAccount);

        list<BillingContract__c >lstContract = new list<BillingContract__c>(); 
        lstContract.add(objContract);
        lstContract.add(objContract2);
        Database.insert(lstContract);
        Suppression__c objSuppression = new Suppression__c();
        objSuppression.Account__c= objAccount.id;
        objSuppression.BillingContract__c=objContract.id;
        objSuppression.SuppressionStartDate__c = system.today();
        objSuppression.SuppressionEndDate__c= system.today().addDays(10);
        objSuppression.SuppressBillPrint__c =true;
        objSuppression.SuppressionReason__c = COURTSUMMONS;
        database.insert(objSuppression);
            
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
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
        
        // Create Main Supply Point
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
            
        // Create Sub Supply Point
        SupplyPoint__c  objSubSP = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSubSP.Measured__c= True; // AT-3174 
        Database.insert(objSubSP);
            
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
        objServiceItemType.EligibleForAnAgreedRate__c = 'Yes';
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
        objServiceItem.StartDate__c = system.today();
        Database.insert(objServiceItem);
        
        // Commented by Ankit Gangwani for task - AT-2926, 22 June 2018    
        /*DeviceRelationship__c  objDeviceRelationship = GlUt_FactoryData_Test.CreateDeviceRelationship(objDevice,objsubDevice);
        Database.insert(objDeviceRelationship);*/
          
        SupplyPointRelationship__c objSupplyPointRelationship = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPoint, objSubSP);
        Database.insert(objSupplyPointRelationship);
            
        DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
        Database.insert(objDischargeAgreement); 
        
        Sample__c  objSample =GlUt_FactoryData_Test.CreateSample(SAMPLE );
        objSample.CODSampleStrength__c = SAMPLE_STRENGTH_NUMBER;
        objSample.SampleCollectionDate__c = Date.today();
        objSample.DischargeAgreement__c = objDischargeAgreement.Id;            
        Database.insert(objSample);
        AgreedRate__c  objAgreedRate =GlUt_FactoryData_Test.CreateAgreedRate(AGREERATE,objServiceItem);
        objAgreedRate.EndDate__c = system.today().addDays(10);
        Database.insert(objAgreedRate);
        Rate__c objRate = GlUt_FactoryData_Test.createRate(objServiceItemType,10);
        objRate.StartDate__c = System.today()-2;
        objRate.EndDate__c = System.today()+10;
        Database.insert(objRate);
        }
           
    }
    
/*******************************************************************
Purpose: Method to test CuAp_SelectContractPageCtrlr   {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void CuAp_AgreedRatePageCtrlr_retrieveAgreedRatesFieldPropDetails_neg(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String customerId = objaccount.id;
        CuAp_AgreedRatePageCtrlr.AgreedRatesFields = null;
        boolean isException = false;
        system.Runas(objUser){
        Test.starttest();
        List<GLAp_FieldProps>lstFieldProps;    
        try{
        lstFieldProps = CuAp_AgreedRatePageCtrlr.retrieveAgreedRatesFieldPropDetails();
        }
        //make conFields variable of CuAp_SelectContractCtrlr class to test negative scenario
        catch(Exception exc){
         isException = true;
        }
        Test.stoptest();
         //Asserts to check properties of list of GlAp_FieldProps retrieved
         System.assertEquals(lstFieldProps.isEmpty(),true);            

        }
    
    }
    /*******************************************************************
Purpose: Method to test CuAp_SelectContractPageCtrlr   {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void CuAp_AgreedRatePageCtrlr_retrieveAgreedRatesFieldPropDetails(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String customerId = objaccount.id;
        system.Runas(objUser){
        Test.starttest();
        List<GLAp_FieldProps>lstFieldProps = CuAp_AgreedRatePageCtrlr.retrieveAgreedRatesFieldPropDetails();
        Test.stoptest();
         //Asserts to check properties of list of GlAp_FieldProps retrieved
            System.assert(lstFieldProps.size()>0);
            System.assertEquals(lstFieldProps[0].isEditable,false);
            System.assertEquals(lstFieldProps[0].fieldType,'text');
            System.assertEquals(lstFieldProps[1].fieldType,'reference');
            System.assertEquals(lstFieldProps[2].fieldType,'text');
            System.assertEquals(lstFieldProps[3].fieldType,'text');
        }
    
    }
      
/*******************************************************************
Purpose: Method to test CuAp_SelectContractPageCtrlr   {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void CuAp_AgreedRatePageCtrlr_retrieveAgreedRatesNew_positive(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser =[select id,name from user where isActive=true and username =:USERNAMECOMPLETE limit 1];
        String customerId = objContract.id;
        system.Runas(objUser){
        Test.starttest();
        List<BlAp_CombinedRecord>lstCombineContracts = CuAp_AgreedRatePageCtrlr.retrieveAgreedRatesNew(customerId);
        BillingContract__c  objContractResponse = CuAp_AgreedRatePageCtrlr.retrieveContract(customerId);
        Test.stoptest();
        //Asserts to check properties of list of BlAp_CombinedRecord retrieved
            System.assert(lstCombineContracts.size()>0);
            System.assertEquals(lstCombineContracts[0].isSelected,false);
        }
    
    }

    /*******************************************************************
Purpose: Method to test CuAp_SelectContractPageCtrlr   {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void CuAp_AgreedRatePageCtrlr_retrieveAgreedRatesNew_negative(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser =[select id,name from user where isActive=true and username =:USERNAMECOMPLETE limit 1];
        String customerId = objContract.id;
        
        //Delete contract record related to account in order to test negative scenario
        delete objContract;
        system.Runas(objUser){
        Test.starttest();
        List<BlAp_CombinedRecord>lstCombineContracts = CuAp_AgreedRatePageCtrlr.retrieveAgreedRatesNew(customerId);
        Test.stoptest();
        //Asserts to check properties of list of BlAp_CombinedRecord retrieved
         System.assertEquals(lstCombineContracts.size(),0);

        }
    
    }
    
     /*******************************************************************
Purpose: Method to test CuAp_SelectContractPageCtrlr   {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void CuAp_AgreedRatePageCtrlr_saveAgreedRateNeg(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        ServiceItem__c  objServiceItem = [select id,name from ServiceItem__c  limit 1];
        User objUser =[select id,name from user where isActive=true and username =:USERNAMECOMPLETE limit 1];
        //string AgreedRateString = '[{"checkboxId":"add-checkbox-a0O0Y000006OjcSUAS","isSelected":true,"objectMap":{"ServiceItem__c":{"Id":"objServiceItem.id","Name":"SIN-001318","ServiceType__c":"water  - DO NOT USE","ServiceItemType__c":"a0a0Y0000031MauQAE","Retail_Amount__c":1.25,"Supply_Point__c":"SP-000001693","Location__c":"Rattery,South Brent, Devon, England, UK, TQ10 9LB","Service__c":"a010Y00000cn1u2QAA","attributes":{"type":"ServiceItem__c"}},"AgreedRate__c":{"Value__c":100,"StartDate__c":"2017-12-19","EndDate__c":"2017-12-30","LeapYear__c":true,"attributes":{"type":"AgreedRate__c"}}},"readOnlyFields":{},"uniqueId":"a0O0Y000006OjcSUAS"}]';
        //Delete contract record related to account in order to test negative scenario
        AgreedRate__c aggrate = new AgreedRate__c();
        aggrate.StartDate__c = system.today();
        aggrate.EndDate__c = system.today().addDays(300);
        Rate__c objRate = [Select id, RetailAmount__c from Rate__c limit 1];
        List<BlAp_CombinedRecord>  AgreedRatesComList = new List<BlAp_CombinedRecord>();
        BlAp_CombinedRecord aggContract = new BlAp_CombinedRecord();            
        aggContract.uniqueId=objServiceItem.Id;
        aggContract.isSelected = true;
        aggContract.objectMap = new Map<string, sObject>();
        aggContract.readOnlyFields = new Map<string, boolean>();
        aggContract.objectMap.put(BlAp_Constants.SERVICEITEMNAME , objServiceItem);
        aggContract.objectMap.put(BlAp_Constants.AGREEDRATESNAME, aggrate);
        aggContract.objectMap.put(CuAp_Constants.OBJECTAPIRATES, objRate);
        AgreedRatesComList.add(aggContract);
        string AgreedRateString = JSON.serialize(AgreedRatesComList);
        system.Runas(objUser){
        Test.starttest();
        string response = CuAp_AgreedRatePageCtrlr.saveAgreedRate(AgreedRateString);
        Test.stoptest();
        //Asserts to check properties of list of BlAp_CombinedRecord retrieved
         System.assertNotEquals(response,Label.CuAp_AgreedRate_Sucess);

        }
    
    }
   
    /*******************************************************************
Purpose: Method to test CuAp_SelectContractPageCtrlr   {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void CuAp_AgreedRatePageCtrlr_saveAgreedRatePos(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        ServiceItem__c  objServiceItem = [select id,name from ServiceItem__c  limit 1];
        Rate__c objRate = [Select id, RetailAmount__c from Rate__c limit 1];
        User objUser =[select id,name from user where isActive=true and username =:USERNAMECOMPLETE limit 1];
        //string AgreedRateString = '[{"checkboxId":"add-checkbox-a0O0Y000006OjcSUAS","isSelected":true,"objectMap":{"ServiceItem__c":{"Id":"objServiceItem.id","Name":"SIN-001318","ServiceType__c":"water  - DO NOT USE","ServiceItemType__c":"a0a0Y0000031MauQAE","Retail_Amount__c":1.25,"Supply_Point__c":"SP-000001693","Location__c":"Rattery,South Brent, Devon, England, UK, TQ10 9LB","Service__c":"a010Y00000cn1u2QAA","attributes":{"type":"ServiceItem__c"}},"AgreedRate__c":{"Value__c":100,"StartDate__c":"2017-12-19","EndDate__c":"2017-12-30","LeapYear__c":true,"attributes":{"type":"AgreedRate__c"}}},"readOnlyFields":{},"uniqueId":"a0O0Y000006OjcSUAS"}]';
        //Delete contract record related to account in order to test negative scenario
        AgreedRate__c aggrate = new AgreedRate__c();
        aggrate.StartDate__c = system.today();
        aggrate.EndDate__c = system.today().addDays(300);
        aggrate.Value__c = 100;
        aggrate.LeapYear__c = false;
        List<BlAp_CombinedRecord>  AgreedRatesComList = new List<BlAp_CombinedRecord>();
        BlAp_CombinedRecord aggContract = new BlAp_CombinedRecord();            
        aggContract.uniqueId=objServiceItem.Id;
        aggContract.isSelected = true;
        aggContract.objectMap = new Map<string, sObject>();
        aggContract.readOnlyFields = new Map<string, boolean>();
        aggContract.objectMap.put(BlAp_Constants.SERVICEITEMNAME , objServiceItem);
        aggContract.objectMap.put(BlAp_Constants.AGREEDRATESNAME, aggrate);
        aggContract.objectMap.put(CuAp_Constants.OBJECTAPIRATES, objRate);
        AgreedRatesComList.add(aggContract);
        string AgreedRateString = JSON.serialize(AgreedRatesComList);
        system.Runas(objUser){
        Test.starttest();
        string response = CuAp_AgreedRatePageCtrlr.saveAgreedRate(AgreedRateString);
        Test.stoptest();
        //Asserts to check properties of list of BlAp_CombinedRecord retrieved
         System.assertEquals(response,Label.CuAp_AgreedRate_Sucess);

        }
    
    }
    
    }