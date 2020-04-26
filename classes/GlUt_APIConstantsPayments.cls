/************************************************************************************************************
@author         Echo : Gopal Gupta
@date           29-Jan-2018
@description:   This is the constants class for all static fields used in the payment object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsPayments {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Payment Object API Name
    public static String  PAYMENTAPINAME = NAMESPACEPREFIX + 'Payment__c';
    
    // Payment object fields API Names
	public static String  NAMEAPINAME 						= 'Name';
    public static String  PAYMENTDATEAPINAME 				= NAMESPACEPREFIX + 'PaymentDate__c';
    public static String  RECORDTYPEAPINAME					= 'RecordTypeId';
    public static String  PAYMENTMETHODAPINAME 				= NAMESPACEPREFIX + 'PaymentMethod__c';
    public static String  AMOUNTAPINAME 					= NAMESPACEPREFIX + 'Amount__c';
    public static String  BILLALLOCATIONSTATUSAPINAME 		= NAMESPACEPREFIX + 'BillAllocationStatus__c';
    public static String  INSTALMENTALLOCATIONSTATUSAPINAME = NAMESPACEPREFIX + 'InstalmentAllocationStatus__c';
    public static String  CONTRACTAPINAME 					= NAMESPACEPREFIX + 'BillingContract__c';
    public static String  LOCATIONAPINAME					= NAMESPACEPREFIX + 'Location__c';
    public static String  ACCOUNTAPINAME 					= NAMESPACEPREFIX + 'Account__c';
    public static String  REVERSEDAMOUNTAPINAME 			= NAMESPACEPREFIX + 'ReversedAmount__c';
    public static String  AMENDMENTREASONAPINAME 			= NAMESPACEPREFIX + 'AmendmentReason__c';
    public static String  PAYMENTTRANSFERREASONAPINAME 		= NAMESPACEPREFIX + 'PaymentTransferReason__c';
    public static String  CREDITAMOUNTAPINAME 				= NAMESPACEPREFIX + 'CreditAmount__c';
    public static String  BILLAMTUNALLOCATEDAPINAME 		= NAMESPACEPREFIX + 'BillAmountUnallocated__c';
    public static String  INSTALAMTUNALLOCATEDAPINAME 		= NAMESPACEPREFIX + 'InstalmentAmountUnallocated__c';
    
    // 12 Feb 2018, Dependra Singh - Constants for PyAp_RefundTransferCreditPageCtrlr class
    public static string  REFUNDACCOUNTAPINAME       = NAMESPACEPREFIX + 'NameofRefundAccount__c';
    public static string  BANKACCSORTCODEAPINAME     = NAMESPACEPREFIX + 'BankAccountSortCode__c';
    public static string  BANKACCOUNTNOAPINAME       = NAMESPACEPREFIX + 'BankAccountNumber__c';
    public static string  REFUNDADDRESSAPINAME       = NAMESPACEPREFIX + 'RefundAddress__c';
    public static string  REFUNDREFRENCEAPINAME      = NAMESPACEPREFIX + 'RefundReference__c';
    public static string  CREDITAMOUNT               = NAMESPACEPREFIX + 'CreditAmount__c';
    public static String GOODWILLREASONAPINAME		 = NAMESPACEPREFIX + 'GoodwillReason__c' ;	// Sudhir: AT-2878(Core 7a)
    public static String REFUNDSTATUSAPINAME		 = NAMESPACEPREFIX + 'RefundStatus__c' ;
    public static String DONOTPRINT           		 = NAMESPACEPREFIX + 'DoNotPrint__c' ;    //AT-4897
    
    //Start - AT-4912. Ankit, 29/01/2018
    public static String REFUNDEXPORTSTATUSAPINAME   				= NAMESPACEPREFIX + 'RefundExportStatus__c'; 	
    public static String REFUNDAPPROVEDDATEAPINAME   				= NAMESPACEPREFIX + 'RefundApprovedDate__c'; 	
    public static String TRANSFERREDAPINAME		     				= NAMESPACEPREFIX + 'Transferred__c'; 			
    public static String BANKACCOUNTDETAILAPINAME    				= NAMESPACEPREFIX + 'BankAccountDetail__c'; 	
    public static String INVALIDSUSPENSEAPINAME    					= NAMESPACEPREFIX + 'InvalidSuspense__c';
    public static String BANKACCOUNTDETAILSBANKACCOUNTNUMBERAPINAME = NAMESPACEPREFIX + 'BankAccountDetail__r' + '.' + NAMESPACEPREFIX + 'BankAccountNumber__c';  
    public static String BANKACCOUNTDETAILSSORTCODEAPINAMEAPINAME  	= NAMESPACEPREFIX + 'BankAccountDetail__r' + '.' + NAMESPACEPREFIX + 'BankAccountSortCode__c';
    public static String BANKACCOUNTDETAILSNAMEAPINAME 				= NAMESPACEPREFIX + 'BankAccountDetail__r' + '.' + 'Name';
    public static String ACCOUNTNAMEAPINAME							= NAMESPACEPREFIX + 'Account__r' + '.' + 'Name';
    //End
    
}