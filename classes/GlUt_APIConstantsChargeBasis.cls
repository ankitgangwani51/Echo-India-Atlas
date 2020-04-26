/******************************************************************************
@author         Echo: Patrick Dixon
@date           14 Mar 2018
@description:   This is the constants class for all static fields used in 
				the Charge Basis object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public with sharing class GlUt_APIConstantsChargeBasis {
    
    // get the namespace prefix and prefix it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
	public static String NAMEAPINAME   				= 'Name';
    public static String OBJECTAPINAME 				= NAMESPACEPREFIX + 'ChargeBasis__c';    
    public static String AMOUNTAPINAME   			= NAMESPACEPREFIX + 'Amount__c';
    public static String AVAILABLESERVICEAPINAME   	= NAMESPACEPREFIX + 'AvailableService__c';
    public static String STARTDATEAPINAME   		= NAMESPACEPREFIX + 'StartDate__c';
    public static String ENDDATEAPINAME   			= NAMESPACEPREFIX + 'EndDate__c';
    public static String TYPEAPINAME   			    = NAMESPACEPREFIX + 'Type__c';    
}