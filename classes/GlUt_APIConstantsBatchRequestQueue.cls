public with sharing class GlUt_APIConstantsBatchRequestQueue {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  BATCHREQQUEUEAPINAME = NAMESPACEPREFIX + 'BatchRequestQueue__c';
    
    // Batch Request Queue object fields API Names
    public static final string ID = 'Id';
    public static final String CREATEDDATEAPINAME 	= 'CreatedDate';
    public static final String NAMEAPINAME 			= 'Name';
    public static final String USERAPINAME 			= NAMESPACEPREFIX + 'NotificationUser__c';
    public static final String STATUSAPINAME		= NAMESPACEPREFIX + 'Status__c';
    public static final String PARAMETERAPINAME		= NAMESPACEPREFIX + 'Parameters__c';  
    public static final String REQUESTNAMEAPINAME	= NAMESPACEPREFIX + 'RequestName__c';  
    public static final String BATCH_PROCESS		= NAMESPACEPREFIX + 'BatchProcess__c';  
    public static final String TYPEAPINAME          = NAMESPACEPREFIX + 'Type__c';
    
    
      
}