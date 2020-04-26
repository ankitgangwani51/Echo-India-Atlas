/**********************************************************************************************
@author         Accenture : Shivangi Gaur
@date           18-Sep-2017
@description:   Controller class for CuAp_HHCustomerEditOverride lightning component.
Revision(s):    Shivangi Gaur -- 21-12-2017 -- Updated class name as per naming standards.
                Shivangi Gaur -- 22-12-2017 -- Incorporated review comments on AT-439 dated 21-12-2017.
                Shivangi Gaur -- 04-01-2018 -- Incorporated review comments on AT-439 dated 03-01-2018.
@Revision        AT-3985, Tarun, modified class name as per security reviews
**********************************************************************************************/
public with sharing class CuAp_HHCustomerEditOverrideCtrlr {
    
    //Variable declaration start
    private static final String CLASS_NAME = 'CuAp_HHCustomerEditOverrideCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    public static string recTypeName;
        
    //Variable declaration end
    /**********************************************************************************************
    @author         Accenture: Shivangi Gaur
    @date           18-Sep-2017
    @return         String
    @params         Id
    @description    This method returns the record type name for the account/ contact record being edited.
    **********************************************************************************************/ 
    @AuraEnabled
    public static string getHHAccountRecordTypeName(Id recordId){
        if(recTypeName != null){
            return recTypeName;
        }
        else{
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            try {
                if(sObjName == GlUt_Constants.OBJACCOUNT){
                    Account accObj = (Account) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsAccount.ACCOUNTAPINAME, Id.valueOf(recordId), 
                                                                                  new List<String>{GlUt_APIConstantsAccount.RECORD_TYPE_ID});
                    //Account accObj = [Select id, RecordTypeId from Account where id =: recordId limit 1];
                    recTypeName = Schema.SObjectType.Account.getRecordTypeInfosById().get(accObj.RecordTypeId).getName();
                }
                else if(sObjName == GlUt_Constants.OBJCONTACT){ 
                    //Contact conObj = [Select id, RecordTypeId from Contact where id =: recordId limit 1];
                    Contact conObj = (Contact) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContact.CONTACTAPINAME, Id.valueOf(recordId), 
                                                                                  new List<String>{GlUt_APIConstantsContact.RECORDTYPEID});
                    recTypeName = Schema.SObjectType.Contact.getRecordTypeInfosById().get(conObj.RecordTypeId).getName();
                }
            } catch (exception e) {
                GlUt_Logger.logException(e);
            }
            finally {
                GlUt_Logger.writeLogsToDatabase();
            }
            return recTypeName;
        }                    
    }
}