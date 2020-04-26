/******************************************************************************
@author         Echo: Swati Mathur
@date           08 May 2018
@description    Component controller for device related list lightning component
@Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class GlAp_ReadTimetableReadPeriodCtrlr {
    
    private static final String CLASS_NAME = 'GlAp_ReadTimetableReadPeriodCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> readTimetableFields = new List<String> {
        GlUt_APIConstantsReadTimetable.READTIMETABLENAMEAPINAME,
        GlUt_APIConstantsReadTimetable.READFREQUENCYAPINAME 
    };
    private static final List<String> readPeriodFields = new List<String> {
        GlUt_APIConstantsReadPeriod.ORDERAPINAME,
        GlUt_APIConstantsReadPeriod.BILLINGPERIODSTARTAPINAME,
        GlUt_APIConstantsReadPeriod.BILLINGPERIODENDAPINAME,
        GlUt_APIConstantsReadPeriod.READSTARTAPINAME,
        GlUt_APIConstantsReadPeriod.READENDAPINAME                        
    };
        
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           08 May 2018
    @return         List<GLAp_FieldProps> - list of field properties for device table
    @description    get the field properties for the ReadTimetable__c object
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveFieldPropDetails() {
        try {
            List<GLAp_FieldProps> fieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReadTimetable.READTIMETABLEAPINAME, readTimetableFields);
            List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
            
            for(GLAp_FieldProps fldProp : fieldProperties){
                if(fldProp.fieldName == GlUt_APIConstantsReadTimetable.READTIMETABLENAMEAPINAME){
                    fldProp.fieldLabel =LoAp_Constants.READINGTIMETABLELABEL;  
                }
                fldProp.isEditable = false;
                fldPropList.add(fldProp);
            }
            return fldPropList;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           08 May 2018
    @return         List<BlAp_CombinedRecord> - list of combined device records to display
    @description    get the list of device records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveRecords() {        
        try {
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            
            // get the readTimetable records
            List<ReadTimetable__c> lstReadTimetable =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadTimetable.READTIMETABLEAPINAME, readTimetableFields);
            
            for (ReadTimetable__c objReadTimetable : lstReadTimetable) {
                BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                record.uniqueId = objReadTimetable.Id;
                record.isSelected = false;
                record.readOnlyFields = new Map<String, Boolean>();
                record.objectMap = new Map<String, sObject>();
                record.objectMap.put(GlUt_APIConstantsReadTimetable.READTIMETABLEAPINAME, objReadTimetable);
                records.add(record);
            }
            records[0].isSelected = true;        
            return records;
            
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           08 May 2018
    @return         List<GLAp_FieldProps> - list of field properties for device table
    @description    get the field properties for the ReadPeriod__c object
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveReadPeriodFieldPropDetails() {
        try {
            List<GLAp_FieldProps> fieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReadPeriod.READPERIODAPINAME, readPeriodFields);
            List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
            for(GLAp_FieldProps fldProp : fieldProperties){
                if(fldProp.fieldName == GlUt_APIConstantsReadPeriod.BILLINGPERIODSTARTAPINAME){
                    fldProp.fieldLabel =LoAp_Constants.PERIODSTARTLABEL;                
                }
                if(fldProp.fieldName == GlUt_APIConstantsReadPeriod.BILLINGPERIODENDAPINAME){
                    fldProp.fieldLabel =LoAp_Constants.PERIODENDLABEL;                
                }
                fldPropList.add(fldProp);
            }
            return fldPropList;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           09 May 2018
    @param          Id - the Read Timetable Id
    @return         List<BlAp_CombinedRecord> - list of combined device records to display
    @description    get the list of device records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveReadPeriodRecords(Id ReadTimetableId) {
        
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        try {
            // get the readPeriods records
            List<ReadPeriod__c> lstReadPeriod =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadPeriod.READPERIODAPINAME, 
                                                                                     readPeriodFields, 
                                                                                     ReadTimetableId, 
                                                                                     GlUt_APIConstantsReadTimetable.READTIMETABLEAPINAME,
                                                                                     null,
                                                                                     ' ORDER BY ' + GlUt_APIConstantsReadPeriod.BILLINGPERIODSTARTAPINAME + ' DESC' );
            
            for (ReadPeriod__c objReadPeriod : lstReadPeriod) {
                BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                record.uniqueId = objReadPeriod.Id;
                record.isSelected = false;
                record.readOnlyFields = new Map<String, Boolean>();
                record.objectMap = new Map<String, sObject>();
                record.objectMap.put(GlUt_APIConstantsReadPeriod.READPERIODAPINAME, objReadPeriod);
                records.add(record);
            }
            return records;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}