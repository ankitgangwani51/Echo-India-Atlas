/************************************************************************************************************
@author         Echo: Amit K.
@date           22-June-2018
@description:   This is the constants class for all static strings used in this namespace
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class PyBt_Constants {
    
    public static string NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    public static final String BANK_ACCOUNT_ACTION_CHANGE_PAYMEMENT_PLAN  = 'Change Payment Plan';
    public static final String BANK_ACCOUNT_ACTION_CREATE_CORRESPONDENCE  = 'Create Correspondence';
    public static final String BANK_ACCOUNT_ACTION_UPDATE_BANK_DETAILS    = 'Change Bank Details';
    public static final String BANK_ACCOUNT_ACTION_RETURN_PAYMENT         = 'Return Payment';
    public static final String PAYMENT_METHOD_TYPE_DIRECTDEBIT       = 'Direct Debit'; //AT-3120 Starts/ends Here
    public static final String DIRECT_DEBIT_REQUEST_STATUS_PENDING   = 'Pending';
    public static final String DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED = 'Confirmed';
    public static final String DIRECT_DEBIT_REQUEST_TRANSACTION_CODE_01 = '01';
    public static final String DIRECT_DEBIT_REQUEST_TRANSACTION_CODE_17 = '17';
    public static final String DIRECT_DEBIT_REQUEST_ZERO_MARKER = '0';
    public static final String BANK_ACCOUNT_ACTION_PROCESSED = 'Processed';
    public static final String BANK_ACCOUNT_ACTION_ERROR = 'Error';    
    public static final String DIRECT_DEBIT_RETURN_PROCESSED  	= 'Processed';  //AT-3004
    //Start - AT-4912. Ankit, 29/01/2018
    public static final String REFUND_EXPORT_STATUS_READY 	= 'Ready'; 		
    public static final String TRANSFERRED_STATUS_NO 		= 'No'; 		
    public static final String DIRECT_CREDIT_COMBIZ_EXPORT 	= 'Direct Credit Combiz Export';
    public static final String DIRECT_DEBIT_COMBIZ_EXPORT 	= 'Direct Debit Combiz Export';
    
    public static final String COMBIZ_REFUND 				= 'CombizRefund';
    public static final String COMBIZ_DIRECT_DEBIT			= 'CombizDD';
    public static final String ZERO							= '0';
    public static final String SPACE						= ' ';    
    //End
     
    public static final String COMBIZMETADATAQUERY = 'SELECT ' + NAMESPACEPREFIX + 'BankAccount__c,' + NAMESPACEPREFIX + 'BankBranch__c,'  + 
                                                      NAMESPACEPREFIX + 'DDFilename__c,' +  NAMESPACEPREFIX + 'DDLodgementReference__c,' + 
                                                      NAMESPACEPREFIX + 'ProcessingDays__c,' +  NAMESPACEPREFIX + 'RefundFilename__c,' +  
                                                      NAMESPACEPREFIX + 'RefundLodgementReference__c,' +  NAMESPACEPREFIX + 'UserBank__c,' +  
                                                      NAMESPACEPREFIX + 'UserName__c,' + NAMESPACEPREFIX + 'UserNumber__c' + 
                                                      ' FROM '+ NAMESPACEPREFIX+'CombizInterface__mdt LIMIT 1'; //Ankit:condev deployment issue
    
    public static final String COMBIZ_BANKACCOUNT_FIELD 				= NAMESPACEPREFIX + 'BankAccount__c';       
    public static final String COMBIZ_BANKACCOUNT_VALUE 				= '1234567890'; 
    public static final String COMBIZ_BANKBRANCH_FIELD 					= NAMESPACEPREFIX + 'BankBranch__c';       
    public static final String COMBIZ_BANKBRANCH_VALUE 					= '063-506'; 
    public static final String COMBIZ_DDFILENAME_FIELD 					= NAMESPACEPREFIX + 'DDFilename__c';       
    public static final String COMBIZ_DDFILENAME_VALUE 					= 'CombizDD_DDMMYYYYhhmmss.aba'; 
    public static final String COMBIZ_DDLODGEMENT_FIELD 				= NAMESPACEPREFIX + 'DDLodgementReference__c';       
    public static final String COMBIZ_DDLODGEMENT_VALUE 				= ''; 
    public static final String COMBIZ_PROCESSINGDAYS_FIELD 				= NAMESPACEPREFIX + 'ProcessingDays__c';       
    public static final String COMBIZ_PROCESSINGDAYS_VALUE 				= '1'; 
    public static final String COMBIZ_REFUNDFILENAME_FIELD 				= NAMESPACEPREFIX + 'RefundFilename__c';       
    public static final String COMBIZ_REFUNDFILENAME_VALUE 				= 'CombizRefund_DDMMYYYYhhmmss.aba'; 
    public static final String COMBIZ_REFUNDLODGEMENTREFERENCE_FIELD 	= NAMESPACEPREFIX + 'RefundLodgementReference__c';       
    public static final String COMBIZ_REFUNDLODGEMENTREFERENCE_VALUE 	= 'Name'; 
    public static final String COMBIZ_USERBANK_FIELD 					= NAMESPACEPREFIX + 'UserBank__c';       
    public static final String COMBIZ_USERBANK_VALUE 					= 'CBA'; 
    public static final String COMBIZ_USERNAME_FIELD 					= NAMESPACEPREFIX + 'UserName__c';       
    public static final String COMBIZ_USERNAME_VALUE 					= 'Coliban Region Water Corp'; 
    public static final String COMBIZ_USERNUMBER_FIELD 					= NAMESPACEPREFIX + 'UserNumber__c';       
    public static final String COMBIZ_USERNUMBER_VALUE 					= '301500'; 
    
    
    

}