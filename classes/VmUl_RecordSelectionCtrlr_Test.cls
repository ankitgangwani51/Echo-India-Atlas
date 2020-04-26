/******************************************************************************
@author         Ankit Gangwani
@date           07 DEC 2017
@description    Test Class For VmUl_RecordSelectionCtrlr
*******************************************************************************/
@isTest
public class VmUl_RecordSelectionCtrlr_Test {
    
    private static final String USER_PROFILE 			='System Administrator';
    private static final String USER_NAME 				='FN123LN123';  
    private static final String USER_FNAME				= 'FN123';	
    private static final String USER_LNAME				= 'LN123'; 
    private static final String LOCATION_NAME 			='A99 9AA';
    private static final String LOCATION_SUB_TYPE 		= 'Detached';
    private static final String STREET 					= 'teststreet';
    private static final String VOID_MANAGEMENT_PROFILE	= 'HH Void Management Profile';
    private static final String CURRENT_STAGE           = 'Stage 1';
    private static final DateTime CURRENT_STAGE_DATE_TIME = system.today();
    private static final Integer RESULT_LIMIT           = 2000;
    private static String CRON_EXPRESSION               = '';
    private static String REPORT_TYPE                   = 'immediate';
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          07 DEC 2017   
    @return        Void   
    @description   Setup Method for Initialize Data in VoidManagementProcess__c Object 
    for Unit Testing
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Location record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Void Management Process record
        VoidManagementProcess__c objVoidMgtProcess = GlUt_FactoryData_Test.createVoidManagementProcess(objLocation);
        objVoidMgtProcess.VoidManagementProfile__c = VOID_MANAGEMENT_PROFILE;   
        objVoidMgtProcess.CurrentStage__c = CURRENT_STAGE;
        objVoidMgtProcess.CurrentStageDateTime__c = system.today();
        Database.insert(objVoidMgtProcess);        
    }
    
    /******************************************************************************
    @author        Ankit Gangwani    
    @date          07 DEC 2017       
    @return        Void   
    @description   Method To test Evaluate checkbox update scenario 
    *******************************************************************************/     
    static testmethod void TestEvaluateMethod(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        VoidManagementProcess__c objVMId = [SELECT Id,VoidManagementProfile__c,CurrentStage__c,CurrentStageDateTime__c FROM VoidManagementProcess__c LIMIT 1];       
        
        System.runAs(objUser[0]){
            Test.starttest();
            Boolean immediateReport = VmUl_RecordSelectionCtrlr.callingBatchEvaluateMode(objVMId.VoidManagementProfile__c,
                                                                                         objVMId.CurrentStage__c,
                                                                                         String.valueOfGmt(objVMId.CurrentStageDateTime__c),
                                                                                         RESULT_LIMIT,
                                                                                         CRON_EXPRESSION,
                                                                                         REPORT_TYPE);
            
            REPORT_TYPE = 'daily';
            CRON_EXPRESSION = '0 0 12 * * ?';
            Boolean dailyReport = VmUl_RecordSelectionCtrlr.callingBatchEvaluateMode(objVMId.VoidManagementProfile__c,
                                                                                     objVMId.CurrentStage__c,
                                                                                     String.valueOfGmt(objVMId.CurrentStageDateTime__c),
                                                                                     RESULT_LIMIT,
                                                                                     CRON_EXPRESSION,
                                                                                     REPORT_TYPE);
            
            Boolean dailyDuplicateReport = VmUl_RecordSelectionCtrlr.callingBatchEvaluateMode(objVMId.VoidManagementProfile__c,
                                                                                              objVMId.CurrentStage__c,
                                                                                              String.valueOfGmt(objVMId.CurrentStageDateTime__c),
                                                                                              RESULT_LIMIT,
                                                                                              CRON_EXPRESSION,
                                                                                              REPORT_TYPE);
            
            Test.stopTest();
            //Return false if batch run/schedule successfully
            System.assertEquals(immediateReport, false);
            System.assertEquals(dailyReport, false);
            
            //Return true if same criteria of report has been scheduled already
            System.assertEquals(dailyDuplicateReport, true);
        }
    }
}