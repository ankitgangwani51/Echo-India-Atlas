/************************************************************************************************************
@author         Echo : Andrew Edge
@date           23-Feb-2018
@description:   This is the constants class for all static fields used in the service item type object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsServiceItemType {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Service Item Type Object API Name
    public static String  SERVICEITEMTYPEAPINAME = NAMESPACEPREFIX + 'ServiceItemType__c';
            
    // Service Item Type object fields API Names
    public static String  NAMEAPINAME 					= 'Name';
    public static String  ELIGIBLEFORAGREEDDATEAPINAME 	= NAMESPACEPREFIX + 'EligibleForAnAgreedRate__c';
    public static String  SERVICEITEMFAMILYAPINAME 		= NAMESPACEPREFIX + 'ServiceItemFamily__c';
    

    
}