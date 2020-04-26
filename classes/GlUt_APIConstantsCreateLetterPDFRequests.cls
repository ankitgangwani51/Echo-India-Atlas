public class GlUt_APIConstantsCreateLetterPDFRequests {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Contract Object API Name
    public static String  CREATELETTERPDFREQUESTAPINAME = NAMESPACEPREFIX + 'CreateLetterPDFRequest__c';
    
    public static String  PDFREQUESTAPINAME = NAMESPACEPREFIX + 'PDFRequest__c';
    
    // Create Letter PDF Request object fields API Names
    public static String  HTMLBODYAPINAME 	= NAMESPACEPREFIX + 'HtmlBody__c';
    public static String  RELATEDTOAPINAME 	= NAMESPACEPREFIX + 'RelatedToId__c';
    public static String  ACCOUNTAPINAME 	= NAMESPACEPREFIX + 'Account__c';
    public static String  CONTRACTAPINAME 	= NAMESPACEPREFIX + 'BillingContract__c';
    public static String  CONTACTAPINAME 	= NAMESPACEPREFIX + 'Contact__c';
    public static String  SOURCETYPEAPINAME = NAMESPACEPREFIX + 'SourceType__c';
    public static String  STATUSAPINAME     = NAMESPACEPREFIX + 'Status__c';
}