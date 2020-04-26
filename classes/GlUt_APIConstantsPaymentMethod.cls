/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           29-Jan-2018
@description:   This is the constants class for all static fields used in the payment method type object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsPaymentMethod {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Payment Object API Name
    public static String  PAYMENTMETHODAPINAME = NAMESPACEPREFIX + 'PaymentMethod__c';
    
    // Payment object fields API Names
	public static String  NAMEAPINAME 			= 'Name';
    public static String  PAYMETHODTYPEAPINAME 	= NAMESPACEPREFIX + 'PaymentMethodType__c';
    public static String  PAYPLANTYPEAPINAME 	= NAMESPACEPREFIX + 'PaymentPlanType__c';
}