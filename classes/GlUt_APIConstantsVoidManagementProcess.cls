/************************************************************************************************************
@author         Echo : Mohit Tayal
@date           31-JAN-2018
@description:   This is the constants class for all static fields used in the void management process object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsVoidManagementProcess {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX 				= GlUt_NamespacePrefix.getNamespacePrefix();    
    
    public static String VOIDMANAGEMENTPROCESSAPINAME   = NAMESPACEPREFIX + 'VoidManagementProcess__c';
    
    //Custom Fields
    public static String EVALUATEAPINAME 				= NAMESPACEPREFIX + 'Evaluate__c';
    public static String VOIDMANAGEMENTPROFILEAPINAME 	= NAMESPACEPREFIX + 'VoidManagementProfile__c';
    public static String CURRENTSTAGEAPINAME 			= NAMESPACEPREFIX + 'CurrentStage__c';
    public static String CURRENTSTAGEDATETIMEAPINAME 	= NAMESPACEPREFIX + 'CurrentStageDateTime__c';
    public static String PREDICTAPINAME 	            = NAMESPACEPREFIX + 'Predict__c';    
}