/************************************************************************************************************
@author    		Accenture : Luke Emberton
@date      		26-Aug-2017
@description: 	This class is utilised to 
@revision       MT - Corrected the naming convention of class from GlAp_ReferenceFieldController to GlAp_ReferenceFieldCtrlr
**************************************************************************************************************/
public with sharing class GlAp_ReferenceFieldCtrlr {
	  
    private static final String CLASS_NAME = 'GlAp_ReferenceFieldCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';	
    private static final List<String> fields = new List<string>{
        GlUt_Constants.NAMEAPINAME
            };        
	/**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		26-Aug-2017
	@param			String searchKeyWord
	@param			string sObjectType
	@return			List<sObject>
	@description	This method takes and object name and a search strnkg to do fuzzy / like
					query on the object to find records of that name
	**********************************************************************************************/
    @AuraEnabled
    public static List<sObject> fetchRecords(String searchKeyWord, string sObjectType) {
        //String searchKey = searchKeyWord + '%';
        List<sObject> returnList = new List<sObject>();
        try {
            string sOQLQuery = 'SELECT Id, Name FROM ' + sObjectType + ' WHERE Name LIKE \'' + String.escapeSingleQuotes(searchKeyWord) + '%\'' ; //AT-4433,Clayton Code Review Starts/Ends here
            List<SObject> lstOfObjects = Database.query(sOQLQuery);      	
            
            
            for (sObject objRec: lstOfObjects) {
                returnList.add(objRec);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return returnList;
    }
		
	/**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		26-Aug-2017
	@param			String searchKeyWord
	@return			string
	@description	Method used to get the object type from the id
	**********************************************************************************************/
	@AuraEnabled
	public static string getObjectType(string recordIdString){
		Id sId = (Id)recordIdString;
		string objName = sId.getSobjectType().getDescribe().getName();
		return objName;
	}
		
	/**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		26-Aug-2017
	@param			String searchKeyWord
	@return			string
	@description	Method used to get the reference object type from the field name
	**********************************************************************************************/
	@AuraEnabled
    public static string getObjectTypeForField(string fieldName, string parentObject){
        
        string refObj ='';
        try {
            //Get describe details from the object
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(parentObject).getDescribe().fields.getMap();
            
            //Get specific field details
            Schema.SObjectField fld = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fldDesRes = fld.getDescribe();
            
            List <Schema.sObjectType> objRef = fldDesRes.getReferenceTo();
            if(objRef.size()>0){
                refObj = objRef[0].getDescribe().getName();		 	
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return refObj;
    }
	
	/**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		26-Aug-2017
	@param			String recordIdString
	@return			string
	@description	Method used to retireve the name record for a passed in id so that the
					display shows the record name and not the salesforce id
	**********************************************************************************************/
	@AuraEnabled
	public static string getRecordName(string recordIdString){
		string recName ='';
        try {
            if(!String.isBlank(recordIdString)) {
                String objName = getObjectType(recordIdString);
                String filterStatement =' WHERE Id = \'' + String.escapeSingleQuotes(recordIdString) + '\'';
                List<SObject> retList = GlAp_LightningDataAccess.getRecords(objName,fields,filterStatement);
                if(retList.size() > 0){
                    SObject retVal = retList[0];
                    recName = (String)retVal.get('Name');
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return recName;
	}
    
}