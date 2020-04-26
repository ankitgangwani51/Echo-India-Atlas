/******************************************************************************
@author         Echo: Mohit Tayal
@date           29 May 2018
@description    Component controller for BookExportRequest lightning component
@Revisions      
*******************************************************************************/
public with sharing class LoAp_BookExportRequestCtrlr {

    private static final String CLASS_NAME = 'LoAp_BookExportRequestCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    public static List<String> brqFields = new List<String>();
    public static List<String> batchProcessFields = new List<String>();
    public static List<String> readTimetableFields = new List<String>();
    public static List<String> readPeriodFields = new List<String>();
    public static List<String> contentDocumentFields = new List<String>();
    public static List<String> batchErrorFields = new List<String>();
    
    static{
        brqFields.add(GlUt_APIConstantsBatchRequestQueue.CREATEDDATEAPINAME);
        brqFields.add(GlUt_APIConstantsBatchRequestQueue.STATUSAPINAME);
        
        readTimetableFields.add(GlUt_APIConstantsReadTimetable.READFREQUENCYAPINAME);
        
        readPeriodFields.add(GlUt_APIConstantsReadPeriod.NAMEAPINAME);
        
        contentDocumentFields.add('Id');
        contentDocumentFields.add('ContentSize');
        contentDocumentFields.add('FileType');
        
        batchErrorFields.add(GlUt_APIConstantsBatchError.ERRORDETAILSAPINAME);
        batchErrorFields.add(GlUt_APIConstantsBatchError.BATCHREQUESTIDAPINAME);
    }
    
    
    
    
    
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 31 May 2018
    @params      : none
    @return      : List<GLAp_FieldProps>
    @description : This method returns the list of field properties which will display on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GlAp_Fieldprops> retrieveBookExportRequestFields(){
        List<GlAp_FieldProps> lstFieldProps = new List<GlAp_FieldProps>();
        try{
            lstFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME, brqFields);
            List<GlAp_FieldProps> lstReadTimetablefieldprops = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReadTimetable.READTIMETABLEAPINAME, 
                                                                                                                  readTimetableFields);
            for(GlAp_FieldProps objGlAp_FieldProps : lstReadTimetablefieldprops){
                if(objGlAp_FieldProps.fieldLabel == LoAp_constants.READFREQUENCYLABEL){
                    objGlAp_FieldProps.fieldLabel = LoAp_constants.READTIMETABLELABEL;
                }
            }
            lstFieldProps.add(1,lstReadTimetablefieldprops[0]);
            List<GlAp_FieldProps> lstReadPeriodfieldprop = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReadPeriod.READPERIODAPINAME, readPeriodFields);
            for(GlAp_FieldProps objGlAp_FieldProps : lstReadPeriodfieldprop){
                if(objGlAp_FieldProps.fieldLabel == LoAp_constants.READPERIODNOLABEL){
                    objGlAp_FieldProps.fieldLabel = LoAp_constants.READPERIODLABEL;
                }
            }
            lstFieldProps.add(2,lstReadPeriodfieldprop[0]);
            GlAp_FieldProps fieldprop2 = new GlAp_FieldProps(false, false, true, false, GlUt_APIConstantsBatchRequestQueue.USERAPINAME, 
                                                             LoAp_Constants.NOTIFICATIONUSERFIELDNAME, LoAp_Constants.REFERENCEFIELD, true, 
                                                             GlUt_APIConstantsBatchRequestQueue.USERAPINAME);
            lstFieldProps.add(3,fieldprop2);
            GlAp_FieldProps fieldprop3 = new GlAp_FieldProps(false, false, false, false, LoAp_Constants.ACTION, LoAp_Constants.ACTION, 
                                                             LoAp_Constants.TEXT, false, GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME);
            fieldprop3.buttonField = True;
            lstFieldProps.add(fieldprop3);
        }catch(exception e){
            GlUt_Logger.logException(e);
            system.debug('Error : ' +e.getMessage());
        }finally{
            GlUt_Logger.writeLogsToDatabase();
        }
        return lstfieldProps;
    }
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 31 May 2018
    @params      : none
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the list of BlAp_CombinedRecord which will display on the screen 
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveBookExportRequestRecords(){
        List<BlAp_CombinedRecord> lstRecords = new List<BlAp_CombinedRecord>();
        try{
            String filterStatement = ' WHERE ' + GlUt_APIConstantsBatchProcess.OPERATIONAPINAME + ' = \'' + LoAp_Constants.BATCHPROCESSOPERATION + '\'' 
                                     + + ' AND ' + GlUt_APIConstantsBatchProcess.BATCHCLASSAPINAME  + ' = \'' + LoAp_Constants.BATCHPROCESSEXPORTBOOKCLASSNAME + '\''; 
            batchProcessFields.add('Id');
            List<BatchProcess__c> lstBatchProcess = (List<BatchProcess__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBatchProcess.BATCHPROCESSAPINAME ,
                                                                                                               batchProcessFields, filterStatement);
            List<Id> lstBatchProcessIds = new List<Id>();
            if(!lstBatchProcess.isEmpty()){
                for(BatchProcess__c objBatchProcess : lstBatchProcess){
                    lstBatchProcessIds.add(objBatchProcess.Id);
                }
            }
            
            brqFields.add(GlUt_APIConstantsBatchRequestQueue.USERAPINAME);
            brqFields.add(GlUt_APIConstantsBatchRequestQueue.PARAMETERAPINAME);
            if(!lstBatchProcessIds.isEmpty()){    
                List<BatchRequestQueue__c> lstBatchRequestQueue = (List<BatchRequestQueue__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME, 
                                                                                                                                  brqFields,
                                                                                                                                  String.format('WHERE {0} IN {1} AND {2} ORDER BY CreatedDate DESC',
                                                                                                                                                new List<String>{GlUt_APIConstantsBatchProcess.BATCHPROCESSAPINAME,GlUt_FieldSecurity.IdsToString(lstBatchProcessIds),
                                                                                                                                                    GlUt_APIConstantsBatchRequestQueue.TYPEAPINAME + ' = \'' + LoAp_Constants.BATCHPROCESSTYPE + '\''
                                                                                                                                                    }));
                if(!lstBatchRequestQueue.isEmpty()){    
                    Map<Id,Id> batchRequestIdReadTimeTableIdMap = new Map<Id,Id>();
                    Map<Id,Id> batchRequestIdReadPeriodIdMap = new Map<Id,Id>();
                    List<Id> lstreferencefield = new List<Id>();
                    for(BatchRequestQueue__c objBatchRequestQueue : lstBatchRequestQueue){
                        if(objBatchRequestQueue.Parameters__c != null){
                            lstreferencefield.add(objBatchRequestQueue.NotificationUser__c);
                            LoPr_BookExportParameters bookExportParameter = LoPr_BookExportParameters.parse(objBatchRequestQueue.Parameters__c);
                            batchRequestIdReadTimeTableIdMap.put(objBatchRequestQueue.Id,bookExportParameter.timetableID);
                            batchRequestIdReadPeriodIdMap.put(objBatchRequestQueue.Id,bookExportParameter.periodID);
                        }
                    }
                    Map<Id,String> notificationIdReferenceNameMap = new Map<Id,String>();
                    if(!lstreferencefield.isEmpty()){
                        notificationIdReferenceNameMap = GlAp_LightningDataAccess.getRecordName(lstreferencefield);
                    }

                    if(!batchRequestIdReadTimeTableIdMap.values().isEmpty() && !batchRequestIdReadPeriodIdMap.values().isEmpty()){
                        List<ReadTimetable__c> lstReadTimetable = (List<ReadTimetable__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadTimetable.READTIMETABLEAPINAME, 
                                                                                                                               readTimetableFields,
                                                                                                                               String.format('WHERE {0} IN {1}',new List<String>{'Id',GlUt_FieldSecurity.IdsToString(batchRequestIdReadTimeTableIdMap.values())})
                                                                                                                              );
                        if(!lstReadTimetable.isEmpty()){
                            List<ReadPeriod__c> lstReadPeriod = (List<ReadPeriod__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadPeriod.READPERIODAPINAME, 
                                                                                                                          readPeriodFields,
                                                                                                                          String.format('WHERE {0} IN {1}',new List<String>{'Id',GlUt_FieldSecurity.IdsToString(batchRequestIdReadPeriodIdMap.values())})
                                                                                                                         );
                            if(!lstReadPeriod.isEmpty()){
                                Map<Id,ReadTimetable__c> readTimeTableIdRecordMap = new Map<Id,ReadTimetable__c>();
                                
                                Map<Id,ReadPeriod__c> readPeriodIdRecordMap = new Map<Id,ReadPeriod__c>();
                                
                                for(ReadTimetable__c objReadTimetable : lstReadTimetable){
                                    readTimeTableIdRecordMap.put(objReadTimetable.Id, objReadTimetable);
                                }
                                
                                for(ReadPeriod__c objReadPeriod : lstReadPeriod){
                                    readPeriodIdRecordMap.put(objReadPeriod.Id, objReadPeriod);
                                }
                                
                                for(BatchRequestQueue__c objBatchRequestQueue : lstBatchRequestQueue){
                                    BlAp_CombinedRecord record = new BlAp_CombinedRecord();
                                    record.uniqueId = objBatchRequestQueue.Id;
                                    record.isSelected = false;
                                    record.objectMap = new Map<String, sObject>();
                                    record.objectMap.put(GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME, objBatchRequestQueue);
                                    if(!notificationIdReferenceNameMap.isEmpty() || !readTimeTableIdRecordMap.isEmpty() || !readPeriodIdRecordMap.isEmpty()){
                                        if(!readTimeTableIdRecordMap.isEmpty()){
                                            record.objectMap.put(GlUt_APIConstantsReadTimetable.READTIMETABLEAPINAME, readTimeTableIdRecordMap.get(batchRequestIdReadTimeTableIdMap.get(objBatchRequestQueue.Id)));
                                        }
                                        if(!readPeriodIdRecordMap.isEmpty()){
                                            record.objectMap.put(GlUt_APIConstantsReadPeriod.READPERIODAPINAME, readPeriodIdRecordMap.get(batchRequestIdReadPeriodIdMap.get(objBatchRequestQueue.Id)));
                                        }
                                        
                                        record.transformFieldMap = new Map<String,Map<String,String>>();
                                        if(!notificationIdReferenceNameMap.isEmpty()){
                                            Map<String,String> notificationTransformFieldMap = new Map<String,String>();
                                            notificationTransformFieldMap.put(objBatchRequestQueue.NotificationUser__c,
                                                                              notificationIdReferenceNameMap.get(objBatchRequestQueue.NotificationUser__c));
                                            record.transformFieldMap.put(GlUt_APIConstantsBatchRequestQueue.USERAPINAME ,notificationTransformFieldMap);
                                        }
                                    }
                                    
                                    // initialise the button attributes
                                    record.buttonAttributes = new List<BlAp_CombinedRecord.ButtonAttribute>();
                                    
                                    // add cancel button display attributes
                                    String buttonStatus = (objBatchRequestQueue.Status__c == Label.GlAp_Initialised 
            												|| objBatchRequestQueue.Status__c == Label.GlAp_Processing
            												|| objBatchRequestQueue.Status__c == Label.GlAp_Pending) 
            											? CuAp_Constants.BUTTON_ACTIVE : CuAp_Constants.BUTTON_INACTIVE;
                                                
                                    record.buttonAttributes.add(new BlAp_CombinedRecord.ButtonAttribute(LoAp_Constants.ACTION, 
                                                                                                        LoAp_Constants.CANCEL, 
                                                                                                        buttonStatus));
                                    system.debug(DEBUG + 'record.buttonAttributes: ' + record.buttonAttributes);
                                    lstRecords.add(record);
                                }
                            }
                        }
                    }
                }
            }
        }catch(exception e){
            GlUt_Logger.logException(e);
            system.debug('Error : ' + e.getMessage());
        }finally{
            GlUt_Logger.writeLogsToDatabase();
        }
        return lstRecords;
    }
    
    /**********************************************************************************************
    @author      : Echo: Mohit Tayal
    @date        : 31 May 2018
    @params      : Sting activeTab - to identify currently which tab is active
    @return      : List<GLAp_FieldProps>
    @description : This method returns the list of field properties based on the active tab 
    **********************************************************************************************/
    @AuraEnabled
    public static Map<String, List<GLAp_FieldProps>> retrieveFieldPropDetails() {
        Map<String, List<GLAp_FieldProps>> tabFields = new Map<String, List<GLAp_FieldProps>>();
        try {
            tabFields.put(Label.LoAp_BookExportRequestTab1, GlAp_SelectBookCtrlr.retrieveBookPropDetails());
            tabFields.put(Label.GlAp_FilesTab, GlAp_BatchRequestQueueCtrlr.retrieveFieldPropDetails('ContentDocument', contentDocumentFields));
            tabFields.put(Label.GlAp_ErrorsTab, GlAp_BatchRequestQueueCtrlr.retrieveFieldPropDetails(GlUt_APIConstantsBatchError.BATCHERRORAPINAME, batchErrorFields));
	        
        } catch (exception e) {
            GlUt_Logger.logException(e);
            system.debug('Error : ' + e.getMessage());
            
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return tabFields;
    }
    
    /**********************************************************************************************
    @author:		Echo: Patrick Dixon
    @date:			25 Jun 2018
    @description:	sub class for tabs
    **********************************************************************************************/
	public class tab {
		
		@AuraEnabled public String tabName;
		@AuraEnabled public Integer numberOfRecords;
		@AuraEnabled public List<BlAp_CombinedRecord> records;
		
	    /**********************************************************************************************
	    @author:		Echo: Patrick Dixon
	    @date:			25 Jun 2018
	    @description:	constructor
	    **********************************************************************************************/
		public tab(String tabName, List<BlAp_CombinedRecord> records) {
			this.tabName = tabName;
			this.records = records;
			numberOfRecords = records.size();
		}
	}

    /**********************************************************************************************
    @author      : Echo : Mohit Tayal
    @date        : 31 May 2018
    @return      : List<BlAp_CombinedRecord>
    @parameter   : string activeTab - To identify that currently which tab is active
                   List<Id> periodIds - While get the list of Read period Ids
                   String BatchRequestQueueId - Hold the batch request id of the record selected on
                                                screen
    @description : This method returns the list of book,content document, batch error records based on the active tab
    **********************************************************************************************/
    @AuraEnabled
    public static List<tab> retrieveTabRecords(List<Id> periodIds, String batchRequestQueueId) {
        List<tab> tabs = new List<tab>();
        
        try {
            
            tabs.add(new tab(Label.LoAP_BookExportRequestTab1, 
            				GlAp_SelectBookCtrlr.getBooks(periodIds, LoAp_Constants.BOOKSECTION + LoAp_Constants.BATCHPROCESSOPERATION)));
        
            tabs.add(new tab(Label.GlAp_FilesTab, 
            				GlAp_BatchRequestQueueCtrlr.retrieveFilesRecords('ContentDocument', contentDocumentFields, BatchRequestQueueId)));
        
            tabs.add(new tab(Label.GlAp_ErrorsTab, 
            				GlAp_BatchRequestQueueCtrlr.retrieveErrorRecords(GlUt_APIConstantsBatchError.BATCHERRORAPINAME, batchErrorFields, BatchRequestQueueId)));
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            system.debug('Error : ' + e.getMessage());
            
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return tabs;
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           31 May 2018
    @return         List<BlAp_CombinedRecord>
    @description    Cancel the batch request queue record and get the updated list of records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> cancelledStatus(Id BRQId) {
        try {
            GlAp_BatchRequestQueueCtrlr.cancelledStatus(BRQId);
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
		return retrieveBookExportRequestRecords();
    }
}