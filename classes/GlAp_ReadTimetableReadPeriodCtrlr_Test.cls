/******************************************************************************
@author:      Echo: Swati
@date:        04-06-2018
@description: Test Class for GlAp_ReadTimetableReadPeriodCtrlr
*******************************************************************************/
@isTest
public class GlAp_ReadTimetableReadPeriodCtrlr_Test {
    
    //Variable declaration start    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static final String MONTHLY = 'Monthly';
    private static final String READTIMETABLE = 'Read TimeTable';
    private static final Date READ_START_DATE = date.valueOf('2018-02-15');
    private static final Date READ_END_DATE = date.valueOf('2018-03-01');
    private static final Date BILL_PERIOD_STARTDATE = date.valueOf('2018-02-01');
    private static final Date BILL_PERIOD_ENDDATE = date.valueOf('2018-03-01');
    
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
        
            
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveFieldPropDetails() method 
    *******************************************************************************/    
    static testmethod void retrieveFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = GlAp_ReadTimetableReadPeriodCtrlr.retrieveFieldPropDetails();            
            Test.stopTest();
            
            System.assertNotEquals(lstFieldProps.size(), 0);                     
        }
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveRecords() method 
    *******************************************************************************/    
    static testmethod void retrieveRecords_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<BlAp_CombinedRecord> records = GlAp_ReadTimetableReadPeriodCtrlr.retrieveRecords();            
            Test.stopTest();
            
            System.assertNotEquals(records.size(), 0);                     
        }
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveRecords() method 
    *******************************************************************************/    
    static testmethod void retrieveReadPeriodFieldPropDetails_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = GlAp_ReadTimetableReadPeriodCtrlr.retrieveReadPeriodFieldPropDetails();            
            Test.stopTest();
            
            System.assertNotEquals(lstFieldProps.size(), 0);                     
        }
    }
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveReadPeriodRecords() method 
    *******************************************************************************/    
    static testmethod void retrieveReadPeriodRecords_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadTimetable__c objReadTimetable  = [Select id,name from ReadTimetable__c];
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<BlAp_CombinedRecord> records = GlAp_ReadTimetableReadPeriodCtrlr.retrieveReadPeriodRecords(objReadTimetable.Id);            
            Test.stopTest();
            
            System.assertNotEquals(records.size(), 0);                     
        }
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018
    @description: Test method for retrieveReadPeriodRecords() method
    *******************************************************************************/    
    static testmethod void retrieveReadPeriodRecords_Negative(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        ReadTimetable__c objReadTimetable  = [Select id,name from ReadTimetable__c];
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<BlAp_CombinedRecord> records = GlAp_ReadTimetableReadPeriodCtrlr.retrieveReadPeriodRecords(objUser.Id);            
            Test.stopTest();
            
            System.assertEquals(records.size(), 0);                     
        }
    }

}