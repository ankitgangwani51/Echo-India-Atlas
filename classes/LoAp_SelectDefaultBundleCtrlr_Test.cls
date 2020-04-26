/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        12 Feb 2018
@description: Test Class for LoAp_SelectDefaultBundleCtrlr 
*******************************************************************************/

@isTest
public class LoAp_SelectDefaultBundleCtrlr_Test {

    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static final String DEVICE_NAME         = 'TestDevice';
    private static final String DEVICE_TYPE         = 'TestDeviceType';
    private static final String TEST_SERVICE_TYPE   = 'TestServiceType';
    private static final String LOCATION_NAME       = 'A99 9AA';
    private static final String YES                 = 'yes';
    private static final String MEASURED            = 'Monthly';
    private static final String WHOLESALER          = 'TestWholesaler';
    private static final String AVAILABLESERVICES   = 'TestAvailableService';
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';
    private static final String BUNDLE1             = 'TestBundle1';
    private static final String BUNDLE2             = 'TestBundle2';
    private static final String BUNDLEITEM1         = 'TestBundleItem1';  
    private static final String BUNDLEITEM2         = 'TestBundleItem2';
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    private static final String MANUFACTURER 		= 'Kent';
    private static final String DEVICE_SIZE 		= 'TestDeviceSize';
    private static final String MANUFACTURER1		= 'Siemens';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String AVAILABLEBUNDLE 	= 'AB-00049267';
    
