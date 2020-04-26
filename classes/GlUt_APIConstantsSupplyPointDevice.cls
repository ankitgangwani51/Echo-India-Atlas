public class GlUt_APIConstantsSupplyPointDevice {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Supply Point Device Object API Name
    public static String  SUPPLYPOINTDEVICEAPINAME = NAMESPACEPREFIX + 'SupplyPointDevice__c';
    
    // Supply Point Device object fields API Names
    public static String  ID						= 'Id';
    public static String  NAMEAPINAME 			 	= 'Name';
    public static String  DEVICEAPINAME  		 	= NAMESPACEPREFIX + 'Device__c';
    public static String  SUPPLYPOINTAPINAME     	= NAMESPACEPREFIX + 'SupplyPoint__c';
    public static String  ACTIVEAPINAME 		 	= NAMESPACEPREFIX + 'Active__c';
    public static String  INSTALLATIONDATEAPINAME 	= NAMESPACEPREFIX + 'InstallationDate__c';
    public static String  REMOVALDATEAPINAME      	= NAMESPACEPREFIX + 'RemovalDate__c';
   
    public static String  SUPPLYPOINTBOOKAPINAME = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Book__c';   //AT-3855 
    
}