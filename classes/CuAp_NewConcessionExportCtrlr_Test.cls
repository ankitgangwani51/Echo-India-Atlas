/******************************************************************************
@author:      Echo: Vivek Sethi 
@date:        08-Jan-2019  
@description: Test Class for CuAp_NewConcessionExportCtrlr
*******************************************************************************/
@isTest
public class CuAp_NewConcessionExportCtrlr_Test {
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'vivek';
    private static final String USER_LNAME = 'sethi';
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    private static final String AREA_NAME = 'Test Area';
    private static final String DEPOT_NAME = 'Test Depot'; 
    private static final String READTIMETABLE = 'Read TimeTable';
    private static final String MONTHLY = 'Monthly';
    private static final String BATCH_CLASS_NAME = LoAp_Constants.BATCHPROCESSCONSCESSIONEXPORT;
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        08-Jan-2019 
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME; 
        Database.insert(objUser);
        
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);
        objDepot .Area__c = objArea.Id;        
        Database.insert(objDepot);
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE,MONTHLY);        
        Database.insert(objReadTimetable);
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable);        
        Database.insert(objBook);
        
        // Create ReadPeriod Record 
        ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimetable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        Database.insert(objReadPeriod);
        
        // Create Batch Process Record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS_NAME);
        objBatchProcess.Operation__c = LoAp_Constants.BATCHPROCESSOPERATION;
        objBatchProcess.BatchClass__c = LoAp_Constants.BATCHPROCESSCONSCESSIONEXPORT;
        Database.insert(objBatchProcess);
        
    }
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        08-Jan-2019  
	@description: Test Method to handel create BRQ record in POSITIVE scenario
	*******************************************************************************/
    static testmethod void createBRQ_Positive(){
        
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        List<Book__c> objBook = [SELECT Id 
                                 FROM Book__c LIMIT 1];
        
        List<Id> bookId = new List<Id>();
        List<Id> periodId = new List<Id>();
        List<Id> readTimeTableId = new List<Id>();
        for(Book__c b : objBook){
            bookId.add(b.Id);
        }
        List<ReadPeriod__c> objperiodId = [SELECT Id 
                                           FROM ReadPeriod__c LIMIT 1];
        for(ReadPeriod__c rp : objperiodId){
            periodId.add(rp.Id);
        }
        List<ReadTimetable__c> objreadTimeTableId = [SELECT Id 
                                                     FROM ReadTimetable__c LIMIT 1];
        for(ReadTimetable__c rt : objreadTimeTableId){
            readTimeTableId.add(rt.Id);
        }
        Id brqId;
        System.runAs(objUser){
            Test.startTest();           
            brqId = CuAp_NewConcessionExportCtrlr.createBRQ(readTimeTableId,periodId,bookId);
            Test.stopTest();          
        }
        System.assert (brqId != null);
        
    }
    /******************************************************************************
	@author:      Echo: Vivek Sethi 
	@date:        08-Jan-2019  
	@description: Test Method to handel create BRQ record in NEGATIVE scenario
	*******************************************************************************/
    static testmethod void createBRQ_Negative(){
        boolean isException;
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        List<Book__c> objBook = [SELECT Id 
                                 FROM Book__c LIMIT 1];
        List<Id> bookId = new List<Id>();
        List<Id> periodId = new List<Id>();
        List<Id> readTimeTableId = new List<Id>();
        for(Book__c b : objBook){
            bookId.add(b.Id);
        }
        
        List<ReadTimetable__c> objreadTimeTableId = [SELECT Id 
                                                     FROM ReadTimetable__c LIMIT 1];
        
        for(ReadTimetable__c rt : objreadTimeTableId){
            readTimeTableId.add(rt.Id);
        }
        Id brqId;
        System.runAs(objUser){
            try{
                Test.startTest();           
                brqId = CuAp_NewConcessionExportCtrlr.createBRQ(readTimeTableId,periodId,bookId);
            }catch(Exception e)
            {
                isException = true;            
            }
            Test.stopTest();
        }
        System.assert (brqId == null);
    }  
}