/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           07-Mar-2018
@description:   This is the constants class for all static fields used in the Bill calculation object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/

public class GlUt_APIConstantsBillCalculation {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bill Calculation Object API Name
    public static String  BILLCALCULATIONAPINAME = NAMESPACEPREFIX + 'BillCalculation__c';
    
    // Bill Calculation object fields API Names
	public static String  NAMEAPINAME 	= 'Name';
    public static String  STATUSAPINAME = NAMESPACEPREFIX + 'Status__c';
    
    // Lookup fields
    public static String CONTRACT = NAMESPACEPREFIX + 'BillingContract__c';
    public static String TYPE = NAMESPACEPREFIX + 'Type__c';
    public static String READING = NAMESPACEPREFIX + 'Reading__c';
    public static String CHARGEBASIS = NAMESPACEPREFIX + 'ChargeBasis__c';
    public static String AGREEDRATE = NAMESPACEPREFIX + 'AgreedRate__c';
    public static String SERVICEITEM = NAMESPACEPREFIX + 'ServiceItem__c';
    public static String DISCOUNT = NAMESPACEPREFIX + 'Discount__c';
    public static String MANUALAMENDMENT = NAMESPACEPREFIX + 'ManualAmendment__c';
    public static String TAXCLASSIFICATION = NAMESPACEPREFIX + 'TaxClassification__c';
    public static String AGREEDVOLUME = NAMESPACEPREFIX + 'AgreedVolume__c';
    public static String AGREEDSAMPLESTRENGTH = NAMESPACEPREFIX + 'AgreedSampleStrength__c';
    public static String SUPPLYPOINTALLOWANCE = NAMESPACEPREFIX + 'SupplyPointAllowance__c';
    public static String SIAGREEDVOLUME = NAMESPACEPREFIX + 'SIAgreedVolume__c';
    public static String SUPPLYPOINTBAND = NAMESPACEPREFIX + 'SupplyPointBand__c';
    public static String AVAILABLEBUNDLE = NAMESPACEPREFIX + 'AvailableBundle__c';
    public static String SAMPLE = NAMESPACEPREFIX + 'Sample__c';
    public static String RURALGROSSCONSUMPTION = NAMESPACEPREFIX + 'RuralGrossConsumption__c';
    
}