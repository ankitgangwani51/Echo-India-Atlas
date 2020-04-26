/************************************************************************************************************
@author         Echo : Dependra Singh
@date           7 Mar 2018
@description:   This is the constants class for all static fields used in the Available Bundle Object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsAvailableBundle {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String  AVAILABLEBUNDLEAPINAME = NAMESPACEPREFIX + 'AvailableBundle__c';
    
    // AvailableService object fields API Names
    public static String NAMEAPINAME                = 'Name';
    public static String BUNDLENAMEAPINAME          = NAMESPACEPREFIX + 'BundleName__c';
    public static String BUNDLEAPINAME              = NAMESPACEPREFIX + 'Bundle__c';
    public static String AVAILABLESERVICEAPINAME    = NAMESPACEPREFIX + 'AvailableService__c';
    public static String DEFAULTAPINAME             = NAMESPACEPREFIX + 'Default__c';
    public static String LASTBUNDLECHANGEDATEAPINAME = NAMESPACEPREFIX + 'LastBundleChangeDate__c';
    public static String TARIFFLIMITAPINAME = NAMESPACEPREFIX + 'TariffLimit__c';
}