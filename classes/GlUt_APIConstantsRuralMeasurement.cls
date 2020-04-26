/******************************************************************************
@author    		Echo: Neha R.
@date      		14 Dec 2018
@description 	API Constants for Rural Measurement
Revisions		
*******************************************************************************/
public class GlUt_APIConstantsRuralMeasurement {
    
	// Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  RURALMEASUREMENTAPINAME = NAMESPACEPREFIX + 'RuralMeasurement__c';
    
    // Rural Order object fields API Names
    public static string  ID                      = 'Id';
    public static string  DATETIMEAPINAME         = NAMESPACEPREFIX + 'DateTime__c';
    public static string  HEADAPINAME             = NAMESPACEPREFIX + 'Head__c';
    public static string  TYPEAPINAME             = NAMESPACEPREFIX + 'Type__c';
    public static string  SUPPLYPOINTAPINAME      = NAMESPACEPREFIX + 'SupplyPoint__c';
    public static string  RURALCHANNELAPINAME     = NAMESPACEPREFIX + 'RuralChannel__c';
        
}