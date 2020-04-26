/************************************************************************************************************
@author         Accenture: Luke Emberton
@date           26-Aug-2017
@description:   This class is used by all classes that retrive data from the database to ensure that FLS
                and encryption rules are respected. This is essential for Lightning Component classes
                it is a requirement for standard Apex classes to pass the AppExchange security review
Revision(s)		01 Mar 2018, P Dixon - updated to support parent relationship fields in fieldsets
**************************************************************************************************************/
public class Testing_Security {
      
 private static final String CLASS_NAME = 'GlUt_FieldSecurity';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          sObject obj
    @return         string
    @description	Private Method that is used to identify and return the type of an sObject
    **********************************************************************************************/
    private static string getTypeofSObject(sObject obj){
        return obj.getSObjectType().getDescribe().getName();       
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           26-Aug-2017
    @param          string objectName
    @return         Map<String, Schema.SObjectField> 
    @description	Method calls the describe method to find out the properties of all fields on the object
    **********************************************************************************************/
    private static Map<String, Schema.SObjectField> getFieldMap(string objectName){

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        return fieldMap;        
    }
    	
    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           01 Mar 2018
    @param          String - object api name
    @param          List<String> - list of field names with paths
    @return         List<GlAp_FieldProps> - list of field properties
    @description    Retrieves the field properties for an object and list of field names passed in
    **********************************************************************************************/
    public static List<GlAp_FieldProps> getFieldPropertiesObject(String objectName, List<String> fieldNames) {
    	
        // map of field properties maps keyed on the object type
		Map<String, Map<String, Schema.SObjectField>> objectFieldPropertiesMap = new Map<String, Map<String, Schema.SObjectField>>();
		Map<String, GlAp_FieldProps> fieldPropertiesMap = new Map<String, GlAp_FieldProps>();		// map of GlAp_FieldProps objects keyed on field name with path

		// build a map of field properties objects for the list of fields, populated with the parent object and field name
		for (String fieldPath : fieldNames) {
			if (!fieldPropertiesMap.keySet().contains(fieldPath)) {
				fieldPropertiesMap.put(fieldPath, new GlAp_FieldProps(objectName, fieldPath));
			}
		}

		// build a map of the schema field properties for all the parent objects
        for (String fieldPath : fieldPropertiesMap.keySet()) {
        	
			String parentObject = fieldPropertiesMap.get(fieldPath).parentObject;
            if (!objectFieldPropertiesMap.keySet().contains(parentObject)) {
            	objectFieldPropertiesMap.put(parentObject, getFieldMap(parentObject));
            }
        }

		// populate the field properties objects with the rest of their properties from the schema field properties
        for (String fieldPath : fieldPropertiesMap.keySet()) {
        	
			GlAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldPath);
			String parentObject = fieldPropertiesMap.get(fieldPath).parentObject;
			String fieldName = fieldPropertiesMap.get(fieldPath).fieldName;
			
        	Schema.DescribeFieldResult schemaFieldProperties = objectFieldPropertiesMap.get(parentObject).get(fieldName).getDescribe();                
			fieldProperties.isFLSVisible = schemaFieldProperties.isAccessible();
			
			if (fieldProperties.isFLSVisible) {
				
				fieldProperties.isEncrypted = schemaFieldProperties.isEncrypted();
				fieldProperties.isEditable = schemaFieldProperties.isUpdateable() || schemaFieldProperties.isCreateable();		// isCreateable allows access to master/detail fields on insert
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
                
			} else {
				
				// remove inaccessible fields from the map
				fieldPropertiesMap.remove(fieldPath);
			}
        }
		System.debug(DEBUG + 'fieldPropertiesMap.values(): ' + fieldPropertiesMap.values());
        return fieldPropertiesMap.values();
	}
	
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		06 Mar 2018
	@param			Set<String> - the populated fieldnames (including parent refernces)
	@param			Object - the populated field object returned by getPopulatedFieldsAsMap()
	@param			String - the field name key returned by getPopulatedFieldsAsMap()
	@description 	Adds parent record fields populated in getPopulatedFieldsAsMap() to the set of fields.
					Called recursively to cope with parents of parents etc.
	*******************************************************************************/
	private static void addParentPopulatedFields(Set<String> fieldNames, Object populatedField, String fieldName) {
		
    	// populate the parent fields
		Map<String, Object> parentFieldValueMap = ((SObject) populatedField).getPopulatedFieldsAsMap();
    	for (String parentFieldName : parentFieldValueMap.keySet()) {
    		
			// if the parent field value is another parent record
			Object parentPopulatedField = parentFieldValueMap.get(parentFieldName);
			if (parentPopulatedField != null && String.valueOf(parentPopulatedField).contains(':{')) {

				// add the parent fields to the set
				addParentPopulatedFields(fieldNames, parentPopulatedField, parentFieldName);

			} else {
				
				// add the field name to the set
				fieldNames.add(fieldName + '.' + parentFieldName);
			}
		}
	}
	
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		06 Mar 2018
	@param			SObject - the record
	@return			Set<String> - the populated fieldnames (including parent references)
	@description 	Returns a set all populated fields (including parent fields) in a record
	*******************************************************************************/
	private static Set<String> getPopulatedFields(SOBject record) {
		Set<String> fieldNames = new Set<String>();

		// check if it contains parent field values
		Map<String, Object> fieldValueMap = record.getPopulatedFieldsAsMap();
		System.debug(DEBUG + 'fieldValueMap: ' + fieldValueMap);

		for (String fieldName : fieldValueMap.keySet()) {

			// if the field value is a parent record
			Object populatedField = fieldValueMap.get(fieldName);
			if (populatedField != null && String.valueOf(populatedField).contains(':{')) {
				
				// add the parent fields to the set
				addParentPopulatedFields(fieldNames, populatedField, fieldName);

			} else {
				
				// add the field name to the set
				fieldNames.add(fieldName);
			}
		}
		System.debug(DEBUG + 'fieldNames: ' + fieldNames);
		return fieldNames;
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
    public static sObject cleanseFields(sObject obj, boolean isRead){       
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
    @description	Takes the list of records and processes them without needing the
                    list of fields to be provided. Any fields which are not accessible to the user are 
                    removed from the sObject any fields that are encrypted have their value obscufated. 
                    A parameter is passed in to detail whether this is for reading or writing fields. 
                    If the field is encrypted and the user does not have permission to see encrypted data 
                    the field is removed from the sObject so its value is not overwritten
    **********************************************************************************************/
    public static List<SObject> cleanseFields(List<SObject> records, Boolean isRead) {       

		if (!records.isEmpty() && records != null) {
			Map<String, GlAp_FieldProps> fieldPropertiesMap = new Map<String, GlAp_FieldProps>();		// map of GlAp_FieldProps objects keyed on field name with path
	
	        String objectName;
	        for (SObject record : records) {
	            objectName = objectName == null ? getTypeofSObject(record) : objectName;		// records are all the same object
	    
	            // build a map of field properties objects for the populated fields, populated with the parent object and field name
	            for (String fieldPath : getPopulatedFields(record)) {
	                if (!fieldPropertiesMap.keySet().contains(fieldPath)) {
	                    fieldPropertiesMap.put(fieldPath, new GlAp_FieldProps(objectName, fieldPath));
	                }
	            }
	        }
			system.debug('fieldPropertiesMap:: ' + fieldPropertiesMap) ;
	        // cleanse the records
	        return cleanseRecordsUsingFieldProperties(records, isRead, fieldPropertiesMap);
		}
        return records;		// nothing to cleanse
    }
        
    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           02 Mar 2018
    @param          List<SObject> - list of records to cleanse
    @param          Boolean - true if for reading fields/false for writing
    @return         List<SObject> - list of cleansed records
    @description	Takes the list of records and associated fields and processes them so that
                    any fields which are not accessible to the user are removed from the sObject
                    any fields that are encrypted have their value obscufated. A parameter is passed
                    in to detail whether this is for reading or writing fields. If the field is
                    encrypted and the user does not have permission to see encrypted data the field
                    is removed from the sObject so its value is not overwritten
    **********************************************************************************************/
    public static List<SObject> cleanseFields(List<SObject> records, List<String> fieldNames, Boolean isRead) {

		if (!records.isEmpty() && records != null) {
	        Map<String, GlAp_FieldProps> fieldPropertiesMap = new Map<String, GlAp_FieldProps>();       // map of GlAp_FieldProps objects keyed on field name with path
	
	        String objectName;
	        for (SObject record : records) {
	            objectName = getTypeofSObject(record);
	            break;		// records are all the same object
	        }
	        
	        // build a map of field properties objects for the list of fields, populated with the parent object and field name
	        for (String fieldPath : fieldNames) {
	            if (!fieldPropertiesMap.keySet().contains(fieldPath)) {
	                fieldPropertiesMap.put(fieldPath, new GlAp_FieldProps(objectName, fieldPath));
	
	            }
	        }
	        system.debug('fieldPropertiesMap:: ' + fieldPropertiesMap);
	        // cleanse the records
	        return cleanseRecordsUsingFieldProperties(records, isRead, fieldPropertiesMap);
		}
        return records;		// nothing to cleanse
    }
    
    /**********************************************************************************************
    @author         Echo: Patrick Dixon
    @date           02 Mar 2018
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
		system.debug('objectFieldPropertiesMap:: ' + objectFieldPropertiesMap);
		// populate the field properties objects with the required properties from the schema field properties
        for (String fieldPath : fieldPropertiesMap.keySet()) {

			GlAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldPath);
			String parentObject = fieldPropertiesMap.get(fieldPath).parentObject;
			String fieldName = fieldPropertiesMap.get(fieldPath).fieldName;
			Schema.DescribeFieldResult schemaFieldProperties = objectFieldPropertiesMap.get(parentObject).get(fieldName).getDescribe();                

			fieldProperties.isFLSVisible = schemaFieldProperties.isAccessible();
			fieldProperties.isEncrypted = schemaFieldProperties.isEncrypted();
			fieldProperties.isEditable = schemaFieldProperties.isUpdateable() || schemaFieldProperties.isCreateable();		// isCreateable allows access to master/detail fields on insert
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
        System.debug(DEBUG + 'isRead: ' + isRead);
		System.debug(DEBUG + 'fieldPropertiesMap: ' + fieldPropertiesMap);
		// create new updater record to allow fields to be removed or updated
        GlUt_ObjectUpdater newRecord = new GlUt_ObjectUpdater(record, objectName, fieldPropertiesMap.keySet());
		System.debug(DEBUG + 'newRecord: ' + newRecord);
               
        // Work out which fields have a value on the object already (e.g. are set)
        Set<String> populatedFields = getPopulatedFields(record);
		System.debug(DEBUG + 'populatedFields: ' + populatedFields);

        // loop through the list of fields
        for (String fieldPath : fieldPropertiesMap.keySet()) {
            
			GlAp_FieldProps fieldProperties = fieldPropertiesMap.get(fieldPath);             
			Boolean isEncrypted = fieldProperties.isEncrypted;
			Boolean isAccessible = fieldProperties.isFLSVisible;
			Boolean isEditable = fieldProperties.isEditable;
            String fieldName = fieldPath;  
            
            // see if the field is already populated on the object
            if (populatedFields.contains(fieldName)) {
                            
                if (isRead) {
                    
                    // if the user cannot access the field then remove it so long as not the Id field
                    if (!isAccessible && (fieldName != 'Id')) {
                        newRecord.removeField(fieldName);
						System.debug(DEBUG + 'removeField: ' + fieldName);
                    
                    // if the field is encrypted obscufate the value
                	} else if (isEncrypted) {
                        newRecord.obfuscateField(fieldName);
						System.debug(DEBUG + 'obfuscateField: ' + fieldName);
                    }
                    
                } else {		// write
                    
                    // if the field is encryted or not editable then remove from the map as long as its not the Id field             
                    if ((isEncrypted || !isEditable) && fieldName != 'Id') {
						newRecord.removeField(fieldName);
						System.debug(DEBUG + 'removeField (write): ' + fieldName);
                    }
                }
			} 
        }
        
		// get the sObject back
		System.debug(DEBUG + 'newRecord: ' + newRecord);
        return (SObject) newRecord.getSObject();
   }  
    
    
}