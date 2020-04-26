/******************************************************************************
@author:      Echo: Dependra Singh
@date:        15 December 2017
@description: Test Class for GlUt_ProcessAvailableBundle
*******************************************************************************/

@isTest
Public class GlUt_AvailableBundleHandler_Test{
   
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
    private static String YES = 'yes';
    private static String MEASURED = 'Monthly';
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
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String MANUFACTURER1 = 'Kent';
    
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String BANDTYPE_LOWER_VALUE = '1';
    private static final String BANDTYPE_UPPER_VALUE = '10';
    
    // Trigger Specific variables
    private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';
    
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
        //update objContract;
        //Create Location record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =LOCATION_STREET ;
        Database.insert(objLocation);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174
        Database.insert(objSupplyPoint);
        
        //Create Band Type 
        BandType__c  objBandType = GlUt_FactoryData_Test.createBandType(BANDTYPE_LOWER_VALUE, BANDTYPE_UPPER_VALUE);
        Database.insert(objBandType);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Size Record - 
        DeviceSize__c objDeviceSize1 = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize1);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType1 = GlUt_FactoryData_Test.createDeviceType(objDeviceSize1,MANUFACTURER1,UNIT_OF_MEASURE);
        Database.insert(objDeviceType1);
       
        //Create device record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
        
        
        //Create Supply Point Device record
        SupplyPointDevice__c  objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        objSupplyPointDevice.InstallationDate__c = Date.newInstance(2016, 12, 9) ;
        Database.insert(objSupplyPointDevice);
        
        //Create Supply Point Band record
        SupplyPointBand__c  objSupplyPointBand = GlUt_FactoryData_Test.createSupplyPointBand(objSupplyPoint);
        objSupplyPointBand.BandType__c		=	objBandType.Id ;
        objSupplyPointBand.StartDate__c 	= 	Date.newInstance(2016, 12, 9) ;
        Database.insert(objSupplyPointBand);
        
        //Create reading record
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice);
        Database.insert(objReading);
        
        //Create service record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
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
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Create service record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        
        //Create service item type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        //objServiceItemType.DeviceType__c =objDeviceType.id; --AT-3174
        Database.insert(objServiceItemType);
		
		// Create New Service Item Type
		ServiceItemType__c  objServiceItemType1 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE+'-1',objServiceItemFamily,objDivision,objDeviceType1,objWholesaler);
        //objServiceItemType1.DeviceType__c =objDeviceType.id;  --AT-3174
        Database.insert(objServiceItemType1);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
		
		Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME +'-1',objServiceType);
        Database.insert(objBundle1);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        AvailableBundle__c objAvailableBundle2 = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        objAvailableBundle2.LastBundleChangeDate__c	= Date.newInstance(2017, 12, 9) ; //AT-4111
        Database.insert(new list<AvailableBundle__c> {objAvailableBundle, objAvailableBundle2});
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        BundleItem__c  objBundleItem0 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType1,objServiceItemFamily);
        Database.insert(objBundleItem0);
        
		//Create New  bundle item record
        BundleItem__c  objBundleItem1 = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM+'-1',objBundle1,objServiceItemType1,objServiceItemFamily);
        Database.insert(objBundleItem1);
		
		
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem.EndDate__c =Date.newInstance(2019, 12, 9);
        AvailableServiceItem__c  objAvailableServiceItem2 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem2.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem2.StartDate__c = Date.newInstance(2016, 12, 9);
        objAvailableServiceItem2.EndDate__c = Date.newInstance(2019, 12, 9);
        objAvailableServiceItem2.SupplyPointDevice__c = objSupplyPointDevice.Id ;
        AvailableServiceItem__c  objAvailableServiceItem3 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem3.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem3.StartDate__c = Date.newInstance(2016, 12, 9);
        objAvailableServiceItem3.EndDate__c = Date.newInstance(2019, 12, 9);
        objAvailableServiceItem3.SupplyPointBand__c = objSupplyPointBand.Id ;
        Database.insert(new list<AvailableServiceItem__c> {objAvailableServiceItem, objAvailableServiceItem2, objAvailableServiceItem3}); 
		
		//Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM+'-1',objBundleItem,objServiceItemType,objAvailableBundle);
        objAvailableServiceItem1.ServiceItemType__c = objServiceItemType.id;
        objAvailableServiceItem1.StartDate__c= Date.newInstance(2016, 12, 9);
        objAvailableServiceItem1.EndDate__c =Date.newInstance(2019, 12, 9);
        Database.insert(objAvailableServiceItem1); 
        
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem);
        
         //Create service item record
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType1,objService);
        objServiceItem1.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem1.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem1);
        
    }

    /*******************************************************************
    Purpose: Test bulk Insert for Available Bundle(Scenario when both Service Item Family and service item type exist.)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    static testmethod void insertAvailableBundle_Bulk(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        List<Bundle__c> lstBundle =new List<Bundle__c>();
        List<AvailableService__c> lstAvailableService = [Select Id from AvailableService__c limit 1 ];
        List<ServiceType__c> lstServiceType =[Select Id, Name from ServiceType__c];
        List<AvailableBundle__c> lstAvailableBundle = new List<AvailableBundle__c>();
        for(integer i =0; i < 200; i++){
            lstBundle.add(GlUt_FactoryData_Test.createBundle(BUNDLENAME+'-'+string.valueOf(i),lstServiceType[0]));
        }     
        for(integer j =0; j < 200; j++){
            AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle('',lstBundle[j],lstAvailableService[0]);
            lstAvailableBundle.add(objAvailableBundle);
        }
		
        //Run test class in user context
        system.runas(objUser){
            Test.startTest();
            Database.insert(lstAvailableBundle);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    /*******************************************************************
    Purpose: Test bulk update for Available Bundle
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void updateAvailableBundle_Bulk(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        List<Bundle__c> lstBundle =new List<Bundle__c>();
        List<AvailableService__c> lstAvailableService = [Select Id from AvailableService__c limit 1 ];
        List<ServiceType__c> lstServiceType =[Select Id, Name from ServiceType__c];
        List<AvailableBundle__c> lstAvailableBundle = new List<AvailableBundle__c>();
        
         for(integer i =0; i < 200; i++){
            lstBundle.add(GlUt_FactoryData_Test.createBundle(BUNDLENAME+'-'+string.valueOf(i),lstServiceType[0]));
        }     
        for(integer j =0; j < 200; j++){
            AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle('',lstBundle[j],lstAvailableService[0]);
            lstAvailableBundle.add(objAvailableBundle);
        }     
        Database.insert(lstAvailableBundle);
        if(!lstAvailableBundle.isEmpty())
        {
            for(integer i =0; i < 200; i++){
                lstAvailableBundle[i].Default__c = true;
            }     
        }
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstAvailableBundle);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
	
	   /*******************************************************************
    Purpose: Test bulk Insert for Available Bundle(Scenario when only Service Item Family exist and service item type is not exist.)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
     static testmethod void updateAvailableBundleSITNotExist(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        List<Bundle__c> lstBundle =[Select Id, Name, ServiceType__c from Bundle__c];
        List<AvailableService__c> lstAvailableService = [Select Id from AvailableService__c limit 1 ];
        List<ServiceType__c> lstServiceType =[Select Id, Name from ServiceType__c];
        List<AvailableBundle__c> lstAvailableBundle = [Select Id, Default__c,AvailableService__c,Bundle__c from AvailableBundle__c];
       
        List<BundleItem__c> bundleItemUpdateList = new List<BundleItem__c>();
        List<BundleItem__c> bundleItemList = [Select Id,Bundle__c, ServiceItemFamily__c, ServiceItemType__c // ,ServiceItemType__r.DeviceType__c --AT-3174
                                              from BundleItem__c];
        system.debug('bundleItemList============='+bundleItemList);
        if(!bundleItemList.isEmpty())
            for(BundleItem__c objBundleItem :bundleItemList)
        {
            objBundleItem.ServiceItemType__c= null;
            bundleItemUpdateList.add(objBundleItem);
        }
        if(bundleItemUpdateList.size() >0)
        {
            update bundleItemUpdateList;
            system.debug('bundleItemUpdateList============='+bundleItemUpdateList);
        }

        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstAvailableBundle);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
	
	/*******************************************************************
    Purpose: Test bulk Insert for Available Bundle(Scenario when only Service Item Family exist and service item type is not exist.)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
     static testmethod void updateAvailableBundleSITExist(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        List<Bundle__c> lstBundle =[Select Id, Name, ServiceType__c from Bundle__c where Name='TestBundle-1' LIMIT 1];
        List<AvailableService__c> lstAvailableService = [Select Id from AvailableService__c limit 1 ];
        List<ServiceType__c> lstServiceType =[Select Id, Name from ServiceType__c];
        List<AvailableBundle__c> lstAvailableBundle = [Select Id, Default__c,AvailableService__c,Bundle__c from AvailableBundle__c];
		

        if(!lstAvailableBundle.isEmpty())
        {
            for(integer i =0; i < lstAvailableBundle.size(); i++){
                lstAvailableBundle[i].Default__c = true;
				lstAvailableBundle[i].Bundle__c = lstBundle[0].Id;
            }     
        }
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstAvailableBundle);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
   /*******************************************************************
    Purpose: Test bulk Insert for Available Bundle(Scenario when only Service Item Family exist and service item type is not exist.)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
     static testmethod void updateSupplyPointBandAndDevice() {
         User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
         list<SupplyPointDevice__c> listSpd = [SELECT Id, RemovalDate__c FROM SupplyPointDevice__c WHERE SupplyPoint__r.Location__r.Name =: LOCATION_NAME LIMIT 1] ;
         list<SupplyPointBand__c> listSpb = [SELECT Id, EndDate__c FROM SupplyPointBand__c WHERE SupplyPoint__r.Location__r.Name =: LOCATION_NAME LIMIT 1] ;
         list<SObject> listSObject = new list<SObject>() ;
         system.runas(objUser) {
            Test.startTest();
            	for(SupplyPointDevice__c spd : listSpd) {
                    spd.RemovalDate__c = Date.newInstance(2017, 12, 10) ;
                    listSObject.add(spd) ;
                }
             	for(SupplyPointBand__c spb : listSpb) {
                    spb.EndDate__c = Date.newInstance(2017, 12, 10) ;
                    listSObject.add(spb) ;
                }
             Database.update(listSObject) ;
            Test.stopTest();
        }
         
     }
}