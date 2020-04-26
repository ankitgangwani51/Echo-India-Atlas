/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		20-Dec-2017
@description 	Component controller for Creating New Reading

Revision(s) 	05 Apr 2018, P Dixon - revised component to use NewReadingForm component
				02 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
				23 May 2018, T Gupta - revised to use DEVICEREFERENCEAPINAME instead of READINGDEVICEREFAPINAME as it was breaking the class
*******************************************************************************/
public with sharing class BlAp_CreateNewReadingPageCtrlr {

    private static final String CLASS_NAME = 'BlAp_CreateNewReadingPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<string> readingFields;
    static {
        readingFields = new List<string>();
        readingFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
    }
  /*  private static List<string> supplyPointFields;  //AT-4185
    static {
        supplyPointFields = new List<string>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.READFREQUENCYAPINAME); 
   
    }*/
    private static List<string> deviceFields;
    static {
        deviceFields = new List<string>();
        deviceFields.add(GlUt_APIConstantsDevice.DEVICENAMEAPINAME); 
        deviceFields.add(GlUt_APIConstantsDevice.SERIALNOAPINAME); 
        deviceFields.add(GlUt_APIConstantsDevice.DIGITSAPINAME); 
   
    }
    private static List<string> locationFields;
    static {
        locationFields = new List<string>();
        //locationFields.add(GlUt_APIConstantsLocation.LOCATIONREFERENCEAPINAME);  //AT-3174
    }

    /**********************************************************************************************
    @author			Echo: Amit K.
    @date			08-Mar-2018
    @return			List<List<GLAp_FieldProps>>
	@description	This method returns the device/location related fields as List.
    Revision(s)		05 Apr 2018, P Dixon, revised to get device/location fields only
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveDeviceFields() {

        try {
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> combinedFields = new List<GLAp_FieldProps>();
            List<GLAp_FieldProps> deviceFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceFields);
            //List<GLAp_FieldProps> locationFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationFields); //AT-3174

            for (GLAp_FieldProps deviceProp : deviceFields) { 
                deviceProp.showLabel = true;
                deviceProp.isEditable = false;
            }
            /*for (GLAp_FieldProps locationProp : locationFields) { 
                locationProp.showLabel = true;
                locationProp.isEditable = false;
            }*/ //AT-3174
            for (Integer i = 0; i < deviceFields.size(); i++){
                combinedFields.add(deviceFields[i]);
            }
            /*for (Integer j = 0; j < locationFields.size(); j++){
                combinedFields.add(locationFields[j]);
            }*/ //AT-3174

			for (Integer i = 0; i < combinedFields.size(); i = i + 2) {
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                Integer secondEntryIndex = i + 1;
                lstEntry.add(combinedFields[i]);
                if (secondEntryIndex < combinedFields.size()) {
                    lstEntry.add(combinedFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }
    
	/**********************************************************************************************
    @author			Echo: Amit K.
    @date 			08-Mar-2018
    @return			List<List<GLAp_FieldProps>>
    @description	This method returns back supplyPoint related fields as List. 
    **********************************************************************************************/
 /*   @AuraEnabled   //AT-4185
    public static List<List<GlAp_FieldProps>> retrieveSupplyPointFields() {
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> lstSupplyPointFields = GlAp_LightningDataAccess.getObjectsFieldProperties(
            														GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supplyPointFields);

            for (GLAp_FieldProps readingProp: lstSupplyPointFields) { 
                readingProp.showLabel = true;
                readingProp.isEditable = true;
            }
            for (Integer i = 0; i < lstSupplyPointFields.size(); i = i + 2) {
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                Integer secondEntryIndex = i + 1;
                lstEntry.add(lstSupplyPointFields[i]);
                if (secondEntryIndex < lstSupplyPointFields.size()) {
                    lstEntry.add(lstSupplyPointFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;

        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }*/
    
    /**********************************************************************************************
    @author			Echo: Amit K.
    @date			19-March-2018
    @return			Location__c
    @description	This method returns the location object data 
    **********************************************************************************************/  
    /*@AuraEnabled
    public static Location__c getLocation(Id locationId) {
        system.debug(DEBUG + 'locationId: ' + locationId);
    	return (Location__c) GlAp_LightningDataAccess.getRecordByIdAndFieldList(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationId, locationFields);
    }*/ //AT-3174
    
    /**********************************************************************************************
    @author 		Echo: Tarun
    @date 			20-Dec-2017
    @return			List<Wrapper>
    @description	This method returns the Device, Reading values 
    **********************************************************************************************/    
    @AuraEnabled
    public static WrapSelectDevice fetchDeviceData(Id deviceId){ 
        
        system.debug(DEBUG + 'deviceId: '+ deviceId);
        
        // Wrapper class to set values
        WrapSelectDevice objWrap = new WrapSelectDevice();
        
        Device__c objDevice = (Device__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsDevice.DEVICEAPINAME, 
        																			deviceId, 
        																			deviceFields);
		System.debug(DEBUG + 'objDevice: ' + objDevice);
        if (objDevice != null) {														
	        objWrap.deviceDigits = objDevice.Digit__c;
	        objWrap.existingDevice = objDevice;
        }
        
        List<Reading__c> lstReadings = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
        																						readingFields, 
        																						deviceId, 
                                                                                                GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME, 
        																						null, 
        																						' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC'
        																						);
        for (Reading__c reading : lstReadings) {
        														
        	objWrap.actualReading = reading.ActualDeviceReading__c;
        	break;		// most recent only
		}
       
        return objWrap;
    }
    
    /******************************************************************************
    @author      	Echo: Tarun Gupta
    @date      		20-Dec-2017
    @description	wrapper class to hold the Reading & Device information
    *******************************************************************************/
    public class WrapSelectDevice {        
         
        @AuraEnabled public String actualReading;
        @AuraEnabled public Double deviceDigits;
        @AuraEnabled public Device__c existingDevice;
    }
    
}