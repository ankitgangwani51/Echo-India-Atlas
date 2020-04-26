/************************************************************************************************************
@author      : Echo : Ankit Gangwani
@date        : 17 Sept 2018
@description : CuAp_CustMoveAmendEnterReadingCtrlr class is used to enter readings
**************************************************************************************************************/
public with sharing class CuAp_CustMoveAmendEnterReadingCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_CustMoveAmendEnterReadingCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> supplyPointFields;
    private static final List<String> deviceFields;
    private static final List<String> readingFields;
    private static final List<String> supplyPointDeviceFields;
    
    static{
        supplyPointFields = new List<String>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME);
        
        deviceFields = new List<String>();
        deviceFields.add(GlUt_APIConstantsDevice.SERIALNOAPINAME);
        
        readingFields = new List<String>();
        readingFields.add(GlUt_APIConstantsReading.READINGDATEAPINAME);
        readingFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        readingFields.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);
        
        supplyPointDeviceFields = new List<String>();
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME);
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME);
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME);
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 17 Sept 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveReadingPropDetails() {        
        try{
            List<GlAp_FieldProps> addFieldProp = new List<GlAp_FieldProps>();
                        
            //Get the field properties for the Device object
            List<GLAp_FieldProps> supplyPointDeviceFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, supplyPointDeviceFields); 
            
            //Get the field properties for the Device object
            List<GLAp_FieldProps> deviceFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceFields); 
            
            //Get the field properties for the Reading object
            List<GLAp_FieldProps> readinFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readingFields); 
            
            // Added the supply point fields 
            for(GlAp_FieldProps fieldProp : supplyPointDeviceFieldProp){ 
                fieldProp.isEditable = false;  
                if(fieldProp.fieldName == GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME)
                    addFieldProp.add(fieldProp);
            } 
            
            // Added the Device fields
            for(GlAp_FieldProps fieldProp : deviceFieldProp){
                fieldProp.isEditable = false;
                fieldProp.fieldLabel = 'Serial #';
                addFieldProp.add(fieldProp);
            }
            
            // Added the Reading fields
            for(GlAp_FieldProps fieldProp : readinFieldProp){                
                if(fieldProp.fieldName == GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME){
                    fieldProp.isEditable = true;
                    fieldProp.fieldLabel = System.Label.CuAp_NewReadingLabel;                                    
                }
                if(fieldProp.fieldName == GlUt_APIConstantsReading.READINGMETHODAPINAME){
                    fieldProp.isEditable = true;
                }                    
                if(fieldProp.fieldName != GlUt_APIConstantsReading.READINGDATEAPINAME)
                    addFieldProp.add(fieldProp);
            }
            
            //Add Estimate button 
            GLAp_FieldProps estimateButton = new GLAp_FieldProps();
            estimateButton.isFLSVisible = true;
            estimateButton.isEncrypted = false;
            estimateButton.isEditable = false;
            estimateButton.isRequired = false;
            estimateButton.fieldName = CuAp_Constants.ESTIMATE;
            estimateButton.fieldLabel = CuAp_Constants.ESTIMATE;
            estimateButton.buttonField = true;
            estimateButton.transformField = true;            
            addFieldProp.add(estimateButton);
            
            // Return Supply Point, Device and Reading fields to display
            return addFieldProp;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           17 Sept 2018
    @param          locationId
	@return         List<BlAp_CombinedRecord>
    @description    This method returns the BlAp_CombinedRecord with list of Supply Points, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getSupplyPointAndDeviceRecords(Id locationId) {
        
        // Initialised collections
        Set<Id> deviceIdsSet = new Set<Id>();
        Set<Id> supplyPointIdsSet = new Set<Id>();
        List<Device__c> deviceLists = new List<Device__c>();
        List<Reading__c> readingLists = new List<Reading__c>();
        List<SupplyPoint__c> supplyPointLists = new List<SupplyPoint__c>();
        List<BlAp_CombinedRecord> activeSPDeviceList = new List<BlAp_CombinedRecord>();  
        List<SupplyPointDevice__c> supplyPointDeviceLists = new List<SupplyPointDevice__c>();        
        Map<Id,SupplyPointDevice__c> mapOfDeviceId2SupplyPointDevice = new Map<Id,SupplyPointDevice__c>();
        String filterStatement = '';
        // Intilaised the sObject(Reading__c) to get fields in helper
        Reading__c objReading = new Reading__c();
        objReading.ActualDeviceReading__c = '';
        objReading.ReadingMethod__c = '';
        
        try {
            if(locationId != null){
                filterStatement = '';            
                filterStatement = ' WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = \'' + locationId + '\'';            
                supplyPointLists = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                              new List<String>{LoAp_Constants.Id,
                                                                                                  GlUt_APIConstantsLocation.LOCATIONAPINAME}, 
                                                                                              filterStatement); 
            }
            
            if(!supplyPointLists.isEmpty()){                
                for(SupplyPoint__c objSupplyPoint : supplyPointLists){
                    supplyPointIdsSet.add(objSupplyPoint.Id);
                }
            }
            
            if(supplyPointIdsSet.size() > 0){
                filterStatement = 'WHERE ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIdsSet) ;
                filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = TRUE '; 
                supplyPointDeviceLists = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,
                                                                                                          supplyPointDeviceFields, 
                                                                                                          filterStatement);
                if(!supplyPointDeviceLists.isEmpty()){                    
                    for(SupplyPointDevice__c objSPD : supplyPointDeviceLists){                        
                        if(objSPD.Device__c != null){
                            mapOfDeviceId2SupplyPointDevice.put(objSPD.Device__c,objSPD);
                            deviceIdsSet.add(objSPD.Device__c);
                        }
                    }
                }
            }
            
            if(deviceIdsSet.size() > 0 ){
                deviceLists = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME,
                                                                                    deviceFields, 
                                                                                    'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(deviceIdsSet));                
                
            }            
                       
            if(!deviceLists.isEmpty()){
                for (Device__c objDevice : deviceLists) {
                    // Initialised the Combined record to display the data into table
                    BlAp_CombinedRecord combinedRecord = new BlAp_CombinedRecord();
                    combinedRecord.uniqueId = objDevice.Id;
                    combinedRecord.isSelected = true;
                    combinedRecord.objectMap = new Map<String, sObject>();
                    combinedRecord.objectMap.put(GlUt_APIConstantsDevice.DEVICEAPINAME ,objDevice);
                    combinedRecord.objectMap.put(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,mapOfDeviceId2SupplyPointDevice.get(objDevice.Id));
                    combinedRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME,objReading);
                    activeSPDeviceList.add(combinedRecord);
                }   
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return activeSPDeviceList;
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani                  
    @date        : 17 Sept 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveReadingsfieldList() {        
        
        List<GlAp_FieldProps> addFieldProp = new List<GlAp_FieldProps>();
        try{
            //Get the field properties for the Reading object
            List<GLAp_FieldProps> readinFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readingFields); 
            // Added the Reading fields
            for(GlAp_FieldProps fieldProp : readinFieldProp){                
                if(fieldProp.fieldName == GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME){
                    fieldProp.fieldLabel = LoAp_Constants.BATCHPROCESSREADINGTYPE;                                    
                }                    
                addFieldProp.add(fieldProp);
            }            
        }catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return addFieldProp;
    }  
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           17 Sept 2018
    @param          deviceId
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the BlAp_CombinedRecord with list of Readings, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveReadingsRecordList(Id deviceId){

        // Initialised collections
        List<Reading__c> readingLists = new List<Reading__c>();
        List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>();  
        
        try{
            String filterStatement;               
            if(deviceId != null){
                filterStatement = 'WHERE ' + GlUt_APIConstantsDevice.DEVICEAPINAME + ' = \'' + deviceId + '\'';                
                readingLists = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,
                                                                                      readingFields, 
                                                                                      filterStatement);                
                if(!readingLists.isEmpty()){                    
                    for (Reading__c objReading : readingLists) {
                        BlAp_CombinedRecord combinedRecord = new BlAp_CombinedRecord();
                        combinedRecord.uniqueId = objReading.Id;
                        combinedRecord.isSelected = false;
                        combinedRecord.objectMap = new Map<String, sObject>();
                        combinedRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME,objReading);
                        combinedRecordList.add(combinedRecord);
                    } 
                }
            }
        }catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return combinedRecordList;
    }    
        
    /**********************************************************************************************
    @author         Echo: Neha R.
    @date           19 Mar 2019
    @param          LocationId
    @return         Map<>
    @description    This method returns the all existing device Readings AT-5276
    **********************************************************************************************/
    @AuraEnabled   
    public static Map<Id,List<Reading__c>> getallDeviceReading(Id locationId){  
        
        Map<Id,List<Reading__c>> deviceExistingReding = new Map<Id,List<Reading__c>>();
        try {
            if(locationId != null){
                Map<Id, SupplyPoint__c> supplyPointMap = new Map<Id, SupplyPoint__c>([SELECT Id, Location__c 
                                                                                      FROM SupplyPoint__c 
                                                                                      WHERE Location__c =: locationId]);            
                if(supplyPointMap != null && !supplyPointMap.isEmpty()){   
                    List<SupplyPointDevice__c> supplyPointDeviceLists = new List<SupplyPointDevice__c>();
                    supplyPointDeviceLists = [SELECT Id, Device__c, SupplyPoint__c  
                                              FROM SupplyPointDevice__c 
                                              WHERE SupplyPoint__c IN: supplyPointMap.keySet()
                                              AND Active__c = true];
                    if(!supplyPointDeviceLists.isEmpty()){
                        Set<Id> deviceIdSet = new Set<Id>();
                        for(SupplyPointDevice__c objSPD: supplyPointDeviceLists){
                            deviceIdSet.add(objSPD.Device__c);
                        }
                        
                        List<Reading__c> allexistingReading = new List<Reading__c>();                        
                        String filterStatement = ' WHERE ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(deviceIdSet) + 
                            					 ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC, CreatedDate DESC'; 
                        List<String> newReadingList = readingFields.clone();
                        newReadingList.add(GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME);
                        allexistingReading = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,
                                                                                                    newReadingList, 
                                                                                                    filterStatement);
                        if(!allexistingReading.isEmpty()){
                            for(Reading__c objReading: allexistingReading){
                                if(!deviceExistingReding.containsKey(objReading.Device__c))
                                    deviceExistingReding.put(objReading.Device__c, new List<Reading__c>{});
                                
                                deviceExistingReding.get(objReading.Device__c).add(objReading);
                            }
                        }
                    }
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return deviceExistingReding;
    }
}