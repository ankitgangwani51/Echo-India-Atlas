/******************************************************************************
@author         Accenture: Patrick Dixon
@date           11 Sep 2017
@description    Component controller for generate PDF lightning component

        This class runs without object and field permission checks since: 
        (a) Its primary function is to pass data between Salesforce and Heroku 
            and save the resulting PDF as a file attachment
        (b) It does not expose record data to the user
*******************************************************************************/
public with sharing class BlAp_GeneratePDFComponentCtrlr {

    private static final String CLASS_NAME = 'BlAp_GeneratePDFComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static list<String> billFieldList = new list<String> {   
        GlUt_APIConstantsBill.DONOTPRINTAPINAME
            };
                
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           11 Sep 2017
    @param          Id - bill Id
    @return         Bill__c - bill record
    @description    Method called to return the bill record (with attachments)
    *******************************************************************************/
    public static Bill__c getBill(Id billId) {
        
        for (Bill__c bill : [select Id, 
                                    (select Id, 
                                            LinkedEntityId, 
                                            ContentDocumentId, 
                                            Title, 
                                            FileType, 
                                            ContentSize, 
                                            FileExtension 
                                    from AttachedContentDocuments where FileType = 'PDF'
                                    )
                            from Bill__c 
                            where Id = :billId]) {

            return bill;
        }
        return null;
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           16 Jan 2019
    @param          Id - bill Id
    @return         Boolean
    @description    Method called to return boolean values to show component.
    *******************************************************************************/
 
    @AuraEnabled
    public static boolean isShowComponent(Id recordId) {
        boolean isShowComponent = true;
        try {
            Bill__c objBill = (Bill__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsBill.BILLAPINAME, 
                                                                                      recordId, 
                                                                                      billFieldList);
            if(objBill.DoNotPrint__c){
                isShowComponent = false;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return isShowComponent;
    }
    

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           11 Sep 2017
    @param          Id - bill Id
    @return         Id - attachment Id
    @description    Method called to return the attachment Id
    @revision       Echo: Sudhir: AU1 AT-4098: Generic variable
    *******************************************************************************/
    @AuraEnabled
    public static String getAttachmentId(Id recordId) {
        try {
            String signedUrl = BlIn_ExecutePDFGeneration.getSignedUrl(recordId,False); // AT-4098 
            return signedUrl;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());

        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           07 Sep 2017
    @param          Id - bill Id
    @return         Id - PDF bill attachment Id
    @description    Method called to generate a bill PDF
    @revision       Echo: Sudhir: AU1 AT-4098: Generic variable
    *******************************************************************************/
    @AuraEnabled
    public static String getGeneratedPDF(Id recordId) {
        String attachmentId;
        try {
            // generate the PDF and save as an attachment on the bill
            attachmentId = BlIn_ExecutePDFGeneration.ExecutePDF(recordId); // AT-4098
            if(attachmentId.containsIgnoreCase(Label.GlAp_NotificationTypeError)) {
                return attachmentId ;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());

        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return attachmentId;
    }
}