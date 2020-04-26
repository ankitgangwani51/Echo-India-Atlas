/******************************************************************************
@author:      Echo: Hasan Faisal
@date:        08-06-2018  
@description: Test Class for GlAp_SelectBookCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class GlAp_SelectBookCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'hasan';
    private static final String USER_LNAME = 'faisal';
    
    private static final Boolean IS_USER_NOTIFY = true;
    private static final String USER_NOTIFY = 'hasanfaisal@echo-ms.com';
    private static final String RELATED_LIST = 'RelatedListDetails';
    private static final String SUPPLYPOINTUSAGE = 'Supply Point usages';
    private static final String ZIPCODE = 'WS2 8DE';
    private static final String MEASURED = 'Yes';
    private static final String screenName1 = 'BookExport';
    private static final String screenName2 = 'Book';
    private static final String MONTHLY = 'Monthly';
    private static final String Quarterly;
    private static final String AREA_NAME = 'Test Area';
    private static final String AREA_NAME1;
    private static final String DEPOT_NAME1 = 'Test Depot1'; 
    private static final String DEPOT_NAME2 = 'Test Depot2';
    private static final String DEPOT_NAME3 = 'Test Depot3';
    private static final String READTIMETABLE = 'Read TimeTable';  
    private static final String READTIMETABLE1 = 'New Read TimeTable'; 
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date ESTIMATION = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    
   /******************************************************************************
   @author:      Echo: hasan
   @date:        08-06-2018  
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
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME1);
        objDepot .Area__c = objArea.Id;        
        Database.insert(objDepot);
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE,MONTHLY);        
        Database.insert(objReadTimetable);  
        
        // Create ReadPeriod Record 
        ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimetable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        Database.insert(objReadPeriod); 
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable); 
        objBook.ReadFrequency__c = MONTHLY;
        Database.insert(objBook);
        
        // Create ReadingMode Record
        ReadingMode__c objReadingMode = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);
        Database.insert(objReadingMode);
        
        // Create Depot Record
        Depot__c objDepotNew = GlUt_FactoryData_Test.createDepot(DEPOT_NAME2);
        objDepotNew .Area__c = objArea.Id;        
        Database.insert(objDepotNew);
        
        // Create Book Record
        Book__c objBookNew = GlUt_FactoryData_Test.createBook(objDepotNew, objReadTimeTable);
        
        Database.insert(objBookNew);
        
        // Create ReadingMode Record
        ReadingMode__c objReadingModeNew = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBookNew, objDepotNew, objArea);
        objReadingModeNew.EstimateDate__c = ESTIMATION;
        Database.insert(objReadingModeNew);
        
        // Create Depot Record
        Depot__c objDepotNew1 = GlUt_FactoryData_Test.createDepot(DEPOT_NAME3);
        objDepotNew1 .Area__c = objArea.Id;        
        Database.insert(objDepotNew1);
        
        // Create Book Record
        Book__c objBookNew1 = GlUt_FactoryData_Test.createBook(objDepotNew1, objReadTimeTable);
        objBookNew1.Depot__c=objDepotNew1.Id;
        Database.insert(objBookNew1);
        
        // Create ReadingMode Record
        ReadingMode__c objReadingModeNew1 = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBookNew, objDepotNew, objArea);
        
        Database.insert(objReadingModeNew1);
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable1 = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE,Quarterly);        
        Database.insert(objReadTimetable1, false);  
        
        //Create Location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);        
        Database.insert(objLocation);
        
        // Create SupplyPointUsageType Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SUPPLYPOINTUSAGE);        
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation,objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
        objSupplyPoint.Book__c = objBook.Id;
        objSupplyPoint.Depot__c = objDepot.Id;  
        Database.insert(objSupplyPoint);
    }
    
    /******************************************************************************
    @author:      Echo: hasan
    @date:        08-06-2018  
    @description: Test Method 
    *******************************************************************************/
    static testmethod void getBooks_Positive(){
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<ReadPeriod__c> readPeriod = [select id from ReadPeriod__c LIMIT 1];
        List<id> periodId = new List<id>();
        for(ReadPeriod__c rp: readPeriod){
            periodId.add(rp.Id);
        }
        List<BlAp_CombinedRecord> cmbRecords = new List<BlAp_CombinedRecord>();
        try {
            System.runAs(objUser){
                Test.startTest();
                cmbRecords = GlAp_SelectBookCtrlr.getBooks(periodId, screenName1); 
                cmbRecords = GlAp_SelectBookCtrlr.getBooks(periodId, screenName2); 
                cmbRecords = GlAp_SelectBookCtrlr.getBooks(null, null); 
                Test.stopTest();
                System.assert(cmbRecords.size() == 0);
            } 
        } catch(Exception e) {
            
        }
    }
    /*******************************************************************
    Purpose: Method to test scenario for retrieveBookFieldPropDetails method
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void retrieveBookFieldPropDetails_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<GLAp_FieldProps>  fldPropList = new List<GLAp_FieldProps>();  
        System.runAs(objUser){
            Test.startTest();
            fldPropList = GlAp_SelectBookCtrlr.retrieveBookPropDetails();
            Test.stopTest();
        }
        System.assert(fldPropList.size() > 0);
    }
    
    /*******************************************************************
    Purpose: Method to test scenario for getInfoToDisplay method
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void getInfoToDisplay_Positive()
    {            
        User objUser =[select Id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<ReadPeriod__c> readPeriod = [select id from ReadPeriod__c LIMIT 1];
        List<id> periodId = new List<id>();
        for(ReadPeriod__c rp: readPeriod){
            periodId.add(rp.Id);
        }
        GlAp_SelectBookCtrlr.ContainerWrapper resultContainer = new GlAp_SelectBookCtrlr.ContainerWrapper();  
        System.runAs(objUser){
            try {
            Test.startTest();
                resultContainer = GlAp_SelectBookCtrlr.getInfoToDisplay( periodId, screenName1);
                Test.stopTest();
                System.assert(resultContainer.fieldPropList.size() > 0);
            } catch(Exception ex) {}
        }
    }
}