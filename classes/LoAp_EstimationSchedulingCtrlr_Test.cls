/******************************************************************************
@author         Ankit Gangwani
@date           11 June 2018
@description    Test Class For LoAp_EstimationSchedulingCtrlr
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class LoAp_EstimationSchedulingCtrlr_Test {
    
    private static final String USER_PROFILE 			= 'System Administrator';
    private static final String USER_NAME 				= 'FN123LN123'; 
    private static final String USER_FNAME				= 'FN123';	
    private static final String USER_LNAME				= 'LN123';
    private static final String cronTrigger				= '0 0 12 1/1 * ? *';
    private static final String SCHEDULE_ESTIMATE		= 'Schedule Estimate';
    private static final String SCHEDULE_ESTIMATES		= 'Schedule Estimates';    
    private static final String SWEEP_UP_ESTIMATE		= 'Sweep Up Estimate';
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        11 June 2018
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData(){  
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null); 
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        // Create Batch Process Record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(System.Label.LoBt_ScheduledEstimatesLabel);
        //objBatchProcess.Operation__c = LoAp_Constants.BATCHPROCESSOPERATION;
        Database.insert(objBatchProcess);
        
        // Create Batch Process Record
        BatchProcess__c objBatchProcess2 = GlUt_FactoryData_Test.createBatchProcess(System.Label.LoBt_SweepUpEstimatesLabel);
        Database.insert(objBatchProcess2);
        
        // Schedule Job
        GlBt_ScheduleBatchRequest myBatchObject = new GlBt_ScheduleBatchRequest(SCHEDULE_ESTIMATES);
        System.schedule(SCHEDULE_ESTIMATES, cronTrigger, myBatchObject);
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani 
    @date:        11 June 2018     
	@description: startScheduleJobs_SCHEDULE_ESTIMATE 
	*******************************************************************************/
    static testmethod void startScheduleJobs_SCHEDULE_ESTIMATE(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            LoAp_EstimationSchedulingCtrlr.startScheduleJobs(SCHEDULE_ESTIMATE, cronTrigger);
            Test.stoptest();
            List<BatchRequestQueue__c> objBRQ = [SELECT Id FROM BatchRequestQueue__c];
            System.assert(objBRQ.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani  
    @date:        11 June 2018     
	@description: startScheduleJobs_SWEEP_UP_ESTIMATE 
	*******************************************************************************/
    static testmethod void startScheduleJobs_SWEEP_UP_ESTIMATE(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            LoAp_EstimationSchedulingCtrlr.startScheduleJobs(SWEEP_UP_ESTIMATE, cronTrigger);
            Test.stoptest();
            List<BatchRequestQueue__c> objBRQ = [SELECT Id FROM BatchRequestQueue__c];
            System.assert(objBRQ.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani  
    @date:        11 June 2018    
	@description: retrieveScheduleJobs 
	*******************************************************************************/
    static testmethod void retrieveScheduleJobs(){
        Map<String,String> mapOftimeZoneConvertMap = new Map<String,String>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            mapOftimeZoneConvertMap = LoAp_EstimationSchedulingCtrlr.retrieveScheduleJobs(SCHEDULE_ESTIMATES);
            Test.stoptest();
            System.assert(mapOftimeZoneConvertMap.size() > 0);
        }
    }    
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani 
    @date:        11 June 2018  
	@description: stopScheduleJobs 
	*******************************************************************************/ 
    static testmethod void stopScheduleJobs(){
        Map<String,String> mapOftimeZoneConvertMap = new Map<String,String>();
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        System.runAs(objUser[0]){
            Test.starttest();
            LoAp_EstimationSchedulingCtrlr.stopScheduleJobs(SCHEDULE_ESTIMATES);
            Test.stoptest();
            mapOftimeZoneConvertMap = LoAp_EstimationSchedulingCtrlr.retrieveScheduleJobs(SCHEDULE_ESTIMATES);
            system.assert(mapOftimeZoneConvertMap.keyset().size() == 0);
        }
    }
}