/******************************************************************************
@author         Echo: Mohit Tayal
@date           08 June 2018
@description    Component controller for BookExportRequest lightning component
@Revisions      
*******************************************************************************/
@isTest
public class LoAp_BookExportRequestCtrlr_Test {

    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'neha';
    private static final String USER_LNAME = 'rajput';
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    private static final String AREA_NAME = 'Test Area';
    private static final String DEPOT_NAME = 'Test Depot'; 
    private static final String READTIMETABLE = 'Read TimeTable';
    private static final String MONTHLY = 'Monthly';
    private static final String BATCH_CLASS_NAME = 'LoBt_ExportBooks';
    
    /******************************************************************************
    @author:      Echo: Mohit Tayal
    @date:        08-June-2018  
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){
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
        objBatchProcess.BatchClass__c = LoAp_Constants.BATCHPROCESSEXPORTBOOKCLASSNAME;
        Database.insert(objBatchProcess);

        List<Id> booksIdsToExports = new List<Id>();  
        booksIdsToExports.add(objBook.Id);
        
        LoPr_BookExportParameters objLoPr_BookExportParameters = new LoPr_BookExportParameters();
        objLoPr_BookExportParameters.timetableID = objReadTimetable.Id;
        objLoPr_BookExportParameters.periodID = objReadPeriod.Id;
        objLoPr_BookExportParameters.booksToExport = booksIdsToExports;
        
        BatchRequestQueue__c objBatchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        objBatchRequestQueue.BatchProcess__c = objBatchProcess.Id;
        objBatchRequestQueue.NotificationUser__c = objUser.Id;
        objBatchRequestQueue.Status__c = 'Completed';
        objBatchRequestQueue.Parameters__c = JSON.serialize(objLoPr_BookExportParameters);
        Database.insert(objBatchRequestQueue);
    }
    
    /******************************************************************************
    @author:      Echo: Mohit Tayal
    @date:        08-JUNE-2018  
    @description: Test Method to handel create BRQ record in POSITIVE scenario
    *******************************************************************************/
    static testmethod void retrieveBookExportRequestFields(){
        
        User objUser = [SELECT Id,Name 
                        FROM User 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        List<GlAp_FieldProps> lstFieldProps = new List<GlAp_FieldProps>();
        
        System.runAs(objUser){
            Test.startTest();           
            lstFieldProps = LoAP_BookExportRequestCtrlr.retrieveBookExportRequestFields();
            Test.stopTest();          
        }
        System.assert(lstFieldProps != null);
        
    }
    /******************************************************************************
    @author:      Echo: Mohit Tayal
    @date:        08-JUNE-2018  
    @description: Test Method to handel create BRQ record in NEGATIVE scenario
    *******************************************************************************/
    static testmethod void reteriveBookExportRequestRecords(){
        List<BlAp_CombinedRecord> lstRecords = new List<BlAp_CombinedRecord>();
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest();           
            lstRecords = LoAp_BookExportRequestCtrlr.retrieveBookExportRequestRecords();
            Test.stopTest();
        }
        System.assert(lstRecords != null);
        
    }  
    /******************************************************************************
    @author:      Echo: Mohit Tayal
    @date:        08-JUNE-2018  
    @description: Test Method to handel create BRQ record in POSITIVE scenario
    *******************************************************************************/
    static testmethod void retrieveFieldPropDetails(){
        
        User objUser = [SELECT Id,Name 
                        FROM User 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Map<String,List<GlAp_FieldProps>> mapOfTabNameAndFieldProps = new Map<String,List<GlAp_FieldProps>>();
        
        System.runAs(objUser){
            Test.startTest();           
            mapOfTabNameAndFieldProps = LoAP_BookExportRequestCtrlr.retrieveFieldPropDetails();
            Test.stopTest();          
        }
        System.assert(mapOfTabNameAndFieldProps != null);
        
    }
    /******************************************************************************
    @author:      Echo: Mohit Tayal
    @date:        08-JUNE-2018  
    @description: Test Method to handel create BRQ record in NEGATIVE scenario
    *******************************************************************************/
    static testmethod void retrieveTabRecords(){
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<Id> lstBatchProcess = new List<Id>();
        for(BatchProcess__c objBatchProcess : [SELECT Id FROM BatchProcess__c WHERE BatchClass__c = :BATCH_CLASS_NAME]){
            lstBatchProcess.add(objBatchProcess.Id);
        }
        List<BatchRequestQueue__c> lstBatchRequestQueue = [SELECT Id From BatchRequestQueue__c WHERE BatchProcess__c IN :lstBatchProcess];
        ReadTimetable__c objReadTimetable = [SELECT Id FROM ReadTimetable__c WHERE Name = :READTIMETABLE AND ReadFrequency__c = :MONTHLY];
        List<Id> periodIds = new List<Id>();
        for(ReadPeriod__c objPeriod : [SELECT Id FROM ReadPeriod__c WHERE ReadTimetable__c = :objReadTimetable.Id]){
            periodIds.add(objPeriod.Id);
        }   
        List<LoAp_BookExportRequestCtrlr.tab> lstRecords = new List<LoAp_BookExportRequestCtrlr.tab>();
        
        System.runAs(objUser){
            Test.startTest();           
            lstRecords = LoAp_BookExportRequestCtrlr.retrieveTabRecords(periodIds,lstBatchRequestQueue[0].Id);
            Test.stopTest();
        }
        System.assert(lstRecords != null); 
    }  
}