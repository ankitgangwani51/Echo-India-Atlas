/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        06 September 2017
@description: Test Class for BlIn_BillCalcResponseContainer 
*******************************************************************************/
@isTest
//test data creation for BlIn_BillCalcResponseContainer class
public class BlIn_BillCalcResponseContainer_Test{

    private static final String USER_ALIAS = 'standt';
    private static final String USER_EMAIL = '@unitest.com';
    private static final String USER_UTF = 'UTF-8';
    private static final String USER_LNAME= 'UnitTest';
    private static final String USER_LAN_LOCALKEY= 'en_US';
    private static final String USER_TIMEZONEKEY= 'America/Los_Angeles';
    private static final String USER_PHONE = '1234567891';
    private static final String USER_MPHONE = '0111111111';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
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
    private static final String MEASURED = 'monthly';
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
    private static final String DONOTPRINT = 'false';
    private static final String ANNUALBILL = 'false';
    private static final String BILLDATE = string.valueOf(System.Today());
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String TAXCLASSIFICATIONTYP_NAME = 'TestTaxClassificationType';
    private static final String AGREEDSAMPLESTRENGTH_NAME = 'TestAgreedSampleStrength';
    private static final String AGREEDVOLUME_NAME = 'TestAgreedVolume';
    private static final Decimal PERCENTAGE_DISC_AMOUNT = 5.0;
    private static final Date START_DATE 		 	 	= date.valueOf('2018-02-01');
    private static final Date END_DATE 		 			= date.valueOf('2019-02-28');
    private static final String DISCOUNT_NAME 	     	= 'TestDiscount';    
    private static final String DISCOUNT_TYPE 	 	 	= 'Percentage';
    private static final String AMENDMENTREASON 	 	= 'Reading Amendment';
    private static final String AMOUNT 	 	 	        = '100';
    private static final String TAXAMOUNT 	 	 	    = '10';
    private static final String DISCOUNTAMOUNT 	 	    = '10';
    //Start: AT-2782
    private static final String ALLOWANCETYPENAME 	 	= 'TestAllowanceType';
    private static final String ALLOWANCEPRIORITY 	 	= '1';
    private static final String ALLOWANCETYPE 	 	    = 'Fixed Volume Allowance';
    private static final String SIAGREEDVOLUMENAME 	 	= 'TestSIAgreedVolumeName';
    private static final Integer SIAGREEDVOLUME 	 	= 50;
    private static final String SUPPLYPOINTALLOWANCENAME = 'TestSupplyPointAllowanceName';
    private static final String VOLUMEALTERATIONITEMNAME = 'TestVolumeAlterationItemName';
    private static final Decimal ALLOWANCEAPPLIED        = 5.0;
    private static final Decimal ALLOWANCEAVAILABLE      = 5.0;
    private static final Integer VOLUMEALTERATIONITEMORDER = 10;
    //End: AT-2782
   
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
        System.runAs(objUser){
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
            
            // Commented by Ankit Gangwani for task - AT-2926, 22 June 2018  
            /*DeviceRelationship__c  objDeviceRelationship = GlUt_FactoryData_Test.CreateDeviceRelationship(objDevice,objsubDevice);
            // objDeviceRelationship.MainSupply__c=objSupplyPoint.Id;
            Database.insert(objDeviceRelationship);*/
        
        	SupplyPointRelationship__c objSupplyPointRelationship = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPoint, objSubSP);
        	Database.insert(objSupplyPointRelationship);  
            DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
            Database.insert(objDischargeAgreement);   
            /*
            Sample__c  objSample = GlUt_FactoryData_Test.CreateSample(SAMPLE ,objSupplyPoint);
            objSample.DischargeAgreement__c = objDischargeAgreement.Id;
            Database.insert(objSample);
			*/
            AgreedRate__c  objAgreedRate =GlUt_FactoryData_Test.CreateAgreedRate(AGREERATE,objServiceItem);
            Database.insert(objAgreedRate);
            Rate__c  objRate = GlUt_FactoryData_Test.createRate(objServiceItemType,100);
            Database.insert(objRate);
            RateBand__c  objRateBand = GlUt_FactoryData_Test.createRateBand(objRate,10,50);
            Database.insert(objRateBand);
            Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,objContract);
            objBill.Account__c = objAccount.id; //AT-3174
            Database.insert(objBill);
            BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
            Database.insert(objBillServiceType);
            BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
            Database.insert(objBillItems);
            ContractGroup__c objContractGroup = GlUt_FactoryData_Test.createContractGroup(objAccount);
            Database.insert(objContractGroup);              
            TaxClassificationType__c objTaxClassificationType = GlUt_FactoryData_Test.createTaxClassificationType(TAXCLASSIFICATIONTYP_NAME);
            Database.insert(objTaxClassificationType);
            AgreedSampleStrength__c objAgreedSampleStrength = GlUt_FactoryData_Test.createAgreedSampleStrength(AGREEDSAMPLESTRENGTH_NAME,objDischargeAgreement);
            Database.insert(objAgreedSampleStrength);
            AgreedVolume__c objAgreedVolume = GlUt_FactoryData_Test.createAgreedVolume(AGREEDVOLUME_NAME,objDischargeAgreement);
            Database.insert(objAgreedVolume); 
            TaxClassification__c objTaxClassification = GlUt_FactoryData_Test.createTaxClassification(objAccount,objTaxClassificationType);
            Database.insert(objTaxClassification); 
            ChargeBasis__c objChargeBasis = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
            Database.insert(objChargeBasis);
            // Create Discount Type Record
            DiscountType__c objDiscountType = GlUt_FactoryData_Test.createDiscountType(DISCOUNT_NAME, START_DATE, END_DATE, DISCOUNT_TYPE, PERCENTAGE_DISC_AMOUNT);
            system.debug('objDiscountType****'+ objDiscountType);
            Database.insert(objDiscountType); 
            system.debug('objDiscountType 222****'+ objDiscountType);
            
            // Create Discount Record
            Discount__c objDiscount = GlUt_FactoryData_Test.createDiscount(objContract, objDiscountType);
            Database.insert(objDiscount);
            
            ManualAmendment__c objManualAmendment = GlUt_FactoryData_Test.createManualAmendment(objBillItems);
            Database.insert(objManualAmendment);
			//Start: AT-2782
            AllowanceType__c objAllowanceType = GlUt_FactoryData_Test.createAllowanceType(ALLOWANCETYPENAME, objServiceItemFamily, objSupplyPointUsageType, ALLOWANCEPRIORITY, ALLOWANCETYPE, True);
            Database.insert(objAllowanceType);
            
            SIAgreedVolume__c objSIAgreedVolume = GlUt_FactoryData_Test.createSIAgreedVolume(SIAGREEDVOLUMENAME, objServiceItem, SIAGREEDVOLUME);
            Database.insert(objSIAgreedVolume);

            SupplyPointAllowance__c objSupplyPointAllowance = GlUt_FactoryData_Test.createSupplyPointAllowance(SUPPLYPOINTALLOWANCENAME, objServiceItem, objAllowanceType, TRUE, objSupplyPoint);
            Database.insert(objSupplyPointAllowance);
            
            VolumeAlterationItem__c objVolumeAlterationItem = GlUt_FactoryData_Test.createVolumeAlterationItem(VOLUMEALTERATIONITEMNAME, objBillItems, VOLUMEALTERATIONITEMORDER, ALLOWANCEAPPLIED, ALLOWANCEAVAILABLE, objSIAgreedVolume, objSupplyPointAllowance);
            Database.insert(objVolumeAlterationItem);
            //End: AT-2782
        }
    }
    /*******************************************************************
Purpose: Method to test JSON response Parsing {Positive scenario1}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void parseJSONString_Positive1(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation = [select id from BillCalculation__c limit 1]; 
        String jsonStr = herokuManualResponseCreationScenario(BILLDATE,FINALBILL);
        system.debug('');
        System.runAs(objUser){
            Test.startTest();
            BlIn_BillCalcResponseContainer objBlIn_BillCalcResponseContainer1 = BlIn_BillCalcResponseContainer.parse(jsonStr);
            List<Id>responseIds = BlIn_BillCalcResponseContainer.processResult(objBillCalculation.id,objBlIn_BillCalcResponseContainer1);
            Test.stopTest();
            Integer count = [select count() from Bill__c where Id In:responseIds];
            system.assertEquals(responseIds.size(),count);
            system.assert(responseIds!=null);
        }
    }

    /*******************************************************************
Author: Amit K.
Purpose: Method to manually create heroku response in test class wrather then using static JSON string.
Parameters: N/A 
Returns: String
Throws [Exceptions]: N/A
********************************************************************/
    static String herokuManualResponseCreationScenario(String billDate,String finalBill){
        ServiceItem__c  objServiceItem = [select id from ServiceItem__c  limit 1]; 
        Account objAccount = [Select id from Account limit 1];
        BillingContract__c objcontract = [Select id from BillingContract__c limit 1];
        Reading__c  objReading = [Select id from Reading__c limit 1];
        BillItem__c objBillItem = [Select id from BillItem__c limit 1];
        Rate__c  objRate = [Select id from Rate__c  limit 1];
        RateBand__c objRateBand = [Select id from RateBand__c limit 1];
        ContractGroup__c objContractGroup = [Select id from ContractGroup__c  limit 1];
        
        Location__c objLocation = [SELECT Id FROM Location__c WHERE PostalCode__c = :LOCATION_NAME LIMIT 1];
        DischargeAgreement__c objDischargeAgreement = [SELECT Id FROM DischargeAgreement__c WHERE Location__c = :objLocation.Id LIMIT 1];
        AgreedSampleStrength__c objAgreedSampleStrength = [SELECT Id FROM AgreedSampleStrength__c WHERE DischargeAgreement__c = :objDischargeAgreement.Id LIMIT 1];
        AgreedVolume__c objAgreedVolume = [SELECT Id FROM AgreedVolume__c WHERE DischargeAgreement__c = :objDischargeAgreement.Id LIMIT 1];
        TaxClassificationType__c objTaxClassificationType = [SELECT Id FROM TaxClassificationType__c WHERE Name = :TAXCLASSIFICATIONTYP_NAME LIMIT 1];
        TaxClassification__c objTaxClassification = [SELECT Id FROM TaxClassification__c WHERE Account__c = :objAccount.Id AND TaxClassificationType__c = :objTaxClassificationType.Id LIMIT 1];
        ServiceType__c objServiceType = [SELECT Id FROM ServiceType__c WHERE Name = :TEST_SERVICE_TYPE LIMIT 1];
        AvailableService__c  objAvailableService = [SELECT Id FROM AvailableService__c WHERE ServiceType__c = :objServiceType.Id LIMIT 1];
        ChargeBasis__c objChargeBasis = [SELECT Id FROM ChargeBasis__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        DiscountType__c objDiscountType = [SELECT Id FROM DiscountType__c WHERE Name =: DISCOUNT_NAME LIMIT 1];
        Discount__c objDiscount = [SELECT Id FROM Discount__c WHERE DiscountType__c = :objDiscountType.Id LIMIT 1];
        ManualAmendment__c objManualAmendment = [SELECT Id FROM ManualAmendment__c WHERE AmendedBillItem__c = :objBillItem.Id LIMIT 1];
        system.debug('101***');
        //Start: AT-2782
        ServiceItemFamily__c objServiceItemFamily = [SELECT Id FROM ServiceItemFamily__c WHERE ServiceType__c = :objServiceType.Id LIMIT 1];
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c WHERE Name = :SP_USAGE_TYPE LIMIT 1];
        AllowanceType__c objAllowanceType = [SELECT Id FROM AllowanceType__c WHERE SupplyPointUsageType__c = :objSupplyPointUsageType.Id AND ServiceItemFamily__c = :objServiceItemFamily.Id LIMIT 1];
        SIAgreedVolume__c objSIAgreedVolume = [SELECT Id FROM SIAgreedVolume__c WHERE ServiceItem__c = :objServiceItem.Id LIMIT 1];
        SupplyPointAllowance__c objSupplyPointAllowance = [SELECT Id FROM SupplyPointAllowance__c WHERE ServiceItem__c = :objServiceItem.Id AND AllowanceType__c = :objAllowanceType.Id LIMIT 1];
        VolumeAlterationItem__c objVolumeAlterationItem = [SELECT Id, StartDate__c, EndDate__c, AllowanceApplied__c, AllowanceAvailable__c,
                                                           BillItem__c, Order__c, ServiceItemAgreedVolume__c, SupplyPointAllowance__c FROM VolumeAlterationItem__c WHERE BillItem__c = :objBillItem.Id AND SupplyPointAllowance__c = :objSupplyPointAllowance.Id AND ServiceItemAgreedVolume__c = :objSIAgreedVolume.Id LIMIT 1];
        system.debug('102***');
        //End: AT-2782
        BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemObject objBlIn_BillCalcResponseBillItemObject = new BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemObject();
        objBlIn_BillCalcResponseBillItemObject.Id = TESTID ; 
        objBlIn_BillCalcResponseBillItemObject.Name = TESTNAME ;
        objBlIn_BillCalcResponseBillItemObject.ServiceItemId = objServiceItem.id;
        objBlIn_BillCalcResponseBillItemObject.BillItemId = objBillItem.id;
        objBlIn_BillCalcResponseBillItemObject.RateBandId = objRateBand.id;
        objBlIn_BillCalcResponseBillItemObject.ReadingId = objReading.id;
        objBlIn_BillCalcResponseBillItemObject.VolumeUsed = TESTAMOUNT ;
        objBlIn_BillCalcResponseBillItemObject.StartDate = String.valueof(system.today());
        objBlIn_BillCalcResponseBillItemObject.EndDate = String.valueof(system.today());
        objBlIn_BillCalcResponseBillItemObject.BilledAmount = TESTAMOUNT ;
        objBlIn_BillCalcResponseBillItemObject.BillItemTaxes = new List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemTaxObject>();
        objBlIn_BillCalcResponseBillItemObject.BillItemDiscounts = new List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemDiscountObject>();
        BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemAmendmentObject objBlIn_BillCalcResponseBillItemAmendmentObject = new BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemAmendmentObject();
        objBlIn_BillCalcResponseBillItemAmendmentObject.Id = TESTID;
        objBlIn_BillCalcResponseBillItemAmendmentObject.Name = TESTNAME;
        objBlIn_BillCalcResponseBillItemAmendmentObject.AmendmentReason = AMENDMENTREASON;
        objBlIn_BillCalcResponseBillItemAmendmentObject.AgreedSampleStrengthId = objAgreedSampleStrength.Id;
        objBlIn_BillCalcResponseBillItemAmendmentObject.AgreedVolumeId = objAgreedVolume.Id;
        objBlIn_BillCalcResponseBillItemAmendmentObject.ChargeBasisId = objChargeBasis.Id;
        //objBlIn_BillCalcResponseBillItemAmendmentObject.DiscountId = objDiscount.Id;
        objBlIn_BillCalcResponseBillItemAmendmentObject.ReadingId = objReading.Id;
        objBlIn_BillCalcResponseBillItemAmendmentObject.ServiceItemId = objServiceItem.Id;
        objBlIn_BillCalcResponseBillItemAmendmentObject.TaxClassificationId = objTaxClassification.Id;
        objBlIn_BillCalcResponseBillItemAmendmentObject.ManualAmendmentId = objManualAmendment.Id;
        objBlIn_BillCalcResponseBillItemAmendmentObject.Amount = AMOUNT;
        objBlIn_BillCalcResponseBillItemAmendmentObject.DiscountAmount = DISCOUNTAMOUNT;
        objBlIn_BillCalcResponseBillItemAmendmentObject.TaxAmount = TAXAMOUNT;
        //Start: AT-2782
        objBlIn_BillCalcResponseBillItemObject.VolumeAlterationItems = new List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemVolumeAlterationItemObject>();
        BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemVolumeAlterationItemObject objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject = new BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemVolumeAlterationItemObject();
        objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.AllowanceApplied = String.valueOf(objVolumeAlterationItem.AllowanceApplied__c);
        objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.AllowanceAvailable = String.valueOf(objVolumeAlterationItem.AllowanceAvailable__c);
        objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.BillItemId = objVolumeAlterationItem.BillItem__c;
        objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.EndDate = String.valueOf(objVolumeAlterationItem.EndDate__c);
        objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.Id = objVolumeAlterationItem.Id;
        objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.Order = String.valueOf(objVolumeAlterationItem.Order__c);
       // objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.SIAgreedVolume = objVolumeAlterationItem.ServiceItemAgreedVolume__c;
        objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.StartDate = String.valueOf(objVolumeAlterationItem.StartDate__c);
      //  objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject.SupplyPointAllowance = objVolumeAlterationItem.SupplyPointAllowance__c;
        objBlIn_BillCalcResponseBillItemObject.VolumeAlterationItems.add(objBlIn_BillCalcResponseBillItemVolumeAlterationItemObject);
        //End: AT-2782
        List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemAmendmentObject>lstBlIn_BillCalcResponseBillItemAmendmentObject = new List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemAmendmentObject>();
        lstBlIn_BillCalcResponseBillItemAmendmentObject.add(objBlIn_BillCalcResponseBillItemAmendmentObject);
        List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemObject>lstBlIn_BillCalcResponseBillItemObject  = new List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillItemObject>();
        lstBlIn_BillCalcResponseBillItemObject.add(objBlIn_BillCalcResponseBillItemObject);
        BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillServiceTypeObject objBlIn_BillCalcResponseBillServiceTypeObject = new BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillServiceTypeObject ();
        objBlIn_BillCalcResponseBillServiceTypeObject.Id = TESTID ;
        objBlIn_BillCalcResponseBillServiceTypeObject.Name = TESTNAME ;
        objBlIn_BillCalcResponseBillServiceTypeObject.ServiceTypeId = objServiceType.id;
        objBlIn_BillCalcResponseBillServiceTypeObject.BillItems = lstBlIn_BillCalcResponseBillItemObject;
        List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillServiceTypeObject>lstBlIn_BillCalcResponseBillServiceTypeObject  = new List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillServiceTypeObject>();
        lstBlIn_BillCalcResponseBillServiceTypeObject.add(objBlIn_BillCalcResponseBillServiceTypeObject);
        BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillObj objBlIn_BillCalcResponseBillObj = new BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillObj();
        objBlIn_BillCalcResponseBillObj.Id = TESTID ;
        objBlIn_BillCalcResponseBillObj.Name = TESTNAME ;
        objBlIn_BillCalcResponseBillObj.AccountId = objAccount.id;
        objBlIn_BillCalcResponseBillObj.BillDate = billDate;
        objBlIn_BillCalcResponseBillObj.ContractId = objcontract.id;
        objBlIn_BillCalcResponseBillObj.ContractGroupId = objContractGroup.id;
        objBlIn_BillCalcResponseBillObj.BilledAmount = TESTAMOUNT ;
        objBlIn_BillCalcResponseBillObj.TotalDue = TESTAMOUNT ;
        objBlIn_BillCalcResponseBillObj.FinalBill = finalBill;
        objBlIn_BillCalcResponseBillObj.DoNotPrint = DONOTPRINT;
        objBlIn_BillCalcResponseBillObj.AnnualBill = ANNUALBILL;
        objBlIn_BillCalcResponseBillObj.BillServiceTypes = lstBlIn_BillCalcResponseBillServiceTypeObject;
        List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillObj>lstBlIn_BillCalcResponseBillObj = new List<BlIn_BillCalcResponseContainer.BlIn_BillCalcResponseBillObj>();
        lstBlIn_BillCalcResponseBillObj.add(objBlIn_BillCalcResponseBillObj);
        BlIn_BillCalcResponseContainer objBlIn_BillCalcResponseContainer = new BlIn_BillCalcResponseContainer();
        objBlIn_BillCalcResponseContainer.Status = Label.BlIn_BillCalculationStatusCompleted; 
        objBlIn_BillCalcResponseContainer.Bills = lstBlIn_BillCalcResponseBillObj;
        objBlIn_BillCalcResponseContainer.Amendments = lstBlIn_BillCalcResponseBillItemAmendmentObject;
        String jsonStr = JSON.serialize(objBlIn_BillCalcResponseContainer);
        return jsonStr;
    }
    
    /*******************************************************************
Purpose: Method to test JSON response Parsing {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/   
    static testmethod void parseJSONString_Negative(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation = [select id from BillCalculation__c limit 1]; 
        boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                BlIn_BillCalcResponseContainer objBlIn_BillCalcResponseContainer1 = BlIn_BillCalcResponseContainer.parse(null);
                List<Id> responseIds = BlIn_BillCalcResponseContainer.processResult(objBillCalculation.Id,objBlIn_BillCalcResponseContainer1);
            }
            Catch(Exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
        }
    }
    
    /*******************************************************************
Purpose: Method to test JSON response Parsing {Positive scenario2}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void parseJSONString_Positive2(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation = [select id from BillCalculation__c limit 1]; 
        String jsonStr = herokuManualResponseCreationScenario(NULL,FINALBILLFALSE);
        System.runAs(objUser){
            Test.startTest();
            BlIn_BillCalcResponseContainer objBlIn_BillCalcResponseContainer1 = BlIn_BillCalcResponseContainer.parse(jsonStr);
            List<Id> responseIds = BlIn_BillCalcResponseContainer.processResult(objBillCalculation.Id,objBlIn_BillCalcResponseContainer1);
            Test.stopTest();
            Integer count = [select count() from Bill__c where Id In:responseIds];
            system.assertEquals(responseIds.size(),count);
            system.assert(responseIds!=null);
        }
    }

     /*******************************************************************
Purpose: Method to test JSON response Parsing {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void parse_Positive(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        String jsonStr = herokuManualResponseCreationScenario(BILLDATE,FINALBILLFALSE);
        System.runAs(objUser){
            Test.startTest();
            BlIn_BillCalcResponseContainer objBlIn_BillCalcResponseContainer1 = BlIn_BillCalcResponseContainer.parse(jsonStr);
            Test.stopTest();
            system.assert(objBlIn_BillCalcResponseContainer1!=null);
        }
    }

    /*******************************************************************
Purpose: Method to test JSON response Parsing {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void parse_Negative(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                BlIn_BillCalcResponseContainer objBlIn_BillCalcResponseContainer1 = BlIn_BillCalcResponseContainer.parse(null);
            }
            Catch(Exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException,true);
        }
    }
}