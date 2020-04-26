public class GlUt_APIConstantsAvailableService {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();

    public static String  AVAILABLESERVICEAPINAME = NAMESPACEPREFIX + 'AvailableService__c';
    public static string ID = 'Id';
    
    // Object Relational Fields  -  Sudhir - 9/3/2018
    public static FINAL String AVAILABLESERVICERELAPINNAME  = NAMESPACEPREFIX + 'AvailableService__r'  ;
    
    // AvailableService object fields API Names
    public static String NAMEAPINAME 					= 'Name';
    public static String ACTIVEAPINAME 					= NAMESPACEPREFIX + 'Active__c';
    public static String SUPPLYPOINTAPINAME 			= NAMESPACEPREFIX + 'SupplyPoint__c';
    public static String SUPPLYPOINTRELAPINAME 			= NAMESPACEPREFIX + 'SupplyPoint__r';
    public static String SERVICETYPEAPINAME 			= NAMESPACEPREFIX + 'ServiceType__c';
    //public static String SERVICETYPEREFAPINAME 			= NAMESPACEPREFIX + 'ServiceTypesRef__c';--AT-3174
    public static String DEFAULTAPINAME 				= NAMESPACEPREFIX + 'Default__c';

}