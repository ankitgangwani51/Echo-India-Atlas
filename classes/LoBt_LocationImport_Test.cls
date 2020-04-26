/*****************************************************************************************************************************
@author         Echo: Sudhir Kumar
@date           01 Feb 2019
@description    AT-4767, AT-5049, AT-5050: Test class for LoBt_LocationImport
******************************************************************************************************************************/
@isTest
private class LoBt_LocationImport_Test {
    private static String USERPROFILE 				= 'System Administrator' ;
    private static final String USERFNAME			= 'LocationImportName' ;
    private static final String USERLNAME			= 'LocationImportLName' ;
	private static final String USER_NAME 			= 'TestLocationImportUser' ; 
    private static final String USERNAMECOMPLETE 	= USER_NAME+ '@unitest.com' ;
    private static final String TEST_SERVICE_TYPE 	= 'TestServiceType' ;
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType' ;
    private static final String TESTSERVICE_TYPE1 	= 'TestServiceType1' ; 
    private static final String TESTSERVICE_TYPE2 	= 'TestServiceType2' ;
    private static final String WHOLESALER 			= 'TestWholesaler' ;
    private static final String BUNDLE1 			= 'Water Measured Bundle' ;
    private static final String BUNDLE2 			= 'Measured Sewerage Bundle - Standard' ;
    private static final Integer BATCH_SIZE 		= 200 ;
    private static final String BATCHCLASS 			= 'LoBt_LocationImport' ;
    private static final String BATCHREQQUEUEINITIALISEDSTATUS = 'Initialised' ;
    
    
    @testSetup
    static void createTestDate() {
        //Create User Record.
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE, USER_NAME, null) ;
        objUser.FirstName = USERFNAME ;
        objUser.LastName = USERLNAME ;
        Database.insert(objUser) ;  
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE) ;
        Database.insert(objSupplyPointUsageType) ;
        // Create Division Record
        Division__c  objDivision1 = GlUt_FactoryData_Test.createDivision() ;
        Division__c  objDivision2 = GlUt_FactoryData_Test.createDivision() ;
        Database.insert(new list<Division__c> {objDivision1, objDivision2}) ;
        // Create Wholesaler Record
        Wholesaler__c objWholesaler1 = GlUt_FactoryData_Test.createWholesaler(WHOLESALER) ;
        Wholesaler__c objWholesaler2 = GlUt_FactoryData_Test.createWholesaler(WHOLESALER) ;
        Database.insert(new list<Wholesaler__c> {objWholesaler1, objWholesaler2}) ;
        //Create Service Type Record
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1) ;
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE2) ;
        Database.insert(new list<ServiceType__c> {objServiceType1, objServiceType2}) ;
        //Create Bundle
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLE1, objServiceType1) ;
        Bundle__c objBundle2 = GlUt_FactoryData_Test.CreateBundle(BUNDLE2, objServiceType2) ;
        Database.insert(new list<Bundle__c> {objBundle1, objBundle2});
        //Create LocationUpload records from GlUt_FactoryData_Test
        LocationUpload__c objLocationUpload = GlUt_FactoryData_Test.createLocationUpload(objServiceType1.Id, objServiceType2.Id, objDivision1.Id, objDivision2.Id,
                                                                           objWholesaler1.Id, objWholesaler2.Id, BUNDLE1, BUNDLE2, objSupplyPointUsageType.Id) ;
        Database.insert(objLocationUpload) ;
        //Create LocationUpload records from CSV file
        list<StaticResource> listStaticResource = [SELECT Id FROM StaticResource WHERE Name =: System.Label.LoBt_LocationImport_BulkStaticResource] ;
        if(listStaticResource != null && !listStaticResource.isEmpty()) {
            //Commenting Static Resource reference here for AU3 deployment Test Class issue: Validation Errors While Saving Record(s) Stack Trace: null
            //list<sObject> listCsvRecords = Test.loadData(LocationUpload__c.sobjectType, System.Label.LoBt_LocationImport_BulkStaticResource) ;
        }
        //Create Batch Process        
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCHCLASS);
        Database.insert(objBatchProcess);
        ////Create Batch Reques tQueue        
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.BatchProcess__c = objBatchProcess.Id;
        objBatchRequestQueue.Status__c = BATCHREQQUEUEINITIALISEDSTATUS;
        Database.insert(objBatchRequestQueue);
    }
    /******************************************************************************
    @author:    	Echo: Sudhir Kumar
    @date:      	01 Feb 2019
    @description: 	Test method for "execute" method - Bulk Positive scenario
    *******************************************************************************/ 
    static testmethod void execute_BulkPositive() {
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE limit 1];
        System.runAs(objUser) {
            Boolean isException = false ;
            try {
                BatchRequestQueue__c objBatchRequestQueue = [SELECT Id, Status__c FROM BatchRequestQueue__c LIMIT 1] ;
                list<sObject> listCsvRecords = [SELECT Id FROM LocationUpload__c LIMIT 200] ;
                system.assert(listCsvRecords != null && !listCsvRecords.isEmpty()) ;
                Test.startTest() ;
                    LoBt_LocationImport locationImportJob  = new LoBt_LocationImport() ;
                	locationImportJob.Initialise(objBatchRequestQueue) ;
                    Database.executeBatch(locationImportJob, BATCH_SIZE) ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    
    /******************************************************************************
    @author:    	Echo: Sudhir Kumar
    @date:      	01 Feb 2019
    @description: 	Test method for "execute" method - Bulk Negative scenario
    *******************************************************************************/ 
    static testmethod void execute_BulkNegative() {
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE limit 1];
        System.runAs(objUser) {
            Boolean isException = false ;
            try {
                Test.startTest() ;
                    list<sObject> listCsvRecords = new list<sObject>() ;
                    for(LocationUpload__c locUpload : [SELECT Id FROM LocationUpload__c LIMIT 200]) {
                        locUpload.City__c = null ;
                        listCsvRecords.add(locUpload) ;
                    }
                	Database.update(listCsvRecords) ;
                    LoBt_LocationImport jobLocationImport = new LoBt_LocationImport() ;
                    Database.executeBatch(jobLocationImport, BATCH_SIZE) ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(isException) ;
            
        }
    }
    
    /******************************************************************************
    @author:    	Echo: Sudhir Kumar
    @date:      	01 Feb 2019
    @description: 	Test method for "execute" method - Positive scenario
    *******************************************************************************/ 
    static testmethod void execute_Positive() {
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser) {
            Boolean isException = false ;
            try {
                Test.startTest() ;
                	BatchRequestQueue__c objBatchRequestQueue = [SELECT Id, Status__c FROM BatchRequestQueue__c LIMIT 1] ;
                    LoBt_LocationImport locationImportJob = new LoBt_LocationImport() ;
                	locationImportJob.Initialise(objBatchRequestQueue) ;
                    Database.executeBatch(locationImportJob, BATCH_SIZE) ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author:    	Echo: Sudhir Kumar
    @date:      	01 Feb 2019
    @description: 	Test method for "execute" method - Negative scenario
    *******************************************************************************/ 
    static testmethod void execute_Negative() {
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE limit 1];
        System.runAs(objUser) {
            Boolean isException = false ;
            try {
                LocationUpload__c locUpload = [SELECT Id FROM LocationUpload__c LIMIT 1] ;
                locUpload.SupplyPointUsageType__c = null ;
                Database.update(locUpload) ;
                Test.startTest() ;
                    LoBt_LocationImport jobLocationImport = new LoBt_LocationImport() ;
                    Database.executeBatch(jobLocationImport, BATCH_SIZE) ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(isException) ;
        }
    }
}