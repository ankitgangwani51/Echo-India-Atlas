public class GlUt_APIConstantsServiceType {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX 					= GlUt_NamespacePrefix.getNamespacePrefix();
  
    public static String SERVICETYPEAPINAME 				= NAMESPACEPREFIX + 'ServiceType__c';
    public static String SUPPLYPOINTAPINAME 				= NAMESPACEPREFIX + 'SupplyPoint__c';
    
    // Sudhir 9/3/2018 - Object Relational Fields
    public static FINAL String SERVICETYPERELAPINNAME  		= NAMESPACEPREFIX + 'ServiceType__r'  ;
    
    // AvailableService object fields API Names
    public static String NAMEAPINAME 						= 'Name';
    public static String SERVICETYPEDSCRAPINAME 			= NAMESPACEPREFIX + 'ServiceTypeDescription__c';
    
    //Added as used in CuAp_SelectServicesPageCtrlr - Swati - 09-Mar-2018
    //public static final String SRVCTYPSREFAPINAME                 =  NAMESPACEPREFIX + 'ServiceTypesRef__c'; --AT-3174
    public static final String Id                                 =  'Id';
    
}