/******************************************************************************
@author:      Echo: Swati
@date:        04-06-2018
@description: Test Class for LoAp_ReadTimetableMaintenanceCtrlr
*******************************************************************************/
@isTest
public class LoAp_ReadTimetableMaintenanceCtrlr_Test {
    
    //Variable declaration start    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static final String MONTHLY = 'Monthly';
    private static final String AREA_SECTION_NAME = 'Area';
    private static final String BOOK_SECTION_NAME = 'Book';
    private static final String DEPOT_SECTION_NAME = 'Depot';
    private static final String AREA_NAME = 'Test Area';
    private static final String DEPOT_NAME = 'Test Depot'; 
    private static final String READTIMETABLE = 'Read TimeTable';
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    private static final String AREA_NAME_1 = 'East';
    private static final String DEPOT_NAME_1 = 'Leeds';
    private static final String BOOK_NAME = 'Book1';
    private static final String MODE_ESTIMATE = 'Estimate';
    private static final String MODE_ACTUAL = 'Actual';
        
    //Variable declaration end

/******************************************************************************
@author:    Echo: Swati
@date:      04-06-2018 
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE,MONTHLY);        
        Database.insert(objReadTimetable);  
        
        // Create ReadPeriod Record 
        ReadPeriod__c objReadPeriod = GlUt_FactoryData_Test.createReadPeriod(objReadTimetable, READ_START_DATE, READ_END_DATE, BILL_PERIOD_STARTDATE, BILL_PERIOD_ENDDATE);
        Database.insert(objReadPeriod);
        
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);
        objDepot .Area__c = objArea.Id;        
        Database.insert(objDepot);
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable);        
        Database.insert(objBook);
        
        // Create ReadingMode Record
        List<ReadingMode__c> lstReadingMode = new List<ReadingMode__c>();
        ReadingMode__c objReadingMode1 = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);       
        objReadingMode1.Book__c = null;
        objReadingMode1.Depot__c = null;
        lstReadingMode.add(objReadingMode1);        
        
        ReadingMode__c objReadingMode2 = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);
        objReadingMode2.Book__c = null;
        objReadingMode2.Area__c = null;
        lstReadingMode.add(objReadingMode2);
        
        ReadingMode__c objReadingMode3 = GlUt_FactoryData_Test.createReadingMode(objReadPeriod, objBook, objDepot, objArea);
        objReadingMode3.Depot__c = null;
        objReadingMode3.Area__c = null;
        lstReadingMode.add(objReadingMode3);        
        
        Database.insert(lstReadingMode);
            
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveFieldPropDetails() method 
    *******************************************************************************/    
    static testmethod void retrieveFieldPropDetailsArea_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = LoAp_ReadTimetableMaintenanceCtrlr.retrieveFieldPropDetails(AREA_SECTION_NAME);            
            Test.stopTest();
            System.assertNotEquals(lstFieldProps.size(), 0);                     
        }
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveFieldPropDetails() method 
    *******************************************************************************/    
    static testmethod void retrieveFieldPropDetailsDepot_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = LoAp_ReadTimetableMaintenanceCtrlr.retrieveFieldPropDetails(DEPOT_SECTION_NAME);            
            Test.stopTest();
            System.assertNotEquals(lstFieldProps.size(), 0);                     
        }
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveFieldPropDetails() method 
    *******************************************************************************/    
    static testmethod void retrieveFieldPropDetailsBook_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = LoAp_ReadTimetableMaintenanceCtrlr.retrieveFieldPropDetails(BOOK_SECTION_NAME);            
            Test.stopTest();
            System.assertNotEquals(lstFieldProps.size(), 0);                     
        }
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveRecords() method 
    *******************************************************************************/    
    static testmethod void getReadingModeRecords_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadPeriod__c objReadPeriod  = [Select id,name from ReadPeriod__c];        
        //Run test class in user context
        System.runAs(objUser){ 
            try {
                Test.startTest();
                LoAp_ReadTimetableMaintenanceCtrlr.ContainerWrapper resultContainer = LoAp_ReadTimetableMaintenanceCtrlr.getReadingModeRecords(objReadPeriod.Id);            
                Test.stopTest();
                System.assertNotEquals(resultContainer.areaRecordList.size(), 0);
                System.assertNotEquals(resultContainer.depotRecordList.size(), 0);
                System.assertNotEquals(resultContainer.bookRecordList.size(), 0);
          } catch(Exception ex) {}            
        }
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveRecords() method 
    *******************************************************************************/    
    static testmethod void getReadingModeRecords_Negative(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadPeriod__c objReadPeriod  = [Select id,name from ReadPeriod__c];        
        //Run test class in user context
        System.runAs(objUser){ 
            try {
                Test.startTest();
                LoAp_ReadTimetableMaintenanceCtrlr.ContainerWrapper resultContainer = LoAp_ReadTimetableMaintenanceCtrlr.getReadingModeRecords(objUser.Id);            
                Test.stopTest();
                System.assertEquals(resultContainer.areaRecordList.size(), 0);
                System.assertEquals(resultContainer.depotRecordList.size(), 0);
                System.assertEquals(resultContainer.bookRecordList.size(), 0);
          } catch(Exception ex) {}            
        }
    }    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveRecords() method 
    *******************************************************************************/    
    static testmethod void blankRow_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadPeriod__c objReadPeriod  = [Select id,name from ReadPeriod__c];        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            BlAp_CombinedRecord areaRecord = LoAp_ReadTimetableMaintenanceCtrlr.blankRow(objReadPeriod.Id,AREA_SECTION_NAME); 
            BlAp_CombinedRecord depotRecord = LoAp_ReadTimetableMaintenanceCtrlr.blankRow(objReadPeriod.Id,DEPOT_SECTION_NAME); 
            BlAp_CombinedRecord bookRecord = LoAp_ReadTimetableMaintenanceCtrlr.blankRow(objReadPeriod.Id,BOOK_SECTION_NAME);            
            Test.stopTest();
            System.assertNotEquals(areaRecord, null);  
            System.assertNotEquals(depotRecord, null); 
            System.assertNotEquals(bookRecord, null); 
                          
        }
    }
     
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveRecords() method 
    *******************************************************************************/    
    static testmethod void doSave_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadPeriod__c objReadPeriod  = [Select id,name from ReadPeriod__c];
        List<ReadingMode__c> lstReadingMode  = [Select id,name from ReadingMode__c where ReadPeriod__c = :objReadPeriod.Id]; 

        ReadingMode__c objReadingMode = new ReadingMode__c();
        objReadingMode.ReadPeriod__c = objReadPeriod.Id;
        objReadingMode.Mode__c = MODE_ESTIMATE;
        objReadingMode.EstimateDate__c = Date.valueOf('2018-06-05');
        ReadingMode__c objReadingMode2 = new ReadingMode__c();
        objReadingMode2.ReadPeriod__c = objReadPeriod.Id;
        objReadingMode2.Mode__c = MODE_ACTUAL;
        Area__c objArea = new Area__c();
        objArea.Name = AREA_NAME_1;
        Depot__c objDepot = new Depot__c();
        objDepot.Name = DEPOT_NAME_1;
        Book__c objBook = new Book__c();
        objBook.Name = BOOK_NAME;
        
        List<BlAp_CombinedRecord> recordList = new List<BlAp_CombinedRecord>();
        BlAp_CombinedRecord rec1 = new BlAp_CombinedRecord();
        rec1.uniqueId = null;
        rec1.isSelected = false;
        rec1.readOnlyFields = new Map<String, Boolean>();   
        rec1.readOnlyFields.put(GlUt_APIConstantsReadingMode.ESTIMATEDATEFIELDREFERENCE,false);
        rec1.objectMap = new Map<String, sObject>();
        rec1.objectMap.put(GlUt_APIConstantsArea.AREAAPINAME, objArea);
        rec1.objectMap.put(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,objReadingMode);
        recordList.add(rec1);
        
        BlAp_CombinedRecord rec2 = new BlAp_CombinedRecord();
        rec2.uniqueId = null;
        rec2.isSelected = false;
        rec2.readOnlyFields = new Map<String, Boolean>();   
        rec2.readOnlyFields.put(GlUt_APIConstantsReadingMode.ESTIMATEDATEFIELDREFERENCE,false);
        rec2.objectMap = new Map<String, sObject>();
        rec2.objectMap.put(GlUt_APIConstantsDepot.DEPOTAPINAME, objDepot);
        rec2.objectMap.put(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,objReadingMode);
        recordList.add(rec2);
        
        BlAp_CombinedRecord rec3 = new BlAp_CombinedRecord();
        rec3.uniqueId = null;
        rec3.isSelected = false;
        rec3.readOnlyFields = new Map<String, Boolean>();   
        rec3.readOnlyFields.put(GlUt_APIConstantsReadingMode.ESTIMATEDATEFIELDREFERENCE,false);
        rec3.objectMap = new Map<String, sObject>();
        rec3.objectMap.put(GlUt_APIConstantsBook.BOOKAPINAME,objBook);
        rec3.objectMap.put(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,objReadingMode2);
        recordList.add(rec3);
                
        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            LoAp_ReadTimetableMaintenanceCtrlr.doSave(System.JSON.serialize(recordList)); 
            
            List<ReadingMode__c> lstReadingMode2  = [Select id,name from ReadingMode__c where ReadPeriod__c = :objReadPeriod.Id]; 
            System.assertNotEquals(lstReadingMode, lstReadingMode2);  
            Test.stopTest();                          
        }
        
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for doSave() method 
    *******************************************************************************/
        static testmethod void doSave_Negative(){ 
        boolean isException;
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        BlAp_CombinedRecord obj = new BlAp_CombinedRecord();
        String stringJson = JSON.serialize(obj); 
        
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();           
                LoAp_ReadTimetableMaintenanceCtrlr.doSave(stringJson); 
            }catch(Exception e)
            {
                isException = true;            
            }
            Test.stopTest();
        }
        System.assert(isException == true);
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      15-06-2018
    @description: Test method for deleteRecord method 
    *******************************************************************************/
        static testmethod void deleteRecord_Positive(){ 
        boolean isException;
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadingMode__c objReadingMode  = [Select id,name from ReadingMode__c limit 1];   
        Id readingModeId = objReadingMode.Id;
            
        //Run test class in user context
        System.runAs(objUser){            
            Test.startTest();           
            LoAp_ReadTimetableMaintenanceCtrlr.deleteRecord(readingModeId); 
            List<ReadingMode__c> lstReadingMode  = [Select id,name from ReadingMode__c where Id = :readingModeId]; 
            System.assertEquals(lstReadingMode.size(), 0);  
            Test.stopTest();
        }       
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      15-06-2018
    @description: Test method for deleteRecord method 
    *******************************************************************************/
        static testmethod void deleteRecord_Negative(){ 
        boolean isException;
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadingMode__c objReadingMode  = [Select id,name from ReadingMode__c limit 1];   
        Id readingModeId = objReadingMode.Id;
            
        //Run test class in user context
        System.runAs(objUser){            
            Test.startTest();           
            LoAp_ReadTimetableMaintenanceCtrlr.deleteRecord(objUser.Id); 
            List<ReadingMode__c> lstReadingMode  = [Select id,name from ReadingMode__c where Id = :readingModeId]; 
            System.assertEquals(lstReadingMode.size(), 1);  
            Test.stopTest();
        }       
    }

}