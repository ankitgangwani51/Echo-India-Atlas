/************************************************************************************************************
@author         Accenture : Ashish Tiwari
@date           26-Sep-2017
@description:   This class use to queue a job for all test class to execute 
Revision(s):    
**************************************************************************************************************/
global with sharing class GlUt_AutomatedTestJobQueuer implements schedulable {
    
    public static List<EmailAddress__c> customSetting = EmailAddress__c.getAll().values();
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          SchedulableContext inputParam
    @return         void
    @description    This method is use to call doExecute() method  
    **********************************************************************************************/
    global void execute(SchedulableContext SC) {
        doExecute();
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          
    @return         void
    @description    This method is use to call enqueueUnitTests() method Under Future Callout 
    **********************************************************************************************/
    @future (callout=true)
    public static void doExecute(){
        enqueueUnitTests();
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          
    @return         void
    @description    This method is use to Schedule the class "GlUt_AutomatedTestJobQueuer" at 4 AM  
    **********************************************************************************************/
    public static void createDaily11PMScheduledJob(){
        GlUt_AutomatedTestJobQueuer atj = new GlUt_AutomatedTestJobQueuer();  
        system.schedule(customSetting[0].QueueJobName__c,customSetting[0].QueueScheduleTime__c,atj);
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          
    @return         void
    @description    Allows us to externally enqueue our unit tests. 
                    For example,whenever we check our code into source control, we could 
                    run our unit tests. 
    **********************************************************************************************/
    webservice static void enqueueUnitTests(){      
        enqueueTests();
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          
    @return         void
    @description    Enqueue all classes ending with "Test".For Example In our org, our 
                    test classes are named "<Class_Name_Here>Test"  
    **********************************************************************************************/
    public static void enqueueTests() {
     //   ApexClass[] testClasses = [SELECT Id,Name FROM ApexClass WHERE Name LIKE: '%'+customSetting[0].ClassKeyWord__c];
         List<ApexClass> testClasses = new List<ApexClass>();
        for(ApexClass apClass: [SELECT Id,Name,body FROM ApexClass Limit 50000]){ /*AT-4374, Clayton Code Review Starts/Ends Here */
            if(apClass.body.containsIgnoreCase('@isTest')){
                testClasses.add(apClass);
            }
        }
        Integer testClassCnt = testClasses != null ? testClasses.size() : 0;
        if (testClassCnt > 0) {
          /*
             Insertion of the ApexTestQueueItem causes the unit tests to be 
             executed. Since they're asynchronous, the apex async job id
             needs to be stored somewhere so we can process the test results
             when the job is complete.
          */
            ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            for (ApexClass testClass : testClasses) {
                queueItems.add(new ApexTestQueueItem(ApexClassId=testClass.Id));
            }
            insert queueItems;
    
          // Get the job ID of the first queue item returned. 
    
            ApexTestQueueItem item = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id=:queueItems[0].Id LIMIT 1];
            AutomatedTestingQueue__c atq = new AutomatedTestingQueue__c(AsyncId__c = item.parentjobid);
            insert atq;
        }
    }
}