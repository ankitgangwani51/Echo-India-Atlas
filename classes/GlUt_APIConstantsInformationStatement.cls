/******************************************************************************
@author         Echo: Neha R.
@date           29 Oct 2018
@description:   This is the constants class for all static fields used in 
                the Information Statement object.
                Please no revisions in constants classes, 
                but use comments so that it's clear how the constants are being used
@revision       Echo: Sudhir- Added additional field constants
*******************************************************************************/
public with sharing class GlUt_APIConstantsInformationStatement{
    
    // get the namespace prefix and prefix it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    //Object
    public static String OBJECTAPINAME    = NAMESPACEPREFIX + 'InformationStatement__c';
    //Relational
    public static String TEMPLATEMAPPINGRELAPINAME  = NAMESPACEPREFIX + 'TemplateMapping__r' ;
    //Fields
    public static String NAMEAPINAME                = 'Name' ;
    public static String DESCRIPTIONAPINAME         = NAMESPACEPREFIX + 'Description__c' ;
    //Sudhir
    public static String TEMPLATEAPINAME            = NAMESPACEPREFIX + 'Template__c' ;
    public static String SETTLEMENTDATEAPINAME      = NAMESPACEPREFIX + 'SettlementDate__c' ;
    public static String AMOUNTDUEAPINAME           = NAMESPACEPREFIX + 'AmountDue__c' ;
    public static String SCHEMEARRERSAPINAME        = NAMESPACEPREFIX + 'SchemeArrears__c' ;
    public static String CALCULATEDCHARGEAPINAME    = NAMESPACEPREFIX + 'CalculatedCharges__c' ;
    public static String LOCATIONBALANCEAPINAME     = NAMESPACEPREFIX + 'LocationBalance__c' ;
    public static String TYPEAPINAME                = NAMESPACEPREFIX + 'Type__c' ;
    public static String SOLICITORNAMEAPINAME       = NAMESPACEPREFIX + 'SolicitorName__c' ;
    public static String ISSUEDATEAPINAME           = NAMESPACEPREFIX + 'IssueDate__c' ;
    public static String SUPPLYADDRESSAPINAME       = NAMESPACEPREFIX + 'SupplyAddress__c' ;
    public static String LOCATIONAPINAME            = NAMESPACEPREFIX + 'Location__c' ;
    public static String DATAXMLAPINAME             = NAMESPACEPREFIX + 'DataXml__c' ;
    public static String PRINTXMLAPINAME            = NAMESPACEPREFIX + 'PrintXml__c' ;
    public static String STATEMENTPDFAPINAME        = NAMESPACEPREFIX + 'StatementPdf__c' ;
    public static String BILLINGCONTRACTAPINAME     = NAMESPACEPREFIX + 'BillingContract__c' ;
    public static String TEMPLATEMAPPINGAPINAME     = NAMESPACEPREFIX + 'TemplateMapping__c' ;
    public static String ADDITIONAL_CHARGE_DESCRIPTION	=	NAMESPACEPREFIX + 'AdditionalChargesDescription__c' ;
    public static String ADDITIONAL_CHARGES				=	NAMESPACEPREFIX + 'AdditionalCharges__c' ;
    
    //public static String INFORMATION_STATEMENT    = 'InformationStatement__c';
}