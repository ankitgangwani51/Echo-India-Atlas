/************************************************************************************************************
@author         Echo : Mohit Tayal
@date           07-Mar-2018
@description:   This is the constants class for all static fields used in the bill item object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsServiceItemFamily {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bill Item Object API Name
    public static String  SRVCITEMFMLYAPINAME = NAMESPACEPREFIX + 'ServiceItemFamily__c';
    
    // Bill Item object fields API Names
	public static String  SERVICETYPEAPINAME 		= NAMESPACEPREFIX + 'ServiceType__c';
    public static String  ALGORITHMTYPEAPINAME 	    = NAMESPACEPREFIX + 'AlgorithmType__c';
}