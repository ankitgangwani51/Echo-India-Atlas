/******************************************************************************
@author         Echo: Amit K.
@date           04 Feb 2019
@description    Batch class to validate device upload staging data and map the data with existing data model for device exchanges scenarios
                and save the content report in the form of txt and .csv file.
*******************************************************************************/
global with sharing class LoBt_DeviceUpload extends GlBt_BatchProcess implements Database.Batchable<sObject>, Database.Stateful  {
    private static final String CLASS_NAME = 'LoBt_DeviceUpload';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    global Id batchRequestQueueId;
    global Integer totalNumberOfErrors = 0 ;
    global Integer numberOfReading = 0 ;
    global Integer numberOfDevice = 0 ;
    global Integer numberOfAvailableBundle = 0 ;
    global Integer numberOfSupplyPoint = 0 ;
    global Integer numberOfSupplyPointDevice = 0 ;
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){         
        this.batchRequestQueueId = brq.Id;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @description    Batch's start method
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        LoBt_ExportRequestedReadingsHelper.changeBRQStatus(this.batchRequestQueueId,LoBt_Constants.BRQPROCESSINGSTATUS);
		String sQuery = 'SELECT Id, '  + 
                        GlUt_APIConstantsDeviceImport.BOOKAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.CATAGORYAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.CURRENTMANUFACTURERAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.CURRENTSERIALNUMBERAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.DEPOTAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.DEVICELOCATIONAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.DIGITSAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.FINALREADINGAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.GEOLOCATIONAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.INITIALREADINGAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.INITIALREADINGDATEAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.INSTALLATIONDATEAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.LOCATIONNOAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.NEWDEVICEMANUFACTURERAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.NEWDEVICESERIALNUMBERAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.NEWDEVICESIZEAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.REMOVALDATEAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.SERVICE1APINAME + ',' +
                        GlUt_APIConstantsDeviceImport.SERVICE1AVAILABLEBUNDLEAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.SERVICE2APINAME + ',' +
                        GlUt_APIConstantsDeviceImport.SERVICE2AVAILABLEBUNDLEAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.SPECIALINSTRUCTIONSAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.SUPPLYPOINTAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.WALKORDERAPINAME + ',' +
                        GlUt_APIConstantsDeviceImport.GEOLOCATION_LATITUDE + ',' +
                        GlUt_APIConstantsDeviceImport.GEOLOCATION_LONGITUDE +
                        ' FROM ' + GlUt_APIConstantsDeviceImport.DEVICEUPLOADEAPINAME + 
            			' WHERE ' + GlUt_APIConstantsDeviceImport.PROCESSEDAPINAME + '='+ false ; 
        return Database.getQueryLocator(sQuery);
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<DeviceUploadStaging__c> deviceUploadRecords){
        system.debug('deviceUploadRecords===='+deviceUploadRecords);
        //try{
            LoBt_DeviceUploadHelper.DeviceUploadWrapper deviceUploadWrapper = new LoBt_DeviceUploadHelper.DeviceUploadWrapper();
            deviceUploadWrapper = LoBt_DeviceUploadHelper.deviceUploadHelper(deviceUploadRecords,this.batchRequestQueueId);
            system.debug('deviceUploadWrapper===='+deviceUploadWrapper);
            //Number of Reading
            if(numberOfReading != 0)
                numberOfReading = numberOfReading + deviceUploadWrapper.insertedReadingList.size();
            else
                numberOfReading = deviceUploadWrapper.insertedReadingList.size();
            // Number of Devices Created
            if(numberOfDevice != 0)
                numberOfDevice = numberOfDevice + deviceUploadWrapper.mapOfDeviceUploadId2NewDevice.values().size();
            else
                numberOfDevice = deviceUploadWrapper.mapOfDeviceUploadId2NewDevice.values().size();
            
            // Number of Available Bundle
            if(numberOfAvailableBundle != 0)
                numberOfAvailableBundle = numberOfAvailableBundle + deviceUploadWrapper.availableBundleList.size();
            else
                numberOfAvailableBundle = deviceUploadWrapper.availableBundleList.size();
            // Number of Supply Point
            if(numberOfSupplyPoint != 0)
                numberOfSupplyPoint = numberOfSupplyPoint + deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.values().size();
            else
                numberOfSupplyPoint = deviceUploadWrapper.mapOfDeviceUploadId2UpdatedMeasuredSP.values().size();
            // Number of Supply Point Device
            if(numberOfSupplyPointDevice != 0)
                numberOfSupplyPointDevice = numberOfSupplyPointDevice + deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice.values().size();
            else
                numberOfSupplyPointDevice = deviceUploadWrapper.mapOfDeviceUploadId2NewSupplyPointDevice.values().size();
            //Total Errors....
            if(totalNumberOfErrors != 0)
                totalNumberOfErrors = totalNumberOfErrors + deviceUploadWrapper.mapOfDeviceUploadId2BatchError.size();
            else
                totalNumberOfErrors = deviceUploadWrapper.mapOfDeviceUploadId2BatchError.size();  
        /*}Catch(Exception e){
            GlUt_Logger.logException(e);
            System.debug(DEBUG+' Exception==>'+e.getMessage());
        }finally {   
            GlUt_Logger.writeLogsToDatabase();
        }*/
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 Feb 2019
    @description    Batch's final method
	*******************************************************************************/
    global void finish(Database.BatchableContext bc){
        String deviceUploadLibraryName= '';
        EnvironmentSettings__mdt mdtEnvSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGDEVICEUPLOADQUERY);
        if (mdtEnvSetting != null && string.isNotBlank(mdtEnvSetting.DeviceUploadLibrary__c)) {
            deviceUploadLibraryName = mdtEnvSetting.DeviceUploadLibrary__c;
        }
        //txt file format
        string exportFileName = LoBt_Constants.DEVICE_IMPORT+'_' +DateTime.now().format(GlUt_Constants.DATE_TIME_FORMAT) + GlUt_Constants.REPORT_FILE_EXTENSION;
        String txtContent =''  ;
        txtContent = LoBt_Constants.TOTAL_NO_ERRORS + totalNumberOfErrors +'\n '+ LoBt_Constants.NUMBER_OF_DEVICES_CREATED + numberOfDevice +'\n ' + LoBt_Constants.NUMBER_OF_AVAILABLE_BUNDLE + numberOfAvailableBundle;
        txtContent = txtContent +'\n '+ LoBt_Constants.NUMBER_OF_SUPPLYPOINT + numberOfSupplyPoint + '\n '+ LoBt_Constants.NUMBER_OF_SUPPLY_POINT_DEVICE + numberOfSupplyPointDevice+'\n '+LoBt_Constants.NUMBER_OF_READING_CREATED + numberOfReading;
        //Save the data in content files as a csv.
        Id cdId =  GlUt_ContentDocument.saveLinkedDocument(this.batchRequestQueueId, deviceUploadLibraryName, exportFileName, exportFileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(txtContent));
        // Batch Request Queue Status with ‘Completed'        
        BatchRequestQueue__c objBRQ = [SELECT Status__c FROM BatchRequestQueue__c WHERE Id =: this.batchRequestQueueId LIMIT 1];            
        objBRQ.Status__c = GlUt_Constants.COMPLETED;  
        objBRQ  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(objBRQ, false);
        database.update(objBRQ);
    }
 }