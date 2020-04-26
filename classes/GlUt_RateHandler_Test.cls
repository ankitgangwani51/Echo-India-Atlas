/******************************************************************************
@author:      Accenture: Satish Nair
@date:        11 December 2017
@description: Test Class for GlUt_RateHandler
*******************************************************************************/

@isTest
Public class GlUt_RateHandler_Test{

    //Variable declaration start

    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='BundleLN123'; 
    private static final String USER_FNAME= 'BundleFN123';
    private static final String USER_LNAME= 'BundleLN123';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String YES ='yes';
    private static String MEASURED = 'measured';
    private static String WHOLESALER ='TestWholesaler';
    private static String USERNAMECOMPLETE = USER_NAME+ '@unitest.com'; 
    private static String DEVICETYPE ='TestDeviceType';
    private static String SERVICEITEMTYPE = 'TestSrvItemType';  
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';  
    private static String ACCOUNTNAME = 'TestAccount'; 
    private static String DEVICENAME = 'TestDevice';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
	private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';
    
     //Variable declaration end

/******************************************************************************
@author:      Accenture: Satish Nair
@date:        11 December 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
    
         User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);

        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        Database.insert(objServiceType); 

        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);

        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);

        //Create device record
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);

        //Create service item family record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);

         //Create service item type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Rate__c objRate = GlUt_FactoryData_Test.createRate(objServiceItemType,123);
        objRate.StartDate__c= system.today().addMonths(-10);
        Database.insert(objRate); 
        
    }

	/******************************************************************************
	@author:      Echo: Dependra Singh
	@date          07-Mar-2019
	@description: Test method for rateInsertBulk_Positive method.
	*******************************************************************************/
	static testmethod void rateInsertBulk_Positive(){
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username=:USERNAMECOMPLETE  limit 1];
        ServiceItemType__c srvItmType = [Select id,Name from ServiceItemType__c where name=:SERVICEITEMTYPE Limit 1];
        List<Rate__c> rates = [Select id,retailAmount__c,ServiceItemType__c from Rate__c where ServiceItemType__c =:srvItmType.Id];
		List<Rate__c> rateList = new List<Rate__c>();
		for(Integer i=0; i<200; i++){
		  Rate__c rateObj = GlUt_FactoryData_Test.createRate(srvItmType,i);
		  rateObj.StartDate__c = System.today().addMonths(i);
		  rateList.add(rateObj);
		}     
        System.runAs(objUser){
			Test.startTest();  
			Database.insert(rateList);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
	/******************************************************************************
	@author:      Echo: Dependra Singh
	@date          07-Mar-2019
	@description: Test method for rateUpdateBulk_Positive method.
	*******************************************************************************/
    static testmethod void rateUpdateBulk_Positive(){
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username=:USERNAMECOMPLETE  limit 1];
        ServiceItemType__c srvItmType = [Select id,Name from ServiceItemType__c where name=:SERVICEITEMTYPE Limit 1];
        List<Rate__c> rates = [Select id,retailAmount__c,ServiceItemType__c from Rate__c where ServiceItemType__c =:srvItmType.Id];
        List<Rate__c> rateList = new List<Rate__c>();
        List<Rate__c> rateListUpdate = new List<Rate__c>();  
        for(Integer i=0; i<20; i++){
            Rate__c rateObj = GlUt_FactoryData_Test.createRate(srvItmType,i);
            rateObj.StartDate__c = System.today().addMonths(i);
            rateList.add(rateObj);
        }    
        Database.insert(rateList);
        for(Rate__c objRate : rateList){
            objRate.RetailAmount__c = 100;
            rateListUpdate.add(objRate);
        }
        System.runAs(objUser){
            Test.startTest();  
            Database.update(rateListUpdate);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    
    /******************************************************************************
	@author:      Echo: Dependra Singh
	@date          07-Mar-2019
	@description: Test method for checkOverlapRatesIfNotBanded_Positive method.
	*******************************************************************************/
    static testmethod void checkOverlapRatesIfNotBanded_Positive(){
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username=:USERNAMECOMPLETE  limit 1];
        ServiceItemType__c srvItmType = [Select id,Name from ServiceItemType__c where name=:SERVICEITEMTYPE Limit 1];
        Rate__c rateObj = GlUt_FactoryData_Test.createRate(srvItmType,300);
        rateObj.StartDate__c = System.today().addMonths(-12);
        System.runAs(objUser){
            Test.startTest();  
            Database.insert(rateObj);
            //Asserts to check bulk limits
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    
    /******************************************************************************
	@author:      Echo: Dependra Singh
	@date          07-Mar-2019
	@description: Test method for checkOverlapRatesIfNotBanded_Negative method.
	*******************************************************************************/
    static testmethod void checkOverlapRatesIfNotBanded_Negative(){
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username=:USERNAMECOMPLETE  limit 1];
        ServiceItemType__c srvItmType = [Select id,Name from ServiceItemType__c where name=:SERVICEITEMTYPE Limit 1];
        Rate__c rateObj = GlUt_FactoryData_Test.createRate(srvItmType,300);
        rateObj.StartDate__c = System.today().addMonths(-12);
        rateObj.EndDate__c = System.today().addMonths(-5);
        System.runAs(objUser){
            Test.startTest();  
            Database.insert(rateObj);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    
  }