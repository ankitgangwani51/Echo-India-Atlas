public class GlUt_APIConstantsAvailableServiceItem {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();

    public static String  AVALSRVCITEMAPINAME = NAMESPACEPREFIX + 'AvailableServiceItem__c';
    
    // Object Relational Fields
    public static FINAL String AVALSRVCITEMRELAPINAME  = NAMESPACEPREFIX + 'AvailableServiceItem__r'  ;
    public static FINAL String SERVICEITEMAPINAME  = NAMESPACEPREFIX + 'ServiceItemType__c'  ;
    public static FINAL String AVAILABLEBUNDLEAPINAME  = NAMESPACEPREFIX + 'AvailableBundle__c'  ;
    public static FINAL String AVAILABLESERVICEITEMSAPINAME  = NAMESPACEPREFIX + 'AvailableServiceItem__c'  ;

    
    // AvailableServiceItem object fields API Names
    public static String NAMEAPINAME 					= 'Name';
    public static FINAL String ENDDATEAPINAME  = NAMESPACEPREFIX + 'EndDate__c'  ;
}