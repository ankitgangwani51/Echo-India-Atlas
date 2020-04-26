/************************************************************************************************************
@author         Echo : Dependra Singh
@date           20-mar-2018
@description:   This is the constants class for all static fields used in the Financial ControlTotal object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsFinancialControlTotal {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Financial Control Total Object API Name
    public static String  FINANCIALCONTROLAPINAME = NAMESPACEPREFIX + 'FinancialControlTotal__c';
    
    // Account object fields API Names
    public static String  DAILYRECORDAPINAME = NAMESPACEPREFIX + 'DailyRecord__c';
    
    public static String  EFFECTIVEACTUALAPINAME = NAMESPACEPREFIX + 'EffectiveActual__c';
    public static String  BILLINGFREQUENCYAPINAME = NAMESPACEPREFIX + 'BillingFrequency__c';
    public static String  SERVICEITEMTYPEAPINAME = NAMESPACEPREFIX + 'ServiceItemType__c';
    public static String  FINANCIALTRANSEVENTAPINAME = NAMESPACEPREFIX + 'FinancialTransactionEvent__c';
    public static String  PERIODIDAPINAME = NAMESPACEPREFIX + 'Period_Id__c';
    public static String  FINANCIALYEARAPINAME = NAMESPACEPREFIX + 'FinancialYear__c';
    public static String  FINANCIALPERIODAPINAME = NAMESPACEPREFIX + 'FinancialPeriod__c';
    public static String  TOTALAMOUNTAPINAME = NAMESPACEPREFIX + 'TotalAmount__c';
    public static String  TOTALDISCOUNTAPINAME = NAMESPACEPREFIX + 'TotalDiscount__c';
    public static String  TOTALTAXAPINAME = NAMESPACEPREFIX + 'TotalTax__c';
    public static String  VOIDAPINAME = NAMESPACEPREFIX + 'Void__c';
    
    //NAME SPACE SUFFIX NOT REQUIRED FOR THE BELOW , AS THESE ARE USED FOR MAP
    public static String  EFFECTIVENOTDAILY = 'Effective-false';
    public static String  EFFECTIVEDAILY = 'Effective-true';
    public static String  ACTUALNOTDAILY = 'Actual-false';
    public static String  ACTUALDAILY = 'Actual-true';
    public static String  EFFECTIVE = 'Effective';
    public static String  ACTUAL = 'Actual';
}