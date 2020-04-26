/******************************************************************************
@author    		Echo: Neha R.
@date      		11 Dec 2018
@description 	API Constants for Rural Order
Revisions		
*******************************************************************************/
public class GlUt_APIConstantsRuralOrder {
    
	// Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  RURALORDERAPINAME = 'RuralOrder__c';
    
    // Rural Order object fields API Names
    public static string  ID                      = 'Id';
    public static string  LOADREFAPINAME          = 'LoadReference__c';
    public static string  LOCATIONAPINAME         = 'Location__c';
    public static string  ORDERVOLAPINAME         = 'OrderVolume__c';
    public static string  HALFDAYORDERAPINAME     = 'HalfDayOrder__c';
    public static string  ORDERDATEAPINAME        = 'OrderDate__c';
    public static string  STARTDATEAPINAME        = 'StartDate__c';
    public static string  ENDDATEAPINAME          = 'EndDate__c';
    public static string  RURALCHANNELAPINAME     = 'RuralChannel__c';
    public static string  OUTLETAPINAME           = 'Outlet__c';
    public static string  RURALENTITLEMENTAPINAME = 'RuralEntitlement__c';
    
}