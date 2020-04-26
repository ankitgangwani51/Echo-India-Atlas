/************************************************************************************************************
@author         Echo : Dependra
@date           24-Jan-2017
@description:   This is the constants class for all static strings used in this namespace
@revision:      07-Mar-2018 MT - Added the namespace prefix
**************************************************************************************************************/
public with sharing class PyAp_Constants { 
    //The prefix for this namespace
    public static string NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    public static String PREFIX = 'PyAp_';
    public static String ID = 'Id';
    public static String NAME = 'Name';
    //Appended to the end of all trigger handler classes
    public static String  PAYMENTAPINAME             = NAMESPACEPREFIX + 'Payment__c';
    
    public static String  BUDGETPLAN                 = 'Budget Plan';
    public static String  PAYMENT                    = 'Payment';
    public static String  FULLYALLOCATED             = 'Fully Allocated';
    public static String  PARTIALLYALLOCATED         = 'Partially Allocated';
    public static String  CREDITTRANSFER             = 'Credit Transfer';
    public static String  REFUND                     = 'Refund';
    public static String  YES                        = 'Yes';
    
    // 29 Jan 2018, Gopal Gupta - Constants for PyAp_BillPaymentHistoryCtrlr class
    public static String  BILLAMTPAIDOFFLABEL       = 'Bill Amount Paid off';
    public static String  PAYMENTMETHODLABEL        = 'Method';
    public static String  RECORDTYPELABEL           = 'Type';
    public static String  PAYMENTDATELABEL          = 'Date';
    public static String  NAMELABEL                 = 'Id';
    public static String  SERVICEITEMTYPENAMELABEL  = 'Bill Item Type';
    public static String  BILLEDAMOUNTLABEL         = 'Amount';
    
    // 31 Jan 2018, Vivek Sethi - Constants for PyAp_BillHistoryCtrl class
    public static String  BILLDATELABEL             = 'Date';
    public static String  PMTMETHODLABEL            = 'Method';
    public static String  AMOUNTALLOCATEDLABEL      = 'Amount Paid off by this Payment';
    public static String  BILLEDAMTLABEL            = 'Amount';
    public static String  SERVICEITEMTYPELABEL      = 'Service Item Type';
    public static String  BILLALLOCATIONSTATUSLABEL = 'Status';
    public static String  TOTALAMOUNT             = 'Total Amount';
    
    // 01 Feb 2018, Tarun Gupta - Constants for PyAp_ContractPaymentHistoryCtrlr class
    public static String  BILLAMTUNALLOCATEDLABEL          = 'Bill Amount Unallocated';
    public static String  INSTALAMTUNALLOCATEDAPINAMELABEL = 'Instalment Amount Unallocated';
    public static String AMTALLOCATEDLABEL                 = 'Bill Amount Paid';
    public static final string CONTRACTDISPLAYFIELDS = 'Id,Name,'+ NAMESPACEPREFIX + 'AccountName__c';
   
    // 16 Feb 2018, Dependra Singh - Constants for PyAp_RefundTransferCreditPageCtrlr class
    public static String  BANKACCOUNTDETAILS          = 'BankAccountDetails';
    public static String  CHEQUEDETAILS               = 'ChequeDetails';
    public static String  CASH                        = 'Cash';
    public static String  CHEQUE                      = 'Cheque';
    public static String  DIRECTDEBIT                 = 'Direct Debit';
    public static String  DIRECTCREDIT                = 'Direct Credit';
    public static String  RETURNTRNASFER              = 'Return/Transfer';
    public static String  PAYINFULL                   = 'Pay In Full';
    public static String  CREDITWRITEOFF 			  =  'Credit Write Off';
    // AT-2824 27 June 2018, Vivek Sethi - Constants for PyAp_DirectDebitRequestExportCtrlr class
    public static String INITIALISED           = 'Initialised';              
    public static String HIGH                  = 'High';                
    public static String DIRECTDEBITEXPORT     = 'Direct Debit Export';   
    public static String IMPORTFROMFILEFALSE   = 'No'; 
    public static String BATCHPROCESSOPERATION  = 'Export';
    public static String BATCHPROCESSEXPORTBOOKCLASSNAME  = 'PyBt_DirectDebitRequestExport';
    public static String FIELDTYPETEXT           = 'text';               
    public static String FIELDTYPETEXTENCRYPTED  = 'textEncrypted';
    
    
    //AT-2984 03 Jul 2018, Swati Mathur - Constant for PyAp_RefundTransferCreditUtility
    public static String REMITTANCEADVICE = 'Remittance Advice';
    
    //Sudhir: AT-2873 (Core7a)
    public static String REQUESTED_REFUND_STATUS                = 'Requested' ;
    public static string  GOODWILL_PAYMENT_RECORD_TYPE          = 'Goodwill' ;
    public static string  APPROVED_PAYMENT                      = 'Approved' ;
    public static string  UNALLOCATED_PAYMENT_STATUS            = 'None' ;
    
    //Dependra : Suspense Payment
    public static string  PAYMENTNUMBER             = 'Payment Number' ;
    public static string  ORIGINALAMOUNT            = 'Original Amount' ;
    public static string  TRANSFERREDAMOUNT         = 'Transferred Amount';
    public static string  REMANINGAMOUNT            = 'Remaning Amount';
    
    // AT-4014, Payment Allocation Routine
    public static String SETTLEMENTPAYMENT						= 'Settlement Payment';
    
    public static final String CARDHOLDERNAME_FIELDTYPE =  'CardHolderName';
    public static final String CARDHOLDERNAME_FIELDLABEL =  'CardHolder Name';
    public static final String PAYMENTMETHOD_FIELDLABEL =  'Payment Method';
    public static final String PAYMENTMETHOD_FIELDTYPE =  'PaymentMethod';
    public static final String PAYMENTDATE_FIELDTYPE =  'PaymentDate';
    public static final String PAYMENTDATE_FIELDLABEL =  'Payment Date';
    public static final String FIELDTYPE_SELECT =  'select';
    public static final String BPOINT_SERVER_CONNECTION_FAILURE =  'Internal Exception Occur, Please contact your administrator';
    public static final String CURRENCY_REPLACED =  'Currency_x';
    public static final String CURRENCY_RESERVED =  'Currency';
    
    public static final String LOCATIONADDRESS_FIELDLABEL =  'Location';  //AT-5108
    public static final String SUPPLYPOINT_FIELDLABEL =  'Supply Point';  //AT-5108

	
    public static final String BPOINTINTERFACEPARAMSETTINGQUERY = 'SELECT ' + NAMESPACEPREFIX + 'AuthkeyEndpoint__c,' + 
                                                                        NAMESPACEPREFIX + 'IframeURL__c,' +  NAMESPACEPREFIX + 'Password__c,' + 
        																NAMESPACEPREFIX + 'PaymentEndpoint__c,' + NAMESPACEPREFIX + 'Testmode__c,' +
        																NAMESPACEPREFIX + 'TransactionType__c,' + NAMESPACEPREFIX + 'Username__c' + ' FROM ' + 
                                                                        NAMESPACEPREFIX + 'BPointInterfaceParameters__mdt  LIMIT 1';
    
    public static final String BPOINT_INTERFACE_AUTHKEY_FIELD =  NAMESPACEPREFIX + 'AuthkeyEndpoint__c';       
    public static final String BPOINT_INTERFACE_AUTHKEY_VALUE =  'https://www.bpoint.com.au/webapi/v3/txns/processtxnauthkey'; 
    public static final String BPOINT_INTERFACE_IFRAME_FIELD =  NAMESPACEPREFIX + 'IframeURL__c';       
    public static final String BPOINT_INTERFACE_IFRAME_VALUE =  'https://www.bpoint.com.au/webapi/v3/txns/iframe/'; 
    public static final String BPOINT_INTERFACE_PWD_FIELD =  NAMESPACEPREFIX + 'Password__c';       
    public static final String BPOINT_INTERFACE_PWD_VALUE =  'testPassword'; 
    public static final String BPOINT_INTERFACE_PAYMENT_FIELD =  NAMESPACEPREFIX + 'PaymentEndpoint__c';       
    public static final String BPOINT_INTERFACE_PAYMENT_VALUE =  'https://www.bpoint.com.au/webapi/v3/txns/processiframetxn/'; 
    public static final String BPOINT_INTERFACE_TESTMODE_FIELD =  NAMESPACEPREFIX + 'Testmode__c';       
    public static final Boolean BPOINT_INTERFACE_TESTMODE_VALUE =  true; 
    public static final String BPOINT_INTERFACE_TRANSTYPE_FIELD =  NAMESPACEPREFIX + 'TransactionType__c';       
    public static final String BPOINT_INTERFACE_TRANSTYPE_VALUE =  'callcentre'; 
    public static final String BPOINT_INTERFACE_USERNAME_FIELD =  NAMESPACEPREFIX + 'Username__c';       
    public static final String BPOINT_INTERFACE_USERNAME_VALUE =  'andrewedge'; 

}