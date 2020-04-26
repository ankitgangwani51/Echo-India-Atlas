/******************************************************************************
@author      	Echo: Vivek Sethi
@date      		25-Oct-2018
@description	Component controller for Information Statement Add Reading Component
@revision		Echo:Sudhir Kumar
				AT-5361: Not able to ADD One Reading Per Device per Information Statement, when multiple devices are associated to Location

*******************************************************************************/
public with sharing class LoAp_InfoStatementAddReadingsCtrlr {
  
    private static final String CLASS_NAME = 'LoAp_InfoStatementAddReadingsCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> deviceTypeFields = new List<String> {
        GlUt_APIConstantsDeviceType.NAMEAPINAME
    };
    
    private static final List<String> deviceFields = new List<String>  {
        GlUt_APIConstantsDevice.DEVICENAMEAPINAME , 
        GlUt_APIConstantsDevice.SERIALNOAPINAME
    };
    private static final List<String> readingFields = new List<String>  {
        GlUt_APIConstantsReading.INFORMATIONSTATEMENT,
        GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME //AT-5361
    };
                
    /**********************************************************************************************
	@author      	Echo: Vivek Sethi
	@date      		25-Oct-2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	**********************************************************************************************/ 
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveDevicePropDetails() {
        List<GLAp_FieldProps> DeviceProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceFields);
   		List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        
        try {
            // Create transform field for Payment Allocation - Amount Allocated
            GLAp_FieldProps AvailServiceProperties = new GLAp_FieldProps();
            AvailServiceProperties.isFLSVisible = true;
            AvailServiceProperties.isEncrypted = false;
            AvailServiceProperties.isEditable = false;
            AvailServiceProperties.isRequired = false;
            AvailServiceProperties.fieldName = GlUt_APIConstantsAvailableService.NAMEAPINAME;
            AvailServiceProperties.fieldLabel = CuAp_Constants.SERVICETYPELBL;
            AvailServiceProperties.fieldType = 'text';
            AvailServiceProperties.transformField = true; //Indicates this is a Transfrom and NOT a DB field
            AvailServiceProperties.parentObject = GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME;
            
            for(GLAp_FieldProps fldProp : DeviceProperties){
                if (fldProp.fieldName == GlUt_APIConstantsDevice.DEVICENAMEAPINAME) 
                    fldPropList.add(fldProp); 
            }
            
            fldPropList.add(AvailServiceProperties); 
            
            for(GLAp_FieldProps fldProp : DeviceProperties){
                if (fldProp.fieldName ==  GlUt_APIConstantsDevice.SERIALNOAPINAME) {	// AT-5361
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp); 
                }
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
	@author      	Echo: Vivek Sethi
	@date      		25-Oct-2018
	@return         List<BlAp_CombinedRecord>
	@description    This method returns the Bill data
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveDeviceRecords(string infoStatementId) {
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        Set<Id> deviceTypeIds = new Set<Id>();
        Map<Id,Id> sPId2SPDMap = new Map<Id,Id>();
        Map<Id,String> deviceId2AvailServiceNameMap = new Map<Id,String>();
        Map<Id,Id> sPId2DeviceMap = new Map<Id,Id>();
        List<Id> sPDSupplyPointList = new List<Id>();
        List<Device__c> devicesList = new List<Device__c>();
        try {
            List<Id> locationId = new List<Id>();
            List<Device__c> devices = new List<Device__c>(); 
            for(InformationStatement__c objInformationStatement : [SELECT Id, 
                                                                   Location__c 
                                                                   FROM InformationStatement__c 
                                                                   WHERE Id =: infoStatementId LIMIT 1]) 
            {
                if(objInformationStatement.Location__c != null)                                                        
                    locationId.add(objInformationStatement.Location__c);
            }
            // build a map of the supply point devices related to the location
            if(locationId != null && !locationId.isEmpty()) {
                for(SupplyPointDevice__c sPD : [select Id,
                                                SupplyPoint__c,
                                                Device__c
                                                from SupplyPointDevice__c 
                                                where SupplyPoint__r.Location__c = :locationId[0]
                                                and Active__c = true])
                {
                    sPId2SPDMap.put(sPD.SupplyPoint__c,sPD.Id);
                    sPId2DeviceMap.put(sPD.SupplyPoint__c,sPD.Device__c);
                }
            }
            if(sPId2SPDMap != null && !sPId2SPDMap.isEmpty()){
                String availServiceNames = '';
                for(AvailableService__c availServiceObj : [Select Id,
                                                           SupplyPoint__c , 
                                                           ServiceType__r.name
                                                           from AvailableService__c
                                                           where SupplyPoint__c in:sPId2SPDMap.keyset()
                                                           and Active__c =: true])
                {
                    if(availServiceObj.ServiceType__r.name != null) {
                        
                        if(!deviceId2AvailServiceNameMap.containsKey(sPId2DeviceMap.get(availServiceObj.SupplyPoint__c)))
                            availServiceNames = '';  
                        
                        availServiceNames += '*' + availServiceObj.ServiceType__r.name; 
                        availServiceNames = availServiceNames.removeStart('*');
                        availServiceNames = availServiceNames.replace('*',', ');    
                        deviceId2AvailServiceNameMap.put(sPId2DeviceMap.get(availServiceObj.SupplyPoint__c),availServiceNames);
                    }
                }
               
                devicesList = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                    deviceFields, 
                                                                                    String.format('where Id IN (select {0} from {1} where Id IN {2})', 
                                                                                                  new List<String>{
                                                                                                      GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                                          GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                          GlUt_FieldSecurity.IdsToString(sPId2SPDMap.values())}));
            }
            
            // build a set of the device type Ids
            if(devicesList != null && !devicesList.isEmpty() ) {
                Integer counter = 0 ;
                for (Device__c device : devicesList) {
                    BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                    record.uniqueId = device.Id;
                    record.isSelected = counter == 0 ? true : false ;
                    record.readOnlyFields = new Map<String, Boolean>();
                    record.objectMap = new Map<String, sObject>();
                    record.objectMap.put(GlUt_APIConstantsDevice.DEVICEAPINAME, device);     
                    record.transformFieldMap = new Map<String, Map<String, String>>();
                    Map<String,String> transFormFieldMap2 = new Map<String, String>();
                    if (deviceId2AvailServiceNameMap != null && !deviceId2AvailServiceNameMap.isEmpty() && deviceId2AvailServiceNameMap.get(device.Id) != null) {
                        transFormFieldMap2.put(GlUt_APIConstantsAvailableService.NAMEAPINAME, deviceId2AvailServiceNameMap.get(device.Id));
                        record.transformFieldMap.put(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME, transFormFieldMap2);
                    }
                    records.add(record);
                    counter++ ;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return records;
    }
    
    /**********************************************************************************************
	@author      	Echo: Vivek Sethi
	@date      		25-Oct-2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveReadingsPropDetails(String fieldset) {
        List<GLAp_FieldProps> fieldPropertiesList = new List<GLAp_FieldProps>();
        List<GLAp_FieldProps> fieldPropertiesList1 = new List<GLAp_FieldProps>();
        try {
            fieldPropertiesList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsReading.READINGAPINAME, fieldset);
            // make all fields read only
            for (GLAp_FieldProps fieldProperties : fieldPropertiesList) {	
                if(fieldProperties.fieldName != GlUt_APIConstantsReading.INFORMATIONSTATEMENT)  {	//AT-5361
                    fieldPropertiesList1.add(fieldProperties);
                    fieldProperties.isEditable = false;   
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fieldPropertiesList1;
    }
    
    /**********************************************************************************************
	@author      	Echo: Vivek Sethi
	@date      		25-Oct-2018
	@return         List<BlAp_CombinedRecord>
	@description    This method returns the reading data
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveReadings(String recordId , String fieldset , string infoStatementId) {
        List<BlAp_CombinedRecord> recordsToDisplay = new List<BlAp_CombinedRecord>();
    //    try {
            InformationStatement__c infoStatementObj = [select Id, CreatedDate from InformationStatement__c where Id =:infoStatementId limit 1];
            Date infoStatementCreatedDate =  date.valueOf(infoStatementObj.CreatedDate);
            Date infoStatCreatedDate;
           
            String infoStmtCreatedDateInString = String.valueOf(infoStatementCreatedDate);
            List<String> infoStmtCreatedDateDateInList = infoStmtCreatedDateInString.split(' ');
            DateTime infoStmtCreatedDt = Date.valueOf(infoStmtCreatedDateDateInList[0]);
   
            String orderByClause = ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME +  ' DESC , CreatedDate DESC'; 
            String filter =   GlUt_APIConstantsReading.AMENDEDBYREADINGAPINAME + ' = null and ' +   GlUt_APIConstantsReading.READINGDATEAPINAME + ' >= ' + infoStmtCreatedDt.format('yyyy-MM-dd');
           

            String parentField  = GlUt_APIConstantsDevice.DEVICEAPINAME;
            String objectName  = GlUt_APIConstantsReading.READINGAPINAME;
            
            Boolean isFieldExist = doesFieldExist(objectName,GlUt_Constants.INVALID);
            if(isFieldExist){
                filter = filter + ' AND '+ GlUt_Constants.INVALID +'= false';
            }
            
            fieldset =  GlUt_NamespacePrefix.getNamespacePrefix() + fieldset; 
            List<SObject> records = GlAp_LightningDataAccess.getRecords(objectName, fieldset, recordId, parentField, filter, orderByClause);
         
            // build the display list
            for (SObject record : records) {
                BlAp_CombinedRecord recordToDisplay = new BlAp_CombinedRecord();            
                recordToDisplay.uniqueId = record.Id;
                recordToDisplay.isSelected = (record.get(GlUt_APIConstantsReading.INFORMATIONSTATEMENT) != null && record.get(GlUt_APIConstantsReading.INFORMATIONSTATEMENT) == infoStatementId) ? true: false ;   //AT-5361
                recordToDisplay.readOnlyFields = new Map<String, Boolean>();
                recordToDisplay.objectMap = GlAp_LightningDataAccess.getRecordMapWithFields(objectName, record);
                recordsToDisplay.add(recordToDisplay);           
            }
   /*     } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }*/
        return recordsToDisplay;
    }
    
    /******************************************************************************
	@author    		Echo: Vivek Sethi
	@date      		25-Oct-2018
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
        catch(Exception ex) {
            GlUt_Logger.logException(ex);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return false;
    }
    
    /******************************************************************************
	@author    		Echo: Vivek Sethi
	@date      		25-Oct-2018
	@param			String - the object api name
	@param			String - the field api name
	@return			boolean
	@description 	Check if the field exist on object or not.
	*******************************************************************************/
    @AuraEnabled
    public static boolean saveRecords(Id selectedreadingId, Id infoStatementId, Id selectedDeviceId)
    {
        system.debug('SK-saveRecords-selectedDeviceId=> ' + selectedDeviceId);
        List<Reading__c> readingUpdateList = new List<Reading__c>();
        try {
            for(Reading__c readingObj : (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                               readingFields, 
                                                                                               ' where '  + GlUt_APIConstantsReading.INFORMATIONSTATEMENT + ' = \'' + infoStatementId + '\''))
            {
                system.debug('SK-saveRecords-readingObj.Device__c=> ' + readingObj.Device__c);
                system.debug('SK-saveRecords-selectedDeviceId=> ' + selectedDeviceId);
                if(readingObj.Device__c == selectedDeviceId) {	// AT-5361
                    readingObj.InformationStatement__c = Null;
                	readingUpdateList.add(readingObj);
                }
            }
            system.debug('SK-saveRecords-readingUpdateList=> ' + readingUpdateList);
            List<Reading__c> readingToUpdateList =  (List<Reading__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                                          readingFields, 
                                                                                                          ' where Id  = \''  + selectedreadingId + '\'');
            
            
            if(readingToUpdateList != null && !readingToUpdateList.isEmpty()) {
                readingToUpdateList[0].InformationStatement__c = infoStatementId;
                readingUpdateList.add(readingToUpdateList[0]);
            }
           
            if(!readingUpdateList.isEmpty()) {
                readingUpdateList = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(readingUpdateList, false) ;
                update readingUpdateList;
                return true;
            }
        }
        catch(Exception ex) {
            GlUt_Logger.logException(ex);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return false;
    }
}