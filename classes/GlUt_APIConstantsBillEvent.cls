/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           31-May-2018
@description:   This is the constants class for all static fields used in the bill event  object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBillEvent {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bill Event Object API Name
    public static String BILLEVENTAPINAME = NAMESPACEPREFIX + 'BillEvent__c';
    
    // BillEvent Object Rel API Name
    public static final String BILLEVENTRELAPINAME = NAMESPACEPREFIX + 'BillEvent__r';		// Sudhir
    
    // Bill Event object fields API Names
	public static String BILLINGCONTRACTAPINAME	= NAMESPACEPREFIX + 'BillingContract__c'; 
    public static final String EVENT_TYPE = NAMESPACEPREFIX + 'EventType__c';
    public static final String STATUS = NAMESPACEPREFIX + 'Status__c'; 
    
    // Bill Event object Constants API Names 
    // ******  DO NOT ADD NAMESPACEPREFIX FOR CONSTANTS ******
    
    public static String PAYMENTPLANBILLEVENTTYPE	= 'Payment Plan Change'; 
    public static String PENDINGBILLEVENTSTATUS	= 'Pending'; 
    public static String PROCESSEDBILLEVENTSTATUS	= 'Processed'; 
    public static String NORMALBILLEVENTSTATUS		= 'Normal'; 	// Sudhir

}