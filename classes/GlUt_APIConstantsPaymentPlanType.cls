/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           29-Jan-2018
@description:   This is the constants class for all static fields used in the Contract object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsPaymentPlanType {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Payment Plan Type Object API Name
    public static String  PAYMENTPLANTYPEAPINAME = NAMESPACEPREFIX + 'PaymentPlanType__c';
    
    // Payment Plan Type object fields API Names
    public static String  RESETDEBTRECAPINAME 		= NAMESPACEPREFIX + 'ResetDebtRecovery__c';
    public static String  NAMEAPINAME 				= 'Name';
    public static String  PLANTYPEAPINAME 			= NAMESPACEPREFIX + 'PlanType__c';
    public static String  PAYMENTFREQAPINAME 		= NAMESPACEPREFIX + 'PaymentFrequency__c';
    public static String  MAXNUMINSTALAPINAME 		= NAMESPACEPREFIX + 'MaximumNumberOfInstalments__c';
    public static String  ELIGIBLEPAYMETHODAPINAME 	= NAMESPACEPREFIX + 'EligiblePaymentMethod__c';
    public static String  FINALPAYMENTPLANAPINAME 	= NAMESPACEPREFIX + 'FinalPaymentPlan__c';
    public static String  DAYSNOTICEAPINAME 		= NAMESPACEPREFIX + 'DaysNotice__c';
    public static String  DEBTRECPROFILEAPINAME 	= NAMESPACEPREFIX + 'DebtRecoveryProfile__c';
    public static String  NUMOFROLLINGINSTALAPINAME = NAMESPACEPREFIX + 'NumberofRollingInstalments__c';
    public static String  SPECIALAPINAME			= NAMESPACEPREFIX + 'Special__c';
    
    // 09-Mar-2018 Added for a new req AT-2006
    public static String  UNMEASUREDAPINAME 		= NAMESPACEPREFIX + 'Unmeasured__c';
    
                                                      	 	  
}