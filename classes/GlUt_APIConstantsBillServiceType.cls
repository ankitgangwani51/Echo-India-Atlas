/******************************************************************************
@author         Echo: Patrick Dixon
@date           02 May 2018
@description:   This is the constants class for all static fields used in 
        		the Bill Service Type object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public with sharing class GlUt_APIConstantsBillServiceType {
    
    // get the namespace prefix and prefix it to the object and fields api names
    private static final String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static final String OBJECTAPINAME = NAMESPACEPREFIX + 'BillServiceType__c';
    
    // object field API Names
    public static final String NAME = 'Name';
    public static final String BILLAPINAME = NAMESPACEPREFIX + 'Bill__c';
    public static final String SERVICETYPEAPINAME = NAMESPACEPREFIX + 'ServiceType__c';
}