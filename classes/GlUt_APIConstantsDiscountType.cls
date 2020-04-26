/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           08-Mar-2018
@description:   This is the constants class for all static fields used in the Discount type object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsDiscountType {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Discount relaeted objects API Name
    public static String  DISCOUNTTYPEAPINAME 		= NAMESPACEPREFIX + 'DiscountType__c';
    
    // Discount related object fields API Names	
    public static final String DISCOUNTTYPENAMEAPINAME			= 'Name';    
    public static final String TYPEAPINAME     	 				= NAMESPACEPREFIX + 'Type__c'; 
    public static final String PERCENTAGEDISCOUNTAPINAME		= NAMESPACEPREFIX + 'PercentageDiscountAmount__c';
    public static final String FIXEDDISCOUNTAPINAME				= NAMESPACEPREFIX + 'AbsoluteDiscountAmount__c';
    public static final String OVERRIDDENPERCENTAGEAPINAME		= NAMESPACEPREFIX + 'OverriddenDiscountPercentage' ;
    public static final String RECURRINGFREQUENCYAPINAME		= NAMESPACEPREFIX + 'RecurrenceFrequency__c';   
    public static final String CANBEOVERRIDDENAPINAME      		= NAMESPACEPREFIX + 'CanbeOverridden__c';
    public static final String RECURRINGAPINAME		      		= NAMESPACEPREFIX + 'Recurring__c';
    public static final String DISCOUNTPERDAYAPINAME			= NAMESPACEPREFIX + 'DiscountPerDay__c';
    public static final String NFPAPINAME						= NAMESPACEPREFIX + 'NFP__c';
    public static final String ACTIVEAPINAME					= NAMESPACEPREFIX + 'Active__c';
    public static final String MAXDISCOUNTPERSERVICEITEMAPINAME	= NAMESPACEPREFIX + 'MaximumDIscountPerServiceItem__c';
    public static final String TOPUPAPINAME 					= NAMESPACEPREFIX + 'TopUp__c';
    public static final String DISCOUNTTYPESELFLOOKUPAPINAME	= NAMESPACEPREFIX + 'DiscountType__c';
    public static final String DISCOUNTTYPESTARTDATE        	= NAMESPACEPREFIX +  'StartDate__c';
    public static final String RECORDTYPEAPINAME				= 'RecordTypeId';
    
    

}