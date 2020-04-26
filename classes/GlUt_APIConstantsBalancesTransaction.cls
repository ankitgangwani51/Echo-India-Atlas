/************************************************************************************************************
@author         Echo : Dependra Singh
@date           12-Feb-2018
@description:   This is the constants class for all static fields used in the Balance Transaction object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBalancesTransaction {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Balance Transaction Object API Name
    public static String  BALANCETRANSACTIONAPINAME = NAMESPACEPREFIX + 'BalanceTransaction__c';
    
    // Balance Transaction object fields API Names
    public static String  AMOUNTAPINAME       = NAMESPACEPREFIX + 'Amount__c';
    public static String  BALANCEAPINAME      = NAMESPACEPREFIX + 'Balance__c';
    public static String  PAYMENTAPINAME      = NAMESPACEPREFIX + 'Payment__c';
    public static String  RECORDTYPEAPINAME   = 'RecordTypeId';

}