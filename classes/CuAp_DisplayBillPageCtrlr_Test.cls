/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        04 December 2017
@description: Test Class for CuAp_DisplayBillPageCtrlr
Revision(s):  
@Revision	 	AT-3979, Tarun - Modified as per security review
*******************************************************************************/
@isTest
Public Class CuAp_DisplayBillPageCtrlr_Test{
    

    //Variable declaration start

    public static String PROFILENAME = 'System Administrator';
    public static String USERNAME = 'TestUser222';
    private static String ACCOUNTNAME = 'TestAccount'; 
    private static String CONTRACTID = 'contractId'; 
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
    private static Integer VOLUMEUSED = 200;
    private static Integer BILLEDAMOUNT = 250; 
    private static String HEROKUPOSTGRESSID ='HerokuPostgresId'; 
    private static string DUMMYOBJECT = 'DUMMYOBJECT';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';


    //Variable declaration end

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        04 December 2017
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
        objSupplyPoint.Measured__c= True; // AT-3174 
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

        //Create bill record
        Bill__c objBill = GlUt_FactoryData_Test.createBill(' ',objContract);
        Database.insert(objBill);

        //Create bill Service Type record
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(' ',objBill,HEROKUPOSTGRESSID);
        Database.insert(objBillServiceType);

        //Create bill Item record
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(' ',objServiceItem,VOLUMEUSED ,BILLEDAMOUNT,objBillServiceType,HEROKUPOSTGRESSID);
        Database.insert(objBillItem);

    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        04 December 2017
@description: Test method for retrieveBillItemFieldPropDetails() method positive scenario
*******************************************************************************/
    static testmethod void retrieveBillItemFieldPropDetails_Positive(){

        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Run test class in user context
        system.runas(objUser){

            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp = CuAp_DisplayBillPageCtrlr.retrieveBillItemFieldPropDetails();
            Test.stopTest();

            System.assert(lstFieldProp.size()>0);
            System.assertEquals(lstFieldProp[0].isEditable,false);
        }

    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        07 December 2017
@description: Test method for fetchLstOfBillItems() method positive scenario.
*******************************************************************************/
    static testmethod void fetchLstOfBillItems_Positive(){

        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query account record
        Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];

        //Query contract record
        BillingContract__c contractObj = [Select id from BillingContract__c where AccountName__c=: accObj.id limit 1];

        //Query Bill record
        List<String> billRec = new List<String>();
        List<String> billServTypeRec= new List<String>();

        for(Bill__c  blRec:[Select id from Bill__c  where BillingContract__c =: contractObj.id 
                              order by createdDate desc Limit 1]){
            billRec.add(blRec.Id);
        }

        for(BillServiceType__c blServTypeRec : [Select id,Name from BillServiceType__c where bill__c =:billRec]){
            billServTypeRec.add(blServTypeRec.Id);
        }

        List<BillItem__c> blItemRec = [Select id, Name, BilledAmount__c, StartDate__c, EndDate__c from BillItem__c  where BillServiceType__c =: billServTypeRec order by createdDate desc Limit 1];

        //Run test class in user context
        system.runas(objUser){

            Test.startTest();
            List<BlAp_CombinedRecord> combBillItemList = CuAp_DisplayBillPageCtrlr.fetchLstOfBillItems(billRec[0]);
            Test.stopTest();

            System.assert(combBillItemList.size()>0);
            System.assertEquals(combBillItemList[0].isSelected,false);
        }

    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        07 December 2017
@description: Test method for fetchLstOfBillItems() method negative scenario.
*******************************************************************************/
    static testmethod void fetchLstOfBillItems_Negative(){

        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query account record
        Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];

        //Query contract record
        BillingContract__c contractObj = [Select id from BillingContract__c where AccountName__c=: accObj.id limit 1];

        //Query Bill record
        List<String> billRec = new List<String>();
        List<String> billServTypeRec= new List<String>();

        for(Bill__c  blRec:[Select id from Bill__c  where BillingContract__c =: contractObj.id 
                              order by createdDate desc Limit 1]){
            billRec.add(blRec.Id);
        }

        for(BillServiceType__c blServTypeRec : [Select id,Name from BillServiceType__c where bill__c =:billRec]){
            billServTypeRec.add(blServTypeRec.Id);
        }

        List<BillItem__c> blItemRec = [Select id, Name, BilledAmount__c, StartDate__c, EndDate__c from BillItem__c  where BillServiceType__c =: billServTypeRec 
                                                                                                        order by createdDate desc Limit 1];
                             
        //Delete Bill Item related to Bill Service Type in order to test negative scenario
        delete blItemRec;

        //Run test class in user context
        system.runas(objUser){

            Test.startTest();
            List<BlAp_CombinedRecord> combBillItemList = CuAp_DisplayBillPageCtrlr.fetchLstOfBillItems(null);
            Test.stopTest();

            System.assertEquals(combBillItemList.size(),0);
        }

    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        07 December 2017
@description: Test method for retrieveBillAmount() method positive scenario.
*******************************************************************************/
    static testmethod void retrieveBillAmount_Positive(){

        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query account record
        Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];

        //Query contract record
        BillingContract__c contractObj = [Select id from BillingContract__c where AccountName__c=: accObj.id limit 1];

        //Query Bill record

        List<Bill__c> billList = [Select id, BilledAmount__c from Bill__c  where BillingContract__c =: contractObj.id order by createdDate desc Limit 1];      

        //Run test class in user context
        system.runas(objUser){

            Test.startTest();
            double  totalBilledAmount = CuAp_DisplayBillPageCtrlr.retrieveBillAmount(billList[0].id);
            Test.stopTest();

            System.assertEquals(totalBilledAmount,billList[0].BilledAmount__c);
        }

    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        07 December 2017
@description: Test method for retrieveBillAmount() method Negative scenario.
*******************************************************************************/
    static testmethod void retrieveBillAmount_Negative(){

        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query account record
        Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];

        //Query contract record
        BillingContract__c contractObj = [Select id from BillingContract__c where AccountName__c=: accObj.id limit 1];

        //Query Bill record

        List<Bill__c> billList = [Select id, BilledAmount__c from Bill__c  where BillingContract__c =: contractObj.id order by createdDate desc Limit 1];      

        //Delete Bill list in order to test negative scenario
        delete billList;

        //Run test class in user context
        system.runas(objUser){

            Test.startTest();
            double  totalBilledAmount = CuAp_DisplayBillPageCtrlr.retrieveBillAmount(null);
            Test.stopTest();

            System.assertEquals(totalBilledAmount,null);

        }

    }

}