/****************************************************************************************************************************
@author    		Echo: Sudhir Kumar
@date      		28-Mar-2018
@description 	Component Controller to identify the correct Account that is related to the logged in Community User.
@Revision        AT-3985, Tarun, modified class name as per security reviews
@Revision        AT-3969, Tarun, modified class name as per security reviews
*****************************************************************************************************************************/

public with sharing class CmAp_MyAccountCtrlr {
        
    public static Account objAccount = getCurrentUserAccount();
    public static String recordType = getRecordTypeName();
    private static final String CLASS_NAME = 'CmAp_MyAccountCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			List<List<GLAp_FieldProps>> - twoColFormattedList
	@description	Account Information field properties details
	*******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> getAccountFieldsProps() {
        
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            if(recordType == System.Label.AccAp_AccountRecordTypeHouseholdAccount){
                twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.HHACCINFOFIELDSET);
            }else{
                twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.NHHACCINFOFIELDSET);
            }
            
            for(List<GlAp_FieldProps> lstGlApFieldProps : twoColFormattedList){
                for(GLAp_FieldProps prop : lstGlApFieldProps){
                    prop.isEditable = false;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			List<List<GLAp_FieldProps>> - twoColFormattedList
    @description	Account Address field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> getAccountAddressFieldsProps() {
        
        List<List<GlAp_FieldProps>> twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.ACCADDRESSFIELDSET);
        try {
            Integer size = twoColFormattedList.size();
            for(Integer i = size - 1; i > 0; i--){
                twoColFormattedList.remove(i);
            }
            size = 0;
            for(List<GlAp_FieldProps> lstGlApFieldProps : twoColFormattedList){
                for(GLAp_FieldProps prop : lstGlApFieldProps){
                    prop.isEditable = false;
                    if(size == 0){
                        prop.fieldName = CmAp_Constants.BILLINGADDRESS;
                        prop.fieldLabel = CmAp_Constants.BILLINGADDRESSLABEL ;
                    }else{
                        prop.fieldName = CmAp_Constants.SHIPPINGADDRESS ;
                        prop.fieldLabel = CmAp_Constants.SHIPPINGADDRESSLABEL ;
                    }
                    size += 1;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return twoColFormattedList;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			List<List<GLAp_FieldProps>> - twoColFormattedList
    @description	Account Contact Information field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> getAccountContactFieldsProps() {
        List<List<GlAp_FieldProps>> twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.CONTACTINFOFIELDSET);
        try {
            for(List<GlAp_FieldProps> lstGlApFieldProps : twoColFormattedList){
                for(GLAp_FieldProps prop : lstGlApFieldProps){
                    prop.isEditable = false;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			List<List<GLAp_FieldProps>> - twoColFormattedList
    @description	Account Sic Information field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> getAccountSicFieldsProps() {
        List<List<GlAp_FieldProps>> twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.ACCSICFIELDSET);
        try {
            for(List<GlAp_FieldProps> lstGlApFieldProps : twoColFormattedList){
                for(GLAp_FieldProps prop : lstGlApFieldProps){
                    prop.isEditable = false;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			List<List<GLAp_FieldProps>> - twoColFormattedList
    @description	Account Consideration field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> getAccountConsiderationFieldsProps() {
        List<List<GlAp_FieldProps>> twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.CONSIDERATIONFIELDSET);
        try {
            for(List<GlAp_FieldProps> lstGlApFieldProps : twoColFormattedList){
                for(GLAp_FieldProps prop : lstGlApFieldProps){
                    prop.isEditable = false;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			List<List<GLAp_FieldProps>> - twoColFormattedList
    @description	Account Additional Information field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> getAccountAdditionalFieldsProps() {
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            if(recordType == System.Label.AccAp_AccountRecordTypeHouseholdAccount){
                twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.HHADDITIONALINFOFIELDSET);
            }else{
                twoColFormattedList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(GlUt_APIConstantsAccount.ACCOUNTAPINAME, CmAp_Constants.NHHADDITIONALINFOFIELDSET);
            }
            
            for(List<GlAp_FieldProps> lstGlApFieldProps : twoColFormattedList){
                for(GLAp_FieldProps prop : lstGlApFieldProps){
                    prop.isEditable = false;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			Account - accountRecord
    @description	Account Information record values of logged in user
    *******************************************************************************/
    @AuraEnabled
    public static Account getMyAccountDetails() {
        Account accountRecord;
        try {
            if(recordType == System.Label.AccAp_AccountRecordTypeHouseholdAccount){
                accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.HHACCINFOFIELDSET);
            }else{
                accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.NHHACCINFOFIELDSET);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }

        return accountRecord ;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			Account - accountRecord
    @description	Account Address record values of logged in user
    *******************************************************************************/
    @AuraEnabled
    public static Account getMyAccountAddressDetails() {
        Account accountRecord;
        try {
            accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.ACCADDRESSFIELDSET);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return accountRecord ;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			Account - accountRecord
    @description	Account Contact Information record values of logged in user
    *******************************************************************************/
    @AuraEnabled
    public static Account getMyAccountContactDetails() {
        Account accountRecord;
        try {
            accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.CONTACTINFOFIELDSET);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return accountRecord ;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			Account - accountRecord
    @description	Account Sic record values of logged in user
    *******************************************************************************/
    @AuraEnabled
    public static Account getMyAccountSicDetails() {
        Account accountRecord;
        try {
            accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.ACCSICFIELDSET);
            
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return accountRecord ;
    }
        
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			Account - accountRecord
    @description	Account Consideration record values of logged in user
    *******************************************************************************/
    @AuraEnabled
    public static Account getMyAccountConsiderationDetails() {
        Account accountRecord;
        try {
            accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.CONSIDERATIONFIELDSET);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return accountRecord ;
    }
    
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			Account - accountRecord
    @description	Account Additinonal Information record values of logged in user
    *******************************************************************************/
    @AuraEnabled
    public static Account getMyAccountAdditionalDetails() {
        Account accountRecord;
        try {
            if(recordType == System.Label.AccAp_AccountRecordTypeHouseholdAccount){
                accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.HHADDITIONALINFOFIELDSET);
            }else{
                accountRecord = (Account) GlAp_LightningDataAccess.getRecordByIdAndFieldSetName(GlUt_APIConstantsAccount.ACCOUNTAPINAME, objAccount.Id, CmAp_Constants.NHHADDITIONALINFOFIELDSET);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return accountRecord ;
    }
	
    /******************************************************************************
    @author      	Echo: Mohit Tayal
    @date      		17-Apr-2018
    @param			none
    @return			string - recType
    @description	Account record type of the logged in user
    *******************************************************************************/
    @AuraEnabled
    public static string getRecordTypeName(){
        String recType;
        try {
            recType = CuAp_HHCustomerEditOverrideCtrlr.getHHAccountRecordTypeName(objAccount.Id);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return recType;
    }
    
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		28-Mar-2018
    @param			none
    @return			Account
    @description	Get logged in Community User's Account Details
    *******************************************************************************/
    @AuraEnabled
    public static Account getCurrentUserAccount() {
        Account accountObj;
        try {
            User objUser = [SELECT Id, Contact.AccountId FROM USER WHERE Id = :UserInfo.getUserId()];
            If(objUser != null && objUser.Contact.AccountId != null)  {
                accountObj = new Account(Id = objUser.Contact.AccountId);
            } else if (Test.isRunningTest()) {
                String ACCOUNT_NAME        = 'TestAccount';
                accountObj = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            }
            system.debug('accountObj:: ' + accountObj);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return accountObj ;
    }
}