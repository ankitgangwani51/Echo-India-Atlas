/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        23 January 2018
@description: Test Class for DrUt_AddServiceItems 
*******************************************************************************/

@isTest
public class DrUt_AddServiceItems_Test {
   
    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static final String CONTRACT_NAME1       = 'TestContract1';
    private static final String CONTRACT_NAME2       = 'TestContract2';  
    private static final String PAYMENTPLANTYPE_NAME = 'TestPaymentPlanType';
    private static final Integer PLANAMOUNT          = 5000;
    private static final Integer NUMBEROFINSTALMENTS = 10;
    private static final String DEVICE_NAME         = 'TestDevice';
    private static final String DEVICE_TYPE         = 'TestDeviceType';
    private static final String TEST_SERVICE_TYPE1  = 'TestServiceType1';
    private static final String TEST_SERVICE_TYPE2  = 'TestServiceType2';
    private static final String LOCATION_NAME       = 'A99 9AA';
    private static final String LOCATION_SUB_TYPE   = 'Detached';
    private static final String STREET              = 'teststreet';
    private static final String YES                 = 'yes';
    private static final String MEASURED            = 'Monthly';
    private static final String WHOLESALER          = 'TestWholesaler';
    private static final String AVAILABLESERVICES   = 'TestAvailableService';
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';
    private static final String BUNDLE_POSITIVE     = 'TestBundle1';
    private static final String BUNDLE_NEGATIVE     = 'TestBundle2';
    private static final String BUNDLEITEM          = 'TestBundleItem';
    private static final String POSITIVETEST        = 'PositiveTest';
    private static final String NEGATIVETEST        = 'NegativeTest';
    private static final String YEARLY              = 'Yearly';
    private static final String INSTALMENTPLAN      = 'Instalment Plan';
    private static final Integer MAXNUMOFINSTALMENTS = 12;
    private static final String ADDADDTNALSERVICES  = 'Add Additional Services';
    private static final String POSITIVE            = 'Positive';
    private static final String NEGATIVE            = 'Negative';
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    private static final String DEVICE_SIZE 		= 'TestDeviceSize';
    private static final String MANUFACTURER 		= 'Siemens';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    
    /*******************************************************************
    @author:      Echo: Mohit Tayal
    @date:        16 January 2018
    @param:       N/A
    @return:      void
    @description: method to create test data used by all test methods
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c con1 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME1,objAccount); 
        Database.insert(con1);
        
        BillingContract__c con2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2,objAccount); 
        Database.insert(con2);

        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME, YEARLY, MAXNUMOFINSTALMENTS);
        objPaymentPlanType.PlanType__c = INSTALMENTPLAN;       
        Database.insert(objPaymentPlanType);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE1);
        Database.insert(objServiceType);
        
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE2);
        Database.insert(objServiceType2);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = Date.today();
        Database.insert(objReading1); 
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Insert Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c objService = GlUt_FactoryData_Test.createService(con1,objReading1,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        Service__c objService2 = GlUt_FactoryData_Test.createService(con1,objReading1,objServiceType2,objSupplyPoint,objAvailableService);
        Database.insert(objService2);
        
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_POSITIVE,objServiceType);
        Database.insert(objBundle);
        
        Bundle__c objBundle2 = GlUt_FactoryData_Test.createBundle(BUNDLE_NEGATIVE,objServiceType2);
        Database.insert(objBundle2);
        
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,null);
        Database.insert(objBundleItem);     
        
        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess1 = GlUt_FactoryData_Test.createDebtRecoveryProcess(con1);
        objDebtRecProcess1.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess1);
        con1.CurrentDebtRecoveryProcess__c = objDebtRecProcess1.Id;
        Database.update(con1);
        
        DebtRecoveryProcess__c objDebtRecProcess2 = GlUt_FactoryData_Test.createDebtRecoveryProcess(con2);
        objDebtRecProcess2.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess2);
        
        //Create Debt. Recovery Action record        
        DebtRecoveryAction__c objDebtRecAct4 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
        objDebtRecAct4.Action__c = ADDADDTNALSERVICES;
        objDebtRecAct4.Processed__c = FALSE;
        objDebtRecAct4.Parameters__c = BUNDLE_POSITIVE;
        objDebtRecAct4.Date__c = Date.today() - 5;
        Database.insert(objDebtRecAct4);
        
        DebtRecoveryAction__c objDebtRecAct5 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess2);
        objDebtRecAct5.Action__c = ADDADDTNALSERVICES;
        objDebtRecAct5.Processed__c = FALSE;
        objDebtRecAct5.Parameters__c = BUNDLE_POSITIVE;
        objDebtRecAct5.Date__c = Date.today() - 5;
        Database.insert(objDebtRecAct5);
    }
    
/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 January 2018
@param:       N/A
@return:      void
@description: Positive Test scenario for AddServiceItem
********************************************************************/
 
