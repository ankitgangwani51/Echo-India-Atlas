/************************************************************************************************************
@author         Echo : Amit K.
@date           02-July-2018
@description:   This is the constants class for all static fields used in the Bank Account Change object                
**************************************************************************************************************/
public class GlUt_APIConstantsBankAccountChange {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bank Account Change Object API Name
    public static String  BANKACCOUNTCHANGEAPINAME = NAMESPACEPREFIX + 'BankAccountChange__c';
    
     // Bank Account Change object fields API Names
    public static String  STATUSAPINAME = NAMESPACEPREFIX + 'Status__c';

}