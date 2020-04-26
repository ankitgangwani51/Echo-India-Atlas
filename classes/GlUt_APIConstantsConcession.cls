/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           28 Nov 2018
@description:   This is the constants class for all static fields used in the Concession object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsConcession {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Instalment Object API Name
    public static String  CONCESSIONAPINAME = NAMESPACEPREFIX + 'Concession__c';
    
    // Instalment object fields API Names
	public static String PRIMARYACCOUNTAPINAME		= NAMESPACEPREFIX + 'Account__c';
    public static String CONSENTDATEAPINAME			= NAMESPACEPREFIX + 'ConsentDate__c';
    public static String NONPRIMARYACCOUNTAPINAME   = NAMESPACEPREFIX + 'NonPrimaryAccount__c';
    public static String TYPEAPINAME 				= NAMESPACEPREFIX + 'Type__c';
    public static String VALIDATEDAPINAME	 		= NAMESPACEPREFIX + 'Validated__c'; 
    public static String CRNAPINAME					= NAMESPACEPREFIX + 'CRN__c'; 
    public static String CONFIRMDATEAPINAME			= NAMESPACEPREFIX + 'ConfirmDate__c'; 
    
}