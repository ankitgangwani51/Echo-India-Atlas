/************************************************************************************************************
@author         Echo : Amit K.
@date           20-Feb-2018
@description:   This is the constants class for all static fields used in the Payment Association object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsPaymentAssociation {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Payment Association Object API Name
    public static final String PAYMENTASSOCIATIONAPINAME = NAMESPACEPREFIX + 'PaymentAssociation__c';
    
    // Payment Association object fields API Names
    public static final String ORIGINALPAYMENTAPINAME 			= NAMESPACEPREFIX + 'OriginalPayment__c';
    public static final String TRANSFERREDFUNDEDPAYMENTAPINAME 	= NAMESPACEPREFIX + 'TransferredRefundedPayment__c';
    
}