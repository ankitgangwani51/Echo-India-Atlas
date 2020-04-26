/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        05 September 2017
@description: Test Class for BlIn_BillCalcDataContainer
Revision(s):  Shivangi Gaur -- 05-Jan-2018 -- Incorporated review comments on AT-1091 
                                              dated 03-01-2018
              Shivangi Gaur -- 08-Jan-2018 -- Incorporated review comments on AT-1091 
                                              dated 05-01-2018
*******************************************************************************/

@isTest
//test data creation for BlIn_BillCalcDataContainer class
public class BlIn_BillCalcDataContainer_Test{
    
    private static final String PDF_TEMPLATE_NAME = 'pdfTemplateName';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME1 ='TestContract1';
    private static final String CONTRACT_NAME2 ='TestContract2';
    private static final String REGION ='England';
    private static final String REGION1 ='Scotland';
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
    private static final String AVAILABLESERVIEITEM1='TestAvailableServiceItem1';
    private static final String SITESAMPLE ='Testsitesample';
    private static final String SAMPLE ='TestSample';
    private static final String AGREERATE ='TestAgreeRate';
    private static final String AGREERATE1 ='TestAgreeRate1';
    private static final String BILLNAME = 'testBill';
    private static final String BILLSERVICENAME = 'Test Bill Service';
    private static final String BILLITEMNAME = 'Test Bill Item';
    private static final String GROUPNAME = 'Test Group';
    private static final String GROUPITEMNAME = 'Test Group Item';
    private static final String PAYMENTPLANNAME = 'Test Payment Plan Type';
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final String HEROKUPOSTGRESID = 'Test ID';
    private static final Integer PLANAMOUNT = 56557;
    private static final Integer NUMBEROFINSTALMENTS =12;
    private static final String USERNAMECOMPLETE = USER_NAME+ '@unitest.com';
    private static final Integer MAXINSTLLMNT = 12;
    private static final String PLANTYP = 'Instalment Plan';
    private static final String FREQUENCY = 'Monthly';
    private static final Decimal AVGUSE = 200.0;
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String ALLOWANCETYPENAME       = 'TestAllowanceType';
    private static final String ALLOWANCEPRIORITY       = '1';
    private static final String ALLOWANCETYPE           = 'Fixed Volume Allowance';
    private static final String SIAGREEDVOLUMENAME      = 'TestSIAgreedVolumeName';
    private static final String SIAGREEDVOLUMENAME1      = 'TestSIAgreedVolumeName1';
    private static final Integer SIAGREEDVOLUME         = 50;
    private static final String SUPPLYPOINTALLOWANCENAME = 'TestSupplyPointAllowanceName';
    private static final String VOLUMEALTERATIONITEMNAME = 'TestVolumeAlterationItemName';
    private static final Decimal ALLOWANCEAPPLIED        = 5.0;
    private static final Decimal ALLOWANCEAVAILABLE      = 5.0;
    private static final Integer VOLUMEALTERATIONITEMORDER = 10;
    private static final String GROUPTYPENAME = 'TestGroupTypeName';
    private static final String TAXCLASSIFICATIONTYP_NAME = 'TestTaxClassificationType';
    private static final String SUPPRESSION_REASON = 'Payment Query';
    private static final Decimal PERCENTAGE_DISC_AMOUNT = 5.0;
    private static final Date START_DATE           = date.valueOf('2018-02-01');
    private static final Date END_DATE            = date.valueOf('2019-02-28');
    private static final String DISCOUNT_NAME          = 'Discount Type - 1';    
    private static final String DISCOUNT_TYPE         = 'Percentage';
    private static final String AGREEDSAMPLESTRENGTH_NAME = 'TestAgreedSampleStrength';
    private static final String AGREEDVOLUME_NAME = 'TestAgreedVolume';
    private static final Integer SAMPLE_STRENGTH_NUMBER = 100;
    /*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    
    @TestSetup
    static void createTestData(){        
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount); 
        
        ContractGroup__c objConGroup = GlUt_FactoryData_Test.createContractGroup(objAccount);
        Database.insert(objConGroup );
       
        List<BillingContract__c> billingContractList = new List<BillingContract__c>();
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME1,objAccount);
        con.Region__c = REGION;
        con.ContractGroup__c = objConGroup.id;
        billingContractList.add(con);
        
        BillingContract__c con1 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2,objAccount);
        con1.Region__c = REGION1;
        con1.ContractGroup__c = objConGroup.id;
        billingContractList.add(con1);
        
        if(!billingContractList.isEmpty())
            insert  billingContractList;
        
        BillEvent__c ObjBillEvent = GlUt_FactoryData_Test.createBillEvent(con);
        Database.insert(ObjBillEvent);
        
        BillEvent__c ObjBillEvent1 = GlUt_FactoryData_Test.createBillEvent(con1);
        Database.insert(ObjBillEvent1);
        
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
     
        List<Device__c> deviceList = new List<Device__c>();
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        deviceList.add(objDevice);
        
        Device__c objsubDevice = GlUt_FactoryData_Test.createDevice(SUB_DEVICE_TYPE ,objDeviceType );
        deviceList.add(objsubDevice);
        
        if(!deviceList.isEmpty())
            insert deviceList;
        
        List<ServiceType__c> serviceTypeList = new List<ServiceType__c>();
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        serviceTypeList.add(objServiceType);
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        serviceTypeList.add(objServiceType1);
        
        if(!serviceTypeList.isEmpty())
            insert serviceTypeList;
        
        List<Reading__c> readingList = new List<Reading__c>();
        Reading__c  objReading = GlUt_FactoryData_Test.createReading(objDevice);
        readingList.add(objReading);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.AmendedByReading__c = objReading.id;
        readingList.add(objReading1);
        
        if(!readingList.isEmpty())
            insert readingList;
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Main Supply Point
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        supplyPointList.add(objSupplyPoint);
        
        // Create Sub Supply Point
        SupplyPoint__c  objSubSP = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSubSP.Measured__c= True; // AT-3174 
        supplyPointList.add(objSubSP);
        
        if(!supplyPointList.isEmpty())
            insert supplyPointList;
        
        SupplyPointDevice__c objSupplyPointDevices = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevices);
        
        List<SupplyPointDeviceService__c> supplyPointDeviceServiceList = new List<SupplyPointDeviceService__c>();
        SupplyPointDeviceService__c objSPDS = GlUt_FactoryData_Test.createSupplyPointDeviceService(objSupplyPointDevices, objServiceType);
        supplyPointDeviceServiceList.add(objSPDS);
        
        SupplyPointDeviceService__c objSPDS1 = GlUt_FactoryData_Test.createSupplyPointDeviceService(objSupplyPointDevices, objServiceType1);
        supplyPointDeviceServiceList.add(objSPDS1);
        
        if(!supplyPointDeviceServiceList.isEmpty())
            insert supplyPointDeviceServiceList;
        
        AverageDailyUsage__c objAvgDailyUses = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevices);
        Database.insert(objAvgDailyUses);
        
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        List<ChargeBasis__c> chargeBasisList = new List<ChargeBasis__c>();
        ChargeBasis__c objChargeBasis = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        chargeBasisList.add(objChargeBasis);
        
        If(!chargeBasisList.isEmpty())
            insert chargeBasisList;
        
        Service__c  objService = GlUt_FactoryData_Test.createService(con,objReading,objServiceType,objSupplyPoint,objAvailableService);    
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
        
        List<AvailableServiceItem__c> availableServiceItemList = new List<AvailableServiceItem__c>();
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        availableServiceItemList.add(objAvailableServiceItem);
       
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM1,objBundleItem,objServiceItemType,objAvailableBundle);
        availableServiceItemList.add(objAvailableServiceItem1);
        
        if(!availableServiceItemList.isEmpty())
            insert availableServiceItemList;
        
         //AT-3147
        DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
        Database.insert(objDischargeAgreement);   
        
        List<Sample__c> sampleList = new List<Sample__c>();
        Sample__c  objSample =GlUt_FactoryData_Test.createSample(SAMPLE);
        objSample.CODSampleStrength__c = SAMPLE_STRENGTH_NUMBER;
        objSample.SampleCollectionDate__c = Date.today();           
        objSample.DischargeAgreement__c  = objDischargeAgreement.Id;   //at-3147
        sampleList.add(objSample);
        
        Sample__c  objSample1 =GlUt_FactoryData_Test.createSample(SAMPLE);
        objSample1.SampleCollectionDate__c = Date.today();
        objSample1.DischargeAgreement__c  = objDischargeAgreement.Id;   //at-3147
        objSample1.SSSampleStrength__c = SAMPLE_STRENGTH_NUMBER;
        objSample1.AmendedBySample__c = objSample.Id;
        sampleList.add(objSample1);

        if(!sampleList.isEmpty())
            insert sampleList;
        
        List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.DischargeAgreement__c = objDischargeAgreement.Id;
        serviceItemList.add(objServiceItem);
        
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem1,objServiceItemType,objService);
        objServiceItem1.AmendedByServiceItem__c = objServiceItem.Id;
        objServiceItem1.DischargeAgreement__c = objDischargeAgreement.Id;
        serviceItemList.add(objServiceItem1);      
        
        if(!serviceItemList.isEmpty())
            insert serviceItemList;
        
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
       // objDeviceRelationship.MainSupply__c=objSupplyPoint.Id;
        Database.insert(objDeviceRelationship);*/
        
