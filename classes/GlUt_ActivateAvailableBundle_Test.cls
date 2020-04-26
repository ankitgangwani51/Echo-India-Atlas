/******************************************************************************
@author         Echo: Mohit Tayal
@date           31 July 2018
@description    Test class for GlUt_ActivateAvailableBundle
@revision(s)        
*******************************************************************************/
@isTest
public class GlUt_ActivateAvailableBundle_Test {

    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
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
    private static final String AVAILABLEBUNDLE1 ='TestAvailableBundle1';
    private static final String AVAILABLEBUNDLE2 ='TestAvailableBundle2';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String TARIFFLIMITSTATUS = 'Approved';
    private static final String GROUPTYPENAME = 'TariffLimit';
    private static final String GROUPTYPESELECTIONOPTION = 'Highest';
    
    
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
            Database.insert(objContract);
            
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
            
            List<Service__c> lstService = new List<Service__c>();
            Service__c  objService1 = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService1);
            lstService.add(objService1);
            Service__c  objService2 = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService1);
            lstService.add(objService2);
            Database.insert(lstService);
            
            ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
            Database.insert(objServiceItemFamily);
            ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
            Database.insert(objServiceItemType);
            
            ServiceItemType__c  objServiceItemType2 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
            Database.insert(objServiceItemType2);
            
            Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
            objBundle.TariffLimit__c= true;
            Database.insert(objBundle);
            
            List<AvailableBundle__c> lstAvailableBundle = new List<AvailableBundle__c>();
            AvailableBundle__c  objAvailableBundle1 = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE1,objBundle,objAvailableService1);
            lstAvailableBundle.add(objAvailableBundle1);
            AvailableBundle__c  objAvailableBundle2 = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE2,objBundle,objAvailableService2);
            lstAvailableBundle.add(objAvailableBundle2);
            Database.insert(lstAvailableBundle);
            
            BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
           
            Database.insert(objBundleItem);
            
            List<AvailableServiceItem__c> lstAvailableServiceItem = new List<AvailableServiceItem__c>();
            AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle1);
            objAvailableServiceItem1.ServiceItemType__c = objServiceItemType.Id;
            lstAvailableServiceItem.add(objAvailableServiceItem1); 
            AvailableServiceItem__c  objAvailableServiceItem2 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle1);
            objAvailableServiceItem2.ServiceItemType__c = objServiceItemType.Id;
            lstAvailableServiceItem.add(objAvailableServiceItem2);
            Database.insert(lstAvailableServiceItem);
            
            List<ServiceItem__c> lstServiceItem = new List<ServiceItem__c>();
            ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem1,objServiceItemType,objService1);
            objServiceItem1.StartDate__c = system.today() - 20;
            lstServiceItem.add(objServiceItem1);
            ServiceItem__c  objServiceItem2 = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem2,objServiceItemType2,objService2);
            objServiceItem2.StartDate__c = system.today() - 20;
            lstServiceItem.add(objServiceItem2);
            Database.insert(lstServiceItem);
            
            TariffLimit__c objTariffLimit = GlUt_FactoryData_Test.createTariffLimit(objAccount,TARIFFLIMITSTATUS,system.today(),null);
            insert objTariffLimit;
            GroupType__c objGroupType = GlUt_FactoryData_Test.createGroupType(GROUPTYPENAME,1,GROUPTYPESELECTIONOPTION);
            insert objGroupType;
            Group__c objGroup  =GlUt_FactoryData_Test.createGroup(objTariffLimit,objGroupType);
            insert objGroup;
            GroupItem__c objGroupItem  = GlUt_FactoryData_Test.createGroupItem(objGroup,lstServiceItem[0]); 
            insert objGroupItem;
            
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    positive test scenario for activateAvailableBundle method
    *******************************************************************************/ 
    static testmethod void activateAvailableBundle_Positive(){
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        List<ServiceItem__c> lstServiceItem= [Select Id FROM ServiceItem__c LIMIT 2];
        Location__c  objLocation = [SELECT Id FROM Location__c  WHERE PostalCode__c = :LOCATION_NAME LIMIT 1];
        SupplyPoint__c  objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id LIMIT 1];
        AvailableService__c objAvailableService = [SELECT Id FROM AvailableService__c WHERE SupplyPoint__c = :objSupplyPoint.Id LIMIT 1];
        AvailableBundle__c objAvailableBundle = [SELECT Id, Default__c FROM AvailableBundle__c WHERE AvailableService__c = :objAvailableService.Id LIMIT 1];
        Map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper> mapOfAvailableBundleIdToWrapper = new Map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper>();
        GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper();
        objWrapper.availableBundle = objAvailableBundle;
        objWrapper.effectiveDate = System.today();
        mapOfAvailableBundleIdToWrapper.put(objAvailableBundle.Id,objWrapper);
        System.runAs(objUser){
            Test.startTest();
            GlUt_ActivateAvailableBundle.activateAvailableBundle(mapOfAvailableBundleIdToWrapper);
            Test.stopTest();
            List<ServiceItem__c> lstServiceItem1 =[Select Id From ServiceItem__c WHERE ID IN : lstServiceItem];
            System.debug('lcstServiceItem1 = '+lstServiceItem1);
            System.assert(lstServiceItem1.size() > 0);
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 July 2018
    @description    negative test scenario for activateAvailableBundle method
    *******************************************************************************/ 
    static testmethod void activateAvailableBundle_Negative(){
        List<ServiceItem__c> lstServiceItem= [Select Id FROM ServiceItem__c LIMIT 2];
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper> mapOfAvailableBundleIdToWrapper = new Map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper>();
        GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper();
        objWrapper.availableBundle = null;
        objWrapper.effectiveDate = null;
        mapOfAvailableBundleIdToWrapper.put(objUser.Id,objWrapper);
        System.runAs(objUser){
            Test.startTest();
            try{
                GlUt_ActivateAvailableBundle.activateAvailableBundle(mapOfAvailableBundleIdToWrapper);
            }
            catch(Exception e){
                System.debug('Error : ' +e.getMessage());
            }
            List<ServiceItem__c> lstServiceItem1 =[Select Id From ServiceItem__c WHERE ID NOT IN : lstServiceItem];
            System.assert(lstServiceItem1.isEmpty());
            Test.stopTest();
        }
    }
}