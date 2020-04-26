/******************************************************************************
@author         Echo: Patrick Dixon
@date           01 Jun 2018
@description:   This is the constants class for all static fields used in 
				the PDF Request object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
*******************************************************************************/
public with sharing class GlUt_APIConstantsPDFRequest {
    
    // get the namespace prefix
    private static final String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // object API Name
    public static final String OBJECTAPINAME = NAMESPACEPREFIX + 'PDFRequest__c';
    
    // field API Names
    public static final String ACCOUNT = NAMESPACEPREFIX + 'Account__c';
    public static final String CONTACT = NAMESPACEPREFIX + 'Contact__c';
    public static final String CONTRACT = NAMESPACEPREFIX + 'BillingContract__c';
    public static final String SOURCE_TYPE = NAMESPACEPREFIX + 'SourceType__c';
    public static final String CORRESPONDENCE_TYPE = NAMESPACEPREFIX + 'CorrespondenceType__c';
    public static final String STATUS = NAMESPACEPREFIX + 'Status__c';
    
    // related object API Names
    public static final String RELATED_ACCOUNT = NAMESPACEPREFIX + 'Account__r';
    public static final String RELATED_CONTRACT = NAMESPACEPREFIX + 'BillingContract__r';
    
    // PDF Request object Constants API Names 
    // ******  DO NOT ADD NAMESPACEPREFIX FOR CONSTANTS ******
    
    public static String PAYMENTPLANNOTIFICATION  = 'Payment Plan Notification'; 
    public static String PENDINGSTATUS	= 'Pending'; 
    public static String CANCELSTATUS	= 'Cancelled';
    public static String XMLSOURCETYPE	= 'Data Transfer XML'; 	
    public static String HTMLSOURCETYPE				= 'HTML'; 
    public static String BILLPDFCORRESPONDENCEYPE	= 'Bill PDF'; 
    
    

}