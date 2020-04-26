/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		27 Feb 2018
@description 	Component controller for related list lightning component

@revision(s)		
*******************************************************************************/
public with sharing class GlAp_RelatedRecordListCtrlr {
	
	private static final String CLASS_NAME = 'GlAp_RelatedRecordListCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		12 Feb 2018
	@param			String - the object api name
	@param			String - the name of the fieldset
	@return			List<GLAp_FieldProps> - list of field properties for device table
	@description 	get the field properties for the Device__c object
    @Revision       Add an extra parameter named as deleteOption as per AT-3317
	*******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveFieldProperties(String objectName, String fieldsetName, Boolean deleteOption) {
        List<GLAp_FieldProps> fieldPropertiesList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(objectName, fieldsetName);
        // make all fields read only
        for (GLAp_FieldProps fieldProperties : fieldPropertiesList) {
            fieldProperties.isEditable = false;
        }
        //Changes for AT-3317 start Here
        //Add delete button option field
        if(deleteOption != null && deleteOption == true){
            GLAp_FieldProps deletebuttonFieldProp = new GLAp_FieldProps();            
            deletebuttonFieldProp.isFLSVisible = false;
            deletebuttonFieldProp.isEncrypted = false;
            deletebuttonFieldProp.isEditable = false;
            deletebuttonFieldProp.isRequired = false;
            deletebuttonFieldProp.fieldName = GlUt_Constants.DELETE_BUTTON;
            deletebuttonFieldProp.fieldLabel = GlUt_Constants.DELETE_BUTTON;
            deletebuttonFieldProp.buttonField = true;
            deletebuttonFieldProp.transformField = false;
            fieldPropertiesList.add(deletebuttonFieldProp);
        }
        return fieldPropertiesList;
        //Changes for AT-3317 Ends Here
    }
 
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		12 Feb 2018
	@param			Id - the record Id
	@param			String - the object api name
	@param			String - the parent field api name
	@param			String - the name of the fieldset
	@param			String - the api name of the amended by field
	@param			Boolean - true if the list is used to select records to amend
	@return			List<BlAp_CombinedRecord> - list of combined device records to display
	@description 	get the list of device records to display
    @revision       MT - 16/05/2018 AT-2646 added a order by clause to sort by reading date
                    if the objectName is reading__c
                    AT-3317 -21/Aug/2018 Add an extra filter condition to fetch all valid records.
	*******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveRecords(Id recordId, String objectName, String parentField, String fieldsetName, String filter) {
        
        System.debug(DEBUG + 'recordId: ' + recordId);
        List<BlAp_CombinedRecord> recordsToDisplay = new List<BlAp_CombinedRecord>();
        
        try {
	        //AT-2646 start
	        String orderByClause = ' ORDER BY CreatedDate DESC ';
            if (objectName == GlUt_APIConstantsReading.READINGAPINAME) {
                orderByClause = ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME +  ' DESC , CreatedDate DESC'; //AT-2646 
            }
            //AT-2646 end
            //Changes for AT-3317 start Here
            Boolean isFieldExist = doesFieldExist(objectName,GlUt_Constants.INVALID);
            
            if(isFieldExist){
                filter = filter + ' AND '+ GlUt_Constants.INVALID +'= false';
            }
            //Changes for AT-3317 Ends Here
            // check field accessibility and get the records
            system.debug('101-------filter ' + filter);
            
            
            system.debug('objectName  '   + objectName +  ' fieldSetName  ' + fieldSetName   + ' recordId '   +  recordId  + ' parentField ' +  parentField   + '  filter '  +  filter
                        +   '  orderByClause'     +  orderByClause);
                
            List<SObject> records = GlAp_LightningDataAccess.getRecords(objectName, fieldSetName, recordId, parentField, filter, orderByClause);
            system.debug('102-------------records ' + records);
            // build the display list
            for (SObject record : records) {
                BlAp_CombinedRecord recordToDisplay = new BlAp_CombinedRecord();            
                recordToDisplay.uniqueId = record.Id;
                recordToDisplay.isSelected = false;
                recordToDisplay.readOnlyFields = new Map<String, Boolean>();
                recordToDisplay.objectMap = GlAp_LightningDataAccess.getRecordMapWithFields(objectName, record);
                recordsToDisplay.add(recordToDisplay);           
                System.debug(DEBUG + 'recordToDisplay: ' + recordToDisplay);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return recordsToDisplay;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 Aug 2018
	@param			String - the object api name
	@param			String - the field api name
	@return			boolean - True if field exist else false
	@description 	Check if the field exist on object or not.
	*******************************************************************************/
    public static boolean doesFieldExist(String objName, string fieldName)
    {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {}
        return false;
    }
    /******************************************************************************
	@author    		Echo:Amit K.
	@date      		20 Aug 2018
	@param			Id - the record Id
	@return			List<SObject> - list of sobjectRecord
	@description 	get the list of sObject Record that has been set as Invalid. AT-3317
	*******************************************************************************/
    @AuraEnabled
    public static List<SObject> setRecordInvalid(Id sobjectRowId) {
        List<SObject> sobjectRecords = new List<SObject>();
        try {
            if(sobjectRowId != null) {
                List<String> fields = new List<String>();
                fields.add(GlUt_Constants.INVALID);
                String objName = GlUt_ServiceUtilities.getObjectType(sobjectRowId);
                String filterStatement = 'WHERE Id =' + '\'' + sobjectRowId + '\' Limit 1';
                sobjectRecords = GlAp_LightningDataAccess.getRecords(objName,fields,filterStatement);
                if(sobjectRecords!= null && !sobjectRecords.isEmpty()){
                    for(SObject record :sobjectRecords){
                        record.put(fields[0],true);
                    }
                    sobjectRecords = GlUt_FieldSecurity.cleanseFields(sobjectRecords, false);
                    update sobjectRecords;
                }
            }
        } 
        catch (exception e) {
            
            GlUt_Logger.logException(e);
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return sobjectRecords;
        
    }
}