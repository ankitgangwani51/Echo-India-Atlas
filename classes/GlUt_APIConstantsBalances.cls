/************************************************************************************************************
@author         Echo : Dependra Singh
@date           12-Feb-2018
@description:   This is the constants class for all static fields used in the Balance object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBalances {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Balance Object API Name
    public static String  BALANCEAPINAME = NAMESPACEPREFIX + 'Balance__c';
    
    // Balance Object Rel API Name
    public static final String BALANCERELAPINAME = NAMESPACEPREFIX + 'Balance__r';
    
    // Balance object fields API Names
    public static String  TOTALREFUNDAMOUNTAPINAME 	= NAMESPACEPREFIX + 'TotalRefundAmount__c';
    public static String  BALANCEAMOUNTAPINAME   	= NAMESPACEPREFIX + 'Balance__c';
    public static String  BALANCESNAPSHOTAPINAME   	= NAMESPACEPREFIX + 'BalanceSnapshot__c';
    public static String  ACCOUNTAPINAME   	= NAMESPACEPREFIX + 'Account__c';
    
}