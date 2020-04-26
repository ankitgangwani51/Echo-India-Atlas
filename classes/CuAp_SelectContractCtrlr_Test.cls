/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        23 November 2017
@description: Test Class for CuAp_SelectContractCtrlr
Revision(s):  Shivangi Gaur -- 12-Dec-2017 -- Incorporated review comments provided 
                                                on AT-1181 dated 11-12-2017.
*******************************************************************************/

@isTest
Public Class CuAp_SelectContractCtrlr_Test{
    
    //Variable declaration start
    
    public static String PROFILENAME = 'System Administrator';
    public static String USERNAME = 'TestUser222';
    private static String ACCOUNTNAME = 'TestAccount'; 
    private static String DEVICENAME = 'TestDevice';
    private static String DEVICETYPE ='TestDeviceType';
    private static String SUBDEVICETYPE ='TestSubDevice';
    private static String TESTSERVICETYPE ='TestServiceType';
    private static String LOCATIONNAME ='A99 9AA';
    private static String LOCATIONSUBTYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static String SERVICEITEMTYPE ='TestServiceitemtype';
    private static String BUNDLE ='TestBundle';
    private static String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String moveInDate = String.valueOf(date.today());
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    //Variable declaration end

    /******************************************************************************
    @author:      Accenture: Shivangi Gaur
    @date:        23 November 2017
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 

        //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        Database.insert(objContract);
        
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
        
        //Create service type record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICETYPE );
        Database.insert(objServiceType);
        
        //Create location record        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATIONNAME);
        objLocation.LocationSubType__c=LOCATIONSUBTYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create supply point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        //objSupplyPoint.Measured__c=YES ;
        Database.insert(objSupplyPoint);
        
        //Create division record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //Create wholesaler record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create available service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
                
        //Create service record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        //Create service item family record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create service item type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        //Create bundle record
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        //Create available bundle record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
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
    
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        23 November 2017
    @description: Test method for retrieveContractFieldPropDetails() method
    *******************************************************************************/
    static testmethod void retrieveContractFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp = CuAp_SelectContractCtrlr.retrieveContractFieldPropDetails();
            Test.stopTest();
            
            //Asserts to check properties of list of GlAp_FieldProps retrieved
            System.assert(lstFieldProp.size()>0);
            System.assertEquals(lstFieldProp[0].isEditable,false);
            System.assertEquals(lstFieldProp[0].fieldType,'text');
            System.assertEquals(lstFieldProp[1].fieldType,'text');
            System.assertEquals(lstFieldProp[2].fieldType,'date');
            System.assertEquals(lstFieldProp[3].fieldType,'date');
            System.assertEquals(lstFieldProp[4].fieldType,'checkbox');
        }
    }
    
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        23 November 2017
    @description: Test method for retrieveContractFieldPropDetails() method negative scenario.
    *******************************************************************************/
    static testmethod void retrieveContractFieldPropDetails_Negative(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //make conFields variable of CuAp_SelectContractCtrlr class to test negative scenario
        CuAp_SelectContractCtrlr.conFields = null;
        boolean isException = false;
        
        //Run test class in user context
        system.runas(objUser){
            List<GlAp_FieldProps> lstFieldProp;
            Test.startTest();
            try{
                lstFieldProp = CuAp_SelectContractCtrlr.retrieveContractFieldPropDetails();
            }
            catch(Exception exc){
                isException = true;
            }
            Test.stopTest();
            
            System.assertEquals(lstFieldProp.isEmpty(),true);            
        }
    }
    
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        23 November 2017
    @description: Test method for retrieveContractSuppressions() method. This is for 
                  positive scenario when there are active contracts associated to an account.
    *******************************************************************************/
    static testmethod void retrieveContractSuppressions_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Query account record
        Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];
        
        //Query contract record
        BillingContract__c conObj = [Select id from BillingContract__c where AccountName__c =: accObj.id];
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            system.debug(moveInDate);
            List<BlAp_CombinedRecord> lstCombinedRec = CuAp_SelectContractCtrlr.retrieveContractSuppressions(accObj.id,moveInDate);
            Test.stopTest();
            
            //Asserts to check properties of list of BlAp_CombinedRecord retrieved
            System.assert(lstCombinedRec.size()>0);
            System.assertEquals(lstCombinedRec[0].isSelected,false);
            System.assertEquals(lstCombinedRec[0].uniqueId,conObj.id);
        }
    }

    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        29 November 2017
    @description: Test method for retrieveContractSuppressions() method. This is for 
                  negative scenario when there are no active contracts associated to an account.
    *******************************************************************************/
    static testmethod void retrieveContractSuppressions_Negative(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Query account record
        Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];
        
        //Query contract record
        BillingContract__c conObj = [Select id from BillingContract__c where AccountName__c =: accObj.id];
        
        //Delete contract record related to account in order to test negative scenario
        delete conObj;
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRec = CuAp_SelectContractCtrlr.retrieveContractSuppressions(accObj.id,moveInDate);
            Test.stopTest();
            
            System.assertEquals(lstCombinedRec.size(),0);
        }
    } 
}