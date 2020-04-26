/***************************************************************************************************
@author        Echo : Dependra Singh
@date          29 May 2018
@description:  Class is used to upload xslt file in Heroku
@group         
*******************************************************************************************************/
public with sharing class BlAp_UploadXsltDocumentCtrlr {
   // String variable used for file name sending in Heroku
    public String fileName{get;set;}
    
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
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           29 May 2018
    @param          
    @description    Method is used to upload xslt file in heroku .
    *******************************************************************************/   
    public void uploadFile() {
        try{
            if(objAttachment.Name.contains('.xslt')) {
                BlUt_DocumentsUpload.isXSLTUpload = true ;
            }
            if(string.isNotBlank(fileName)){
                fileName = fileName + '.xslt';
                BlUt_DocumentsUpload.ResponseHandler  objResponseHandler = BlUt_DocumentsUpload.UploadTemplate(objAttachment.Body, fileName, '');
                if(objResponseHandler.isSuccess){
                    message = system.label.BlAp_FileUploadSuccesFullyMessage;
                    messageType = system.label.GlAp_Success;
                    fileUploadProcessed = true ;
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
}