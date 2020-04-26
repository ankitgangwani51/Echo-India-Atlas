public class GlUt_APIConstantsSupplyPointRelationship {
    
	// Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Supply Point Relationship Object API Name
    public static String  SUPPLYPOINTRELATIONSHIPAPINAME = NAMESPACEPREFIX + 'SupplyPointRelationship__c';
    
    // Supply Point Relationship object fields API Names
    public static String  ID				= 'Id';
    public static String  NAMEAPINAME 		= 'Name';
    public static String  MAINSUPPLYAPINAME = NAMESPACEPREFIX + 'MainSupply__c';
    public static String  SUBSUPPLYAPINAME  = NAMESPACEPREFIX + 'SubSupply__c';
    public static String  STARTDATEAPINAME 	= NAMESPACEPREFIX + 'StartDate__c';
    public static String  ENDDATEAPINAME 	= NAMESPACEPREFIX + 'EndDate__c';
   
}