        SupplyPointRelationship__c objSupplyPointRelationship = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplypoint, objSubSP);
        Database.insert(objSupplyPointRelationship);       
        
        List<AgreedRate__c> agreedRateList = new List<AgreedRate__c>();
        AgreedRate__c  objAgreedRate =GlUt_FactoryData_Test.createAgreedRate(AGREERATE,objServiceItem);
        agreedRateList.add(objAgreedRate);
        
        AgreedRate__c  objAgreedRate1 =GlUt_FactoryData_Test.createAgreedRate(AGREERATE1,objServiceItem);
        objAgreedRate1.AmendedByAgreedRate__c = objAgreedRate.Id;
        agreedRateList.add(objAgreedRate1);
        
        if(!agreedRateList.isEmpty())
            insert agreedRateList;
        
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
        
        TaxClassificationType__c objTaxClassificationType = GlUt_FactoryData_Test.createTaxClassificationType(TAXCLASSIFICATIONTYP_NAME);
        Database.insert(objTaxClassificationType);
        
        TaxClassification__c objTaxClassification = GlUt_FactoryData_Test.createTaxClassification(objAccount,objTaxClassificationType);
        objTaxClassification.Account__c = con.AccountName__c;
        Database.insert(objTaxClassification);
        
        TaxClassification__c objTaxClassification1 = GlUt_FactoryData_Test.createTaxClassification(objAccount,objTaxClassificationType);
        objTaxClassification1.AmendedByTaxClassification__c = objTaxClassification.Id;
        Database.insert(objTaxClassification1);
        
        Suppression__c objSuppression = GlUt_FactoryData_Test.createSuppression(objAccount, con, SUPPRESSION_REASON);  
        objSuppression.SuppressionStartDate__c = System.today();
        Database.insert(objSuppression); 
        
        // Create Discount Type Record
        DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(DISCOUNT_NAME, START_DATE, END_DATE, DISCOUNT_TYPE, PERCENTAGE_DISC_AMOUNT);
        Database.insert(objDiscountType); 
        
        Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(con,objDiscountType);
        Database.insert(objDiscount); 
        
        Discount__c objDiscount1 = GlUt_FactoryData_Test.createDiscount(con,objDiscountType);
        objDiscount1.AmendedByDiscount__c = objDiscount.Id;
        Database.insert(objDiscount1); 
        
        AllowanceType__c objAllowanceType = GlUt_FactoryData_Test.createAllowanceType(ALLOWANCETYPENAME, objServiceItemFamily, objSupplyPointUsageType, ALLOWANCEPRIORITY, ALLOWANCETYPE, True);
        Database.insert(objAllowanceType);
        
        SIAgreedVolume__c objSIAgreedVolume = GlUt_FactoryData_Test.createSIAgreedVolume(SIAGREEDVOLUMENAME, objServiceItem, SIAGREEDVOLUME);
        Database.insert(objSIAgreedVolume);
        
        SIAgreedVolume__c objSIAgreedVolume1 = GlUt_FactoryData_Test.createSIAgreedVolume(SIAGREEDVOLUMENAME1, objServiceItem, SIAGREEDVOLUME);
        objSIAgreedVolume1.SIAgreedVolume__c = objSIAgreedVolume.Id;
        Database.insert(objSIAgreedVolume1);
        
        SupplyPointAllowance__c objSupplyPointAllowance = GlUt_FactoryData_Test.createSupplyPointAllowance(SUPPLYPOINTALLOWANCENAME, objServiceItem, objAllowanceType, TRUE, objSupplyPoint);
        Database.insert(objSupplyPointAllowance);
        
        AgreedSampleStrength__c objAgreedSampleStrength = GlUt_FactoryData_Test.createAgreedSampleStrength(AGREEDSAMPLESTRENGTH_NAME,objDischargeAgreement);
        Database.insert(objAgreedSampleStrength);
        
        AgreedVolume__c objAgreedVolume = GlUt_FactoryData_Test.createAgreedVolume(AGREEDVOLUME_NAME,objDischargeAgreement);
        Database.insert(objAgreedVolume); 
        
        // Rural License record
        RuralLicense__c objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
        Database.insert(objRuralLicense);
       
        //Rural Entitlement record
        RuralEntitlement__c objRuralEntitlement = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        Database.insert(objRuralEntitlement);
        
        //Rural Gross Consumption record
        RuralGrossConsumption__c objRuralGrossConsumptionOld = GlUt_FactoryData_Test.createRuralGrossConsumption(objRuralEntitlement, objSupplyPoint);
        Database.insert(objRuralGrossConsumptionOld);
        
        //Rural Gross Consumption record
        RuralGrossConsumption__c objRuralGrossConsumptionNew = GlUt_FactoryData_Test.createRuralGrossConsumption(objRuralEntitlement, objSupplyPoint);
        Database.insert(objRuralGrossConsumptionNew);
        
        //update old Rural gross consuption record 
        objRuralGrossConsumptionOld.AmendedBy__c = objRuralGrossConsumptionNew.Id;
        Database.update(objRuralGrossConsumptionOld);
        
    }           
    

 /******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        15 December 2017
@description: Test method for BlIn_BillCalcDataContainer  {Positive scenario} where 
              bill id is fetched on basis of contract group
*******************************************************************************/ 

    static testmethod void BlIn_BillCalcDataContainerFromContractGrp_Positive(){
        
        //Query user record
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
                
        //Query ContractGroup__c record
        ContractGroup__c objConGroup = [select id from ContractGroup__c limit 1];
        SupplyPointDevice__c spdObj = [Select id from SupplyPointDevice__c limit 1];
        //Query Bill Calculation record
        BillCalculation__c objBillCalculation = [select id, ContractGroup__c,BillingContract__c from BillCalculation__c where ContractGroup__c =: objConGroup.id];
        Id billCalculationId = objBillCalculation.id;
        
        // as per main class construction passing parameter is List<BillingContract__c>
       // List<BillingContract__c> objCon = [select id from BillingContract__c ];
        // get the contract records
        List<BillingContract__c> contracts = objBillCalculation.ContractGroup__c != null 
					                ? GlUt_ContractUtilities.getContracts(objBillCalculation.ContractGroup__c) 
					                : GlUt_ContractUtilities.getContract(objBillCalculation.BillingContract__c);
        
        System.runAs(objUser){
            Test.startTest();            
            BlIn_BillCalcDataContainer objBlIn_BillCalcDataContainer = new BlIn_BillCalcDataContainer(contracts); 
            Test.stopTest();
            
            //Assert various properties of objBlIn_BillCalcDataContainer received
            //System.assertNotEquals(objBlIn_BillCalcDataContainer.billData,null);
           // System.assertNotEquals(objBlIn_BillCalcDataContainer.averageDailyUses,null);
            //Fetch details of average daily use from the response
            AverageDailyUsage__c avgUseObj = [Select id, SupplyPointDevice__c, AverageDailyUsage__c from AverageDailyUsage__c where id =: objBlIn_BillCalcDataContainer.averageDailyUses[0].id];
            System.assertEquals(avgUseObj.AverageDailyUsage__c,AVGUSE);
            System.assertEquals(avgUseObj.SupplyPointDevice__c,spdObj.id);  
            
            System.assertNotEquals(objBlIn_BillCalcDataContainer.services,null);
        }       
    }
    
   /******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        15 December 2017
@description: Test method for BlIn_BillCalcDataContainer  {Positive scenario} where 
              bill id is fetched on basis of contract directly
*******************************************************************************/    
     static testmethod void BlIn_BillCalcDataContainerFromContract_Positive(){
        
        //Query user record
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        //Query ContractGroup__c record
        ContractGroup__c objConGroup = [select id from ContractGroup__c limit 1];
        SupplyPointDevice__c spdObj = [Select id from SupplyPointDevice__c limit 1];
        //Query Bill Calculation record
        BillCalculation__c objBillCalculation = [select id, ContractGroup__c,BillingContract__c from BillCalculation__c where ContractGroup__c =: objConGroup.id];
        Id billCalculationId = objBillCalculation.id;
        
        // as per main class construction passing parameter is List<BillingContract__c>
        List<BillingContract__c> lstCon = [select Id,BillingMethod__c,BillingFrequency__c,AccountName__r.Name,AccountName__r.Suppressed__c,
                                           AccountName__c,ContractStartDate__c,BudgetPlanHold__c,ContractEndDate__c,
                                           LastBillCalculationDate__c,OwnedBy__c,HoldEntireBillforToleranceFail__c,
                                          (select Id,EventType__c,Status__c from BillEvents__r),Suppressed__c
                                           from BillingContract__c LIMIT 5];
        
        System.runAs(objUser){
            Test.startTest();            
            BlIn_BillCalcDataContainer objBlIn_BillCalcDataContainer = new BlIn_BillCalcDataContainer(lstCon); 
            BlIn_BillCalcDataContainer.BlIn_BillCalcContractObj objBlIn_BillCalcContractObj = new BlIn_BillCalcDataContainer.BlIn_BillCalcContractObj(objBlIn_BillCalcDataContainer, lstCon[0]);
            Test.stopTest();
            
            //Assert various properties of objBlIn_BillCalcDataContainer received
            //System.assertNotEquals(objBlIn_BillCalcDataContainer.billData,null);
           // System.assertNotEquals(objBlIn_BillCalcDataContainer.averageDailyUses,null);
            //Fetch details of average daily use from the response
            AverageDailyUsage__c avgUseObj = [Select id, SupplyPointDevice__c, AverageDailyUsage__c from AverageDailyUsage__c where id =: objBlIn_BillCalcDataContainer.averageDailyUses[0].id];
            System.assertEquals(avgUseObj.AverageDailyUsage__c,AVGUSE);
            System.assertEquals(avgUseObj.SupplyPointDevice__c,spdObj.id);  
            
            System.assertNotEquals(objBlIn_BillCalcDataContainer.services,null);         
        }
 }   

   /******************************************************************************
    @author:      Accenture: Vandana Anshu
    @date:        15 December 2017
    @description: Test method for BlIn_BillCalcDataContainer  {Negative scenario} where 
                  instead of bill id some other id is passed as parameter
    *******************************************************************************/    
    static testmethod void BlIn_BillCalcDataContainer_Negative(){

        //Query user record
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];

        //Query Contract record 
        List<BillingContract__c> objContract = new List<BillingContract__c>();

        boolean isException = false;
        BlIn_BillCalcDataContainer objBlIn_BillCalcDataContainer;

        System.runAs(objUser){
            Test.startTest();
            try{
                 objBlIn_BillCalcDataContainer = new BlIn_BillCalcDataContainer(objContract);
            }
            catch(Exception exc){
                isException = true;
            } 
            System.assert(objBlIn_BillCalcDataContainer.contracts.isEmpty());     
            Test.stopTest();    
        }
    }
}