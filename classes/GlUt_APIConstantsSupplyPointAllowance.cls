/******************************************************************************
@author         Echo: Mohit Tayal
@date           05 July 2018
@description:   This is the constants class for all static fields used in 
				the Supply Point Allowance object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public with sharing class GlUt_APIConstantsSupplyPointAllowance {

    // get the namespace prefix and prefix it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String SUPPLYPOINTALLOWANCEAPINAME = NAMESPACEPREFIX + 'SupplyPointAllowance__c';
}