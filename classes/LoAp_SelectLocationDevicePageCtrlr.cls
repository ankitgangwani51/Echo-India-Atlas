/******************************************************************************
@author         Echo: Swati Mathur
@date           20-Nov-2017
                06/03/2018 - Echo - Tarun Gupta
                Made changes to change the outfield to GlAp_GenericField to make sure namespace issue is resolved
@description    Component controller for Select Location Device wizard page

Revisions       10 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class LoAp_SelectLocationDevicePageCtrlr {    
        
    private static final String CLASS_NAME = 'LoAp_SelectLocationDevicePageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<string> locFields;    
    static{  
        //get fields from Location__c object
        locFields = new List<string>();
        locFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
        //locFields.add(GlUt_APIConstantsLocation.LOCATIONREFERENCEAPINAME);      AT-3174  
    }
    
    private static List<string> spdFields;    
    static{
        //get fields from SupplyPointDevice__c object
        spdFields = new List<string>();
        spdFields.add(GlUt_APIConstantsSupplyPointDevice.INSTALLATIONDATEAPINAME);  
        spdFields.add(GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME); 
        spdFields.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME);
    }
        
    private static List<string> deviceFields;     
    static{
        //get fields from Device__c object
        deviceFields = new List<string>();
        deviceFields.add(GlUt_APIConstantsDevice.SERIALNOAPINAME);
        deviceFields.add(GlUt_APIConstantsDevice.DEVICETYPEAPINAME);
    }
        
    private static List<string> devTypeFields;    
    static{
        //get fields from DeviceType__c object
        devTypeFields = new List<string>();
       // devTypeFields.add(GlUt_APIConstantsDeviceType.DEVICETYPENAMEFIELDAPINAME); 
        devTypeFields.add(GlUt_APIConstantsDeviceType.MANUFACTUREAPINAME); 
       // devTypeFields.add(GlUt_APIConstantsDeviceType.DEVICESIZENAMEAPINAME);  --AT-3174
    } 
    
    private static List<string> spdsFields;    
    static{
        //get fields from SupplyPointDeviceService__c object
        spdsFields = new List<string>();
        spdsFields.add(GlUt_APIConstantsSPDService.SERVICETYPEAPINAME);  
        spdsFields.add(GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME);        
    }
            
    private static List<string> servTypeFields;    
    static{
        //get fields from ServiceType__c object
        servTypeFields = new List<string>();
        servTypeFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);       
    }
    
    //This is for changing output field to generic field
    private static final List < String > locationListField = new List < string > {
       // GlUt_APIConstantsLocation.LOCATIONREFERENCEAPINAME, AT-3174  
        GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME
    };

    
    /**********************************************************************************************
    @author      : Echo: Tarun Gupta
    @date        : 06-Mar-2018
    @params      : String
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back ocation related fields as List 
                   This change is done to cater name spaces changes
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveLocationFields() {
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            
            List<GLAp_FieldProps> lstLocationFields = new List<GLAp_FieldProps>();
            lstLocationFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationListField);
            
            
            for(GLAp_FieldProps locProp: lstLocationFields){ 
                
                locProp.showLabel = true;
                locProp.isEditable = false;
                
                /*if(locProp.fieldName == GlUt_APIConstantsLocation.LOCATIONREFERENCEAPINAME){
                    locProp.fieldLabel = Label.CuAp_LocationRef;
                }*/ //AT-3174  
                
                if(locProp.fieldName == GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME){
                    locProp.fieldLabel = Label.CuAp_LocationAddress;
                }
            }
            
            for(integer i=0; i < lstLocationFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstLocationFields[i]);
                
                if(secondEntryIndex < lstLocationFields.size()){
                    lstEntry.add(lstLocationFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
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
    @date           20-Nov-2017
    @param          Location Id
    @return         instance of wrapper class; this will contain location information,
                    field properties and devices information
    @description    This method will collect the required details in wrapper and send it to helper 
	*******************************************************************************/ 
    @AuraEnabled
    public static ContainerWrapper getInfoToDisplay (String sLocationId){
        
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper(); 
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );  
            //call to method to get location details
            resultContainer.locObject = getLocationDetails(sLocationId);        
            //call to method to get field properties
            resultContainer.fieldPropList = getLocationDeviceFieldProps();
            //call to method to get device details
            resultContainer.devicesList = getLocationDevices(sLocationId);  
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return resultContainer;
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           20-Nov-2017
    @param          none
    @return         List<GLAp_FieldProps> 
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    public static List<GLAp_FieldProps> getLocationDeviceFieldProps() {    

        //Get the field properties for Device object
        List<GLAp_FieldProps> deviceProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceFields);
        
        //Get the field properties for the SupplyPointDevice object
        List<GLAp_FieldProps> spdProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, spdFields);
        
        //Create Transform Field for Device Type, this is a dummy field property
        GLAp_FieldProps deviceProp = new GLAp_FieldProps();        
        createTransformField(deviceProp,LoAp_Constants.TYPEOFDEVICE,GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME);
        
        //Create Transform Field for Service Types, this is a dummy field property
        GLAp_FieldProps spdServicesProp = new GLAp_FieldProps();
        createTransformField(spdServicesProp,LoAp_Constants.SERVICETYPE,GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME);
               
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        
        for(GLAp_FieldProps fldProp : deviceProps){
            fldProp.isEditable = false;  
            if(fldProp.fieldName == GlUt_APIConstantsDevice.SERIALNOAPINAME){
                 fldPropList.add(fldProp);
            } 
        }  
        
        //Add transform fields to the property list
        fldPropList.add(deviceProp);
        fldPropList.add(spdServicesProp);
        
        for(GLAp_FieldProps fldProp : spdProps){
            fldProp.isEditable = false;
            if(fldProp.fieldName == GlUt_APIConstantsSupplyPointDevice.INSTALLATIONDATEAPINAME){
                 fldPropList.add(fldProp); 
            }           
        }  
       
        return fldPropList;
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           20-Nov-2017
    @param          Location Id
    @return         details of location found
    @description    This method to extracts the details of location found by Location Id 
    *******************************************************************************/ 
    public static Location__c getLocationDetails(String sLocationId) {
       
        Location__c foundLocation = (Location__c)GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsLocation.LOCATIONAPINAME, sLocationId, locFields);       
        return foundLocation;
        
    }
        
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           20-Nov-2017
    @param          Location Id
    @return         List<BlAp_CombinedRecord>; details of active supply point devices found
    @description    This method extracts the active supply point devices on location  
    @revision       MT 07-Mar-2018 Use the field from constant class
    *******************************************************************************/ 
    public static List<BlAp_CombinedRecord> getLocationDevices (String sLocationId) {
              
        // list which will hold the record to be displayed
        List<BlAp_CombinedRecord>  displaySPDeviceServiceList = new List<BlAp_CombinedRecord>(); 
        
        //Get supply points for location        
        List<SupplyPoint__c> spList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                                new List<String>{'Id'},  
                                                                                                Id.valueOf(sLocationId), 
                                                                                                GlUt_APIConstantsLocation.LOCATIONAPINAME);  
        system.debug('1********spList ' + spList);
        if (spList != null && spList.size() > 0) {
            
            List<Id>spIDs = new List<Id>();
            for (SupplyPoint__c objSP : spList) {
                spIDs.add(objSP.Id);
            }         
        
            //Get supply point devices on the basis of supply point Ids
            List<SupplyPointDevice__c> spdList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                                spdFields, 
                                                                                                                String.format('WHERE {0} IN {1} AND {2} = true', 
                                                                                                                    new List<String>{
                                                                                                                        GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                                                        GlUt_FieldSecurity.IdsToString(spIDs), 
                                                                                                                        GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME}));
            
            if (!spdList.isEmpty()) {
                
                List<Id>spdIDs = new List<Id>(); 
                List<Id>deviceIDs = new List<Id>(); 
                
                for (SupplyPointDevice__c objSPD : spdList) {
                    spdIDs.add(objSPD.Id);
                    deviceIDs.add(objSPD.Device__c);
                }
              
                //Get supply point device services on the basis of supply point device Ids
                List<SupplyPointDeviceService__c> spdsList = (List<SupplyPointDeviceService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, 
                                                                                                                                    spdsFields, 
                                                                                                                                    String.format('WHERE {0} IN {1}', 
                                                                                                                                        new List<String>{
                                                                                                                                            GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                                                            GlUt_FieldSecurity.IdsToString(spdIDs)}));
                
                List<Id>servTypeIDs = new List<Id>();        
                for (SupplyPointDeviceService__c objSPDS : spdsList) {           
                    servTypeIDs.add(objSPDS.ServiceType__c);
                }  
                
                //Get Devices
                List<Device__c> deviceList = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                                    deviceFields, 
                                                                                                    'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(deviceIDs));
    
                List<Id>devTypeIDs = new List<Id>();        
                for (Device__c objDevice : deviceList) {
                    devTypeIDs.add(objDevice.DeviceType__c);
                } 
                System.debug('deviceList--'+deviceList);
                
                //Get Device Types
                List<DeviceType__c> devTypeList = (List<DeviceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICETYPEAPINAME, 
                                                                                                            devTypeFields, 
                                                                                                            'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(devTypeIDs));
                
                //Get Service Types
                List<ServiceType__c> servTypeList = (List<ServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, 
                                                                                                                servTypeFields, 
                                                                                                                'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(servTypeIDs));
                
                //Create Map of Service Type Name to Service Type Ids
                Map<Id, String> servTypeMap = new Map<Id, String>();
                for (ServiceType__c st : servTypeList) {
                    servTypeMap.put(st.Id, st.name);
                }
                
                //Create Map of Supply Point Devices to Service Types 
                Map<Id, String> spdToServiceTypesMap = new Map<Id, String>();
                for (SupplyPointDeviceService__c spds : spdsList) {
                    String services = '';
                    if (spdToServiceTypesMap.containsKey(spds.SupplyPointDevice__c)) {
                        services = spdToServiceTypesMap.get(spds.SupplyPointDevice__c);                
                        services = services + ';';
                    }
                    String serviceType = servTypeMap.get(spds.ServiceType__c);
                    services = services + serviceType;
                    spdToServiceTypesMap.put(spds.SupplyPointDevice__c, services);
                }
                
                //Create Map of Devices to Device ids
                Map<Id, Device__c> deviceMap = new Map<Id, Device__c>();
                for (Device__c device: deviceList) {
                    deviceMap.put(device.Id, device);
                }
                
                //Create Map of Device Types to Device Type Ids
                Map<Id, DeviceType__c> devTypeMap = new Map<Id, DeviceType__c>();
                for(DeviceType__c dt : devTypeList){
                    devTypeMap.put(dt.Id, dt);
                }
                //Create Map of Devices to Device Types
                Map<Id, DeviceType__c> deviceToTypesMap = new Map<Id, DeviceType__c>();
                for (Device__c dev : deviceList) {
                    DeviceType__c deviceType = devTypeMap.get(dev.DeviceType__c);
                    deviceToTypesMap.put(dev.Id, deviceType);
                }  
                
                //Create Map of Supply Point Devices to Devices
                Map<Id, Device__c> spdToDeviceMap = new Map<Id, Device__c>();
                List<Id> supplyPointIds = new List<Id>();
                for (SupplyPointDevice__c spd : spdList) {
                    Device__c device = deviceMap.get(spd.Device__c);
                    spdToDeviceMap.put(spd.Id, device);
                    supplyPointIds.add(spd.SupplyPoint__c);
                }
                Map<Id, SupplyPoint__c> mapOfSupplyPointIdToSupplyPoint = new  Map<Id, SupplyPoint__c>();
                List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
                if (supplyPointIds.size() > 0) {
    
                    //Get Supply points
                    List<String> spFields = new List<string>{
                                                            GlUt_APIConstantsSupplyPoint.READFREQUENCYAPINAME
                                                            };
                    supplyPointList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                                spFields, 
                                                                                                'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds));
                }
                for (SupplyPoint__c sp : supplyPointList) {
                    mapOfSupplyPointIdToSupplyPoint.put(sp.Id, sp);
                }
    
                //Loop through the Supply Point Device list and capture the appropriate information
                for (SupplyPointDevice__c sPD : spdList) {
                    
                    BlAp_CombinedRecord sPDSelectRecord = new BlAp_CombinedRecord();           
                    
                    sPDSelectRecord.uniqueId = sPD.Id;
                    sPDSelectRecord.isSelected = false;
                    sPDSelectRecord.objectMap = new Map<string, sObject>();
                    sPDSelectRecord.transformFieldMap = new Map<string,Map<string, string>>();
                    
                    Device__c relatedDevice = new Device__c();
                    relatedDevice = spdToDeviceMap.get(sPD.Id);                    
                    
                    DeviceType__c relatedDeviceType = new DeviceType__c();
                    relatedDeviceType = deviceToTypesMap.get(relatedDevice.Id);
                    String relatedDeviceTypeInfo = relatedDeviceType.Manufacturer__c; //+ ' ' + relatedDeviceType.DeviceSizeName__c; --AT-3174
                    
                    String relatedServices = spdToServiceTypesMap.get(sPD.Id);
                    
                    sPDSelectRecord.objectMap.put(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, sPD); 
                    sPDSelectRecord.objectMap.put(GlUt_APIConstantsDevice.DEVICEAPINAME, relatedDevice); 
                    if (mapOfSupplyPointIdToSupplyPoint.containsKey(sPD.SupplyPoint__c)) {
                        sPDSelectRecord.objectMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, mapOfSupplyPointIdToSupplyPoint.get(sPD.SupplyPoint__c));
                    }
                    Map<string, string> transFormFieldMap = new Map<string, string>();
                    transFormFieldMap.put(LoAp_Constants.SERVICETYPE, relatedServices);
                    transFormFieldMap.put(LoAp_Constants.TYPEOFDEVICE, relatedDeviceTypeInfo);
                    
                    sPDSelectRecord.transformFieldMap.put(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, transFormFieldMap);  
                    
                    displaySPDeviceServiceList.add(sPDSelectRecord);
                    
                }
            } 
        }
       
        return displaySPDeviceServiceList;
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           20-Nov-2017
    @param          Object, String, String
    @return         none
    @description    This method creates the transform field  
    *******************************************************************************/
    public static void createTransformField(GLAp_FieldProps objProp, String objfieldName, String parentObjName) {  
        
        objProp.isFLSVisible = true;
        objProp.isEncrypted = false;
        objProp.isEditable = false;
        objProp.isRequired = false;
        objProp.fieldName = objfieldName;
        objProp.fieldLabel = objfieldName;
        objProp.fieldType = 'text';
        objProp.transformField = true; 
        objProp.parentObject = parentObjName;   
        
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           20-Nov-2017
    @param          none
    @return         none
    @description    Wrapper Class to hold location details, field properties and device details
                    which will be returned to helper
    *******************************************************************************/
    public class ContainerWrapper {
        
        @AuraEnabled public Location__c locObject;
        @AuraEnabled public List<GLAp_FieldProps> fieldPropList; 
        @AuraEnabled public List<BlAp_CombinedRecord> devicesList;
        
    }
    
}