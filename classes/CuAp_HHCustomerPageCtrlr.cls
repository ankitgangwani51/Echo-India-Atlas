/**********************************************************************************************
@author         Accenture : Manish Singh
@date           18-Sep-2017
@description:   This is controller Class used to Query & Edit House hold accounts.  
@group          Customer
@Revision(s)    Shivangi Gaur -- 21-12-2017 -- Updated class name as per naming convention.
                Shivangi Gaur -- 21-12-2017 -- Incorporated review comments on AT-436 dated 21-12-2017.
                03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
**********************************************************************************************/
public with sharing class CuAp_HHCustomerPageCtrlr {

    private static final String CLASS_NAME = 'CuAp_HHCustomerCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';    
    public static List<string> accountFields;   
    static{
        //Get Fields from the account Object
        accountFields = new List<string>();
        accountFields.add(GlUt_APIConstantsAccount.ACCOUNTNAMEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.TYPEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.MOBILEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.EMAILAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.BILLINGSTREETAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.BILLINGCITYAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.BILLINGSTATEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.BILLINGCOUNTRYAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.BILLINGPOSTALCODEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.BIRTHDATEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.MAILOPTOUTAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.CONSIDERATIONPASSWORDAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.PREFERREDCONTACTMETHODAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.ACCSHIPSTREET);
        accountFields.add(GlUt_APIConstantsAccount.ACCSHIPSTATE);
        accountFields.add(GlUt_APIConstantsAccount.ACCSHIPCITY);
        accountFields.add(GlUt_APIConstantsAccount.ACCSHIPCOUNTRY);
        accountFields.add(GlUt_APIConstantsAccount.ACCSHIPZIP);
        accountFields.add(GlUt_APIConstantsAccount.PHONEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.NOMINEEAPINAME);
        accountFields.add(GlUt_APIConstantsAccount.NOMINEECONTACTDETAILSAPINAME);
        //accountFields.add(GlUt_APIConstantsAccount.NFPAPINAME);    //AT-4383 //...removed under AU package testing2
         
    }
    public static List<string> contactFields;   
    static{
        //Get Fields from the contact Object
        contactFields = new List<string>();
        contactFields.add(GlUt_APIConstantsContact.CONSALUTATION);
        contactFields.add(GlUt_APIConstantsContact.CONFIRSTNAME);
        contactFields.add(GlUt_APIConstantsContact.CONLASTNAME);
        contactFields.add(GlUt_APIConstantsContact.CONACCID);
        contactFields.add(GlUt_APIConstantsContact.CONMOBILE);
        contactFields.add(GlUt_APIConstantsContact.CONEMAIL);
    }
    public static List<string> contactFields1;   
    static{
        //Get Fields from the contact Object
        contactFields1 = new List<string>();
        contactFields1.add(GlUt_APIConstantsContact.CONSALUTATION);
        contactFields1.add(GlUt_APIConstantsContact.CONFIRSTNAME);
        contactFields1.add(GlUt_APIConstantsContact.CONLASTNAME);
    }
    
    public static List<string> accountBillingAddressFields;   
    static{
        //Get Fields from the Account Object
        accountBillingAddressFields = new List<string>();
        accountBillingAddressFields.add(GlUt_APIConstantsAccount.BILLINGSTREETAPINAME);
        accountBillingAddressFields.add(GlUt_APIConstantsAccount.BILLINGCITYAPINAME);
        accountBillingAddressFields.add(GlUt_APIConstantsAccount.BILLINGSTATEAPINAME);
        accountBillingAddressFields.add(GlUt_APIConstantsAccount.BILLINGCOUNTRYAPINAME);
        accountBillingAddressFields.add(GlUt_APIConstantsAccount.BILLINGPOSTALCODEAPINAME);
    }
    
    public static List<string> accountShippingAddressFields;   
    static{
        //Get Fields from the Account Object
        accountShippingAddressFields = new List<string>();
        accountShippingAddressFields.add(GlUt_APIConstantsAccount.ACCSHIPSTREET);
        accountShippingAddressFields.add(GlUt_APIConstantsAccount.ACCSHIPSTATE);
        accountShippingAddressFields.add(GlUt_APIConstantsAccount.ACCSHIPCITY);
        accountShippingAddressFields.add(GlUt_APIConstantsAccount.ACCSHIPCOUNTRY);
        accountShippingAddressFields.add(GlUt_APIConstantsAccount.ACCSHIPZIP);
    }
    public static List<string> accountInformationFields;   
    static{
        //Get Fields from the Account Object
        accountInformationFields = new List<string>();
        accountInformationFields.add(GlUt_APIConstantsAccount.MOBILEAPINAME);
        accountInformationFields.add(GlUt_APIConstantsAccount.PHONEAPINAME);
        accountInformationFields.add(GlUt_APIConstantsAccount.EMAILAPINAME);
        accountInformationFields.add(GlUt_APIConstantsAccount.PREFERREDCONTACTMETHODAPINAME);
        accountInformationFields.add(GlUt_APIConstantsAccount.MAILOPTOUTAPINAME);
    }
    public static List<string> accountConsiderationFields;   
    static{
        //Get Fields from the Account Object
        accountConsiderationFields = new List<string>();
        accountConsiderationFields.add(GlUt_APIConstantsAccount.CONSIDERATIONPASSWORDAPINAME);
    }
    public static List<string> accountAddtionalInfoFields;   
    static{
        //Get Fields from the Account Object
        accountAddtionalInfoFields = new List<string>();
        accountAddtionalInfoFields.add(GlUt_APIConstantsAccount.BIRTHDATEAPINAME);
        accountAddtionalInfoFields.add(GlUt_APIConstantsAccount.NOMINEEAPINAME);
        accountAddtionalInfoFields.add(GlUt_APIConstantsAccount.NOMINEECONTACTDETAILSAPINAME);
        // accountAddtionalInfoFields.add(GlUt_APIConstantsAccount.NFPAPINAME);    //AT-4383 //...removed under AU package testing2
    }
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           10-Oct-2017
    @description    Account Wrapper class.
    **********************************************************************************************/  
    public class AccountWrapper{
        @AuraEnabled public List<List<GlAp_FieldProps>> contactList;
        @AuraEnabled public List<GlAp_FieldProps> accountBillingList;
        @AuraEnabled public List<GlAp_FieldProps> accountShippingList;
        @AuraEnabled public List<List<GlAp_FieldProps>> accountInformationList;
        @AuraEnabled public List<List<GlAp_FieldProps>> accountConsiderationList;
        @AuraEnabled public List<List<GlAp_FieldProps>> accountAddtionalInfoList;
        public AccountWrapper()
        {
            contactList = new List<List<GlAp_FieldProps>>();
            accountBillingList = new List<GlAp_FieldProps>(); 
            accountShippingList = new List<GlAp_FieldProps>();
            accountInformationList = new List<List<GlAp_FieldProps>>();
            accountConsiderationList= new List<List<GlAp_FieldProps>>();
            accountAddtionalInfoList= new List<List<GlAp_FieldProps>>();
        }
    }     
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           10-Oct-2017
    @param          None
    @return         AccountWrapper
    @description    This method returns the account related information in the form of wrapper. 
    **********************************************************************************************/  
    @AuraEnabled
    public static AccountWrapper getHHAccountFieldProps(){
        AccountWrapper objAccountWrap = new AccountWrapper();
        try {
            objAccountWrap.accountBillingList =  GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_Constants.OBJACCOUNT, accountBillingAddressFields);
            objAccountWrap.accountShippingList =  GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_Constants.OBJACCOUNT, accountShippingAddressFields);
            List<GLAp_FieldProps> fldPropsAccountInfo =  GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_Constants.OBJACCOUNT, accountInformationFields);
            objAccountWrap.accountInformationList =  getObjectFieldProperties2ColumForm(fldPropsAccountInfo);
            List<GLAp_FieldProps> fldPropsConsiderations =  GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_Constants.OBJACCOUNT, accountConsiderationFields);
            objAccountWrap.accountConsiderationList =  getObjectFieldProperties2ColumForm(fldPropsConsiderations);
            List<GLAp_FieldProps> fldPropsAddtionalInfo =  GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_Constants.OBJACCOUNT, accountAddtionalInfoFields);
            objAccountWrap.accountAddtionalInfoList =  getObjectFieldProperties2ColumForm(fldPropsAddtionalInfo);
            List<GLAp_FieldProps> fldPropsContact =  GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_Constants.OBJCONTACT, contactFields1);
            objAccountWrap.contactList =  getObjectFieldProperties2ColumForm(fldPropsContact);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return objAccountWrap;
    }
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           10-Oct-2017
    @param          List<GLAp_FieldProps> fldProps
    @return         List<List<GlAp_FieldProps>>
    @description    This method returns the field properties in two way column format.
    **********************************************************************************************/     
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> getObjectFieldProperties2ColumForm(List<GLAp_FieldProps> fldProps){
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            for(integer i=0; i < fldProps.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(fldProps[i]);
                
                if(secondEntryIndex < fldProps.size()){
                    lstEntry.add(fldProps[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           10-Oct-2017
    @param          Id recordId
    @return         BlAp_CombinedRecord
    @description    This method returns the combined record of HH account and its contact.
    **********************************************************************************************/ 
    @AuraEnabled
    public static BlAp_CombinedRecord getHHAccount(Id recordId){
        BlAp_CombinedRecord HHRec  = new BlAp_CombinedRecord();
        try {
            //If it is new account/ contact, then return new reference of account and contact in BlAp_CombinedRecord
            if (recordId == null) {
                HHRec = emptyHHAccount();            
            }
            else {
                //Fetch reference of account and contact that is being edited and pass them in BlAp_CombinedRecord
                String sObjName = recordId.getSObjectType().getDescribe().getName();
                Contact contact;
                Account account;             
                if (sObjName == GlUt_Constants.OBJACCOUNT) {
                    //Query  if invoked from account
                    account = (Account) GlAp_LightningDataAccess.getRecord(GlUt_Constants.OBJACCOUNT, 
                                                                           recordId, 
                                                                           accountFields);
                    if (account.Id != null) {            
                        for (Contact theContact : (List<Contact>) GlAp_LightningDataAccess.getRecords(GlUt_Constants.OBJCONTACT, contactFields, account.Id, 'AccountId')) {                            
                            contact = theContact;
                            break;
                        }
                    }
                }
                else if (sObjName == GlUt_Constants.OBJCONTACT) { 
                    contact = (Contact) GlAp_LightningDataAccess.getRecord(GlUt_Constants.OBJCONTACT, 
                                                                           recordId, 
                                                                           contactFields);
                    if (contact.AccountId != null) {
                        account = (Account) GlAp_LightningDataAccess.getRecord(GlUt_Constants.OBJACCOUNT, 
                                                                               contact.AccountId, 
                                                                               accountFields);
                    }
                }
                HHRec.uniqueId = recordId;
                HHRec.objectMap = new Map<string, sObject>();            
                if (account != null) {
                    HHRec.objectMap.put(GlUt_Constants.OBJACCOUNT, account);
                }
                if (contact != null) {
                    HHRec.objectMap.put(GlUt_Constants.OBJCONTACT, contact);
                }            
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return HHRec;            
    }
    
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           10-Oct-2017
    @param          none
    @return         BlAp_CombinedRecord
    @description    This method returns the combined record of new reference of HH account and its contact.
    **********************************************************************************************/    
    @AuraEnabled
    public static BlAp_CombinedRecord  emptyHHAccount(){
        BlAp_CombinedRecord  HHAccount = new BlAp_CombinedRecord();
        try {
            HHAccount.objectMap = new Map<string, sObject>();
            HHAccount.objectMap.put(GlUt_Constants.OBJACCOUNT, new Account());
            HHAccount.objectMap.put(GlUt_Constants.OBJCONTACT, new Contact());
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return HHAccount; 
        
    }
    
    /**********************************************************************************************
    @author        Accenture: Shivangi Gaur
    @date          12-Sep-2017
    @param         Contact contactString, Account accountString,String recordId, boolean allowSaveRec
    @return        string
    @description   This method is used to save HH account and contact.
    **********************************************************************************************/
    @AuraEnabled
    public static string saveHHAccount(Contact contactString, Account accountString,String recordId, boolean allowSaveRec) {
        string retVal;
        try {
          //  List<Id> duplicateRecords = new List<Id>();   //AT-3724
            Id AccounthhRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.Label.AccAp_AccountRecordTypeHouseholdAccount).getRecordTypeId(); 
            Id ContacthhRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(system.Label.CuAp_ContactRecordTypeHouseholdContact).getRecordTypeId(); 
            Account accObj = accountString;
            Contact conObj = contactString;
            Account accRec = new Account();
            Contact conRec = new Contact();
            //If account or contact is being edited, then set respective ids in SObject that will be updated
            if(recordId != null){
                //if recordId is of account SObject then query as per account and its related HH contact
                if(recordId.startsWith(CuAp_Constants.ACCURLPREFIX)){
                    accRec = [Select id from Account where id =: recordId limit 1];
                    conRec = [Select id, accountId from Contact where accountId =: recordId limit 1];
                }
                else{
                    //if recordId is of contact SObject then query as per contact and its related HH account
                    conRec = [Select id, accountId from Contact where id =: recordId limit 1];
                    accRec = [Select id from Account where id =: conRec.accountId limit 1];
                }
                accObj.id = accRec.id;
                conObj.id = conRec.id;
            }
            //Concatenate account name field with Salutation, FirstName and LastName from contact
            if(conObj.Salutation == null || conObj.Salutation == ' '){
                accObj.Name= conObj.FirstName + ' ' + conObj.LastName;
            }
            else{
                accObj.Name= conObj.Salutation + ' ' + conObj.FirstName + ' ' + conObj.LastName;
            }
            //Set mappings for fields of account and contact
            accObj.recordtypeId = AccounthhRecordTypeId;
            conObj.MobilePhone = accObj.Mobile__c;
            conObj.Email = accObj.Email__c;
            conObj.MobilePhone = accObj.Mobile__c;
            conObj.MailingStreet = accObj.BillingStreet;
            conObj.MailingState = accObj.BillingState;
            conObj.MailingCity = accObj.BillingCity;
            conObj.MailingCountry = accObj.BillingCountry;
            conObj.MailingPostalCode = accObj.BillingPostalCode;
            conObj.Birthdate = accObj.DateofBirth__c;
            conObj.MailOptOut__c = accObj.MailOptOut__c;
            conObj.ConsiderationPassword__c = accObj.ConsiderationPassword__c;
            conObj.PreferredContactMethod__c = accObj.PreferredContactMethod__c;
            conObj.OtherStreet = accObj.ShippingStreet;
            conObj.OtherState = accObj.ShippingState;
            conObj.OtherCity = accObj.ShippingCity;
            conObj.OtherCountry = accObj.ShippingCountry;
            conObj.OtherPostalCode = accObj.ShippingPostalCode;
            conObj.recordtypeId = ContacthhRecordTypeId;
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = allowSaveRec;
            Database.SaveResult upsertResultAcc;
            //Insert account if recordId is null i.e. it is a new account/ contact to be inserted
            if(recordId == null){
                upsertResultAcc = Database.insert(accObj, dml);
            }
            else{
                //Update account if recordId is null i.e. it is not a new account/ contact
                upsertResultAcc = Database.update(accObj, dml);
            }
            //Check of duplicate rules throw error
            if (!upsertResultAcc.isSuccess()) {
                for (Database.Error error : upsertResultAcc.getErrors()) {
                    if (error instanceof Database.DuplicateError) {   //AT-3724
                     /*   Database.DuplicateError duplicateError = (Database.DuplicateError)error;  
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                        Datacloud.MatchResult matchResult = matchResults[0];
                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                        for (Datacloud.MatchRecord matchRecord : matchRecords) {
                            duplicateRecords.add(matchRecord.getRecord().Id);
                        }
                          retVal = CuAp_Constants.DUPLICATERESP+duplicateRecords;*/  
                          retVal = CuAp_Constants.DUPLICATERESP+ '(' + accObj.Name  + ')';     //AT-3724
                      
                    }
                    else{
                        retVal = error.getMessage();
                    }
                }               
            }
            else{
                conObj.AccountId = accObj.Id;
                conObj = (Contact) GlUt_FieldSecurity.cleanseFields(conObj, false);
                if(recordId == null){
                    Database.SaveResult UpsertResultCon = Database.insert(conObj, dml);
                }
                else{
                    Database.SaveResult UpsertResultCon = Database.update(conObj, dml);
                }
                retVal = accObj.Id;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        //Return Id of the HH account inserted/ updated
        return retVal;
    }
    
    /**********************************************************************************************
    @author         Accenture: Shivangi Gaur
    @date           05-Dec-2017
    @param          None
    @return         List<String>
    @description    This method returns the picklist values for Preferred Contact Method field.
    **********************************************************************************************/
    @AuraEnabled
    public static List<String> preferredContactMethod(){
        List<String> returnOptionsList = new List<String>();
        try {
            List<GlAp_FieldProps> fldProps = GlUt_FieldSecurity.getFieldPropertiesObject(GlUt_Constants.OBJACCOUNT,new List<String>{CuAp_Constants.ACCPREFERREDCONTACT});
            for(GlAp_FieldProps fp : fldProps){
                if(fp.isFLSVisible){
                    returnOptionsList.addAll(fp.pickListEntries.Values());
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return returnOptionsList;
    }
    
    /**********************************************************************************************
    @author         Accenture: Shivangi Gaur
    @date           05-Dec-2017
    @param          None
    @return         List<String>
    @description    This method returns the picklist values for Salutation field.
    **********************************************************************************************/
    @AuraEnabled
    public static List<String> salutationValues(){
        List<String> returnOptionsList = new List<String>();
        try {
            List<GlAp_FieldProps> fldProps = GlUt_FieldSecurity.getFieldPropertiesObject(GlUt_Constants.OBJCONTACT,new List<String>{CuAp_Constants.CONSALUTATION});
            for(GlAp_FieldProps fp : fldProps){
                if(fp.isFLSVisible){
                    returnOptionsList.addAll(fp.pickListEntries.Values());
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return returnOptionsList;
    }
}