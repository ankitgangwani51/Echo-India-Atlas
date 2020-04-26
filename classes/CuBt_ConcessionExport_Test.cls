/******************************************************************************
@author         Vivek Sethi
@date           07 Jan 2018
@description    Test Class For CuBt_ConcessionExport
@Revisions	  	05/03/19 Tarun , Fixed consdev test class deployment failures.
*******************************************************************************/
@isTest
public class CuBt_ConcessionExport_Test {
    
    private static final String USER_PROFILE 	 		= 'System Administrator';
    private static final String USER_NAME 		 		= 'FN123LN123';  
    private static final String USERNAMECOMPLETE  		=  USER_NAME + '@unitest.com';
    private static final String USER_FNAME		 		= 'FN123';	
    private static final String USER_LNAME		 		= 'LN123'; 
    private static final String TEST_DEPOT   			= 'Test Depot';
    private static final String AVAIL_SERVICE     	    = 'WATER';
    private static final String WHOLESALER        	    = 'abc';
    private static final String LOCATION_NAME 			= 'A99 9AA';
    private static final String AREA_NAME 				= 'Test Area';
    private static final String TEST_READ_TIMETABLE	    = 'Test Read Timetable';
    private static final String ACCOUNT_NAME            = 'TestAccount';
    private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';  
    private static final String MEASURED 				= 'Monthly';
    private static final String MONTHLY  			    = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    private static final String SERVICE_TYPE            = 'Service_Type';    
    private static final String CRN                     = 'Test';    
    private static final Date READ_START_DATE 			= date.valueOf('2018-02-15');
    private static final Date READ_END_DATE 			=  system.today() + 20; 
    private static final Date BILL_PERIOD_STARTDATE	 	= date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE 		= system.today() + 20;
    
    private class BRQParameters_JSON {
        private Id timetableID ;
        private Id periodID;
        private List<Id> booksToExport  = new List<Id>();
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           07 Jan 2018
    @return         Void   
    @description    Test data setup method
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){ 
  
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
    
        //Create account
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Concession
        Concession__c  objConcession = GlUt_FactoryData_Test.createConcession(objAccount);
        objConcession.ConsentDate__c = system.today();
        objConcession.StartDate__c = system.today();
        objConcession.ValidationDate__c = system.today();
        objConcession.ConfirmDate__c = system.today();
        objConcession.CRN__c = CRN;  
        Database.insert(objConcession);
        
        //Create Contract
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        Database.insert(objContract);
        
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        //Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(TEST_DEPOT);
        Database.insert(objDepot);
        
        //Create Read Timetable Record
        ReadTimetable__c objReadTimeTable = GlUt_FactoryData_Test.createReadTimetable(TEST_READ_TIMETABLE,MONTHLY);
        Database.insert(objReadTimeTable);
        
        //Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot,objReadTimeTable);
        objBook.ReadFrequency__c = MEASURED;
        Database.insert(objBook);
        
        // Create ReadPeriod Record 
        ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimeTable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        Database.insert(objReadPeriod);   
        
         // Create ReadingMode Record
        ReadingMode__c objReadingMode = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);
        Database.insert(objReadingMode);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //Create location occupant record    
        LocationOccupant__c objLocationOccupants = GlUt_FactoryData_Test.createLocationOccupant(objAccount,objLocation);
        objLocationOccupants.Primary__c = TRUE;
        Database.insert(objLocationOccupants);        
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Book__c   = objBook.Id;  
        objSupplyPoint.Location__c = objLocation.Id;
        objSupplyPoint.Measured__c= True; 
        Database.insert(objSupplyPoint);
    
        //create Reading Request record createReadingRequest
        ReadingRequest__c objReadingRequest = GlUt_FactoryData_Test.createReadingRequest(objSupplyPoint);
        objReadingRequest.Status__c= LoBt_Constants.READINGREQUESTNEWSTATUS;
        Database.insert(objReadingRequest);
        
        // Create ServiceType Record            
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE);
        Database.insert(objServiceType);
        
        // Create Division Record            
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);   
        
        // Create Wholesaler Record            
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);   
        
        // Create AvailableService Record            
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE, objDivision, objServiceType, objSupplyPoint, objWholesaler );
        Database.insert(objAvailableService);   
        
        BRQParameters_JSON brqObj = new  BRQParameters_JSON();
        brqObj.booksToExport.add(objBook.Id);        
        brqObj.periodID =  objReadPeriod.Id;
        
        //Create BatchRequestQueue Record
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.Parameters__c = JSON.serialize(brqObj);
        Database.insert(objBatchRequestQueue);
    }
    
    /******************************************************************************
	@author         Vivek Sethi
	@date           07 Jan 2018
	@description:   Test Method to check CuBt_ConcessionExport Batch class
	*******************************************************************************/
    static testmethod void CuBt_ConcessionExport_Positive() {
        setEnvironmentSettingData();
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BatchRequestQueue__c BatchRequestQueue = [select Id , Parameters__c, Status__c from BatchRequestQueue__c limit 1]; 
        
        System.runAs(objUser){
            Test.startTest();
            CuBt_ConcessionExport obj = new CuBt_ConcessionExport();
            obj.Initialise(BatchRequestQueue);
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
        BatchRequestQueue__c BatchRequestQueue1 = [select Id , Parameters__c, Status__c from BatchRequestQueue__c limit 1]; 
        system.assert(BatchRequestQueue1.Status__c != LoAp_Constants.LOADING);
       
    }
    /******************************************************************************
	@author         Vivek Sethi
	@date           07 Jan 2018
	@description:   Test Method to check CuBt_ConcessionExport Batch class Negative Scenario
*******************************************************************************/
    static testmethod void CuBt_ConcessionExport_Negative() {
        setEnvironmentSettingData();
        User objUser = [Select Id, Name from User where isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        boolean isException;
        System.runAs(objUser){
            try{
                Test.startTest();
                CuBt_ConcessionExport obj = new CuBt_ConcessionExport();
                CuPr_ConcessionExportParameters.parse(null);
                DataBase.executeBatch(obj);
            }
            catch(Exception e){
                isException = true;            
            }
            Test.stopTest();
        }
        System.assert(isException == true);
    }
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Enviroment Setting Custom meta data type Data
    *******************************************************************************/ 
    private static void setEnvironmentSettingData(){
        GlUt_CustomMetaDataUtility.setMetadata(GlUt_Constants.ENVSETTINGCONCESSIONEXPORTQUERY,(List<EnvironmentSettings__mdt>) JSON.deserialize( 
            '[{"' + GlUt_Constants.CONCESSTIONEXPOTAPINAME + '":"' + GlUt_Constants.CONCESSTIONEXPORTVALUE + '"}]',List<EnvironmentSettings__mdt>.class )); 
    }
}