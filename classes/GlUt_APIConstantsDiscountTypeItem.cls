/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           08-Mar-2018
@description:   This is the constants class for all static fields used in the Discount type item object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsDiscountTypeItem {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Discount relaeted objects API Name
    public static String  DISCOUNTTYPEITEMAPINAME 		= NAMESPACEPREFIX + 'DiscountTypeitem__c';
    public static String  SERVICEITEMTYPEAPINAME 		= NAMESPACEPREFIX + 'ServiceItemType__c';
}