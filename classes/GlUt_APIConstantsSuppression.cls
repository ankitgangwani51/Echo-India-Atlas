public class GlUt_APIConstantsSuppression {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();

    // Suppression Object API Name
    public static String  SUPPRESSIONAPINAME 			= NAMESPACEPREFIX + 'Suppression__c';
    public static String  SUPPRESSIONSTARTDATEAPINAME 	= NAMESPACEPREFIX + 'SuppressionStartDate__c';    
    public static String  SUPPRESSIONENDDATEAPINAME 	= NAMESPACEPREFIX + 'SuppressionEndDate__c';    
    public static String  ACCOUNTAPINAME	 			= NAMESPACEPREFIX + 'Account__c';
    
    public static String  NAMEAPINAME = 'Name';
}