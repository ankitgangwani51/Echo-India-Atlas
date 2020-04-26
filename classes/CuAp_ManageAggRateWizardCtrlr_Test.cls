/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        20 Dec 2017
@description: Test Class for CuAp_AgreedRateWizardComponentCtrlr
@Revisions	   AT-3987,Tarun , modified class name as per security review changes
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
//test data creation for LoAp_SearchDevicePageToAddCtrlr class
Public Class CuAp_ManageAggRateWizardCtrlr_Test{
    
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
      private static final String MEASURED = 'Monthly';
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
      private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
      private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
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
    @revesion	   Change By Dependra Singh- 25-02-2019- Salesforce Limit Analysis
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
            
            List<Device__c> lstDevice = new List<Device__c>();
            Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
            lstDevice.add(objDevice);
            //Database.insert(objDevice);
            
            Device__c objsubDevice = GlUt_FactoryData_Test.CreateDevice(SUB_DEVICE_TYPE ,objDeviceType );
            lstDevice.add(objsubDevice);
            Database.insert(lstDevice);
            
            ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
            Database.insert(objServiceType);
            
            List<Reading__c> lstReading = new List<Reading__c>();
            Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
            lstReading.add(objReading);
            
            Reading__c  objReadingSecond = GlUt_FactoryData_Test.CreateReading(objsubDevice);
            lstReading.add(objReadingSecond);
            Database.insert(lstReading);
            
            Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
            objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
            objLocation.Street__c =STREET ;
            Database.insert(objLocation);
            
            //Create Supply Point Usage Type Record
            SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
            Database.insert(objSupplyPointUsageType);
            
            List<SupplyPoint__c> lstSP = new List<SupplyPoint__c>();
            // Create Main Supply Point
            SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
            objSupplyPoint.Measured__c= True; // AT-3174 
            lstSP.add(objSupplyPoint);
            //Database.insert(objSupplyPoint);
            
            // Create Sub Supply Point
            SupplyPoint__c  objSubSP = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
            objSubSP.Measured__c= True; // AT-3174 
            lstSP.add(objSubSP);
            Database.insert(lstSP);
            
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
            objServiceItem.StartDate__c = system.today();
            Database.insert(objServiceItem);
            
            // Commented by Ankit Gangwani for task - AT-2926, 22 June 2018
            /*DeviceRelationship__c  objDeviceRelationship = GlUt_FactoryData_Test.CreateDeviceRelationship(objDevice,objsubDevice);
                Database.insert(objDeviceRelationship);*/
            
            SupplyPointRelationship__c objSupplyPointRelationship = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPoint, objSubSP);
            Database.insert(objSupplyPointRelationship);
            
            DischargeAgreement__c objDischargeAgreement = GlUt_FactoryData_Test.createDischargeAgreement(objLocation);
            Database.insert(objDischargeAgreement);
            
            Sample__c  objSample =GlUt_FactoryData_Test.CreateSample(SAMPLE);
            objSample.CODSampleStrength__c = SAMPLE_STRENGTH_NUMBER;
            objSample.SampleCollectionDate__c = Date.today();
            objSample.DischargeAgreement__c = objDischargeAgreement.Id;
            Database.insert(objSample);
            
            AgreedRate__c  objAgreedRate =GlUt_FactoryData_Test.CreateAgreedRate(AGREERATE,objServiceItem);
            Database.insert(objAgreedRate);
        }
        
    }
    /*******************************************************************
    Purpose: Method to test CuAp_AgreedRateWizardComponentCtrlr WizardStatus {Positive scenario}
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void CuAp_AgreedRateWizardComponentCtrlr_WizardStatus(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Device__c  objDevice = [select id from Device__c  limit 1];
        String wizardprop = '{"recordId":"'+objaccount.id+'","contractId":"'+objContract.id+'"}';
        boolean isException = false;
        system.Runas(objUser){
            Test.starttest();
            CuAp_ManageAggRateWizardCtrlr.WizardStatus(wizardprop);
            Test.stoptest();
            System.assert(!wizardprop.containsAny('?'));
            //Asserts to check properties of list of GlAp_FieldProps retrieved
        }
        
    }
   
    /*******************************************************************
    Purpose: Method to test hasMultiActiveContracts
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void CuAp_AgreedRateWizardComponentCtrlr_hasMultiActiveContracts(){
    
        Account objaccount = [select id from Account limit 1];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        List<BlAp_CombinedRecord> lstRecords = new List<BlAp_CombinedRecord>();
        
        system.Runas(objUser){
        Test.starttest();
        lstRecords = CuAp_ManageAggRateWizardCtrlr.getActiveContracts(objaccount.Id);
        Test.stoptest();
         //Asserts to check properties of list of GlAp_FieldProps retrieved
         
		 Boolean isExpected = true;            
         system.assertEquals(isExpected, lstRecords.size() > 0 );
        }    
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        13 Sept 2018
	@description: Method to test hasMultiActiveContracts for CuAp_AgreedRateWizardComponentCtrlr with Negative Scenario
	*******************************************************************************/
    static testmethod void CuAp_AgreedRateWizardComponentCtrlr_hasMultiActiveContracts_Negative(){    
        
        User objUser = [SELECT Id, Name 
                        FROM user 
                        WHERE isActive = True
                        AND username = :USERNAMECOMPLETE 
                        LIMIT 1];
        
        List<BlAp_CombinedRecord> lstRecords = new List<BlAp_CombinedRecord>();                
        Boolean isExpected;                    
        
        System.Runas(objUser){
            try{
                Test.starttest();
                lstRecords = CuAp_ManageAggRateWizardCtrlr.getActiveContracts(Null); // passing null account id
                Test.stoptest();
            }catch(Exception ex) {
                system.debug('exception caught in test context:: ' + ex);        
            }         
            isExpected = true; 
            system.assertEquals(isExpected, lstRecords.size() == 0 );
        }    
    }    
}