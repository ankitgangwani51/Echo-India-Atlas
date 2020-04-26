/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           29-Jan-2018
@description:   This is the constants class for all static fields used in the Contract object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsContracts {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Contract Object API Name
    public static String  CONTRACTAPINAME = NAMESPACEPREFIX + 'BillingContract__c';
    
    // Contract Object Rel API Name
    public static final String CONTRACTRELAPINAME = NAMESPACEPREFIX + 'BillingContract__r';
    
    // Contract object fields API Names
    public static String  CONTRACTNAMEAPINAME 	= 'Name';
    public static String  CONTRACTENDDATEAPINAME 	= NAMESPACEPREFIX + 'ContractEndDate__c';
    public static String  CONTRACTSTARTDATEAPINAME 	= NAMESPACEPREFIX + 'ContractStartDate__c';    
    public static String  ELIGIBLEFORBUDGETAPINAME 	= NAMESPACEPREFIX + 'EligibleforBudgetPlan__c';
    public static String  DAYOFMONTHAPINAME 		= NAMESPACEPREFIX + 'DayOfMonth__c';
    public static String  DAYOFWEEKAPINAME 			= NAMESPACEPREFIX + 'DayOfWeek__c';
    public static String  DEBTRECPROCESSAPINAME 	= NAMESPACEPREFIX + 'DebtRecoveryProcess__c';
    public static String  SUPPRESSEDAPINAME		 	= NAMESPACEPREFIX + 'Suppressed__c';    
    
    //12 Feb 2018 - Dependra Singh  Constants for CuAp_NewBillingAddressPageCtlr class, 
    //PyAp_CreRefundTransfWizardComponentCtrlr, PyAp_RefundTransferCreditPageCtrlr -
    public static final String BILLINGADDRESSAPINAME 		= NAMESPACEPREFIX + 'BillingAddress__c';
    public static final String BILLINGSTREETNAME 			= NAMESPACEPREFIX + 'BillingStreet__c';
    public static final String BILLINGCITYAPINAME 			= NAMESPACEPREFIX + 'BillingCity__c';
    public static final String BILLINGSTATEAPINAME 			= NAMESPACEPREFIX + 'BillingState__c';
    public static final String BILLINGPOSTALCODEAPINAME 	= NAMESPACEPREFIX + 'BillingPostalCode__c';
    public static final String BILLINGCOUNTRYAPINAME 		= NAMESPACEPREFIX + 'BillingCountry__c';
    public static final String STATUSAPINAME 				= NAMESPACEPREFIX + 'Status__c';
    public static final String HOUSEHOLDBILLINGAPINAME 		= NAMESPACEPREFIX + 'HouseholdBilling__c';
    public static final String CUSTOMERAPINAME 				= NAMESPACEPREFIX + 'AccountName__c';
    public static final String RELATED_ACCOUNT = NAMESPACEPREFIX + 'AccountName__r';
    public static final String RELATED_SERVICES = NAMESPACEPREFIX + 'Services__r';
    public static final String RELATED_BILL_EVENTS = NAMESPACEPREFIX + 'BillEvents__r';
    public static final String BALANCEAPINAME 				= NAMESPACEPREFIX + 'Balance__c';
    public static final String CURRENTPAYMENTPLANTYPE 		= NAMESPACEPREFIX + 'CurrentPaymentPlanType__c';
    public static final String PAYMENTMETHODTYPEAPINAME 	= NAMESPACEPREFIX + 'PaymentMethodType__c';
    public static final String DEBTRECPROFILEAPINAME 		= NAMESPACEPREFIX + 'DebtRecoveryProfile__c';
    public static final String PAYPLANRENEWALDATEAPINAME 	= NAMESPACEPREFIX + 'PaymentPlanRenewalDate__c';
    public static final String BILLING_FREQUENCY = NAMESPACEPREFIX + 'BillingFrequency__c';
    public static final String BILLING_METHOD = NAMESPACEPREFIX + 'BillingMethod__c';
    
    // 23 Feb 2018 - Neha Constants for 
    public static final String CURRENTDRPAPINAME = NAMESPACEPREFIX + 'CurrentDebtRecoveryProcess__c';
    
     // 01 Mar 2018 - Dependra 
    public static final String ENDDATEBACKGROUND 	= NAMESPACEPREFIX + 'ContractEndDateBackground__c';
    public static final String ENDDATE 				= NAMESPACEPREFIX + 'ContractEndDate__c';
    public static final String STARTDATE 			= NAMESPACEPREFIX + 'ContractStartDate__c';
    public static final String LAST_BILL_CALCULATION_DATE = NAMESPACEPREFIX + 'LastBillCalculationDate__c';

    //23 Feb 2018 - Vivek Sethi  Constants for GlUt_ContractUtilities , 
    public static final String CONTRACTGROUPAPINAME = NAMESPACEPREFIX + 'ContractGroup__c';

	public static final String CONTRACTBALANCEAPINAME = NAMESPACEPREFIX + 'ContractBalance__c';    

	public static final String STATUS_ACTIVE = 'Active';    
    
    // 02 July 2018 - AT-2935 
    public static final String BUDGETPLANONHOLDAPINAME = NAMESPACEPREFIX + 'BudgetPlanHold__c';
    public static final String ACCOUNTREFERENCEAPINAME = NAMESPACEPREFIX + 'AccountReference__c';
    
    public static final String USEALTERNATIVEADDRESSAPINAME = NAMESPACEPREFIX + 'UseAlternativeAddress__c';
    public static final String ALTERNATIVEBILLINGRELAPINAME = NAMESPACEPREFIX + 'AlternativeBilling__r';
    public static final String ALTERNATIVEBILLINGRELATIONSHIPAPINAME = NAMESPACEPREFIX + 'AlternativeBillingRelationship__c';
    public static final String ALTERNATIVEBILLINGNAMEAPINAME = NAMESPACEPREFIX + 'AlternativeBillingName__c	';
    
    //AT-5084, Ankit, 23/01/2018
    public static final String OWNEDBYAPINAME = NAMESPACEPREFIX + 'OwnedBy__c';
    
    // 29 Jan 2019 - AT-4858 
    public static final String BILLINGAUDPIDAPINAME = NAMESPACEPREFIX + 'BillingAuDpid__c';
    public static final String ALTERNATEAUDPIDAPINAME = NAMESPACEPREFIX + 'AlternativeAuDpid__c';
    
    // UL-21, Ankit, 21/02/2019
    public static final String HOLDENTIREBILLTOLERANCEAPINAME = NAMESPACEPREFIX + 'HoldEntireBillforToleranceFail__c';
    
}