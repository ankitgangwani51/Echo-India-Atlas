/************************************************************************************************************
@author         Accenture : Ashish Tiwari
@date           26-Sep-2017
@description:   This class use to get the all test class execution result for the org 
                and genrate a CSV file to send as attachment for some key persons
Revision(s):    
**************************************************************************************************************/
global with sharing class GlUt_AutomatedTestingJob implements Schedulable {
    
    public static List<EmailAddress__c> customSetting = EmailAddress__c.getAll().values();
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          SchedulableContext
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
    @description    This method is use to call processAsyncResults() method Under Future Callout 
    **********************************************************************************************/
    @future (callout=true)
    public static void doExecute(){
        processAsyncResults();
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          
    @return         void
    @description    This method is use to Schedule the class "GlUt_AutomatedTestingJob" at every 15 min. interval. 
                    For Example,
                    Schedule String Format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    **********************************************************************************************/
    public static void createEvery15MinuteScheduledJobs(){
        GlUt_AutomatedTestingJob atj = new GlUt_AutomatedTestingJob();  
        system.schedule(customSetting[0].JobExecutionName1__c,customSetting[0].JobExecutionTime1__c,atj);
        system.schedule(customSetting[0].JobExecutionName2__c,customSetting[0].JobExecutionTime2__c,atj);
        system.schedule(customSetting[0].JobExecutionName3__c,customSetting[0].JobExecutionTime3__c,atj);
        system.schedule(customSetting[0].JobExecutionName4__c,customSetting[0].JobExecutionTime4__c,atj);
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          
    @return         void
    @description    This method is use to get the test class execution job id from custom object. 
                    Use this job id to collect the test class result and clear id.
    **********************************************************************************************/
    public static void processAsyncResults(){
        List<AutomatedTestingQueue__c> queuedTests = [select id,name,AsyncId__c from AutomatedTestingQueue__c limit 5];
        if (queuedTests != null && queuedTests.size() > 0){
            Set<Id> AsyncIds = new Set<Id>();
            for (AutomatedTestingQueue__c queuedJob : queuedTests){
                 AsyncIds.add(queuedJob.AsyncId__c);
            }
            List<ApexTestQueueItem> queuedItems = checkClassStatus(AsyncIds);
            Map<Id, List<ApexTestQueueItem>> groupedTestsByJob = new Map<Id, List<ApexTestQueueItem>>();
            for (ApexTestQueueItem atqi : queuedItems){
                if (groupedTestsByJob.containsKey(atqi.ParentJobId) == true){
                    List<ApexTestQueueItem> groupedTests = groupedTestsByJob.get(atqi.ParentJobId);
                    groupedTests.add(atqi);
                }
                else{
                    List<ApexTestQueueItem> groupedTests = new List<ApexTestQueueItem>();
                    groupedTests.add(atqi);
                    groupedTestsByJob.put(atqi.ParentJobId, groupedTests);
                }
            }
            Set<Id> completedAsyncIds = getCompletedAsyncJobsIds(groupedTestsByJob);
            if (completedAsyncIds != null && completedAsyncIds.size() > 0){
                List<ApexTestResult> testResults = checkMethodStatus(completedAsyncIds);
                Map<Id, List<ApexTestResult>> groupedTestResultsByJob = new Map<Id, List<ApexTestResult>>();
                for (ApexTestResult testResult : testResults){
                    if (groupedTestResultsByJob.containsKey(testResult.AsyncApexJobId)){
                        List<ApexTestResult> groupedTestsResults = groupedTestResultsByJob.get(testResult.AsyncApexJobId);
                        groupedTestsResults.add(testResult);
                    }
                    else{
                        List<ApexTestResult> groupedTestsResults = new List<ApexTestResult>();
                        groupedTestsResults.add(testResult);
                        
                        groupedTestResultsByJob.put(testResult.AsyncApexJobId, groupedTestsResults );
                    }
                }
                List<AutomatedTestingQueue__c> queuedTestsToDelete = new List<AutomatedTestingQueue__c>(); 
                for (List<ApexTestResult> jobTestResults : groupedTestResultsByJob.values()){
                    sendTestResultEmail(jobTestResults);
                }
                for (AutomatedTestingQueue__c queuedTest : queuedTests){
                    for (Id completedAsyncId : completedAsyncIds){
                        if (queuedTest.AsyncId__c == completedAsyncId){
                            queuedTestsToDelete.add(queuedTest);
                            break;
                        }
                    }
                    if (groupedTestsByJob.containsKey(queuedTest.asyncId__c) == false){
                        queuedTestsToDelete.add(queuedTest);
                    }
                }
                if (queuedTestsToDelete.size() > 0){
                    delete queuedTestsToDelete;
                }
            }
        }
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          Map<Id, List<ApexTestQueueItem>> groupedTestsByJob
    @return         Set<Id>
    @description    This method is use to return the ParentJobId for each test class which will 
                    be clear once process done. 
    **********************************************************************************************/
    public static Set<Id> getCompletedAsyncJobsIds(Map<Id, List<ApexTestQueueItem>> groupedTestsByJob){
        Set<Id> completedAsyncJobIds = new Set<Id>();
        for (List<ApexTestQueueItem> jobTests : groupedTestsByJob.values()){
            if (jobTests == null || jobTests.size() == 0){
                continue;
            }
            Boolean allCompleted = true;
            for (ApexTestQueueItem queuedTest : jobTests){
                if (queuedTest.Status != customSetting[0].StatusComplete__c && 
                    queuedTest.Status != customSetting[0].StatusFailed__c && 
                    queuedTest.Status != customSetting[0].StatusAborted__c){
                    allCompleted = false;      
                    break;
                }
            }
            if (allCompleted == true){
                completedAsyncJobIds.add(jobTests[0].ParentJobId);
            }
        }
        return completedAsyncJobIds;
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          List<ApexTestResult> jobTestResults
    @return         void
    @description    This method is use to send an eamil to some key person along with test result in attachemnt. 
    **********************************************************************************************/
    private static void sendTestResultEmail(List<ApexTestResult> jobTestResults){
        Messaging.EmailFileAttachment failcsvAttc = new Messaging.EmailFileAttachment();
        failcsvAttc.setFileName(customSetting[0].FailTestReportName__c+ Datetime.now().format('MMM') + Datetime.now().year()+customSetting[0].FileExtension__c);
        failcsvAttc.setBody(Blob.valueOf(generateTestFailCSV(jobTestResults)));
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName(customSetting[0].CompleteTestReportName__c+ Datetime.now().format('MMM') + Datetime.now().year()+customSetting[0].FileExtension__c);
        csvAttc.setBody(Blob.valueOf(getCoverageforClasses()));
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(EmailAddress__c.getAll().values().toAddress__c != null){
            mail.setToAddresses(EmailAddress__c.getAll().values().toAddress__c.split(customSetting[0].EmailSeparator__c));
        }
        if(EmailAddress__c.getAll().values().ccAddress__c != null){
            mail.setccAddresses(EmailAddress__c.getAll().values().ccAddress__c.split(customSetting[0].EmailSeparator__c));
        }
        mail.setSubject(customSetting[0].EmailSubject__c + String.valueOf(Date.today()));
        mail.setHtmlBody(getTestResultHtmlEmailBody(jobTestResults));
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc,failcsvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          List<ApexTestResult> jobTestResults
    @return         String
    @description    This method is use to genrate a HTML body for email having test result.
    **********************************************************************************************/
    private static String getTestResultHtmlEmailBody(List<ApexTestResult> jobTestResults){
        List<ApexTestResult> successTests = new List<ApexTestResult>();
        List<ApexTestResult> failedTests = new List<ApexTestResult>();
        for (ApexTestResult jobTestResult : jobTestResults){
            if (jobTestResult.Outcome == customSetting[0].JobResult__c){
                successTests.add(jobTestResult);
            }
            else{
                failedTests.add(jobTestResult);
            }
        }
        Integer numTestsRun = successTests.size() + failedTests.size();
        Integer numFailures = failedTests.size();
        Integer successNum = numTestsRun - numFailures;
        if (successNum < 0){
            successNum = 0;
        }
        String testResultBody = '<table style="height: 21px;" width="686"><tbody><tr><td style="width: 676px;"><p>Hi All,</p>';
        testResultBody += '<p>Please find the org code coverage report as attached and test classes which are getting fail.&nbsp;</p></td></tr></tbody></table>';
        testResultBody += '<table style="height: 9px; width: 232px;"><tbody><tr><td style="width: 137px;"><strong>Tests Run</strong></td><td style="width: 103px;">:' + numTestsRun + '</td></tr>';
        testResultBody += '<tr><td style="width: 137px;"><strong>Success Count</strong></td><td style="width: 103px;">:' + successNum + '</td></tr>';
        testResultBody += '<tr><td style="width: 137px;"><strong>Test Failures</strong></td><td style="width: 103px;">:' + numFailures + '</td></tr></tbody></table><p>&nbsp;</p>';
        if (numFailures > 0){
            testResultBody += '<table style="width: 691px;" border="1"><tbody><tr style="background-color: #999999;"><td style="width: 124px; text-align: center;"><strong>Test Class</strong></td>';
            testResultBody += '<td style="width: 105px; text-align: center;"><strong>Unit Test</strong></td>';
            testResultBody += '<td style="width: 10px; text-align: center;"><strong>Message</strong></td>';
            testResultBody += '<td style="width: 557px; text-align: center;"><strong>Stack Trace</strong></td>';
            testResultBody += '<td style="width: 100px; text-align: center;"><strong>LastModifiedBy</strong></td>';
            testResultBody += '<td style="width: 58px; text-align: center;"><strong>Time (Ms)</strong></td></tr>';
            for (ApexTestResult testFailure : failedTests){
                testResultBody += '<tr><td style="width: 124px;">'+testFailure.ApexClass.Name +'</td><td style="width: 105px;">' + testFailure.MethodName +'</td><td style="width: 10px;">' + testFailure.message +'</td><td style="width: 557px;">' + testFailure.stackTrace +'</td><td style="width: 557px;">' + testFailure.ApexClass.LastModifiedBy.Name +'</td><td style="width: 158px;">' + testFailure.ApexLog.DurationMilliseconds +'</td></tr>';
                
            }
        }
        testResultBody += '</tbody></table><p>&nbsp;</p><table style="width: 690px;"><tbody><tr style="height: 51px;"><td style="width: 692px; height: 51px;"><p>Thanks &amp; Regards,</p><p>ECHO Support Team</p></td></tr></tbody></table>';
        return testResultBody;
    }

    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          Set<ID> jobIds
    @return         List<ApexTestQueueItem>
    @description    This method is use to Get the status and pass rate for each class. 
                    whose tests were run by the job and that correspond to the specified job ID. 
    **********************************************************************************************/
    public static List<ApexTestQueueItem> checkClassStatus(Set<ID> jobIds) {
        ApexTestQueueItem[] items = [SELECT ApexClass.Name,Status,ExtendedStatus,ParentJobId 
                                     FROM ApexTestQueueItem WHERE ParentJobId in :jobIds];
        return items;
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          Set<ID> jobIds
    @return         List<ApexTestResult>
    @description    This method is use to get the result for each test method that was executed.  
    **********************************************************************************************/
    public static List<ApexTestResult> checkMethodStatus(Set<ID> jobIds) {
        ApexTestResult[] results = [SELECT Outcome,MethodName,Message,StackTrace,AsyncApexJobId, 
                                    ApexClass.Name,ApexClass.LastModifiedBy.Name,
                                    ApexLog.DurationMilliseconds    
                                    FROM ApexTestResult 
                                    WHERE AsyncApexJobId in :jobIds];
        return results;
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          
    @return         String
    @description    This method is use to make a http request for tooling api and get query the test code coverage   
    **********************************************************************************************/
    private static String getCoverageforClasses()
    {
        String CSVData = null;
        List<CoverageWrap> cwList = new List<CoverageWrap>();
        JSONObject oauth = oauthLogin(URL.getSalesforceBaseUrl().toExternalForm(), 
            customSetting[0].Consumer_Key__c,
            customSetting[0].Consumer_Secret__c,
            customSetting[0].Org_UserName__c,
            customSetting[0].Org_Password__c);
        System.debug('Response :'+oauth ); 
        String objectIdQuery = 'SELECT Id, ApexClassorTriggerId,ApexClassorTrigger.Name,NumLinesCovered, NumLinesUncovered, Coverage FROM ApexCodeCoverageAggregate';
        String environmentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v40.0/tooling/query/?q=' +EncodingUtil.urlEncode(objectIdQuery, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + oauth.access_token);
        req.setEndpoint(environmentURL);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('Response :'+res.getbody());
        if(res.getStatusCode() == 200){
            CoverageWrap cw  = (CoverageWrap)JSON.deserialize(res.getBody(),CoverageWrap.class);
            cwList.add(cw);
        }
        if(cwList != null && cwList.size()>0)
            CSVData = generateTestCoverageCSV(cwList);
        return CSVData;
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          List<CoverageWrap> cwList
    @return         String
    @description    This method is use to return a string for all test code coverage CSV file   
    **********************************************************************************************/
    private static String generateTestCoverageCSV(List<CoverageWrap> cwList){
    Map<String,String> mapTestClass = new Map<String,String>();
    Map<Id,ApexClass> mapApexClass = new Map<Id,ApexClass>();
    for(ApexClass ap: [SELECT Id,LastModifiedBy.Name,Name,body FROM ApexClass Limit 50000]){ /*AT-4374, Clayton Code Review Starts/Ends Here */
        if(ap.Name.containsIgnoreCase(customSetting[0].ClassKeyWord__c)){
            mapTestClass.put(ap.Name.substringBeforeLast('_'),ap.Name);    
        }
        mapApexClass.put(ap.id,ap);
    }
    List<String> csvRowValues = new List<String>();
        String csvColumnHeader = 'Apex Class Name,Lines Covered, Lines Uncovered, Code Coverage,Test Class, LastModifiedBy\n';
        for(CoverageWrap csvs : cwList){
            for(Records rec : csvs.records){
                if(rec.ApexClassOrTrigger != null){
                    String testClass = mapTestClass.containsKey(rec.ApexClassOrTrigger.Name) ? mapTestClass.get(rec.ApexClassOrTrigger.Name) : '';
                    String LastModifyBy = mapApexClass.containsKey(rec.ApexClassOrTriggerId) ? mapApexClass.get(rec.ApexClassOrTriggerId).LastModifiedBy.Name : '';
                    String rowStr =  rec.ApexClassOrTrigger.Name + ',' + rec.NumLinesCovered + ',' + rec.NumLinesUncovered + ',' 
                    + String.ValueOf(getPercentage(Integer.valueOf(rec.NumLinesCovered),Integer.valueOf(rec.NumLinesUncovered)))+ ',' 
                    + testClass +','
                    + LastModifyBy ;
                    csvRowValues.add(rowStr);
                }
            }
        }
        return csvColumnHeader + String.join(csvRowValues,'\n');
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          List<CoverageWrap> cwList
    @return         String
    @description    This method is use to return a string for test fail result CSV file   
    **********************************************************************************************/
    private static String generateTestFailCSV(List<ApexTestResult> TestResult){
    List<String> csvRowValues = new List<String>();
        String csvColumnHeader = 'Test Class Name,Unit Test, Message, Stack Trace, LastModifiedBy,Time (Ms)\n';
        for(ApexTestResult csvs : TestResult){
            if(csvs.Outcome != customSetting[0].JobResult__c && csvs.ApexClass.Name != null){
                String MethodName = csvs.MethodName != null ? csvs.MethodName.escapeCsv() : '';
                String message = csvs.message != null ? csvs.message.escapeCsv() : '';
                String stackTrace = csvs.stackTrace != null ? csvs.stackTrace.escapeCsv() : '';
                String rowStr =  csvs.ApexClass.Name + ',' + MethodName + ',' + message + ',' 
                + stackTrace + ',' + csvs.ApexClass.LastModifiedBy.Name + ',' + csvs.ApexLog.DurationMilliseconds;
                csvRowValues.add(rowStr);
            }
        }
        return csvColumnHeader + String.join(csvRowValues,'\n');
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          Integer LineCovered
    @param          Integer LineUncovered
    @return         Double
    @description    This method is use to calculate the code ceverage percentage   
    **********************************************************************************************/
    private static Double getPercentage(Integer LineCovered,Integer LineUncovered){
        Double result = 0.0;
        If((LineCovered+LineUncovered)>0){
            result = ((LineCovered*100)/(LineCovered+LineUncovered));
        }
        return result;
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           26-Sep-2017
    @param          String loginUri
    @param          String clientId
    @param          String clientSecret
    @param          String username
    @param          String password
    @return         JSONObject 
    @description    This method is use to provide the SFDC connection   
    **********************************************************************************************/
    private static JSONObject oauthLogin(String loginUri, String clientId,
        String clientSecret, String username, String password) {
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setEndpoint(loginUri+'/services/oauth2/token');
        req.setBody('grant_type=password' +
            '&client_id=' + clientId +
            '&client_secret=' + clientSecret +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8'));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return (JSONObject)JSON.deserialize(res.getBody(),JSONObject.class);
    }
    
    /************************************************************************************************************
    @author         Accenture : Ashish Tiwari
    @date           26-Sep-2017
    @description:   This class use to wrap the tooling API json response
    Revision(s):    
    **************************************************************************************************************/  
    public class Attributes {
        public String type;
        public String url;
    }
    
    /************************************************************************************************************
    @author         Accenture : Ashish Tiwari
    @date           26-Sep-2017
    @description:   This class use to wrap the tooling API json response
    Revision(s):    
    **************************************************************************************************************/
    public class Records {
        public Attributes attributes;
        public String Id;
        public ApexClassOrTrigger ApexClassOrTrigger {get;set;}
        public Id ApexClassOrTriggerId{set;get;}
        public String NumLinesCovered {get;set;}
        public String NumLinesUncovered {get;set;}
    }
    
    /************************************************************************************************************
    @author         Accenture : Ashish Tiwari
    @date           26-Sep-2017
    @description:   This class use to wrap the tooling API json response
    Revision(s):    
    **************************************************************************************************************/
    public class ApexClassOrTrigger {
        public Attributes attributes;
        public String Name{get;set;}
    }
    
    /************************************************************************************************************
    @author         Accenture : Ashish Tiwari
    @date           26-Sep-2017
    @description:   This class use to wrap the tooling API json response
    Revision(s):    
    **************************************************************************************************************/
    public class CoverageWrap{
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<Records> records{get;set;}
    }
    
    /************************************************************************************************************
    @author         Accenture : Ashish Tiwari
    @date           26-Sep-2017
    @description:   This class use to wrap the SFDC connection json response
    Revision(s):    
    **************************************************************************************************************/
    public class JSONObject{
        public String refresh_token{get;set;}
        public Integer expires_in{get;set;}
        public String scope{get;set;}
        public String token_type{get;set;}
        public String state{get;set;}
        public String access_token{get;set;}
    }
}