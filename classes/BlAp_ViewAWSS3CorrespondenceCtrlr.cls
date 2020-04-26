/******************************************************************************
@author         Echo: Amit K.
@date           04 June 2018
@description    Component controller for View Correspondence lightning component
@Revision	 	AT-3965, Tarun - Modified as per security review
*******************************************************************************/
public with sharing class BlAp_ViewAWSS3CorrespondenceCtrlr {
    private static final String CLASS_NAME = 'BlAp_ViewAWSS3CorrespondenceCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static FINAL List<String> taskFieldList = new List<String> {
        GlUt_APIConstantsTask.S3FILENAMEAPINAME
    };
   /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 04 June 2018
    @return      : String
    @parameter   : string recordId
    @description : This method returns the string of AWSS3 SignedUrl
    **********************************************************************************************/
    @AuraEnabled
    public static String getAWSS3CorrespondencePDFDocument(string recordId) {
        List<Task> taskList = getS3FileName(recordId);
        String signedUrl='';
        List<GlUt_AWSS3ViewFiles.BucketFileWrapper> lstBucketWrapper = new List<GlUt_AWSS3ViewFiles.BucketFileWrapper>();
        if(!taskList.isEmpty()){
            string s3FileName = taskList[0].S3Filename__c;
            GlUt_AWSS3ViewFiles viewCorrespondenceDoc = new GlUt_AWSS3ViewFiles(GlUt_AWSConstants.ECHOPDFCORRESPONDENCEBUCKET,s3FileName) ; 
            lstBucketWrapper = viewCorrespondenceDoc.getCloudFrontSignedURL(s3FileName);
        }
        try {
            if(lstBucketWrapper != null && !lstBucketWrapper.isEmpty()) {
                signedUrl = lstBucketWrapper[0].signedUrl;
            }
        } catch (Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return signedUrl;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 04 June 2018
    @return      : List<Task>
    @parameter   : string recordId
    @description : This method returns the List of Task records
    **********************************************************************************************/
    private static List<Task> getS3FileName(string recordId) {
        List<Task> taskList = new List<Task>();
        if(string.isNotBlank(recordId)){
            Task objTask = (Task) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsTask.TASKAPINAME, 
                                                                     Id.ValueOf(recordId),
                                                                     taskFieldList);
            
            if(objTask != null)
                taskList.add(objTask); 
        }
        return taskList;
    }
}