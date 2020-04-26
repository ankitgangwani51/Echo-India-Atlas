/******************************************************************************
@author         Ankit Gangwani
@date           07 DEC 2017
@description    Test Class For DrUI_RecordSelectionComponentCtrlr
@revision	  :	Echo: Sudhir Kumar - AT-3995: Naming Convention for DrUI_RecordSelectionComponent (Security Review)
								   - Updated controller name from DrUI_RecordSelectionCtrlr to DrUI_RecordSelectionComponentCtrlr
*******************************************************************************/
@isTest
public class DrUI_RecordSelectionComponentCtrlr_Test {
   
    private static final String USER_PROFILE 			='System Administrator';
    private static final String USER_NAME 				='FN123LN123'; 
    private static final String USER_FNAME				= 'FN123';	
    private static final String USER_LNAME				= 'LN123';
    private static final String ACCOUNT_NAME 			= 'Test Account';
    private static final String CONTRACT_NAME    		= 'Test Contract';
    private static final String DEBT_RECOVERY_PROFILE	= 'Profile 1';
    private static final String CURRENT_STAGE           = 'Payment Due';
    private static final Decimal TOTAL_AMOUNT_DUE       = 125;
    private static Integer RESULT_LIMIT           		= 2000;
    private static String CRON_EXPRESSION               = '';
    private static String REPORT_TYPE                   = 'immediate';
    private static String sMode                         = 'predict';
    
    /****************************************************************************** 
    @author        Ankit Gangwani 
    @date          07 DEC 2017   
    @return        Void   
    @description   Setup Method for Initialize Data in DebtRecoveryProcess__c Object 
    for Unit Testing
    *******************************************************************************/
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount); 
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
        
        //Create Debt Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract);
        objDebtRecProcess.DebtRecoveryProfile__c = DEBT_RECOVERY_PROFILE;
        objDebtRecProcess.CurrentStage__c = CURRENT_STAGE;
        objDebtRecProcess.CurrentStageDateTime__c = system.today();
        //objDebtRecProcess.TotalAmountDue__c = TOTAL_AMOUNT_DUE; --AT-3430
        Database.insert(objDebtRecProcess);
    }
    
    /*****************************************************************************
    @author        Ankit Gangwani    
    @date          07 DEC 2017       
    @return        Void   
    @description   Method To test Predict/Evaluate checkbox update scenario 
    *******************************************************************************/     
    static testmethod void TestEvaluateMethod(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        DebtRecoveryProcess__c objDRPId = [SELECT Id, DebtRecoveryProfile__c, CurrentStage__c,CurrentStageDateTime__c,TotalAmountDue__c
                                            FROM DebtRecoveryProcess__c LIMIT 1];       
        
        System.runAs(objUser[0]){
            Test.starttest();
            Boolean immediatePredictReport = DrUI_RecordSelectionComponentCtrlr.callingBatchOrSchedule(objDRPId.DebtRecoveryProfile__c,
                                                                                              objDRPId.CurrentStage__c,                                                                                         
                                                                                              String.valueOfGmt(objDRPId.CurrentStageDateTime__c),
                                                                                              objDRPId.TotalAmountDue__c,
                                                                                              RESULT_LIMIT,
                                                                                              CRON_EXPRESSION,
                                                                                              REPORT_TYPE,
                                                                                              sMode);
            sMode = 'evaluate';            
            Boolean immediateEvaluateReport = DrUI_RecordSelectionComponentCtrlr.callingBatchOrSchedule(objDRPId.DebtRecoveryProfile__c,
                                                                                               objDRPId.CurrentStage__c,                                                                                         
                                                                                               String.valueOfGmt(objDRPId.CurrentStageDateTime__c),
                                                                                               objDRPId.TotalAmountDue__c,                                                                                                                                      
                                                                                               RESULT_LIMIT,
                                                                                               CRON_EXPRESSION,
                                                                                               REPORT_TYPE,
                                                                                               sMode);
            REPORT_TYPE = 'daily';
            CRON_EXPRESSION = '0 0 12 * * ?';
            RESULT_LIMIT = null;
            Boolean evaluateDailyReport = DrUI_RecordSelectionComponentCtrlr.callingBatchOrSchedule(objDRPId.DebtRecoveryProfile__c,
                                                                                           objDRPId.CurrentStage__c,                                                                                         
                                                                                           String.valueOfGmt(objDRPId.CurrentStageDateTime__c),
                                                                                           objDRPId.TotalAmountDue__c,                                                                                                                                                
                                                                                           RESULT_LIMIT,
                                                                                           CRON_EXPRESSION,
                                                                                           REPORT_TYPE,
                                                                                           sMode);
            
            Boolean evaluateDailyDuplicateReport = DrUI_RecordSelectionComponentCtrlr.callingBatchOrSchedule(objDRPId.DebtRecoveryProfile__c,
                                                                                                             objDRPId.CurrentStage__c,                                                                                         
                                                                                                             String.valueOfGmt(objDRPId.CurrentStageDateTime__c),
                                                                                                             objDRPId.TotalAmountDue__c,                                                                                                                                                
                                                                                                             RESULT_LIMIT,
                                                                                                             CRON_EXPRESSION,
                                                                                                             REPORT_TYPE,
                                                                                                             sMode);
            
            Test.stopTest();
            
            //Return false if batch run/schedule successfully
            System.assertEquals(immediatePredictReport, false);            
            System.assertEquals(immediateEvaluateReport, false);
            System.assertEquals(evaluateDailyReport, false);
            
            //Return true if same criteria of report has been scheduled already
            System.assertEquals(evaluateDailyDuplicateReport, true);
        }
    }
}