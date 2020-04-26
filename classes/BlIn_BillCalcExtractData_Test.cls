/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        05 September 2017
@description: Test Class for BlIn_BillCalcExtractData
Revision(s):  Shivangi Gaur -- 16-Nov-2017 -- Updated value for Debt Recovery Profile.
*******************************************************************************/

@isTest
//test data creation for BlIn_BillCalcExtractData class
public Class BlIn_BillCalcExtractData_Test{
    
    private static final string DEBT_RECOVERY_PROFILE = 'Profile 1';
    private static final string BILLING_FREQUENCY = 'Monthly';
    private static final string BILLING_ADDRESS = 'Test Address';
    private static final string PROFILE_NAME = 'System Administrator';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser';
    private static final String USER_EMAIL = 'TestUser@unitest.com'; 
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String SUB_DEVICE_TYPE ='TestSubDevice';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final String BILLITEMNAME = 'Test Bill Item';
    private static final String HEROKUPOSTGRESID = 'Test ID';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String BUNDLE ='TestBundle';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String AVAILABLESERVIEITEM1='TestAvailableServiceItem1';
    private static final String SITESAMPLE ='Testsitesample';
    private static final String SAMPLE ='TestSample';
    private static final String AGREERATE ='TestAgreeRate';
    private static final String BILLNAME = 'testBill';
    private static final String BILLSERVICENAME = 'Test Bill Service';
    private static final String GROUPNAME = 'Test Group';
    private static final String PAYMENTPLANNAME = 'Test Payment Plan Type';
    private static final Integer MAXINSTLLMNT = 12;
    private static final String PLANTYP = 'Instalment Plan';
    private static final String FREQUENCY = 'Monthly';
    private static final Integer PLANAMOUNT = 56557;
    private static final String GROUPTYPENAME = 'TestGroupTypeName';
    private static final Integer SAMPLE_STRENGTH_NUMBER = 100;
    
    /*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME );
        Database.insert(objAccount);
        
        // Create contract group Record  
        ContractGroup__c objConGroup = GlUt_FactoryData_Test.createContractGroup(objAccount);
        Database.insert(objConGroup);
        
        //Create list of contract records
        list<BillingContract__c >lstContract = new list<BillingContract__c>(); 
        
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_ONE ,objAccount); 
        con.DebtRecoveryProfile__c = DEBT_RECOVERY_PROFILE;
        con.BillingFrequency__c = BILLING_FREQUENCY;
        con.ContractGroup__c = objConGroup.Id;
        lstContract.add(con);
        
        BillingContract__c con2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_SECOND ,objAccount);
        con2.DebtRecoveryProfile__c = DEBT_RECOVERY_PROFILE;
        con2.BillingFrequency__c = BILLING_FREQUENCY;
        con.ContractGroup__c = objConGroup.Id;
        lstContract.add(con2);
        
        Database.insert(lstContract);
        
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation();        
        objBillCalculation.ContractGroup__c = objConGroup.Id;
        Database.insert(objBillCalculation);
        
        BillCalculation__c objBillCalculation1 = GlUt_FactoryData_Test.createBillCalculation();
        objBillCalculation1.BillingContract__c = con.id;
        Database.insert(objBillCalculation1);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        Device__c objsubDevice = GlUt_FactoryData_Test.createDevice(SUB_DEVICE_TYPE ,objDeviceType );
        Database.insert(objsubDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType1);
        
        Reading__c  objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.AmendedByReading__c = objReading.id;
        Database.insert(objReading1);
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);        
        
        // Create Main Supply Point
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Sub Supply Point
        SupplyPoint__c  objSubSP = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSubSP.Measured__c= True; // AT-3174 
        Database.insert(objSubSP);
        
        SupplyPointDevice__c objSupplyPointDevices = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevices);
        
        SupplyPointDeviceService__c objSPDS = GlUt_FactoryData_Test.createSupplyPointDeviceService(objSupplyPointDevices, objServiceType);
        Database.insert(objSPDS);
        
        SupplyPointDeviceService__c objSPDS1 = GlUt_FactoryData_Test.createSupplyPointDeviceService(objSupplyPointDevices, objServiceType1);
        Database.insert(objSPDS1);
        
        AverageDailyUsage__c objAvgDailyUses = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevices);
        Database.insert(objAvgDailyUses);  
        
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        ChargeBasis__c objChargeBasis = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        Database.insert(objChargeBasis);

        DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
        Database.insert(objDischargeAgreement);
        
        Service__c  objService = GlUt_FactoryData_Test.createService(con,objReading,objServiceType,objSupplyPoint,objAvailableService);  
       // objService.DischargeAgreement__c = objDischargeAgreement.Id;   //Commented AT-3147
        Database.insert(objService);
        
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM1,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem1); 
        
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.DischargeAgreement__c = objDischargeAgreement.Id; //AT-3147
        objServiceItem.StartDate__c = system.today();  //AT-3147
        Database.insert(objServiceItem);
        
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem1,objServiceItemType,objService);
        objServiceItem1.AmendedByServiceItem__c = objServiceItem.Id;
        objServiceItem1.DischargeAgreement__c = objDischargeAgreement.Id; //AT-3147
        objServiceItem1.StartDate__c = system.today();  //AT-3147
        Database.insert(objServiceItem1);
               
        GroupType__c objGroupType = GlUt_FactoryData_Test.createGroupType(GROUPTYPENAME);
        Database.insert(objGroupType);
                   
        Group__c objGroup = GlUt_FactoryData_Test.createGroup(GROUPNAME);  
        objGroup.GroupType__c = objGroupType.Id;
        Database.insert(objGroup);
        
        GroupItem__c  objGroupItem = GlUt_FactoryData_Test.createGroupItem(objServiceItem); 
        objGroupItem.Group__c = objGroup.Id;
        Database.insert(objGroupItem);
        
        // Commented by Ankit Gangwani for task - AT-2926, 22 June 2018  
        /*DeviceRelationship__c  objDeviceRelationship = GlUt_FactoryData_Test.createDeviceRelationship(objDevice,objsubDevice);
        //objDeviceRelationship.MainSupply__c=objSupplyPoint.Id;
        Database.insert(objDeviceRelationship);*/
        
        SupplyPointRelationship__c objSupplyPointRelationship = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPoint, objSubSP);
        Database.insert(objSupplyPointRelationship);    
        
        Sample__c  objSample =GlUt_FactoryData_Test.createSample(SAMPLE);
        objSample.CODSampleStrength__c = SAMPLE_STRENGTH_NUMBER;
        objSample.SampleCollectionDate__c = Date.today();
        objSample.DischargeAgreement__c = objDischargeAgreement.Id; //AT-3147
        Database.insert(objSample);
        
        Sample__c  objSample1 =GlUt_FactoryData_Test.createSample(SAMPLE);
        objSample1.SampleCollectionDate__c = Date.today();
        objSample1.SSSampleStrength__c = SAMPLE_STRENGTH_NUMBER;
        objSample1.AmendedBySample__c = objSample.Id;
        objSample1.DischargeAgreement__c = objDischargeAgreement.Id; //AT-3147
        Database.insert(objSample1);
        
        AgreedRate__c  objAgreedRate =GlUt_FactoryData_Test.createAgreedRate(AGREERATE,objServiceItem);
        Database.insert(objAgreedRate);
        
        AgreedRate__c  objAgreedRate1 =GlUt_FactoryData_Test.createAgreedRate(AGREERATE,objServiceItem);
        objAgreedRate1.AmendedByAgreedRate__c = objAgreedRate.Id;
        Database.insert(objAgreedRate1);
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME ,con);
        objBill.Account__c = objAccount.id; //AT-3174
        Database.insert(objBill);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        Database.insert(objBillItems);
        
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANNAME, FREQUENCY, MAXINSTLLMNT);      
        objPaymentPlanType.PlanType__c = PLANTYP;        
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,con,PLANAMOUNT);
        Database.insert(objPaymentPlan);
        
        ManualAmendment__c objManualAmendment = GlUt_FactoryData_Test.createManualAmendment(objBillItems);
        Database.insert(objManualAmendment);
        
        
    }
      
    /*******************************************************************
Purpose: Method to test Retrives and packages billing data (List of ID'S) {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retriveDataListContract_Positive(){
        User objUser =[select id,name from user where isActive=true and Email=:USER_EMAIL limit 1];
        BillingContract__c con =[Select id,name from BillingContract__c limit 1];
        BillCalculation__c objBillCalculation = [select id from BillCalculation__c limit 1];
        Id billCalculationId = objBillCalculation .id;
        List<Id> lstContractIds = new List<Id>();
        lstContractIds.add(con.id);
        System.runAs(objUser){
            Test.startTest();
            BlIn_BillCalcExtractData objBlIn_BillCalcExtractData = new BlIn_BillCalcExtractData(billCalculationId);
            String str1 = objBlIn_BillCalcExtractData.retrieveData();
            Test.stopTest();
            System.assertNotEquals(null,str1);
        }
        
    }
 
    /*******************************************************************
Purpose: Method to test Retrives and packages billing data (List of ID'S) {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retriveDataListContract_Negative(){
        User objUser =[select id,name from user where isActive=true and Email=:USER_EMAIL limit 1];
        boolean isException = false;
        BillingContract__c con =[Select id,name from BillingContract__c limit 1];
        BillCalculation__c objBillCalculation = [select id from BillCalculation__c limit 1];
        Id billCalculationId = objBillCalculation.id;
        List<Id> lstContractIds = new List<Id>();
        lstContractIds.add(con.id);
        
        delete objBillCalculation;
        billCalculationId = objBillCalculation.Id;
        System.runAs(objUser){
            Test.startTest();
            try{
                BlIn_BillCalcExtractData objBlIn_BillCalcExtractData = new BlIn_BillCalcExtractData(billCalculationId);
                String str1 = objBlIn_BillCalcExtractData.retrieveData();
            }catch(Exception e){
                System.assertEquals(e.getMessage(), e.getMessage());
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
            
        }
        
    }
    /*******************************************************************
Purpose: Method to test Retrives and packages billing data (List of ID'S) {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void retriveDataListContractGroup_Positive(){
        User objUser =[select id,name from user where isActive=true and Email=:USER_EMAIL limit 1];
        BillingContract__c con =[Select id,name from BillingContract__c limit 1];
        ContractGroup__c cg = [Select id,name from ContractGroup__c limit 1];
        BillCalculation__c objBillCalculation = [select id from BillCalculation__c limit 1];
        objBillCalculation.ContractGroup__c = cg.Id;
        update objBillCalculation;
        Id billCalculationId = objBillCalculation .id;
        List<Id> lstContractIds = new List<Id>();
        lstContractIds.add(con.id);
        System.runAs(objUser){
            Test.startTest();
            BlIn_BillCalcExtractData objBlIn_BillCalcExtractData = new BlIn_BillCalcExtractData(billCalculationId);
            String str1 = objBlIn_BillCalcExtractData.retrieveData();
            Test.stopTest();
            System.assertNotEquals(null,str1);
        }
        
    }
 
}