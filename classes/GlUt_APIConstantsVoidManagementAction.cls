public class GlUt_APIConstantsVoidManagementAction {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String VOIDMANAGEMENTACTIONAPINAME = NAMESPACEPREFIX + 'VoidManagementAction__c';

    public static String NAMEAPINAME = 'Name';
    public static String PARAMETERSAPINAME = NAMESPACEPREFIX + 'Parameters__c';
    public static String PROCESSEDAPINAME = NAMESPACEPREFIX + 'Processed__c' ; 
    public static String ACTIONAPINAME = NAMESPACEPREFIX + 'Action__c' ;
}