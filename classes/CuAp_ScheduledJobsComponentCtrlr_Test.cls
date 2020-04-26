/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		05 Jul 2018
@description 	Test Class for CuAp_ScheduledJobsComponentCtrlr
Revision(s)		
*******************************************************************************/
@isTest 
public class CuAp_ScheduledJobsComponentCtrlr_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
    private static final String ACCOUNT_NAME = 'Test Account';
    
    
    private static final String BATCH_CLASS = 'LoBt_ScheduledEstimates';
    private static final String STAGING_TABLE = 'ReadingUpload__c';
    private static final String FIELDSET_NAME = 'RelatedListDetails';		// fieldsets must exist
    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Test data setup
	*******************************************************************************/
    @TestSetup
    static void createTestData() {
    	
        // create a user
        User testUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        testUser.FirstName = USER_FIRST_NAME;
        testUser.LastName = USER_LAST_NAME;
        insert testUser;
        
        // create some batch processes
        List<BatchProcess__c> batchProcesses = new List<BatchProcess__c>();
        for (Integer i = 0; i < 10; i++) {
	        BatchProcess__c batchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS);
        	batchProcess.Name = 'TestProcess' + String.valueOf(i);
        	batchProcess.Operation__c = GlUt_Constants.BATCHPROCESSOPERATION;
	        batchProcess.StagingTable__c = STAGING_TABLE;
	        batchProcesses.add(batchProcess);
        }
        insert batchProcesses;
        
        // create a batch request queue linked to a bacth process
        BatchRequestQueue__c batchRequestQueue = GlUt_FactoryData_Test.createBatchRequestQueue();
        batchRequestQueue.Status__c = GlBt_Constants.BRQINITIALISEDSTATUS;
        batchRequestQueue.BatchProcess__c = batchProcesses[0].Id;
        batchRequestQueue.NotificationUser__c = testUser.Id;        
        insert batchRequestQueue;
        
    }
    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Get schedule test (no schedule)
	*******************************************************************************/
    static testmethod void getSchedule_Negative() {            
        
        Id batchProcessId;
        for (BatchProcess__c batchProcess : [select Id  
											from BatchProcess__c
											where Id in (select BatchProcess__c from BatchRequestQueue__c)]) {
												
        	batchProcessId = batchProcess.Id;
       		break;
        }

        User testUser = [select Id, 
        						Name 
        				from User 
        				where isActive = true 
        					and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
        	CronTrigger schedule = CuAp_ScheduledJobsComponentCtrlr.getSchedule(batchProcessId); 
            system.assert(schedule == null);
            Test.stopTest();          
        }         
    }  
    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Get schedule test (has schedule)
	*******************************************************************************/
    static testmethod void getSchedule_Positive() {            
        
        Id batchProcessId;
        for (BatchProcess__c batchProcess : [select Id  
											from BatchProcess__c
											where Id in (select BatchProcess__c from BatchRequestQueue__c)]) {
												
        	batchProcessId = batchProcess.Id;
       		break;
        }

        User testUser = [select Id, 
        						Name 
        				from User 
        				where isActive = true 
        					and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
        	CronTrigger schedule = CuAp_ScheduledJobsComponentCtrlr.createNewSchedule(batchProcessId, '15', '12', '*', '?');
        	schedule = CuAp_ScheduledJobsComponentCtrlr.getSchedule(batchProcessId); 
            system.assert(schedule.Id != null);
            Test.stopTest();          
        }         
    }  
    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Create schedule test 
	*******************************************************************************/
    static testmethod void createNewSchedule() {            
        
        Id batchProcessId;
        for (BatchProcess__c batchProcess : [select Id  
											from BatchProcess__c
											where Id in (select BatchProcess__c from BatchRequestQueue__c)]) {
												
        	batchProcessId = batchProcess.Id;
       		break;
        }

        User testUser = [select Id, 
        						Name 
        				from User 
        				where isActive = true 
        					and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
        	CronTrigger schedule = CuAp_ScheduledJobsComponentCtrlr.createNewSchedule(batchProcessId, '15', '12', '*', '?'); 
            system.assert(schedule.Id != null);
            Test.stopTest();          
        }         
    }  
    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Stop schedule test 
	*******************************************************************************/
    static testmethod void stopScheduledJob() {            
        
        Id batchProcessId;
        for (BatchProcess__c batchProcess : [select Id  
											from BatchProcess__c
											where Id in (select BatchProcess__c from BatchRequestQueue__c)]) {
												
        	batchProcessId = batchProcess.Id;
       		break;
        }

        User testUser = [select Id, 
        						Name 
        				from User 
        				where isActive = true 
        					and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {

            Test.startTest(); 
        	CronTrigger schedule = CuAp_ScheduledJobsComponentCtrlr.createNewSchedule(batchProcessId, '15', '12', '*', '?');
            system.assert(schedule.Id != null);
        	CuAp_ScheduledJobsComponentCtrlr.stopScheduledJob(schedule.Id);
        	schedule = CuAp_ScheduledJobsComponentCtrlr.getSchedule(batchProcessId); 
            system.assert(schedule == null);
            Test.stopTest();          
        }         
    }  
    
}