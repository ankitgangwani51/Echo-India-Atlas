/***************************************************************************************************
@author        Echo : Dependra Singh
@date          25 May 2018
@description:  Class is used to upload zip file in Heroku   
*******************************************************************************************************/
public with sharing class BlAp_UploadPdfTemplateCtrlr {
    
    // String variable used for file name sending in Heroku
    public String fileName{get;set;}
    // String variable for xslt template name.
    public String xsltTemplateName{get;set;}
    
    public transient Attachment objAttachment ;
    
    public Attachment getObjAttachment() {
        objAttachment = new Attachment() ;
        return objAttachment ;
    }
    public Boolean fileUploadProcessed {get; set;}
    // String variable to send the message in response in LC.
    public String message {get; set;}
    //String variable for type of message(success, error)
    public String messageType {get; set;}
    public static Boolean uploadPdfTemplateRequest() {
        return true;
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           29 May 2018
    @param          
    @description    Method is used to upload zip file in heroku and will create pdf-xslt mapping.
    *******************************************************************************/
    public void uploadFile() {
        try{
            if(string.isNotBlank(fileName)){
                fileName= fileName + '.zip';
                BlUt_DocumentsUpload.ResponseHandler  objResponseHandler = BlUt_DocumentsUpload.UploadTemplate(objAttachment.Body, fileName, '');
                if(objResponseHandler.isSuccess){
                    message = system.label.BlAp_FileUploadSuccesFullyMessage;
                    messageType = system.label.GlAp_Success;
                    if(string.isNotBlank(fileName) && string.isNotBlank(xsltTemplateName)){
                        createPdfXsltMapping(fileName,xsltTemplateName);
                        fileUploadProcessed = true ;
                    }
                }else{
                    message = objResponseHandler.message ;
                    messageType = system.label.GlAp_NotificationTypeError;
                    fileUploadProcessed = false ;
                }
            }
            //ELSE calloutFailure
       } catch(Exception ex) {
            message = ex.getMessage() ;
            messageType = system.label.GlAp_NotificationTypeError;
            fileUploadProcessed = false ;
            GlUt_Logger.logException(ex);
        }
        finally{   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           29 May 2018
    @param          string pdfTemplateName , string xsltDocumentName
    @description    Method is used to create pdf-xslt mapping record.
                    AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
    *******************************************************************************/
    private void createPdfXsltMapping(string pdfTemplateName , string xsltDocumentName){
        TemplateMapping__c objMapping = new TemplateMapping__c();
        objMapping.PDFTemplate__c = pdfTemplateName;
        objMapping.XSLTDocument__c = xsltDocumentName;
        objMapping = (TemplateMapping__c) GlUt_FieldSecurity.cleanseFields(objMapping, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
        insert objMapping;
    }
}