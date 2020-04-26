public class GlUt_APIConstantsSupplyPoint {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Supply Point Object API Name
    public static String  SUPPLYPOINTAPINAME = NAMESPACEPREFIX + 'SupplyPoint__c';
    
    //SupplyPoint "Standard" RecordTypeId: AT-5050
    public static Id STANDARD_SUPPLYPOINT_RECORDTYPEID	= Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByDeveloperName().get(System.Label.LoBt_LocationImport_SupplyPointRecordTypeName).getRecordTypeId() ;
    
    // Supply Point Object Relation API Name
    public static String  SUPPLYPOINTRELAPINAME = NAMESPACEPREFIX + 'SupplyPoint__r';
    
    // Supply Point object fields API Names
    public static String  DEVICELOCATIONAPINAME = NAMESPACEPREFIX + 'DeviceLocation__c';
    
    // Location fields API Names
    public static String  LOCATIONAPINAME = NAMESPACEPREFIX + 'Location__c';

    public static String  READFREQUENCYAPINAME = NAMESPACEPREFIX + 'Read_Frequency__c';
    public static String  MEASUREDAPINAME = NAMESPACEPREFIX + 'Measured__c';  // AT-3157
    //Swati - 09-Mar-2018    
    public static final String NAMEAPINAME = 'Name';
    
    // Book Field API Name
    public static String  BOOKAPINAME = NAMESPACEPREFIX + 'Book__c';
    public static String  WALKORDERAPINAME = NAMESPACEPREFIX + 'WalkOrder__c';
    public static String  LOCATIONRELAPINAME = NAMESPACEPREFIX + 'Location__r.Name';
    public static String  LOCATIONADDRESSAPINAME = NAMESPACEPREFIX + 'Location__r.' + NAMESPACEPREFIX + 'Address__c';
    public static String  DEPOTRELAPINAME = NAMESPACEPREFIX + 'Depot__r.Name';
    public static String  BOOKRELAPINAME = NAMESPACEPREFIX + 'Book__r.Name';
    public static String  VOIDLOCATIONAPINAME = NAMESPACEPREFIX + 'Location__r.' + NAMESPACEPREFIX + 'VoidLocation__c';
    public static String  GEOLOCATIONAPINAME = NAMESPACEPREFIX + 'Geolocation__c';
    public static String  SPECIALINSTRUCTIONAPINAME = NAMESPACEPREFIX + 'SpecialInstructions__c';
    public static String  TARGETREADDATEAPINAME = NAMESPACEPREFIX + 'TargetReadDate__c';
    public static String  EXCLUDEFROMESTIMATIONAPINAME = NAMESPACEPREFIX + 'ExcludeFromEstimation__c';
    public static String  BOOKREADTIMETABLERAPINAME = NAMESPACEPREFIX + 'Book__r.'  + NAMESPACEPREFIX + 'ReadTimetable__c';
    public static String  ID = 'Id';
    public static String  BOOKDEPOTRELAPINAME = NAMESPACEPREFIX + 'Book__r.' + NAMESPACEPREFIX +'Depot__r.Name';
    public static String  RECORDTYPEOUTLETTYPE = 'Rural Outlet'; //AT-4499
    public static String  RURALOUTLETBILLINGTYPEAPINAME = NAMESPACEPREFIX + 'RuralOutLetBillingType__c'; 
    public static String  RURALCHANNELAPINAME = NAMESPACEPREFIX + 'RuralChannel__c'; 
    public static String  RURALLICENCEAPINAME = NAMESPACEPREFIX + 'Location__r.'+ NAMESPACEPREFIX +'RuralLicense__c'; 
    public static String  ADVICEAPINAME = NAMESPACEPREFIX + 'Advice__c';  
   
}