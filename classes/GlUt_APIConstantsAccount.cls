/******************************************************************************
@author         Echo: 
@date           
@description:   This is the constants class for all static fields used in 
				the Account object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public class GlUt_APIConstantsAccount {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    // Account
    public static String ACCOUNTAPINAME			= 'Account' ;
    
    // Account object fields API Names
    public static String BIRTHDATEAPINAME 						= NAMESPACEPREFIX + 'DateofBirth__c'; //Swati- 30/072018 -- Made changes as the field name has been changed 
    public static String CONSIDERATIONPASSWORDAPINAME 	= NAMESPACEPREFIX + 'ConsiderationPassword__c';
    public static String RECORD_TYPE_ID 				= 'RecordTypeId' ;
    public static String RECORD_TYPE 					= 'RecordType' ;
    public static String ACCOUNTNAMEAPINAME				=	'Name' ;
    public static String ACCOUNTNUMBERAPINAME			=	'AccountNumber' ;
    public static String ACCOUNTREFERENCEAPINAME		=	NAMESPACEPREFIX + 'AccountReference__c' ;
    public static String ACCOUNTSOURCEAPINAME			=	'AccountSource' ;
    public static String ACCOUNTBILLINGADDRESSAPINAME	=	'BillingAddress' ;
    public static String NUMEMPLOYEEAPINAME		=	'NumberOfEmployees' ;
    public static String STATUSAPINAME		=	NAMESPACEPREFIX + 'Status__c' ;
    public static String TOTALBILLITEMAMOUNTAPINAME		=	NAMESPACEPREFIX + 'TotalBillItemAmount__c' ;
    public static String TOTALPAYMENTAMOUNTAPINAME		=	NAMESPACEPREFIX + 'TotalPaymentAmount__c' ;
    public static String TOTALREFUNDAMOUNTAPINAME		=	NAMESPACEPREFIX + 'TotalRefundAmount__c' ;
    public static String TOTALRETURNTRANSFERAMOUNTAPINAME		=	NAMESPACEPREFIX + 'TotalReturnTransferAmount__c' ;
    public static String TYPEAPINAME		=	'Type' ;
    public static String SUPPRESSEDAPINAME		=	NAMESPACEPREFIX + 'Suppressed__c' ;
    public static String RATINGAPINAME		=	'Rating' ;
    public static String BALANCEAPINAME		=	NAMESPACEPREFIX + 'Balance__c' ;  
    public static String SHIPPINGADDRESSAPINAME		=	'ShippingAddress' ;
    public static String MOBILEAPINAME		=	NAMESPACEPREFIX + 'Mobile__c' ;
    public static String PREFERREDCONTACTMETHODAPINAME		=	NAMESPACEPREFIX + 'PreferredContactMethod__c' ;
    public static String PHONEAPINAME		=	'Phone' ;
    public static String MAILOPTOUTAPINAME		=	NAMESPACEPREFIX + 'MailOptOut__c';
    public static String EMAILAPINAME		=	NAMESPACEPREFIX + 'Email__c';
    public static String HASCONSIDERATIONAPINAME		=	NAMESPACEPREFIX + 'HasConsideration__c';
    public static String NUMBEROFCONSIDERATIONSAPINAME		=	NAMESPACEPREFIX + 'NumberofConsiderations__c';
    public static String NOMINEEAPINAME		=	NAMESPACEPREFIX + 'Nominee__c';
    //public static String SOCIALRATEAPINAME		=	NAMESPACEPREFIX + 'SocialRate__c';
    public static String NOMINEECONTACTDETAILSAPINAME		=	NAMESPACEPREFIX + 'NomineeContactDetails__c';
    public static String PARENTIDAPINAME		=	'ParentId';
    public static String KEYACCOUNTAPINAME		=	NAMESPACEPREFIX + 'Key_Account__c';
    public static String KEYACCOUNTMANAGERAPINAME		=	NAMESPACEPREFIX + 'KeyAccountManager__c';
    public static String RECEIVEBILLAPINAME		=	NAMESPACEPREFIX + 'ReceiveBill__c';
    
    public static final String BILLINGSTREETAPINAME 		= 'BillingStreet';
    public static final String BILLINGCITYAPINAME 			= 'BillingCity';
    public static final String BILLINGSTATEAPINAME 			= 'BillingState';
    public static final String BILLINGPOSTALCODEAPINAME 	= 'BillingPostalCode';
    public static final String BILLINGCOUNTRYAPINAME 		= 'BillingCountry';
    public static final String NFPAPINAME 					= NAMESPACEPREFIX +  'NFP__c';   //AT-4383     
    
    public static final String ACCSHIPSTREET       = 'ShippingStreet';
    public static final String ACCSHIPSTATE        = 'ShippingState';
    public static final String ACCSHIPCITY         = 'ShippingCity';
    public static final String ACCSHIPCOUNTRY      = 'ShippingCountry';
    public static final String ACCSHIPZIP          = 'ShippingPostalCode';    
    
    public static final String AUDPIDAPINAME          = 'AuDpid__c';    //AT-4858
}