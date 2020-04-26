/************************************************************************************************************
@author         Echo : Gopal Gupta
@date           31-Jan-2018
@description:   This is the constants class for all static fields used in the service item object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsServiceItem {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Service Item Object API Name
    public static String  SERVICEITEMAPINAME = NAMESPACEPREFIX + 'ServiceItem__c';
    
    // Service Item object fields API Names
    public static String  LOCATIONAPINAME           = NAMESPACEPREFIX + 'Location__c';
    public static String  SUPPLYPOINTAPINAME        = NAMESPACEPREFIX + 'Supply_Point__c';
    public static String  SERVICETYPEAPINAME        = NAMESPACEPREFIX + 'ServiceType__c';
    public static String  SERVICEITEMTYPEAPINAME    = NAMESPACEPREFIX + 'ServiceItemType__c';
    public static String  SERVICEAPINAME            = NAMESPACEPREFIX + 'Service__c';
    public static String  STARTDATEAPINAME          = NAMESPACEPREFIX + 'StartDate__c';
    public static String  ENDDATE                   = NAMESPACEPREFIX + 'EndDate__c';
    public static String  AVAILABLESERVICEITEMAPINAME = NAMESPACEPREFIX + 'AvailableServiceItem__c';
    
    public static String  AMENDEDBYSERVICEITEMAPINAME = NAMESPACEPREFIX + 'AmendedByServiceItem__c';
    public static String  DISCHARGEAGREEMENTAPINAME = NAMESPACEPREFIX + 'DischargeAgreement__c';
    public static String  QUANTITYAPINAME = NAMESPACEPREFIX + 'Quantity__c';
    
    public static String  ENDEDAPINAME = NAMESPACEPREFIX + 'Ended__c';
    
    public static String  SERVICECONTRACTREFAPINAME = NAMESPACEPREFIX + 'Service__r' + '.' + NAMESPACEPREFIX + 'BillingContract__c';
    public static String  SERVICESPLOCATIONREFAPINAME = NAMESPACEPREFIX + 'Service__r' + '.' + NAMESPACEPREFIX + 'Supplypoint__r' + '.' + NAMESPACEPREFIX + 'Location__c'; //AT-4038
    public static String  SERVICEITEMTYPETENANTREFAPINAME = NAMESPACEPREFIX + 'ServiceItemType__r' + '.' + NAMESPACEPREFIX + 'Tenant__c'; //AT-4038
    public static String  SERVICEITEMTYPEOWNERREFAPINAME = NAMESPACEPREFIX + 'ServiceItemType__r' + '.' + NAMESPACEPREFIX + 'Owner__c'; //AT-4025
    public static String  SERVICEOCCTYPEREFAPINAME = NAMESPACEPREFIX + 'Service__r' + '.' + NAMESPACEPREFIX + 'OccupancyType__c'; //AT-4025
    public static String  SERVICESPREFERENCAPINAME = NAMESPACEPREFIX + 'Service__r' + '.' + NAMESPACEPREFIX + 'Supplypoint__c'; //AT-4025
    
    // AT-4906 start...
    public static String  SERVICEITEMNOAPINAME     = 'Name';
    public static String  SUSPENDENDDATEAPINAME    = NAMESPACEPREFIX + 'SuspendEndDate__c';
    public static String  ENDDATERESUMEAPINAME     = NAMESPACEPREFIX + 'EndDateResume__c';   
    // AT-4906 end...
    
    

}