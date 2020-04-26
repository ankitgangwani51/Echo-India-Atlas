/******************************************************************************
@author         Echo: Mohit Tayal
@date           27 July 2018
@description    Test class for LoAp_ChangeBundleCtrlr
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class LoAp_ChangeBundleCtrlr_Test {
    
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String CONTRACT_NAME_SECOND ='TestContract2';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES1 ='TestAvailableService1';
    private static final String AVAILABLESERVICES2 ='TestAvailableService2';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String BUNDLE ='TestBundle';
    private static final String BUNDLECHANGE ='TestBundleChange';
    private static final String BUNDLESAMESUPPLYPOINT ='TestBundleSameSupplyPoint';
    private static final String BUNDLECHANGESOCIAL ='TestBundleChangeSocial';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final Integer LIMIT1 =1;
    private static final String TESTNAME ='test';
    private static final String TESTAMOUNT ='100';
    private static final String TESTID ='1';
    private static final String BILLDATE = string.valueOf(System.Today());
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final Date START_DATE 		 	 	= date.valueOf('2018-02-01');
    private static final Date END_DATE 		 			= date.valueOf('2019-02-28');
    
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
            ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
            Database.insert(objServiceType);
            Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
            Database.insert(objReading);
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
            
            Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
            Database.insert(objDivision);
            Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
            Database.insert(objWholesaler);
            List<AvailableService__c> lstAvailableService = new List<AvailableService__c>();
            AvailableService__c  objAvailableService1 = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES1 ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
            lstAvailableService.add(objAvailableService1);
            AvailableService__c  objAvailableService2 = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES2 ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
            lstAvailableService.add(objAvailableService2);
            Database.insert(lstAvailableService);
            Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService1);
            Database.insert(objService);
            ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
            Database.insert(objServiceItemFamily);
            ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
            Database.insert(objServiceItemType);
            List<Bundle__c> lstBundle = new List<Bundle__c>();
            Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
            Bundle__c objChangeBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLECHANGE,objServiceType);
            Bundle__c objSameSupplyPointBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLESAMESUPPLYPOINT,objServiceType);
            Bundle__c objChangeBundlesocial = GlUt_FactoryData_Test.CreateBundle(BUNDLECHANGESOCIAL,objServiceType);
            objChangeBundlesocial.TariffLimit__c = True; // AT-3280
            lstBundle.add(objBundle);
            lstBundle.add(objChangeBundle);
            lstBundle.add(objSameSupplyPointBundle);
            lstBundle.add(objChangeBundlesocial);
            Database.insert(lstBundle);
            List<AvailableBundle__c> lstAvailableBundle = new List<AvailableBundle__c>();
            for(Bundle__c bundleObj : lstBundle){
                if(bundleObj.Name != BUNDLECHANGESOCIAL && bundleObj.Name != BUNDLECHANGE){
                    AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,bundleObj,objAvailableService1);
                    lstAvailableBundle.add(objAvailableBundle);
                }
            }
            Database.insert(lstAvailableBundle);
            BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
            Database.insert(objBundleItem);
            AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,lstAvailableBundle[0]);
            Database.insert(objAvailableServiceItem); 
            ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
            Database.insert(objServiceItem);
        }
    }
    
   /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           27 July 2018
    @description    positive test scenario for retrieveRecords method
    *******************************************************************************/ 
    static testmethod void retrieveRecords_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME LIMIT 1];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id LIMIT 1];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = [SELECT Id FROM AvailableBundle__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        System.runAs(objUser){
            AvailableBundle__c objAvailableBundle2 = new AvailableBundle__c();
            Test.startTest();
            objAvailableBundle2 = LoAp_ChangeBundleCtrlr.retrieveRecords(objAvailableBundle.Id);
            Test.stopTest();
            System.assert(objAvailableBundle2 != Null);
        }
    }
   /******************************************************************************
    @author         Echo: Dependra Singh
    @date           10 September 2018
    @description    negative test scenario for retrieve records method
    *******************************************************************************/ 
    static testmethod void retrieveRecords_NegativeExpection(){
        Boolean isException;
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME LIMIT 1];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id LIMIT 1];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = [SELECT Id FROM AvailableBundle__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        LoAp_ChangeBundleCtrlr.lstAvailableServiceFields = null;
        GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME='abc';
        System.runAs(objUser){
            
            try{
                AvailableBundle__c objAvailableBundle2 = new AvailableBundle__c();
                Test.startTest();
                objAvailableBundle2 = LoAp_ChangeBundleCtrlr.retrieveRecords(objAvailableBundle.Id);
                Test.stopTest();
            }
            catch(Exception e){
                isException = true;
                System.assertNotEquals(e.getMessage(),null);
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           27 July 2018
    @description    negative test scenario for retrieveRecords method
    *******************************************************************************/ 
    static testmethod void retrieveRecords_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            AvailableBundle__c objAvailableBundle = new AvailableBundle__c();
            Test.startTest();
            objAvailableBundle = LoAp_ChangeBundleCtrlr.retrieveRecords(null);
            Test.stopTest();
            System.assert(objAvailableBundle == Null);
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           27 July 2018
    @description    negative test scenario for retrieveContractIds method
    *******************************************************************************/ 
    static testmethod void retrieveFieldProps_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            List<List<GlAp_FieldProps>> lstFieldProps = new List<List<GlAp_FieldProps>>();
            Test.startTest();
            lstFieldProps = LoAp_ChangeBundleCtrlr.retrieveFieldProps();
            Test.stopTest();
              system.debug('lstFieldProps====='+lstFieldProps);
            System.assert(!lstFieldProps.isEmpty());
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           10 September 2018
    @description    negative test scenario for retrieveFieldProps method
    *******************************************************************************/ 
    static testmethod void retrieveFieldProps_Negative(){
        Boolean isException;
        LoAp_ChangeBundleCtrlr.lstAvailableServiceFields = null;
        GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME='abc';
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            try{
                Test.startTest();
                List<List<GlAp_FieldProps>> lstFieldProps = LoAp_ChangeBundleCtrlr.retrieveFieldProps();
                Test.stopTest();
            }
            catch(Exception e){
                isException = true;
                System.assertNotEquals(e.getMessage(),null);
            }
        }
    } 
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           27 July 2018
    @description    positive test scenario for saveRecords method
    *******************************************************************************/ 
    static testmethod void saveRecords_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME LIMIT 1];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id LIMIT 1];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = [SELECT Id, Default__c FROM AvailableBundle__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        ServiceType__c objServiceType = [SELECT Id FROM ServiceType__c WHERE Name =:TEST_SERVICE_TYPE LIMIT 1];
        List<Bundle__c> lstBundle = [SELECT Id, Name FROM Bundle__c WHERE ServiceType__c = :objServiceType.Id];
        Bundle__c objBundleChangeSocial = new Bundle__c();
        Bundle__c objBundleSameSupplyPoint = new Bundle__c();
        Bundle__c objChangeBundle = new Bundle__c();
        for(Bundle__c objBundle : lstBundle){
            if(objBundle.Name == BUNDLECHANGESOCIAL)
                objBundleChangeSocial = objBundle;
            if(objBundle.Name == BUNDLESAMESUPPLYPOINT)
                objBundleSameSupplyPoint = objBundle;
            if(objBundle.Name == BUNDLECHANGE)
                objChangeBundle = objBundle;
        }
        system.debug('');
        System.runAs(objUser){
            Test.startTest();
            try{
                objAvailableBundle.Default__c = True;
                objAvailableBundle.Bundle__c = objBundleChangeSocial.Id;
                LoAp_ChangeBundleCtrlr.saveRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, objSupplyPoint.Id, JSON.serialize(objAvailableBundle));
            }
            catch(exception e){
                system.debug('error');
            }
            
            try{
                objAvailableBundle.Bundle__c = objBundleSameSupplyPoint.Id;
                LoAp_ChangeBundleCtrlr.saveRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, objSupplyPoint.Id, JSON.serialize(objAvailableBundle));
            }
            catch(exception e){
                system.debug('error');
            }
            
            try{
                objAvailableBundle.Bundle__c = objChangeBundle.Id;
                LoAp_ChangeBundleCtrlr.saveRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, objSupplyPoint.Id, JSON.serialize(objAvailableBundle));
            }
            catch(exception e){
                system.debug('error');
                System.assertNotEquals(e.getMessage(),null);
            }
            Test.stopTest();
            /*AvailableBundle__c objAvailableBundle2 = [SELECT Id FROM AvailableBundle__c WHERE Bundle__c = :objBundle.Id LIMIT 1];
            System.assert(objAvailableBundle2 != Null);*/
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date            10 September 2018
    @description    Negative Test scenario for saveRecords method
    *******************************************************************************/ 
    static testmethod void saveRecords_Negative(){
        Boolean isException;
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME='abc';
        System.runAs(objUser){
            try{
                Test.startTest();
                LoAp_ChangeBundleCtrlr.saveRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME,'sss','sssss');
                Test.stopTest();
            }
            catch(Exception e){
                isException = true;
                System.assertNotEquals(e.getMessage(),null);
            }
        }
    }
}