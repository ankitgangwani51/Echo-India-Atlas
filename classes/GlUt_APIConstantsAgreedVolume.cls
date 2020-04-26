/******************************************************************************
@author         Echo: Patrick Dixon
@date           16 Mar 2018
@description:   This is the constants class for all static fields used in 
				the Agreed Volume object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public with sharing class GlUt_APIConstantsAgreedVolume {
    
    // get the namespace prefix and prefix it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String OBJECTAPINAME = NAMESPACEPREFIX + 'AgreedVolume__c';
    
}