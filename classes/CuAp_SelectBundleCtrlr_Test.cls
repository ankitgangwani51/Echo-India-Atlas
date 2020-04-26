/******************************************************************************
@author:      Echo: Satish Nair
@date:        01 Dec 2017
@description: Test Class for CuAp_SelectBundleCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
Private class CuAp_SelectBundleCtrlr_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='BundleLN123'; 
    private static final String USER_FNAME= 'BundleFN123';
    private static final String USER_LNAME= 'BundleLN123';
    private static String TEST_SERVICE_TYPE ='TestServiceType';   
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String BUNDLENAME ='TestBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String USERNAMECOMPLETE = USER_NAME+ '@unitest.com'; 
    private static String DEVICETYPE ='TestDeviceType';
    private static String SERVICEITEMTYPE = 'TestSrvItemType';  
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';  
    private static String ACCOUNTNAME = 'TestAccount'; 
    private static String DEVICENAME = 'TestDevice';  
    private static String BUNDLENAMENEW ='TestBundleNew';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    /******************************************************************************
    @author:      Echo: Satish Nair
    @date:        01 Dec 2017
    @description: Test setup method
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
         //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        Database.insert(objContract);

        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        //objSupplyPoint.Measured__c=YES ;
        Database.insert(objSupplyPoint);

        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create device record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);

        //Create reading record
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        Database.insert(objServiceType);

        //Create service item family record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);

        //Create service record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);

         //Create service item type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        objServiceItemType.StartDate__c = Date.Today();
        objServiceItemType.AvailableToSelectInWizard__c = True;
        Database.insert(objServiceItemType);

        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);

        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
      
        // Create new Bundle
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAMENEW,objServiceType);
        Database.insert(objBundle1);
        
        //Create Default Available Bundle
        AvailableBundle__c objDefAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAMENEW,objBundle1,objAvailableService);
        objDefAvailableBundle.Default__c = True;
        Database.insert(objDefAvailableBundle);

         //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem);


    }
    
    /*****************************************************************************
@author:      Satish Nair
@date:        06 December 2017
@description: Test method for retrieveSerBundlesFieldPropDetails() method
*******************************************************************************/
    static testmethod void retrieveSerBundlesFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp = CuAp_SelectBundleCtrlr.retrieveSerBundlesFieldPropDetails();
            Test.stopTest();
            
            System.assert(lstFieldProp.size()>0);
            System.assertEquals(lstFieldProp[0].isEditable,false);
            System.assertEquals(lstFieldProp[0].fieldType,'text');
            System.assertEquals(lstFieldProp[1].isEditable,false);
            System.assertEquals(lstFieldProp[1].fieldType,'text');
            System.assertEquals(lstFieldProp[2].isEditable,false);
            System.assertEquals(lstFieldProp[2].fieldType,'text');
            System.assertEquals(lstFieldProp[3].isEditable,false);
            System.assertEquals(lstFieldProp[3].fieldType,'text'); 
        }
    }

   
