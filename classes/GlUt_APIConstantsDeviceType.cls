public with sharing class GlUt_APIConstantsDeviceType {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
 	// Object API Name
    public static String  DEVICETYPEAPINAME = NAMESPACEPREFIX + 'DeviceType__c';
    
    // DeviceType Object Rel API Name
    public static final String DEVICETYPERELAPINAME = NAMESPACEPREFIX + 'DeviceType__r';
    
    // Field API Names
    public static String  ID						 = 'Id';
    public static String  NAMEAPINAME 				 = 'Name';
    public static String  MANUFACTUREAPINAME 		 = NAMESPACEPREFIX + 'Manufacturer__c';
    //public static String  DEVICESIZENAMEAPINAME 	 = NAMESPACEPREFIX + 'DeviceSizeName__c'; --AT-3174
}