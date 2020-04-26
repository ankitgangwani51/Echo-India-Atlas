/************************************************************************************************************
@author         Accenture: Luke Emberton
@date           26-Aug-2017
@description:   This class is used by all classes that retrive data from the database to ensure that FLS
                and encryption rules are respected. This is essential for Lightning Component classes
                it is a requirement for standard Apex classes to pass the AppExchange security review
Revision(s)     01 Mar 2018, P Dixon - updated to support parent relationship fields in fieldsets
Revision(s)     28 Mar 2019, Tarun Gupta - Updated to return the map of string,sobject where we can get the Id in map after cleanse
**************************************************************************************************************/
public class GlUt_FieldSecurity_Amit {
      
    private static final String CLASS_NAME = 'GlUt_FieldSecurity';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          sObject obj
    @return         string
    @description    Private Method that is used to identify and return the type of an sObject
    **********************************************************************************************/
    private static string getTypeofSObject(sObject obj){
        return obj.getSObjectType().getDescribe().getName();       
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          string objectName
    @return         Map<String, Schema.SObjectField> 
    @description    Method calls the describe method to find out the properties of all fields on the object
    **********************************************************************************************/
    private static Map<String, Schema.SObjectField> getFieldMap(string objectName){

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        return fieldMap;        
    }
        
    /**********************************************************************************************
    @author         Accenture: Luke Emberton/Accenture: Ashish Tiwari
    @date           10-Sep-2017
    @param          String - apiname of the field
    @param          String - value to match
    @param          string operation
    @param          Boolean - true if this is the first 'like' clause on the query
    @return         String - 'search' clause to append to query
    @description    Builds a 'search' clause to append to a query
    **********************************************************************************************/
    public static String appendSearchClause(String fieldName, String fieldVal) {
        return appendSearchClause(fieldName, fieldVal, CuAp_Constants.OPERATIONCONTAINS, true);
    }
    public static String appendSearchClause(String fieldName, String fieldVal, Boolean isStart) {
        return appendSearchClause(fieldName, fieldVal, CuAp_Constants.OPERATIONCONTAINS, isStart);
    }
    public static String appendSearchClause(String fieldName, String fieldVal, String operation) {
        return appendSearchClause(fieldName, fieldVal, operation, true);
    }
    public static String appendSearchClause(String fieldName, String fieldVal, String operation, Boolean isStart) {
        String retVal = isStart ? '' : ' AND ';
        if (operation == CuAp_Constants.OPERATIONEQUALS) {
          retVal += String.escapeSingleQuotes(fieldName) + ' = \'' + String.escapeSingleQuotes(fieldVal) + '\'';
        }
        if (operation == CuAp_Constants.OPERATIONNOTEQUALSTO) {
          retVal += String.escapeSingleQuotes(fieldName) + ' != \'' + String.escapeSingleQuotes(fieldVal) + '\'';
        }
        if (operation == CuAp_Constants.OPERATIONCONTAINS) {
            retVal += String.escapeSingleQuotes(fieldName) + ' LIKE \'%' + String.escapeSingleQuotes(fieldVal) + '%\'';
        } 
        if (operation == CuAp_Constants.OPERATIONNOTCONTAINS) {
            retVal += ' (NOT ' + String.escapeSingleQuotes(fieldName) + ' LIKE \'%' + String.escapeSingleQuotes(fieldVal) + '%\')';
        }
        if (operation == CuAp_Constants.OPERATIONIN) {
            retVal += String.escapeSingleQuotes(fieldName) + ' IN \'' + String.escapeSingleQuotes(fieldVal) + '\'';
        }
        return retVal;
    }

	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		11 May 2018
	@param			String - filter statement string
	@return			String - the string in quotes
	@description 	Transforms a string  into a string in quotes
	*******************************************************************************/
	public static String QuotedString(String s) {
		return '\'' + s + '\'';
	}

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           20 Apr 2018
    @param          List<String> - list of Strings
    @return         String - a bracketed list of the quoted Strings
    @description    Transforms list of Strings into a string of comma seperated Strings
    *******************************************************************************/
    public static String StringsToString(List<String> strings) {
        return '(\'' + String.join(strings, '\', \'') + '\')';
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           20 Apr 2018
    @param          Set<String> - list of Strings
    @return         String - a bracketed list of the quoted Ids
    @description    Transforms set of Strings into a string of comma seperated Stringss
    *******************************************************************************/
    public static String StringsToString(Set<String> strings) {
        List<String> stringList = new List<String>();
        stringList.addAll(strings);
        return StringsToString(stringList);
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           20 Apr 2018
    @param          List<Id> - list of Ids
    @return         String - a bracketed list of the quoted Ids
    @description    Transforms list of Ids into a string of comma seperated Ids
    *******************************************************************************/
    public static String IdsToString(List<Id> Ids) {
        return '(\'' + String.join(Ids, '\', \'') + '\')';
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           28 March 2019
    @param          List<String> - list of Ids
    @return         String - a bracketed list of the quoted string
    @description    Transforms list of string into a string of comma seperated Ids
    *******************************************************************************/
    public static String ListToString(List<string> lstString) {
        return '(\'' + String.join(lstString, '\', \'') + '\')';
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           20 Apr 2018
    @param          Set<Id> - set of Ids
    @return         String - a bracketed list of the quoted Ids
    @description    Transforms set of Ids into a string of comma seperated Ids
    *******************************************************************************/
    public static String IdsToString(Set<Id> Ids) {
        List<Id> idList = new List<Id>();
        idList.addAll(Ids);
        return IdsToString(idList);
    }

    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           01 Mar 2018
    @param          String - object api name
    @param          List<String> - list of field names with paths
    @return         List<GlAp_FieldProps> - list of field properties
    @description    Retrieves the field properties for the accessible fields for an object and list of field names passed in
    **********************************************************************************************/
    public static List<GlAp_FieldProps> getFieldPropertiesObject(String objectName, List<String> fieldNames) {
        
        Map<String, GlAp_FieldProps> fieldPropertiesMap = getFieldPropertiesMap(objectName, fieldNames);
        System.debug(DEBUG + 'fieldPropertiesMap.values(): ' + fieldPropertiesMap.values());
        return fieldPropertiesMap.values();
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Mar 2018
    @param          Map<String, Object> - map of the populated fieldnames (including parent refernces)
    @param          Object - the populated field object returned by getPopulatedFieldsAsMap()
    @param          String - the field name key returned by getPopulatedFieldsAsMap()
    @description    Adds parent record fields populated in getPopulatedFieldsAsMap() to the set of fields.
                    Called recursively to cope with parents of parents etc.
    *******************************************************************************/
    private static void addParentPopulatedFields(Map<String, Object> recordMap, Object populatedField, String fieldName) {
        
        // populate the parent fields
        Map<String, Object> parentFieldValueMap = ((SObject) populatedField).getPopulatedFieldsAsMap();
        for (String parentFieldName : parentFieldValueMap.keySet()) {
            
            // if the parent field value is another parent record
            Object parentPopulatedField = parentFieldValueMap.get(parentFieldName);
            if (parentPopulatedField != null && String.valueOf(parentPopulatedField).contains(':{')) {

                // add the parent fields to the map
                addParentPopulatedFields(recordMap, parentPopulatedField, parentFieldName);

            } else {
                
                // add the field name to the map
                recordMap.put(fieldName + '.' + parentFieldName, parentPopulatedField);
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Mar 2018
    @param          SObject - the record
    @return         Map<String, Object> - map of the populated fieldnames (including parent references)
    @description    Returns a set all populated fields (including parent fields) in a record
    *******************************************************************************/
    private static Map<String, Object> getPopulatedFields(SOBject record) {
        
        Map<String, Object> recordMap = new Map<String, Object>();

        // check if it contains parent field values
        Map<String, Object> fieldValueMap = record.getPopulatedFieldsAsMap();
        System.debug(DEBUG + 'fieldValueMap: ' + fieldValueMap);
        Schema.SObjectType sObjectType = record.getSObjectType();
        string objectName = String.valueOf(sObjectType);
          Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        List<String> strList = new List<String>(objectFields.keySet());
        strList.sort();
        
        System.debug('******!!'+strList);
        for (String fieldName : fieldValueMap.keySet()) {
            System.debug('****'+fieldName);
            if(strList.contains(fieldName.toLowerCase())){
                // if the field value is a parent record
                Object populatedField = fieldValueMap.get(fieldName);
                if (populatedField != null && String.valueOf(populatedField).contains(':{')) {
                    
                    // add the parent fields to the map
                    addParentPopulatedFields(recordMap, populatedField, fieldName);
                    
                } else {
                    
                    // add the field to the map
                    recordMap.put(fieldName, populatedField);
                }
            }
        }
        System.debug(DEBUG + 'recordMap: ' + recordMap);
        return recordMap;
    }
    
    /**********************************************************************************************
    @author         Accenture: Patrick Dixon
    @date           10 Oct 2017
    @param          SObject obj
    @param          Boolean isRead
    @return         SObject
    @description    This method takes the record and processes it without needing the
                    list of fields to be provided. Any fields which are not accessible to the user are 
                    removed from the sObject any fields that are encrypted have their value obscufated. 
                    A parameter is passed in to detail whether this is for reading or writing fields. 
                    If the field is encrypted and the user does not have permission to see encrypted data 
                    the field is removed from the sObject so its value is not overwritten
    **********************************************************************************************/
    public static sObject cleanseFields(sObject obj, boolean isRead) {       
        List<sObject> objList = new List<sObject>{obj};
            for (sObject retObj : cleanseFields(objList, isRead)) {
                return retObj;
            }
        return null;        
    }
    
    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           01 Mar 2018
    @param          List<SObject> - list of records to cleanse
    @param          Boolean - true if for reading fields/false for writing
    @return         List<SObject> - list of cleansed records
    @description    Takes the list of records and processes them without needing the
                    list of fields to be provided. Any fields which are not accessible to the user are 
                    removed from the sObject any fields that are encrypted have their value obscufated. 
                    A parameter is passed in to detail whether this is for reading or writing fields. 
                    If the field is encrypted and the user does not have permission to see encrypted data 
                    the field is removed from the sObject so its value is not overwritten
    **********************************************************************************************/
    public static List<SObject> cleanseFields(List<SObject> records, Boolean isRead) {       
        Schema.SObjectType sObjectType = records.getSObjectType();
        if (!records.isEmpty() && records != null) { 
            Map<String, GlAp_FieldProps> fieldPropertiesMap = new Map<String, GlAp_FieldProps>();       // map of GlAp_FieldProps objects keyed on field name with path
            
            String objectName;
            for (SObject record : records) {
                objectName = objectName == null ? getTypeofSObject(record) : objectName;        // records are all the same object
                
                // build a map of field properties objects for the populated fields, populated with the parent object and field name
                for (String fieldPath : getPopulatedFields(record).keySet()) {
                    if (!fieldPropertiesMap.keySet().contains(fieldPath)) {
                        fieldPropertiesMap.put(fieldPath, new GlAp_FieldProps(objectName, fieldPath));
                    }
                }
            }
            // cleanse the records
            // CLB-125- Issues identified by Clayton- 08-04-2019 -> Dependra Singh
            if(sObjectType != null){
                String listType = 'List<' + sObjectType + '>';
                List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
                records = cleanseRecordsUsingFieldProperties(records, isRead, fieldPropertiesMap);
                castRecords.addAll(records);
                return castRecords;
            }else{
                return cleanseRecordsUsingFieldProperties(records, isRead, fieldPropertiesMap);
            }
            
        }
        return records;     // nothing to cleanse
    }
        
    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           02 Mar 2018
    @param          List<SObject> - list of records to cleanse
    @param          Boolean - true if for reading fields/false for writing
    @return         List<SObject> - list of cleansed records
    @description    Takes the list of records and associated fields and processes them so that
                    any fields which are not accessible to the user are removed from the sObject
                    any fields that are encrypted have their value obscufated. A parameter is passed
                    in to detail whether this is for reading or writing fields. If the field is
                    encrypted and the user does not have permission to see encrypted data the field
                    is removed from the sObject so its value is not overwritten
    **********************************************************************************************/
    public static List<SObject> cleanseFields(List<SObject> records, List<String> fieldNames, Boolean isRead) {
         Schema.SObjectType sObjectType = records.getSObjectType();
        // add the Id field to the field names if it's not there already
        if (!new Set<String>(fieldNames).contains('Id')) {
            fieldNames.add('Id');
        }

        if (!records.isEmpty() && records!= null) {  
            Map<String, GlAp_FieldProps> fieldPropertiesMap = new Map<String, GlAp_FieldProps>();       // map of GlAp_FieldProps objects keyed on field name with path
    
            String objectName;
            for (SObject record : records) {
                objectName = getTypeofSObject(record);
                break;      // records are all the same object
            }
            
            // build a map of field properties objects for the list of fields, populated with the parent object and field name
            for (String fieldPath : fieldNames) {
                if (!fieldPropertiesMap.keySet().contains(fieldPath)) {
                    fieldPropertiesMap.put(fieldPath, new GlAp_FieldProps(objectName, fieldPath));
                }
            }
            
            // cleanse the records
            // CLB-125- Issues identified by Clayton- 08-04-2019 -> Dependra Singh
            if(sObjectType != null){
                 String listType = 'List<' + sObjectType + '>';
                  List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
                records = cleanseRecordsUsingFieldProperties(records, isRead, fieldPropertiesMap);
                castRecords.addAll(records);
                return castRecords;
            }else{
                 return cleanseRecordsUsingFieldProperties(records, isRead, fieldPropertiesMap);
            }
        }
        return records;     // nothing to cleanse
    }

    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           02 Mar 2018
    @param          List<SObject> - list of records to be cleansed
    @param          Boolean - check for read
    @param          Map<String, GlAp_FieldProps> - map of GlAp_FieldProps objects keyed on field name with path
    @param          Map<String, Map<String, Schema.SObjectField>> - map of field properties maps keyed on the object type
    @return         List<SObject> - list of cleansed records
    @description    Use the field properties map to cleanse the records
    **********************************************************************************************/
    private static List<SObject> cleanseRecordsUsingFieldProperties(List<SObject> records, Boolean isRead, Map<String, GlAp_FieldProps> fieldPropertiesMap) {
        
        // map of field properties maps keyed on the object type
        Map<String, Map<String, Schema.SObjectField>> objectFieldPropertiesMap = new Map<String, Map<String, Schema.SObjectField>>();
        // build a map of the schema field properties for all the field parents
        for (String fieldPath : fieldPropertiesMap.keySet()) {
            String parentObject = fieldPropertiesMap.get(fieldPath).parentObject;
            if (!objectFieldPropertiesMap.keySet().contains(parentObject)) {
                objectFieldPropertiesMap.put(parentObject, getFieldMap(parentObject));
            }
        }
        // populate the field properties objects with the required properties from the schema field properties
        for (String fieldPath : fieldPropertiesMap.keySet()) {
            GlAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldPath);
            String parentObject = fieldPropertiesMap.get(fieldPath).parentObject;
            String fieldName = fieldPropertiesMap.get(fieldPath).fieldName;       
            Schema.DescribeFieldResult schemaFieldProperties = objectFieldPropertiesMap.get(parentObject).get(fieldName).getDescribe(); 
            fieldProperties.isFLSVisible = schemaFieldProperties.isAccessible();
            fieldProperties.isEncrypted = schemaFieldProperties.isEncrypted();
            fieldProperties.isEditable = schemaFieldProperties.isUpdateable() || schemaFieldProperties.isCreateable();      // isCreateable allows access to master/detail fields on insert
        }
        List<SObject> cleansedRecords = new List<SObject>();
        for (SObject record : records) {
            SObject cleansedRecord = cleanseRecord(record, fieldPropertiesMap, isRead);
            cleansedRecords.add(cleansedRecord);
        }        
        return cleansedRecords;        
    }
    
    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           01 Mar 2018
    @param          SObject - the record to check
    @param          Map<String, GlAp_FieldProps> - map of field properties keyed on the field name with path
    @param          Boolean - true if for reading fields/false for writing
    @return         SObject - checked record
    @description    Go through all of the fields on the record and either blank out or obscufate
    **********************************************************************************************/
    private static SObject cleanseRecord(SObject record, Map<String, GlAp_FieldProps> fieldPropertiesMap, Boolean isRead) {
        
        String objectName = getTypeofSObject(record);

        // create new updater record to allow fields to be removed or updated
        GlUt_ObjectUpdater newRecord = new GlUt_ObjectUpdater(objectName);
        System.debug(DEBUG + 'newRecord1: ' + newRecord);       
        // Work out which fields have a value on the object already (e.g. are set)
        Map<String, Object> recordMap = getPopulatedFields(record);

        // loop through the list of fields
        for (String fieldPath : fieldPropertiesMap.keySet()) {
            String fieldName = fieldPath;   
            // if the field is populated on the object
            if (recordMap.keySet().contains(fieldName)) {
                
                // get its properties
                GlAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldPath);    
                Boolean isEncrypted = fieldProperties.isEncrypted;
                Boolean isAccessible = fieldProperties.isFLSVisible;
                Boolean isEditable = fieldProperties.isEditable;
                            
                if (isRead) {
                    
                    // add the field if it's accessible or it's the Id field
                    if (isAccessible || (fieldName == 'Id')) {
                        newRecord.addField(fieldName, recordMap.get(fieldName));
                    
                    // add and obscufate if the field is encrypted
                    } else if (isEncrypted) {
                        
                        // if the field is numeric give it a numeric dummy value, if it is text give it a text value
                        Object dummyValue = fieldProperties.fieldType == 'number' || fieldProperties.fieldType == 'currency' 
                                            ? '999999' 
                                            : '"xxxxxxxx"';
                        newRecord.addField(fieldName, dummyValue);
                    }
                    
                } else {        // write
                    // add the field if it's not encryted and editable or it's the Id field             
                    if ((!isEncrypted && isEditable) || fieldName == 'Id') {
                        newRecord.addField(fieldName, recordMap.get(fieldName));	
                    }
                }
            } 
        }
        
        // get the revised record back
        System.debug(DEBUG + 'newRecord: ' + newRecord);
        return (SObject) newRecord.getSObject();
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           20 Apr 2018
    @param          String - the object's api Name
    @param          List<String> - the field names required
    @return         Map<String, GlAp_FieldProps> - map of GlAp_FieldProps objects keyed on the full field name
    @description    
    *******************************************************************************/
    private static Map<String, GlAp_FieldProps> getFieldPropertiesMap(String objectName, List<String> fieldNames) {
        Map<String, GlAp_FieldProps> fieldPropertiesMap = new Map<String, GlAp_FieldProps>();

        // build a map of field properties objects for these fields, populated with the parent object and field name
        for (String fieldName : fieldNames) {
            if (!fieldPropertiesMap.keySet().contains(fieldName)) {
                fieldPropertiesMap.put(fieldName, new GlAp_FieldProps(objectName, fieldName));
            }
        }
        System.debug(DEBUG + 'fieldPropertiesMap: ' + fieldPropertiesMap);
        
        // map of field properties maps keyed on the object type
        Map<String, Map<String, Schema.SObjectField>> objectFieldPropertiesMap = new Map<String, Map<String, Schema.SObjectField>>();

        // build a map of the schema field properties for all the field parents
        for (String fieldPath : fieldPropertiesMap.keySet()) {
            
            String parentObject = fieldPropertiesMap.get(fieldPath).parentObject;

            if (!objectFieldPropertiesMap.keySet().contains(parentObject)) {
                objectFieldPropertiesMap.put(parentObject, getFieldMap(parentObject));
            }
        }
        System.debug(DEBUG + 'objectFieldPropertiesMap: ' + objectFieldPropertiesMap);

        // populate the FLS properties objects from the schema field properties
        for (String fieldPath : fieldPropertiesMap.keySet()) {

            GlAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldPath);
            String parentObject = fieldPropertiesMap.get(fieldPath).parentObject;
            String fieldName = fieldPropertiesMap.get(fieldPath).fieldName;
            System.debug(DEBUG + 'parentObject: ' + parentObject);
            System.debug(DEBUG + 'fieldName: ' + fieldName);

            Schema.DescribeFieldResult schemaFieldProperties = objectFieldPropertiesMap.get(parentObject).get(fieldName).getDescribe();                
            fieldProperties.isFLSVisible = schemaFieldProperties.isAccessible();

            if (fieldProperties.isFLSVisible) {
                fieldProperties.isEncrypted = schemaFieldProperties.isEncrypted();
                fieldProperties.isEditable = schemaFieldProperties.isUpdateable() || schemaFieldProperties.isCreateable();      // isCreateable allows access to master/detail fields on insert
                    
                fieldProperties.fieldLabel = schemaFieldProperties.getLabel();
                System.debug(DEBUG + 'fieldProperties.fieldLabel: ' + fieldProperties.fieldLabel);
                fieldProperties.buttonField = false;
                fieldProperties.transformField = false;
                DisplayType fieldType = schemaFieldProperties.getType();
                fieldProperties.setfieldType(fieldType);
                            
                // get the picklist values for picklist fields
                if (fieldType == Schema.DisplayType.PICKLIST) {         
                    Map<String, String> pickListEntries = new Map<String, String>();
                        
                    // start with a blank value
                    pickListEntries.put('', '');
                        
                    for (Schema.PicklistEntry picklistEntry : schemaFieldProperties.getPicklistValues()) {
                        if (picklistEntry.isActive()) {
                            pickListEntries.put(picklistEntry.getLabel(), picklistEntry.getValue());
                        }
                    }
                    fieldProperties.pickListEntries = pickListEntries;
                    fieldProperties.pickListValues = pickListEntries.values();                    
                }

            // remove inaccessible fields from the map
            } else {
                fieldPropertiesMap.remove(fieldPath);
            }
        }
        return fieldPropertiesMap;
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           20 Apr 2018
    @param          String - the object's api Name
    @param          List<String> - the fieldnames to be queried (including parent relationship fields)
    @param          String - the query 'where' clause and other constraints
    @return         List<SObject> - the list of retrieved records
    @description    Cleanse a query by removing the fields from the query to which the user does not have access 
    				(includes parent relationship fields)
    *******************************************************************************/
    public static List<SObject> getCleansedRecords(String objectName, List<String> fieldNames, String filterStatements) {
        List<SObject> records;
        system.debug(DEBUG + 'objectName: ' + objectName);
        system.debug(DEBUG + 'fieldNames: ' + fieldNames);
        system.debug(DEBUG + 'filterStatements: ' + filterStatements);

        // ensure the Id field is always included in the query
        if (!new Set<String>(fieldNames).contains('Id')) {
            fieldNames.add('Id');
        }
            
        List<String> queryFields = new List<String>();      // set of cleansed field names to be queried
        Map<String, Object> obscufatedFieldMap = new Map<String, Object>();     // map of obscufated field values keyed on field name
            
        // get a map of the populated field properties objects for the fields
        Map<String, GlAp_FieldProps> fieldPropertiesMap = getFieldPropertiesMap(objectName, fieldNames);

        // check the field property for each field
        for (String fieldName : new Set<String>(fieldNames)) {
            
            // always allow the Id field on the query
            if (fieldName == 'Id') {
                queryFields.add(fieldName);
                
            // else if the field's in the map it must be accessible
            } else if (fieldPropertiesMap.keySet().contains(fieldName)) {
                GlAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldName);
                System.debug(DEBUG + 'fieldName: ' + fieldName);
                System.debug(DEBUG + 'fieldProperties: ' + fieldProperties);
                queryFields.add(fieldName);
                    
                // if it's encrypted mark it for obscufation
                if (fieldProperties.isEncrypted) {
                    
                    // if the field is numeric give it a numeric dummy value, if it is text give it a text value
                    Object dummyValue = fieldProperties.fieldType == 'number' || fieldProperties.fieldType == 'currency' 
                                        ? '999999' 
                                        : '"xxxxxxxx"';
    
                    obscufatedFieldMap.put(fieldName, dummyValue);
                }
            }
        }

        string queryString = String.format('select {0} from {1}', new List<String>{String.join(queryFields, ', '), objectName});
        queryString = (filterStatements == null) ? queryString : queryString + ' ' + filterStatements;

        //GlUt_Logger.LogDebug(CLASS_NAME, 'queryString: ' + queryString);
        System.debug(DEBUG + 'Sudhir: Testing Query Optmimization: ' + queryString);
        

        try {           
            // make the query
            for (SObject record : Database.query(queryString)) {

                // obscufate the encrypted fields
                for (String fieldName : obscufatedFieldMap.keySet()) {
                    record.put(fieldName, obscufatedFieldMap.get(fieldName));
                }
                
                if (records == null) records = new List<SObject>();
                records.add(record);
            }
            
            records = Database.query(queryString);
            System.debug(DEBUG + 'records: ' + records);

        } catch (System.QueryException ex) {
            //GlUt_Logger.logException(ex);
            //GlUt_Logger.LogException(CLASS_NAME, 'Malformed query: ' + queryString, ex);
        }
        finally {   
            //GlUt_Logger.writeLogsToDatabase() ;		// Sudhir: Query Optmimization Test
           // GlUt_Logger.writeLogsToDatabase(); 
        }
            
        return records;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           28 Mar 2019
    @param          Map<String,Sobject>
    @return         Map<String,Sobject>
    @description    This method returns the map of string,sobject where we can get the Id in map after cleanse
    *******************************************************************************/
    public static Map<String,Sobject> createMapAfterCleanse(Map<String,Sobject> mapUniqueString2Sobject) {
        
        List<String> listKeySets = new List<String>();
        List<Sobject> listSobject = new List<Sobject>();
        
        listKeySets.addAll(mapUniqueString2Sobject.keyset());
        listSobject = mapUniqueString2Sobject.values();
        listSobject = cleanseFields(listSobject, false);
        if(!listSobject.isEmpty())
            insert listSobject;
        mapUniqueString2Sobject.clear();
        if(listKeySets.size() == listSobject.size()){
            for(integer i=0 ; i< listSobject.size() ; i++){
                mapUniqueString2Sobject.put(listKeySets[i],listSobject[i]);
            }
        }
        return mapUniqueString2Sobject;
    }
}