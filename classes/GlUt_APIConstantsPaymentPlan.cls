/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           01-Mar-2018
@description:   This is the constants class for all static fields used in the payment plan object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
@Revisions - 19-Apr-2018 Tarun , AT-2266 , Removed End Date reference.
**************************************************************************************************************/

public class GlUt_APIConstantsPaymentPlan {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Payment Object API Name
    public static String  PAYMENTPLANAPINAME = NAMESPACEPREFIX + 'PaymentPlan__c';
    
    // Payment Plan Object Fields Relational API Names
    public static String PAYMENTPLANRELAPINAME		= NAMESPACEPREFIX + 'PaymentPlan__r';
    public static String CONTRACTORDERRELAPINAME	= NAMESPACEPREFIX + 'BillingContract__r';//AT-3174
    
    
    // Payment object fields API Names
	public static String  NAMEAPINAME 					= 'Name';
    public static String  PAYMENTPLANSTARTDATEAPINAME 	= NAMESPACEPREFIX + 'StartDate__c';
    //public static String  PAYMENTPLANENDDATEAPINAME 	= NAMESPACEPREFIX + 'EndDate__c';
    public static String  CONTRACTORDERAPINAME 			= NAMESPACEPREFIX + 'BillingContract__c'; //AT-3174
    public static String  ACTIVEAPINAME 				= NAMESPACEPREFIX + 'Active__c'; 
    
    public static String  PAYMENTPLANTOTALAPINAME 		= NAMESPACEPREFIX + 'PaymentPlanTotal__c'; 
    public static String  FORECASTAMOUNTAPINAME 		= NAMESPACEPREFIX + 'ForecastAmount__c'; 	//	Sudhir: AT-2199 - Mar 03
    
    public static String  PAYMENTPLANTYPEAPINAME 		= NAMESPACEPREFIX + 'PaymentPlanType__c'; 	//	Tarun: AT-2449 - June 04
    public static String  CANCELLEDDATEAPINAME 		= NAMESPACEPREFIX + 'AutoCancelledDate__c'; 	
    public static String  PAYMENTPLANENDDATELABEL 		= NAMESPACEPREFIX + 'EndDate__c'; 	

}