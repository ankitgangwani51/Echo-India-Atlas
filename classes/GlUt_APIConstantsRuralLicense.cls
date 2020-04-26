/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           11-Dec-2018
@description:   This is the constants class for all static fields used in the Rural License object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsRuralLicense {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Discount relaeted objects API Name
    public static String  RURALLICENSEAPINAME 		= NAMESPACEPREFIX + 'RuralLicense__c';
    
    // Discount related object fields API Names	
    public static final String RURALLICENSENAMEAPINAME			= 'Name';    
    public static final String RURALLICENSETRANSFERDATEAPINAME  = NAMESPACEPREFIX + 'TransferDate__c'; 
    public static final String RURALLICENSECONTRACTAPINAME     	= NAMESPACEPREFIX + 'BillingContract__c'; 
    public static final String RURALLICENSESTARTDATEAPINAME     = NAMESPACEPREFIX + 'StartDate__c'; 
    public static final String RURALLICENSESTATUSAPINAME     	= NAMESPACEPREFIX + 'Status__c'; 
    public static final String RURALLICENSEALLOCATEBANKAPINAME  = NAMESPACEPREFIX + 'AllocationBankAccountReference__c'; 
    public static final String RURALLICENSEBUNDLEENTITLEAPINAME = NAMESPACEPREFIX + 'BundledEntitlementEntityReference__c'; 
    public static final String RURALLICENSECANCELDATEAPINAME    = NAMESPACEPREFIX + 'CancelledDate__c'; 
    public static final String RURALLICENSETRANSFERTOLICENSEAPINAME  = NAMESPACEPREFIX + 'TransferredToLicense__c'; 
    
    public static final String RURALLICENSEINFRACHARGEAPINAME  = NAMESPACEPREFIX + 'InfrastructureCharge__c'; 
    public static final String RURALLICENSELOADREFERENCEAPINAME  = NAMESPACEPREFIX + 'LoadReference__c'; 
    public static final String RURALLICENSEOUTLETCHARGEAPINAME  = NAMESPACEPREFIX + 'OutletCharge__c'; 
    public static final String RURALLICENSETOTALOUTLETAPINAME  = NAMESPACEPREFIX + 'TotalOutlets__c'; 
    public static final String RURALLICENSETOTALCHARGEOUTLETAPINAME  = NAMESPACEPREFIX + 'TotalChargeableOutlets__c'; 
    public static final String RURALLICENSEBASEENTITLEAPINAME  = NAMESPACEPREFIX + 'BaseEntitlement__c'; 
    public static final String RURALLICENSEHEADINFRACHARGEAPINAME  = NAMESPACEPREFIX + 'HeadworkInfrastructureCharge__c'; 
}