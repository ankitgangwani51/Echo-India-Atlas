/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           07-Mar-2018
@description:   This is the constants class for all static fields used in the Agreed Rate object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsAgreedRate {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Rate Object API Name
    public static String  AGREEDRATEAPINAME = NAMESPACEPREFIX + 'AgreedRate__c';
    
    // Rate object fields API Names
    public static final string VALUEAPINAME 				= NAMESPACEPREFIX + 'Value__c';
    public static final string STARTDATEAPINAME 			= NAMESPACEPREFIX + 'StartDate__c';
    public static final string ENDDATEAPINAME 				= NAMESPACEPREFIX + 'EndDate__c';
    public static final string LEAPYEARAPINAME 				= NAMESPACEPREFIX + 'LeapYear__c';
    public static final string SERVICEITEMAPINAME 			= NAMESPACEPREFIX + 'ServiceItem__c';
    public static final string AMENDEDBYAGREEDRATEAPINAME 	= NAMESPACEPREFIX + 'AmendedByAgreedRate__c';
    public static final string WHOLESALEAMOUNTAPINAME 	    = NAMESPACEPREFIX + 'WholesaleAmount__c';
    
    
    
    

}