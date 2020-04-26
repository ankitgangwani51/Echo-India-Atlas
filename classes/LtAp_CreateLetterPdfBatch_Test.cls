/******************************************************************************
@author:      Echo: Amit K.
@date:        06 March 2018
@description: Test Class for LtAp_CreateLetterPdfBatch
Revision(s):  
*******************************************************************************/
@isTest
public class LtAp_CreateLetterPdfBatch_Test {
    private static String USERPROFILE = 'System Administrator';
    private static final String USERFNAME= 'TestFName';
    private static final String USERLNAME= 'TestLName';
    private static String USERNAME = 'TestUser';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount'; 
    private static String AUTHENTICATION_TOKEN = 'xyz';
    private static String WORKSPACE_NAME = 'Letter PDFs';
    
/*******************************************************************
Purpose: method to create test data used by all USER_NAMEtest methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @testSetup
    static void createTestData(){
        //Create User Record.
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE,USERNAME,null);
        objUser.FirstName = USERFNAME;
        objUser.LastName = USERLNAME;
        Database.insert(objUser); 
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);        
        Database.insert(objAccount);
        // Create Heroku Security Record
        HerokuSecurity__c objHeroku = GlUt_FactoryData_Test.createHerokuSecurity(AUTHENTICATION_TOKEN);
        Database.insert(objHeroku);
        // Create Letter PDF Request Record
        PDFRequest__c objCreateLetterPDFRequest = GlUt_FactoryData_Test.createLetterPDFRequest(objAccount);
        objCreateLetterPDFRequest.CorrespondenceType__c = 'Bill PDF';
        objCreateLetterPDFRequest.SourceType__c = LtBt_Constants.HTMLPDFSOURCETYPE;
        Database.insert(objCreateLetterPDFRequest);
        
        AWSBucketSettings__c objCustomSetting = new AWSBucketSettings__c(Name = GlUt_AWSConstants.ECHODATATRANSFERXMLS3BUCKET,
                                                                         DistributionURL__c = 'https://d3q8ucvhfcpp9m.cloudfront.net',
                                                                         Endpoint__c = 'https://echo-data-xml.s3.amazonaws.com', 
                                                                         Region__c = 'eu-west-2');
        database.insert(objCustomSetting);
        
    }
/*******************************************************************
Purpose: Method to test HEROKU callout to generate a PDF 
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testMethod void executePDF()
    {
        User objUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
		        
        System.runAs(objUser){
            String SchedulerName  = 'LtAp_CreateLetterPdf Batch';
            String sCronExp = '0 1 * * * ? *';
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new LtAp_MockHttpResponseGenerator_Test(200));
            LtAp_CreateLetterPdfBatch batchObject = new LtAp_CreateLetterPdfBatch();             
            Database.executeBatch(batchObject);
            String jobID = System.schedule(SchedulerName, sCronExp, batchObject);
            Test.stopTest(); 
            System.assert(jobID != null);
        }
    }
    
    
}