/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           07-Mar-2018
@description:   This is the constants class for all static fields used in the service  object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsService {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Service Object API Name
    public static String  SERVICEAPINAME = NAMESPACEPREFIX + 'Service__c';
    
    // Service Object Relation API Name
    public static String  SERVICERELAPINAME = NAMESPACEPREFIX + 'Service__r';
    
    // Service object fields API Names
    public static String NAMEAPINAME				= 'Name';
	public static String SERVICECONTRACTAPINAME		= NAMESPACEPREFIX + 'BillingContract__c';
    public static String SUPPLYPOINTAPINAME			= NAMESPACEPREFIX + 'SupplyPoint__c';   // modified in AT-3852
    public static String SERVICESTARTDATEAPINAME 	= NAMESPACEPREFIX + 'ServiceStartDate__c';
    public static String SERVICEENDDATEAPINAME 		= NAMESPACEPREFIX + 'ServiceEndDate__c';
    public static String SERVICETYPEAPINAME 		= NAMESPACEPREFIX + 'ServiceType__c';
    public static String DISCHARGEAGREEMENTAPINAME 	= NAMESPACEPREFIX + 'DischargeAgreement__c';
    public static String OCCUPANCYTYPEAPINAME		= NAMESPACEPREFIX + 'OccupancyType__c';
}