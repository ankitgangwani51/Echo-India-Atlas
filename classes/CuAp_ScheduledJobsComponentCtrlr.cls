/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		27 Jun 2018
@description 	Component controller for batch process scheduled jobs lightning component
Revision(s)		
*******************************************************************************/
public with sharing class CuAp_ScheduledJobsComponentCtrlr {
	
	private static final String CLASS_NAME = 'CuAp_ScheduledJobsComponentCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	

	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		27 Jun 2018
	@param			Id - the batch process Id
	@return			CronTrigger - existing schedule
	@description 	gets an existing schedule for this batch process (null if no schedule)
	*******************************************************************************/
    @AuraEnabled
    public static CronTrigger getSchedule(Id batchProcessId) {
        CronTrigger existingSchedule;
        try {
            // get the job name
            String jobName;
            for (BatchProcess__c batchProcess : [select Id, 
            											Name 
            									from BatchProcess__c
            									where Id = :batchProcessId]) {
            										
            	jobName = batchProcess.Name;
			}
			
			// get the job details that match the job name
			/*AT-4375 CLAYTON security review changes starts here */
            if (String.isNotBlank(jobName)) {
                String jobId = '';
                for (CronJobDetail job : [select Id  
                                          from CronJobDetail 
                                          where Name = :jobName 
                                          and JobType = '7']) {
                                              jobId = job.Id;
                                              break;
                                          }
                if(string.isNotBlank(jobId)){
                    for (CronTrigger schedule : [select Id, 
                                                 PreviousFireTime, 
                                                 NextFireTime 
                                                 from CronTrigger
                                                 where CronJobDetailId =: jobId]) {
                                                     existingSchedule = schedule;
                                                     break;
                                                 }
                }
            }
            
		/*	if (String.isNotBlank(jobName)) {
				for (CronJobDetail job : [select Id  
											from CronJobDetail 
											where Name = :jobName 
												and JobType = '7']) {
													
					for (CronTrigger schedule : [select Id, 
									            		PreviousFireTime, 
									            		NextFireTime 
									            	from CronTrigger
									            	where CronJobDetailId = :job.Id]) {
									            		
						existingSchedule = schedule;	            		
						break;		            		
					}
					break;
				}
			}*/
			/*AT-4375 CLAYTON security review changes Ends here */
        } catch (exception e) {
            GlUt_Logger.logException(e);
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return existingSchedule;
    }

	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		28 Jun 2018
	@param			Id - batch process Id
	@param			String minutes - minutes eg 15
	@param			String hours - hour eg 10
	@param			String dayOfMonth - date for monthly (1-31)
	@param			String dayOfWeek - day for weekly (1-7)
	@return			CronTrigger - new schedule
	@description 	creates a new batch request record
	*******************************************************************************/
    @AuraEnabled
    public static CronTrigger createNewSchedule(Id batchProcessId, String minutes, String hours, String dayOfMonth, String dayOfWeek) {
    	CronTrigger newSchedule;
    	/* ss mm hh dayOfMonth month dayOfWeek */
    	String cronSchedule = '0 ' 
    						+ minutes + ' ' 
    						+ hours + ' ' 
    						+ dayOfMonth + ' '	// '?' if dayOfWeek != '*'
    						+ '* ' 		// every month
    						+ dayOfWeek;	// '?' if dayOfMonth != '*'
		System.debug(DEBUG + 'cronSchedule: ' + cronSchedule);
		
        try {  
            // get the batch class name
            String batchClass;
            for (BatchProcess__c batchProcess : [select Id, 
            											Name 
            									from BatchProcess__c 
            									where Id = :batchProcessId]) {
            										
            	batchClass = batchProcess.Name;
            }
            
            // schedule the job
            Id jobId = System.schedule(batchClass, cronSchedule, new GlBt_ScheduleBatchRequest(batchClass));
			// get the new schedule details
			for (CronTrigger schedule : [select Id, 
							            		PreviousFireTime, 
							            		NextFireTime 
							            	from CronTrigger
							            	where Id = :jobId]) {
									            		
				newSchedule = schedule;	            		
			}         		
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return newSchedule;
    }

	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		28 Jun 2018
	@param			Id - scheduled job Id
	@description 	stops the current scheduled job
	*******************************************************************************/
    @AuraEnabled
    public static void stopScheduledJob(Id jobId) {
        try {  
            System.abortJob(jobId);
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}