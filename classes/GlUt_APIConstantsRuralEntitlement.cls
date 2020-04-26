/************************************************************************************************************
@author         Echo : Vivek Sethi
@date           11-Dec-2018
@description:   This is the constants class for all static fields used in the Rural Entitlement object
Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsRuralEntitlement {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX 							= GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Rural Entitlement related objects API Name
    public static String  RURALENTITLEMENTAPINAME       			= NAMESPACEPREFIX + 'RuralEntitlement__c';
    
    // RuralEntitlement related object fields API Names	
    public static final String RURALENTITLEMENTNUMBERAPINAME		= 'Name';    
    public static final String ACTIVEAPINAME     	 		    	= NAMESPACEPREFIX + 'Active__c'; 
    public static final String PERMANENTTRANSFERINAPINAME			= NAMESPACEPREFIX + 'PermanentTransfersIn__c';
    public static final String PERMANENTTRANSFEROUTAPINAME			= NAMESPACEPREFIX + 'PermanentTransfersOut__c';
    public static final String SEASONALALLOCATIONAPINAME			= NAMESPACEPREFIX + 'SeasonalAllocation__c';   
    public static final String TEMPORARYTRANSFERSINAPINAME		    = NAMESPACEPREFIX + 'TemporaryTransfersIn__c';
    public static final String TEMPORARYTRANSFERSOUTAPINAME			= NAMESPACEPREFIX + 'TemporaryTransfersOut__c';
    public static final String STARTDATEAPINAME      				= NAMESPACEPREFIX + 'StartDate__c';
    public static final String ENDDATEAPINAME						= NAMESPACEPREFIX + 'EndDate__c';
    public static final String RURALLICENSEAPINAME					= NAMESPACEPREFIX + 'RuralLicense__c';
    public static final String BASEVOLUMEWITHTRANSFERSAPINAME		= NAMESPACEPREFIX + 'BaseVolumewithTransfers__c'; //AT-5030, Ankit, 08 Feb 2019
}