/************************************************************************************************************
@author         Echo : Swati Mathur
@date           12-Jul-2018
@description:   This is the constants class for all static fields used in the Supply Point Band object
**************************************************************************************************************/
public class GlUt_APIConstantsSupplyPointBand {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();  
    
    // Supply Point Band Object API Name
    public static String  SUPPLYPOINTBANDAPINAME = NAMESPACEPREFIX + 'SupplyPointBand__c';    
    
    public static final String SUPPLYPOINTBANDID  = 'Id';
	public static final String NAMEAPINAME = 'Name';
    public static String  BANDTYPEAPINAME 			 = NAMESPACEPREFIX + 'BandType__c';
    public static string  BANDVALUEAPINAME           = NAMESPACEPREFIX + 'BandValue__c'; 
    public static string  STARTDATEAPINAME           = NAMESPACEPREFIX + 'StartDate__c'; 
    public static string  ENDDATEAPINAME         	 = NAMESPACEPREFIX + 'EndDate__c' ;
    public static string  SUPPLYPOINTAPINAME         = NAMESPACEPREFIX + 'SupplyPoint__c' ;
    
  
}