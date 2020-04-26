@isTest
public class BlAp_ViewAWSS3CorrespondenceCtrlr_Test {
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'neha';
    private static final String USER_LNAME = 'rajput';
    private static final String S3FILENAME = 'XYZ.zip';
    @TestSetup
    static void createTestData(){
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME; 
        Database.insert(objUser);
        Task objTask = GlUt_FactoryData_Test.createTask();
        objTask.OwnerId = UserInfo.getUserId();
        objTask.S3Filename__c = S3FILENAME;
        Database.insert(objTask);
    }
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        18-06-2018  
    @description: Test Method POSITIVE SCENARIO
    *******************************************************************************/
    static testmethod void getAWSS3CorrespondencePDFDocument_Positive(){
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Task objTask = [SELECT Id,Subject, Status,Priority,S3Filename__c 
                        FROM Task LIMIT 1];
        String signedUrl;
        System.runAs(objUser){
            Test.startTest();           
            signedUrl = BlAp_ViewAWSS3CorrespondenceCtrlr.getAWSS3CorrespondencePDFDocument(objTask.Id);
            Test.stopTest();          
        }
        System.assert(signedUrl != null);
  
    }
    
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        18-06-2018  
    @description: Test Method NEGATIVE SCENARIO
    *******************************************************************************/
    static testmethod void getAWSS3CorrespondencePDFDocument_NEGATIVE(){
        User objUser = [SELECT Id,Name 
                        FROM user 
                        WHERE isActive=true 
                        AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Task objTask = new Task();
        
        boolean isException;
        String signedUrl;
        System.runAs(objUser){
            Test.startTest();           
            signedUrl = BlAp_ViewAWSS3CorrespondenceCtrlr.getAWSS3CorrespondencePDFDocument(objTask.Id);
            System.debug('****signedUrl'+signedUrl);
            Test.stopTest();
            
        }
        System.assert(string.isBlank(signedUrl));
    }
    
}