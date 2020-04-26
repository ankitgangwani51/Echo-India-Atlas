/********************************************************************************************
@author    		Echo: Sudhir Kumar
@date      		28-Mar-2018
@description 	For Viewing Devices Details and Submitting a Reading
Revision(s)		03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
@revision		Echo: Sudhir - AT-3956 - Naming Convention for CmAp_MyMeterDetailsCtrlr - Added with sharing (Security Review)
@Revision	 	AT-3969, Tarun - Modified as per security review
*********************************************************************************************/

public with sharing class CmAp_MyMeterDetailsCtlr {
    
    static Map<Id, Set<Id>> deviceTypeId2ReadingIdMap = new Map<Id, Set<Id>>() ;
    static Map<Id, Set<Id>> deviceId2ReadingIdMap = new Map<Id, Set<Id>>() ;
    
    private static final String CLASS_NAME = 'CmAp_MyMeterDetailsCtlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public static set<Id> supplyPointDeviceIdSet {get; set;} 
    
    private static FINAL List<String> readingFieldList = new List<String> {
        GlUt_APIConstantsReading.READINGDATEAPINAME, 
        GlUt_APIConstantsReading.READINGFIELDAPINAME, 
        GlUt_APIConstantsReading.READINGMETHODAPINAME,
        GlUt_APIConstantsReading.READINGTYPEAPINAME,
        GlUt_APIConstantsReading.BILLABLETYPEAPINAME,
        GlUt_APIConstantsReading.BILLEDAPINAME       
    } ;
	
	private static FINAL List<String> deviceFieldList = new List<String> {
        GlUt_APIConstantsDevice.SERIALNOAPINAME, 
		GlUt_APIConstantsDevice.DIGITSAPINAME, 
	    GlUt_APIConstantsDevice.DEVICETYPEAPINAME
    } ;
	
	private static FINAL List<String> deviceTypeFieldList = new List<String> {
        GlUt_APIConstantsDeviceType.NAMEAPINAME    //MT 07-08-2018 AT-3174 changed from device type to name field   
    } ;
    
    private static FINAL List<String> readingReferencedFieldList = new List<String> {
        GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME ,
		GlUt_APIConstantsReading.READINGDEVICEREFAPINAME + '.' + GlUt_APIConstantsDeviceType.DEVICETYPERELAPINAME + '.' + GlUt_APIConstantsDeviceType.NAMEAPINAME  //MT 07-08-2018 AT-3174 changed from device type to name field
    } ;
        
    private static FINAL List<String> newReadingFieldList = new List<String> { 
        GlUt_APIConstantsReading.READINGDATEAPINAME, 
        GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME
    } ;
        
    private static FINAL List<String> deviceFieldsList = new List<string> {
        GlUt_APIConstantsDevice.SERIALNOAPINAME
    } ; 
    
    private static FINAL List<String> deviceTypeFieldsList = new List<string> {
        GlUt_APIConstantsDeviceType.NAMEAPINAME      //MT 07-08-2018 AT-3174 changed from device type to name field
    } ; 
	
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		04-Apr-2018
    @param			String deviceId, String actualDeviceReading, String readingDate
    @return			void
    @description	Insert a Reading record for the Device
    *******************************************************************************/
    @AuraEnabled
    public static void submitMyReading(String deviceId, Decimal actualDeviceReading, String readingDate) {
        
        try {
            Reading__c newReading = new Reading__c(Device__c = deviceId, ReadingDate__c = Date.valueOf(readingDate), 
                                                   ActualDeviceReading__c = String.valueOf(actualDeviceReading)) ;
            Reading__c readingObj = (Reading__c) GlUt_FieldSecurity.cleanseFields(newReading, false);
            Database.insert(new List<Reading__c> {readingObj}) ;
        } catch(Exception oException) {
            GlUt_Logger.logException(oException);
            system.debug('submitMyReading-oException:: ' + oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		04-Apr-2018
    @param			none
    @return			List<GlAp_FieldProps> - readingPropList
    @description	Device Reading field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<GlAp_FieldProps> retrieveReadingPropDetails() {
        List<GlAp_FieldProps> readingPropList = new List<GlAp_FieldProps>() ;
        readingPropList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readingFieldList) ;
        return readingPropList ;
    }
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		07-Apr-2018
    @param			none
    @return			List<GlAp_FieldProps> - new readingProps
    @description	Device Reading field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrieveNewReadingPropDetails() {
        
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
               
        List<GLAp_FieldProps> readingProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, newReadingFieldList);
        for(GLAp_FieldProps read : readingProps) {
            if(read.fieldName == GlUt_APIConstantsReading.READINGDATEAPINAME)
                read.fieldType = 'date' ;
            if(read.fieldName == GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME)
               read.fieldType = 'number' ;
        }
        for(integer i=0; i < readingProps.size(); i = i+2){
            List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
            integer secondEntryIndex = i+1;
            lstEntry.add(readingProps[i]);
            
            if(secondEntryIndex < readingProps.size()){
                lstEntry.add(readingProps[secondEntryIndex]);   
            }
            twoColFormattedList.add(lstEntry);
        }
        return twoColFormattedList;
    }
    
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		06-Apr-2018
    @param			none
    @return			List<GlAp_FieldProps> - devicePropList
    @description	DeviceType field properties details
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrieveDevicePropDetails() {
        
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
               
        List<GlAp_FieldProps> devicePropList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceFieldsList) ;
        devicePropList.addAll(GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, deviceTypeFieldsList)) ;
        for(GlAp_FieldProps fieldProp : devicePropList) {
            fieldProp.isEditable = false ;
        }
        for(integer i=0; i < devicePropList.size(); i = i+2){
            List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
            integer secondEntryIndex = i+1;
            lstEntry.add(devicePropList[i]);
            
            if(secondEntryIndex < devicePropList.size()) {
                lstEntry.add(devicePropList[secondEntryIndex]);   
            }
            twoColFormattedList.add(lstEntry);
        }
        return twoColFormattedList;
    }
	
	/******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		10-Oct-2018
    @param			none
    @return			set<Id> supplyPointSet
    @description	Getter/Stter property for supplyPointSet
					AT-3956 - Naming Convention for CmAp_MyMeterDetailsCtrlr - Added header (Security Review)
    *******************************************************************************/
    
    public static set<Id> supplyPointSet {
        get {
            if(supplyPointSet == null && serviceIdSet != null && !serviceIdSet.isEmpty()) {
                supplyPointSet = new set<Id>() ;
                supplyPointSet = new Map<Id, SupplyPoint__c>([SELECT Id FROM SupplyPoint__c WHERE Id IN: serviceIdSet]).keySet() ;
            }
            system.debug('supplyPointSet:: ' + supplyPointSet);
            return supplyPointSet ;
        }
        set ;
    }
	
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		10-Oct-2018
    @param			none
    @return			set<Id> serviceIdSet
    @description	Getter/Stter property for serviceIdSet
					AT-3956 - Naming Convention for CmAp_MyMeterDetailsCtrlr - Added header (Security Review)
    *******************************************************************************/
    public static set<Id> serviceIdSet {
        get {
            if(serviceIdSet == null && CmAp_MyAccountCtrlr.getCurrentUserAccount() != null) {
            	serviceIdSet = new set<Id>() ;
                String accountId = CmAp_MyAccountCtrlr.getCurrentUserAccount().Id ;  
                for(Service__c service : [SELECT Id, SupplyPoint__c FROM Service__c WHERE BillingContract__c 
                                            IN (SELECT Id FROM BillingContract__c WHERE AccountName__c =:accountId  AND Status__c =: CmAp_Constants.ACTIVEVALUE)]) {
                    if(service.SupplyPoint__c != null) serviceIdSet.add(service.SupplyPoint__c) ;
                }
            }
            system.debug('serviceIdSet:: ' + serviceIdSet);
            return serviceIdSet ;
        }
        set ;
    }
    
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		10-Oct-2018
    @param			none
    @return			Map<Id, DeviceType__c> readingId2DeviceTypeMap
    @description	Getter/Stter property for readingId2DeviceTypeMap // Get Reading DeviceType Map
					AT-3956 - Naming Convention for CmAp_MyMeterDetailsCtrlr - Added header (Security Review)
    *******************************************************************************/
    
    public static Map<Id, DeviceType__c> readingId2DeviceTypeMap {
        get {
            if(readingId2DeviceTypeMap == null && readingMap != null && !readingMap.isEmpty()) {
                readingId2DeviceTypeMap = new Map<Id, DeviceType__c>() ;
                set<Id> deviceTypeIdSet = new set<Id> (deviceTypeId2ReadingIdMap.keySet()) ;
				List<DeviceType__c> deviceTypeList = (List<DeviceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, 
																												deviceTypeFieldList,
																												'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(deviceTypeIdSet));

                if(deviceTypeList != null && !deviceTypeList.isEmpty()) {
					for(DeviceType__c deviceType : deviceTypeList) {
						if(deviceTypeId2ReadingIdMap.containsKey(deviceType.Id)) {
							for(String readingId : deviceTypeId2ReadingIdMap.get(deviceType.Id)) {
								readingId2DeviceTypeMap.put(readingId, deviceType) ;
							}
						}
					}
                }
            }
            system.debug('readingId2DeviceTypeMap:: ' + readingId2DeviceTypeMap) ;
            return readingId2DeviceTypeMap ;
        }
		set ;
    }
    
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		10-Oct-2018
    @param			none
    @return			Map<Id, Device__c> readingId2DeviceMap
    @description	Getter/Stter property for readingId2DeviceMap // Get Reading Device Map
					AT-3956 - Naming Convention for CmAp_MyMeterDetailsCtrlr - Added header (Security Review)
    *******************************************************************************/
    
    public static Map<Id, Device__c> readingId2DeviceMap {
        get {
            if(readingId2DeviceMap == null && readingMap != null && !readingMap.isEmpty()) {
                readingId2DeviceMap = new Map<Id, Device__c>() ;
                set<Id> deviceIdSet = new set<Id> (deviceId2ReadingIdMap.keySet()) ;
				List<Device__c> deviceList = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
																												deviceFieldList,
																												'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(deviceIdSet));

                if(deviceList != null && !deviceList.isEmpty()) {
					for(Device__c device : deviceList) {
						if(deviceId2ReadingIdMap.containsKey(device.Id)) {
							for(String readingId : deviceId2ReadingIdMap.get(device.Id))
								readingId2DeviceMap.put(readingId, device) ;
						}
					}
                }
            }
            system.debug('readingId2DeviceMap:: ' + readingId2DeviceMap) ;
            return readingId2DeviceMap ;
        }
        set ;
    }
    
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		10-Oct-2018
    @param			none
    @return			void
    @description	getSupplyPointDeviceIdSet method return SupplyPointDeviceId Set
					AT-3956 - Naming Convention for CmAp_MyMeterDetailsCtrlr - Added header (Security Review)
    *******************************************************************************/
    public static void getSupplyPointDeviceIdSet() {
            if(supplyPointDeviceIdSet == null && supplyPointSet != null && !supplyPointSet.isEmpty()) {
                supplyPointDeviceIdSet = new set<Id>() ;
            	List<SupplyPointDevice__c> supplyPointDeviceList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
																												new List<String>{GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME},
																												String.format('WHERE {0} IN {1} AND {2} = TRUE', 
																													new List<String>{
																        												GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME, 
																        												GlUt_FieldSecurity.IdsToString(supplyPointSet), 
																        												GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME})
																												);

                if(supplyPointDeviceList != null && !supplyPointDeviceList.isEmpty()) {
                    for(SupplyPointDevice__c spd : supplyPointDeviceList) {
                        supplyPointDeviceIdSet.add(spd.Device__c) ;
                    }
                }

				List<String> fieldsToQuery = new List<String>();
				fieldsToQuery.addAll(readingFieldList);
				fieldsToQuery.addAll(readingReferencedFieldList);
                List<Reading__c> readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
																									fieldsToQuery,
																									String.format('WHERE {0} IN {1} {2}', 
																										new List<String>{
													        												GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME, 
													        												GlUt_FieldSecurity.IdsToString(supplyPointDeviceIdSet), 
													        												'ORDER BY CreatedDate DESC'})
																									);

                if(readingList != null && !readingList.isEmpty()) {
                    for(Reading__c read : readingList) {
                        if(read.Device__r != null) { //AT-3174
                            if(!deviceTypeId2ReadingIdMap.containsKey(read.Device__r.DeviceType__c))//AT-3174
                                deviceTypeId2ReadingIdMap.put(read.Device__r.DeviceType__c, new Set<Id> {read.Id}) ;//AT-3174
                            else
                                deviceTypeId2ReadingIdMap.get(read.Device__r.DeviceType__c).add(read.Id) ;//AT-3174
                        }
                        if(read.Device__c != null) {
                            if(!deviceId2ReadingIdMap.containsKey(read.Device__c))
                                deviceId2ReadingIdMap.put(read.Device__c,  new Set<Id> {read.Id}) ;
                            else
                                deviceId2ReadingIdMap.get(read.Device__c).add(read.Id) ;
                        }
                    }
                }
            }
            system.debug('supplyPointDeviceIdSet:: ' + supplyPointDeviceIdSet) ;
        }
	
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		10-Oct-2018
    @param			none
    @return			Map<Id, Reading__c> readingMap
    @description	Getter/Stter property for readingMap // Get Reading Map
					AT-3956 - Naming Convention for CmAp_MyMeterDetailsCtrlr - Added header (Security Review)
    *******************************************************************************/
    
    public static Map<Id, Reading__c> readingMap {
        get {
            if(readingMap == null && supplyPointSet != null && !supplyPointSet.isEmpty()) {
                readingFieldList.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
                getSupplyPointDeviceIdSet();

                List<Reading__c> readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
																									readingFieldList,
                                                                                                      String.format('WHERE {0} IN {1} ORDER BY {2} ',   //AT-2306
																										new List<String>{
																											GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME, 
													        												GlUt_FieldSecurity.IdsToString(supplyPointDeviceIdSet), 
                                                                                                            GlUt_APIConstantsReading.READINGDATEAPINAME +  ' DESC , CreatedDate DESC'})
																									);		// Sudhir: AT-2306

                readingMap = new map<Id, Reading__c>() ;
                readingMap.putAll(readingList) ;
            }
            return readingMap ;
        }
        set ;
    }
    /******************************************************************************
    @author      	Echo: Sudhir Kumar
    @date      		28-Mar-2018
    @param			none
    @return			List<BlAp_CombinedRecord>
    @description	Device reading details
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getUserMeterDetails() {
        List<BlAp_CombinedRecord> blAp_CombinedRecordList = new List<BlAp_CombinedRecord>() ;
        Map<Id, List<BillItem__c>> readingId2BillItemMap ;
        Map<Id, Id> readingId2DeviceIdMap ;
        
        if(readingMap != null && !readingMap.isEmpty()) {
            blAp_CombinedRecordList = new List<BlAp_CombinedRecord>() ;
            for(Reading__c reading : readingMap.values()) {
                BlAp_CombinedRecord record = new BlAp_CombinedRecord() ;
				record.uniqueId = reading.Id ;
                record.objectMap = new Map<String, Sobject>() ;
                record.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME, reading) ;
                if(readingId2DeviceMap.containsKey(reading.Id)) {
					record.objectMap.put(GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, readingId2DeviceMap.get(reading.Id)) ;
				}
				if(readingId2DeviceTypeMap.containsKey(reading.Id)) {
					record.objectMap.put(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, readingId2DeviceTypeMap.get(reading.Id)) ;
				}
                blAp_CombinedRecordList.add(record) ;
            }
        }
        system.debug('blAp_CombinedRecordList:: ' + blAp_CombinedRecordList) ;
        return blAp_CombinedRecordList ;
    }
}