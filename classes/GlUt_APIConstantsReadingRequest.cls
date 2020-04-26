public class GlUt_APIConstantsReadingRequest {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    // Reading Request Object API Name
    public static String  READINGREQUESTAPINAME = NAMESPACEPREFIX + 'ReadingRequest__c';   
    public static String  ID = 'Id';
    public static String  READBYDATEAPINAME = NAMESPACEPREFIX + 'ReadbyDate__c';
    public static String  CREATEDDATEAPINAME = 'CreatedDate';
    public static String  READCOMMENTSAPINAME = NAMESPACEPREFIX + 'ReadComments__c';
    public static String  READREASONAPINAME = NAMESPACEPREFIX + 'ReadReason__c';
    public static String  STATUSAPINAME = NAMESPACEPREFIX + 'Status__c';
    public static String  SPTOLOCATION = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Location__r.Name';
    public static String  SPTODEPOTNAME = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Depot__r.Name';
    public static String  SPTOBOOKNAME = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Book__r.Name';
    public static String  SPTOBOOKTOREADTIMETABLE = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Book__r.' + NAMESPACEPREFIX + 'ReadTimetable__c';
    public static String  SPTOWALKORDER = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'WalkOrder__c';
    public static String  SPTOVOIDLOCATION = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Location__r.VoidLocation__c';
    public static String  SPTODEVICELOCATION = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'DeviceLocation__c';
    public static String  SPTOGEOLOCATION = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Geolocation__c';
    public static String  SPTOSPECIALINSTRUCTION = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'SpecialInstructions__c';
    public static String  SPTOTARGETREADDATE = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'TargetReadDate__c';

}