/************************************************************************************************************
@author         Vivek Sethi   
@date           
@description:   This is the constants class for all static fields used in the Site Supply object
                
**************************************************************************************************************/
public class GlUt_APIConstantsSiteSupply {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Supply Point Object API Name
    public static String  SITESUPPLYAPINAME = NAMESPACEPREFIX + 'SiteSupply__c';

    // Site Supply Field API Name
    public static String  NAMEAPINAME = 'Name'; 
    public static String  SITESUPPLYPOINTAPINAME = NAMESPACEPREFIX + 'SiteSupplyPoint__c'; 
    public static String  SUPPLYPOINTAPINAME = NAMESPACEPREFIX + 'SupplyPoint__c';
    public static String  STARTDATEAPINAME = NAMESPACEPREFIX + 'StartDate__c';
    public static String  ENDDATEAPINAME = NAMESPACEPREFIX + 'EndDate__c';
    public static String  PERCENTAGESPLITAPINAME = NAMESPACEPREFIX + 'PercentageSplit__c';
    public static String  INVALIDAPINAME = NAMESPACEPREFIX + 'Invalid__c'; 
    public static String  AMENDEDBYSITESUPPLYAPINAME = NAMESPACEPREFIX +  'AmendedBySiteSupply__c';
    public static String  ENDEDAPINAME = NAMESPACEPREFIX +  'Ended__c';
    
    }