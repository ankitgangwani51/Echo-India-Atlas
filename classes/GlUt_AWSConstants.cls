/****************************************************************************************************************
@author         Echo: Sudhir Kumar
@date           28 May 2018
@description    GlUt_AWSConstants class contains AWS specific constants to be referenced in other classes.
@revision		Echo: Dependra Singh - 14-03-2019 -Meta data Setting updated.
*****************************************************************************************************************/

public class GlUt_AWSConstants {
    public static string NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();    
    // Constants to show label in Generic table in view bill component. Added by Dependra 
    // 1 Jun 2018, P Dixon - THESE SHOULD BE CUSTOM LABELS!!
    public static final String DATAXML 		= 'Data XML';  
	public static final String PRINTXML 	= 'Print XML';  
	public static final String BILLPDF 		= 'Bill PDF';  
	public static final String DOCUMENTNAME = 'DocumentName'; 
	public static final String BILLLINK 	= 'BillLink';
    public static final String STATEMENTPDF = 'Statement PDF';  
    // START: AU1 AT-4098
    public static final String BILL_PDF_CONTAINER_PREFIX						= 'BlUt_' ; 
	public static final String INFORMATION_STATEMENT_PDF_CONTAINER_PREFIX		= 'LoUt_' ; 
    public static final String PDF_CONTAINER_SUFFIX			= 'XmlContainer' ;
    public static final String BILL_OBJECT					= NAMESPACEPREFIX  + 'Bill__c' ;	//AT-4098
    public static final String INFORMATION_STATEMENT_OBJECT	= NAMESPACEPREFIX  + 'InformationStatement__c' ; //AT-4098
    // END: AU1 AT-4098
    
    // Constants strings for bucket names
	public static final String PRINTXMLBUCKET 				= System.Label.GlUt_AWS_PRINT_XML_BUCKET ;   		//AT-3003
	public static final String BILLPDFBUCKET 				= System.Label.GlUt_AWS_BILL_PDF_BUCKET ;   		//AT-3003
	public static final String DATAXMLSS3BUCKET 			= System.Label.GlUt_AWS_DATA_XML_BUCKET ;			//AT-3003
	public static final String XSLTS3BUCKET 				= System.Label.GlUt_AWS_XSLT_BUCKET ;				//AT-3003
    public static final String ECHODATATRANSFERXMLS3BUCKET 	= System.Label.GlUt_AWS_DATA_TRANSFER_XML_BUCKET ;	//AT-3003
    public static final	Integer	CLOUDFRONTURLEXPIRYMINUTE	= 10 ;		// reset it to 10 as per doc. Currently set to 1 for testing purpose	// Move it to Custom Label/Custom Setting
    public static final String DATA_TRANSFER_XML_FILE_NAME	= 'DataTransferXML';
    public static final String DATATRANSFERXMLFILENAME 		= 'DataTransferXML';
    public static final String DATETIMEFORMAT 				= 'yyyy-MM-dd_hh-mm-ss';
    public static final String XMLFILEEXTENSION 			= '.xml'; 
    public static final String ECHOPDFTEMPLATEBUCKET		= System.Label.GlUt_AWS_PDF_TEMPLATE_BUCKET ;			//AT-3003
    public static final String ECHOPDFCORRESPONDENCEBUCKET  = System.Label.GlUt_AWS_PDF_CORRESPONDENCE_BUCKET ;		//AT-3003
    
    public static final String CORRESPONDENCE_XML_REPORT_FILE_NAME	= 'CorrespondenceXMLReport';
    public static final String REPORT_FILE_EXTENSION                = '.txt';
    public static final String DATA_TRANSFER_XML_BATCH_REPORT	    = 'DataTransferXmlBatchReport' ;
    public static final String DATA_TRANSFER_XML_WORKSPACE		    = 'Data Transfer Xml' ;
    public static final String PDF_FILE_EXTENSION                   = '.pdf';
    public static final String SHARE_TYPE                           = 'V';
    public static final String AWSS3PDFBUCKET_FIELD_PROP			= 'AWSS3PDFBUCKET' ;
    public static final String AWSS3XSLTBUCKET_FIELD_PROP			= 'AWSS3XSLTBUCKET' ;
    public static final String TEMPLATE_NAME	=	'TemplateName__c' ;
    public static final String ACTION			=	'Action__c' ;
    public static final String ACCESSKEYIDAPINAME			=	NAMESPACEPREFIX +'AccessKeyId__c' ;
    public static final String CLOUDFRONTKEYPAIRIDAPINAME			=	NAMESPACEPREFIX +'CloudFrontKeyPairId__c' ;
    public static final String CLOUDFRONTKEYPAIRPRIVATEKEYAPINAME	=	NAMESPACEPREFIX+'CloudFrontKeyPairPrivateKey__c' ;
    public static final String SECRETKEYAPINAME			=	NAMESPACEPREFIX+'SecretKey__c' ;
    public static final String SERVICEAPINAME			=	NAMESPACEPREFIX+'Service__c' ;
    public static final String AWSCONFIGURATIONSETTINGQUERY =  'SELECT ' + ACCESSKEYIDAPINAME +','+  CLOUDFRONTKEYPAIRIDAPINAME +','+ CLOUDFRONTKEYPAIRPRIVATEKEYAPINAME + ','
        + SECRETKEYAPINAME + ',' +SERVICEAPINAME + ' FROM ' + NAMESPACEPREFIX +'AWSConfigurationsSettings__mdt LIMIT 1';
    
}