/******************************************************************************
@author      	Echo: Gopal Gupta
@date      		07-Nov-2017
@description	Component controller for GlAp_CustomLookup
@Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class GlAp_CustomLookupCtrlr {

    /******************************************************************************
	@author      	Echo: Gopal Gupta
	@date      		07-Nov-2017
	@param			objectName         - Name of SObject
					fld_API_Text       - API name of field to be returned
					lim                - Total number of record to be returned
					fld_API_Search     - API name of field to be searched
					searchText         - text to be searched
					fld_API_FilterText - API name of field to put any additional filter
					fld_API_FilterVal  - text value for the additional filter
	@return			JSON of list of ResultList to the Component
	@description	This method query the sObject based on the parameters passed
    @revisions      Add an extra parameter named as field_API_Field_Concatenate
                    In order to make the search unique by concatenating additional information on name field.
	*******************************************************************************/
    @AuraEnabled(cacheable=true) 
    public static String searchDB(String objectName, String fld_API_Text, 
                                  Integer lim, String fld_API_Search, String searchText, String fld_API_FilterText, String fld_API_FilterVal, String field_API_Field_Concatenate, String field_API_FilterIds) {
        
        List<String> filterIDs = new List<String>();
        if(field_API_FilterIds != null){
            List<Id> filterListsIds = (List<Id>)JSON.deserialize(field_API_FilterIds, List<Id>.class);
            for(Id fieldId : filterListsIds){
                filterIDs.add('\'' + fieldId + '\'');
            }
        }

        // convert the field list into a list of fields
        List<String> fieldsList = new List<String>();
        if (fld_API_Text.length() > 0) {
        	fieldsList = fld_API_Text.split(',');                                  
        }
        //Changes for AT-1742 Starts Here
        if(string.isNotBlank(field_API_Field_Concatenate)){
           fieldsList.add(field_API_Field_Concatenate);                               
        }
        //Changes for AT-1742 Ends Here
        // Prevent soql injection
        searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        // Prepare the filter statements string
        String filterStatements = 'WHERE ' + fld_API_Search + ' LIKE ' + searchText;         
		
        if (string.isNotBlank(fld_API_FilterText) &&  string.isNotBlank(fld_API_FilterVal)) {
            fld_API_FilterVal = '\'' + String.escapeSingleQuotes(fld_API_FilterVal.trim()) + '\'';
        	filterStatements += ' AND ' + fld_API_FilterText + ' = ' + fld_API_FilterVal;                             
        }else if (string.isNotBlank(fld_API_FilterText) && filterIDs.size() > 0) {
            filterStatements += ' AND ' + fld_API_FilterText + ' IN ' + filterIDs;   
        }
                                      
        filterStatements += ' LIMIT ' + lim;
        system.debug('filterStatements=> ' + filterStatements) ;
        system.debug('fieldsList=> ' + fieldsList) ;
		List<sObject> sobjList = GlAp_LightningDataAccess.getRecords(objectName, 
																	fieldsList, 
																	filterStatements);
		
        // Please do not delete debug. - Dependra Singh(16-04-2018)                              
        System.debug('sobjList===== ' + sobjList);
		return JSON.serialize(sobjList);
    }
}