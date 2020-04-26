/******************************************************************************
@author        Echo : Vivek Sethi
@date          30 Aug  2018
@description   This class is used to generate Mock repsonse
*******************************************************************************/
@isTest
global class GlAp_MockHerokuBatchJobsCtrlr_Test implements HttpCalloutMock {
    private Integer statusCode;

    public GlAp_MockHerokuBatchJobsCtrlr_Test (Integer statusCode){
        this.statusCode = statusCode;
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"id":105,"TenantId":"00D0Y000002HI1tUAG","JobName":null,"JobCron":null,"JobQuery":"select sfid from salesforce.billingcontract__c","ActiveFlag":false,"JobType":"Batch Billing","EndDate":null,"SubmittedBy":"Ankit Gangwani","NextSchedule":null},{"id":107,"TenantId":"00D0Y000002HI1tUAG","JobName":null,"JobCron":null,"JobQuery":"select sfid from salesforce.billingcontract__c","ActiveFlag":false,"JobType":"Accruals","EndDate":"2018-08-30","SubmittedBy":"Ankit Gangwani","NextSchedule":null},{"id":108,"TenantId":"00D0Y000002HI1tUAG","JobName":null,"JobCron":"0 15 06 ? * Mon,Tue,Wed,Thu,Fri,Sat,Sun","JobQuery":"select sfid from salesforce.billingcontract__c","ActiveFlag":true,"JobType":"Batch Billing","EndDate":null,"SubmittedBy":"Ankit Gangwani","NextSchedule":"2018-08-31 06:15:00"},{"id":109,"TenantId":"00D0Y000002HI1tUAG","JobName":null,"JobCron":null,"JobQuery":"select sfid from salesforce.billingcontract__c","ActiveFlag":false,"JobType":"Batch Billing","EndDate":null,"SubmittedBy":"Ankit Gangwani","NextSchedule":null},{"id":110,"TenantId":"00D0Y000002HI1tUAG","JobName":null,"JobCron":null,"JobQuery":"select sfid from salesforce.billingcontract__c","ActiveFlag":false,"JobType":"Accruals","EndDate":"2018-08-17","SubmittedBy":"Ankit Gangwani","NextSchedule":null},{"id":111,"TenantId":"00D0Y000002HI1tUAG","JobName":null,"JobCron":"0 30 00 29 * ?","JobQuery":"select sfid from salesforce.billingcontract__c","ActiveFlag":true,"JobType":"Forecast","EndDate":null,"SubmittedBy":"Ankit Gangwani","NextSchedule":"2018-09-29 00:30:00"}]');
        res.setStatusCode(this.statusCode);
        return res;
    }
}