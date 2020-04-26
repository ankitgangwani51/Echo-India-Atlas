/******************************************************************************
@author         Accenture: Patrick Dixon
@date           18 Oct 2017
@description    Class for Heroku webservice utilities
Revision(s)     18 Feb 2019, Tarun, UL-314, Sending Region information at Heroku side to handle some of the AU specific logic.
*******************************************************************************/
public with sharing class BlUt_HerokuWebservices {

    private static final String CLASS_NAME = 'BlUt_HerokuWebservices';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // Authentication strings for Heroku webservices
    private static final String ACCESS_TOKEN = 'AccessToken';		// token issued by Heroku
    private static final String CLIENT_SYSTEM_ID = 'ClientSystemId';		// for Salesforce clients this is Org Id
    private static final String REGION = 'Region';		// Region to segregateDictionary different client specifi logic

    // webservice names
    public static final String BILL_CALCULATION = 'BillCalculation';
    public static final String BILL_FORECAST = 'BillForecast';
    public static final String PDF_GENERATION = 'PDFGeneration';
    public static final String PDF_TEMPLATE_UPLOAD = 'PDFTemplateUpload';
    public static final String HTML_TO_PDF_GENERATION = 'HtmlToPDFGeneration';
    public static final String XSLT_DOCUMENT_UPLOAD = 'XSLTDocumentUpload';	// Sudhir
    public static final String BILL_TRANSFER = 'BillTransfer'; //AT-3256
    public static final String DEBT_TRANSFER = 'DebtTransfer'; //AT-4052 - Dependra 23 Oct 2018
    public static final String HEROKU_BATCH_JOB = 'BatchJob'; // Ankit, AT-2785
    public static final String HEROKU_BATCH_STATUS = 'BatchStatus'; // Ankit, AT-2785
    public static final String HEROKU_BATCH_IMMEDIATE = 'BatchImmediate'; // Ankit, AT-2785
    public static final String INFORMATION_STATEMENT	= 'InformationStatementCharges' ; // Sudhir: AU1 - AT-4127
    public static final String PRINT_BILL = 'PrintBill'; // Ankit, AU3-AT-5026, 17-01-2018
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           18 Oct 2017
    @return         String - token
    @description    Retrieve Heroku authentication token from protected custom setting
    *******************************************************************************/
    private static String token;
    private static String getToken() {
    	if (token == null) {
	        for (HerokuSecurity__c security : [select AuthenticationToken__c 
												from HerokuSecurity__c
												limit 1]) {
	
	            token = security.AuthenticationToken__c;
	            break;
	        }
    	}
    	return token;
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           18 Oct 2017
    @param          String - name of webservice
    @return         String - endpoint
    @description    Retrieve Heroku endpoint from custom metadata
    *******************************************************************************/
    @TestVisible private static EnvironmentSettings__mdt settings;
    @TestVisible private static String getEndpoint(String webserviceName) {
        if (settings == null) {
            /*for (EnvironmentSettings__mdt env : [select BillingCalculationEndpoint__c, 
            BillingForecastEndpoint__c, 
            PDFGenerationEndpoint__c, 
            PDFTemplateUploadEndpoint__c,
            HTMLToPDFGenerationEndPoint__c,
            XSLTUploadEndpoint__c,		// Sudhir
            BillTransferEndpoint__c, //AT-3256
            BatchBillingJobEndpoint__c, // Ankit, AT-2785
            BatchBillingJobStatusEndpoint__c, // Ankit, AT-2785
            BatchBillingJobImmediateEndpoint__c, // Ankit, AT-2785
            Information_Statement_Endpoint__c, // Sudhir: AU1 - AT-4127
            PrintBill__c // Ankit, AU3-AT-5026, 17-01-2018
            from EnvironmentSettings__mdt
            limit 1]) {
            settings = env;
            break;
            }*/
            settings = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGQUERY);
        }
        if(settings != null){    
            if (webserviceName == BILL_CALCULATION) return settings.BillingCalculationEndpoint__c;
            else if (webserviceName == BILL_FORECAST) return settings.BillingForecastEndpoint__c;
            else if (webserviceName == PDF_GENERATION) return settings.PDFGenerationEndpoint__c;
            else if (webserviceName == PDF_TEMPLATE_UPLOAD) return settings.PDFTemplateUploadEndpoint__c;
            else if (webserviceName == HTML_TO_PDF_GENERATION) return settings.HTMLToPDFGenerationEndPoint__c;
            else if (webserviceName == XSLT_DOCUMENT_UPLOAD) return settings.XSLTUploadEndpoint__c; // Sudhir
            else if (webserviceName == BILL_TRANSFER) return settings.BillTransferEndpoint__c;	//AT-4052 - Dependra 23 Oct 2018
            else if (webserviceName == DEBT_TRANSFER) return settings.BillTransferEndpoint__c;	//AT-3256
            else if (webserviceName == HEROKU_BATCH_JOB) return settings.BatchBillingJobEndpoint__c; // Ankit, AT-2785
            else if (webserviceName == HEROKU_BATCH_STATUS) return settings.BatchBillingJobStatusEndpoint__c; // Ankit, AT-2785 
            else if (webserviceName == HEROKU_BATCH_IMMEDIATE) return settings.BatchBillingJobImmediateEndpoint__c; // Ankit, AT-2785 
            else if(webserviceName == INFORMATION_STATEMENT) return settings.Information_Statement_Endpoint__c ; // Sudhir: AU1 - AT-4127
            else if(webserviceName == PRINT_BILL) return settings.PrintBill__c; // Ankit, AU3-AT-5026, 17-01-2018
        }
        return null;
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           02 Feb 2018
    @param          String - webservice name (determines endpoint)
    @param          String - method (POST/GET etc)
    @param          String - URL parameters (appended to the endpoint)
    @param          Integer - timeout in ms
    @param          String - contentType (json/XML etc), null for GET
    @param          String - payload, null for GET/blob payload
    @param          Blob - bodyBlob, null for json/xml payloads
    @return         HttpResponse - callout response
    @description    makes the callout to HEROKU using HttpRequest
    *******************************************************************************/
    public static HttpResponse makeCallout(String webserviceName, String urlParams, Integer timeout) {		// GET
    	return makeCallout(webserviceName, urlParams, 'GET', timeout, null, null, null,null);
    }
    public static HttpResponse makeCallout(String webserviceName, Integer timeout, String contentType, String payload) {		// POST
    	return makeCallout(webserviceName, '', 'POST', timeout, contentType, payload, null, null);
    }
    public static HttpResponse makeCallout(String webserviceName, Integer timeout, String contentType, String payload, String method) {		// PUT
    	return makeCallout(webserviceName, '', 'PUT', timeout, contentType, payload, null, null);
    }
    public static HttpResponse makeCallout(String webserviceName, Integer timeout, String contentType, Blob bodyBlob) {		// POST + blob
    	return makeCallout(webserviceName, '', 'POST', timeout, contentType, null, bodyBlob, null);
    }
    public static HttpResponse makeCallout(String webserviceName, Integer timeout, String contentType, Blob bodyBlob, string fileName) {		// POST + blob Overrided by Dependra.
        return makeCallout(webserviceName, '', 'POST', timeout, contentType, null, bodyBlob, fileName);
    }
    public static HttpResponse makeCalloutDelete(String webserviceName, String urlParams, Integer timeout) {		// Delete
    	return makeCallout(webserviceName, urlParams, 'DELETE', timeout, null, null, null,null);
    }
    
    public static HttpResponse makeCallout(String webserviceName, String urlParams, String method, Integer timeout, String contentType, String payload, Blob bodyBlob, string fileName) {
		// build the request
        HttpRequest request = new HttpRequest();    
        request.setMethod(method);
        urlParams = urlParams == null ? '' : urlParams;
        request.setEndpoint(getEndpoint(webserviceName) + urlParams);
        
        system.debug('getToken()=='+ getToken());
        system.debug('UserInfo.getOrganizationId()()=='+ UserInfo.getOrganizationId());
        system.debug('REGION=='+ Region__c.getOrgDefaults().Name__c);
        request.setHeader(ACCESS_TOKEN, getToken());
        request.setHeader(CLIENT_SYSTEM_ID, UserInfo.getOrganizationId());
        request.setHeader(REGION, Region__c.getOrgDefaults().Name__c);
        
        if (bodyBlob != null) {
	        request.setHeader('Content-Type', contentType);
			request.setHeader('Content-Length', String.valueOf(bodyBlob.size()));
			request.setBodyAsBlob(bodyBlob);
	        System.debug(DEBUG + 'Content-Type: ' + request.getHeader('Content-Type'));
	        System.debug(DEBUG + 'fileBlob.size(): ' + bodyBlob.size());
             if(webserviceName == BlUt_HerokuWebservices.PDF_TEMPLATE_UPLOAD && fileName != null){
                 request.setHeader('name', fileName);
                 //request.setHeader('file', bodyBlob);
            }
		}
        else if (method != 'GET' && method != 'DELETE') {
        	request.setHeader('Content-Type', contentType);
        	request.setBody(payload);
		}
        request.setTimeout(timeout);
        System.debug(DEBUG + 'request: ' + request);
        System.debug(DEBUG + 'request Header: ' + request.getHeader(REGION));

        // invoke the endpoint using the Http class
        Http http = new Http();
        return http.send(request);
    }

    
}