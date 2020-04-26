/******************************************************************************
@author         Echo: Amit K.
@date           04 Feb 2019
@description    Helper class used for Device Upload batch(LoBt_DeviceUpload).
*******************************************************************************/
public with sharing class LoBt_DeviceUploadHelper {
    private static final String CLASS_NAME = 'LoBt_DeviceUploadHelper';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @description    Device Upload Wrapper class containing the final set of data of device import data.
    *******************************************************************************/
    public class DeviceUploadWrapper{
        public Id brqId;
        public Map<Id,BatchError__c> mapOfDeviceUploadId2BatchError = new Map<Id,BatchError__c>();
        public Map<Id,DeviceUploadStaging__c> mapOfDeviceUploadId2DeviceUpload ;
        public Map<Id,SupplyPoint__c> mapOfDeviceUploadId2UpdatedMeasuredSP;
        public Map<Id,DeviceUploadStaging__c> mapOfMeasuredSPId2DeviceUpload;
        public Map<Id,SupplyPointDevice__c> mapOfDeviceUploadId2UpdatedSPD;
        public Map<Id,AverageDailyUsage__c> mapOfDeviceUploadId2UpdatedADU;
        public Map<Id,String> mapOfDeviceUploadId2SerialManufacture;
        public List<AvailableBundle__c> availableBundleList;
        public Map<Id,Device__c> mapOfDeviceUploadId2NewDevice;
        public Map<Id,SupplyPointDevice__c> mapOfDeviceUploadId2NewSupplyPointDevice;
        public Map<Id,List<Reading__c>> mapOfDeviceUpload2Reading;
        public List<SupplyPointDeviceService__c> newSupplyPointDeviceServicesList ;
        public List<ServiceItem__c> endedServiceItemList ;
        public List<AvailableServiceItem__c> endedAvailableServiceItemList ;
        public List<Reading__c> insertedReadingList;
        
        public DeviceUploadWrapper(){
            mapOfDeviceUploadId2BatchError = new Map<Id,BatchError__c>();
            mapOfDeviceUploadId2DeviceUpload = new Map<Id,DeviceUploadStaging__c>();
            mapOfDeviceUploadId2UpdatedMeasuredSP = new Map<Id,SupplyPoint__c>();
            mapOfMeasuredSPId2DeviceUpload = new Map<Id,DeviceUploadStaging__c>();
            mapOfDeviceUploadId2UpdatedSPD =  new Map<Id,SupplyPointDevice__c>();
            mapOfDeviceUploadId2UpdatedADU = new Map<Id,AverageDailyUsage__c>();
            mapOfDeviceUploadId2SerialManufacture = new Map<Id,String>();
            availableBundleList = new List<AvailableBundle__c>();
            mapOfDeviceUploadId2NewDevice = new Map<Id,Device__c>();
            mapOfDeviceUploadId2NewSupplyPointDevice = new Map<Id,SupplyPointDevice__c>();
            mapOfDeviceUpload2Reading = new Map<Id,List<Reading__c>>();
            newSupplyPointDeviceServicesList = new List<SupplyPointDeviceService__c>();
            endedServiceItemList = new List<ServiceItem__c>();
            endedAvailableServiceItemList = new List<AvailableServiceItem__c>();
            insertedReadingList = new List<Reading__c>();
        }
        
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          List<DeviceUploadStaging__c> deviceUploadList,Id brqID
    @description    Method containing set of methods required for Device import validation and uploading.
    *******************************************************************************/
    public static DeviceUploadWrapper deviceUploadHelper(List<DeviceUploadStaging__c> deviceUploadList,Id brqID) {
        //Remove Meter Fields
        List<String> removeMeterFields = new List<String>(); 
        removeMeterFields.add(GlUt_APIConstantsDeviceImport.CURRENTMANUFACTURERAPINAME);
        removeMeterFields.add(GlUt_APIConstantsDeviceImport.CURRENTSERIALNUMBERAPINAME);
        removeMeterFields.add(GlUt_APIConstantsDeviceImport.REMOVALDATEAPINAME);
        //Exchange Meter Fields
        List<String> exchangeMeterFields = new List<String>();
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.CURRENTMANUFACTURERAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.CURRENTSERIALNUMBERAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.NEWDEVICESERIALNUMBERAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.NEWDEVICEMANUFACTURERAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.NEWDEVICESIZEAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.INSTALLATIONDATEAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.DIGITSAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.REMOVALDATEAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.FINALREADINGAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.INITIALREADINGAPINAME);
        exchangeMeterFields.add(GlUt_APIConstantsDeviceImport.INITIALREADINGDATEAPINAME);
        //New Meter Fields
        List<String> newMeterFields = new List<String>();
        newMeterFields.add(GlUt_APIConstantsDeviceImport.NEWDEVICESERIALNUMBERAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.NEWDEVICEMANUFACTURERAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.NEWDEVICESIZEAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.INSTALLATIONDATEAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.LOCATIONNOAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.SUPPLYPOINTAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.DIGITSAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.INITIALREADINGAPINAME);
        newMeterFields.add(GlUt_APIConstantsDeviceImport.INITIALREADINGDATEAPINAME);
        
        Map<String,List<String>> mapOfDeviceUploadType2Fields = new Map<String,List<String>>();
        mapOfDeviceUploadType2Fields.put(LoBt_Constants.REMOVE_METER,removeMeterFields);
        mapOfDeviceUploadType2Fields.put(LoBt_Constants.EXCHANGE_METER,exchangeMeterFields);
        mapOfDeviceUploadType2Fields.put(LoBt_Constants.NEW_METER,newMeterFields);
        
        DeviceUploadWrapper deviceUploadWrapper = new deviceUploadWrapper();
        //Validate Device Upload Fields
        deviceUploadWrapper = validateDeviceUpload(deviceUploadList,mapOfDeviceUploadType2Fields,brqID);
        //Get Supply Point and device upload combination + Manufacture and Serial Number combination with device Upload
        getSupplyPointDevices(deviceUploadWrapper);
		
        //Update and Validate Supply Point for New Device
        createAndvalidateDeviceSP(deviceUploadWrapper);
        //Validate Supply Point Devices and Device for Exchange and Remove Meter
        validateSupplyPointDevices(deviceUploadWrapper);
        //Validate Availabe Bundle
        validateBundle(deviceUploadWrapper);
		
        //try{
            //Create Available Bundle
            if(deviceUploadWrapper.availableBundleList != null &&  !deviceUploadWrapper.availableBundleList.isEmpty()){
                deviceUploadWrapper.availableBundleList = (List<AvailableBundle__c>) GlUt_FieldSecurity.cleanseFields(deviceUploadWrapper.availableBundleList, false);
                Database.insert(deviceUploadWrapper.availableBundleList,false);
                //Create Available Service Items Should Create Automatically.
            }
            //End Service Items
            endAvailableServiceItemsAndServiceItems(deviceUploadWrapper);
            //Update existing Supply Point Device
            if(!deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.isEmpty()){
                List<SupplyPointDevice__c> spdList = deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.values();
                    spdList = (List<SupplyPointDevice__c>) GlUt_FieldSecurity.cleanseFields(spdList, false);
                Database.update(spdList,false);
            }
            //Update existing Supply Point
            if(!deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.isEmpty()){
                List<SupplyPoint__c> spList = deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.values();
                spList = (List<SupplyPoint__c>) GlUt_FieldSecurity.cleanseFields(spList, false);
                Database.update(spList,false);
            }
            //Update ADU
            if(!deviceUploadWrapper.mapOfDeviceUploadId2UpdatedADU.isEmpty()){
                List<AverageDailyUsage__c> aduList = deviceUploadWrapper.mapOfDeviceUploadId2UpdatedADU.values();
                aduList = (List<AverageDailyUsage__c>) GlUt_FieldSecurity.cleanseFields(aduList, false);
                Database.update(aduList,false);
            }
            //Create New Device
            createNewDevice(deviceUploadWrapper);
            if(!deviceUploadWrapper.mapOfDeviceUploadId2NewDevice.isEmpty()){
                GlUt_FieldSecurity.createMapAfterCleanse(deviceUploadWrapper.mapOfDeviceUploadId2NewDevice);
            }
            //Create New SPD and Initial Reading
            createNewSupplyPointDevice(deviceUploadWrapper);
            if(!deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice.isEmpty()){
                GlUt_FieldSecurity.createMapAfterCleanse(deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice);
            }
            //Create SPDS(Supply Point Device Services)
            createSupplyPointDeviceServices(deviceUploadWrapper);
            if(!deviceUploadWrapper.newSupplyPointDeviceServicesList.isEmpty()){
                deviceUploadWrapper.newSupplyPointDeviceServicesList = (List<SupplyPointDeviceService__c>) GlUt_FieldSecurity.cleanseFields(deviceUploadWrapper.newSupplyPointDeviceServicesList, false);
                Database.insert(deviceUploadWrapper.newSupplyPointDeviceServicesList,false);
            }
            //End Available Service Items
            if(deviceUploadWrapper.endedAvailableServiceItemList != null && !deviceUploadWrapper.endedAvailableServiceItemList.isEmpty()){
                deviceUploadWrapper.endedAvailableServiceItemList = (List<AvailableServiceItem__c>) GlUt_FieldSecurity.cleanseFields(deviceUploadWrapper.endedAvailableServiceItemList, false);
                Database.update(deviceUploadWrapper.endedAvailableServiceItemList,false);
            }
            //End Service Items
            if(deviceUploadWrapper.endedServiceItemList != null && !deviceUploadWrapper.endedServiceItemList.isEmpty()){
                deviceUploadWrapper.endedServiceItemList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(deviceUploadWrapper.endedServiceItemList, false);
                Database.update(deviceUploadWrapper.endedServiceItemList,false);
            }
            //Create Final and Initial Reading
            if(!deviceUploadWrapper.mapOfDeviceUpload2Reading.isEmpty()){
                for(List<Reading__c> readingList : deviceUploadWrapper.mapOfDeviceUpload2Reading.values()){
                    deviceUploadWrapper.insertedReadingList.addAll(readingList);
                }
                deviceUploadWrapper.insertedReadingList = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(deviceUploadWrapper.insertedReadingList, false);
                Database.insert(deviceUploadWrapper.insertedReadingList,false);
            }
            //Create Batch Error
            if(!deviceUploadWrapper.mapOfDeviceUploadId2BatchError.isEmpty()){
                GlUt_FieldSecurity.createMapAfterCleanse(deviceUploadWrapper.mapOfDeviceUploadId2BatchError);
            }
            List<DeviceUploadStaging__c> errorDeviceImportList = new List<DeviceUploadStaging__c>();
            for(DeviceUploadStaging__c deviceUpload : deviceUploadList){
                if(deviceUploadWrapper.mapOfDeviceUploadId2BatchError.containsKey(deviceUpload.Id)){
                    BatchError__c batchError = deviceUploadWrapper.mapOfDeviceUploadId2BatchError.get(deviceUpload.Id);
                    deviceUpload.BatchError__c =  batchError.Id;
                    deviceUpload.BatchRequestQueue__c = brqId;
                    errorDeviceImportList.add(deviceUpload);
                }
            }
            //Update Device Upload Record.
            if(!errorDeviceImportList.isEmpty()){
                errorDeviceImportList = (List<DeviceUploadStaging__c>) GlUt_FieldSecurity.cleanseFields(errorDeviceImportList, false);
                Database.update(errorDeviceImportList,false);
            }
            //Update Device Upload as processed.
            if(!deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.isEmpty()){
                for(DeviceUploadStaging__c deviceUpload: deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.values()){
                    deviceUpload.Processed__c = True;
                    deviceUpload.BatchRequestQueue__c = brqId;
                }
                List<DeviceUploadStaging__c> processedDeviceUploadList = deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.values();
                processedDeviceUploadList = (List<DeviceUploadStaging__c>) GlUt_FieldSecurity.cleanseFields(processedDeviceUploadList, false);
                Database.update(processedDeviceUploadList,false);
            }
        /*}Catch(Exception e){
            GlUt_Logger.logException(e);
            System.debug(DEBUG+' Exception==>'+e.getMessage());
        }finally {   
            GlUt_Logger.writeLogsToDatabase();
        }*/
        return deviceUploadWrapper;
    }
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to validate supply point and update the supply point for 
                    new meter scenarios.
    *******************************************************************************/
    public static void createAndvalidateDeviceSP(DeviceUploadWrapper deviceUploadWrapper){
        if(!deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.isEmpty()){
            BatchError__c batchError;
            Map<Id,SupplyPoint__c> mapOfSupplyPointId2SupplyPoint = new Map<Id,SupplyPoint__c>([Select Id,Measured__c,SupplyPointUsageType__c from SupplyPoint__c Where Id In: deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.keySet()]);
            for(DeviceUploadStaging__c deviceUpload : deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.values()){
                if(deviceUpload.Catagory__c == LoBt_Constants.NEW_METER){
                    SupplyPoint__c existingSupplyPoint = mapOfSupplyPointId2SupplyPoint.get(deviceUpload.SupplyPoint__c);
                    if(!existingSupplyPoint.Measured__c){
                        batchError = new BatchError__c(BatchRequestQueue__c = deviceUploadWrapper.brqID,ErrorDetails__c = LoBt_Constants.UNMEASURED_SUPPLY_POINT,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUpload.Id);
                        deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.remove(deviceUpload.Id);
                        deviceUploadWrapper.mapOfDeviceUploadId2BatchError.put(deviceUpload.Id,batchError);
                    }else{
                        existingSupplyPoint.DeviceLocation__c = deviceUpload.DeviceLocation__c;
                        existingSupplyPoint.Geolocation__Latitude__s = deviceUpload.Geolocation__Latitude__s;
                        existingSupplyPoint.Geolocation__Longitude__s = deviceUpload.Geolocation__Longitude__s;
                        existingSupplyPoint.SpecialInstructions__c = deviceUpload.SpecialInstructions__c;
                        existingSupplyPoint.Depot__c = deviceUpload.Depot__c;
                        existingSupplyPoint.Book__c = deviceUpload.Book__c;
                        existingSupplyPoint.WalkOrder__c = deviceUpload.WalkOrder__c; 
                        existingSupplyPoint.Location__c = deviceUpload.LocationNo__c;
                        deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.put(deviceUpload.Id,existingSupplyPoint);
                    }
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to end Available service items and service items for 
                    Remove Meter scenario
    *******************************************************************************/
    public static void endAvailableServiceItemsAndServiceItems(DeviceUploadWrapper deviceUploadWrapper){
        List<AvailableServiceItem__c> availableServiceItemList = [Select Id,EndDate__c,AvailableBundle__r.AvailableService__r.SupplyPoint__c, (Select Id, EndDate__c from ServiceItems__r)  from AvailableServiceItem__c where AvailableBundle__r.AvailableService__r.SupplyPoint__c In:deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.keySet()];
        if(availableServiceItemList != null && !availableServiceItemList.isEmpty()){
            for(AvailableServiceItem__c avServiceItem: availableServiceItemList){
                if(deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload != null && !deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.isEmpty() && deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.containsKey(avServiceItem.AvailableBundle__r.AvailableService__r.SupplyPoint__c)){
                    DeviceUploadStaging__c deviceUpload = deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.get(avServiceItem.AvailableBundle__r.AvailableService__r.SupplyPoint__c);
                    if(deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.containsKey(deviceUpload.Id) && deviceUpload.Catagory__c == LoBt_Constants.REMOVE_METER){
                        AvailableServiceItem__c endAvailableServiceItem = new AvailableServiceItem__c();
                        endAvailableServiceItem.EndDate__c = deviceUpload.RemovalDate__c;
                        endAvailableServiceItem.Id = avServiceItem.Id;
                        deviceUploadWrapper.endedAvailableServiceItemList.add(endAvailableServiceItem);
                        for(ServiceItem__c serItem : avServiceItem.ServiceItems__r){
                            serItem.EndDate__c = deviceUpload.RemovalDate__c;
                            deviceUploadWrapper.endedServiceItemList.add(serItem);
                        }
                    }
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to fetch Device upload and Current Manufacture+Serial No.
                    combination for Exchange,Remove Meter scenario and get the combination 
                    of Supply point and Device Upload.
    *******************************************************************************/
    public static void getSupplyPointDevices(DeviceUploadWrapper deviceUploadWrapper){
        Map<Id,String> mapOfDeviceUploadId2SerialManufacture = new Map<Id,String>();
        if(!deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.isEmpty()){
            for(DeviceUploadStaging__c deviceUpload: deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.values()){
                if(deviceUpload.Catagory__c != LoBt_Constants.NEW_METER)
                    deviceUploadWrapper.mapOfDeviceUploadId2SerialManufacture.put(deviceUpload.Id,deviceUpload.CurrentManufacturer__c+deviceUpload.CurrentSerialNumber__c);
                else
                    deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.put(deviceUpload.SupplyPoint__c,deviceUpload);
            }
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to validate Supply point and devices for Exchange 
                    and Remove Meter scenario
    *******************************************************************************/
    public static void validateSupplyPointDevices(DeviceUploadWrapper deviceUploadWrapper){
        BatchError__c batchError;
        List<Device__c> deviceList = new List<Device__c>();
        if(!deviceUploadWrapper.mapOfDeviceUploadId2SerialManufacture.isEmpty())
            deviceList = [Select Id,SerialNumberandManufacturer__c, (Select Id,RemovalDate__c,SupplyPoint__c FROM SupplyPointDevices__r WHERE Active__c =: TRUE LIMIT 1) from Device__c where SerialNumberandManufacturer__c In: deviceUploadWrapper.mapOfDeviceUploadId2SerialManufacture.values()];
        Map<String,Device__c> mapOfSerialNumberManufacturer2Device = new Map<String,Device__c>();
        Set<Id> spdIdSet = new Set<Id>();
        for(Device__c device: deviceList){
            mapOfSerialNumberManufacturer2Device.put(device.SerialNumberandManufacturer__c,device);
            for(SupplyPointDevice__c spd: device.SupplyPointDevices__r){
                spdIdSet.add(spd.Id);
            }
        }
        Map<Id,AverageDailyUsage__c> mapOfSPDId2AverageDailyUsageLatest = new Map<Id,AverageDailyUsage__c>();
        if(!spdIdSet.isEmpty()){
            List<AverageDailyUsage__c> averageDailyUsageList = [Select Id,SupplyPointDevice__c,EndDate__c from AverageDailyUsage__c where SupplyPointDevice__c In: spdIdSet order by CreatedDate desc];
            for(AverageDailyUsage__c adu: averageDailyUsageList){
                if(!mapOfSPDId2AverageDailyUsageLatest.containsKey(adu.SupplyPointDevice__c))
                    mapOfSPDId2AverageDailyUsageLatest.put(adu.SupplyPointDevice__c,adu);
            }
        }
        for(Id deviceUploadId : deviceUploadWrapper.mapOfDeviceUploadId2SerialManufacture.keySet()){
            DeviceUploadStaging__c deviceUpload = deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.get(deviceUploadId);
            Device__c deviceExist = mapOfSerialNumberManufacturer2Device.get(deviceUploadWrapper.mapOfDeviceUploadId2SerialManufacture.get(deviceUploadId));
            if(deviceExist == null){
                batchError = new BatchError__c(BatchRequestQueue__c = deviceUploadWrapper.brqID,ErrorDetails__c = LoBt_Constants.MISSING_DEVICE,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUploadId);
                deviceUploadWrapper.mapOfDeviceUploadId2BatchError.put(deviceUploadId,batchError);
                deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.remove(deviceUploadId);
            }else if(deviceExist.SupplyPointDevices__r.size() == 0){
                batchError = new BatchError__c(BatchRequestQueue__c = deviceUploadWrapper.brqID,ErrorDetails__c = LoBt_Constants.NO_ACTIVE_SUPPLYPOINT,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE ,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUploadId);
                deviceUploadWrapper.mapOfDeviceUploadId2BatchError.put(deviceUploadId,batchError);
                deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.remove(deviceUploadId);
            }else if(deviceExist.SupplyPointDevices__r[0] != null && deviceExist.SupplyPointDevices__r[0].RemovalDate__c == null){
                SupplyPointDevice__c spd = new SupplyPointDevice__c(Id = deviceExist.SupplyPointDevices__r[0].Id,
                                                                    SupplyPoint__c = deviceExist.SupplyPointDevices__r[0].SupplyPoint__c,
                                                                    RemovalDate__c = deviceUpload.RemovalDate__c,
                                                                    Ended__c = true);
                List<Reading__c> readingList = new List<Reading__c>();
                readingList.add(createFinalReading(deviceExist.Id,deviceUpload));
                deviceUploadWrapper.mapOfDeviceUpload2Reading.put(deviceUpload.Id,readingList);
                if(deviceUpload.Catagory__c == LoBt_Constants.REMOVE_METER){
                    SupplyPoint__c sp = new SupplyPoint__c(Id  = deviceExist.SupplyPointDevices__r[0].SupplyPoint__c,
                                                           Measured__c = false);
                    deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.put(deviceUpload.Id,sp);
                    if(!mapOfSPDId2AverageDailyUsageLatest.isEmpty() && mapOfSPDId2AverageDailyUsageLatest.containsKey(spd.Id)){
                        AverageDailyUsage__c updatedADU = mapOfSPDId2AverageDailyUsageLatest.get(spd.Id);
                        updatedADU.EndDate__c = deviceUpload.RemovalDate__c;
                        deviceUploadWrapper.mapOfDeviceUploadId2UpdatedADU.put(deviceUpload.Id,updatedADU);
                    }
                    deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.put(sp.Id,deviceUpload);
                }
                if(deviceUpload.Catagory__c == LoBt_Constants.EXCHANGE_METER){
                    deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.put(spd.SupplyPoint__c,deviceUpload);
                }
                deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.put(deviceUpload.Id,spd);
            }else if(deviceExist.SupplyPointDevices__r[0] != null && deviceExist.SupplyPointDevices__r[0].RemovalDate__c != null){
                batchError = new BatchError__c(BatchRequestQueue__c = deviceUploadWrapper.brqID,ErrorDetails__c = LoBt_Constants.DEVICE_ALREADY_REMOVED_EXCHANGED,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUploadId);
                deviceUploadWrapper.mapOfDeviceUploadId2BatchError.put(deviceUpload.Id,batchError);
                deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.remove(deviceUploadId);
            }
        }
    } 
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to validate Bundle for New and Remove Meter scenario
    *******************************************************************************/
    public static void validateBundle(DeviceUploadWrapper deviceUploadWrapper){
        if(deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload != null && !deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.isEmpty()){
            List<AvailableService__c> avServiceList = [Select id,SupplyPoint__c,ServiceType__c from AvailableService__c where SupplyPoint__c In: deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.keySet()];
            if(avServiceList != null && !avServiceList.isEmpty()){
                Set<Id> serviceTypeIdSet = new Set<Id>();
                for(AvailableService__c avService : avServiceList){
                    serviceTypeIdSet.add(avService.ServiceType__c);
                }
                Map<String,Bundle__c> mapOfBundleName2Bundle = new Map<String,Bundle__c>();
                if(!serviceTypeIdSet.isEmpty()){
                    List<Bundle__c> bundleList = [Select Id,Name,ServiceType__c,(Select Id, ServiceItemType__c from BundleItems__r) from Bundle__c where ServiceType__c In: serviceTypeIdSet];
                    for(Bundle__c bundle: bundleList){
                        mapOfBundleName2Bundle.put(bundle.Name,bundle);
                    }
                    for(AvailableService__c avService : avServiceList){
                        String errorDetail;
                        BatchError__c batchError;
                        DeviceUploadStaging__c deviceUpload = deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.get(avService.SupplyPoint__c);
                        if(deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.containsKey(deviceUpload.Id)){
                            AvailableBundle__c newAvailableBundle1;
                            AvailableBundle__c newAvailableBundle2;
                            if(avService.ServiceType__c ==  deviceUpload.Service1__c){
                                if(mapOfBundleName2Bundle != null && mapOfBundleName2Bundle.containsKey(deviceUpload.Service1AvailableBundle__c) && avService.ServiceType__c == mapOfBundleName2Bundle.get(deviceUpload.Service1AvailableBundle__c).ServiceType__c){
                                    Id bundleId = mapOfBundleName2Bundle.get(deviceUpload.Service1AvailableBundle__c).Id;
                                    newAvailableBundle1 = new AvailableBundle__c();
                                    newAvailableBundle1.Bundle__c = bundleId;
                                    newAvailableBundle1.AvailableService__c = avService.Id;
                                    newAvailableBundle1.LastBundleChangeDate__c = deviceUpload.InstallationDate__c;
                                }else{
                                    errorDetail = LoBt_Constants.INVALID_BUNDLE;
                                }
                                if(string.isNotBlank(errorDetail)){
                                    batchError = new BatchError__c(BatchRequestQueue__c = deviceUploadWrapper.brqID,ErrorDetails__c = errorDetail,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUpload.Id);
                                    if(batchError != null){
                                        deviceUploadWrapper.mapOfDeviceUploadId2BatchError.put(deviceUpload.Id,batchError);
                                        deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUpload2Reading.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUpload2Reading.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUploadId2UpdatedADU.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUploadId2UpdatedADU.remove(deviceUpload.Id);
                                        continue;
                                    }
                                }
                            }
                            if(avService.ServiceType__c ==  deviceUpload.Service2__c){
                                if(mapOfBundleName2Bundle != null && mapOfBundleName2Bundle.containsKey(deviceUpload.Service2AvailableBundle__c) && avService.ServiceType__c == mapOfBundleName2Bundle.get(deviceUpload.Service2AvailableBundle__c).ServiceType__c){
                                    Id bundleId = mapOfBundleName2Bundle.get(deviceUpload.Service2AvailableBundle__c).Id;
                                    newAvailableBundle2 = new AvailableBundle__c();
                                    newAvailableBundle2.Bundle__c = bundleId;
                                    newAvailableBundle2.AvailableService__c = avService.Id;
                                    newAvailableBundle2.LastBundleChangeDate__c = deviceUpload.InstallationDate__c;
                                }else{
                                    errorDetail = LoBt_Constants.INVALID_BUNDLE;
                                }
                                if(string.isNotBlank(errorDetail)){
                                    batchError = new BatchError__c(BatchRequestQueue__c = deviceUploadWrapper.brqID,ErrorDetails__c = errorDetail,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUpload.Id);
                                    if(batchError != null){
                                        deviceUploadWrapper.mapOfDeviceUploadId2BatchError.put(deviceUpload.Id,batchError);
                                        deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUpload2Reading.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUpload2Reading.remove(deviceUpload.Id);
                                        if(deviceUploadWrapper.mapOfDeviceUploadId2UpdatedADU.containsKey(deviceUpload.Id))
                                            deviceUploadWrapper.mapOfDeviceUploadId2UpdatedADU.remove(deviceUpload.Id);
                                        continue;
                                    }
                                }
                            }
                            if(batchError == null){
                                if(newAvailableBundle1 != null)
                                    deviceUploadWrapper.availableBundleList.add(newAvailableBundle1);
                                if(newAvailableBundle2 != null)
                                    deviceUploadWrapper.availableBundleList.add(newAvailableBundle2);
                            }
                        }
                    }
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          Id deviceId, DeviceUploadStaging__c deviceUpload
    @description    Method used to Create Final Reading
    *******************************************************************************/
    public static Reading__c createFinalReading(Id deviceId, DeviceUploadStaging__c deviceUpload){
        Reading__c newReading = new Reading__c();
        newReading.Device__c = deviceId;
        newReading.ReadingDate__c = deviceUpload.RemovalDate__c;
        newReading.ActualDeviceReading__c = deviceUpload.FinalReading__c;
        newReading.ReadingMethod__c = LoBt_Constants.READINGMETHOD;
        newReading.ReadingSource__c = LoBt_Constants.COMPANYREADING;
        newReading.ReadingType__c = LoBt_Constants.EXCHANGE_FINAL;
        return newReading;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          Id deviceId, DeviceUploadStaging__c deviceUpload
    @description    Method used to Create Final Reading
    *******************************************************************************/
    public static Reading__c createInitialReading(Id deviceId, DeviceUploadStaging__c deviceUpload){
        Reading__c newReading = new Reading__c();
        newReading.Device__c = deviceId;
        newReading.ReadingDate__c = deviceUpload.InitialReadingDate__c;
        newReading.ActualDeviceReading__c = deviceUpload.InitialReading__c;
        newReading.ReadingMethod__c = LoBt_Constants.READINGMETHOD;
        newReading.ReadingSource__c = LoBt_Constants.COMPANYREADING;
        newReading.ReadingType__c = LoBt_Constants.EXCHANGE_INITIAL;
        return newReading;
    }
       //Map of Fields and Error Messages
        private static final Map<String, String> fieldErrorMap = new Map<String, String> {
         GlUt_APIConstantsDeviceImport.CURRENTMANUFACTURERAPINAME => LoBt_Constants.MISSING_CURRENT_MANUFACTURER, 
         GlUt_APIConstantsDeviceImport.CURRENTSERIALNUMBERAPINAME => LoBt_Constants.MISSING_CURRENT_SERIAL_NUMBER, 
         GlUt_APIConstantsDeviceImport.NEWDEVICESERIALNUMBERAPINAME => LoBt_Constants.MISSING_DEVICE_SERIAL_NUMBER,
         GlUt_APIConstantsDeviceImport.NEWDEVICEMANUFACTURERAPINAME => LoBt_Constants.MISSING_DEVICE_MANUFACTURER,
         GlUt_APIConstantsDeviceImport.NEWDEVICESIZEAPINAME => LoBt_Constants.MISSING_DEVICE_SIZE,
         GlUt_APIConstantsDeviceImport.INSTALLATIONDATEAPINAME => LoBt_Constants.MISSING_INSTALLATION_DATE,
         GlUt_APIConstantsDeviceImport.DIGITSAPINAME => LoBt_Constants.MISSING_DEVICE_DIGITS,
         GlUt_APIConstantsDeviceImport.SUPPLYPOINTAPINAME => LoBt_Constants.MISSING_SUPPLY_POINT,
         GlUt_APIConstantsDeviceImport.REMOVALDATEAPINAME => LoBt_Constants.MISSING_REMOVAL_DATE,
         GlUt_APIConstantsDeviceImport.FINALREADINGAPINAME => LoBt_Constants.MISSING_FINAL_READING,
         GlUt_APIConstantsDeviceImport.INITIALREADINGAPINAME => LoBt_Constants.MISSING_INITIAL_READING,
         GlUt_APIConstantsDeviceImport.INITIALREADINGDATEAPINAME => LoBt_Constants.MISSING_INITIAL_READING_DATE,
         GlUt_APIConstantsDeviceImport.LOCATIONNOAPINAME => LoBt_Constants.MISSING_LOCATION
            };
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          List<DeviceUploadStaging__c> deviceUploadList, Map<String,List<String>> mapOfDeviceUploadType2Fields,Id brqID
    @description    Method used to validate device upload records for New/Remove/Exchange Scenarios
    *******************************************************************************/
    public static DeviceUploadWrapper validateDeviceUpload(List<DeviceUploadStaging__c> deviceUploadList, Map<String,List<String>> mapOfDeviceUploadType2Fields,Id brqID){
        DeviceUploadWrapper deviceUploadWrapper = new DeviceUploadWrapper();
        deviceUploadWrapper.brqId = brqId;
        for(DeviceUploadStaging__c deviceUpload : deviceUploadList){
            String errorDetail;
            BatchError__c batchError;
            List<String> validateFields = mapOfDeviceUploadType2Fields.get(deviceUpload.Catagory__c);
            for(string field: validateFields){
                if(deviceUpload.get(field) == null || deviceUpload.get(field) == ''){
                    if(string.isNotBlank(errorDetail))
                        errorDetail = errorDetail+','+fieldErrorMap.get(field);
                    else
                        errorDetail = LoBt_Constants.MISSING +' '+fieldErrorMap.get(field);
                }
                if(string.isNotBlank(errorDetail)){
                    batchError = new BatchError__c(BatchRequestQueue__c = brqID,ErrorDetails__c = errorDetail,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUpload.Id);
                }
            }
            
            if(deviceUpload.Catagory__c != LoBt_Constants.EXCHANGE_METER){
                if(string.isBlank(deviceUpload.Service1AvailableBundle__c) && string.isBlank(deviceUpload.Service2AvailableBundle__c)){
                    errorDetail = LoBt_Constants.MISSING_BUNDLES;
                    if(batchError != null){
                        batchError.ErrorDetails__c = batchError.ErrorDetails__c+','+errorDetail;
                    }else{
                        batchError = new BatchError__c(BatchRequestQueue__c = brqID,ErrorDetails__c = LoBt_Constants.MISSING +' '+ errorDetail,BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,BatchRequestType__c = LoBt_Constants.DEVICE_IMPORT,OperatingRecordId__c = deviceUpload.Id);
                    }
                }
            }
            if(batchError != null){
                deviceUploadWrapper.mapOfDeviceUploadId2BatchError.put(deviceUpload.Id,batchError);
            }else{
                deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.put(deviceUpload.Id,deviceUpload);
            }
        }
        return deviceUploadWrapper;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to create New Devices for New/Exchange Scenarios.
    *******************************************************************************/
    public static void createNewDevice(DeviceUploadWrapper deviceUploadWrapper){
        Set<String> manufactureSet = new Set<String>(); 
        Set<String> deviceSizeSet = new Set<String>();
        if(!deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.isEmpty()){
            for(DeviceUploadStaging__c deviceUpload : deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.values()){
                manufactureSet.add(deviceUpload.NewDeviceManufacturer__c);
                deviceSizeSet.add(deviceUpload.NewDeviceSize__c);
            }
            List<DeviceType__c> deviceTypeList = [Select Id,Manufacturer__c,DeviceSize__r.Name from DeviceType__c where Manufacturer__c In: manufactureSet AND DeviceSize__r.Name In:deviceSizeSet];
            Map<String,Id> mapOfManufatureDeviceSize2DeviceTypeId = new Map<String,Id>();
            for(DeviceType__c deviceType: deviceTypeList){
                mapOfManufatureDeviceSize2DeviceTypeId.put(deviceType.Manufacturer__c+deviceType.DeviceSize__r.Name,deviceType.Id);
            }
            for(DeviceUploadStaging__c deviceUpload : deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.values()){
                if(deviceUpload.Catagory__c != LoBt_Constants.REMOVE_METER){
                    Device__c newDevice = new Device__c();
                    newDevice.SerialNo__c = deviceUpload.NewDeviceSerialNumber__c;
                    newDevice.Digit__c = deviceUpload.Digits__c;
                    newDevice.SerialNumberandManufacturer__c = deviceUpload.NewDeviceManufacturer__c+deviceUpload.NewDeviceSerialNumber__c;
                    if(mapOfManufatureDeviceSize2DeviceTypeId.containsKey(deviceUpload.NewDeviceManufacturer__c+deviceUpload.NewDeviceSize__c))
                        newDevice.DeviceType__c = mapOfManufatureDeviceSize2DeviceTypeId.get(deviceUpload.NewDeviceManufacturer__c+deviceUpload.NewDeviceSize__c);
                    deviceUploadWrapper.mapOfDeviceUploadId2NewDevice.put(deviceUpload.Id,newDevice);
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to create New Supply Point Devices for New/Exchange Scenarios.
    *******************************************************************************/
    public static void createNewSupplyPointDevice(DeviceUploadWrapper deviceUploadWrapper){
        if(!deviceUploadWrapper.mapOfDeviceUploadId2NewDevice.isEmpty() && !deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.isEmpty()){
            for(DeviceUploadStaging__c deviceUpload : deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.values()){
                if(deviceUploadWrapper.mapOfDeviceUploadId2NewDevice.containsKey(deviceUpload.Id)){
                    Id supplyPointId;
                    if(deviceUpload.Catagory__c == LoBt_Constants.NEW_METER){
                        supplyPointId = deviceUpload.SupplyPoint__c;
                    }
                    if(deviceUpload.Catagory__c == LoBt_Constants.EXCHANGE_METER){
                        if(deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.containsKey(deviceUpload.Id)){
                            SupplyPointDevice__c existingSPD = deviceUploadWrapper.mapOfDeviceUploadId2UpdatedSPD.get(deviceUpload.Id);
                            supplyPointId = existingSPD.SupplyPoint__c;
                        }
                    }
                    Device__c newDevice = deviceUploadWrapper.mapOfDeviceUploadId2NewDevice.get(deviceUpload.Id);
                    SupplyPointDevice__c newSPD = new SupplyPointDevice__c();
                    newSPD.SupplyPoint__c = supplyPointId;
                    newSPD.Device__c = newDevice.Id;
                    newSPD.InstallationDate__c = deviceUpload.InstallationDate__c;
                    deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice.put(deviceUpload.Id,newSPD);
                    if(!deviceUploadWrapper.mapOfDeviceUpload2Reading.containsKey(deviceUpload.Id)){
                        deviceUploadWrapper.mapOfDeviceUpload2Reading.put(deviceUpload.Id,new List<Reading__c>());
                    }
                    deviceUploadWrapper.mapOfDeviceUpload2Reading.get(deviceUpload.Id).add(createInitialReading(newDevice.Id,deviceUpload));
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @param          DeviceUploadWrapper deviceUploadWrapper
    @description    Method used to create New Supply Point Device services for New/Exchange Scenarios.
    *******************************************************************************/
    public static void createSupplyPointDeviceServices(DeviceUploadWrapper deviceUploadWrapper){
        if(!deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.isEmpty() &&  !deviceUploadWrapper.mapOfDeviceUploadId2DeviceUpload.isEmpty()){
            List<AvailableService__c> avServiceList = [Select id,SupplyPoint__c,ServiceType__c from AvailableService__c where SupplyPoint__c In: deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.keySet()];
            if(avServiceList != null && !avServiceList.isEmpty()){
                for(AvailableService__c avService : avServiceList){
                    DeviceUploadStaging__c deviceUpload = deviceUploadWrapper.mapOfMeasuredSPId2DeviceUpload.get(avService.SupplyPoint__c);
                    if(!deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice.isEmpty() && deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice.containsKey(deviceUpload.Id)){
                        SupplyPointDevice__c newSPD = deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice.get(deviceUpload.Id);
                        if(avService.ServiceType__c ==  deviceUpload.Service1__c){
                            SupplyPointDeviceService__c spds = new SupplyPointDeviceService__c();
                            spds.SupplyPointDevice__c = newSPD.Id;
                            spds.ServiceType__c = deviceUpload.Service1__c;
                            deviceUploadWrapper.newSupplyPointDeviceServicesList.add(spds);
                        }
                        if(avService.ServiceType__c ==  deviceUpload.Service2__c){
                            SupplyPointDeviceService__c spds = new SupplyPointDeviceService__c();
                            spds.SupplyPointDevice__c = deviceUpload.Id;
                            spds.ServiceType__c = deviceUpload.Service2__c;
                            deviceUploadWrapper.newSupplyPointDeviceServicesList.add(spds);
                        }
                    }
                }
            }
        }
    }
}