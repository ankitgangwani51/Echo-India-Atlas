/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           17 July 2018
@description:   This is the constants class for all static fields used in the Stepped Tariff type object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsSteppedTariff {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Stepped Tariff relaeted objects API Name
    public static String  STEPPEDTARIFFAPINAME = NAMESPACEPREFIX + 'SteppedTariff__c';
    
    // Stepped Tariff related object fields API Names	
    public static final String STARTDATEAPINAME	= NAMESPACEPREFIX + 'StartDate__c'; 
    public static final String ENDDATEAPINAME	= NAMESPACEPREFIX + 'EndDate__c';
    public static final string  RENEWALMONTHAPINAME	= NAMESPACEPREFIX + 'RenewalMonths__c';
    public static final string  SERVICETYPEAPINAME	= NAMESPACEPREFIX + 'ServiceType__c';
    public static final string  BILLINGCONTRACTAPINAME	= NAMESPACEPREFIX + 'BillingContract__c';
    public static final string RENEWALSTEPPEDTARIFFAPINAME	= NAMESPACEPREFIX + 'RenewalSteppedTariff__c';
}