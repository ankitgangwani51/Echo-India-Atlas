/******************************************************************************
@author    		Echo: Amit K.
@date      		27-March-2018
@description 	Component controller for close and close New Case.
Revision(s)		03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CsAp_LogCaseCtrlr {
    private static List<string> caseFields;
    static{
        caseFields = new List<string>();
        caseFields.add(GlUt_APIConstantsCase.CASENUMBERAPINAME);
        caseFields.add(GlUt_APIConstantsCase.STATUSAPINAME);
        caseFields.add(GlUt_APIConstantsCase.ORIGINAPINAME);
        caseFields.add(GlUt_APIConstantsCase.OWNERAPINAME);
        caseFields.add(GlUt_APIConstantsCase.CREATEDDATEAPINAME);
        caseFields.add(GlUt_APIConstantsCase.GROUPAPINAME);
        caseFields.add(GlUt_APIConstantsCase.TYPEAPINAME);
      
    }
    private static List<string> retrieveCaseFields;
    static{
        retrieveCaseFields = new List<string>();
        retrieveCaseFields.add(GlUt_APIConstantsCase.REASONAPINAME);
        retrieveCaseFields.add(GlUt_APIConstantsCase.ADVICEGIVENAPINAME);
    }
    
    private static final String CLASS_NAME = 'CsAp_LogCaseCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 23 March 2018
    @params      : 
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back case related fields as List. 
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> getTwoColFormattedCaseFields() {
        try {
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            
            List<GLAp_FieldProps> lstCaseFields = new List<GLAp_FieldProps>();
            lstCaseFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsCase.CASEAPINAME, retrieveCaseFields);
            for(GLAp_FieldProps readingProp: lstCaseFields){ 
                readingProp.showLabel = true;
                readingProp.isEditable = true;
            }
            
            for(integer i=0; i < lstCaseFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstCaseFields[i]);
                if(secondEntryIndex < lstCaseFields.size()){
                    lstEntry.add(lstCaseFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        } 
    }
/**********************************************************************************************
@author         Echo: Amit K.
@date           23 March 2018
@param			string accountId 
@return         instance of wrapper class; this will contain case information and field properties 
@description	This method will collect the required details in wrapper and send it to helper
**********************************************************************************************/    
    @AuraEnabled
    Public static ContainerWrapper getInfoToDisplay(string accountId){
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper(); 
        try {
            //call to method to get field properties
            resultContainer.fieldPropList = getCaseFieldProps();
            //call to method to get case details
            resultContainer.caseList = getOpenCases(accountId);
            //call to method to get case field and it's values
            resultContainer.getCaseFields = getTwoColFormattedCaseFields();
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return resultContainer;
        
    }
/**********************************************************************************************
@author         Echo: Amit K.
@date           23 March 2018
@return         List<GLAp_FieldProps>
@description    This method returns the field properties for each of the fields that are to be displayed on the screen
**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> getCaseFieldProps() {  
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            //Get the field properties for case object
            List<GLAp_FieldProps> caseProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsCase.CASEAPINAME, caseFields);
            //Want to make all of the case fields readonly   
            
            for(GLAp_FieldProps fldProp : caseProps){
                fldProp.isEditable = false;
                fldPropList.add(fldProp);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 23 March 2018
    @return      : List<BlAp_CombinedRecord>
    @parameter   : string accountId
    @description : This method returns the BlAp_CombinedRecord with list of cases, and it's unique-ids, isSelected
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getOpenCases(string accountId){
        String closed = 'Closed';
        List<BlAp_CombinedRecord>  caseComList = new List<BlAp_CombinedRecord>();
        List<Case> caseList = new List<Case>();
        try {
            if(string.isNotBlank(accountId)){
                
                caseList = (List<Case>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCase.CASEAPINAME, 
                                                                            caseFields,
                                                                            accountId, 
                                                                            GlUt_APIConstantsCase.ACCOUNTIDAPINAME);
            }
            for (Case c: caseList){
                BlAp_CombinedRecord objCaseCom = new BlAp_CombinedRecord();            
                objCaseCom.uniqueId = c.Id;
                objCaseCom.isSelected = false;
                objCaseCom.objectMap = new Map<string, sObject>();
                //Create a map of Case related field values
                objCaseCom.objectMap.put(GlUt_APIConstantsCase.CASEAPINAME, c);
                caseComList.add(objCaseCom);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return caseComList;
    }
    
/******************************************************************************
@author      	Echo: Amit K.
@date      		23 March 2018
@param			none
@return			none
@description	Wrapper Class to hold case details, field properties which will be returned to helper
*******************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<GLAp_FieldProps> fieldPropList; 
        @AuraEnabled public List<BlAp_CombinedRecord> caseList;
        @AuraEnabled public List<List<GlAp_FieldProps>> getCaseFields;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 23 March 2018
    @return      : 
    @parameter   : string accountId
    @description : This method used to log and close the case by getting the default value from custom setting.
    **********************************************************************************************/
    @AuraEnabled
    public static void logAndCloseCase(string accountId) { 
        try {
            Map<String,String> additionalFields = new Map<String,String>();
            additionalFields.put(GlUt_APIConstantsCase.STATUSAPINAME,'Closed');
            additionalFields.put(GlUt_APIConstantsCase.ACCOUNTIDAPINAME,accountId);
            GlUt_LogCloseCaseUtilities.closeNewCase(additionalFields);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 23 March 2018
    @return      : 
    @parameter   : List<Id> selectedCaseIds
    @description : This method used to close the case.
    **********************************************************************************************/
    @AuraEnabled
    public static void closeCase(List<Id> selectedCaseIds,string caseReason,string adviceGiven) {
        try {
            GlUt_LogCloseCaseUtilities.closeCase(selectedCaseIds, caseReason, adviceGiven);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}