/***************************************************************************************************
@author        Echo : Dependra Singh
@date          29 May 2018
@description:  
@group         Utility
               AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************************************/
public with sharing class GlUt_CorrespondenceHandler {
    
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_CorrespondenceHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           06 Jun 2018
    @param          String correspondenceType, Id accountId, 
    Id contractId, Id contactId, Id paymentPlanTypeId, 
    Id paymentMethodId, String accountType
    @return         void
    @description    Create an EmailMessage using the associated template and send the email to the email address 
    associated with the ‘Printed Letter’ contact and Create a PDF request record related to the Account, 
    Contact and Contract that has been found / passed in
    *******************************************************************************/
    public static void CreateCorrespondence(String correspondenceType, Id accountID, Id contractId, Id contactId,Id paymentPlanTypeId, Id paymentMethodId, String accountType) {
        
        //if CorrespondenceType or accountID are not populated do not continue         
        // If account id is populated.
        if(accountID != null && string.isNotBlank(CorrespondenceType)){
            List<BillingContract__c> contractList = new List<BillingContract__c>();
            List<Contact> contactList = new List<Contact>();
            List<Account> accountList = new List<Account>();
            
            if(string.isBlank(AccountType)){
                accountList =[SELECT Id, RecordTypeId, RecordType.Name FROM Account WHERE Id =: accountID];
                if(!accountList.isEmpty()){
                    AccountType = accountList[0].RecordType.Name;
                }
            }
            System.debug(DEBUG + 'AccountType: ' + AccountType);
            
            //If Contract ID isn’t populated retrieve the ID of the first active Contract associated with the Account 
            if(contractId == null ){
                contractList = [SELECT  Id, Name,AccountName__c, Status__c, PaymentMethodType__c, CurrentPaymentPlanType__c 
                                FROM BillingContract__c WHERE AccountName__c =: accountID 
                                AND Status__c =:System.Label.GlAp_ContractStatusActive];
                System.debug(DEBUG + 'contactList2: ' + contactList);
                if(!contractList.isEmpty()){
                    contractId = contractList[0].Id;
                    if(contractList[0].PaymentMethodType__c != null){
                        PaymentMethodId = contractList[0].PaymentMethodType__c;
                    }
                    if(contractList[0].CurrentPaymentPlanType__c != null){
                        PaymentPlanTypeId = contractList[0].CurrentPaymentPlanType__c;
                    }
                }
            }else{
                //If Payment Plan Type ID isn’t populated retrieve the Contact and use the value in Current Payment Plan Type 
                //If Payment Method Type ID isn’t populated retrieve the Contact and use the value in Payment Method Type 
                if(PaymentPlanTypeId == null  || PaymentMethodId == null ){
                    contractList = [SELECT  Id, Name, AccountName__c, Status__c, PaymentMethodType__c, CurrentPaymentPlanType__c 
                                    FROM BillingContract__c WHERE Id = :contractId ];
                    System.debug(DEBUG + 'contactList1: ' + contactList);
                    if(contractList[0].PaymentMethodType__c != null){
                        PaymentMethodId = contractList[0].PaymentMethodType__c;
                    }
                    if(contractList[0].CurrentPaymentPlanType__c != null){
                        PaymentPlanTypeId = contractList[0].CurrentPaymentPlanType__c;
                    }
                }
            }
            
            // select a matching Template Setting
            TemplateSetting__c matchedTemplateSetting;
            for (TemplateSetting__c TemplateSetting : [select Id, 
                                                       Name, 
                                                       Type__c, 
                                                       BillingEvent__c, 
                                                       AccountType__c, 
                                                       PaymentMethodType__c, 
                                                       PaymentPlanType__c, 
                                                       EmailTemplateId__c, 
                                                       TemplateName__c, 
                                                       TemplateMapping__c 
                                                       from TemplateSetting__c 
                                                       where Type__c = :correspondenceType]) {
                                                           
                                                           // check for a perfect match first
                                                           if (paymentMethodId != null && TemplateSetting.PaymentMethodType__c == paymentMethodId 
                                                               && paymentPlanTypeId != null && TemplateSetting.PaymentPlanType__c == paymentPlanTypeId 
                                                               && String.isNotBlank(accountType) && TemplateSetting.AccountType__c == accountType) {
                                                                   matchedTemplateSetting = TemplateSetting; // found an exact match
                                                                   break;
                                                                   // no perfect match yet, so check for the default match
                                                               } 
                                                           else 
                                                               if (TemplateSetting.PaymentMethodType__c == null 
                                                                   && TemplateSetting.PaymentPlanType__c == null 
                                                                   && String.isBlank(TemplateSetting.AccountType__c)) {
                                                                       matchedTemplateSetting = TemplateSetting; // found the default match
                                                                   }
                                                       }
            
            if (matchedTemplateSetting != null) {
                generateCorrespondence(matchedTemplateSetting, accountId, contactId, contractId, correspondenceType);
            }
            
        } else {
            System.debug(DEBUG + '============ Correspondence type or accountID not found============');
        }
    }
    
    /******************************************************************************
@author         Echo: Dependra Singh
@date           31 May 2018
@param          TemplateSetting__c TemplateSetting, Id accountId, Id contactId, Id contractId, string correspondenceType 
@return         Void 
@description    Method is used to perform an operation based on template.
*******************************************************************************/
    private static void generateCorrespondence(TemplateSetting__c TemplateSetting, Id accountId, Id contactId, Id contractId, String correspondenceType){
        System.debug(DEBUG + 'TemplateSetting: ' + TemplateSetting);
        
        if (String.isNotBlank(TemplateSetting.EmailTemplateId__c)) {
            
            // Send an email using this email template 
            EmailTemplate objEmailTemplate = [Select Id, Name from EmailTemplate where Name = :TemplateSetting.TemplateName__c]; 
            Id recipientId = GlUt_AccountUtilities.getContactByCustomSetting();
            if (objEmailTemplate.Id != null && recipientId != null) {
                sendEmailUsingEmailTemplate(recipientId, objEmailTemplate.Id);
            }
            
        } else if (String.isNotBlank(TemplateSetting.TemplateMapping__c)) {
            
            //Create a PDF request record related to the Account, Contact and Contract that has been found / passed in
            createPDFRequestRecord(accountId, contactId, contractId, correspondenceType, TemplateSetting.Id);
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           31 May 2018
    @param           
    @return         Id 
    @description    Method is used to Get the contact id based on email address which we are getting from custom setting.
    *******************************************************************************/
    /*private static Id getContactByCustomSetting(){
        string printLetterEmailAddress = '';
        List<Contact> contactList = new List<Contact>();
        // Need to pass profile id or user id. 
        ConfigureTemplate__c templateSetting = ConfigureTemplate__c.getOrgDefaults();
        if(templateSetting.PrintedLetterEmailAddress__c != null){
            printLetterEmailAddress = templateSetting.PrintedLetterEmailAddress__c;
        }
        if(string.isNotBlank(printLetterEmailAddress)){
            contactList = [Select Id, Email from Contact where Email =:printLetterEmailAddress];
        }         
        System.debug(DEBUG + 'contactList: ' + contactList);
        if(!contactList.isEmpty() && contactList[0] != null){
            return contactList[0].Id;
        }else{
            return null;
        }
    }*/
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           31 May 2018
    @param          Id recipientId , Id objTemplateId
    @return         Void 
    @description    Method is used to send an email.
    *******************************************************************************/
    private static void sendEmailUsingEmailTemplate(Id recipientId, Id objTemplateId){
        //Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(recipientId); // Specify who the email should be sent to.
        mail.setSaveAsActivity(false); 
        mail.setTemplateId(objTemplateId);
        mails.add(mail);
        System.debug(DEBUG + 'mails: ' + mails);
        //Send all emails in the master list
        Messaging.sendEmail(mails);
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           31 May 2018
    @param          Id accountId, Id contactId, Id contractId, string correspondenceType
    @return         PDFRequest__c 
    @description    Method is used to create PDF Request record based on parameter.
*******************************************************************************/
    public static PDFRequest__c createPDFRequestRecord(Id accountId, Id contactId, Id contractId, string correspondenceType, Id idTemplateSetting){
        PDFRequest__c objPdfRequest = new PDFRequest__c();
        if(accountId != null){
            objPdfRequest.Account__c = accountId;
            objPdfRequest.Contact__c = contactId;
            objPdfRequest.BillingContract__c = contractId;
            objPdfRequest.CorrespondenceType__c= correspondenceType ;
            objPdfRequest.Status__c   =  System.Label.GlUt_PDFRequestStatusPending;
            objPdfRequest.SourceType__c = System.Label.GlUt_PDFRequestSourceTypeDataTransferXML;
            if(idTemplateSetting != null)
                objPdfRequest.PDFTemplate__c = idTemplateSetting;
            objPdfRequest = (PDFRequest__c) GlUt_FieldSecurity.cleanseFields(objPdfRequest, false);//AT-4891 Code Check Marx Changes Starts/Ends Here.
            insert objPdfRequest;
            System.debug(DEBUG + 'objPdfRequest: ' + objPdfRequest); 
        }
        
        if(objPdfRequest.id != null )
            return objPdfRequest;
        else 
            return null;
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           04 Jun 2018
    @param          List<PDFRequest__c> - pdfRequests (required fields: CorrespondenceType__c, 
    account__r.RecordTypeId, 
    contract__r.PaymentMethodType__c, 
    contract__r.CurrentPaymentPlanType__c)
    @return         Map<Id, PDFXLSTMapping__c> - map of PDF XSLT maps keyed on the pdf request Id
    @description    Works out which template to use for each request
    *******************************************************************************/
    public static Map<Id, TemplateMapping__c> getTemplateSettings(List<PDFRequest__c> pdfRequests) {
        Map<Id, TemplateMapping__c> templateSettingMap = new Map<Id, TemplateMapping__c>();
        
        // build a list of correspondence types to contrain the template query
        Set<String> correspondenceTypes = new Set<String>();
        for (PDFRequest__c pdfRequest : pdfRequests) {
            correspondenceTypes.add(pdfRequest.CorrespondenceType__c);
        }
        
        // get all the templates relevant for these correspondence types
        List<TemplateSetting__c> templates = [select Id, 
                                              TemplateMapping__c, 
                                              TemplateMapping__r.PDFTemplate__c, 
                                              TemplateMapping__r.XSLTDocument__c, 
                                              Type__c, 
                                              AccountType__c, 
                                              PaymentMethodType__c, 
                                              PaymentPlanType__c
                                              from TemplateSetting__c 
                                              where Type__c in :correspondenceTypes];
        
        // build a map of the templates keyed on the request Ids
        for (PDFRequest__c pdfRequest : pdfRequests) {
            
            // check each template setting for a match
            TemplateMapping__c matchedTemplate;
            for (TemplateSetting__c template : templates) {
                Id templateAccountTypeId = String.isNotBlank(template.AccountType__c) 
                    ? Schema.SObjectType.Account.getRecordTypeInfosByName().get(template.AccountType__c).getRecordTypeId() 
                    : null;
                
                // check for a perfect match first
                if (pdfRequest.CorrespondenceType__c == template.Type__c 
                    && pdfRequest.account__r.RecordTypeId == templateAccountTypeId  
                    && pdfRequest.BillingContract__r.PaymentMethodType__c == template.PaymentMethodType__c 
                    && pdfRequest.BillingContract__r.CurrentPaymentPlanType__c == template.PaymentPlanType__c) {
                        
                        matchedTemplate = new TemplateMapping__c(Id = template.TemplateMapping__c, 
                                                                 PDFTemplate__c = template.TemplateMapping__r.PDFTemplate__c, 
                                                                 XSLTDocument__c = template.TemplateMapping__r.XSLTDocument__c);
                        break;      // quit looking once a perfect match found
                        
                        // no perfect match yet, so check for the default match
                    } else if (pdfRequest.CorrespondenceType__c == template.Type__c 
                               && String.isBlank(template.AccountType__c) 
                               && template.PaymentMethodType__c == null 
                               && template.PaymentPlanType__c == null) {
                                   
                                   matchedTemplate = new TemplateMapping__c(Id = template.TemplateMapping__c, 
                                                                            PDFTemplate__c = template.TemplateMapping__r.PDFTemplate__c, 
                                                                            XSLTDocument__c = template.TemplateMapping__r.XSLTDocument__c);
                               }
            }
            
            // add the template to the map (will be null if no acceptable template found)
            templateSettingMap.put(pdfRequest.Id, matchedTemplate);
        }
        
        System.debug(DEBUG + 'templateSettingMap: ' + templateSettingMap);
        return templateSettingMap;      
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           28 June 2018
    @description    Wrapper Class for Create Correspondence utility in Bulk record Scenario.
    *******************************************************************************/
    //AT-3124 Starts Here
    public class ContainerWrapper {
        public Id accountId;
        public Id recordId;
        public String correspondenceType;
        public Id contactId;
        public String status;
        
        public ContainerWrapper(Id accountId,Id recordId,String correspondenceType,Id contactId,String status){
            this.accountId = accountId;
            this.recordId = recordId;
            this.correspondenceType = correspondenceType;
            this.contactId = contactId;
            this.status = status;
        }
        //AT-3124 Ends Here
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           28 June 2018
    @param          List<ContainerWrapper> wrapperList
    @return         PDFRequest__c 
    @description    Create an EmailMessage using the associated template and send the email to the email address 
    associated with the ‘Printed Letter’ contact and Create a PDF request record related to the Account, 
    Contact and Contract that has been found / passed in
    *******************************************************************************/
    public static List<ContainerWrapper> CreateCorrespondence(List<ContainerWrapper> wrapperList) {
        //AT-3124 Starts Here
        Map<Id,String> mapOfAccountId2CorrespondenceType  = new  Map<Id,String>(); 
        Map<Id,String> mapOfAccountId2AccountType  = new  Map<Id,String>(); 
        Map<Id,BillingContract__c> mapOfAccountId2ActiveContract  = new  Map<Id,BillingContract__c>();
        Map<Id,String> mapOfRecordId2Status = new Map<Id,String>();
        Map<Id,Id> mapOfAccountId2Contact = new Map<Id,Id>();
        Savepoint sp = Database.setSavepoint();
        try {
            if(!wrapperList.isEmpty()){
                // Account Id and Correspondence Type is must in order to process the records in bulk.
                // If you have contract then account Id can be fetch from Active contract.
                for(ContainerWrapper wrapperRecord: wrapperList){
                    if(wrapperRecord.accountId == null || string.isBlank(wrapperRecord.correspondenceType))
                        wrapperRecord.status = PyBt_Constants.BANK_ACCOUNT_ACTION_ERROR;
                    else if(wrapperRecord.accountId != null && string.isNotBlank(wrapperRecord.correspondenceType)){
                        wrapperRecord.status = PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED;
                        mapOfAccountId2CorrespondenceType.put(wrapperRecord.accountId,wrapperRecord.correspondenceType); // Map of Account Id and Correspondece Type.
                    }
                }
                System.debug(DEBUG + 'mapOfAccountId2CorrespondenceType: ' + mapOfAccountId2CorrespondenceType);
                List<BillingContract__c> accountSpecificContractList = new List<BillingContract__c>();
                List<BillingContract__c> contractList = new List<BillingContract__c>();
                List<Account> accountList = new List<Account>();
                if(!mapOfAccountId2CorrespondenceType.isEmpty()){
                    //Fetch account record Type on the basis of account Ids.
                    accountList = [SELECT Id, RecordTypeId, RecordType.Name FROM Account WHERE Id In: mapOfAccountId2CorrespondenceType.keySet()];
                    if(!accountList.isEmpty()){
                        for(Account acc: accountList){
                            mapOfAccountId2AccountType.put(acc.Id,acc.RecordType.Name);
                        }
                    }
                    System.debug(DEBUG + 'mapOfAccountId2AccountType: ' + mapOfAccountId2AccountType);
                    
                    //If Payment Plan Type ID isn’t populated retrieve the Contract and use the value in Current Payment Plan Type 
                    //If Payment Method Type ID isn’t populated retrieve the Contract and use the value in Payment Method Type 
                    accountSpecificContractList = [SELECT  Id,
                                                   Name,
                                                   AccountName__c,
                                                   Status__c,
                                                   PaymentMethodType__c,
                                                   CurrentPaymentPlanType__c 
                                                   FROM BillingContract__c WHERE AccountName__c In:mapOfAccountId2CorrespondenceType.keySet() 
                                                   AND Status__c =:System.Label.GlAp_ContractStatusActive];
                    System.debug(DEBUG + 'accountSpecificContractList: ' + accountSpecificContractList);
                    for(BillingContract__c contracts: accountSpecificContractList){
                        mapOfAccountId2ActiveContract.put(contracts.AccountName__c,contracts);
                    }
                }
                System.debug(DEBUG + 'mapOfAccountId2ActiveContract: ' + mapOfAccountId2ActiveContract);
                //AT-3124 Ends Here
                // select a matching Template Setting
                Map<Id,TemplateSetting__c> mapOfAccountId2MatchedTemplateSetting = new Map<Id,TemplateSetting__c>();
                if(mapOfAccountId2CorrespondenceType.values().size() > 0){
                    Map<Id,TemplateSetting__c> mapOfTemplateId2TemplateSetting  = new  Map<Id,TemplateSetting__c>([select Id, 
                                                                                                                   Name, 
                                                                                                                   Type__c, 
                                                                                                                   BillingEvent__c, 
                                                                                                                   AccountType__c, 
                                                                                                                   PaymentMethodType__c, 
                                                                                                                   PaymentPlanType__c, 
                                                                                                                   EmailTemplateId__c, 
                                                                                                                   TemplateName__c, 
                                                                                                                   TemplateMapping__c 
                                                                                                                   from TemplateSetting__c 
                                                                                                                   where Type__c In: mapOfAccountId2CorrespondenceType.values()]);
                    
                    if(mapOfTemplateId2TemplateSetting.values().size() > 0){
                        for(Id accountId: mapOfAccountId2ActiveContract.keySet()){
                            BillingContract__c contracts = mapOfAccountId2ActiveContract.get(accountId);
                            for(TemplateSetting__c TemplateSetting: mapOfTemplateId2TemplateSetting.values()){
                                // check for a perfect match first
                                if (contracts.PaymentMethodType__c != null && TemplateSetting.PaymentMethodType__c == contracts.PaymentMethodType__c 
                                    && contracts.CurrentPaymentPlanType__c != null && TemplateSetting.PaymentPlanType__c == contracts.CurrentPaymentPlanType__c 
                                    && mapOfAccountId2AccountType.containsKey(contracts.AccountName__c) && TemplateSetting.AccountType__c == mapOfAccountId2AccountType.get(contracts.AccountName__c)) {
                                        System.debug(DEBUG + 'Exact Match');
                                        if(!mapOfAccountId2MatchedTemplateSetting.containsKey(accountId))
                                            mapOfAccountId2MatchedTemplateSetting.put(accountId,TemplateSetting); // found an exact match
                                        // no perfect match yet, so check for the default match
                                    } 
                                else if (TemplateSetting.PaymentMethodType__c == null 
                                         && TemplateSetting.PaymentPlanType__c == null 
                                         && String.isBlank(TemplateSetting.AccountType__c)) {
                                             mapOfAccountId2MatchedTemplateSetting.put(accountId,TemplateSetting); // found the default match
                                             System.debug(DEBUG + 'Default Match');
                                         }
                            }
                        }
                    }
                }
                
                if (!mapOfAccountId2MatchedTemplateSetting.isEmpty()) {
                    generateCorrespondence(wrapperList, mapOfAccountId2MatchedTemplateSetting,  mapOfAccountId2ActiveContract, mapOfAccountId2CorrespondenceType);
                }
                
            } else {
                System.debug(DEBUG + '============ No Record To Process ============');
            }
        }
        catch (exception e) {
            Database.rollback(sp);
            GlUt_Logger.logException(e);
            System.debug(DEBUG + 'Error == ' + e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return wrapperList;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           28 June 2018
    @param          Map<Id,TemplateSetting__c> mapOfAccountId2MatchedTemplateSetting, Map<Id,Contract__c> mapOfAccountId2ActiveContract,
                    Map<Id,String> mapOfAccountId2CorrespondenceType
    @return         Void 
    @description    Method is used to perform an operation based on template.
    *******************************************************************************/
    private static void generateCorrespondence(List<ContainerWrapper> wrapperList, 
                                               Map<Id,TemplateSetting__c> mapOfAccountId2MatchedTemplateSetting,
                                               Map<Id,BillingContract__c> mapOfAccountId2ActiveContract,
                                               Map<Id,String> mapOfAccountId2CorrespondenceType){
        System.debug(DEBUG + 'mapOfAccountId2MatchedTemplateSetting: ' + mapOfAccountId2MatchedTemplateSetting);
        List<String> templateNameList = new List<String>();
        Map<Id,EmailTemplate> mapOfEmailTemplateId2EmailTemplate = new Map<Id,EmailTemplate>();
        Map<Id,Id> mapOfAccountId2TemplateId = new Map<Id,Id>();
        if(mapOfAccountId2MatchedTemplateSetting.values().size() > 0){
            Id recipientId = GlUt_AccountUtilities.getContactByCustomSetting();
            for(Id accountId :mapOfAccountId2MatchedTemplateSetting.keySet()){
                TemplateSetting__c templateSetting = mapOfAccountId2MatchedTemplateSetting.get(accountId);
                if (String.isNotBlank(templateSetting.EmailTemplateId__c)) {
                    templateNameList.add(templateSetting.TemplateName__c);
                }
                else if (String.isNotBlank(templateSetting.TemplateMapping__c)) {
                    mapOfAccountId2TemplateId.put(accountId,templateSetting.Id);
                }
            }
            System.debug(DEBUG + 'mapOfAccountId2TemplateId: ' + mapOfAccountId2TemplateId);
            if(!templateNameList.isEmpty()){
                // Send an email using this email template 
                List<EmailTemplate> emailTemplateList = [Select Id, Name from EmailTemplate where Name In: templateNameList]; 
                for(EmailTemplate objEmailTemplate : emailTemplateList){
                    if(objEmailTemplate.Id != null && recipientId != null) {
                        sendEmailUsingEmailTemplate(recipientId, objEmailTemplate.Id);
                    }
                }
            }
            //Create a PDF request record related to the Account, Contact and Contract that has been found / passed in
            if(!mapOfAccountId2TemplateId.isEmpty())
              createPDFRequestRecord(wrapperList, mapOfAccountId2ActiveContract, mapOfAccountId2CorrespondenceType, mapOfAccountId2TemplateId);
        }
    }
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           28 June 2018
    @param          Map<Id,Id> mapOfAccountId2TemplateId, Map<Id,Contract__c> mapOfAccountId2ActiveContract,
                    Map<Id,String> mapOfAccountId2CorrespondenceType
    @return         Void 
    @description    Method is used to create PDF Request record based on parameter.
    *******************************************************************************/
    private static void createPDFRequestRecord(List<ContainerWrapper> wrapperList, 
                                               Map<Id,BillingContract__c> mapOfAccountId2ActiveContract,
                                               Map<Id,String> mapOfAccountId2CorrespondenceType,
                                               Map<Id,Id> mapOfAccountId2TemplateId){
        List<PDFRequest__c> pdfRequestList = new List<PDFRequest__c>();
        for(ContainerWrapper wrapperRecord : wrapperList){
            if(wrapperRecord.accountId != null 
               && string.isNotBlank(wrapperRecord.correspondenceType) 
               && mapOfAccountId2TemplateId.containsKey(wrapperRecord.accountId) 
               && mapOfAccountId2CorrespondenceType.containsKey(wrapperRecord.accountId)
               && mapOfAccountId2ActiveContract.containsKey(wrapperRecord.accountId)){
                   
                PDFRequest__c objPdfRequest = new PDFRequest__c();
                objPdfRequest.Account__c = wrapperRecord.accountId;
                objPdfRequest.Contact__c = wrapperRecord.contactId;
                objPdfRequest.BillingContract__c = mapOfAccountId2ActiveContract.get(wrapperRecord.accountId).Id;
                objPdfRequest.CorrespondenceType__c= mapOfAccountId2CorrespondenceType.get(wrapperRecord.accountId);
                objPdfRequest.Status__c   =  System.Label.GlUt_PDFRequestStatusPending;
                objPdfRequest.SourceType__c = System.Label.GlUt_PDFRequestSourceTypeDataTransferXML;
                objPdfRequest.PDFTemplate__c = mapOfAccountId2TemplateId.get(wrapperRecord.accountId);
                pdfRequestList.add(objPdfRequest);
            }
        }
        //AT-4891 Code Check Marx Changes Starts Here.
        if(!pdfRequestList.isEmpty()){
            pdfRequestList = (List<PDFRequest__c>) GlUt_FieldSecurity.cleanseFields(pdfRequestList, false); 
            Database.insert(pdfRequestList);
        }
        //AT-4891 Code Check Marx Changes Ends Here.
        System.debug(DEBUG + 'pdfRequestList: ' + pdfRequestList);
    }
    
}