/******************************************************************************
@author         Echo: Sudhir Kumar
@date           15 Nov 2018
@description:   This is the constants class for all static fields used in the Template Mapping object.
*******************************************************************************/

public with sharing class GlUt_APIConstantsTemplateMapping {
	//Namespace prefix
	public static String NAMESPACEPREFIX	= GlUt_NamespacePrefix.getNamespacePrefix() ;
    //Object
    public static String TEMPLATEMAPPINGAPINAME	=	NAMESPACEPREFIX + 'TemplateMapping__c' ;
    //Fields
    public static String PDFTEMPLATEAPINAME	=	NAMESPACEPREFIX + 'PDFTemplate__c' ;
    public static String XSLTDOCUMENTAPINAME	=	NAMESPACEPREFIX + 'XSLTDocument__c' ;
}