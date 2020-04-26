/******************************************************************************
@author         Echo: Neha R.
@date           29 Oct 2018
@description:   This is the constants class for all static fields used in 
				the Message object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public with sharing class GlUt_APIConstantsMessage {
    
	// get the namespace prefix and prefix it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String OBJECTAPINAME = NAMESPACEPREFIX + 'Message__c';
    
    public static String NAMEAPINAME        = 'Name';
    public static String DESCRIPTIONAPINAME = NAMESPACEPREFIX + 'Description__c';
    public static String TYPEAPINAME        = NAMESPACEPREFIX + 'Type__c';
    public static String ACTIVEAPINAME      = NAMESPACEPREFIX + 'Active__c';
    public static String SELECTABLEAPINAME  = NAMESPACEPREFIX + 'Selectable__c';
    public static String DEFAULTAPINAME     = NAMESPACEPREFIX + 'Default__c';
    
}