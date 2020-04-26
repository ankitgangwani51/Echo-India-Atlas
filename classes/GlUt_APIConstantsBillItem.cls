/************************************************************************************************************
@author         Echo : Gopal Gupta
@date           31-Jan-2018
@description:   This is the constants class for all static fields used in the bill item object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBillItem {

    // Get the prefix and append it to the object and fields api names
    public static final String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bill Item Object API Name
    public static final String  BILLITEMAPINAME = NAMESPACEPREFIX + 'BillItem__c';
    
    // Bill Item object fields API Names
    public static final String BILLITEMNAME = 'Name';
    public static final String SERVICEITEMAPINAME = NAMESPACEPREFIX + 'ServiceItem__c';
    public static final String BILLEDAMOUNTAPINAME = NAMESPACEPREFIX + 'BilledAmount__c';
    public static final String BILLAPINAME = NAMESPACEPREFIX + 'Bill__c';
    public static final String READINGAPINAME = NAMESPACEPREFIX + 'Reading__c';
    public static final String BILLSERVICETYPEAPINAME = NAMESPACEPREFIX + 'BillServiceType__c';
    public static final String BILLITEMFROM = NAMESPACEPREFIX + 'StartDate__c';
    public static final String BILLITEMTO = NAMESPACEPREFIX + 'EndDate__c';
    public static final String SERVICEITEMTYPENAME = NAMESPACEPREFIX + 'ServiceItemTypeName__c';
}