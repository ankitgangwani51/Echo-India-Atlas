/******************************************************************************
@author         Echo: Neha R.
@date           29 Oct 2018
@description:   This is the constants class for all static fields used in 
				the Message object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public with sharing class GlUt_APIConstantsInfoStatementMessage{
    
	// get the namespace prefix and prefix it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String OBJECTAPINAME = NAMESPACEPREFIX + 'InformationStatementMessage__c';
    
    public static String NAMEAPINAME                 = 'Name';
    public static String ACTIVEAPINAME               = NAMESPACEPREFIX + 'Active__c';
    public static String DESCRIPTIONAPINAME          = NAMESPACEPREFIX + 'Description__c';
    public static String INFORMATIONSTATEMENTAPINAME = NAMESPACEPREFIX + 'InformationStatement__c';   
    public static String MESSAGEAPINAME              = NAMESPACEPREFIX + 'Message__c'; 
   
}