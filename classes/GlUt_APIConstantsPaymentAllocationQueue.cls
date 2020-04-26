/************************************************************************************************************
@author         Echo : Amit K.
@date           07-Aug-2018
@description:   This is the constants class for all static fields used in the payment allocation queue object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsPaymentAllocationQueue {
     // Get the prefix and append it to the object and fields api names
    public static final String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Payment Allocation Queue Object API Name
    public static final String PAYMENTALLOCATIONQUEUEAPINAME = NAMESPACEPREFIX + 'PaymentAllocationQueue__c';
    
    // Payment Allocation Queue Object fields API Names
    public static final String  BILLITEMAPINAME = NAMESPACEPREFIX + 'BillItem__c';
    public static final String  STATUSAPINAME = NAMESPACEPREFIX + 'Status__c';

}