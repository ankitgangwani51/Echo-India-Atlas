/************************************************************************************************************
@author         Accenture : Luke Emberton
@date           26-Aug-2017
@description:   This is a class used by all lighting components to retrieve data from the database. It takes
                object names along with a list of fields or a fieldset name and uses that to retrieve data
                from the database. It works in conjunction with the GlUt_FieldSecurity class to ensure that the
                user has access to the field (via FLS) and that the field is encrypted
Revision(s)		01 Mar 2018, P Dixon - updated to support parent relationship fields in fieldsets
				02 May 2018, P Dixon - revised to add methods to retrieve cleansed records
**************************************************************************************************************/
public with sharing class GlAp_LightningDataAccess {
        
    private static final String CLASS_NAME = 'GlAp_LightningDataAccess';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /* regularised query method signatures for use in apex controllers */
    public static sObject getRecord(String objectName, Id Id, String fieldSetName) {
    	return getRecordByIdAndFieldSetName(objectName, (String) Id, fieldSetName);
    }
    public static sObject getRecord(String objectName, Id Id, List<String> fieldNames) {
    	return getRecordByIdAndFieldList(objectName, (String) Id, fieldNames);
    }
    public static List<sObject> getRecords(String objectName, String fieldSetName) {
    	return getRecordsByFieldSetName(objectName, fieldSetName);
    }
    public static List<sObject> getRecords(String objectName, List<String> fieldNames) {
    	return getRecordsByFieldList(objectName,  fieldNames);
    }
    public static List<sObject> getRecords(String objectName, String fieldSetName, Id Id, String parentField) {
    	return getRelatedRecordsByFieldSetName((String) Id, parentField, null, null, objectName, fieldSetName);
    }
    public static List<sObject> getRecords(String objectName, String fieldSetName, Id Id, String parentField, String listFilter) {
    	return getRelatedRecordsByFieldSetName((String) Id, parentField, listFilter, null, objectName, fieldSetName);
    }
    public static List<sObject> getRecords(String objectName, String fieldSetName, Id Id, String parentField, String listFilter, String listOrder) {
    	return getRelatedRecordsByFieldSetName((String) Id, parentField, listFilter, listOrder, objectName, fieldSetName);
    }
    public static List<sObject> getRecords(String objectName, List<String> fieldNames, Id Id, String parentField) {
    	return getRelatedRecordsByFieldList((String) Id, parentField, null, null, objectName, fieldNames);
    }
    public static List<sObject> getRecords(String objectName, List<String> fieldNames, Id Id, String parentField, String listFilter) {
    	return getRelatedRecordsByFieldList((String) Id, parentField, listFilter, null, objectName, fieldNames);
    }
    public static List<sObject> getRecords(String objectName, List<String> fieldNames, Id Id, String parentField, String listFilter, String listOrder) {
    	return getRelatedRecordsByFieldList((String) Id, parentField, listFilter, listOrder, objectName, fieldNames);
    }
    public static List<sObject> getRecords(String objectName, List<String> fieldNames, String filterStatements) {
    	return getFilteredRecordsByFieldList(objectName, fieldNames, filterStatements);
    }

    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          string sFieldSetName
    @return         List<string>
    @description	Method to return a list of fields from a field set name
    **********************************************************************************************/
    public static List<string> getFieldSetFields(String objectAPIName, string sFieldSetName){
        List<string> fieldList = new List<string>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectAPIName);
                
        if(sFieldSetName != null){
            List<Schema.FieldSetMember> fldSetMembers = targetType.getDescribe().FieldSets.getMap().get(sFieldSetName).getFields();
        
            for(Schema.FieldSetMember f : fldSetMembers) {
                string fldName = f.fieldPath;
                fieldList.add(fldName);
            } 
        }
        system.debug(DEBUG + 'getFieldSetFields: ' + fieldList);
        return fieldList; 
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          string sFieldSetName
    @param          List<GLAp_FieldProps> fldProps
    @return         List<GLAp_FieldProps> 
    @description 	Method processes a field properties object to update it for the respective
                    fields that are marked as read only in the field set
    **********************************************************************************************/
    @testVisible
    private static List<GLAp_FieldProps> getFieldSetReadOnlyField(String objectAPIName, String fieldSetName, List<GLAp_FieldProps> fieldPropertiesList){
        
        List<GLAp_FieldProps> updatedFieldProperies = new List<GLAp_FieldProps>();
        Map<string, GLAp_FieldProps> fieldPropertiesMap = new Map<string, GLAp_FieldProps>();
        
        // first put the field properties into a map
        for (GLAp_FieldProps fieldProperties : fieldPropertiesList) {
            fieldPropertiesMap.put(fieldProperties.fieldPath, fieldProperties);
        }
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectAPIName);
                
        if (fieldSetName != null) {
            List<Schema.FieldSetMember> fieldSetFields = targetType.getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
        
            for (Schema.FieldSetMember fieldSetField : fieldSetFields) {
                String fieldPath = fieldSetField.fieldPath;
                
                // 28 Feb 2018, P Dixon - only include fields that are in the field properties list
                if (fieldPropertiesMap.keySet().contains(fieldPath)) {
	                GLAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldPath);
	                Boolean required = fieldSetField.getRequired();
	                Boolean DBRequired = fieldSetField.getDBRequired();
	                fieldProperties.isRequired = (required || DBRequired);
	                updatedFieldProperies.add(fieldProperties);
                }
            }
        }
        return updatedFieldProperies; 
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          List<String> fieldNames
    @return         List<GLAp_FieldProps>
    @description	Method that takes an object API Name and also list of field Names to return details 
                    about the fields from the system
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> getObjectsFieldProperties(String objectAPIName, List<String> fieldNames) {
        List<GLAp_FieldProps> fldProps = new List<GLAp_FieldProps>();
        fldProps = GlUt_FieldSecurity.getFieldPropertiesObject(objectAPIName, fieldNames);
        return fldProps;
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          string fieldSetName
    @return         List<GLAp_FieldProps>
    @description	Method that takes an object API Name and also list of field Names to return 
                    details about the fields from the system in lists of 2
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> getObjectsFieldPropertiesByFieldSetNameFor2ColForm(String objectAPIName, string fieldSetName) {
    	System.debug(DEBUG + 'objectAPIName: ' + objectAPIName);
    	System.debug(DEBUG + 'fieldSetName: ' + fieldSetName);
        
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            //GlUt_Logger.logDebug(DEBUG);
            
            //List of fields from the field set Name
            List<string> fieldNames = getFieldSetFields(objectAPIName,  fieldSetName);
            
            //Field properties
            List<GlAp_FieldProps> fldProps = getObjectsFieldProperties(objectAPIName,  fieldNames);
            //Update the field properties to augment the readonly fields from the field set
            fldProps = getFieldSetReadOnlyField(objectAPIName, fieldSetName, fldProps);     
            for (integer i = 0; i < fldProps.size(); i = i + 2) {
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(fldProps[i]);
                
                if (secondEntryIndex < fldProps.size()) {
                    lstEntry.add(fldProps[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
        } catch (exception e) {
            system.debug(' Here is the exception');
            //GlUt_Logger.logException(e);
        }
        finally {
            //GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }  
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          string fieldSetName
    @return         List<GLAp_FieldProps>
    @description	Method that takes an object API Name and also fieldset Name to return details 
                    about the fields from the system
    **********************************************************************************************/
    @AuraEnabled
    public static List<GlAp_FieldProps> getObjectsFieldPropertiesByFieldSetName(String objectAPIName, string fieldSetName) {
        List<string> fieldNames = getFieldSetFields(objectAPIName,  fieldSetName);
        List<GlAp_FieldProps> fldProps = getObjectsFieldProperties(objectAPIName,  fieldNames);
        
        fldProps = getFieldSetReadOnlyField(objectAPIName, fieldSetName, fldProps);	
        return fldProps;
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          List<String> fieldNames
    @param          string filterStatements 
    @return         List<sObject>
    @description	Method to retrieve a list of records from the database filtered by a particular
                    where clause
    **********************************************************************************************/
    @AuraEnabled
    public static List<sObject> getFilteredRecordsByFieldList(String objectAPIName, List<String> fieldNames, String filterStatements ) {
        system.debug('getFilteredRecordsByFieldList::objectAPIName==>' + objectAPIName);
        system.debug('getFilteredRecordsByFieldList::fieldNames==>' + fieldNames);
        system.debug('getFilteredRecordsByFieldList::filterStatements==>' + filterStatements);
        try {
            return GlUt_FieldSecurity.getCleansedRecords(objectAPIName, fieldNames, filterStatements);
            
        } catch (Exception e) {
            GlUt_Logger.logException(e);
            return new List<sObject>();
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          List<String> fieldNames
    @return         List<sObject> 
    @description	Method that takes an object API Name and also list of field Names to return records
                    from the database
    **********************************************************************************************/
    @AuraEnabled
    public static List<sObject> getRecordsByFieldList(String objectAPIName, List<String> fieldNames) {
    	return getFilteredRecordsByFieldList(objectAPIName, fieldNames, '');
    }
        
    /**********************************************************************************************
    @author         Echo Patrick Dixon
    @date           02 May 2018
    @param          String sId
    @param          String parentField
    @param          String listFilter
    @param          String listOrder
    @param          String objectAPIName
    @param          String fieldSetName
    @return         List<sObject> 
    @description	Method that takes an object API Name and list of field names to return records from 
                    the database
	Revision(s)		02 May 2018, P Dixon - added listOrder param but retained previous method signature for compatibility
    **********************************************************************************************/
    @AuraEnabled
    public static List<sObject> getRelatedRecordsByFieldList(String sId, String parentField, String listFilter, String objectAPIName, List<String> fieldNames) {
    	return getRelatedRecordsByFieldList(sId, parentField, listFilter, null, objectAPIName, fieldNames);
    }
	
    private static List<sObject> getRelatedRecordsByFieldList(String sId, String parentField, String listFilter, String listOrder, String objectAPIName, List<String> fieldNames) {

        String filterStatements = listFilter == null ? '' : ' AND ' + listFilter;
        filterStatements = listOrder == null ? filterStatements : filterStatements + ' ' + listOrder;
        
        String sWhereClause = String.format(' WHERE {0} {1}', new List<String>{parentField + '= \'' + sId + '\'', filterStatements});
        
        System.debug(DEBUG + 'sWhereClause: ' + sWhereClause);
        
        List<sObject> retVal = getFilteredRecordsByFieldList(objectAPIName, fieldNames, sWhereClause);
        System.debug(DEBUG + 'retVal: ' + retVal);
        
        return retVal;
    }

    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String sId
    @param          String parentField
    @param          String listFilter
    @param          String listOrder
    @param          String objectAPIName
    @param          String fieldSetName
    @return         List<sObject> 
    @description	Method that takes an object API Name and fieldset name to return records from 
                    the database
	Revision(s)		02 May 2018, P Dixon - added listOrder param but retained previous method signature for compatibility
    **********************************************************************************************/
    @AuraEnabled
    public static List<sObject> getRelatedRecordsByFieldSetName(String sId, String parentField, String listFilter, String objectAPIName, String fieldSetName) {      
        return getRelatedRecordsByFieldSetName(sId, parentField, listFilter, null, objectAPIName, fieldSetName);
    }
    
    private static List<sObject> getRelatedRecordsByFieldSetName(String sId, String parentField, String listFilter, String listOrder, String objectAPIName, String fieldSetName) {      
        List<string> fieldNames = getFieldSetFields(objectAPIName,  fieldSetName);
        System.debug(DEBUG + 'fieldNames: ' + fieldNames);
        
        return getRelatedRecordsByFieldList(sId, parentField, listFilter, listOrder, objectAPIName, fieldNames);
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          String fieldSetName
    @return         List<sObject>
    @description	Method that takes an object API Name and fieldset name to return records 
                    from the database
    **********************************************************************************************/
    @AuraEnabled
    public static List<sObject> getRecordsByFieldSetName(String objectAPIName, String fieldSetName) {
        List<String> fieldNames = getFieldSetFields(objectAPIName, fieldSetName);      
        List<sObject> retVal = getRecordsByFieldList(objectAPIName, fieldNames);
        return retVal;
    }
       
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          string sId
    @param          List<String> fieldNames
    @return         sObject
    @description	Method that takes an object API Name and list of field names to return a 
                    single record with the sId passed in
    **********************************************************************************************/
    @AuraEnabled
    public static sObject getRecordByIdAndFieldList(String objectAPIName, String sId, List<String> fieldNames) {
        
        if (sId != null) {
	    	for (sObject record : getFilteredRecordsByFieldList(objectAPIName, fieldNames, 'where Id = \'' + sId + '\'')) {
	    		return record;
	    	}
        }
    	
		// return a new SObject if no records found
		return Schema.getGlobalDescribe().get(objectAPIName).newSObject();
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          string sId
    @param          String fieldSetName
    @return         sObject
    @description	Method that takes an object API Name and fieldset name to return a 
                    single record with the sId passed in
    **********************************************************************************************/
    @AuraEnabled
    public static sObject getRecordByIdAndFieldSetName(String objectAPIName, String sId, String fieldSetName) {
        
        System.debug(DEBUG + 'getRecordByIdAndFieldSetName: objectAPIName: ' + objectAPIName + ' sId: ' + sId + ' fieldSetName: ' + fieldSetName);
        sObject retVal;     
        List<String> fieldNames = getFieldSetFields(objectAPIName,  fieldSetName);
        retVal = getRecordByIdAndFieldList(objectAPIName, sId, fieldNames);   
        return retVal;
        
    }
  
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          String objectAPIName
    @param          String recordClientString
    @return         String
    @description	Method that takes the JSON string of an object along with the API name to
                    do an update of the record in the database (work around passing sObjects in 
                    Lightning Components)
    **********************************************************************************************/
    @AuraEnabled
    public static String updateObject(String objectAPIName, String recordClientString) {
        system.Debug('recordClientString====='+recordClientString);
        String retval;
        Type t2 = Type.forName(objectAPIName);        
        sObject sObj = (sObject)JSON.deserialize(recordClientString, t2); 
        retval = updateObjectRecord(sObj);
        return retVal;
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          sObject sObj
    @return         List<sObject>
    @description	Method that takes an object and calls lightning security cleanse fields method 
                    to update it    
    **********************************************************************************************/
    public static String updateObjectRecord(sObject sObj) {
        String retval;
        system.debug('sObj===='+sObj);
        //Determine which fields are present in the object
        Set<string> fieldNamesSet = sObj.getPopulatedFieldsAsMap().keySet();
        system.debug('fieldNamesSet===='+fieldNamesSet);
        List<string> fieldNames = new List<string>(fieldNamesSet);
        
        //Add the object to a list so that it can be sent to the cleanse fields parameter
        List<sObject> objToClean = new List<sObject>();
        objToClean.add(sObj);
        
        
        //Call the cleansed fields utility to ensure that the user is not writing to fields to which
        //they dont have edit rights
        List<sObject> retList = GlUt_FieldSecurity.cleanseFields(objToClean, fieldNames, false);
        system.debug('retList===='+retList);

        //Retrive the cleansed object from the return parameter
        sObject sObjToUpdate = retList[0];
                        
        //Call the update method to save the record to the database
        try {    
           // GlUt_Logger.logDebug(GlUt_Constants.EXECUTING + DEBUG);
            update sObjToUpdate;
            retval = null;
            return retval;
        }
        catch (DMLException ex) {
           // GlUt_Logger.logException(ex);
            retval = ex.getMessage();
            return retval;
        }
        catch (Exception ex) {
            //GlUt_Logger.logException(ex);
            retval = ex.getMessage();
            return retval;
        }
        finally {   
           // GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          sObject sObj
    @return         List<sObject>
    @description	Method that takes an object and calls lightning security cleanse fields method 
                    to update it    
    **********************************************************************************************/
    public static List<sObject> retrieveListOfRecordsByQueryString(String sQueryString) {
        
        //Parse the query to get the query fields
        sQueryString = sQueryString.toUpperCase();
        String selectFields = sQueryString.substringBetween('SELECT', 'FROM');
        selectFields = selectFields.replace(' ', '');
        
        String[] fieldSet = selectFields.split(','); 
        
        //Query the database
        List<SObject> retQuery = Database.query(sQueryString);
        
        return retQuery;
    }
  
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Mar 2018
	@param			Map<String, SObject> - map of records keyed on object api name
	@param			Object - the populated field object returned by getPopulatedFieldsAsMap()
	@param			String - the child object api name
	@param			String - the field name key returned by getPopulatedFieldsAsMap()
	@description 	Adds a parent record populated in getPopulatedFieldsAsMap() 
					to the map of records keyed on the object api name.
					Called recursively to cope with parents of parents etc.
	*******************************************************************************/
	private static void addParentRecordWithFields(Map<String, SObject> recordMap, Object populatedField, String objectName, String fieldName) {
		
		// get the parent object name from the parent relationship field
		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		Schema.SObjectField fieldResult = fieldMap.get(fieldName.replace('__r', '__c'));
		String parentObjectName;
		for (Schema.SObjectType reference : fieldResult.getDescribe().getReferenceTo()) {
		    parentObjectName = reference.getDescribe().getName();
		}
		System.debug(DEBUG + 'parentObjectName: ' + parentObjectName);
		
		SObject parentRecord;
		if (recordMap.keySet().contains(parentObjectName)) {
			parentRecord = recordMap.get(parentObjectName);
			
		} else {
			
			// instantiate the parent record
	    	parentRecord = Schema.getGlobalDescribe().get(parentObjectName).newSObject();
		}
		System.debug(DEBUG + 'parentRecord: ' + parentRecord);
		    	
		// create new updater record to allow non-createable fields to be added
        GlUt_ObjectUpdater parentRecordUpdater = new GlUt_ObjectUpdater(parentObjectName);

    	// populate the parent fields
		Map<String, Object> parentFieldValueMap = ((SObject) populatedField).getPopulatedFieldsAsMap();
    	for (String parentFieldName : parentFieldValueMap.keySet()) {
    		
			// if the parent field value is another parent record
			Object parentPopulatedField = parentFieldValueMap.get(parentFieldName);
			System.debug(DEBUG + 'String.valueOf(parentPopulatedField): ' + String.valueOf(parentPopulatedField));
			if (parentPopulatedField != null && String.valueOf(parentPopulatedField).contains(':{')) {

				// add the parent record to the map
				addParentRecordWithFields(recordMap, parentPopulatedField, parentObjectName, parentFieldName);

			} else {
		        parentRecordUpdater.addField(parentFieldName, parentFieldValueMap.get(parentFieldName));
			}
		}
		
		System.debug(DEBUG + 'parentRecordUpdater: ' + parentRecordUpdater);
		recordMap.put(parentObjectName, (SObject) parentRecordUpdater.getSObject());
	}
	
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Mar 2018
	@param			String - the object api name
	@param			SObject - the record
	@description 	Returns a map of all records (including parents) 
					included in the populated record, keyed on the object api name 
	*******************************************************************************/
	public static Map<String, SObject> getRecordMapWithFields(String objectName, SObject record) {
		Map<String, SObject> recordMap = new Map<String, SObject>();

		// add the base record to the map
		recordMap.put(objectName, record);

		// check if it contains parent field values
		Map<String, Object> fieldValueMap = record.getPopulatedFieldsAsMap();
		for (String fieldName : fieldValueMap.keySet()) {

			// if the field value is a parent record
			Object populatedField = fieldValueMap.get(fieldName);
			System.debug(DEBUG + 'String.valueOf(populatedField): ' + String.valueOf(populatedField));
			if (populatedField != null && String.valueOf(populatedField).contains(':{')) {
				
				// add the parent record to the map
				addParentRecordWithFields(recordMap, populatedField, objectName, fieldName);
			}
		}
		System.debug(DEBUG + 'recordMap: ' + recordMap);
		return recordMap;
	}
    
    /**********************************************************************************************
    @author      : Echo : Mohit Tayal
    @date        : 24 Aug 2018
    @return      : Map<Id,String>
    @parameter   : List<Id> recordIdString
    @description : AT - 3441 This method returns the map of object Id having Name field record.
    **********************************************************************************************/
    public static Map<Id,String> getRecordName(List<Id> recordIdString){
        Map<Id,String> referenceIdNameMap = new Map<Id,String>();
        if(!recordIdString.isEmpty()) {
            String objName = getObjectType(recordIdString[0]);
            List<SObject> retList = Database.query('SELECT Name FROM ' + objName + ' WHERE Id = :recordIdString');
            if(!retList.isEmpty()){
                for(Sobject obj : retList){
                    referenceIdNameMap.put(obj.Id, (String)obj.get('Name'));
                }
            }
        }
        return referenceIdNameMap;
    }
    
    /**********************************************************************************************
    @author      : Echo : Mohit Tayal
    @date        : 24 Aug 2018
    @return      : string
    @parameter   : string objectId
    @description : AT- 3441 This method returns object name on the basis of record Id.
    **********************************************************************************************/ 
    public static string getObjectType(string objectId){
        Id sId = (Id)objectId;
        return sId.getSobjectType().getDescribe().getName();
    }
	
}