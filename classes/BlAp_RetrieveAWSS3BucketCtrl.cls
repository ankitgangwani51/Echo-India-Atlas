/******************************************************************************
@author         Echo: Sudhir Kumar
@date           18 May 2018
@description    BlAp_RetrieveAWSS3BucketCtrl class contains methods and fieldProps to get PDF Templates & XSLT Documents from AWS S3.
*******************************************************************************/

public with sharing class BlAp_RetrieveAWSS3BucketCtrl {

    private static final String CLASS_NAME = 'BlAp_RetrieveAWSS3BucketCtrl';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /**********************************************************************************************
	@author         Echo: Sudhir Kumar
	@date           18 May 2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the PDF Template screen
	**********************************************************************************************/ 
	@AuraEnabled
	public static List<GLAp_FieldProps> retrieveTemplateHeaderPdfPropDetails() {
        
		List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(DEBUG) ;
            GLAp_FieldProps templateHeader1 = new GLAp_FieldProps();
            templateHeader1.isFLSVisible = true;
            templateHeader1.isEncrypted = false;
            templateHeader1.isEditable = false;
            templateHeader1.isRequired = false;
            templateHeader1.fieldName = GlUt_AWSConstants.TEMPLATE_NAME ;
            templateHeader1.fieldLabel = 'Template Name';
            templateHeader1.fieldType = 'text';
            templateHeader1.transformField = true; 
            templateHeader1.parentObject = GlUt_AWSConstants.AWSS3PDFBUCKET_FIELD_PROP ;	
            fldPropList.add(templateHeader1);
            
            GLAp_FieldProps templateHeader2 = new GLAp_FieldProps();
            templateHeader2.isFLSVisible = true;
            templateHeader2.isEncrypted = false;
            templateHeader2.isEditable = false;
            templateHeader2.isRequired = false;
            templateHeader2.fieldName = GlUt_AWSConstants.ACTION ;
            templateHeader2.fieldLabel = 'Download';
            templateHeader2.fieldType = 'url';
            templateHeader2.buttonField = true;
            templateHeader2.transformField = true; 
            templateHeader2.parentObject = GlUt_AWSConstants.AWSS3PDFBUCKET_FIELD_PROP ;	
            fldPropList.add(templateHeader2);
        } catch(Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
		return fldPropList;
	}
	
    /**********************************************************************************************
	@author         Echo: Sudhir Kumar
	@date           18 May 2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the XSLT Document screen
	**********************************************************************************************/ 
    
    @AuraEnabled
	public static List<GLAp_FieldProps> retrieveTemplateHeaderXsltPropDetails() {
        
		List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(DEBUG) ;
            GLAp_FieldProps templateHeader1 = new GLAp_FieldProps();
            templateHeader1.isFLSVisible = true;
            templateHeader1.isEncrypted = false;
            templateHeader1.isEditable = false;
            templateHeader1.isRequired = false;
            templateHeader1.fieldName = GlUt_AWSConstants.TEMPLATE_NAME ;
            templateHeader1.fieldLabel = 'Template Name';
            templateHeader1.fieldType = 'text';
            templateHeader1.transformField = true; 
            templateHeader1.parentObject = GlUt_AWSConstants.AWSS3XSLTBUCKET_FIELD_PROP ;	
            fldPropList.add(templateHeader1);
            
            GLAp_FieldProps templateHeader2 = new GLAp_FieldProps();
            templateHeader2.isFLSVisible = true;
            templateHeader2.isEncrypted = false;
            templateHeader2.isEditable = false;
            templateHeader2.isRequired = false;
            templateHeader2.fieldName = GlUt_AWSConstants.ACTION ;
            templateHeader2.fieldLabel = 'Download';
            templateHeader2.fieldType = 'url';
            templateHeader2.buttonField = true;
            templateHeader2.transformField = true; 
            templateHeader2.parentObject = GlUt_AWSConstants.AWSS3XSLTBUCKET_FIELD_PROP ;	
            fldPropList.add(templateHeader2);
        } catch(Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
		return fldPropList;
	}
    /******************************************************************************
	@author      	Echo: Sudhir Kumar
	@date      		18 May 2018
	@param			none
	@return			List<BlAp_CombinedRecord> 
	@description	Return all Pdf Templates from an AWS Bucket 
	*******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getAWSS3PdfTemplates() {
        
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();
        GlUt_AWSS3ViewFiles awsS3Service = new GlUt_AWSS3ViewFiles(GlUt_AWSConstants.ECHOPDFTEMPLATEBUCKET) ;
		//GlUt_AWSS3ViewFiles awsS3Service = new GlUt_AWSS3ViewFiles('echo-pdf', 'a241v000000tCfYAAU/Statement_a241v000000tCfYAAU.pdf') ;        
        List<GlUt_AWSS3ViewFiles.BucketFileWrapper> lstBucketWrapper = awsS3Service.viewFilesFromBucket() ;
        
        Integer iCount = 0;
      
        try {
            GlUt_Logger.logDebug(DEBUG) ;
            if(lstBucketWrapper != null && !lstBucketWrapper.isEmpty()) {
                for(GlUt_AWSS3ViewFiles.BucketFileWrapper objWrapper : lstBucketWrapper) {
                    iCount += 1;
                    BlAp_CombinedRecord documentObj 		= new BlAp_CombinedRecord(); 
                    documentObj.uniqueId            		= String.valueOf(iCount);
                    documentObj.isSelected          		= false;
                    documentObj.transformFieldMap 			= new Map<String, Map<String, String>>();
                    Map<String,String> transFormFieldMap1 	= new Map<String,String>();
                    transFormFieldMap1.put(GlUt_AWSConstants.TEMPLATE_NAME, objWrapper.fileName);
                    transFormFieldMap1.put(GlUt_AWSConstants.ACTION, objWrapper.signedUrl);
                    documentObj.transFormFieldMap.put(GlUt_AWSConstants.AWSS3PDFBUCKET_FIELD_PROP, transFormFieldMap1);
                    combinedRecordList.add(documentObj);
                }
            }
		} catch (Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return combinedRecordList;
    }
    
    
    /******************************************************************************
	@author      	Echo: Sudhir Kumar
	@date      		18 May 2018
	@param			none
	@return			List<BlAp_CombinedRecord> 
	@description	Return all XSLT Documents from an AWS Bucket 
	*******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getAWSS3XsltTemplates() {
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();
        List<GlUt_AWSS3ViewFiles.BucketFileWrapper> lstBucketWrapper ;
        GlUt_AWSS3ViewFiles awsS3Service = new GlUt_AWSS3ViewFiles(GlUt_AWSConstants.XSLTS3BUCKET) ;
        //GlUt_AWSS3ViewFiles awsS3Service = new GlUt_AWSS3ViewFiles('echo-pdf', 'a241v000000tCfYAAU/Statement_a241v000000tCfYAAU.pdf') ;  
        if(awsS3Service != null) {
             lstBucketWrapper = awsS3Service.viewFilesFromBucket() ;
        }
        Integer iCount = 0;
        try {
                if(lstBucketWrapper != null && !lstBucketWrapper.isEmpty()) {
                    for(GlUt_AWSS3ViewFiles.BucketFileWrapper objWrapper : lstBucketWrapper){
                    iCount += 1;
                    BlAp_CombinedRecord documentObj 		= new BlAp_CombinedRecord(); 
                    documentObj.uniqueId            		= String.valueOf(iCount);
                    documentObj.isSelected          		= false;
                    documentObj.transformFieldMap 			= new Map<String, Map<String, String>>();
                    Map<String,String> transFormFieldMap1 	= new Map<String,String>();
                    transFormFieldMap1.put(GlUt_AWSConstants.TEMPLATE_NAME, objWrapper.fileName);
                    transFormFieldMap1.put(GlUt_AWSConstants.ACTION, objWrapper.signedUrl);
                    documentObj.transFormFieldMap.put(GlUt_AWSConstants.AWSS3XSLTBUCKET_FIELD_PROP, transFormFieldMap1);
                    combinedRecordList.add(documentObj);
                }
            }
        } catch (Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return combinedRecordList;
    }
    
}