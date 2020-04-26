public class GlUt_APIConstantsDevice {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();

 	// Object API Name
    public static String  DEVICEAPINAME = NAMESPACEPREFIX + 'Device__c';
    
    // Device Object Rel API Name
    public static final String DEVICERELAPINAME = NAMESPACEPREFIX + 'Device__r';
    
    // Field API Names
    public static String  ID 					= 'Id';
    public static String  DEVICETYPEAPINAME 	= NAMESPACEPREFIX + 'DeviceType__c'; 
    public static String  DEVICETYPERELAPINAME 	= NAMESPACEPREFIX + 'DeviceType__r';
    public static String  ACTIVEAPINAME 		= NAMESPACEPREFIX + 'Active__c';
    public static String  SERIALNOAPINAME 		= NAMESPACEPREFIX + 'SerialNo__c'; 
    //public static String  DEVICEREFERNCEAPINAME = NAMESPACEPREFIX + 'DeviceReference__c';  -- AT-3174
    public static String  DEVICENAMEAPINAME 	= 'Name';
    public static String  DIGITSAPINAME 		= NAMESPACEPREFIX + 'Digit__c';
    public static String  SNOMANUFACTURERAPINAME = NAMESPACEPREFIX + 'SerialNumberandManufacturer__c';
    public static String  DEVICENUMBER 	= 'Device No.';  //AT-4244
}