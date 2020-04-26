/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           23 July 2018
@description:   This is the constants class for all static fields used in the Stepped Tariff Service type object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsSteppedTariffService {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Stepped Tariff relaeted objects API Name
    public static String  STEPPEDTARIFFSERVICEAPINAME = NAMESPACEPREFIX + 'SteppedTariffService__c';
    
    // Stepped Tariff Service related object fields API Names	
    public static final String STARTDATEAPINAME	= NAMESPACEPREFIX + 'StartDate__c'; 
    public static final String ENDDATEAPINAME	= NAMESPACEPREFIX + 'EndDate__c';
    public static final String SERVICEAPINAME   = NAMESPACEPREFIX + 'Service__c';
    
       
}