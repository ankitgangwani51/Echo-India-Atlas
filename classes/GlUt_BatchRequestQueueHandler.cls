/***************************************************************************************************
@author         Andrew Edge
@date           08-Mar-2018
@description:   This is helper class used by Batch Request Queue object trigger  
@group          TriggerHelper
Revision(s):    Gopal Gupta - Modified the code for Process batch, cancelled and completed batches 
                Sudhir Kumar: Modified as per AT-2426
*******************************************************************************************************/
public with sharing class GlUt_BatchRequestQueueHandler extends GlUt_TriggerHandlerBase {
    
    //Variable declaration
    private static final String CLASS_NAME = 'GlUt_BatchRequestQueueHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final Integer BATCH_SIZE =  200 ;    

    private Map<Id,BatchProcess__c> batchProcessMap = new Map<Id,BatchProcess__c>();
    private ApexQueueInformation queueInformation;    
    private static Messaging.SingleEmailMessage[] messages;
    //AT-3204 Starts Here
    private static Boolean isRun = false;
    //AT-3204 Ends Here
    //End variable declaration
    
    /**********************************************************************************************
    @author        Echo: Andrew Edge
    @date          01-Mar-2017
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {

        // initialise the email message list
        messages = new List<Messaging.SingleEmailMessage>();
        
        try {
            //Remove Empty if statements should use else if
            if(inputParam.isInsert && inputParam.isBefore){
                
            }
            if(inputParam.isInsert && inputParam.isAfter){  
                //Does the batch logic
                doBatchLogic(inputParam.newlist, null);
            }
            //Move to after trigger but requery before updating
            //Make sure that trigger handles recursion
            if(inputParam.isUpdate && inputParam.isBefore){
                
            }
            if(inputParam.isUpdate && inputParam.isAfter){
                //Does the batch logic
                doBatchLogic(inputParam.newlist, inputParam.oldmap);
            } 
            if(inputParam.isDelete && inputParam.isBefore){
                
            }
            if(inputParam.isDelete && inputParam.isAfter){
                
            }
            
            // send all emails
            if (!messages.isEmpty()) Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            

        } catch (Exception ex) {
            system.debug('Exception: ' + ex.getTypeName() + ': '  + ex.getMessage() + ' Line Number:=' + ex.getLineNumber());
            GlUt_Logger.logException(ex);
            GlUt_Logger.writeLogsToDatabase();
            
        } finally {   
            //Reset the active function to null in case this class was first in stack
            //This indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            
        }
    }
    
    /**********************************************************************************************
    @author         Echo: Andy Edge
    @date           13-Mar-2017
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description    This method overides the InProgressEntry in the base class. This is 
                    only necessary where special handling is required in the event that a trigger
                    causes another trigger to fire. In this case it is the Acccount trigger
                    calling the account trigger in which case the subsequnet invocation is supressed
    **********************************************************************************************/
    public override void inProgressEntry(GlUt_TriggerHandlerObj inputParam) {   
        //AT-3204 Starts Here
        if (inputParam.TriggerObject == GlUt_Constants.OBJBATCHREQUESTQUEUE && isRun == false) {  //AT-3204 Ends Here
            //Suppress recursion
            
        } else { //Otherwise invoke the default version of the tigger
            //Running standard trigger
            super.InProgressEntry(inputParam);
        }
    }
    
    /**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           10-Apr-2018
    @param          List<BatchRequestQueue__c> newList, Map<Id,sObject> oldMap
    @description    Checks if logic needs to perform and then process the records
    @revision:      Sudhir Kumar: As per AT-2426
    **********************************************************************************************/
    private void doBatchLogic(List<BatchRequestQueue__c> newList, Map<Id,sObject> oldMap) {  
        system.debug('doBatchLogic-newList:: ' + newList);
        system.debug('doBatchLogic-oldMap:: ' + oldMap);
        Boolean performLogic = false;
        isRun = false;
        //If it is an update trigger
        if (oldmap != null ){
            for (BatchRequestQueue__c brq : newList) {
                if (brq.Status__c != ((BatchRequestQueue__c)oldMap.get(brq.Id)).Status__c) {
                    performLogic = true;
                }
            }
            system.debug('doBatchLogic-performLogic-1:: ' + performLogic);
            
        } else { // It's an insert trigger
            performLogic = true;
            system.debug('doBatchLogic-performLogic-2:: ' + performLogic);
        }
        
        if (performLogic) {
            //Get the batchprocess records
            batchProcessMap  = loadBatchProcesses(newList);
            system.debug('doBatchLogic-batchProcessMap:: ' + batchProcessMap);
            //Get the details of all requests in process
            queueInformation = loadRequestsInProcess();
            system.debug('doBatchLogic-queueInformation:: ' + queueInformation);
            //Get the BRQ records that have been processed to update the status
            Map<Id,BatchRequestQueue__c> totalUpdatedRequests = processBatches(newList, oldMap);
            system.debug('doBatchLogic-totalUpdatedRequests:: ' + totalUpdatedRequests);
            //Requery and Save the updated requests             
            List<BatchRequestQueue__c> brqToUpdateList = [SELECT Id, Status__c, AsyncApexJobId__c FROM BatchRequestQueue__c WHERE Id IN :totalUpdatedRequests.keySet()];
            system.debug('doBatchLogic-brqToUpdateList-1:: ' + brqToUpdateList);
            for(BatchRequestQueue__c brq : brqToUpdateList){
                if(totalUpdatedRequests.containsKey(brq.id)){
                    BatchRequestQueue__c updatedBrq = totalUpdatedRequests.get(brq.Id);
                    brq.AsyncApexJobId__c           = updatedBrq.AsyncApexJobId__c;
                    brq.Status__c                   = updatedBrq.Status__c;
                    //AT-3204 Starts Here
                    if(brq.Status__c == GlBt_Constants.BRQINITIALISEDSTATUS){
                        isRun = true;
                    }
                    //AT-3204 Ends Here
                }
            }
            if(brqToUpdateList != null && !brqToUpdateList.isEmpty()){
                brqToUpdateList = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(brqToUpdateList, false);
                update brqToUpdateList;  
            }
        }
    }
    
    //Loads all related batch processes
    private Map<Id,BatchProcess__c> loadBatchProcesses(List<BatchRequestQueue__c> batchRequests){
        Set<Id> newRequestIds = new Set<Id>();
        for(BatchRequestQueue__c brq : batchRequests) {
            newRequestIds.add(brq.BatchProcess__c);
        }
        
        return new Map<Id,BatchProcess__c>([SELECT BatchClass__c, BatchSize__c FROM BatchProcess__c WHERE Id IN :newRequestIds]); 
    }
    
    //Loads various details of the Existing Job Queue    
    private ApexQueueInformation loadRequestsInProcess() {
        ApexQueueInformation apexQInfo = new ApexQueueInformation();
        Set<Id> holdingJobsSet         = new Set<Id>();
        List<String> runningStatuses   = new List<String>{GlBt_Constants.APEXQUEUEINFOHOLDINGSTATUS,GlBt_Constants.APEXQUEUEINFOQUEUEDSTATUS,
                                            GlBt_Constants.APEXQUEUEINFOPROCESSINGSTATUS,GlBt_Constants.APEXQUEUEINFOPREPARINGSTATUS}; //load all requests in process
        List<AsyncApexJob> runningJobs = [SELECT Status FROM AsyncApexJob WHERE Status IN :runningStatuses]; //picks up jobs based on runningStatuses
        system.debug('loadRequestsInProcess-runningJobs:: ' + runningJobs) ;
        for(AsyncApexJob apexjob : runningJobs) {
            if(apexjob.Status == GlBt_Constants.APEXQUEUEINFOHOLDINGSTATUS) {
                holdingJobsSet.add(apexjob.id); 
            }
        }
            
        apexQInfo.runningJobsCount = runningJobs.size();
        
        if(!holdingJobsSet.isEmpty()){
            
            //If the running Apex job has a status of 'Processing' do not consider it for the IDs 
            //Only use 'holding' when selecting a job to move in front of
            //AT-3204 Starts Here - Fetch the latest BRQ record on the basis of created Date for High,Very High and Medium Priority Jobs - By Default ASC order.
            for(BatchRequestQueue__c brq : [SELECT Id, Priority__c, AsyncApexJobId__c FROM BatchRequestQueue__c WHERE AsyncApexJobId__c IN :holdingJobsSet ORDER BY createdDate]){ //AT-3204 Ends Here
                // get Id of Very High priority job in progess
                if(brq.Priority__c ==  GlBt_Constants.BRQVERYHIGHPRIORITY){
                    apexQInfo.veryHighApexJobId = (Id)brq.AsyncApexJobId__c;                           
                }   
                // get Id of High priority job in progess               
                if(brq.Priority__c == GlBt_Constants.BRQHIGHPRIORITY){
                    apexQInfo.highApexJobID = (Id)brq.AsyncApexJobId__c;                       
                }
                // get Id of medium priority job in progess
                if(brq.Priority__c == GlBt_Constants.BRQMEDIUMPRIORITY){
                    apexQInfo.mediumApexJobId = (Id)brq.AsyncApexJobId__c;                     
                }                   
            }       
        }
        system.debug('loadRequestsInProcess-apexQInfo:: ' + apexQInfo) ;
        return apexQInfo;
    }
    
    private Map<Id,BatchRequestQueue__c> processBatches(List<BatchRequestQueue__c> batchRequests, Map<Id,sObject> oldMap){      
        List<BatchRequestQueue__c> validInitialisedRequestsVeryHigh = new List<BatchRequestQueue__c>();
        List<BatchRequestQueue__c> validInitialisedRequestsHigh     = new List<BatchRequestQueue__c>();
        List<BatchRequestQueue__c> validInitialisedRequestsMedium   = new List<BatchRequestQueue__c>();
        List<BatchRequestQueue__c> validInitialisedRequestsLow      = new List<BatchRequestQueue__c>();
        List<BatchRequestQueue__c> validCancelledRequests           = new List<BatchRequestQueue__c>();
        List<BatchRequestQueue__c> validCompletedRequests           = new List<BatchRequestQueue__c>();             
        Map<Id,BatchRequestQueue__c> updatedRequestMap              = new Map<Id,BatchRequestQueue__c>();       
        Map<Id,BatchRequestQueue__c> requestDependencyMap           = loadDependencies(batchRequests);      
        
        for(BatchRequestQueue__c brq : batchRequests){
            BatchRequestQueue__c oldBrq = null;
            if(oldmap != null){
                oldBrq = ((BatchRequestQueue__c)oldMap.get(brq.Id));
            }
            system.debug('processBatches-brq.Status:: ' + brq.Status__c) ;
            if(oldBrq == null || (oldBrq != null && oldBrq.Status__c != brq.Status__c)){
                //check status is TODO: Name status to indicated it's a new job to process          
                if(brq.Status__c == GlBt_Constants.BRQINITIALISEDSTATUS){
                    //if there are already 100 requests queues don't process (loaded from loadRequestsInProcess)
                    //check its not in the dependency map (in this case just leave it as it is)
                    if(!requestDependencyMap.containsKey(brq.Id) && queueInformation.runningJobsCount < 100){
                        if(brq.Priority__c == GlBt_Constants.BRQVERYHIGHPRIORITY){
                            validInitialisedRequestsVeryHigh.add(brq); 
                        } else if(brq.Priority__c == GlBt_Constants.BRQHIGHPRIORITY){
                            validInitialisedRequestsHigh.add(brq); 
                        } else if(brq.Priority__c == GlBt_Constants.BRQMEDIUMPRIORITY){
                            validInitialisedRequestsMedium.add(brq); 
                        } else {
                            validInitialisedRequestsLow.add(brq); 
                        }
                    } else {
                        BatchRequestQueue__c updatedBrq = new BatchRequestQueue__c(Id = brq.Id);
                        system.debug('processBatches-requestDependencyMap:: ' + requestDependencyMap) ;
                        if(requestDependencyMap.containsKey(brq.Id)){
                            updatedBrq.Status__c = GlBt_Constants.BRQWAITINGSTATUS;
                        } else {
                            updatedBrq.Status__c = GlBt_Constants.BRQERRORSSTATUS;
                        }
                        updatedRequestMap.put(updatedBrq.Id,updatedBrq);
                    }
                    system.debug('processBatches-updatedRequestMap:: ' + updatedRequestMap) ;
                }
                
                // if status is 'cancelled' cancel related apex job
                if(brq.Status__c == GlBt_Constants.BRQCANCELLEDSTATUS){
                    validCancelledRequests.add(brq);
                }
                
                // if status is 'completed' update dependent requests so they might be able to process       
                if(brq.Status__c == GlBt_Constants.BRQCOMPLETEDSTATUS){
                    validCompletedRequests.add(brq);
                }
            }
        }
        system.debug('processBatches-validInitialisedRequestsVeryHigh:: ' + validInitialisedRequestsVeryHigh);
        system.debug('processBatches-validInitialisedRequestsHigh:: ' + validInitialisedRequestsHigh);
        system.debug('processBatches-validInitialisedRequestsMedium:: ' + validInitialisedRequestsMedium);
        system.debug('processBatches-validInitialisedRequestsLow:: ' + validInitialisedRequestsLow);
        
        //Process initialised batch list in order of priority
        if(validInitialisedRequestsVeryHigh.size() > 0){
            updatedRequestMap.putAll(executeInitialisedBatches(validInitialisedRequestsVeryHigh));
        }
        if(validInitialisedRequestsHigh.size() > 0){
            updatedRequestMap.putAll(executeInitialisedBatches(validInitialisedRequestsHigh));
        }
        if(validInitialisedRequestsMedium.size() > 0){
            updatedRequestMap.putAll(executeInitialisedBatches(validInitialisedRequestsMedium));
        }
        if(validInitialisedRequestsLow.size() > 0){
            updatedRequestMap.putAll(executeInitialisedBatches(validInitialisedRequestsLow));
        }
        system.debug('processBatches-validCancelledRequests:: ' + validCancelledRequests);
        //Process cancelled batch list
        if(validCancelledRequests.size() > 0){
            updatedRequestMap.putAll(cancelBatches(validCancelledRequests));
        }
        system.debug('processBatches-validCompletedRequests:: ' + validCompletedRequests);
        //Process completed batch list
        if(validCompletedRequests.size() > 0){
            updatedRequestMap.putAll(completeBatches(validCompletedRequests));
        }
        system.debug('processBatches-updatedRequestMap:: ' + updatedRequestMap) ;    
        return updatedRequestMap;           
    }
    
    //Loads running 'parent' batches for validation
    private Map<Id,BatchRequestQueue__c> loadDependencies(List<BatchRequestQueue__c> batchRequests) {
        //AT-3204 Starts Here - Dependency record creation for scenario having (parent Job and Child Job with Status = Loading OR Status of parent Job = Initialized and Child Job = Loading).
        //Set<Id> parentIds    = new Set<Id>();
        Set<Id> dependentIds = new Set<Id>();
        List<String> brqStatus = new List<String>{GlBt_Constants.BRQCOMPLETEDSTATUS,GlBt_Constants.BRQCANCELLEDSTATUS,GlBt_Constants.BRQERRORSSTATUS};
        // For each new Request, create a map of the dependencies
        for(BatchRequestQueue__c brq : batchRequests){
            dependentIds.add(brq.Id);            
        }   
        system.debug('loadDependencies-dependentIds:: ' + dependentIds) ;
        Map<Id,List<Id>> mapOfParentId2ListDependencyIds = new Map<Id,List<Id>>(); //Map of Parent Id having multiple dependent BRQ Ids.
        for(Dependency__c dependency : [SELECT ID, Parent__c,Dependent__c FROM Dependency__c WHERE Dependent__c IN :dependentIds]){
            //parentIds.add(dependency.Parent__c);
            if (!mapOfParentId2ListDependencyIds.containsKey(dependency.Parent__c)) {
                mapOfParentId2ListDependencyIds.put(dependency.Parent__c, new List<Id>()); 
            }
            mapOfParentId2ListDependencyIds.get(dependency.Parent__c).add(dependency.Dependent__c); 
        }
        system.debug('loadDependencies-parentIds:: ' + mapOfParentId2ListDependencyIds) ;  
        //Create Map of new requests to their controlling parents (that are still executing)
        /*Map<Id,BatchRequestQueue__c> dependencies = new Map<Id,BatchRequestQueue__c>(
                                                [SELECT Id, Status__c FROM BatchRequestQueue__c 
                                                WHERE ID IN :parentIds AND Status__c = :GlBt_Constants.BRQPROCESSINGSTATUS]);*/
        Map<Id,BatchRequestQueue__c> dependencies = new Map<Id,BatchRequestQueue__c>(); // Map of BRQ DependentId having BRQ record.

        if(!mapOfParentId2ListDependencyIds.isEmpty()){
            //Fetch BRQ records having Status != Completed,Error,Cancelled for Parent BRQ record Ids.
            for(BatchRequestQueue__c brq: [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE ID IN :mapOfParentId2ListDependencyIds.keySet() AND  Status__c NOT IN: brqStatus]){
                if(mapOfParentId2ListDependencyIds.containsKey(brq.Id)){
                    List<Id> dependentIdList = mapOfParentId2ListDependencyIds.get(brq.Id);
                    for(Id dependentId :dependentIdList){
                        dependencies.put(dependentId,brq); // Fill the map with Dependent ids whose parents are still in processing mode.
                    }
                    
                }
            }
        }
        //AT-3204 Ends Here
        system.debug('loadDependencies-dependencies:: ' + dependencies);
        return dependencies;
    }
    
    //Executes new batches
    private List<BatchRequestQueue__c> executeInitialisedBatches(List<BatchRequestQueue__c> batchRequests) {        
        List<BatchRequestQueue__c> requestsToUpdate = new List<BatchRequestQueue__c>();     
        List<String> highOrGreater = new List<String>{GlBt_Constants.BRQHIGHPRIORITY,GlBt_Constants.BRQVERYHIGHPRIORITY};
        List<String> medOrGreater  = new List<String>{GlBt_Constants.BRQMEDIUMPRIORITY,GlBt_Constants.BRQHIGHPRIORITY,GlBt_Constants.BRQVERYHIGHPRIORITY};
                
        //for each new request
        for(BatchRequestQueue__c brq : batchRequests){
            
            //if there are already 100 requests queues don't process
            if(queueInformation.runningJobsCount < 100){
                
                // Locate the associated Batch Process Class and Call it's initialise method to deserialise the JSON parameters.
                // Each Batch class must Extend GlBt_BatchProcess in order to work within this framework
                // Instantiate version of appropriate batch class
                system.debug('executeInitialisedBatches-batchProcessMap:: ' + batchProcessMap);
                system.debug('executeInitialisedBatches-brq.BatchProcess:: ' + brq.BatchProcess__c);
                BatchProcess__c batpro = batchProcessMap.get(brq.BatchProcess__c);
                system.debug('executeInitialisedBatches-batpro:: ' + batpro);
                
                Type classType = Type.forName(GlUt_NamespacePrefix.getNamespacePrefix().replace('__',''),batpro.BatchClass__c); 
                system.debug('executeInitialisedBatches-classType:: ' + classType);
                // define activefunction as type of object so it can be cast as the interface class and also Database class.
                Object activeFunction = classType.newInstance();        
                
                // Cast into interface to call initalise method         
                GlBt_BatchProcess batchProcess = (GlBt_BatchProcess)activeFunction; 
                batchProcess.initialise(brq);
                system.debug('batpro=>' + batpro);                        
                // create ApexAsyncJob for each new request
                if(batpro.BatchSize__c == null) batpro.BatchSize__c = BATCH_SIZE ;    
                ID newJobID = Database.executeBatch((Database.Batchable<sObject>)activeFunction , Integer.valueOf(batpro.BatchSize__c));
            system.debug('executeInitialisedBatches-newJobID:: ' + newJobID);
                // increment the job count by 1
                queueInformation.runningJobsCount = queueInformation.runningJobsCount + 1;
                system.debug('executeInitialisedBatches-brq.Priority:: ' + brq.Priority__c);
                System.debug('executeInitialisedBatches-queueInformation:: ' + queueInformation);
                // Check At least 5 jobs are in the queue before prioritising
                if(queueInformation.runningJobsCount >= 5) {
                    
                    // If priority low leave at the back of the queue.      
                    if(brq.Priority__c != GlBt_Constants.BRQLOWPRIORITY) {
                        Boolean isSuccess = false;
                        // if priority is medium, high or very high and there are already medium jobs in the queue
                        // move to after medium priority id via flexqueue method
                        if(medOrGreater.contains(brq.Priority__c) && !String.isEmpty(queueInformation.mediumApexJobId)){
                            isSuccess = FlexQueue.moveAfterJob(newJobID, queueInformation.mediumApexJobId);
                        }       
                        
                        // if priority is High or very high and there are already High jobs in the queue
                        // move to after high priority id via flexqueue method
                        if(highOrGreater.contains(brq.Priority__c) && !String.isEmpty(queueInformation.highApexJobId)){
                            isSuccess = FlexQueue.moveAfterJob(newJobID, queueInformation.highApexJobId);
                        }
                                
                        // if priority is very high and there are already Very High jobs in the queue
                        // move to after very high priority id via flexqueue method             
                        if(brq.Priority__c == GlBt_Constants.BRQVERYHIGHPRIORITY && !String.isEmpty(queueInformation.veryHighApexJobId)){
                            isSuccess = FlexQueue.moveAfterJob(newJobID, queueInformation.veryHighApexJobId);
                        }
                    }
                }   
                
                // update new request with job id and Status__c = Pending
                BatchRequestQueue__c updatedBrq = new BatchRequestQueue__c();  
                updatedBrq.Id                   = brq.id;
                updatedBrq.Status__c            = GlBt_Constants.BRQPENDINGSTATUS;
                updatedBrq.AsyncApexJobId__c    = newJobID;
                requestsToUpdate.add(updatedBrq);    
            }
        }   
        
        return requestsToUpdate;  
    }
    
    //Cancels batches
    @TestVisible
    private List<BatchRequestQueue__c> cancelBatches(List<BatchRequestQueue__c> batchRequests) {        
        //AT-3204 Starts Here
        //Set<Id> reqAsyncJobIds               = new Set<Id>();
        Set<Id> abortedJobIds                  = new Set<Id>();
        Map<Id,Id> mapOfAsyncJobId2ParentId    = new Map<Id,Id>();
        Set<Id> parentIds                      = new Set<Id>();
        Set<Id> dependentIds                   = new Set<Id>();
        List<BatchRequestQueue__c> brqToUpdate = new List<BatchRequestQueue__c>();
        
        for(BatchRequestQueue__c brq : batchRequests){
            //reqAsyncJobIds.add(brq.AsyncApexJobId__c);
            mapOfAsyncJobId2ParentId.put(brq.AsyncApexJobId__c,brq.Id);
        }
        if(!mapOfAsyncJobId2ParentId.isEmpty()){
            for(AsyncApexJob job : [SELECT Id, Status FROM AsyncApexJob 
                                    WHERE Id IN :mapOfAsyncJobId2ParentId.keySet() AND Status != :GlBt_Constants.APEXQUEUEINFOABORTEDSTATUS
                                    AND Status != :GlBt_Constants.APEXQUEUEINFOCOMPLETEDSTATUS]){
                                        System.abortJob(job.Id);
                                        abortedJobIds.add(job.Id);
                                        if(mapOfAsyncJobId2ParentId.containsKey(job.Id))
                                            parentIds.add(mapOfAsyncJobId2ParentId.get(job.Id));                         
                                    }

            if(!parentIds.isEmpty()){
                for(Dependency__c dependency : [SELECT ID, Dependent__c FROM Dependency__c WHERE Parent__c IN :parentIds]){
                    dependentIds.add(dependency.Dependent__c);
                }
            }
            
            if(!dependentIds.isEmpty()){
                for(BatchRequestQueue__c brq: [Select Id,Status__c from BatchRequestQueue__c Where ID In: dependentIds]){
                    brq.Status__c = GlBt_Constants.BRQCANCELLEDSTATUS;
                    brqToUpdate.add(brq);
                }
            }
        }
        //AT-3204 Ends Here
        // Comment the below code as discussed with sudhir, becuase the record has been updated from two sides also read only error appear - Ankit, 08/06/2018
        /*for(BatchRequestQueue__c brq : batchRequests){
            if(abortedJobIds.contains(brq.AsyncApexJobId__c)){
                brq.Status__c = GlBt_Constants.BRQCANCELLEDSTATUS;
                brqToUpdate.add(brq);
            }
        }*/
        return brqToUpdate;
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           28 Jun 2018
    @param          List<BatchRequestQueue__c> - completed batch requests
    @return         Messaging.SingleEmailMessage - email message to send
    @description    creates an email message for the notification user on completion of a batch request
    *******************************************************************************/
    private Messaging.SingleEmailMessage sendCompletionEmail(BatchRequestQueue__c batchRequestQueue) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        // sender email address
        OrgWideEmailAddress sender = [select Id from OrgWideEmailAddress where DisplayName = :CuAp_Constants.BATCH_PROCESS_EMAIL_SENDER];
        
        // setup link url
        String link = '<a href="' 
                    + URL.getSalesforceBaseUrl().toExternalForm() 
                    + '/lightning/r/' + GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME 
                    + '/' + batchRequestQueue.Id + '/view'
                    + '">' 
                    + batchRequestQueue.Name
                    + '</a>';
                            
        // merge fields into custom label subject/body
        String subject = Label.CuAp_BatchProcessCompleteEmailSubject.replace('{!BatchRequestQueue__c.Name}', batchRequestQueue.Name);
        String body = Label.CuAp_BatchProcessCompleteEmailBody.replace('{!BatchRequestQueue__c.Link}', link);

        // create email message
        message.setToAddresses(new List<String>{batchRequestQueue.NotificationUser__c});
        message.setOrgWideEmailAddressId(sender.Id);
        message.setOptOutPolicy('FILTER');
        message.setSubject(subject);
        message.setHtmlBody(body);

        return message;
    }
    
    /******************************************************************************
    @author         Echo: ??
    @date           ?? ??? 2018
    @param          List<BatchRequestQueue__c> - completed batch requests
    @return         List<BatchRequestQueue__c> - dependent batch requests
    @description    processes completed batch actions
    Revision(s)     28 Jun 2018, P Dixon - added email notifications
    *******************************************************************************/
    //Completes batches
    private List<BatchRequestQueue__c> completeBatches(List<BatchRequestQueue__c> batchRequests){       
        Set<Id> parentIds    = new Set<Id>();
        Set<Id> dependentIds = new Set<Id>();
        
        for (BatchRequestQueue__c brq : batchRequests) {
            
            if (brq.SendEmailNotification__c) {
                messages.add(sendCompletionEmail(brq));
            }
            
            parentIds.add(brq.Id);
        }

        for(Dependency__c dependency : [SELECT ID, Dependent__c FROM Dependency__c WHERE Parent__c IN :parentIds]){
            dependentIds.add(dependency.Dependent__c);
        }
        
        List<BatchRequestQueue__c> dependentRequests = [SELECT Id, Status__c FROM BatchRequestQueue__c 
                                                        WHERE Id IN :dependentIds 
                                                        AND (Status__c = :GlBt_Constants.BRQWAITINGSTATUS OR Status__c = :GlBt_Constants.BRQLOADINGDSTATUS)]; 
        
        for(BatchRequestQueue__c brq : dependentRequests){
            brq.Status__c = GlBt_Constants.BRQINITIALISEDSTATUS;
        }
        
        return dependentRequests;
    }
        
    private class ApexQueueInformation {
        private Integer runningJobsCount = 0; 
        private Id veryHighApexJobId;
        private Id highApexJobId;
        private Id mediumApexJobId; 
    }
}