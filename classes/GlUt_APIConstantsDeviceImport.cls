/******************************************************************************
@author         Echo: Amit K.
@date           04 Feb 2019
@description    Constant class for Field API used for Device Import
*******************************************************************************/
public class GlUt_APIConstantsDeviceImport {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String DEVICEUPLOADEAPINAME = NAMESPACEPREFIX + 'DeviceUploadStaging__c';
    
    // Device Upload object fields API Names
    public static String BRQAPINAME = NAMESPACEPREFIX + 'BatchRequestQueue__c';
    public static String BATCHERRORAPINAME = NAMESPACEPREFIX + 'BatchError__c';
    public static String BOOKAPINAME = NAMESPACEPREFIX + 'Book__c';
    public static String CATAGORYAPINAME = NAMESPACEPREFIX + 'Catagory__c';
    public static String CURRENTMANUFACTURERAPINAME = NAMESPACEPREFIX + 'CurrentManufacturer__c';
    public static String CURRENTSERIALNUMBERAPINAME = NAMESPACEPREFIX + 'CurrentSerialNumber__c';
    public static String DEPOTAPINAME = NAMESPACEPREFIX + 'Depot__c';
    public static String DEVICELOCATIONAPINAME = NAMESPACEPREFIX + 'DeviceLocation__c';
    public static String DIGITSAPINAME = NAMESPACEPREFIX + 'Digits__c';
    public static String FINALREADINGAPINAME = NAMESPACEPREFIX + 'FinalReading__c';
    public static String GEOLOCATIONAPINAME = NAMESPACEPREFIX + 'Geolocation__c';
    public static String INITIALREADINGAPINAME = NAMESPACEPREFIX + 'InitialReading__c';
    public static String INITIALREADINGDATEAPINAME = NAMESPACEPREFIX + 'InitialReadingDate__c';
    public static String INSTALLATIONDATEAPINAME = NAMESPACEPREFIX + 'InstallationDate__c';
    public static String LOCATIONNOAPINAME = NAMESPACEPREFIX + 'LocationNo__c';
    public static String NEWDEVICEMANUFACTURERAPINAME = NAMESPACEPREFIX + 'NewDeviceManufacturer__c';
    public static String NEWDEVICESERIALNUMBERAPINAME = NAMESPACEPREFIX + 'NewDeviceSerialNumber__c';
    public static String NEWDEVICESIZEAPINAME = NAMESPACEPREFIX + 'NewDeviceSize__c';
    public static String PROCESSEDAPINAME = NAMESPACEPREFIX + 'Processed__c';
    public static String REMOVALDATEAPINAME = NAMESPACEPREFIX + 'RemovalDate__c';
    public static String SERVICE1APINAME = NAMESPACEPREFIX + 'Service1__c';
    public static String SERVICE1AVAILABLEBUNDLEAPINAME = NAMESPACEPREFIX + 'Service1AvailableBundle__c';
    public static String SERVICE2APINAME = NAMESPACEPREFIX + 'Service2__c';
    public static String SERVICE2AVAILABLEBUNDLEAPINAME = NAMESPACEPREFIX + 'Service2AvailableBundle__c';
    public static String SPECIALINSTRUCTIONSAPINAME = NAMESPACEPREFIX + 'SpecialInstructions__c';
    public static String SUPPLYPOINTAPINAME = NAMESPACEPREFIX + 'SupplyPoint__c';
    public static String WALKORDERAPINAME = NAMESPACEPREFIX + 'WalkOrder__c';
    public static String GEOLOCATION_LATITUDE = 'Geolocation__Latitude__s';
    public static String GEOLOCATION_LONGITUDE = 'Geolocation__Longitude__s';
        
    
}