/******************************************************************************
@author         Echo: Ankit Gangwani
@date           11 May 2018
@description    Class is used to create batch request queue rescod and schedule it. 
@Revisions		
*******************************************************************************/
public with sharing class GlAp_BatchRequestQueueCtrlr {
    
    private static final String CLASS_NAME = 'GlAp_BatchRequestQueueCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> batchReqQueueFieldlist;
    private static List<String> batchProcessFieldlist;
    private static List<String> contentDocumentFieldlist;
    private static List<String> contentDocumentLinkFieldlist;
    Static{
        batchReqQueueFieldlist = new List<string>();
        batchReqQueueFieldlist.add(GlUt_APIConstantsBatchRequestQueue.REQUESTNAMEAPINAME);
        batchReqQueueFieldlist.add(GlUt_APIConstantsBatchRequestQueue.CREATEDDATEAPINAME);
        batchReqQueueFieldlist.add(GlUt_APIConstantsBatchRequestQueue.USERAPINAME);
        batchReqQueueFieldlist.add(GlUt_APIConstantsBatchRequestQueue.STATUSAPINAME);  
        batchProcessFieldlist = new List<String>();
        batchProcessFieldlist.add(GlUt_APIConstantsBatchProcess.ID);
        
        contentDocumentFieldlist = new List<String>();
        contentDocumentFieldlist.add(LoAp_Constants.Id);
        contentDocumentFieldlist.add(LoAp_Constants.Title);
        contentDocumentFieldlist.add(LoAp_Constants.ContentSize);
        contentDocumentFieldlist.add(LoAp_Constants.FileType);  
        contentDocumentLinkFieldlist = new List<String>();
        contentDocumentLinkFieldlist.add(LoAp_Constants.ContentDocumentId);
    }
	private static List<String> readingFields = new List<String> {
       GlUt_APIConstantsReading.NAMEAPINAME
    };
    private static List<String> readingUploadFields = new List<String> {
       GlUt_APIConstantsReadingUpload.READINGAPINAME
    };
	
	
	/**********************************************************************************************
    @author      : Echo : Dependra Singh
    @date        : 17 Jan 2019
    @description : This is a wrapper class Combined List records,FieldProperty Details.
    **********************************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<GLAp_FieldProps> fieldPropList;
		@AuraEnabled public List<BlAp_CombinedRecord> fieldRecordList;
        public ContainerWrapper(){
            fieldPropList = new List<GLAp_FieldProps>();
			fieldRecordList = new List<BlAp_CombinedRecord>();
        }
    }
        /**********************************************************************************************
    @author      : Echo : Dependra Singh
    @date        : 17 Jan 2019
    @return      : ContainerWrapper
    @description : Method is used to show information in lighting page using wrapper class.
    **********************************************************************************************/
    @AuraEnabled
    public static ContainerWrapper getInfoToDisplay(String objectType, String fieldSet,String BatchProcess){
        //try{
        ContainerWrapper resultContainer = new ContainerWrapper();
        resultContainer.fieldPropList = getBatchRequestQueueDetails(objectType, fieldSet);
        system.debug('resultContainer.fieldPropList==='+resultContainer.fieldPropList);
        system.debug('batchReqQueueFieldlist==='+batchReqQueueFieldlist);
        resultContainer.fieldRecordList = retrieveBatchReqQueueRecords(batchReqQueueFieldlist, BatchProcess);
        system.debug('fieldRecordList==='+resultContainer.fieldRecordList);
        return resultContainer;
   		 /*}
        catch (exception e) {
            String errorMsg = GlUt_Logger.getActualErrorMessage(e.getMessage());
            GlUt_Logger.logException(e);
            throw new AuraHandledException(errorMsg);
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }*/
    }
    /**********************************************************************************************
	@author    	   ECHO: Ankit Gangwani
	@date      	   11 May 2018
    @param         String objectType, 
				   String fieldSet
    @return        List<GLAp_FieldProps>
    @description   This method returns the field properties for each of the fields that are
                   to be displayed on the screen
	@Revesion      Updated By Dependra Singh- 18-04-2019
	**********************************************************************************************/

    public static List<GLAp_FieldProps> getBatchRequestQueueDetails(String objectType, String fieldSet) {
        List<GLAp_FieldProps> finalFieldProperties = new List<GLAp_FieldProps>();  
        //Get the field properties for the Payment object
        List<GLAp_FieldProps> fieldProperties = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(objectType, fieldSet); 
        system.debug('fieldProperties====='+fieldProperties);
        for(GLAp_FieldProps batchReqFields: fieldProperties){  
            if(batchReqFields.fieldName == GlUt_APIConstantsBatchRequestQueue.CREATEDDATEAPINAME){
                batchReqFields.fieldLabel = 'Date';
            }
            if(batchReqFields.fieldName != GlUt_APIConstantsBatchRequestQueue.USERAPINAME){
                finalFieldProperties.add(batchReqFields);  
            }   
            //batchReqQueueFieldlist = new List<String>();
            //batchReqQueueFieldlist.add(batchReqFields.fieldName);					
        }
        GLAp_FieldProps cancelButtonField =  new GlAp_FieldProps(true,false,false,false,'cancel','Cancel',null,false,true,GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME);
        
        GLAp_FieldProps userTransformField =  new GlAp_FieldProps(true,false,false,false,LoAp_Constants.USERLABEL,LoAp_Constants.NOTIFICATIONUSERFIELDNAME,
                                                                  'text',true,false,GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME);
        finalFieldProperties.add(userTransformField);        
        finalFieldProperties.add(cancelButtonField);
        
        return finalFieldProperties;
    } 

    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 May 2018
	@param			List<String> fieldListBRQ
    @return         List<GLAp_FieldProps> - list of field properties for Batch Request Queue table
    @description    get the field properties for the BatchRequestQueue__c object
	Commented By Dependra Singh- Removed
    *******************************************************************************/
    @AuraEnabled
	/*public static List<GLAp_FieldProps> retrieveBatchReqQueueFieldPropDetails(List<String> fieldListBRQ) {
        
        try {
            List<GLAp_FieldProps> fieldPropertiesFinal = new List<GLAp_FieldProps>();  
            List<GLAp_FieldProps> fieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME, fieldListBRQ);
            system.debug('fieldProperties====='+fieldProperties);
            GLAp_FieldProps cancelButtonField = new GLAp_FieldProps();
            cancelButtonField.isFLSVisible = true;
            cancelButtonField.isEncrypted = false;
            cancelButtonField.isEditable = false; 
            cancelButtonField.isRequired = false;
            cancelButtonField.fieldName = 'cancel';
            cancelButtonField.fieldLabel = 'Cancel';
            cancelButtonField.buttonField = true;
            cancelButtonField.parentObject = GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME;
            
            GLAp_FieldProps userTransformField = new GLAp_FieldProps();
            userTransformField.isFLSVisible = true;
            userTransformField.isEncrypted = false;
            userTransformField.isEditable = false; 
            userTransformField.isRequired = false;
            userTransformField.fieldName = LoAp_Constants.USERLABEL;
            userTransformField.fieldLabel = LoAp_Constants.NOTIFICATIONUSERFIELDNAME;
            userTransformField.fieldType = 'text';
            userTransformField.transformField = true;
            userTransformField.parentObject = GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME;
            
            for(GLAp_FieldProps batchReqFields: fieldProperties){  
                if(batchReqFields.fieldName == GlUt_APIConstantsBatchRequestQueue.CREATEDDATEAPINAME){
                    batchReqFields.fieldLabel = 'Date';
                }
                if(batchReqFields.fieldName != GlUt_APIConstantsBatchRequestQueue.USERAPINAME)            
                    fieldPropertiesFinal.add(batchReqFields);       
            }
            
            fieldPropertiesFinal.add(userTransformField);        
            fieldPropertiesFinal.add(cancelButtonField);
            return fieldPropertiesFinal;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
        
    }*/
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord>
	@param			List<String> fieldListBRQ, 
					String BatchProcess
    @description    get the list of Batch Request Queue records to display
    *******************************************************************************/
    public static List<BlAp_CombinedRecord> retrieveBatchReqQueueRecords(List<String> fieldListBRQ, String BatchProcess) {
        String whereClause = 'WHERE ' + GlUt_APIConstantsBatchProcess.BATCHCLASSAPINAME + ' = \'' + BatchProcess + '\'';
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            Map<Id,String> usersEmailMap = new Map<Id,String>();
            Set<Id> usersId = new Set<Id>();
            
            List<BatchProcess__c> batchProcessList =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBatchProcess.BATCHPROCESSAPINAME, 
                                                                                          batchProcessFieldlist,
                                                                                          whereClause);
            system.debug('fieldListBRQ======'+fieldListBRQ);
            if(batchProcessList.size() > 0){
                String orderBy = ' ORDER BY CreatedDate ASC';
                List<BatchRequestQueue__c> batchReqWQueueList =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME, 
                                                                                                     fieldListBRQ,
                                                                                                     batchProcessList[0].Id,
                                                                                                     GlUt_APIConstantsBatchProcess.BATCHPROCESSAPINAME,
                                                                                                     null,
                                                                                                     orderBy);
                system.debug('batchReqWQueueList======'+batchReqWQueueList);
                if(!batchReqWQueueList.isEmpty()){
                    for (BatchRequestQueue__c objBRQ : batchReqWQueueList) {
                        usersId.add(objBRQ.NotificationUser__c);
                    }
                }
                system.debug('usersId======'+usersId); 
                List<User> usersList = [SELECT Id, Email FROM User WHERE Id IN :usersId];
                for(User objUser : usersList){
                    usersEmailMap.put(objUser.Id,String.valueOf(objUser.Email));
                }
                system.debug('usersEmailMap======'+usersEmailMap);
                if(!batchReqWQueueList.isEmpty()){
                    for (BatchRequestQueue__c objBatchReqQueue : batchReqWQueueList) {
                        BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                        record.uniqueId = objBatchReqQueue.Id;
                        record.isSelected = false;
                        record.readOnlyFields = new Map<String, Boolean>();
                        record.objectMap = new Map<String, sObject>();
                        record.objectMap.put(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME, objBatchReqQueue); 
                        Map<string, string> transFormFieldMap = new Map<string, string>();
                        transFormFieldMap.put(LoAp_Constants.USERLABEL, usersEmailMap.get(objBatchReqQueue.NotificationUser__c));
                        record.transformFieldMap = new Map<string,Map<string, string>>();
                        record.transformFieldMap.put(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME,transFormFieldMap);
                        records.add(record);
                    }
                }
            }
            return records;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 May 2018
    @return         List<GLAp_FieldProps> - list of field properties for Batch Request Queue table
	@param			String objectName, 
					List<String> objectFields
    @description    get the field properties for the BatchRequestQueue__c object
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveFieldPropDetails(String objectName, List<String> objectFields) {
        try {
            List<GLAp_FieldProps> fieldPropertiesFinal = new List<GLAp_FieldProps>();  
            List<GLAp_FieldProps> fieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(objectName, objectFields);
            for(GLAp_FieldProps fieldProp: fieldProperties){
                if(objectName == LoAp_Constants.ContentDocument){
                    if(fieldProp.fieldName == 'Id'){
                        fieldProp.fieldLabel = LoAp_Constants.fileName;
                        fieldProp.buttonField = false;
                        fieldProp.transformField = true;
                        fieldProp.fieldType = 'reference';
                    }
                    if(fieldProp.fieldName == LoAp_Constants.ContentSize){
                        fieldProp.fieldLabel = 'Size';
                    }                    
                    if(fieldProp.fieldName == LoAp_Constants.FileType){
                        fieldProp.fieldLabel = 'Type';
                    } 
                }
                if(objectName == GlUt_APIConstantsBatchError.BATCHERRORAPINAME){
                    if(fieldProp.fieldName == GlUt_APIConstantsBatchError.ERRORDETAILSAPINAME){
                        fieldProp.fieldLabel = 'Error';
                    }
                    if(fieldProp.fieldName == GlUt_APIConstantsBatchError.OPERATINGRECORDIDAPINAME){
                        fieldProp.fieldLabel = 'Operating Record';
                    }
                }
                fieldPropertiesFinal.add(fieldProp);               
            }   
            if(objectName == GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME){
                GLAp_FieldProps fldProp =  new GlAp_FieldProps(false,false,true,false,LoAp_Constants.READINGLABEL,LoAp_Constants.READINGLABEL,
                                                               LoAp_Constants.REFERENCEFIELD,true,false,LoAp_Constants.READINGLABEL);
               /* //Transform Field for Reading Import Component
                GLAp_FieldProps fldProp = new GLAp_FieldProps();
                fldProp.isFLSVisible = false;
                fldProp.isEncrypted  = false;
                fldProp.isEditable   = true;
                fldProp.isRequired   = false;
                //fldProp.fieldName    = GlUt_APIConstantsReadingUpload.READINGAPINAME;
                fldProp.fieldLabel   = LoAp_Constants.READINGLABEL;
                fldProp.fieldType    = LoAp_Constants.REFERENCEFIELD;
                fldProp.fieldName    = LoAp_Constants.READINGLABEL;
                fldProp.parentObject    = LoAp_Constants.READINGLABEL;
                fldProp.transformField = true; 
                //fldProp.parentObject = GlUt_APIConstantsReadingUpload.READINGAPINAME;*/
                fieldPropertiesFinal.add(fldProp);
            }
            
            return fieldPropertiesFinal;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        } 
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord>
    @param			String objectName, 
                    List<String> objectFields, 
               	    String BatchRequestQueueId
    @description    get the list of Batch Request Queue records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveFilesRecords(String objectName, List<String> objectFields, String BatchRequestQueueId) {
        try {
            List<Id> cdList = new List<Id>();
            String whereClause = 'WHERE LinkedEntityId = \'' + BatchRequestQueueId + '\'';
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            
            // get the Batch Process records
            List<ContentDocumentLink> contentDocumentLinkList =  GlAp_LightningDataAccess.getRecords(LoAp_Constants.ContentDocumentLink, 
                                                                                                     contentDocumentLinkFieldlist,
                                                                                                     whereClause);
            Set<Id> contentDocumentLinkIds = new Set<Id>();
            
            for(ContentDocumentLink objContentDocumentLink : contentDocumentLinkList){            
                contentDocumentLinkIds.add(objContentDocumentLink.ContentDocumentId);
            }
            
            if(contentDocumentLinkList.size() > 0){
                // get the Batch Request Queue records
                List<ContentDocument> contentDocumentList = GlAp_LightningDataAccess.getRecords(objectName,objectFields,String.format('WHERE {0} IN {1}',new List<String>{LoAp_Constants.Id,
                                                                                                GlUt_FieldSecurity.IdsToString(contentDocumentLinkIds)}));
                
                if(!contentDocumentList.isEmpty()){
                    for(ContentDocument objCD : contentDocumentList){
                        cdList.add(objCD.Id);
                    }
                    
                    if(!cdList.isEmpty()){
                        Map<Id,String> contentIdToFileName = new Map<Id,String>();
                        contentIdToFileName = getRecordName(cdList);
                        
                        for (ContentDocument objcontentDocument : contentDocumentList) {
                            BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                            record.uniqueId = objcontentDocument.Id;
                            record.isSelected = false;
                            record.readOnlyFields = new Map<String, Boolean>();
                            record.objectMap = new Map<String, sObject>();
                            record.objectMap.put(objectName, objcontentDocument);                            
                            Map<String,String> notificationTransformFieldMap = new Map<String,String>();
                            notificationTransformFieldMap.put('sfc/servlet.shepherd/document/download/'+String.valueOf(objcontentDocument.Id),contentIdToFileName.get(objcontentDocument.Id));
                            record.transformFieldMap = new Map<string,Map<string, string>>();
                            record.transformFieldMap.put(objectName ,notificationTransformFieldMap);
                            records.add(record);
                        }
                    }
                }
            }
            
            return records;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        } 
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord>
	@param			String objectName, 
                    List<String> objectFields, 
                    String BatchRequestQueueId
    @description    get the list of Batch Request Queue records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveErrorRecords(String objectName, List<String> objectFields, String BatchRequestQueueId) {
        try {
            //String whereClause = 'WHERE BatchRequestQueue__c = \'' + BatchRequestQueueId + '\'';
            String whereClause = 'WHERE ' + GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME + ' = \'' + BatchRequestQueueId + '\'';
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            
            // get the Batch Process records
            List<BatchError__c> batchErrorList =  GlAp_LightningDataAccess.getRecords(objectName,objectFields,whereClause);
            
            if(batchErrorList.size() > 0){
                // get the Batch Error records
                for (BatchError__c objBatchError : batchErrorList) {
                    BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                    record.uniqueId = objBatchError.Id;
                    record.isSelected = false;
                    record.readOnlyFields = new Map<String, Boolean>();
                    record.objectMap = new Map<String, sObject>();
                    record.objectMap.put(objectName, objBatchError);                                
                    records.add(record);
                }
            }
            return records;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }

	/******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord>
	@param			String objectName, 
                    List<String> objectFields, 
                    String BatchRequestQueueId
    @description    get the list of Batch Request Queue records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveStagingRecords(String objectName, List<String> objectFields, String BatchRequestQueueId) {
        try {
            String whereClause = 'WHERE ' + GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME + ' = \'' + BatchRequestQueueId + '\'';
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            
			Map<String,String> mapReadingByReadingUpload = new Map<String,String>();
			Set<Id> setReadingIds = new Set<Id>();
            Set<Id> setReadingUploadIds = new Set<Id>();
            // get the Batch Process records
            List<ReadingUpload__c> readingUploadList =  GlAp_LightningDataAccess.getRecords(objectName,objectFields,whereClause);
            for(ReadingUpload__c objReadingUplod : readingUploadList){
                setReadingUploadIds.add(objReadingUplod.Id);
            }
            List<ReadingUpload__c> readingUploads = (List<ReadingUpload__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME,readingUploadFields, 
                                                                                                                 ' WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(setReadingUploadIds));
            if(readingUploads != null && !readingUploads.isEmpty()){
                for(ReadingUpload__c objReadingUpload1 : readingUploads){
                    if(!mapReadingByReadingUpload.containsKey(objReadingUpload1.Id)){
                        mapReadingByReadingUpload.put(objReadingUpload1.Id, objReadingUpload1.Reading__c);
                    }
                    if(objReadingUpload1.Reading__c != null){
                        setReadingIds.add(objReadingUpload1.Reading__c);
                    }
                }
            }
            List<Reading__c> readings = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,readingFields, 
                                                                                               ' WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(setReadingIds));
            Map<Id, Reading__c> readingMap = new Map<Id, Reading__c>();
            for (Reading__c objReading : readings) {
                if(!readingMap.containsKey(objReading.Id)){
                    readingMap.put(objReading.Id, objReading);
                }
            }		
            if(readingUploadList.size() > 0){
                // get the Batch Error records
                for (ReadingUpload__c objReadingUpload : readingUploadList) {
                    BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                    record.uniqueId = objReadingUpload.Id;
                    record.isSelected = false;
                    record.readOnlyFields = new Map<String, Boolean>();
                    record.objectMap = new Map<String, sObject>();
                    record.objectMap.put(objectName, objReadingUpload);
                    record.transformFieldMap = new Map<String,Map<String,String>>();
                    Map<String,String> readingUploadTransformFieldMap = new Map<String,String>();
                    string readingId = mapReadingByReadingUpload.get(objReadingUpload.Id);
                    if(readingId != null){
                        readingUploadTransformFieldMap.put(readingId,readingMap.get(readingId).Name);
                        record.transformFieldMap.put(LoAp_Constants.READINGLABEL, readingUploadTransformFieldMap); 
                    }
                    records.add(record);
                }
            }
            return records;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    } 
    
    /**********************************************************************************************
    @author      : Echo:Ankit Gangwani
    @date        : 14 June 2018
    @params      : Sting recordIdString - the list of referenced Ids
    @return      : List<GLAp_FieldProps>
    @description : This method returns the Map of referenced object Id and object name
    **********************************************************************************************/
	public static Map<Id,String> getRecordName(List<Id> recordIdString){
		Map<Id,String> referenceIdNameMap = new Map<Id,String>();
		if(!recordIdString.isEmpty()) {
			String objName = getObjectType(recordIdString[0]);
			List<SObject> retList = Database.query('SELECT Id, Title FROM ' + objName + ' WHERE Id = :recordIdString');
			if(!retList.isEmpty()){
                for(Sobject obj : retList){
                    referenceIdNameMap.put(obj.Id, (String)obj.get('Title'));
                }
			}
		}
		return referenceIdNameMap;
	}
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 08 June 2018
    @params      : Sting objectId - the object Id of the referenced object 
    @return      : List<GLAp_FieldProps>
    @description : This method returns the object name of the referenced object
    **********************************************************************************************/
    @testVisible		
	private static string getObjectType(string objectId){
		Id sId = (Id)objectId;
		return sId.getSobjectType().getDescribe().getName();
	}
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord>
	@param			Id BRQId
    @description    get the list of Batch Request Queue records to display
    *******************************************************************************/
    @AuraEnabled
    public static void cancelledStatus(Id BRQId) {
        try {
            BatchRequestQueue__c objBRQ = [SELECT Id, CreatedDate,NotificationUser__c,Status__c FROM BatchRequestQueue__c WHERE Id=: BRQId];
            if(objBRQ.Id != null){
                objBRQ.Status__c = LoAp_Constants.Cancelled;
                objBRQ = (BatchRequestQueue__c)GlUt_FieldSecurity.cleanseFields(objBRQ, false);
                update objBRQ;
            }
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }    
}