/******************************************************************************
@author         Accenture: Patrick Dixon
@date           27 Oct 2017
@description    Handler for Content Document trigger
Revision(s)		AT-4888, Checkmarks issues.
*******************************************************************************/
public with sharing class GlUt_BillTemplateHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_BillTemplateHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           27 Oct 2017
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
                // validate new template names
                Map<String, Id> validTemplatesMap = validateBillTemplates(inputParam.newlist, inputParam.oldmap);
                // upload any new templates to Heroku
                UploadNewBillTemplates(validTemplatesMap);
            }
            if (inputParam.isInsert && inputParam.isAfter) {
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                // validate updated template names
                Map<String, Id> validTemplatesMap = validateBillTemplates(inputParam.newlist, inputParam.oldmap);
                // upload any new templates to Heroku
                UploadNewBillTemplates(validTemplatesMap);
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
            }
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            // TO-DO Logger.debugException(e);
        }
        finally {      
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
            // TO-DO Logger.pop();
        }
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           27 Oct 2017
    @param          List<SObject> - list of new records
    @param          Map<Id, SObject> - map of old records keyed on Id
    @return         Map<String, Id> - validTemplatesMap
    @description    Validates that new or updated filenames exist as template files 
                    and returns the valid templates as a map of file Ids keyed on the name
    *******************************************************************************/
    public Map<String, Id> validateBillTemplates(List<SObject> newlist, Map<Id, SObject> oldmap) {
        Map<String, Id> validTemplatesMap = new Map<String, Id>();      // map of content document Ids keyed on the template name
        // build a list of template filename additions and changes
        Set<String> fileNames = new Set<String>();
        for (BillTemplate__c billTemplate : (List<BillTemplate__c>)newList) {
            if (!oldmap.keySet().contains(billTemplate.Id) 
                || billTemplate.FileName__c != ((BillTemplate__c)oldmap.get(billTemplate.Id)).FileName__c) {
                    fileNames.add(billTemplate.FileName__c);
                }
        }
        Map<String, Id> templateNameMap = new Map<String, Id>();
        for (ContentVersion template : [SELECT Id,ContentDocumentId,Title,VersionData,PathOnClient FROM ContentVersion WHERE Title in :fileNames]) {
            // ensure template title is unique
            if (templateNameMap.keySet().contains(template.Title)) {
                // handle errors - duplicate template name
                // add error messages
                for (BillTemplate__c billTemplate : (List<BillTemplate__c>)newList) {
                    if (billTemplate.FileName__c == template.Title) {
                        billTemplate.addError(System.Label.BlAp_BillTemplateNameNotUniqueError + ' ' + template.Title);
                    }
                }
            }
            templateNameMap.put(template.Title, template.ContentDocumentId);
        }
        EnvironmentSettings__mdt mdtEnvironmentSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGBILLTEMPLATELIBRARYQUERY);
        Set<Id> templateIdsFound = new Set<Id>();
        if(string.isNotBlank(mdtEnvironmentSetting.BillTemplateLibraryName__c)){
            Id templateWorkspaceId = [SELECT Id, Name FROM ContentWorkspace WHERE Name = :mdtEnvironmentSetting.BillTemplateLibraryName__c LIMIT 1].Id; 
            if(templateWorkspaceId != null){
                for (ContentDocumentLink link : [SELECT Id, 
                                                 ContentDocumentId, 
                                                 LinkedEntityId, 
                                                 ShareType
                                                 FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId = :templateWorkspaceId
                                                 AND ContentDocumentId in :templateNameMap.values()]) {
                                                     templateIdsFound.add(link.ContentDocumentId);
                                                 }
            }
        }
        // check the filename exists and it's a template (ie in the template library)
        for (String filename : fileNames) {
            if (!templateNameMap.keySet().contains(filename)|| !templateIdsFound.contains(templateNameMap.get(filename))) {
                // handle errors - template file not found
                System.debug(DEBUG + 'The template file could not be found: ' + filename);
                // add error messages
                for (BillTemplate__c billTemplate : (List<BillTemplate__c>)newList) {
                    if (billTemplate.FileName__c == filename) {
                        billTemplate.addError(System.Label.BlAp_BillTemplateFileNotFoundError + ' ' + filename);
                    }
                }
            }else{
                // add it to the map
                validTemplatesMap.put(filename, templateNameMap.get(filename));
            }
        }
        return validTemplatesMap;
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           30 Oct 2017
    @param          Map<Id, SObject> - newMap
    @description    Finds any templates not previously referenced and uploads them
                    to Heroku using the webservice
    *******************************************************************************/
    public void UploadNewBillTemplates(Map<String, Id> validTemplatesMap) {
        // build a set of the new/updated template names already uploaded to Heroku
        Set<String> uploadedTemplateNames = new Set<String>();
        for (BillTemplate__c billTemplate : [SELECT Id, 
                                                    FileName__c 
                                            FROM BillTemplate__c
                                            WHERE FileName__c in :validTemplatesMap.keySet()]) {
                                                
            uploadedTemplateNames.add(billTemplate.FileName__c);
        }                             
        // find any that have not been previously uploaded
        Set<Id> templateIdsToUpload = new Set<Id>();
        for (String templateName : validTemplatesMap.keySet()) {
            // add the new ones to the upload list
            if (!uploadedTemplateNames.contains(templateName)) {
                templateIdsToUpload.add(validTemplatesMap.get(templateName));
            }
        }
        // upload Bill Templates
        if(!test.isRunningTest())
            uploadBillTemplates(templateIdsToUpload);
    }
    /******************************************************************************
    @author         Echo:Dependra Singh
    @date           11 Mar 2019
    @description    Method is used to set custom meta data  type data for Enviroment Setting.
    *******************************************************************************/
   /* private static EnvironmentSettings__mdt getEnviromentSettingDetails(){
        
        List<EnvironmentSettings__mdt> mdts = new  List<EnvironmentSettings__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(GlUt_Constants.ENVIROMENTSETTINGBILLTEMPLATELIBRARYQUERY)){
                mdts = (List<EnvironmentSettings__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(GlUt_Constants.ENVIROMENTSETTINGBILLTEMPLATELIBRARYQUERY);  
            }
            return mdts[0];
        }else{
            mdts = (List<EnvironmentSettings__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(GlUt_Constants.ENVIROMENTSETTINGBILLTEMPLATELIBRARYQUERY);
            return mdts[0];
        }
    }*/

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           30 Oct 2017
    @param          Set<Id> - template Ids
    @description    Executes the template upload ansynchronously
    *******************************************************************************/
    @future(callout=true)
    public static void UploadBillTemplates(Set<Id> templateIdsToUpload) {
        for (Id templateId : templateIdsToUpload) {
            BlIn_ExecutePDFTemplateUpload.UploadTemplate(templateId);
        }
    }
}