      static testmethod void AddServiceItem_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1]; 
    
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id, DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Processed__c = FALSE];    
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }   
          
        System.runAs(objUser){
            Test.startTest();
            DrUt_AddServiceItems.addServiceItem(debtRecoveryActId);
            Test.stopTest();
            
            List<DebtRecoveryAction__c> debtRecActList = [SELECT Id,Processed__c,DebtRecoveryProcess__r.BillingContract__c,Date__c FROM DebtRecoveryAction__c WHERE Processed__c = TRUE];
            List<ServiceType__c> serviceTypeList = [SELECT Id, Name FROM ServiceType__c WHERE Name = :TEST_SERVICE_TYPE1 LIMIT 1];
            List<Bundle__c> bundleList = [SELECT Id, Name, ServiceType__c FROM Bundle__c WHERE Name = :BUNDLE_POSITIVE AND ServiceType__c = :serviceTypeList.get(0).Id LIMIT 1];
            
            ValidateCreatedData(debtRecActList, bundleList, POSITIVE);
        }
    }
    
/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 January 2018
@param:       N/A
@return:      void
@description: Negative Test scenario for AddServiceItem
********************************************************************/
 
      static testmethod void AddServiceItem_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1]; 
    
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id, DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Processed__c = TRUE];    
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }   
          
        System.runAs(objUser){
            Test.startTest();
            DrUt_AddServiceItems.addServiceItem(debtRecoveryActId);
            Test.stopTest();
            
            List<DebtRecoveryAction__c> debtRecActList = [SELECT Id,Processed__c,DebtRecoveryProcess__r.BillingContract__c,Date__c FROM DebtRecoveryAction__c WHERE Processed__c = TRUE];
            List<ServiceType__c> serviceTypeList = [SELECT Id, Name FROM ServiceType__c WHERE Name = :TEST_SERVICE_TYPE2 LIMIT 1];
            List<Bundle__c> bundleList = [SELECT Id, Name, ServiceType__c FROM Bundle__c WHERE Name = :BUNDLE_NEGATIVE AND ServiceType__c = :serviceTypeList.get(0).Id LIMIT 1];
            
            ValidateCreatedData(debtRecActList, bundleList, NEGATIVE);
        }
    }
    
/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 January 2018
@param:       debtRecActList - Debt Recovery Action records list
              bundleList - Bundle records list
              TestCase - Indicates wether called form postive or negative
                         scenario.
@return:      void
@description: Assertion to be checked by both positive and negative scenario
********************************************************************/    

    public static void ValidateCreatedData(List<DebtRecoveryAction__c> debtRecActList, List<Bundle__c> bundleList, String TestCase){
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> serviceIdSet = new Set<Id>();
        Map<Id,List<Service__c>> contractIdServiceMap = new Map<Id,List<Service__c>>();
        
        for(DebtRecoveryAction__c debtRecAct : debtRecActList){
            contractIdSet.add(debtRecAct.DebtRecoveryProcess__r.BillingContract__c);
        }
        
        List<Service__c> serviceList = [SELECT Id, ServiceType__c, BillingContract__c, ServiceStartDate__c, ServiceEndDate__c FROM Service__c WHERE BillingContract__c IN:contractIdSet];
        
        for(Service__c serviceRec : serviceList){
            if(!contractIdServiceMap.containsKey(serviceRec.BillingContract__c)){
                contractIdServiceMap.put(serviceRec.BillingContract__c, new List<Service__c>());
                contractIdServiceMap.get(serviceRec.BillingContract__c).add(serviceRec);
            }else{
                contractIdServiceMap.get(serviceRec.BillingContract__c).add(serviceRec);
            }
        }
        
        for(DebtRecoveryAction__c dbRecAction : debtRecActList){
            System.assertEquals(True,dbRecAction.Processed__c);
            
            if(contractIdServiceMap.containsKey(dbRecAction.DebtRecoveryProcess__r.BillingContract__c)){
                for(Service__c serviceRec : contractIdServiceMap.get(dbRecAction.DebtRecoveryProcess__r.BillingContract__c)){
                    if(serviceRec.ServiceType__c == bundleList.get(0).ServiceType__c && (serviceRec.ServiceEndDate__c > dbRecAction.Date__c || serviceRec.ServiceEndDate__c == null)){
                        System.assertNotEquals(null, serviceRec.ServiceStartDate__c);   
                        serviceIdSet.add(serviceRec.Id);
                    }
                }
            }
        }
        
        List<ServiceItem__c> serviceItemList = [SELECT Id, Service__c, ServiceItemType__c, StartDate__c FROM ServiceItem__c WHERE Service__c IN :serviceIdSet];
        if(TestCase == NEGATIVE){
            System.assert(serviceItemList.size() == 0);
        } else{
            System.assert(serviceItemList.size() > 0);
        }
    }    
}