/******************************************************************************
@author:      Satish Nair
@date:        06 December 2017
@description: Test method for retrieveServiceBundles() method. This is for 
              positive scenario when there are Available 
              Bundles and associated available Service items associated to the selected
              Available Service.
*******************************************************************************/
    static testmethod void retrieveServiceBundles_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        List<String> avblSrv = new List<String>();
        List<String> suppPoint = new List<String>();
        //Query account record
        
        for(AvailableService__c avlSrv : [Select id,Name,ServiceType__c from AvailableService__c where ServiceType__r.Name =: TEST_SERVICE_TYPE]){
            avblSrv.add(avlSrv.Id);
        }

        for(SupplyPoint__c suppRec : [Select id,(Select id from AvailableServices__r where id in:avblSrv) from SupplyPoint__c]){
            suppPoint.add(suppRec.Id);
        }
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRec = CuAp_SelectBundleCtrlr.retrieveServiceBundles(suppPoint,avblSrv);
            Test.stopTest();
            System.assert(lstCombinedRec.size()>0);
        }
    }


    /******************************************************************************
    @author:      Satish Nair
    @date:        06 December 2017
    @description: Test method for retrieveServiceBundles() method. This is for 
            negative scenario when there are no default bundles are associated to the
            Available Service.
    *******************************************************************************/
    static testmethod void retrieveServiceBundles_Negative(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Query Available Service
        List<String> avblSrv = new List<String>();
        List<String> suppPoint = new List<String>();

        List<AvailableService__c> avlSrvList = [Select id,Name,ServiceType__c from AvailableService__c where 
        ServiceType__r.Name =: TEST_SERVICE_TYPE];
        for(AvailableService__c avlSrv : avlSrvList){
            avblSrv.add(avlSrv.Id);
        }

        List<SupplyPoint__c> supplyPtList = [Select id,(Select id from AvailableServices__r where id in:avlSrvList) from SupplyPoint__c];
        for(SupplyPoint__c suppRec : supplyPtList){
            suppPoint.add(suppRec.Id);
        }

        List<AvailableBundle__c> avlBundleList = [Select id,Bundle__c,AvailableService__c from AvailableBundle__c where 
        AvailableService__c in: avlSrvList];

        
        //Delete Available Bundles related to Available Service in order to test negative scenario
        delete avlBundleList;
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRec = CuAp_SelectBundleCtrlr.retrieveServiceBundles(suppPoint,avblSrv);
            Test.stopTest();
            
            System.assertEquals(lstCombinedRec.size(),0);
        }
    } 

    /******************************************************************************
    @author:      Satish Nair
    @date:        19 December 2017
    @description: Test method for retrieveSundryServices() method. This is for 
                  positive scenario when there are Service Item Type available as Sundry
    *******************************************************************************/
    static testmethod void retrieveSundryServices_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        List<ServiceItemType__c> srvItmType = [Select id,Name,AvailableToSelectInWizard__c,StartDate__c from ServiceItemType__c where AvailableToSelectInWizard__c=True];

        //Run test class in user context
        system.runas(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombRec = CuAp_SelectBundleCtrlr.retrieveSundryServices();
            Test.stopTest();
            System.assert(lstCombRec.size() > 0);
        }
    }
    
    /******************************************************************************
    @author:      Satish Nair
    @date:        19 December 2017
    @description: Test method for retrieveSundryServices() method. This is for 
    negative scenario when there are no Service Item Type available as Sundry
    *******************************************************************************/
    static testmethod void retrieveSundryServices_Negative(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        List<ServiceItemType__c> srvItmType = [Select id,Name,AvailableToSelectInWizard__c,StartDate__c from ServiceItemType__c where AvailableToSelectInWizard__c=True];

        List<ServiceItem__c> serviceItemLists = [SELECT Id FROM ServiceItem__c];
        Database.DeleteResult[] DR_Del1 = Database.delete(serviceItemLists);
        Database.DeleteResult[] DR_Dels = Database.delete(srvItmType);

        //Delete srvItmType;
        //Run test class in user context
        system.runas(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombRec = CuAp_SelectBundleCtrlr.retrieveSundryServices();
            Test.stopTest();
            System.assert(lstCombRec.size() == 0);
        }
    } 

    /******************************************************************************
    @author:      Satish Nair
    @date:        06 December 2017
    @description: Test method for retrieveSundryFieldPropDetails() method
    *******************************************************************************/
    static testmethod void retrieveSundryFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp = CuAp_SelectBundleCtrlr.retrieveSundryFieldPropDetails();
            Test.stopTest();
            
            System.assert(lstFieldProp.size()>0);
            System.assertEquals(lstFieldProp[0].isEditable,false);
            System.assertEquals(lstFieldProp[0].fieldType,'text');
        
        }
    }
   
      
}