/******************************************************************************
@author         Echo: Vivek Sethi
@date           30 July 2018
@description    Test class for LoAp_MakeBundleActiveCtrlr
@revision(s)        
*******************************************************************************/
@isTest
public class LoAp_MakeBundleActiveCtrlr_Test {

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
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String BUNDLE ='TestBundle';
    private static final String BUNDLECHANGE ='TestBundleChange';
    private static final String BUNDLECHANGESOCIAL ='TestBundleChangeSocial';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';

    /******************************************************************
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
       
            DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
            Database.insert(objDeviceSize);
            
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
            
            SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
            Database.insert(objSupplyPointUsageType);

            SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
            objSupplyPoint.Measured__c= True; // AT-3174 
  
            Database.insert(objSupplyPoint);
            
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
            
            List<Bundle__c> lstBundle = new List<Bundle__c>();
            Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
            Bundle__c objChangeBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLECHANGE,objServiceType); 
            Bundle__c objChangeBundlesocial = GlUt_FactoryData_Test.CreateBundle(BUNDLECHANGESOCIAL,objServiceType);
            objChangeBundlesocial.TariffLimit__c = True; //AT-3280
            lstBundle.add(objBundle);
            lstBundle.add(objChangeBundle);
            lstBundle.add(objChangeBundlesocial);
            Database.insert(lstBundle);
            
            AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
            objAvailableBundle.LastBundleChangeDate__c = system.today() + 2 ;
            Database.insert(objAvailableBundle);
            
            BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
            Database.insert(objBundleItem);
            
            AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
            Database.insert(objAvailableServiceItem); 
            
            ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
            Database.insert(objServiceItem);
        }
    }
    
   /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           30 July 2018
    @description    positive test scenario for retrieveRecords method
    *******************************************************************************/
    static testmethod void retrieveRecords_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = [SELECT Id FROM AvailableBundle__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            LoAp_MakeBundleActiveCtrlr.resultWrapper recordToDisplay = LoAp_MakeBundleActiveCtrlr.retrieveRecords(objAvailableBundle.Id);//Core 8b
            System.assertNotEquals(recordToDisplay, null); 
            Test.stopTest();
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           30 July 2018
    @description    negative test scenario for retrieveRecords method
    *******************************************************************************/
    static testmethod void retrieveRecords_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        Boolean isException = false;
        System.runAs(objUser){
            AvailableBundle__c objAvailableBundle = new AvailableBundle__c();
            try{
                Test.startTest();
                LoAp_MakeBundleActiveCtrlr.resultWrapper recordToDisplay = LoAp_MakeBundleActiveCtrlr.retrieveRecords(null);//Core 8b
                System.assertNotEquals(recordToDisplay, null);
            }
            catch(exception e){
                isException = true;
            }
            System.assertEquals(isException, true);
            Test.stopTest();
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           30 July 2018
    @description    negative test scenario for retrieveContractIds method
    *******************************************************************************/ 
    static testmethod void retrieveFieldProps_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        System.runAs(objUser){
            List<List<GlAp_FieldProps>> lstFieldProps = new List<List<GlAp_FieldProps>>();
            Test.startTest();
            lstFieldProps = LoAp_MakeBundleActiveCtrlr.retrieveFieldProps();
            System.assertNotEquals(lstFieldProps, null);
            Test.stopTest();
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           30 July 2018
    @description    positive test scenario for saveRecords method
    *******************************************************************************/ 
    static testmethod void saveRecords_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = [SELECT Id, LastBundleChangeDate__c, Default__c FROM AvailableBundle__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        Bundle__c objBundlechangesocial = [SELECT Id FROM Bundle__c WHERE Name = :BUNDLECHANGESOCIAL LIMIT 1];
        Bundle__c objBundle = [SELECT Id FROM Bundle__c WHERE Name = :BUNDLECHANGE LIMIT 1];
        Boolean isException = false;
        System.runAs(objUser){
            Test.startTest();
            try{
                system.debug('JSON.serialize(objAvailableBundle) = ' + JSON.serialize(objAvailableBundle));
                LoAp_MakeBundleActiveCtrlr.saveRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, JSON.serialize(objAvailableBundle));
            }
             catch(exception e){
               system.debug('saveRecords_Positive-e= ' + e.getMessage());
               system.debug('saveRecords_Positive-e2= ' + e.getStackTraceString());
               isException = true;
            }
            System.assertEquals(false, isException);
            Test.stopTest();
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           30 July 2018
    @description    positive test scenario for saveRecords method
    *******************************************************************************/ 
    static testmethod void saveRecords_Negative(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE limit 1];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = new AvailableBundle__c() ;
        Bundle__c objBundlechangesocial = [SELECT Id FROM Bundle__c WHERE Name = :BUNDLECHANGESOCIAL LIMIT 1];
        Bundle__c objBundle = [SELECT Id FROM Bundle__c WHERE Name = :BUNDLECHANGE LIMIT 1];
        Boolean isException = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                LoAp_MakeBundleActiveCtrlr.saveRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, JSON.serialize(objAvailableBundle));
            }
            catch(exception e){
               isException = true;
            }
            System.assertEquals(true, isException);
            Test.stopTest();
        }
    }
    
}