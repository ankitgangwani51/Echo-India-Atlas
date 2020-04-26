/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		16 Nov 2017
@description 	Class for RecordType utilities
*******************************************************************************/
public with sharing class GlUt_RecordTypeUtilities {
    
	private static final String CLASS_NAME = 'GlUt_RecordTypeUtilities';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	public static Map<String, RecordType> recordTypeMap;		// map of active recordTypes keyed on api name
	
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           16 Nov 2017
    @param          String - SObjectName
    @return			List<Schema.RecordTypeInfo> - list of recordTypeInfo records for the SObject
    @description    gets a list of recordTypeInfo for an SObject
    *******************************************************************************/
    public static List<Schema.RecordTypeInfo> getRecordTypeInfos(String SObjectName) {

        return Schema.getGlobalDescribe().get(SObjectName).getDescribe().getRecordTypeInfos();    
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           16 Nov 2017
    @param          String - SObjectName
    @return			Map<String, RecordType> - map of recordTypes keyed on api name
    @description    gets a map of recordTypes
    *******************************************************************************/
    public static Map<String, RecordType> getRecordTypeMap() {
    	
    	if (recordTypeMap == null) {
    		recordTypeMap = new Map<String, RecordType>();
    		for (RecordType recordType : [select Id, 
												SobjectType, 
												NamespacePrefix, 
												Name, 
												DeveloperName, 
												Description 
			    						from RecordType
			    						where IsActive = true]) {
    							
				recordTypeMap.put(recordType.DeveloperName, recordType);
			}
    	}
    	return recordTypeMap;
    }
}