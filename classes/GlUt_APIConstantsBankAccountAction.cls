/************************************************************************************************************
@author         Echo : Amit K.
@date           22-June-2018
@description:   This is the constants class for all static fields used in the Bank Account Action object                
**************************************************************************************************************/
public class GlUt_APIConstantsBankAccountAction {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bank Account Action Object API Name
    public static String  BANKACCOUNTACTIONAPINAME = NAMESPACEPREFIX + 'BankAccountAction__c';
    
    // Bank Account Action object fields API Names
    public static String  STATUSAPINAME = NAMESPACEPREFIX + 'Status__c';
    public static String  ACTIONAPINAME = NAMESPACEPREFIX + 'Action__c';
    public static String  PARAMETERAPINAME = NAMESPACEPREFIX + 'Parameters__c';
    public static String  BILLINGCONTRACTRELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.' + NAMESPACEPREFIX + 'BillingContract__c';
    public static String  BANKSORTCODERELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.' + NAMESPACEPREFIX +'BankAccountSortCode__c';
    public static String  NAMEONACCOUNTRELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.' + NAMESPACEPREFIX +'NameOnAccount__c';
    public static String  BANKACCOUNTNUMBERRELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.'+ NAMESPACEPREFIX +'BankAccountNumber__c';
    public static String  CUSTOMERNAMERELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.'+ NAMESPACEPREFIX + 'BillingContract__r.' + NAMESPACEPREFIX + 'AccountName__c';
    public static String  BANKACCOUNTCHANGEAPINAME = NAMESPACEPREFIX + 'BankAccountChange__c';
    public static String  BANKACCOUNTDETAILSRELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.' + NAMESPACEPREFIX + 'BankAccountDetails__c';
    public static String  DIRECTDEBITRETURNAPINAME = NAMESPACEPREFIX + 'DirectDebitReturn__c';
    public static String  DIRECTDEBITREQUESTRELAPINAME = NAMESPACEPREFIX + 'DirectDebitReturn__r.' + NAMESPACEPREFIX +'DirectDebitRequest__c';
    public static String  PAYMENTRELAPINAME = NAMESPACEPREFIX + 'DirectDebitReturn__r.' + NAMESPACEPREFIX +'Payment__c';
    public static String  DIRECTDEBITRETURNCONTRACTRELAPINAME = NAMESPACEPREFIX + 'DirectDebitReturn__r.' + NAMESPACEPREFIX +'BillingContract__c';
    public static String  DIRECTDEBITRETURNCONTRACTBALANCERELAPINAME = NAMESPACEPREFIX + 'DirectDebitReturn__r.' + NAMESPACEPREFIX +'BillingContract__r.' + NAMESPACEPREFIX +'ContractBalance__c';
    public static String  BANKACCOUNTCHANGECONTRACTBALANCERELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.' + NAMESPACEPREFIX +'BillingContract__r.' + NAMESPACEPREFIX +'ContractBalance__c';
    public static String  DIRECTDEBITRETURNCONTRACTCUSTOMERNAMERELAPINAME = NAMESPACEPREFIX + 'DirectDebitReturn__r.' + NAMESPACEPREFIX +'BillingContract__r.' + NAMESPACEPREFIX +'AccountName__c';
    public static String  ACCOUNTNAMERELAPINAME = NAMESPACEPREFIX + 'BankAccountChange__r.'+ NAMESPACEPREFIX + 'BillingContract__r.' + NAMESPACEPREFIX + 'AccountName__r.Name'; //AT-3124 starts/Ends here
}