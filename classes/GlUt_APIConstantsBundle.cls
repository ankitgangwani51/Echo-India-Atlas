public class GlUt_APIConstantsBundle {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();

    public static String BUNDLEAPINAME = NAMESPACEPREFIX + 'Bundle__c';
    
    // AvailableService object fields API Names
    public static String NAMEAPINAME = 'Name';
    public static String SERVICETYPEAPINAME = NAMESPACEPREFIX + 'ServiceType__c';
    public static String SOCIALBUNDLEAPINAME = NAMESPACEPREFIX + 'TariffLimit__c';  //AT-3280
    
    public static String ID = 'Id'; //AT-3174
}