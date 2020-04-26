public with sharing class GlUt_APIConstantsBatchProcess {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  BATCHPROCESSAPINAME = NAMESPACEPREFIX + 'BatchProcess__c';
    
    // Batch Request Queue object fields API Names
    public static final String ID = 'Id';
    public static final String OWNERIDAPINAME = 'OwnerId';
    public static final String BATCHSIZEAPINAME = NAMESPACEPREFIX + 'BatchSize__c';
    public static final String BATCHCLASSAPINAME = NAMESPACEPREFIX + 'BatchClass__c';
    public static final String OPERATIONAPINAME = NAMESPACEPREFIX + 'Operation__c'; 
    public static final String TYPEAPINAME = NAMESPACEPREFIX + 'Type__c';       // Deprecated - do not use
    
}