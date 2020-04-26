/************************************************************************************************************
@author         Echo : Vivek Sethi
@date           31-Jan-2018
@description:   This is the constants class for all static fields used in the Bill object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBill {
	
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Payment Allocation Object API Name
    public static String  BILLAPINAME = NAMESPACEPREFIX + 'Bill__c';
    // Relation object Fields API Name
    public static String CONTRACTRELAPINAME			= NAMESPACEPREFIX + 'BillingContract__r' ;
    // Payment Allocation object fields API Names
	public static String  ACCOUNTAPINAME 	= NAMESPACEPREFIX + 'Account__c';//AT-3174
    public static String  BILLCALCULATIONAPINAME 	= NAMESPACEPREFIX + 'BillCalculation__c';
    public static String  BILLDATEAPINAME 			= NAMESPACEPREFIX + 'BillDate__c';
    public static String  BILLNUMBERAPINAME 		= 'Name';
    public static String  BILLEDAMOUNTAPINAME 		= NAMESPACEPREFIX + 'BilledAmount__c';
    public static String  CONTRACTGROUPAPINAME 		= NAMESPACEPREFIX + 'ContractGroup__c';
    public static String  ENDDATEAPINAME 			= NAMESPACEPREFIX + 'EndDate__c';
    public static String  HEROKUPOSTGRESIDAPINAME 	= NAMESPACEPREFIX + 'HerokuPostgresId__c';
    public static String  MIGRATEDAPINAME 			= NAMESPACEPREFIX + 'Migrated__c';
   // public static String  PRINTBILLAPINAME 			= NAMESPACEPREFIX + 'PrintBill__c';
    public static String  PRINTDATEAPINAME 			= NAMESPACEPREFIX + 'PrintDate__c';
    public static String  STARTDATEAPINAME 			= NAMESPACEPREFIX + 'StartDate__c';
    public static String  TOTALDUEAPINAME 			= NAMESPACEPREFIX + 'TotalDue__c';
    public static String  CONTRACTNUMBERAPINAME 	= NAMESPACEPREFIX + 'BillingContract__c' ;		// Sudhir: AT-1817
    public static String  CONTENTDOCUMENTID         =  'ContentDocumentId';    						// Vivek  : AT-1817   
    public static final String BILL_TYPE = NAMESPACEPREFIX + 'BillType__c';
    public static final String CURRENT = NAMESPACEPREFIX + 'LatestPendingBill__c';
    
    public static String  DATAXMLAPINAME		    = NAMESPACEPREFIX + 'DataXml__c' ;	//	AT-2485
    public static String TOTALAMOUNTOUTSTANDINGAPINAME =	NAMESPACEPREFIX + 'TotalAmountOutstanding__c' ;
    public static String  BILLPDFAPINAME 	        = NAMESPACEPREFIX + 'BillPDF__c' ;
    public static String  SELECTEDBILLTRANSFER 	        = NAMESPACEPREFIX + 'SelectedBillTransfer__c' ;
    //Commented By Dependra - 16-11-2018
    //public static String  TRANSFERREASONAPINAME 	        = NAMESPACEPREFIX + 'TransferredReason__c' ; //AT-3255
    //public static String  TRANSFERFROMCONTRACTAPINAME 	        = NAMESPACEPREFIX + 'TransferredFromContract__c' ; //AT-3258
    public static String  PRINTXMLAPINAME		    = NAMESPACEPREFIX + 'PrintXml__c' ;	//	AT-2485
    public static String BILL	= 'Bill__c' ; 	// AT-4098
    public static String DONOTPRINTAPINAME	=  NAMESPACEPREFIX +'DoNotPrint__c'; 	// AT-5020- Added By Dependra 15-01-2018
    public static String FINALBILLAPINAME   =  NAMESPACEPREFIX + 'FinalBill__c';	// AT-5026- Added By Ankit 17-01-2018   
    
    public static String CONTRACTLOADREFAPINAME = NAMESPACEPREFIX + 'BillingContract__r.'+ NAMESPACEPREFIX + 'LoadReference__c';  //AT-5408
    
    

}