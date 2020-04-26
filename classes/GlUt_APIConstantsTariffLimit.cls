public with sharing class GlUt_APIConstantsTariffLimit {
    
    // get the namespace prefix and prefix it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String OBJECTAPINAME 	    = NAMESPACEPREFIX + 'TariffLimit__c';    
    public static String ACCOUNTAPINAME   	= NAMESPACEPREFIX + 'Account__c';
    public static String STARTDATEAPINAME   = NAMESPACEPREFIX + 'StartDate__c';
    public static String ENDDATEAPINAME   	= NAMESPACEPREFIX + 'EndDate__c';
}