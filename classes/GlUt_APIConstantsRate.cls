/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           07-Mar-2018
@description:   This is the constants class for all static fields used in the Rate object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsRate {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Rate Object API Name
    public static String  RATEAPINAME = NAMESPACEPREFIX + 'Rate__c';
    
    // Rate object fields API Names
    public static final string RETAILAMOUNTAPINAME 		= NAMESPACEPREFIX + 'RetailAmount__c';
    public static final string SERVICEITEMTYPEAPINAME 	= NAMESPACEPREFIX + 'ServiceItemType__c';
    public static final string STARTDATEAPINAME 		= NAMESPACEPREFIX + 'StartDate__c';
    public static final string ENDDATEAPINAME 			= NAMESPACEPREFIX + 'EndDate__c';
}