	/*******************************************************************
	@author:      Echo: Mohit Tayal
	@date:        12 Feb 2018
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
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER1,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        objAvailableService.Active__c = TRUE;
        Database.insert(objAvailableService);
        
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle1 = GlUt_FactoryData_Test.createBundle(BUNDLE1,objServiceType);
        Database.insert(objBundle1);
        
        Bundle__c objBundle2 = GlUt_FactoryData_Test.createBundle(BUNDLE2,objServiceType);
        Database.insert(objBundle2);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE ,objBundle1,objAvailableService);
        objAvailableBundle.Default__c = TRUE;
        Database.insert(objAvailableBundle);
        
        BundleItem__c objBundleItem1 = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM1,objBundle1,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem1);   
        
        BundleItem__c objBundleItem2 = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM2,objBundle1,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem2);
    }
 
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 Feb 2018
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method RetrievebundleFieldPropDetails
    ********************************************************************/
    static testmethod void RetrievebundleFieldPropDetails_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];   
        System.runAs(objUser){
            Test.startTest();
            List<GLAp_FieldProps> fldPropList = LoAp_SelectDefaultBundleCtrlr.retrievebundleFieldPropDetails();
            Test.stopTest();            
            System.assert(fldPropList.size() > 0);
        }
    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 Feb 2018
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method retrievebundleRecords
    ********************************************************************/ 
    static testmethod void RetrievebundleRecords_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];   
        List<Location__c> locationList = [SELECT Id FROM Location__c WHERE PostalCode__c =: LOCATION_NAME LIMIT 1];
        List<SupplyPoint__c> supplyPointList = [SELECT Id FROM SupplyPoint__c WHERE Location__c =: locationList.get(0).Id LIMIT 1];
        List<DeviceSize__c> deviceSizeList = [SELECT Id FROM DeviceSize__c WHERE Name = :DEVICE_SIZE LIMIT 1];
        List<DeviceType__c> deviceTypeList = [SELECT Id FROM DeviceType__c WHERE DeviceSize__c = :deviceSizeList.get(0).Id AND Manufacturer__c = :MANUFACTURER1 LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE DeviceType__c = :deviceTypeList.get(0).Id];
        System.runAs(objUser){
            Test.startTest();
            Map<Id,List<BlAp_CombinedRecord>> srvcTypIdCmbinRecMap1 = LoAp_SelectDefaultBundleCtrlr.RetrievebundleRecords(supplyPointList.get(0).Id, LoAp_Constants.NEWDEVICE);
            Map<Id,List<BlAp_CombinedRecord>> srvcTypIdCmbinRecMap2 = LoAp_SelectDefaultBundleCtrlr.RetrievebundleRecords(deviceList.get(0).Id, LoAp_Constants.REMOVEDEVICE);
            Test.stopTest(); 
            
            System.assert(srvcTypIdCmbinRecMap1.keySet() != null);
            System.assert(srvcTypIdCmbinRecMap1.values().size() > 0);
            System.assert(srvcTypIdCmbinRecMap2.keySet() != null);
            System.assert(srvcTypIdCmbinRecMap2.values().size() > 0);
        }
    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 Feb 2018
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method retrievebundleRecords
    ********************************************************************/
    static testmethod void RetrievebundleRecords_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];   
        
        SupplyPoint__c objSupplyPoint = new SupplyPoint__c();
        Device__c objDevice = new Device__c();  
        
        System.runAs(objUser){
            Test.startTest();
            Map<Id,List<BlAp_CombinedRecord>> srvcTypIdCmbinRecMap1 = LoAp_SelectDefaultBundleCtrlr.RetrievebundleRecords(objSupplyPoint.Id, LoAp_Constants.NEWDEVICE);
            Map<Id,List<BlAp_CombinedRecord>> srvcTypIdCmbinRecMap2 = LoAp_SelectDefaultBundleCtrlr.RetrievebundleRecords(objDevice.Id, LoAp_Constants.REMOVEDEVICE);
            Test.stopTest();  
            
            System.assert(srvcTypIdCmbinRecMap1.keySet().size() == 0);
            System.assert(srvcTypIdCmbinRecMap1.values().size() == 0);
            System.assert(srvcTypIdCmbinRecMap2.keySet().size() == 0);
            System.assert(srvcTypIdCmbinRecMap2.values().size() == 0);
        }
    }   
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 Feb 2018
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method RetrvAvalbleBndlRecords
    ********************************************************************/
    static testmethod void RetrvAvalbleBndlRecords_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];   
        List<Location__c> locationList = [SELECT Id FROM Location__c WHERE PostalCode__c =: LOCATION_NAME LIMIT 1];
        List<SupplyPoint__c> supplyPointList = [SELECT Id FROM SupplyPoint__c WHERE Location__c =: locationList.get(0).Id LIMIT 1];
        List<DeviceSize__c> deviceSizeList = [SELECT Id FROM DeviceSize__c WHERE Name = :DEVICE_SIZE LIMIT 1];
        List<DeviceType__c> deviceTypeList = [SELECT Id FROM DeviceType__c WHERE DeviceSize__c = :deviceSizeList.get(0).Id AND Manufacturer__c = :MANUFACTURER1 LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE DeviceType__c = :deviceTypeList.get(0).Id];  
        
        System.runAs(objUser){
            Test.startTest();
            Map<Id,AvailableBundle__c> srvcTypIdAvlBndlRecMap1 = LoAp_SelectDefaultBundleCtrlr.RetrvAvalbleBndlRecords(supplyPointList.get(0).Id, LoAp_Constants.NEWDEVICE);
            Map<Id,AvailableBundle__c> srvcTypIdAvlBndlRecMap2 = LoAp_SelectDefaultBundleCtrlr.RetrvAvalbleBndlRecords(deviceList.get(0).Id, LoAp_Constants.REMOVEDEVICE);
            Test.stopTest();  
            
            System.assert(srvcTypIdAvlBndlRecMap1.keySet() != null);
            System.assert(srvcTypIdAvlBndlRecMap1.values().size() > 0);
            System.assert(srvcTypIdAvlBndlRecMap2.keySet() != null);
            System.assert(srvcTypIdAvlBndlRecMap2.values().size() > 0);
        }
    }    
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 Feb 2018
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method RetrvAvalbleBndlRecords
    ********************************************************************/ 
    static testmethod void RetrvAvalbleBndlRecords_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];   
        
        SupplyPoint__c objSupplyPoint = new SupplyPoint__c();
        Device__c objDevice = new Device__c();  
        
        System.runAs(objUser){
            Test.startTest();
            Map<Id,AvailableBundle__c> srvcTypIdAvlBndlRecMap1 = LoAp_SelectDefaultBundleCtrlr.RetrvAvalbleBndlRecords(objSupplyPoint.Id, LoAp_Constants.NEWDEVICE);
            Map<Id,AvailableBundle__c> srvcTypIdAvlBndlRecMap2 = LoAp_SelectDefaultBundleCtrlr.RetrvAvalbleBndlRecords(objDevice.Id, LoAp_Constants.REMOVEDEVICE);
            Test.stopTest();  
            
            System.assert(srvcTypIdAvlBndlRecMap1.keySet().size() == 0);
            System.assert(srvcTypIdAvlBndlRecMap1.values().size() == 0);
            System.assert(srvcTypIdAvlBndlRecMap2.keySet().size() == 0);
            System.assert(srvcTypIdAvlBndlRecMap2.values().size() == 0);
        }
    }
    
     /*******************************************************************
    @author:      ECHO:  Vivek Sethi
    @date:        24 May 2018
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method RetrieveAvailableServiceRecords
    ********************************************************************/
    static testmethod void RetrieveAvailableServiceRecords_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];   
        List<Location__c> locationList = [SELECT Id FROM Location__c WHERE PostalCode__c =: LOCATION_NAME LIMIT 1];
        List<SupplyPoint__c> supplyPointList = [SELECT Id FROM SupplyPoint__c WHERE Location__c =: locationList.get(0).Id LIMIT 1];
        List<DeviceSize__c> deviceSizeList = [SELECT Id FROM DeviceSize__c WHERE Name = :DEVICE_SIZE LIMIT 1];
        List<DeviceType__c> deviceTypeList = [SELECT Id FROM DeviceType__c WHERE DeviceSize__c = :deviceSizeList.get(0).Id AND Manufacturer__c = :MANUFACTURER1 LIMIT 1];
        List<Device__c> deviceList = [SELECT Id FROM Device__c WHERE DeviceType__c = :deviceTypeList.get(0).Id];  
        
        System.runAs(objUser){
            Test.startTest();
            Map<Id,AvailableService__c> serviceTypeIdToAvailServiceMap1 = LoAp_SelectDefaultBundleCtrlr.RetrieveAvailableServiceRecords(supplyPointList.get(0).Id, LoAp_Constants.NEWDEVICE);
            Map<Id,AvailableService__c> serviceTypeIdToAvailServiceMap2 = LoAp_SelectDefaultBundleCtrlr.RetrieveAvailableServiceRecords(deviceList.get(0).Id, LoAp_Constants.REMOVEDEVICE);
            Test.stopTest();  
            
            System.assert(serviceTypeIdToAvailServiceMap1.keySet() != null);
            System.assert(serviceTypeIdToAvailServiceMap1.values().size() > 0);
            System.assert(serviceTypeIdToAvailServiceMap2.keySet() != null);
            System.assert(serviceTypeIdToAvailServiceMap2.values().size() > 0);
        }
    } 
     /*******************************************************************
    @author:      ECHO:  Vivek Sethi
    @date:        24 May 2018
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method RetrieveAvailableServiceRecords
    ********************************************************************/ 
    static testmethod void RetrieveAvailableServiceRecords_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];   
        
        SupplyPoint__c objSupplyPoint = new SupplyPoint__c();
        Device__c objDevice = new Device__c();  
        
        System.runAs(objUser){
            Test.startTest();
            Map<Id,AvailableService__c> serviceTypeIdToAvailServiceMap1 = LoAp_SelectDefaultBundleCtrlr.RetrieveAvailableServiceRecords(objSupplyPoint.Id, LoAp_Constants.NEWDEVICE);
            Map<Id,AvailableService__c> serviceTypeIdToAvailServiceMap2 = LoAp_SelectDefaultBundleCtrlr.RetrieveAvailableServiceRecords(objDevice.Id, LoAp_Constants.REMOVEDEVICE);
            Test.stopTest();  
            
            System.assert(serviceTypeIdToAvailServiceMap1.keySet().size() == 0);
            System.assert(serviceTypeIdToAvailServiceMap1.values().size() == 0);
            System.assert(serviceTypeIdToAvailServiceMap2.keySet().size() == 0);
            System.assert(serviceTypeIdToAvailServiceMap2.values().size() == 0);
        }
    }
    
}