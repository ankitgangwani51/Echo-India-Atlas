/******************************************************************************
@author         Echo: Swati Mathur
@date           10 May 2018
@description    Component controller for ReadTimetable Maintenance lightning component
@revesion 		Changes by Dependra Singh - Security Review - 14-09-2018
*******************************************************************************/
public with sharing class LoAp_ReadTimetableMaintenanceCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_ReadTimetableMaintenanceCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> readingModeFields = new List<String> {
        GlUt_APIConstantsReadingMode.AREAAPINAME,
        GlUt_APIConstantsReadingMode.DEPOTAPINAME,
        GlUt_APIConstantsReadingMode.BOOKAPINAME,
        GlUt_APIConstantsReadingMode.MODEAPINAME,
        GlUt_APIConstantsReadingMode.ESTIMATEDATEAPINAME
    }; 
        
    private static final List<String> modeFieldValues = new List<String> {
        LoAp_Constants.ACTUALMODE,
        LoAp_Constants.ESTIMATEMODE
    };
        
    private static final List<String> areaFields = new List<String> {
        GlUt_APIConstantsArea.NAME
    };
       
    private static final List<String> depotFields = new List<String> {
        GlUt_APIConstantsDepot.AREAAPINAME,
        GlUt_APIConstantsDepot.NAME
    };
        
    private static final List<String> bookFields = new List<String> {
        GlUt_APIConstantsBook.NAME       
    };
    private static final List<String> readPeriodFields = new List<String> {
        GlUt_APIConstantsReadPeriod.READSTARTAPINAME,
        GlUt_APIConstantsReadPeriod.READENDAPINAME    
    };
        
    private static final List<Area__c> Areas = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsArea.AREAAPINAME,areaFields); 
    private static final List<Depot__c> Depots = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDepot.DEPOTAPINAME, depotFields);
    private static final List<Book__c> Books =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBook.BOOKAPINAME, bookFields);
    
                            
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @return         List<GLAp_FieldProps> - list of field properties for device table
    @description    get the field properties for the ReadTimetable__c object
    *******************************************************************************/
        @AuraEnabled
        public static List<GLAp_FieldProps> retrieveFieldPropDetails(String SectionName) {
            try {
                List<GLAp_FieldProps> readingModePropFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReadingMode.READINGMODEAPINAME, readingModeFields);                
                List<GLAp_FieldProps> areaPropFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsArea.AREAAPINAME, areaFields);
                List<GLAp_FieldProps> depotPropFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDepot.DEPOTAPINAME, depotFields);
                List<GLAp_FieldProps> bookPropFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBook.BOOKAPINAME, bookFields);
                
                List<String> lstArea = new List<String>();
                lstArea.add(System.Label.CuAp_FilterNone);
                for(Area__c objArea : Areas){
                    lstArea.add(objArea.Name);            
                }
                
                List<String> lstDepot = new List<String>(); 
                lstDepot.add(System.Label.CuAp_FilterNone);
                for(Depot__c objDepot : Depots){
                    lstDepot.add(objDepot.Name);            
                }
                
                List<String> lstBook = new List<String>(); 
                lstBook.add(System.Label.CuAp_FilterNone);
                for(Book__c objBook : Books){
                    lstBook.add(objBook.Name);            
                }
                List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
                if (SectionName == LoAp_Constants.AREASECTION ){                
                    for(GLAp_FieldProps areafldProp : areaPropFields){
                        if( areafldProp.fieldName == GlUt_APIConstantsArea.NAME){
                            areafldProp.fieldLabel = areafldProp.fieldName;
                            areafldProp.isEditable = true;
                            areafldProp.fieldType = 'select';  
                            areafldProp.pickListValues = lstArea;
                            fldPropList.add(areafldProp);
                        }
                        
                    }                
                }
                if (SectionName == LoAp_Constants.DEPOTSECTION ){
                    for(GLAp_FieldProps areafldProp : areaPropFields){
                        if( areafldProp.fieldName == GlUt_APIConstantsArea.NAME){
                            areafldProp.fieldLabel = LoBt_Constants.AREALABEL;
                            areafldProp.isEditable = false;
                            fldPropList.add(areafldProp);
                        }                        
                    }  
                    
                    for(GLAp_FieldProps depotfldProp : depotPropFields){                            
                        if( depotfldProp.fieldLabel == LoBt_Constants.DEPOTLABEL){
                            depotfldProp.fieldLabel = depotfldProp.fieldName;
                            depotfldProp.isEditable = true;
                            depotfldProp.fieldType = 'select';
                            depotfldProp.pickListValues = lstDepot; 
                            fldPropList.add(depotfldProp);
                        }
                    }                
                }
                if (SectionName == LoAp_Constants.BOOKSECTION){                
                    for(GLAp_FieldProps bookfldProp : bookPropFields){
                        if( bookfldProp.fieldName == GlUt_APIConstantsBook.NAME){
                            bookfldProp.fieldLabel = bookfldProp.fieldName;
                            bookfldProp.isEditable = true; 
                            bookfldProp.fieldType = 'select';
                            bookfldProp.pickListValues = lstBook;
                            fldPropList.add(bookfldProp);
                        }
                    }                
                }
                
                for(GLAp_FieldProps readingModefldProp : readingModePropFields){
                    
                    if(readingModefldProp.fieldName == GlUt_APIConstantsReadingMode.MODEAPINAME){
                        readingModefldProp.fieldType = 'select'; 
                        readingModefldProp.pickListValues = modeFieldValues;
                        readingModefldProp.isEditable = true;
                        fldPropList.add(readingModefldProp);
                    } 
                    
                    if(readingModefldProp.fieldName == GlUt_APIConstantsReadingMode.ESTIMATEDATEAPINAME){                    
                        readingModefldProp.isEditable = true;
                        fldPropList.add(readingModefldProp);
                    }   
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
    
    /**********************************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @param          readingPeriodId
    @return         instance of wrapper class 
    @description    This method will collect the required details in wrapper and send it to helper
    **********************************************************************************************/
    @AuraEnabled
    Public static ContainerWrapper getReadingModeRecords(Id readingPeriodId){
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper();
        try {            
            resultContainer.areaRecordList = retrieveAreaRecords(readingPeriodId);
            resultContainer.depotRecordList = retrieveDepotRecords(readingPeriodId);
            resultContainer.bookRecordList = retrieveBookRecords(readingPeriodId);  
            return resultContainer;
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
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord> - list of combined records to display
    @description    get the list of records to display
    *******************************************************************************/
    
    public static List<BlAp_CombinedRecord> retrieveAreaRecords(Id readingPeriodId) {
        
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();        
        String filterStatement = 'WHERE ' + GlUt_APIConstantsReadPeriod.READPERIODAPINAME + '= \'' + readingPeriodId + '\' AND ' + GlUt_APIConstantsReadingMode.AREAAPINAME + ' != null' + 
                                + ' AND ' + GlUt_APIConstantsReadingMode.DEPOTAPINAME + ' = null AND ' + GlUt_APIConstantsReadingMode.BOOKAPINAME + ' = null ';    // AT-4065   
        // get the ReadingMode records
        List<ReadingMode__c> lstReadingMode =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,
                                                                                   readingModeFields,
                                                                                   filterStatement);
        Map<Id,Area__c> areaMap = new Map<Id,Area__c>(Areas);        
        for (ReadingMode__c objReadingMode : lstReadingMode){
            BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
            record.uniqueId = objReadingMode.Id;
            record.isSelected = false;
            record.readOnlyFields = new Map<String, Boolean>(); 
            if (objReadingMode.Mode__c != LoAp_Constants.ESTIMATEMODE){
            record.readOnlyFields.put(GlUt_APIConstantsReadingMode.ESTIMATEDATEFIELDREFERENCE,true);
            }
            record.objectMap = new Map<String, sObject>();
            record.objectMap.put(GlUt_APIConstantsReadingMode.READINGMODEAPINAME, objReadingMode);
            if (areaMap.containsKey(objReadingMode.Area__c)){
                record.objectMap.put(GlUt_APIConstantsArea.AREAAPINAME, areaMap.get(objReadingMode.Area__c));
                record.readOnlyFields.put(GlUt_APIConstantsArea.AREANAME,true);
            }
            records.add(record);
        }
        return records;
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord> - list of combined records to display
    @description    get the list of records to display
    *******************************************************************************/
    
    public static List<BlAp_CombinedRecord> retrieveDepotRecords(Id readingPeriodId) {
        
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        String filterStatement = 'WHERE ' + GlUt_APIConstantsReadPeriod.READPERIODAPINAME + '= \'' + readingPeriodId + '\' AND ' + GlUt_APIConstantsReadingMode.DEPOTAPINAME + ' != null ' +
        						+ ' AND ' + GlUt_APIConstantsReadingMode.AREAAPINAME + ' = null AND ' + GlUt_APIConstantsReadingMode.BOOKAPINAME + ' = null ';    // AT-4065  
        // get the ReadingMode records
        List<ReadingMode__c> lstReadingMode =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,
                                                                                   readingModeFields,
                                                                                   filterStatement);
        Map<Id,String> depot2AreaMap = new Map<Id,String>();
        for(Depot__c obj :Depots){
            depot2AreaMap.put(obj.Id, obj.Area__c);
        }
        Map<Id,Depot__c> depotMap = new Map<Id,Depot__c>(Depots); 
        Map<Id,Area__c> areaMap = new Map<Id,Area__c>(Areas);
        for (ReadingMode__c objReadingMode : lstReadingMode){
            BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
            record.uniqueId = objReadingMode.Id;
            record.isSelected = false;
            record.readOnlyFields = new Map<String, Boolean>();            
            if (objReadingMode.Mode__c != LoAp_Constants.ESTIMATEMODE){
            record.readOnlyFields.put(GlUt_APIConstantsReadingMode.ESTIMATEDATEFIELDREFERENCE,true);
            }
            record.objectMap = new Map<String, sObject>();
            record.objectMap.put(GlUt_APIConstantsReadingMode.READINGMODEAPINAME, objReadingMode);            
            if (depotMap.containsKey(objReadingMode.Depot__c)){
                record.objectMap.put(GlUt_APIConstantsDepot.DEPOTAPINAME, depotMap.get(objReadingMode.Depot__c));
                record.objectMap.put(GlUt_APIConstantsArea.AREAAPINAME, areaMap.get(depot2AreaMap.get(objReadingMode.Depot__c)));
                record.readOnlyFields.put(GlUt_APIConstantsDepot.DEPOTNAME,true);
            }
            records.add(record);
        }
        return records;
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @return         List<BlAp_CombinedRecord> - list of combined device records to display
    @description    get the list of device records to display
    *******************************************************************************/
    
    public static List<BlAp_CombinedRecord> retrieveBookRecords(Id readingPeriodId) {
        
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        String filterStatement = 'WHERE ' + GlUt_APIConstantsReadPeriod.READPERIODAPINAME + '= \'' + readingPeriodId + '\' AND ' + GlUt_APIConstantsReadingMode.BOOKAPINAME + ' != null' +        
        						+ ' AND ' + GlUt_APIConstantsReadingMode.AREAAPINAME + ' = null AND ' + GlUt_APIConstantsReadingMode.DEPOTAPINAME + ' = null ';    // AT-4065 
        // get the ReadingMode records
        List<ReadingMode__c> lstReadingMode =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,
                                                                                   readingModeFields,
                                                                                   filterStatement); 
        Map<Id,Book__c> bookMap = new Map<Id,Book__c>(Books); 
        for (ReadingMode__c objReadingMode : lstReadingMode){
            BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
            record.uniqueId = objReadingMode.Id;
            record.isSelected = false;
            record.readOnlyFields = new Map<String, Boolean>();            
            if (objReadingMode.Mode__c != LoAp_Constants.ESTIMATEMODE){
            record.readOnlyFields.put(GlUt_APIConstantsReadingMode.ESTIMATEDATEFIELDREFERENCE,true);
            }
            record.objectMap = new Map<String, sObject>();
            record.objectMap.put(GlUt_APIConstantsReadingMode.READINGMODEAPINAME, objReadingMode);
            if (bookMap.containsKey(objReadingMode.Book__c)){
                record.objectMap.put(GlUt_APIConstantsBook.BOOKAPINAME, bookMap.get(objReadingMode.Book__c));
                record.readOnlyFields.put(GlUt_APIConstantsBook.BOOKNAME,true);
            }
            records.add(record);
        }
        return records;
    }
        
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @return         BlAp_CombinedRecord objcet
    @description    get the blank Row
    *******************************************************************************/
    @AuraEnabled
    public static BlAp_CombinedRecord blankRow(Id readingPeriodId,String SectionName) {
        try {            
            ReadingMode__c obj = new ReadingMode__c();
            obj.ReadPeriod__c = readingPeriodId;
            Area__c objArea = new Area__c();
            Depot__c objDepot = new Depot__c();
            Book__c objBook = new Book__c();
            
            BlAp_CombinedRecord record = new BlAp_CombinedRecord();
            record.uniqueId = null;
            record.isSelected = false;
            record.readOnlyFields = new Map<String, Boolean>();   
            record.readOnlyFields.put(GlUt_APIConstantsReadingMode.ESTIMATEDATEFIELDREFERENCE,true);
            record.objectMap = new Map<String, sObject>();
            record.objectMap.put(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,obj);
            if (SectionName == LoAp_Constants.AREASECTION ){  
                record.objectMap.put(GlUt_APIConstantsArea.AREAAPINAME, objArea);
            }
            if (SectionName == LoAp_Constants.DEPOTSECTION ){  
                record.objectMap.put(GlUt_APIConstantsDepot.DEPOTAPINAME, objDepot);
            }
            if (SectionName == LoAp_Constants.BOOKSECTION ){  
                record.objectMap.put(GlUt_APIConstantsBook.BOOKAPINAME,objBook);
            }
            return record;
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
    @date           11 May 2018
    @return         none
    @param 			Id readingModeId
    @description    delete reading mode record
    *******************************************************************************/
    @AuraEnabled
    public static void deleteRecord(Id readingModeId) {
        try {
            if(readingModeId != null){
                //Changes by Dependra Singh - Security Review - 14-09-2018
                List<ReadingMode__c> lstReadingMode =[Select Id FROM ReadingMode__c  WHERE ID =: readingModeId];
                List<ReadingMode__c> lstReadingModeRecs = (List<ReadingMode__c>)GlUt_FieldSecurity.cleanseFields(lstReadingMode, false); 
                if(lstReadingModeRecs != null && !lstReadingModeRecs.isEmpty() )
                    delete lstReadingModeRecs;  
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 19 July 2018
    @params      : Id readingPeriodId
    @return      : ReadPeriod__c
    @description : This method returns Read Period Record on the basis of read period Id. 
    **********************************************************************************************/
    //Changes for AT-3040 Starts Here
    @AuraEnabled
    public static ReadPeriod__c getReadPeriod(Id readingPeriodId ) {
        try {
            ReadPeriod__c readPeriod = GlUt_MeterBooksUtilities.getReadPeriod(readingPeriodId, readPeriodFields);
            return readPeriod;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    //Changes for AT-3040 Ends Here
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @return         none
	@param 			String responseJSON
    @description    Method is used to save the changes made
    *******************************************************************************/
    @AuraEnabled
    public static void doSave(String responseJSON){
        Savepoint sp = Database.setSavepoint();
        system.debug('100*****');
        List<ReadingMode__c> readingModeToUpsert = new List<ReadingMode__c>();       
        Map<String,Id> areaNametoIdMap = new Map<String,Id>();
        Map<String,Id> depotNametoIdMap = new Map<String,Id>();
        Map<String,Id> bookNametoIdMap = new Map<String,Id>();
        try {
            List<BlAp_CombinedRecord> recordList = (List<BlAp_CombinedRecord>) System.JSON.deserialize(responseJSON, List<BlAp_CombinedRecord>.class);
            for(Area__c objArea : Areas){   
                areaNametoIdMap.put(objArea.Name, objArea.Id);
            }  
            for(Depot__c objDepot : Depots){
                depotNametoIdMap.put(objDepot.Name, objDepot.Id);            
            }  
            for(Book__c objBook : Books){
                bookNametoIdMap.put(objBook.Name, objBook.Id);            
            }
            for(BlAp_CombinedRecord objRec : recordList){                 
                ReadingMode__c objReadingMode = (ReadingMode__c)objRec.objectMap.get(GlUt_APIConstantsReadingMode.READINGMODEAPINAME);
                if(objRec.objectMap.containsKey(GlUt_APIConstantsArea.AREAAPINAME)){
                    Area__c objArea = (Area__c)objRec.objectMap.get(GlUt_APIConstantsArea.AREAAPINAME);
                    objReadingMode.Area__c = areaNametoIdMap.get(objArea.Name);
                }
                if(objRec.objectMap.containsKey(GlUt_APIConstantsDepot.DEPOTAPINAME)){
                    Depot__c objDepot = (Depot__c)objRec.objectMap.get(GlUt_APIConstantsDepot.DEPOTAPINAME);
                    objReadingMode.Depot__c = depotNametoIdMap.get(objDepot.Name);
                    objReadingMode.Area__c = null;
                }
                if(objRec.objectMap.containsKey(GlUt_APIConstantsBook.BOOKAPINAME)){
                    Book__c objBook  = (Book__c)objRec.objectMap.get(GlUt_APIConstantsBook.BOOKAPINAME);
                    objReadingMode.Book__c = bookNametoIdMap.get(objBook.Name);
                } 
                if(objReadingMode.Mode__c == LoAp_Constants.ACTUALMODE){
                    objReadingMode.EstimateDate__c = null;
                }
                readingModeToUpsert.add(objReadingMode); 
            }
             
            if(readingModeToUpsert!=null) {                  
                List<sObject> readingModeSObjectList = GlUt_FieldSecurity.cleanseFields(readingModeToUpsert, false) ;
                readingModeToUpsert.clear();  
                if(!readingModeSObjectList.isEmpty())
                	readingModeToUpsert.addall((List<ReadingMode__c>)readingModeSObjectList);
	        	upsert readingModeToUpsert;
            } 
        }
        catch (exception e){            
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());            
        } finally { 
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @param          none
    @return         none
    @description    Wrapper Class 
    *******************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<BlAp_CombinedRecord> areaRecordList;
        @AuraEnabled public List<BlAp_CombinedRecord> depotRecordList;
        @AuraEnabled public List<BlAp_CombinedRecord> bookRecordList;
    }    
}