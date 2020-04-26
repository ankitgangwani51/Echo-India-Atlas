public class GlUt_APIConstantsSkipCode {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Supply Point Device Object API Name
    public static String  SKIPCODEAPINAME = NAMESPACEPREFIX + 'SkipCode__c';
    
    // Supply Point Device object fields API Names   
    public static String  CREATEERRORAPINAME  	= NAMESPACEPREFIX + 'CreateError__c';
    public static String  CREATEESTIMATEAPINAME = NAMESPACEPREFIX + 'CreateEstimate__c';
    public static String  DESCRIPTIONAPINAME 	= NAMESPACEPREFIX + 'Description__c';
   

}