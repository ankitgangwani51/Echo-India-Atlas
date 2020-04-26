public with sharing class GlUt_APIConstantsReading {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
 	// Object API Name
    public static String  READINGAPINAME = NAMESPACEPREFIX + 'Reading__c';
    
    // Referenced fields APi name
    public static String READINGDEVICEREFAPINAME		= NAMESPACEPREFIX + 'Device__r' ;//AT-3174
    
    public static String NAMEAPINAME 				= 'Name';
    
    // Field API Names
    public static String  READINGDATEAPINAME 			= NAMESPACEPREFIX + 'ReadingDate__c'; 
    public static String  DEVICEREFERENCEAPINAME 		= NAMESPACEPREFIX + 'Device__c'; //AT-3174
    public static String  ACTUALDEVICEREADINGAPINAME 	= NAMESPACEPREFIX + 'ActualDeviceReading__c';
    public static String  READINGMETHODAPINAME 			= NAMESPACEPREFIX + 'ReadingMethod__c'; 
    public static String  READINGTYPEAPINAME 			= NAMESPACEPREFIX + 'ReadingType__c'; 
    public static String  BILLABLETYPEAPINAME 			= NAMESPACEPREFIX + 'BillableType__c'; 
    public static String  BILLEDAPINAME 				= NAMESPACEPREFIX + 'Billed__c'; 
	public static String  READINGSOURCEAPINAME 			= NAMESPACEPREFIX + 'ReadingSource__c';
    public static String  READINGFIELDAPINAME 			= NAMESPACEPREFIX + 'Reading__c';	//		Sudhir: AT-1819
    public static String  AMENDEDBYREADINGAPINAME 		= NAMESPACEPREFIX + 'AmendedByReading__c';	//		Neha: AT-2226
    public static String  EFFDEVICEREADINGAPINAME 		= NAMESPACEPREFIX + 'EffectiveDeviceReading__c'; // Neha AT-2933
    public static String  LEAKAPINAME 		            = NAMESPACEPREFIX + 'Leak__c'; // Neha AT-2933
    public static String  TRIPPEDAPINAME 		        = NAMESPACEPREFIX + 'Tripped__c'; // Neha AT-3420
    public static String  INFORMATIONSTATEMENT	        = NAMESPACEPREFIX + 'InformationStatement__c'; 
}