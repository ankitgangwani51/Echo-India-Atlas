public class GlUt_APIConstantsCase {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  CASEAPINAME = 'Case';
    
    // Case object fields API Names
    public static string  ID = 'Id';
    public static String  CASENUMBERAPINAME = 'CaseNumber';
    public static String  STATUSAPINAME = 'Status';
    public static String  ORIGINAPINAME = 'Origin';
    public static String  OWNERAPINAME =  'OwnerId';
    public static String  ACCOUNTIDAPINAME = 'AccountId';
    public static String  CREATEDDATEAPINAME =  'CreatedDate';
    public static String  REASONAPINAME = 'Reason';
    public static String  GROUPAPINAME = NAMESPACEPREFIX + 'Group__c';
    public static String  TYPEAPINAME = NAMESPACEPREFIX + 'Type__c';
    public static String  ADVICEGIVENAPINAME = NAMESPACEPREFIX + 'AdviceGiven__c';
}