/******************************************************************************
@author:      Echo: Dependra Singh
@date:        15 December 2017
@description: Test Class for GlUt_SupplyPointDeviceHandler
*******************************************************************************/

@isTest
Public class GlUt_SupplyPointDeviceHandler_Test{
    
       //Variable declaration start
    private static String USER_PROFILE = 'System Administrator';
    private static final String USER_FNAME= 'TestFName';
    private static final String USER_LNAME= 'TestLName';
    private static final String ACTIVE = 'Active';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static String USER_NAME = 'TestUser';
    private static String USERNAMECOMPLETE = USER_NAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount';
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String LOCATION_STREET = 'Test Street';
    private static String YES ='yes';
    private static final String HALFYEARLY = 'Half Yearly';   //AT-3140
    private static final string TESERVICELBL  = 'Trade Effluent';
    private static String MEASURED = 'measured';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String BUNDLENAME ='TestBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String DEVICETYPE ='TestDeviceType';
    private static String SERVICEITEMTYPE = 'TestSrvItemType';  
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';  
    private static String DEVICENAME = 'TestDevice';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static integer LISTSIZE = 200;
    private static integer LISTSTART = 0;
    private static integer DAILYSIZE = 1;
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    
    // Trigger Specific variables
    private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';
    private static final String DEPOT_NAME        = 'Leads';
    private static final String AREA_NAME         = 'North';
   
     /*******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        
        Database.insert(objContract);
        
        //Create Location record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =LOCATION_STREET ;
        Database.insert(objLocation);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create device records
        list<Device__c> listDevice = new list<Device__c >();
            for(integer i=LISTSTART ; i<LISTSIZE; i++){
                Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICENAME,objDeviceType);
                objDevice.SerialNo__c = objDevice.SerialNo__c+i;
                objDevice.Digit__c = 10;
                listDevice.add(objDevice);
            }
        Database.insert(listDevice);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
                
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);        
        Database.insert(objDepot);
        
        // Create RuralChannel Record
        RuralChannel__c objRuralChannel = GlUt_FactoryData_Test.createRuralChannel(objArea, objDepot);        
        Database.insert(objRuralChannel);
        
        //Create supply point records
        list<SupplyPoint__c> listSupplyPoint = new list<SupplyPoint__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
            objSupplyPoint.Measured__c= True; // AT-3174 
            objSupplyPoint.RuralChannel__c = objRuralChannel.Id;
            listSupplyPoint.add(objSupplyPoint);
        }
        Database.insert(listSupplyPoint);
        
        //Create reading record
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(listDevice[0]);
        Database.insert(objReading);
        
        //Create service record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        objServiceType.Name = TESERVICELBL;   //at-3140
        Database.insert(objServiceType);
        
        //Create service item family record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create service record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //Create service record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,listSupplyPoint[0],objWholesaler);
        objAvailableService.SupplyPoint__c = listSupplyPoint[0].Id;
        Database.insert(objAvailableService);
        
        //Create service record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,listSupplyPoint[0], objAvailableService);
        Database.insert(objService);
        
        
        //Create service item type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        //objServiceItemType.DeviceType__c =objDeviceType.id; -- AT-3174
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        objAvailableBundle.AvailableService__c = objAvailableService.Id;
        Database.insert(objAvailableBundle);
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        Database.insert(objAvailableServiceItem); 
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem);
        
    }
    /*******************************************************************
    Purpose: Test bulk Insert for SupplyPointDevice
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertSupplyPointDevice_Bulk(){
       //Query user record created in test setup data method
       User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
       // List<Bundle__c> lstBundle = [Select Id from Bundle__c limit 1 ];
       // List<AvailableService__c> lstAvailableService = [Select Id from AvailableService__c limit 1 ];
       List<Device__c> lstDevice = [Select Id,Name, DeviceType__c  from Device__c ];
       List<SupplyPoint__c> lstSupplyPoint = [Select Id,Name, Location__c  from SupplyPoint__c ];
       List<SupplyPointDevice__c> lstSupplyPointDevice = new List<SupplyPointDevice__c>();
       for(integer i=LISTSTART; i<LISTSIZE; i++)
       {
         SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(lstDevice[i], lstSupplyPoint[i]);
         lstSupplyPointDevice.add(objSPD);
       }
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.insert(lstSupplyPointDevice);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
  
    /*******************************************************************
    Purpose: Test bulk Insert for SupplyPointDevice
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void updateSupplyPointDevice_Bulk(){
       //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
       // List<Bundle__c> lstBundle = [Select Id from Bundle__c limit 1 ];
       // List<AvailableService__c> lstAvailableService = [Select Id from AvailableService__c limit 1 ];
        List<Device__c> lstDevice = [Select Id,Name, DeviceType__c  from Device__c ];
        List<SupplyPoint__c> lstSupplyPoint = [Select Id,Name, Location__c  from SupplyPoint__c];
        List<SupplyPointDevice__c> lstSupplyPointDevice = new List<SupplyPointDevice__c>();
        List<SupplyPointDevice__c> lstSupplyPointDeviceForUpdate = new List<SupplyPointDevice__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
         SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(lstDevice[i], lstSupplyPoint[i]);
         lstSupplyPointDevice.add(objSPD);
        }
        Database.insert(lstSupplyPointDevice);

        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            lstSupplyPointDevice[i].DefaultAverageDailyUsage__c = i;
        }
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstSupplyPointDevice);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi   AT-3140
	@date:         24-07-2018  
	@description: Method - scenario to update Supply Point End Date without AgreedVolume.
	*******************************************************************************/
    static testmethod void validateDeviceRemoval_Positive(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        List<Device__c> lstDevice = [Select Id,Name, DeviceType__c  from Device__c ];
        List<SupplyPoint__c> lstSupplyPoint = [Select Id,Name, Location__c  from SupplyPoint__c];
        List<SupplyPointDevice__c> lstSupplyPointDevice = new List<SupplyPointDevice__c>();
        List<SupplyPointDevice__c> lstSupplyPointDeviceForUpdate = new List<SupplyPointDevice__c>();
        Boolean isException;
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(lstDevice[i], lstSupplyPoint[i]);
            lstSupplyPointDevice.add(objSPD);
        }
        Database.insert(lstSupplyPointDevice);
        
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            lstSupplyPointDevice[i].RemovalDate__c = system.today();
            lstSupplyPointDevice[i].TEDevice__c = True;
        }
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            try{ 
                Database.update(lstSupplyPointDevice);
            }
            catch(exception e){
                isException = true;
            }
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi   AT-3283
	@date:        10-08-2018  
	@description: Method - scenario to test eligibleForBudgetPlan positive scenario
	*******************************************************************************/
    static testmethod void eligibleForBudgetPlan_Positive(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        List<Device__c> lstDevice = [Select Id,Name, DeviceType__c  from Device__c ];
        List<SupplyPoint__c> lstSupplyPoint = [Select Id,Name, Location__c  from SupplyPoint__c];
        List<SupplyPointDevice__c> lstSupplyPointDevice = new List<SupplyPointDevice__c>();
        List<SupplyPointDevice__c> lstSupplyPointDeviceForUpdate = new List<SupplyPointDevice__c>();
        Boolean isException;
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(lstDevice[i], lstSupplyPoint[i]);
            objSPD.RemovalDate__c = system.today();
            lstSupplyPointDevice.add(objSPD);
        }
        Database.insert(lstSupplyPointDevice);
        
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            lstSupplyPointDevice[i].RemovalDate__c = null;    //Activating the Supply Point Device by removing its End Date
            lstSupplyPointDevice[i].TEDevice__c = True;
        }
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            try{ 
                   Database.update(lstSupplyPointDevice);
            }
            catch(exception e){
                isException = true;
            }
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi   AT-3283
	@date:        10-08-2018  
	@description: Method - scenario to test eligibleForBudgetPlan positive scenario
	*******************************************************************************/
    static testmethod void uncheckEligibleForBudgetPlanOnContract_Positive(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        List<Device__c> lstDevice = [Select Id,Name, DeviceType__c  from Device__c ];
        List<SupplyPoint__c> lstSupplyPoint = [Select Id,Name, Location__c  from SupplyPoint__c];
        List<SupplyPointDevice__c> lstSupplyPointDevice = new List<SupplyPointDevice__c>();
        List<SupplyPointDevice__c> lstSupplyPointDeviceForUpdate = new List<SupplyPointDevice__c>();
        Boolean isException;
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(lstDevice[i], lstSupplyPoint[i]);
            objSPD.RemovalDate__c  = null;    //Activating the Supply Point Device by removing its End Date
            lstSupplyPointDevice.add(objSPD);
        }
        Database.insert(lstSupplyPointDevice);
        
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            lstSupplyPointDevice[i].RemovalDate__c  = system.today();  //Removing the Device
        }
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            try{ 
                   Database.update(lstSupplyPointDevice);
            }
            catch(exception e){
                isException = true;
            }
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
}