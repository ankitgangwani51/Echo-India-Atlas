/************************************************************************************************************
@author         Sudhir Kumar
@date           07-Sep-2018
@description:   This is the constants class for all static strings used in this namespace
@Revisions		AT-5088 , Tarun, Added constants for BlBt_DHHSInvoiceExport             
**************************************************************************************************************/

public class BlBt_Constants {
	
    //Constants used in BlBt_BillDataTransferXMLExtract class
    //Constants for field of the BatchError__c object
    public static final String BATCHREQUESTOPERATION = 'Process';
    public static final String OPERATINGRECORDTYPE	 = 'BlBt_BillDataTransferXmlExtract';
    
    public static final String DISTRIBUTIONURL	 	 = 'https://d29bzvld9lg0l9.cloudfront.net';
    public static final String ENDPOINT			 	 = 'https://echo-data-transfer-xml.s3.amazonaws.com';
    public static final String REGION			 	 = 'eu-west-1';
    public static final String BRQCOMPLETEDSTATUS 	 = 'Completed';
    
    public static final String BILL_TYPE_NORMAL 	 = 'Normal';
    
    //AT-5088 Starts Here
    public static final String ZERO							= '0';
    public static final String SPACE						= ' ';
    public static final String PRE_FILE_EXTENSION			= '.pre';
    public static final String TXT_FILE_EXTENSION			= '.txt';
    public static final String DHHS_INVOICE_EXPORT 			= 'DHHS';
    public static final String SHARE_TYPE 					= 'V';
    public static final String BRQPROCESSINGSTATUS 			= 'Processing';
    public static final String BRQSTATUS 					= 'Completed';
    public static final String BRQSTATUSERRORS				= 'Errors';
    public static final String BILL_EXPORT_PROCESSEDSTATUS	= 'Processed';
    public static final String DHHS_BATCH_REQ_TYPE 			= 'DHHS';
    public static final String DHHS_BATCH_REQ_OPERATION		= 'Export';
    public static final String DHHS_FILE_FORMAT				= 'dd-MM-yyyy';
    public static final String DHHS_EXPORT_FILE_FORMAT		= 'yyyyMMdd_HHmmss';
    public static final String DHHS_RECORDTYPE_1			= '1';
    public static final String DHHS_RECORDTYPE_2			= '2';
    public static final String DHHS_RECORDTYPE_3			= '3';
    public static final String DHHS_RECORDTYPE_4			= '4';
    public static final String DHHS_RECORDTYPE_5			= '5';
    public static final String DHHS_RECORDTYPE_6			= '6';
    public static final String DHHS_TXTFILE_SEQNO			= '01';
    
    //AT-5088 Ends Here
    
    
    
    
    
}