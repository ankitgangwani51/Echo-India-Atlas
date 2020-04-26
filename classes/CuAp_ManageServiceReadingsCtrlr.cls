/******************************************************************************
@author         Echo : Ankit Gangwani
@date           06 August 2018
@description    Component controller for manage service readings
******************************************************************************/
public class CuAp_ManageServiceReadingsCtrlr {
    
    @TestVisible private static List<string> serviceList;
    @TestVisible private static List<string> readingList;
    @TestVisible private static List<string> previousReadingList;
    
    
    private static final String CLASS_NAME = 'CuAp_ManageServiceReadingsCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        serviceList = new List<String>();
        serviceList.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);
        
        previousReadingList = new List<String>();
        previousReadingList.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);
        previousReadingList.add(GlUt_APIConstantsReading.READINGAPINAME);
        
        readingList = new List<String>();
        readingList.add(GlUt_APIConstantsReading.READINGSOURCEAPINAME);
        readingList.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);
        readingList.add(GlUt_APIConstantsReading.TRIPPEDAPINAME);   //AT-3422 core 8b
        readingList.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);        
    }
    
    /**********************************************************************************************
    @author         Echo : Ankit Gangwani
    @date           06 August 2018
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen. This is for the Manage Service Reading Table.
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> fieldProp(){
        
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();        
        List<GLAp_FieldProps> serviceProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsService.SERVICEAPINAME, serviceList);
        List<GLAp_FieldProps> previousReadingProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME , previousReadingList);
        List<GLAp_FieldProps> readingProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME , readingList);
        
        //Add in button fields
        GLAp_FieldProps buttonFieldProp1 = new GLAp_FieldProps();
        buttonFieldProp1.isFLSVisible = true;
        buttonFieldProp1.isEncrypted = false;
        buttonFieldProp1.isEditable = false;
        buttonFieldProp1.isRequired = false;
        buttonFieldProp1.fieldName = CuAp_Constants.ESTIMATE;
        buttonFieldProp1.fieldLabel = CuAp_Constants.ESTIMATE;
        buttonFieldProp1.buttonField = true;
        buttonFieldProp1.transformField = true;
        
        // Device ID Transform field
        GlAp_FieldProps deviceId = new GlAp_FieldProps();
        deviceId.isFLSVisible = false;
        deviceId.isEncrypted = false;
        deviceId.isEditable = false;
        deviceId.isRequired = false;
        deviceId.fieldName = CuAp_Constants.DEVICELABEL;
        deviceId.fieldLabel = CuAp_Constants.DEVICELABEL;
        deviceId.buttonField = false;
        deviceId.fieldType = 'text';
        deviceId.transformField = true;
        deviceId.parentObject = GlUT_ApiConstantsDevice.DEVICEAPINAME;
        
        // Device ID Transform field
        GlAp_FieldProps deviceDigit = new GlAp_FieldProps();
        deviceDigit.isFLSVisible = false;
        deviceDigit.isEncrypted = false;
        deviceDigit.isEditable = false;
        deviceDigit.isRequired = false;
        deviceDigit.fieldName = CuAp_Constants.DEVICEDIGITLABEL;
        deviceDigit.fieldLabel = CuAp_Constants.DEVICEDIGITLABEL;
        deviceDigit.buttonField = false;
        deviceDigit.fieldType = 'text';
        deviceDigit.transformField = true;
        deviceDigit.parentObject = 'Device';
        
        // Display the Supply Point Name
        GlAp_FieldProps supplyPoint = new GlAp_FieldProps();
        supplyPoint.isFLSVisible = true;
        supplyPoint.isEncrypted = false;
        supplyPoint.isEditable = false;
        supplyPoint.isRequired = false;
        supplyPoint.fieldName = CuAp_Constants.SUPPLYPOINT;
        supplyPoint.fieldLabel = CuAp_Constants.SUPPLYPOINTLABEL;
        supplyPoint.buttonField = false;
        supplyPoint.fieldType = 'text';
        supplyPoint.transformField = true;
        supplyPoint.parentObject = GlUt_ApiConstantsSupplyPoint.SUPPLYPOINTAPINAME;
        fldPropList.add(supplyPoint);
        
        // Display the comma seperated Service Types bases on Service
        GlAp_FieldProps serviceType = new GlAp_FieldProps();
        serviceType.isFLSVisible = true;
        serviceType.isEncrypted = false;
        serviceType.isEditable = false;
        serviceType.isRequired = false;
        serviceType.fieldName = CuAp_Constants.SERVICETYPEFIELD;
        serviceType.fieldLabel = CuAp_Constants.SERVICETYPELABEL;
        serviceType.buttonField = false;
        serviceType.fieldType = 'text';
        serviceType.transformField = true;
        serviceType.parentObject = GlUt_ApiConstantsServiceType.SERVICETYPEAPINAME;
        fldPropList.add(serviceType);
        
        for (GLAp_FieldProps fldProp : previousReadingProps) {   
            fldProp.fieldLabel = 'Previous ' + fldProp.fieldLabel;
            fldProp.isEditable = false;
            fldProp.editMode = false;
            fldProp.isFLSVisible = true;
            fldProp.parentObject = 'Reading';
            fldPropList.add(fldProp);                           
        }  
        
        for (GLAp_FieldProps fldProp : readingProps) {   
            if(fldProp.fieldName == GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME){
                fldProp.fieldType = 'number';
            }
            fldProp.isEditable = true;
            fldProp.editMode = true;
            fldProp.isFLSVisible = true;
            fldPropList.add(fldProp);                           
        }  
        fldPropList.add(buttonFieldProp1);
        return fldPropList;
    }
    
    /**********************************************************************************************
    @author         Echo : Ankit Gangwani
    @date           06 August 2018
    @return         List<BlAp_CombinedRecord>
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveSPAndReadingByContract(List<Service__c> serviceTransfers, String effectiveDate){
        List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
        Set<Id> serviceIds = new Set<Id>();
        Set<Id> serviceTypeIds = new Set<Id>();
        String serviceTypes = '';
        Map<Id,String> mapOfServiceTypeId2Name = new Map<Id,String>();
        Map<Id,String> mapOfSupplyPointId2ServiceTypes = new Map<Id,String>();
        
        if(!serviceTransfers.isEmpty()){
            for(Service__c objService : serviceTransfers){  
                serviceTypeIds.add(objService.ServiceType__c);
                serviceIds.add(objService.Id);                
            }            
            
            /*List<ServiceType__c> serviceTypeList = [SELECT Id, Name FROM ServiceType__c WHERE Id =:serviceTypeIds];*/
            
            List<ServiceType__c> serviceTypeList = (List<ServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,
                                                                                                              new List<String>{LoAp_Constants.Id,
                                                                                                                  LoAp_Constants.NameLabel},
                                                                                                              'WHERE ' + LoAp_Constants.Id + 
                                                                                                              ' IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeIds)); 
            
            
            for(ServiceType__c objServiceType : serviceTypeList){
                mapOfServiceTypeId2Name.put(objServiceType.Id, objServiceType.Name);
            }
            
            for(Service__c objService : serviceTransfers){                              
                if(objService.SupplyPoint__c != null){
                    if(mapOfSupplyPointId2ServiceTypes.containsKey(objService.SupplyPoint__c)){
                        
                        if(!mapOfSupplyPointId2ServiceTypes.get(objService.SupplyPoint__c).contains(mapOfServiceTypeId2Name.get(objService.ServiceType__c))){ 
                            serviceTypes = '';
                            serviceTypes =  mapOfSupplyPointId2ServiceTypes.get(objService.SupplyPoint__c) + ',' + 
                                mapOfServiceTypeId2Name.get(objService.ServiceType__c);
                        }
                    }                    
                    else
                        serviceTypes = mapOfServiceTypeId2Name.get(objService.ServiceType__c);                    
                    mapOfSupplyPointId2ServiceTypes.put(objService.SupplyPoint__c, serviceTypes);                    
                }       
            }    
            
            if(serviceIds.size() > 0)
                combinedList = getSupplyPointAndReading(serviceIds,effectiveDate,mapOfSupplyPointId2ServiceTypes);
            
            if(combinedList != null)
                return combinedList;
            else
                return null;
        }
        return null;
    }
    
    /**********************************************************************************************
@author         Echo : Ankit Gangwani
@date           06 August 2018
@return         
**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveSPAndReadingBySP(List<AvailableService__c> availableServiceTransfers, String effectiveDate){
        
        List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
        Set<Id> availableServiceIds = new Set<Id>();
        Set<Id> serviceIds = new Set<Id>();
        Set<Id> serviceTypeIds = new Set<Id>();
        String serviceTypes = '';
        Map<Id,String> mapOfServiceTypeId2Name = new Map<Id,String>();
        Map<Id,String> mapOfSupplyPointId2ServiceTypes = new Map<Id,String>();
        
        if(!availableServiceTransfers.isEmpty()){
            for(AvailableService__c objAS : availableServiceTransfers){
                serviceTypeIds.add(objAS.ServiceType__c);                   
                availableServiceIds.add(objAS.Id);                
            }
            
            /*List<ServiceType__c> serviceTypeList = [SELECT Id, Name FROM ServiceType__c WHERE Id =:serviceTypeIds];*/
            List<ServiceType__c> serviceTypeList = (List<ServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,
                                                                                                              new List<String>{LoAp_Constants.Id,
                                                                                                                  LoAp_Constants.NameLabel},
                                                                                                              'WHERE ' + LoAp_Constants.Id + 
                                                                                                              ' IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeIds)); 
            
            for(ServiceType__c objServiceType : serviceTypeList){
                mapOfServiceTypeId2Name.put(objServiceType.Id, objServiceType.Name);
            }
            
            for(AvailableService__c objAS : availableServiceTransfers){                              
                if(objAS.SupplyPoint__c != null){
                    if(mapOfSupplyPointId2ServiceTypes.containsKey(objAS.SupplyPoint__c)){
                        
                        if(!mapOfSupplyPointId2ServiceTypes.get(objAS.SupplyPoint__c).contains(mapOfServiceTypeId2Name.get(objAS.ServiceType__c))){ 
                            serviceTypes = '';
                            serviceTypes =  mapOfSupplyPointId2ServiceTypes.get(objAS.SupplyPoint__c) + ',' + 
                                mapOfServiceTypeId2Name.get(objAS.ServiceType__c);
                        }
                    }                    
                    else
                        serviceTypes = mapOfServiceTypeId2Name.get(objAS.ServiceType__c);                    
                    mapOfSupplyPointId2ServiceTypes.put(objAS.SupplyPoint__c, serviceTypes);                    
                }       
            } 
            
            /*List<Service__c> serviceList = [SELECT Id, AvailableService__c, ServiceType__c FROM Service__c WHERE AvailableService__c = :availableServiceIds];*/
            
            List<Service__c> serviceList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                  new List<String>{LoAp_Constants.Id,
                                                                                                      GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME,
                                                                                                      GlUt_APIConstantsServiceType.SERVICETYPEAPINAME},
                                                                                                  'WHERE ' + GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME + 
                                                                                                  ' IN ' + GlUt_FieldSecurity.IdsToString(availableServiceIds)); 
            if(!serviceList.isEmpty()){
                for(Service__c objService : serviceList){                                     
                    serviceIds.add(objService.Id);
                }
                
                if(serviceIds.size() > 0)
                    combinedList = getSupplyPointAndReading(serviceIds,effectiveDate, mapOfSupplyPointId2ServiceTypes);
                
                if(combinedList != null)
                    return combinedList;
                else
                    return null;        
            }
            return null;
        }
        return null;        
    }
    
    /**********************************************************************************************
    @author         Echo : Ankit Gangwani
    @date           06 August 2018
    @return         
    **********************************************************************************************/
    public static List<BlAp_CombinedRecord> getSupplyPointAndReading(Set<Id> serviceIds, String effectiveDate, Map<Id,String> mapOfSupplyPointId2ServiceTypes){
        Set<Id> supplyPointIdsSet = new Set<Id>();
        Map<Id,Id> mapOfSupplyPointId2DeviceId = new Map<Id,Id>();
        Map<Id,Reading__c> mapOfDeviceId2LastReading = new Map<Id,Reading__c>();
        Map<Id,String> mapOfSupplyPointId2Name = new Map<Id,String>();        
        List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
        Map<Id,String> mapOfDeviceId2DeviceDigit = new Map<Id,String>();
        
        /*List<Service__c> serviceLists = [SELECT Id, ServiceType__c, SupplyPoint__c, ServiceStartDate__c, ServiceEndDate__c
                                         FROM Service__c WHERE Id = :serviceIds AND 
                                         SupplyPoint__c != null AND
                                         (ServiceEndDate__c = null OR ServiceEndDate__c >= :Date.valueOf(effectiveDate))];*/
        
        List<Service__c> serviceLists = new List<Service__c>();
        
        serviceLists = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                              new List<String>{LoAp_Constants.Id,
                                                                                  GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,
                                                                                  GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                  GlUt_APIConstantsService.SERVICESTARTDATEAPINAME,
                                                                                  GlUt_APIConstantsService.SERVICEENDDATEAPINAME},                                                                                                              
                                                                              ' WHERE ' + LoAp_Constants.Id + ' IN ' +
                                                                              GlUt_FieldSecurity.IdsToString(serviceIds) +
                                                                              ' AND ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + ' != null ' + 
                                                                              ' AND (' + GlUt_APIConstantsService.SERVICEENDDATEAPINAME + ' = null OR ' + 
                                                                              GlUt_APIConstantsService.SERVICEENDDATEAPINAME + ' >= ' + effectiveDate + ')');
        
        if(!serviceLists.isEmpty()){
            for(Service__c objService : serviceLists){            
                if(objService.SupplyPoint__c != null)                
                    supplyPointIdsSet.add(objService.SupplyPoint__c);                
            }      
            
            /*List<SupplyPoint__c> spList = [SELECT Id, Name FROM SupplyPoint__c WHERE Id = :supplyPointIdsSet];*/
            List<SupplyPoint__c> spList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                     new List<String>{LoAp_Constants.Id,
                                                                                                         LoAp_Constants.NameLabel},
                                                                                                     'WHERE ' + LoAp_Constants.Id + 
                                                                                                     ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIdsSet)); 
            
            for(SupplyPoint__c objSP : spList){
                mapOfSupplyPointId2Name.put(objSP.Id, objSP.Name);
            }
            
            /*List<SupplyPointDevice__c> spdList = [SELECT Id, SupplyPoint__c, Device__c FROM SupplyPointDevice__c WHERE SupplyPoint__c = :supplyPointIdsSet AND 
            (RemovalDate__c = null OR RemovalDate__c >= :Date.valueOf(effectiveDate)) AND 
            Active__c = TRUE];*/
                        
            List<SupplyPointDevice__c> spdList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,
                                                                                                                  new List<String>{LoAp_Constants.Id,
                                                                                                                      GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                                      GlUt_APIConstantsDevice.DEVICEAPINAME},                                                                                                              
                                                                                                                  ' WHERE ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + ' IN ' +
                                                                                                                  GlUt_FieldSecurity.IdsToString(supplyPointIdsSet) +
                                                                                                                  ' AND ' + GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = TRUE ' + 
                                                                                                                  ' AND (' + GlUt_APIConstantsSupplyPointDevice.REMOVALDATEAPINAME + ' = null OR ' + 
                                                                                                                  GlUt_APIConstantsSupplyPointDevice.REMOVALDATEAPINAME + ' >= ' + effectiveDate + ')');
            for(SupplyPointDevice__c objSPD : spdList){
                mapOfSupplyPointId2DeviceId.put(objSPD.SupplyPoint__c , objSPD.Device__c);                
            }            
            
            /*List<Device__c> deviceList = [SELECT Id, Digit__c FROM Device__c WHERE Id = :mapOfSupplyPointId2DeviceId.values()];*/
            List<Device__c> deviceList = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME,
                                                                                               new List<String>{LoAp_Constants.Id,
                                                                                                   GlUt_APIConstantsDevice.DIGITSAPINAME},
                                                                                               'WHERE ' + LoAp_Constants.Id + 
                                                                                               ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfSupplyPointId2DeviceId.values())); 
            for(Device__c objDevice : deviceList){
                mapOfDeviceId2DeviceDigit.put(objDevice.Id,String.valueOf(objDevice.Digit__c));
            }
            
            /*List<Reading__c> readingList = [SELECT Id, Device__c, ReadingMethod__c,Reading__c, ReadingDate__c FROM Reading__c WHERE Device__c IN : mapOfSupplyPointId2DeviceId.Values()
			AND ReadingDate__c <= :Date.valueOf(effectiveDate)];*/
            
            List<Reading__c> readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,
                                                                                                  new List<String>{LoAp_Constants.Id,
                                                                                                      GlUt_APIConstantsDevice.DEVICEAPINAME,
                                                                                                      GlUt_APIConstantsReading.READINGMETHODAPINAME,
                                                                                                      GlUt_APIConstantsReading.READINGAPINAME,
                                                                                                      GlUt_APIConstantsReading.READINGDATEAPINAME},                                                                                                              
                                                                                                  ' WHERE ' + GlUt_APIConstantsDevice.DEVICEAPINAME + ' IN ' +
                                                                                                  GlUt_FieldSecurity.IdsToString(mapOfSupplyPointId2DeviceId.Values()) +
                                                                                                  ' AND ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' <= ' + effectiveDate);
            
            for(Reading__c objReading : readingList){
                mapOfDeviceId2LastReading.put(objReading.Device__c, objReading);
            }
            
            
            for(Id spId : supplyPointIdsSet){
                if(mapOfSupplyPointId2DeviceId.containsKey(spId)){
                    //if(mapOfDeviceId2LastReading.containsKey(mapOfSupplyPointId2DeviceId.get(spId))){
                    BlAp_CombinedRecord combRecord = new BlAp_CombinedRecord();   
                    combRecord.uniqueId = spId;
                    combRecord.isSelected = true;
                    combRecord.objectMap = new Map<String, sObject>();
                    combRecord.objectMap.put('Reading',mapOfDeviceId2LastReading.containsKey(mapOfSupplyPointId2DeviceId.get(spId)) ? mapOfDeviceId2LastReading.get(mapOfSupplyPointId2DeviceId.get(spId)) : null);
                    combRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME,new Reading__c());
                    Map<string, string> serviceTypeMap  = new Map<string, string>();
                    serviceTypeMap.put('ServiceType',mapOfSupplyPointId2ServiceTypes.get(spId));
                    Map<string, string> supplyPointMap = new Map<string, string>();
                    supplyPointMap.put('SupplyPoint',mapOfSupplyPointId2Name.get(spId));
                    Map<string, string> deviceIdMap  = new Map<string, string>();
                    deviceIdMap.put('device',mapOfSupplyPointId2DeviceId.get(spId));
                    Map<string, string> deviceDigitMap  = new Map<string, string>();
                    deviceDigitMap.put('deviceDigit',mapOfDeviceId2DeviceDigit.get(mapOfSupplyPointId2DeviceId.get(spId)));
                    combRecord.transformFieldMap = new Map<string,Map<string, string>>();
                    combRecord.transformFieldMap.put(GlUt_ApiConstantsServiceType.SERVICETYPEAPINAME, serviceTypeMap);
                    combRecord.transformFieldMap.put(GlUt_ApiConstantsSupplyPoint.SUPPLYPOINTAPINAME, supplyPointMap);
                    combRecord.transformFieldMap.put(GlUT_ApiConstantsDevice.DEVICEAPINAME, deviceIdMap);
                    combRecord.transformFieldMap.put('Device', deviceDigitMap);
                    combinedList.add(combRecord);
                    //}
                }
            }        
        }
        return combinedList;
    }
    
}