/******************************************************************************
@author         Ankit Gangwani
@date           05 June 2018
@description    Test Class For GlBt_ScheduleBatchRequest
*******************************************************************************/
@isTest
public class GlBt_ScheduleBatchRequest_Test {
    
    private static final String USER_PROFILE 			= 'System Administrator';
    private static final String USER_NAME 				= 'FN123LN123'; 
    private static final String USER_FNAME				= 'FN123';	
    private static final String USER_LNAME				= 'LN123';
    private static final String BATCH_CLASS      	 	= 'LoBt_ScheduleEstimates';
    private static final String JOBNAME					= 'Schedule Batch Object';
    private static final String CRON					= '0 0 12 * * ?';
    private static final String DUMMYDATA				= 'Test';
    
    /******************************************************************************
    @author        Ankit Gangwani
    @date          05 June 2018 
    @param         -
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Batch Class record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS);
        Database.insert(objBatchProcess);
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void positiveCreateBRQ(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        BatchProcess__c objBatchProcess = [SELECT Id, BatchClass__c FROM BatchProcess__c LIMIT 1];       
        System.runAs(objUser[0]){
            Test.starttest();
            GlBt_ScheduleBatchRequest schBatchObj = new GlBt_ScheduleBatchRequest(objBatchProcess.BatchClass__c);
            String jobID = System.schedule(JOBNAME, CRON, schBatchObj);                 
            Test.stoptest();
            List<BatchRequestQueue__c> objBRQ = [SELECT Id FROM BatchRequestQueue__c];
            System.assert(objBRQ.size() > 0);
        }
    }
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          05 June 2018
    @return        Void   
    *******************************************************************************/     
    static testmethod void negativeCreateBRQ(){
        
        Boolean isException;
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            try{
                Test.starttest();
                GlBt_ScheduleBatchRequest schBatchObj = new GlBt_ScheduleBatchRequest(DUMMYDATA);
                String jobID = System.schedule(JOBNAME, CRON, schBatchObj);                 
                Test.stoptest();                
            } catch (exception e){
                isException = true;
                System.assertEquals(isException,true);
            }
        }
    }
}