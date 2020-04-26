/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           02-Feb-2018
@description:   This is the constants class for all static fields used in the Discount object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsDiscounts {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Discount relaeted objects API Name
    public static String  DISCOUNTAPINAME 			= NAMESPACEPREFIX + 'Discount__c';
    public static String  DISCOUNTTYPEAPINAME 		= NAMESPACEPREFIX + 'DiscountType__c';
    public static String  DISCOUNTTYPEITEMAPINAME 	= NAMESPACEPREFIX + 'DiscountTypeitem__c';
    
    // Discount related object fields API Names	
    public static final String DISCOUNTTYPENAMEAPINAME			= 'Name';    
    public static final String BASEPERCENRAGEDISCOUNTAPINAME	= NAMESPACEPREFIX + 'BaseDiscountPercentage__c';
    public static final String BASEDISCOUNTAMOUNTAPINAME		= NAMESPACEPREFIX + 'BaseDiscountAmount__c';
    public static final String BASEDAILYDISCOUNTAMOUNTAPINAME	= NAMESPACEPREFIX + 'BaseDailyDiscountAmount__c';
    public static final String DISCOUNTPERDAYAPINAME			= NAMESPACEPREFIX + 'DiscounPerDay__c';
    public static final String OVERRIDDENPERCENTAGEAPINAME		= NAMESPACEPREFIX + 'OverriddenDiscountPercentage__c';
    public static final String OVERRIDDENAMOUNTAPINAME			= NAMESPACEPREFIX + 'OverriddenDiscountAmount__c';
    public static final String OVERRIDDENDAILYDISCOUNTAPINAME	= NAMESPACEPREFIX + 'OverriddenDailyDiscountAmount__c';
    public static final String AMENDDEDBYDISCOUNTAPINAME		= NAMESPACEPREFIX + 'AmendedByDiscount__c';
    public static final String RECURRINGFREQUENCYAPINAME		= NAMESPACEPREFIX + 'RecurrenceFrequency__c';        
    public static final String CANBEOVERRIDDENAPINAME      		= NAMESPACEPREFIX + 'CanbeOverridden__c';
    public static final String STARTDATEAPINAME 				= NAMESPACEPREFIX + 'StartDate__c'; 
    public static final String ENDDATEAPINAME 					= NAMESPACEPREFIX + 'EndDate__c'; 
    public static final String TYPEAPINAME     	 				= NAMESPACEPREFIX + 'Type__c'; 
    public static final String RECURRINGAPINAME 				= NAMESPACEPREFIX + 'Recurring__c';
    public static final String CONCESSIONAPINAME				= NAMESPACEPREFIX + 'Concession__c';
    public static final String RECORDTYPEAPINAME				= 'RecordTypeId';
   
}