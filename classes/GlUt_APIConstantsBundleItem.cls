/************************************************************************************************************
@author         Echo : Mohit
@date           05-Feb-2018
@description:   This is the constants class for all static fields used in the BundleItem object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBundleItem {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
   
    public static String BUNDLEITEMAPINAME = NAMESPACEPREFIX + 'BundleItem__c';
    
    // AvailableService object fields API Names
    public static String NAMEAPINAME 				= 'Name';
    public static String BUNDLEAPINAME 				= NAMESPACEPREFIX + 'Bundle__c';
    public static String SERVICEITEMTYPEAPINAME 	= NAMESPACEPREFIX + 'ServiceItemType__c';
    public static String SERVICEITEMFAMILYAPINAME 	= NAMESPACEPREFIX + 'ServiceItemFamily__c';
}