/******************************************************************************
@author      	Echo: Mohit Tayal
@date      		20-Nov-2017
@description	Component controller for Search Device page

Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class LoAp_SearchDevicePageCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_SearchDevicePageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<string> availableServiceFields;
    private static List<string> supplyPointDeviceFields;
    private static List<String> deviceListFields;
    private static List<String> deviceTypeListFields;
    private static List<String> readingListFields;
    
    static{
        availableServiceFields = new List<string>();
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME);
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME);
        
        supplyPointDeviceFields = new List<string>();
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME); 
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME); 
        
        deviceListFields = new List<String>();
        
        deviceTypeListFields = new list<String>();
        
        readingListFields = new List<String>();
        readingListFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        readingListFields.add(GlUt_APIConstantsReading.READINGTYPEAPINAME);
    }
    
    /******************************************************************************
	@author         Echo: Mohit Tayal
	@date           20-Nov-2017
	@param          String sManufacture - Device Manufacture entered on the screen
	String sSerialNo - Device serial number eneterd on the screen
	String oldDeviceId - The id of the device to be removed
	@return         DeviceDetails - returns the device details with variables used to achieve the validations
	@description    Fetching Device Details after validating the device
	@revision       MT - As per the review comments fetching the device type details via another soql except 
	the relation query so, that cleanse Fields could be apply on the device type fields also. 
	*******************************************************************************/ 
    @AuraEnabled
    public static DeviceDetails queryForDevice(String sManufacture, String sSerialNo, String oldDeviceId, String locationId, String wizardType) {
        //Changes for Bug AT-3025 Starts Here
        DeviceDetails dd = new DeviceDetails();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            List<String> supplyPointFields = new List<string>{
                GlUt_APIConstantsSupplyPoint.READFREQUENCYAPINAME
                    };
                        List<SupplyPoint__c> supplyPointList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                                                          supplyPointFields, 
                                                                                                                          locationId, 
                                                                                                                          GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME);
            dd.numberOfSupplyPointPerLocation = supplyPointList.size();
            if(wizardType == System.Label.LoAp_NewDevice){
                if (supplyPointList.size() == 1) {
                    dd.selectedSupplyPoint = supplyPointList[0];
                    List<Id> supplyPointIds = new List<Id>();
                    //check added by Dependra
                    if(!supplyPointList.isEmpty()){
                        for (SupplyPoint__c theSupplyPoint : supplyPointList) {
                            supplyPointIds.add(theSupplyPoint.Id);
                        }
                    }
                    List<SupplyPointDevice__c> spdList = new List<SupplyPointDevice__c>();
                    
                    // Find services on location Supply point in Add Device scenario in order to create new Supply Point Device services for exchange device scenario existing functionality would work as it is.
                    spdList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                               supplyPointDeviceFields, 
                                                                                               String.format('WHERE {0} IN {1} AND {2} = true', 
                                                                                                             new List<String>{
                                                                                                                 GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME, 
                                                                                                                     GlUt_FieldSecurity.IdsToString(supplyPointIds), 
                                                                                                                     GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME}));
                    
                    if (!spdList.isEmpty()) {
                        dd.activeSupplyPointExist = true;   
                    }
                    List<AvailableService__c> availableServiceList = new List<AvailableService__c>();
                    if (!supplyPointList.isEmpty()) {
                        //VS- 22 Feb 2018 AT-1872 added the 'Active' check in the available service query 
                        availableServiceList = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
                                                                                                               availableServiceFields, 
                                                                                                               String.format('WHERE {0} IN {1} AND {2} = true', 
                                                                                                                             new List<String>{
                                                                                                                                 GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME, 
                                                                                                                                     GlUt_FieldSecurity.IdsToString(supplyPointIds), 
                                                                                                                                     GlUt_APIConstantsAvailableService.ACTIVEAPINAME}));
                    }
                    
                    Set<Id> serviceTypeId = new Set<Id>();
                    System.debug('availableServiceList = ' + availableServiceList);
                    for (AvailableService__c avs: availableServiceList) {
                        serviceTypeId.add(avs.ServiceType__c);
                    }
                    if (!serviceTypeId.isEmpty()) {
                        List<Id> stIdList = new  List<Id>();
                        for (Id stId : serviceTypeId) {
                            stIdList.add(stId);
                        }
                        dd.serviceTypeId = stIdList;
                    }
                }
            }
            /*End change For find the number of supply point per location */
            List<String> deviceFields = new List<string>{
                GlUt_APIConstantsDevice.SERIALNOAPINAME, 
                    //GlUt_APIConstantsDevice.DEVICEREFERNCEAPINAME,  --AT-3174
                    GlUt_APIConstantsDevice.DEVICETYPEAPINAME, 
                    GlUt_APIConstantsDevice.DIGITSAPINAME
                    };
                        List<Device__c> deviceList = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                                           deviceFields, 
                                                                                                           String.format('WHERE {0} = {1} AND {2} = {3}', 
                                                                                                                         new List<String>{
                                                                                                                             GlUt_APIConstantsDevice.DEVICETYPERELAPINAME + '.' + GlUt_APIConstantsDeviceType.MANUFACTUREAPINAME, 
                                                                                                                                 GlUt_FieldSecurity.QuotedString(sManufacture), 
                                                                                                                                 GlUt_APIConstantsDevice.SERIALNOAPINAME, 
                                                                                                                                 GlUt_FieldSecurity.QuotedString(sSerialNo)}));
            if(deviceList != null && deviceList.size() > 0) {
                dd.device = deviceList[0];
                
                List<String> deviceTypeFields = new List<string>{
                    GlUt_APIConstantsDeviceType.NAMEAPINAME //MT 07-08-2018 AT-3174 changed from device type to name field
                        };
                            DeviceType__c deviceType = (DeviceType__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, 
                                                                                                          dd.device.DeviceType__c, 
                                                                                                          deviceTypeFields);
                
                if (deviceType.Id != null) {
                    system.debug('1025*********deviceType ' + deviceType);
                    dd.deviceType = deviceType;
                    List<SupplyPointDevice__c> supplyPointDevice = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                                                    new List<String>{
                                                                                                                                        GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME, 
                                                                                                                                            GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME}, 
                                                                                                                                    dd.device.Id, 
                                                                                                                                    GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, 
                                                                                                                                    GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = true');
                    if(supplyPointDevice != null && supplyPointDevice.size() > 0) {
                        system.debug('1026---------');
                        dd.activeDevice = true;
                    } else {
                        system.debug('1027********');
                        dd.activeDevice = false;
                        List<SupplyPointDevice__c> spdRemovalDate = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                                                     new List<String>{
                                                                                                                                         GlUt_APIConstantsSupplyPointDevice.REMOVALDATEAPINAME}, 
                                                                                                                                     dd.device.Id, 
                                                                                                                                     GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, 
                                                                                                                                     null, 
                                                                                                                                     'ORDER BY ' + GlUt_APIConstantsSupplyPointDevice.REMOVALDATEAPINAME + ' DESC LIMIT 1');
                        system.debug('1028***************spdRemovalDate ' + spdRemovalDate);
                        if (spdRemovalDate != null & spdRemovalDate.size() > 0) {
                             system.debug('1029***************spdRemovalDate[0] ' + spdRemovalDate[0]);
                            dd.removalDate = spdRemovalDate[0];
                        }
                        if(wizardType == System.Label.LoAp_ExchangeDevice && string.isNotBlank(oldDeviceId)){

                            /*List<SupplyPointDevice__c> supplyPointDeviceList = [SELECT Id 
                                                                                FROM SupplyPointDevice__c 
                                                                                WHERE Device__c = :oldDeviceId 
                                                                                AND Active__c = true LIMIT 1];*/
                            String filterStatement = ' WHERE ' + GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME + ' = \'' + String.escapeSingleQuotes(oldDeviceId) + '\' LIMIT 1';
                            List<SupplyPointDevice__c> supplyPointDeviceList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,
                                                                                                                                                new List<String>{GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME},
                                                                                                                                                filterStatement);
                            if (supplyPointDeviceList != null && supplyPointDeviceList.size() > 0) {      
                                List<SupplyPointDeviceService__c> supplyPointService = (List<SupplyPointDeviceService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, 
                                                                                                                                                               new List<String>{
                                                                                                                                                                   GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                                                                                       GlUt_APIConstantsSPDService.SERVICETYPEAPINAME}, 
                                                                                                                                                               supplyPointDeviceList[0].Id, 
                                                                                                                                                               GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME);
                                dd.supplyPointDeviceService.addAll(supplyPointService);   
                            }
                        }
                        List<String> readingFields = new List<String>{
                            GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME, 
                                GlUt_APIConstantsReading.READINGTYPEAPINAME
                                };
                                    List<Reading__c> readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                                                          readingFields, 
                                                                                                                          dd.device.Id, 
                                                                                                                          GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME, 
                                                                                                                          null, 
                                                                                                                          'ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC LIMIT 1');
                        
                        if (readingList != null && readingList.size() > 0) {
                            dd.reading = readingList[0];
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
        return dd;
        //Changes for Bug AT-3025 Ends Here
    }
    
    /**********************************************************************************************
    @author      : Echo: Mohit Tayal
    @date        : 07-Mar-2018
    @params      : 
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back device , device type and reading related fields as List 
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveDeviceFields(String fieldType) {
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            
            if(fieldType == 'output'){
                //deviceListFields.add(GlUt_APIConstantsDevice.DEVICEREFERNCEAPINAME); --AT-3174
                deviceListFields.add(GlUt_APIConstantsDevice.SERIALNOAPINAME);
                deviceListFields.add(GlUt_APIConstantsDevice.DIGITSAPINAME);
                deviceTypeListFields.add(GlUt_APIConstantsDeviceType.NAMEAPINAME); //MT 07-08-2018 AT-3174 changed from device type to name field 
            }else {
                deviceTypeListFields.add(GlUt_APIConstantsDeviceType.MANUFACTUREAPINAME);
                deviceListFields.add(GlUt_APIConstantsDevice.SERIALNOAPINAME);
            }
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> deviceFields = new List<GLAp_FieldProps>();
            deviceFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceListFields);
			
            
            List<GLAp_FieldProps> dvcTypeFields = new List<GLAp_FieldProps>();
            dvcTypeFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, deviceTypeListFields);
           
            
            //This is to make a single list of GLAp_FieldProps
            for(integer z=0; z< deviceFields.size() ; z++){
                dvcTypeFields.add(deviceFields[z]);
            }
            
            
          
            if(fieldType == 'output'){
                List<GLAp_FieldProps> readngFields = new List<GLAp_FieldProps>();
                readngFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readingListFields);
                system.debug('readngFields---'+ readngFields);
                
                for(integer z=0; z< readngFields.size() ; z++){
                    dvcTypeFields.add(readngFields[z]);
                }
                
                
                for(GLAp_FieldProps devProp: dvcTypeFields){
                    devProp.showLabel = true;
                    devProp.isEditable = false;
                    system.debug('devProp---'+ devProp);
                }
            }
           
            for(integer i=0; i < dvcTypeFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(dvcTypeFields[i]);
                
                if(secondEntryIndex < dvcTypeFields.size()){
                    lstEntry.add(dvcTypeFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
                system.debug('twoColFormattedList========'+ twoColFormattedList);
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
    
    /**********************************************************************************************
    @author      : Echo: Mohit Tayal
    @date        : 07-Mar-2018
    @params      : 
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back device , device type and reading related fields as List 
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveInitialFields(String fieldType) {
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> deviceFields = new List<GLAp_FieldProps>();
            deviceFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceListFields);
            
            List<GLAp_FieldProps> dvcTypeFields = new List<GLAp_FieldProps>();
            dvcTypeFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME, deviceTypeListFields);
            
            //This is to make a single list of GLAp_FieldProps
            for(integer z=0; z< dvcTypeFields.size() ; z++){
                deviceFields.add(dvcTypeFields[z]);
            }
            
            List<GLAp_FieldProps> readngFields = new List<GLAp_FieldProps>();
            readngFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readingListFields);
            system.debug('readngFields---'+ readngFields);
            
            for(integer z=0; z< readngFields.size() ; z++){
                deviceFields.add(readngFields[z]);
            }
            
            if(fieldType == 'output'){
                for(GLAp_FieldProps devProp: deviceFields){
                    devProp.showLabel = true;
                    devProp.isEditable = false;
                    system.debug('devProp---'+ devProp);
                }
            }
            
            for(integer i=0; i < deviceFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(deviceFields[i]);
                
                if(secondEntryIndex < deviceFields.size()){
                    lstEntry.add(deviceFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
                system.debug('twoColFormattedList========'+ twoColFormattedList);
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
    @author         Echo: Mohit Tayal
    @date           20-Nov-2017
    @param          none
    @return         none
    @description    wrapper class to hold the Device Details
    @revision       MT - added a reference for device type object
    *******************************************************************************/
    public class DeviceDetails {
        @AuraEnabled public Device__c device;
        @AuraEnabled public DeviceType__c deviceType;
        @AuraEnabled public List<SupplyPointDeviceService__c> supplyPointDeviceService;
        @AuraEnabled public Reading__c reading;
        @AuraEnabled public Boolean activeDevice;
        @AuraEnabled public SupplyPointDevice__c removalDate;
        @AuraEnabled public Integer numberOfSupplyPointPerLocation;
        @AuraEnabled public List<Id> serviceTypeId;
        @AuraEnabled public SupplyPoint__c selectedSupplyPoint;
        @AuraEnabled public Boolean activeSupplyPointExist;
        public DeviceDetails() {
            device = new Device__c();
            deviceType = new DeviceType__c();
            reading = new Reading__c();
            supplyPointDeviceService = new List<SupplyPointDeviceService__c>();
            removalDate = new SupplyPointDevice__c();
            serviceTypeId = new List<Id>();
            selectedSupplyPoint = new SupplyPoint__c();
        }
    }
}