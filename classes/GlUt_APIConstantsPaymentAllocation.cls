/************************************************************************************************************
@author         Echo : Gopal Gupta
@date           31-Jan-2018
@description:   This is the constants class for all static fields used in the payment allocation object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsPaymentAllocation {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Payment Allocation Object API Name
    public static String  PAYMENTALLOCATIONAPINAME = NAMESPACEPREFIX + 'PaymentAllocation__c';
    
    // Payment Allocation object fields API Names
	public static String  NAMEAPINAME 				= 'Name';
    public static String  PAYMENTAPINAME 			= NAMESPACEPREFIX + 'Payment__c';
    public static String  AMOUNTALLOCATEDAPINAME 	= NAMESPACEPREFIX + 'AmountAllocated__c';
    public static String  STATUSAPINAME 			= NAMESPACEPREFIX + 'Status__c';
    public static String  BILLITEMAPINAME 			= NAMESPACEPREFIX + 'BillItem__c';
}