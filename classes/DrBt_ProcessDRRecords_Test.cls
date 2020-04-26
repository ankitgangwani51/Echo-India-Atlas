/******************************************************************************
@author         Neha Rajput
@date           27 Nov 2017
@description    Test Class For DrBt_ProcessInstalments
@revision:    08-Mar-2018 MT - Use the field from constant class
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class DrBt_ProcessDRRecords_Test {
    
    static final Integer ITOTREC = 20;    
    static final String sQuery = 'Select ' + GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEAPINAME + ',' + GlUt_APIConstantsDebtRecoveryProcess.EVALUATEFORDEBTRECOVERYAPINAME + ',' +
                                  GlUt_APIConstantsDebtRecoveryProcess.PREDICTFORDEBTRECOVERYAPINAME + ',' + GlUt_APIConstantsDebtRecoveryProcess.PREDICTSTAGEAPINAME + ',' +
                                  GlUt_APIConstantsDebtRecoveryProcess.CONTRACTAPINAME +
                                 ' From ' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROCESSAPINAME + 
                                 ' Where (' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROFILEAPINAME +  ' = \'Profile 1\' ' +
                                   'And ' + GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEAPINAME + ' = \'Reminder 1\' '+
                                   'And ' + GlUt_APIConstantsDebtRecoveryProcess.TOTALAMOUNTDUEAPINAME + ' = 1000 )';
    static String sMode;
    
    /******************************************************************************
    @author        Neha Rajput 
    @date          27 Nov 2017   
    @param         -
    @return        Void   
    @description   Setup Method for Initialize Data in DebtRecoveryProcess__c Object 
                   for Unit Testing
    *******************************************************************************/ 
    @testSetup
    static void SetUp()
    {
        List<DebtRecoveryProcess__c> DRP = new List<DebtRecoveryProcess__c>();
        Integer iCount;           
         
        for(iCount = 0; iCount < ITOTREC ; iCount++){            
            DebtRecoveryProcess__c NewDRP = new DebtRecoveryProcess__c();             
            NewDRP.DebtRecoveryProfile__c = 'Profile 1';
            NewDRP.CurrentStage__c = 'Reminder 1';
            //NewDRP.TotalAmountDue__c = 1000 ;    --AT-3430
            DRP.add(NewDRP);
        }   
        insert(DRP);          
    }
    
    /******************************************************************************
    @author        Neha Rajput 
    @date          27 Nov 2017   
    @param         -
    @return        Void   
    @description   Method To test Predict checkbox update scenario 
    *******************************************************************************/ 
    @isTest
    static void TestPredictMethod()
    {
        sMode = 'Predict';        
        Id batchId = runBatchJob();   
        System.assert(batchId != null);
    }
    
    /******************************************************************************
    @author        Neha Rajput 
    @date          27 Nov 2017   
    @param         
    @return        Void   
    @description   Method To test Evaluate checkbox update scenario 
    *******************************************************************************/ 
    @isTest
    static void TestEvaluateMethod()
    {
        sMode = 'Evaluate';  
        Id batchId = runBatchJob();   
        System.assert(batchId != null);
    }
    
    /******************************************************************************
    @author        Neha Rajput 
    @date          27 Nov 2017   
    @param         
    @return        Void   
    @description   Method Run DrBt_ProcessInstalments batch job 
    *******************************************************************************/
    private static Id runBatchJob()
    {
        DrBt_ProcessDRRecords DRPBatchObject = new DrBt_ProcessDRRecords(sQuery,sMode,100);
        return Database.executeBatch(DRPBatchObject);
    } 
    
    /******************************************************************************
    @author        Neha Rajput 
    @date          27 Nov 2017   
    @param         -
    @return        Void   
    @description   Method To test Predict checkbox update scenario by scedulable 
                   batch job
    *******************************************************************************/ 
    @isTest
    static void TestPredictScheduleMethod()
    {
        sMode = 'Predict';        
        String jobID = runScheduleJob('Test Predict Schedule Job'); 
        System.assert(jobID != null);
    }
    
    /******************************************************************************
    @author        Neha Rajput 
    @date          27 Nov 2017   
    @param         
    @return        Void   
    @description   Method To test Evaluate checkbox update scenario by scedulable 
                   batch job
    *******************************************************************************/ 
    @isTest
    static void TestEvaluateScheduleMethod()
    {
        sMode = 'Evaluate';  
        String jobID = runScheduleJob('Test Evaluate Schedule Job');               
        System.assert(jobID != null);
    }
     
    /******************************************************************************
    @author        Neha Rajput 
    @date          27 Nov 2017   
    @param         
    @return        Void   
    @description   Method Run DrBt_ProcessInstalments Schedule job 
    *******************************************************************************/
    private static String runScheduleJob(String SchedulerName)
    {
        system.debug('sQuery+++++ ' + sQuery);
        DrBt_ProcessDRRecords DRPBatchObject = new DrBt_ProcessDRRecords(sQuery,sMode,100);
        
        // update CronExp Accordingly....
        String sCronExp =  '0 05 * * * ?' ; 
        return System.schedule(SchedulerName, sCronExp, DRPBatchObject);
    }   
    
}