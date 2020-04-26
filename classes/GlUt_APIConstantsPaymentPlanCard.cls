/************************************************************************************************************
@author         Echo : Swati Mathur
@date           22-Jun-2018
@description:   This is the constants class for all static fields used in the payment method type object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsPaymentPlanCard {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Payment Object API Name
    public static String  PAYMENTPLANCARDAPINAME = NAMESPACEPREFIX + 'PaymentPlanCard__c';
    
    // Payment object fields API Names
    public static String  PAYMENTPLANAPINAME 	= NAMESPACEPREFIX + 'PaymentPlan__c';
    public static String  REQUESTEDONAPINAME 	= NAMESPACEPREFIX + 'RequestedOn__c';
    
}