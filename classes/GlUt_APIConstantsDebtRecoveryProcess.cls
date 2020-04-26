/************************************************************************************************************
@author         Echo : Mohit Tayal
@date           31-JAN-2018
@description:   This is the constants class for all static fields used in the debt recovery process object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsDebtRecoveryProcess {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();

    // DebtRecoveryProcess Object API Name
    public static String DEBTRECOVERYPROCESSAPINAME = NAMESPACEPREFIX + 'DebtRecoveryProcess__c';
    
    // Debt Recovery process object fields API Names - Added TG - 09-Feb-2018 , Set Up Payment Plans
	public static String  CURRENTSTAGEAPINAME 				= NAMESPACEPREFIX + 'CurrentStage__c';
    public static String  CURRENTSTAGEDATETIMEAPINAME		= NAMESPACEPREFIX + 'CurrentStageDateTime__c';   
    public static String  EVALUATEFORDEBTRECOVERYAPINAME	= NAMESPACEPREFIX + 'EvaluateForDebtRecovery__c';
    public static String  PREDICTSTAGEAPINAME				= NAMESPACEPREFIX + 'PredictedStage__c';
    public static String  TOTALAMOUNTDUEAPINAME				= NAMESPACEPREFIX + 'TotalAmountDue__c';        
    public static String  PREDICTFORDEBTRECOVERYAPINAME 	= NAMESPACEPREFIX + 'PredictForDebtRecovery__c';
    public static String  DEBTRECOVERYPROFILEAPINAME 		= NAMESPACEPREFIX + 'DebtRecoveryProfile__c';
    public static String  DEBTRECOVERYINSTALMENTAPINAME     = NAMESPACEPREFIX + 'DebtRecoveryInstalment__c';
    public static String  CONTRACTAPINAME                   = NAMESPACEPREFIX + 'BillingContract__c'; 
    
}