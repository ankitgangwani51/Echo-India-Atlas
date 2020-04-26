/******************************************************************************
@author        Echo: Amit K.
@date          27-March-2018
@description   Class for GlUt_LogCloseCaseUtilities 
*******************************************************************************/
public with sharing class GlUt_LogCloseCaseUtilities {
    
    private static final String CLASS_NAME = 'GlUt_LogCloseCaseUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    public static final String STATUS = 'Closed';
    
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 23 March 2018
    @return      : 
    @parameter   : Map<String,String> additionalFields
    @description : This method used to log and close the case
    **********************************************************************************************/
    public static void closeNewCase(Map<String,String> additionalFields){
        Map<string,LogCloseCaseFieldMapping__c> mapOfFieldNameToObject = LogCloseCaseFieldMapping__c.getAll();
        Set<String> apiName = getFieldMetaData(Case.getSObjectType().getDescribe());
        if(!additionalFields.isEmpty())
            apiName.addAll(additionalFields.keySet());
        Case logCloseCase = new Case();
        for (String field : apiName) { 
            if(mapOfFieldNameToObject.containsKey(field)){
                logCloseCase.put(field,mapOfFieldNameToObject.get(field).Value__c);
            }else{
                logCloseCase.put(field,additionalFields.get(field)); 
            }
        }
        try {
            if(logCloseCase!=null){
                logCloseCase  = (Case) GlUt_FieldSecurity.cleanseFields(logCloseCase, false);
                insert logCloseCase;
            }
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 23 March 2018
    @return      : 
    @parameter   : List<Id> selectedCaseIds,string caseReason,string adviceGiven
    @description : This method used to close the case
    **********************************************************************************************/
    public static void closeCase(List<Id> selectedCaseIds,string caseReason,string adviceGiven){
        try {
            if(!selectedCaseIds.isEmpty()){
                List<Case> closedCaseList = new List<Case>();
                for(Id id: selectedCaseIds){
                    Case closeCase = new Case();
                    closeCase.Status = STATUS;
                    closeCase.Id = id;
                    closeCase.Reason = caseReason;
                    closeCase.AdviceGiven__c = adviceGiven;
                    closedCaseList.add(closeCase);
                }
                if(!closedCaseList.isEmpty()){
                    closedCaseList = (List<Case>) GlUt_FieldSecurity.cleanseFields(closedCaseList, false);
                    update closedCaseList;
                }
            }
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 23 March 2018
    @return      : 
    @parameter   : Schema.DescribeSObjectResult dsor
    @description : This method used to get the field Names from Metadata.
    **********************************************************************************************/
    public static Set<String> getFieldMetaData(Schema.DescribeSObjectResult dsor) {
        Set<String>apiNames =  new Set<String>();
        for(string apiName : dsor.fields.getMap().keySet()){
            apiNames.add(apiName);
        }
        return apiNames;
    }

}