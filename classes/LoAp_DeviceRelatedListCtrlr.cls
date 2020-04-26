/******************************************************************************
@author         Echo: Patrick Dixon
@date           12 Feb 2018
@description    Component controller for device related list lightning component

@Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class LoAp_DeviceRelatedListCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_DeviceRelatedListCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> deviceFields = new List<String> {
     //   GlUt_APIConstantsDevice.DEVICENAMEAPINAME , 
        GlUt_APIConstantsDevice.SERIALNOAPINAME, 
        //GlUt_APIConstantsDevice.DEVICEREFERNCEAPINAME, --AT-3174
        GlUt_APIConstantsDevice.ACTIVEAPINAME,
        GlUt_APIConstantsDevice.DEVICETYPEAPINAME
    };
                                                                    
    private static final List<String> deviceTypeFields = new List<String> {
        GlUt_APIConstantsDeviceType.NAMEAPINAME
    };
        
    private static final List<String> supplyPointDeviceFields = new List<String> {
        GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME
    };
        
    private static final List<String> supplyPointDeviceServicesFields = new List<String> {
        GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME,
        GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICERELAPINAME + '.' + GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME ,
        GlUt_APIConstantsSPDService.SERVICETYPEAPINAME,
        GlUt_APIConstantsSPDService.SERVICETYPERELAPINAME + '.' +  GlUt_APIConstantsServiceType.NAMEAPINAME
    };
   
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           12 Feb 2018
    @return         List<GLAp_FieldProps> - list of field properties for device table
    @description    get the field properties for the Device__c object
    *******************************************************************************/
    @AuraEnabled
        public static List<GLAp_FieldProps> retrieveFieldPropDetails() {
            List<GLAp_FieldProps> fieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceFields);
            List<GLAp_FieldProps> supplyPtDevicefieldProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, supplyPointDeviceFields);
            List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
            // insert a read only text field for the device type name
            
            for(GLAp_FieldProps fldProp : supplyPtDevicefieldProperties){
                if (fldProp.fieldName ==  GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME) {
                    fldProp.fieldLabel =   GlUt_APIConstantsDevice.DEVICENUMBER ;
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp);
                }
            } 
            
            for(GLAp_FieldProps fldProp : fieldProperties){
                fldProp.isEditable = false;
                fldPropList.add(fldProp);
            } 
            fldPropList.add(1, new GLAp_FieldProps(GlUt_APIConstantsDeviceType.NAMEAPINAME, 
                                                   Label.LoAp_DeviceTypeLabel, false, 
                                                   GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME));
            
            // AT-3028 
            GLAp_FieldProps serviceTypeList = new GLAp_FieldProps();
            serviceTypeList.isFLSVisible = true;
            serviceTypeList.isEncrypted = false;
            serviceTypeList.isEditable = false;
            serviceTypeList.isRequired = false;
            serviceTypeList.fieldName = GlUt_Constants.SERVICETYPELBL;
            serviceTypeList.fieldLabel = GlUt_Constants.SERVICETYPELBL;
            serviceTypeList.fieldType = GlUt_Constants.TEXT;       
            serviceTypeList.transformField = true; //Indicates this is a Transfrom and NOT a DB field
            serviceTypeList.parentObject = GlUt_APIConstantsServiceType.SERVICETYPEAPINAME;
            fldPropList.Add(serviceTypeList);
            
            return fldPropList;
        }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           12 Feb 2018
    @param          Id - the location Id
    @return         List<BlAp_CombinedRecord> - list of combined device records to display
    @description    get the list of device records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveRecords(Id recordId) {
        
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            // build a map of the supply point devices related to the location
            Map<Id, SupplyPointDevice__c> supplyPointDeviceMap = new Map<Id, SupplyPointDevice__c>([select Id, Device__c,RemovalDate__c  
                                                                                                    from SupplyPointDevice__c 
                                                                                                    where SupplyPoint__r.Location__c = :recordId]);
            
            List<Device__c> devices = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                            deviceFields, 
                                                                                            String.format('where Id IN (select {0} from {1} where Id IN {2})', 
                                                                                            new List<String>{
                                                                                            GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                            GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                            GlUt_FieldSecurity.IdsToString(supplyPointDeviceMap.keySet())}));
            
            Map<Id,SupplyPointDevice__c> deviceSPDMap = new Map<Id,SupplyPointDevice__c>();
            for(SupplyPointDevice__c supplyPointDeviceObj : supplyPointDeviceMap.values()) {
                deviceSPDMap.put(supplyPointDeviceObj.Device__c ,supplyPointDeviceObj);
            }
            
            // build a set of the device type Ids
            Map<Id, SupplyPointDevice__c> sPDdeviceTypeMap = new Map<Id, SupplyPointDevice__c>();
              // build a set of the device type Ids
            Set<Id> deviceTypeIds = new Set<Id>();
            for (Device__c device : devices) {
                if(deviceSPDMap.get(device.Id) != null ) {
                     sPDdeviceTypeMap.put(device.Id  ,deviceSPDMap.get(device.Id));
                }
                deviceTypeIds.add(device.DeviceType__c);
            }
            // get the device types
            List<DeviceType__c> deviceTypes = (List<DeviceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, 
                                                                                                        deviceTypeFields, 
                                                                                                        'where Id IN ' + GlUt_FieldSecurity.IdsToString(deviceTypeIds));
            
            // build a map of device types keyed on their Id
            Map<Id, DeviceType__c> deviceTypeMap = new Map<Id, DeviceType__c>();
            for (DeviceType__c deviceType : deviceTypes) {
                deviceTypeMap.put(deviceType.Id, deviceType);
            }
   
            // AT-3028 ...
            // get Service Point Device Services
           /* List<SupplyPointDeviceService__c> spdsList = new List<SupplyPointDeviceService__c>([SELECT SupplyPointDevice__c,SupplyPointDevice__r.Device__c,ServiceType__c, ServiceType__r.Name
                                                                                                FROM SupplyPointDeviceService__c
                                                                                                WHERE SupplyPointDevice__c IN: supplyPointDeviceMap.keySet()]); */ 
            
            String queryclause = ' WHERE ' + GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointDeviceMap.keySet()) ;
           
            List<SupplyPointDeviceService__c> spdsList = (List<SupplyPointDeviceService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, 
                                                                                                                                 supplyPointDeviceServicesFields, 
                                                                                                                                 queryclause);
            
                    
            Map<Id, Set<String>> serviceTypeNameDeviceIdMap = new Map<Id, Set<String>>();
            Map<Id, String> stNameDeviceIdMap = new Map<Id, String>();
            
            for(SupplyPointDeviceService__c spdsObj : spdsList){
                if(!serviceTypeNameDeviceIdMap.containsKey(spdsObj.SupplyPointDevice__r.Device__c))
                    serviceTypeNameDeviceIdMap.put(spdsObj.SupplyPointDevice__r.Device__c, new Set<String>{});                       
                
                if(! serviceTypeNameDeviceIdMap.get(spdsObj.SupplyPointDevice__r.Device__c).contains(spdsObj.ServiceType__r.Name)){
                	serviceTypeNameDeviceIdMap.get(spdsObj.SupplyPointDevice__r.Device__c).add(spdsObj.ServiceType__r.Name);
                    String servicetype = '';
                    if(!stNameDeviceIdMap.containsKey(spdsObj.SupplyPointDevice__r.Device__c))
                    	servicetype = (spdsObj.ServiceType__r.Name).trim();
                    else
                        servicetype = stNameDeviceIdMap.get(spdsObj.SupplyPointDevice__r.Device__c) + ',' + (spdsObj.ServiceType__r.Name).trim();
                    
                    stNameDeviceIdMap.put(spdsObj.SupplyPointDevice__r.Device__c, servicetype);
                }
            }
            
            for (Device__c device : devices) {
                BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                record.uniqueId = device.Id;
                record.isSelected = false;
                record.readOnlyFields = new Map<String, Boolean>();
                record.objectMap = new Map<String, sObject>();
                record.objectMap.put(GlUt_APIConstantsDevice.DEVICEAPINAME, device);  
                record.objectMap.put(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, sPDdeviceTypeMap.get(device.Id));  
                record.objectMap.put(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, deviceTypeMap.get(device.DeviceType__c)); 
                // AT-3028 start
                Map<String,String> transFormFieldMap = new Map<String,String>();
                transFormFieldMap.put('Service Type', stNameDeviceIdMap.get(device.Id) );
                record.transFormFieldMap = new Map<String,Map<String,String>>();
                record.transFormFieldMap.put(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, transFormFieldMap);  
                //AT-3028 end..
                records.add(record);
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return records;
    }
    
}