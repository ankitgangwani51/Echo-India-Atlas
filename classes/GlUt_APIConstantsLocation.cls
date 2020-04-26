/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           28-Feb-2018
@description:   This is the constants class for all static fields used in the location object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsLocation {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();  
    
    // Location Object API Name
    public static String  LOCATIONAPINAME = NAMESPACEPREFIX + 'Location__c';
    
    // Location object fields API Names - Some Constants Added by Dependra -09-03-2018 
    public static final String LOCATIONID  = 'Id';
	public static final String NAMEAPINAME = 'Name';
    public static String  NUMOFOCCAPINAME 			 = NAMESPACEPREFIX + 'NumberOfOccupiers__c';
    //public static string  LOCATIONREFERENCEAPINAME   = NAMESPACEPREFIX + 'LocationReference__c';  AT-3174
    public static string  LOCATIONADDRESSAPINAME     = NAMESPACEPREFIX + 'Address__c'; 
    public static string  LOCATIONTYPEAPINAME     	 = NAMESPACEPREFIX + 'LocationType__c' ;
    public static string  POSTALCODEAPINAME     	 = NAMESPACEPREFIX + 'PostalCode__c' ;
    public static string  STREETAPINAME              = NAMESPACEPREFIX + 'Street__c';
    public static string  CITYAPINAME                = NAMESPACEPREFIX + 'City__c';
    public static string  STATEPROVINCEAPINAME       = NAMESPACEPREFIX + 'State__c';
    public static string  PARENTLOCATIONAPINAME      = NAMESPACEPREFIX + 'ParentLocation__c';
    public static string  LOCATIONSUBTYPEAPINAME     = NAMESPACEPREFIX + 'LocationSubType__c';
    public static string  LOCATIONCOUNTRYAPINAME     = NAMESPACEPREFIX + 'Country__c';
    public static string  LOCATIONVOIDLOCATIONAPINAME= NAMESPACEPREFIX + 'VoidLocation__c';
    
    public static string  LOCATIONAUDPIDAPINAME= NAMESPACEPREFIX + 'AuDPID__c'; //AT-4039
    
  
}