public class GlUt_APIConstantsSPDService {      // Sudhir - 9/3/2018
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();

    public static String  SUPPLYPOINTSERVICEDEVICEAPINAME = NAMESPACEPREFIX + 'SupplyPointDeviceService__c';
    
    // Object Relational Fields 
    
    // Supply Point Device Service object fields API Names
    public static String  SUPPLYPOINTDEVICEAPINAME = NAMESPACEPREFIX + 'SupplyPointDevice__c';
    public static String  SUPPLYPOINTDEVICERELAPINAME = NAMESPACEPREFIX + 'SupplyPointDevice__r';
    public static String  SERVICETYPEAPINAME = NAMESPACEPREFIX + 'ServiceType__c';  
    public static String  SERVICETYPERELAPINAME = NAMESPACEPREFIX + 'ServiceType__r';  
    
}