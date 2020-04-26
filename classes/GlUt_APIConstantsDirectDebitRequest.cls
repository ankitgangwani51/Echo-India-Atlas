/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           01 Feb 2019
@description:   This is the constants class for all static fields used in the Direct Debit Request object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsDirectDebitRequest {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Direct Debit Request Object API Name
    public static String  DIRECTDEBITREQUESTAPINAME = NAMESPACEPREFIX + 'DirectDebitRequest__c';
    
    // Direct Debit Request Fields API Name
    public static String STATUSAPINMAE 						= NAMESPACEPREFIX + 'Status__c';
    public static String CREATEDDATEAPINAME 				= 'CreatedDate';
    public static String FIRSTREQUESTBANKACCOUNTAPINAME 	= NAMESPACEPREFIX + 'FirstRequestForBankAccount__c';
    public static String TRANSACTIONCODEAPINAME 			= NAMESPACEPREFIX + 'TransactionCode__c';
    public static String BANKACCOUNTDETAILSSORTCODEAPINAME  = NAMESPACEPREFIX + 'BankAccountDetails__r' + '.' + NAMESPACEPREFIX + 'BankAccountSortCode__c';
    public static String BANKACCOUNTDETAILSBANKACCOUNTNUMBERAPINAME = NAMESPACEPREFIX + 'BankAccountDetails__r' + '.' + NAMESPACEPREFIX + 'BankAccountNumber__c';    
    public static String INSTALMENTINSTALMENTAMOUNTDUEAPINAME      = NAMESPACEPREFIX + 'Instalment__r' + '.' + NAMESPACEPREFIX + 'InstalmentAmountDue__c';    
    public static String BANKACCOUNTDETAILSNAMEAPINAME			    = NAMESPACEPREFIX + 'BankAccountDetails__r' + '.' + 'Name';
    public static String BANKACCOUNTDETAILSACCOUNTNAMEAPINAME		= NAMESPACEPREFIX + 'BankAccountDetails__r' + '.' + NAMESPACEPREFIX + 'Account__r' + '.' + 'Name';            
}