/************************************************************************************************************
@author         Accenture : Luke Emberton
@date           24-Aug-2017
@description:   This is the constants class for all static strings used in this namespace
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
@revision:      07-Mar-2018 MT - Added the namespace prefix
**************************************************************************************************************/
public class GlUt_Constants {
    
    // The prefix for this namespace
    public static final String PREFIX = 'GlUt_';
    public static string NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Appended to the end of all trigger handler classes
    public static final String HANDLERSUFFIX = 'Handler';
    
    // Appended to the end of all contract finder classes
    public static final String CONTRACT_FINDER = 'ContractFinder';
    
    // Suffix for trigger automation custom setting fields
    public static final String CUSTSETFIELDSUFFIX = 'Triggers__c';   
    
    // Trigger object names and the prefix for trigger class and field names
    
    public static final String OBJ_BALANCETRANSACTION = 'BalanceTransaction';
    public static final String OBJ_PAYMENTASSOCIATION = 'PaymentAssociation';       // Neha 07 Dec 2018
    public static final String OBJREADING             = 'Reading';       // Manish Added on 04-Sep-2017
    public static final String OBJCONSIDERATION       = 'Consideration';       // Ashish Added on 13-Dec-2017
    public static final String OBJLOCATIONOCCUPANTS   = 'LocationOccupants';  // Ashish Added on 14-Dec-2017
    public static final String OBJCONTACT             = 'Contact';       // Shivangi - Added on 05-Sep-2017
    public static final String OBJACCOUNT             = 'Account';       // Manish- Added on 22-Sep-2017
    public static final String OBJ_BALANCE            = 'Balance';        // 15 Feb 2018, P Dixon
    public static final String OBJ_BILL               = 'Bill';        // 21 Sep 2017, P Dixon
    public static final String OBJ_BILLITEM           = 'BillItem';        // 06 Nov 2017, P Dixon
    public static final String OBJ_BILLTEMPLATE       = 'BillTemplate';        // 27 Oct 2017, P Dixon
    public static final String OBJ_PAYMENTPLAN        = 'PaymentPlan';        // 07 Feb 2018, P Dixon
    public static final String OBJSPDEVICESERVICE     = 'SupplyPointDeviceService';       // 31-Oct-2017 -- Shivangi Gaur
    public static final String OBJAVAILABLEBUNDLE     = 'AvailableBundle';       // 29-Nov-2017 -- Dependra Singh
    public static final String OBJSPDEVICE            = 'SupplyPointDevice';       // 29-Nov-2017 -- Dependra Singh
    public static final String OBJSERVICEITEM         = 'ServiceItem';       // Dependra Singh - added on 10-01-2018
    public static final String OBJSERVICE             = 'Service';       // Dependra Singh - added on 10-01-2018    VS AT-3137
    public static final String OBJ_INSTALMENT         = 'Instalment';        // 16 Jan 2018, Pratyush
    public static final String OBJ_PAYMENT            = 'Payment';        // 16 Jan 2018, Pratyush
    public static final String OBJ_PAYMENTALLOCATION  = 'PaymentAllocation';        // 20 mar 2018, Dependra
    public static final String OBJ_FINANCIALCONTROL   = 'FinancialControl';        // 20 mar 2018, Dependra
    public static final String OBJ_BILLITEMAMENDMENT  = 'BillItemAmendment';        // 20 mar 2018, Dependra  // MT - 14-08-2018 3174
    public static final String OBJSUPPLYPOINT         = 'SupplyPoint';        // 25 Jan 2018, Neha
    public static final String OBJCONTRACT            = 'BillingContract';        // 20 Feb 2018, Dependra
    public static final String OBJDEBTRECOVERYPROCESS = 'DebtRecoveryProcess'; // 22 Feb 2018, Dependra
    public static final String OBJEMAILMESSAGE        = 'EmailMessage'; // 28 Feb 2018, Swati Mathur
    public static final String OBJ_FINANCIALCONTROLTOTAL   = 'FinancialControlTotal';        // 29 mar 2018, Tarun
    public static final String OBJBATCHREQUESTQUEUE        = 'BatchRequestQueue' ;       // Sudhir - AT-2426
    public static final String OBJDIRECTCREDITRETURNS      = 'DirectCreditReturn' ;       // Vivek - AT-2891
    public static final String OBJTARIFFLIMIT         = 'TariffLimit' ;       // Dependra- AT-3233
    public static final String OBJ_PAYMENTPLANTYPE        = 'PaymentPlanType';        // 22 Aug 2018, Swati -- AT-2311
    public static final String OBJFORECASTEDRESULT      = 'ForecastedResult' ;       // Tarun - AT-2941
    public static final String OBJBILLTRANSFER      = 'BillTransfer' ;       // Dependra - AT-4057    
    public static final String OBJRATE               = 'Rate';       // Satish - Added on 01-Nov-2017
    public static final String OBJAGREEDRATE         = 'AgreedRate'; // Vandana - Added on 23-Nov-2017
    public static final String OBJDEVICERELATIONSHIP = 'DeviceRelationship';//Vivek -Added on 3 Dec -2017
    public static final String OBJSUPPLYPOINTRELATIONSHIP = 'SupplyPointRelationship'; // Ankit - Added on 26 June for AT-2926
    public static final String OBJRURALMEASUREMENT   = 'RuralMeasurement'; // Neha -  AT-4507
    public static final String BILLABLE              = 'Billable';      //Neha - Added on 23 Mar 2017
    public static final String NHH_LOCATION          = 'Non-Household'; //Neha - Added on 23 Mar 2017
    public static final String HH_LOCATION           = 'Household';     //Neha - Added on 23 Mar 2017
    public static final String TOPUP                 = 'Top Up';        //Neha - Added on 23 Mar 2017
    public static final String NONBILLABLE           = 'Non Billable';
    public static final String INVALID_BILLABLETYPE   = 'Invalid';   // Neha AT-4192
    public static final String NAMEAPINAME   = 'Name';   // Dependra Singh
    public static final String OBJRURALLICENSE            = 'RuralLicense';        // 17 DEc 2018, Tarun
    
    // RecordType API Names 28-11-2017 added by Manish
    public static final String NHH_ACCOUNT_RECORDTYPE_NAME     = 'NonHouseholdAccount';
    public static final String HH_ACCOUNT_RECORDTYPE_NAME      = 'HouseholdAccount';
    // Reading related string
    public static final string SERVICETYPE                     = NAMESPACEPREFIX + 'ServiceType__c';
    public static final string SUPPLYPOINT                     = NAMESPACEPREFIX + 'SupplyPoint__c';
    public static final string SUPPLYPOINTDEVICE               = NAMESPACEPREFIX + 'SupplyPointDevice__c';
    public static final string DEVICE                          = NAMESPACEPREFIX + 'Device__c';
    public static final string SUPPLYPOINTDEVICESERVICE        = NAMESPACEPREFIX + 'SupplyPointDeviceService__c';
    public static final string SERIAL                          = NAMESPACEPREFIX + 'SerialNo__c';
    public static final string DIGIT                           = NAMESPACEPREFIX + 'Digit__c';
    public static final string DEVICELOCATION                  = NAMESPACEPREFIX + 'DeviceLocation__c';
    public static final string READINGDATE                     = NAMESPACEPREFIX + 'ReadingDate__c';
    public static final string ACTUALREADING                   = NAMESPACEPREFIX + 'ActualDeviceReading__c';
    public static final string READINGMETHOD                   = NAMESPACEPREFIX + 'ReadingMethod__c';
    public static final string READING                         = NAMESPACEPREFIX + 'Reading__c';
    //Reading field label & conversion
    public static final string ACTUALREADINGLABEL              = 'Actual Device Reading';
    public static final string PREVIOUSREADING                 = 'Previous Reading';
    public static final string READINGMETHODLABEL              = 'Reading Method';
    public static final string READINGDATELABEL                = 'Reading Date';
    public static final string MOVEIN                          = 'Move In';
    public static final string COMPANYREADING                  = 'Company Reading';
    public static final string REGULAR                         = 'Regular';
    public static final string MOVEOUT                         = 'Move Out';
    public static final string CUSTOMERREADING                 = 'Customer Reading';
    public static final string ESTIMATE                        = 'Estimate';
    public static final string AMEND                           = 'Amend';
    public static final string OBJAVAILABLEBUNDLEAPI           = NAMESPACEPREFIX + 'AvailableBundle__c';
    public static final string OBJAVAILABLESERVICEAPI          = NAMESPACEPREFIX + 'AvailableService__c';
    
    public static final string SERVICETYPELBL       = 'Service Type';
    public static final string TEXT                 = 'text';
    public static final string AVERAGEDAILYUSEAPI   = NAMESPACEPREFIX + 'AverageDailyUsage__c';  
    public static final string SERVICETYPENAME      = NAMESPACEPREFIX + 'ServiceType__r.Name';
    public static final string SEWSERVICELBL    = 'Sewerage';         //AT-3137
    public static final string TESERVICELBL     = 'Trade Effluent';   //AT-3137  AT-3140
    
    public static final String SUPPLYDISCONNECTIONSTATUS = 'Able to Disconnect';  // Ashish Added on 13-Dec-2017

    // 19 Dec 2017, P Dixon - default contract fields
    public static final string DEFAULT_BILLING_METHOD    = Label.CuAp_ContractBillingMethodContractFrequencyNoTopUp;
    public static final string DEFAULT_PDF_TEMPLATE      = 'Default';
    public static final string DEFAULT_BILLING_FREQUENCY = Label.CuAp_ContractBillingFrequencyMonthly;
    
    public static final string PAYMENTALLOCATIONQUEUE_OPERATION_INSERT  = 'Insert'; // 25 Jan 2018, Pratyush
    public static final string PAYMENTALLOCATIONQUEUE_OPERATION_UPDATE  = 'Update'; // 25 Jan 2018, Pratyush
    public static final string PAYMENTALLOCATIONQUEUE_STATUS_PROCESSSED = 'Processed'; // 25 Jan 2018, Pratyush
    public static final string PAYMENTALLOCATIONQUEUE_STATUS_NEW        = 'New'; // 25 Jan 2018, Pratyush
    public static final string PAYMENTALLOCATIONQUEUE_STATUS_REVERSED   = 'Reversed'; // 25 Jan 2018, Pratyush
    
    public static final string PAYMENTALLOCATION_INSTALMENTALLOCATIONSTATUS_FULLY        = 'Fully Allocated'; // 25 Jan 2018, Pratyush
    public static final string PAYMENTALLOCATION_INSTALMENTALLOCATIONSTATUS_PARTIALLY    = 'Partially Allocated'; // 25 Jan 2018, Pratyush    
    public static final string PAYMENTALLOCATION_BILLALLOCATIONSTATUS_FULLY              = 'Fully Allocated'; // 25 Jan 2018, Pratyush
    public static final string PAYMENTALLOCATION_BILLALLOCATIONSTATUS_PARTIALLY          = 'Partially Allocated'; // 25 Jan 2018, Pratyush    
    public static final string PAYMENTALLOCATION_ALLOCATIONSTATUS_ALLOCATED              = 'Allocated'; // 25 Jan 2018, Pratyush  
    
    public static final string BALANCE_RECORDTYPE_RETURNTRANSFER    = 'Return_Transfer'; // 25 Jan 2018, Pratyush    
    public static final string BALANCE_TYPE_PAYMENT                 = 'Payment'; // 25 Jan 2018, Pratyush    
    public static final string BALANCE_TYPE_REFUND                  = 'Refund'; // 25 Jan 2018, Pratyush    
    public static final string BALANCE_TYPE_RETURNTRANSFER          = 'Return/Transfer'; // 25 Jan 2018, Pratyush   -- AT-3174
    // AT-3275 Start
    //public static final string BALANCE_TYPE_BILLITEM                = 'Bill Item'; // 15 Feb 2018, Pratyush 
    //public static final string BALANCE_TYPE_PENDING_BILL_ITEM = 'Pending Bill Item';        // 04 Jul 2018, P Dixon 
    public static final string BALANCE_TYPE_BILL                = 'Bill'; // 01 Aug 2018, Tarun  
    public static final string BALANCE_TYPE_PENDING_BILL = 'Pending Bill'; 
    public static final string BALANCE_TYPE_TRANSFER_BILL = 'Bill Transfer'; // 26 Oct 2018 Dependra AT-4054
    // AT-3275 End
    public static final string PAYMENT_RECORDTYPE_REFUND            = 'Refund'; // 15 Feb 2018, Pratyush
    public static final string PAYMENT_RECORDTYPE_PAYMENT           = 'Payment'; // 15 Feb 2018, Pratyush
    public static final string PAYMENT_RECORDTYPE_GOODWILL          = 'Goodwill'; // AT-2891
    public static final string DIRECT_CREDIT_STATUS_PROCESSED       = 'Processed'; // AT-2891
    public static final string REFUND_EXPORT_STATUS_ERROR           = 'Error';  // AT-2891
    public static final String DIRECT_CREDIT_RETURN                 = 'Direct Credit Return';
    public static final string BALANCETRANSACTION_SOBJECT_APINAME   = NAMESPACEPREFIX + 'BalanceTransaction__c'; // 15 Feb 2018, Pratyush
    public static final string PAYMENT_SOBJECT_APINAME              = NAMESPACEPREFIX + 'Payment__c'; // 15 Feb 2018, Pratyush
    
    public static final string OBJDADU = 'DefaultAverageDailyUsage';
    public static final string ACTUAL = 'ACTUAL';
    public static final String OBJ_HEROKUBILLCALCULATIONSTATUS  = 'HerokuBillCalculationStatus';  // 03 May 2018, Amit K.
    
    public static final String OBJCONTENTDOCUMENTLINK           = 'ContentDocumentLink';  
    public static final String ALLUSERS                         = 'AllUsers';
    public static final String SHARETYPE                        = 'I';
    public static final String BATCHPROCESSOPERATION            = 'Import';
    public static final String BATCHPROCESSOPERATIONEXPORT      = 'Export'; //AT-4912, Ankit, 29/01/2018
    public static final String FILEEXTENSIONCSV                 = 'csv';
    public static final String FILEEXTENSIONXML                 = 'xml';
    public static final String NOTIMPLEMENTEDERROR              = 'Error Not Implemented';
    public static final String ERRORS                           = 'Errors';
    public static final String INITIALISED                      = 'Initialised'; //AT-2443
    public static final String BRTYPEMETERBOOK                  = 'Meter Book';  //AT-2443 
    public static final String BRTYPECONCESSION                 = 'Concession';  
    public static final String PROCESSED                        = 'Processed';  //AT-2443 
    public static final String COMPLETED                        = 'Completed';  //AT-2443 
    public static final String COMPLETE                         = 'Complete';	// AT-4507
    public static final String AFTERINSERT                      = ' Exception After Insert';
    public static final String BEFOREINSERT                     = ' Exception Before Insert';
    public static final String AFTERUPDATE                      = ' Exception After Update';
    public static final String BEFOREUPDATE                     = ' Exception Before Update';
    public static final String AFTERDELETE                      = ' Exception After Delete';
    public static final String BEFOREDELETE                     = ' Exception Before Delete';
    public static final String EXECUTINGBATCH                   = ' Executing Batch ';
    public static final String EXECUTINGLGTHNGCMPCTRL           = ' Executing Lighting Component Controller ';
    public static final String EXECUTING                        = ' Executing ';
    public static final String NUMBEROFSUPPLYPOINT              = 'Number of Supply Point';
    public static final String FIELDCUSTOMVALIDATIONEXCEPTION   = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    public static final String REQUIREDFIELDMISSING             = 'REQUIRED_FIELD_MISSING';
    
    
    public static final String OBJBILLEVENT                     = 'BillEvent';    //AT-2483
    public static final String BILLEVENTUPDATEDSTATUS           = 'Replaced';     //AT-2483
    public static final String BILLEVENTSTATUS                  = 'Pending';      //AT-2483
    public static final String REPORT_FILE_EXTENSION            = '.txt';
    public static final String ABA_FILE_EXTENSION				= '.aba'; //AT-4912, Ankit, 31/01/2018
    public static final String PDF_FILE_EXTENSION               = '.pdf';
    public static final String DATE_TIME_FORMAT                 = 'yyyy-MM-dd_hh-mm-ss';
    public static final String FILE_EXTENSION_CSV               = '.csv';
    public static final String NUMBEROFREAD                     = 'Number Read';
    
    //Dependra : AT-2884 (Core7a)
    public static final String TRANSACTIONCODE0N                = '0N';
    public static final String TRANSACTIONCODE0C                = '0C';
    public static final String OUTGOING                         = 'Outgoing';

    public static final String BATCH_REQUEST_QUEUE_STATUS_COMPLETED    = 'Completed';
    public static final String BATCH_REQUEST_QUEUE_STATUS_PROCESSING   = 'Processing';
    public static final String OBJ_DIRECTDEBITREQUEST           = 'DirectDebitRequest';
    public static final String OBJ_DIRECTDEBITRETURN            = 'DirectDebitReturn';
    public static final String OBJ_SUPPLYPOINTBAND              = 'SupplyPointBand';
    public static final String OBJ_CHARGEBASIS                  = 'ChargeBasis';
    public static final String DIRECT_CREDIT      = 'Direct Credit' ;       // AT-3189
    
    // suppression statuses - must match lightning component statuses
    public static final String SUPPRESSED_YES = 'YES';
    public static final String SUPPRESSED_NO = 'NO';
    public static final String SUPPRESSED_PARTIAL = 'PARTIALLY';
    
    public static final String SUPPRESSION_REASON_VOID = 'Void';
    public static final String DELETE_BUTTON = 'Delete';
    public static final string TARIFFLIMIT = 'Tariff Limit';
    public static final string INVALID =  NAMESPACEPREFIX + 'Invalid__c';
    
    public static final String OBJDEBTRECOVERYINSTALMENT = 'DebtRecoveryInstalment'; // 27 Aug 2018, Mohit
    
    //AT-3412
    public static final String NOERROR = Label.GlAp_NoError;
    public static final String ERROR = 'Error';
    public static final String SPDINACTIVE = Label.GlAp_SPDInActive;
    public static final String ADUINACTIVE = Label.GlAp_ADUInactive ;
    public static final String READTIMETABLETHRESHOLDINVALID = Label.GlAp_ReadTimetableThresholdInvalid; 
    public static final String READINGREJECTED =  Label.GlAp_LowerThresholdReadingRejected;    //AT-3854
    public static final String READINGREJECTEDUPPER = Label.GlAp_UpperThresholdReadingRejected; //AT-3854
    
    // Ankit Gangwani, AT-3413
    public static final String JOBTYPEAPINAME       = 'JOB_TYPE';
    public static final String JOBTYPELABEL			= 'Job Type';
    public static final String BATCHJOBSAPINAME		= 'BatchJobs';
    public static final String NEXTSCHEDULEDAPINAME	= 'Next_Scheduled';
    public static final String NEXTSCHEDULEDLABEL	= 'Next Scheduled';
    public static final String CRONEXPRESSIONAPINAME= 'cronExpression';
    public static final String STATUSAPINAME        = 'STATUS';
    public static final String FREQUENCYAPINAME     = 'FREQUENCY';
    public static final String SUBMITTEDBYAPINAME   = 'SUBMITTED_BY';
    public static final String SUBMITTEDBYLABEL		= 'SUBMITTED BY';
    public static final String TOTALRECORDSAPINAME  = 'TOTAL_RECORDS';
    public static final String TOTALRECORDSLABEL	= 'TOTAL RECORDS';    
    public static final String SUCCESSAPINAME       = 'SUCCESS';
    public static final String FAILUREAPINAME       = 'FAILURE';
    public static final String JOBENDTIMEAPINAME    = 'Job_End_Time';
    public static final String JOBENDTIMELABEL      = 'Job End Time';
    public static final String VIEWREPORTLABEL		= 'View Report';
    public static final String PREDICTMODE          = 'predict';  // AT-2340 
    public static final String BATCHJOBSACTIONSAPINAME = 'Batch_Jobs_Actions';
    
    public static final String SUCCESSFUL 			= 'YES';  //AT-3377    
    public static final String MAX        			= 'max'; //AT-2431
    public static final String BUDGETPLAN 			= 'Budget Plan'; //AT-2431 
    public static final String READTIMETABLECHANGE  = 'Read Timetable Change';   //AT-2431 
    public static final String MAIN_DEVICE			= 'Main';	// AT-3676
    public static final String SUB_DEVICE  			= 'Sub';  // AT-3676
    public static final String SALESVOIDMANAGEMENTEMAIL = 'SalesVoidManagementEmail';
    public static final String ATLASSUPPORT = 'ATLAS Support';
    public static final String EXCEPTIONMESSAGE = 'Exception: ';
    public static final String EXCEPTIONREASON = ' , Reason: ';
    public static final String BOOKEXPORT = 'BookExport';
    public static final String BILLED = 'Billed';  // AT-3852
    public static final String INFORMATION_STATEMENT = 'Information Statement'; // AT-4134
    public static final String PAYMENTALLOCATION_BILLALLOCATIONSTATUS_NONE = 'None';
    public static final String OBJ_CHANNELOPEN = 'ChannelOpen';
    public static final String RURALOUTLET_BILLINGTYPE_UNCONTROLLED = 'Uncontrolled';
    public static final String RURALOUTLETRECORDTYPE = 'Rural Outlet';
    public static final String RURALGROSSCONSUMPTION_TYPE_METERED = 'Metered';
    public static final String NORMAL = 'Normal';  // AT-4507
    public static final String START  = 'Start';  // AT-4507
    public static final String FINISH = 'Finish';  // AT-4507
    public static final String OBJRURALTRANSFER = 'RuralTransfer';        // AT-4494
    public static final String HEAD = 'Head';        // AT-4507
    public static final String TEMPORARY = 'Temporary';
    public static final String PERMANENT =  'Permanent';  
    public static final String CONCESSIONSYSTEM =  'CCS';    
    public static final String MESSAGE_API_SUFFIX =  'Message__c'; //Sudhir: AU3 AT-4954
    public static final String HELDBILLTYPE =  'Held';  // UL-430
    public static final String TARIFFLIMIT_STATUS_APPROVED =  'Approved'; 
    public static final String GROUPTYPE_NAME_TARIFFLIMIT =  'Tariff Limit'; 
    public static final String BILL_TEMPLATE_LIBRARY_NAME_FIELD = NAMESPACEPREFIX + 'BillTemplateLibraryName__c';  
    public static final String DONOTPRINTAPINAME = NAMESPACEPREFIX + 'DoNotPrintBelow__c';   
    public static final decimal DONOTPRINTVALUE = 10.00;  
    public static final String BILL_TEMPLATE_LIBRARY_NAME_VALUE = 'PDF Bill Templates'; 
    public static final String DEVICEUPLOADLIBRARYAPINAME = NAMESPACEPREFIX + 'DeviceUploadLibrary__c';
    public static final String DEVICEUPLOADLIBRARYVALUE = 'Device Upload';
    public static final String USEROLLINGAVERAGEAPINAME = NAMESPACEPREFIX + 'UseRollingAverage__c';
    public static final boolean USEROLLINGAVERAGEAPINAMEVALUE = true;
    public static final String EXPORTBOOKLIBRARYAPINAME = NAMESPACEPREFIX + 'ExportBooksLibrary__c';
    public static final String EXPORTBOOKLIBRARYVALUE = 'Export Books';
    public static final String BOOKIMPORTAPINAME = NAMESPACEPREFIX + 'BooksImport__c';
    public static final String BOOKIMPORTVALUE = 'Books Import';
    public static final String REQUESTEDREADINGEXPORTLIBRARYAPINAME = NAMESPACEPREFIX + 'RequestedReadingExportLibrary__c';
    public static final String REQUESTEDREADINGEXPORTLIBRARYVALUE = 'Requested Reading';
    public static final String CONCESSIONIMPORTAPINAME = NAMESPACEPREFIX + 'ConcessionImport__c';
    public static final String CONCESSIONIMPORTVALUE = 'Concession Import';
    public static final String CONCESSTIONEXPOTAPINAME = NAMESPACEPREFIX + 'ConcessionExportLibrary__c';
    public static final String CONCESSTIONEXPORTVALUE = 'Concession Export';
    public static final String BILLINGCALCULATIONENDPOINTAPINAME = NAMESPACEPREFIX + 'BillingCalculationEndpoint__c';
	public static final String PDFGENERATIONENDPOINTAPINAME = NAMESPACEPREFIX + 'PDFGenerationEndpoint__c';
	public static final String PDFTEMPLATEUPLOADENDPOINTAPINAME = NAMESPACEPREFIX + 'PDFTemplateUploadEndpoint__c';
	public static final String HTMLTOPDFGENERATIONENDPOINTAPINAME = NAMESPACEPREFIX + 'HTMLToPDFGenerationEndPoint__c';
	public static final String XSLTUPLOADENDPOINTAPINAME = NAMESPACEPREFIX + 'XSLTUploadEndpoint__c';
	public static final String BILLTRANSFERENDPOINTAPINAME = NAMESPACEPREFIX + 'BillTransferEndpoint__c';
	public static final String BATCHBILLINGJOBENDPOINTAPINAME = NAMESPACEPREFIX + 'BatchBillingJobEndpoint__c';
	public static final String BATCHBILLINGJOBSTATUSENDPOINTAPINAME = NAMESPACEPREFIX + 'BatchBillingJobStatusEndpoint__c';
	public static final String BATCHBILLINGIMMEDIATEJOBENDPOINTAPINAME = NAMESPACEPREFIX + 'BatchBillingJobImmediateEndpoint__c';
	public static final String INFORMATIONSTATEMENTAPINAME = NAMESPACEPREFIX + 'Information_Statement_Endpoint__c';
    public static final String PRINTBILLAPINAME = NAMESPACEPREFIX + 'PrintBill__c';
    public static final String BILLINGFORECASTAPINAME = NAMESPACEPREFIX + 'BillingForecastEndpoint__c';
    
    public static final String ENVIROMENTSETTINGQUERY =  'SELECT ' + BILLINGCALCULATIONENDPOINTAPINAME + ','+PDFGENERATIONENDPOINTAPINAME + ','+ PDFTEMPLATEUPLOADENDPOINTAPINAME 
        + ','+ HTMLTOPDFGENERATIONENDPOINTAPINAME + ','+XSLTUPLOADENDPOINTAPINAME + ','+ BILLTRANSFERENDPOINTAPINAME + ','+ BATCHBILLINGJOBENDPOINTAPINAME+ ','+
        BATCHBILLINGJOBSTATUSENDPOINTAPINAME+ ','+ BATCHBILLINGIMMEDIATEJOBENDPOINTAPINAME+ ','+ INFORMATIONSTATEMENTAPINAME+ ','+PRINTBILLAPINAME+',' +BILLINGFORECASTAPINAME
        + ' FROM ' + NAMESPACEPREFIX +'EnvironmentSettings__mdt LIMIT 1';
    
    public static final String ENVSETTINGCONCESSIONEXPORTQUERY =  'SELECT ' + CONCESSTIONEXPOTAPINAME + ' FROM ' + NAMESPACEPREFIX +'EnvironmentSettings__mdt LIMIT 1';
    public static final String ENVIROMENTSETTINGCONCESSIONIMPORTQUERY =  'SELECT MasterLabel,'+ CONCESSIONIMPORTAPINAME + ' FROM ' + NAMESPACEPREFIX +'EnvironmentSettings__mdt  WHERE DeveloperName = \'Default\'';
    public static final String ENVIROMENTSETTINGREQUESTEDREADINGEXPORTQUERY =  'SELECT MasterLabel,'+ REQUESTEDREADINGEXPORTLIBRARYAPINAME + ' FROM ' + NAMESPACEPREFIX +'EnvironmentSettings__mdt  WHERE DeveloperName = \'Default\'';
    public static final String ENVIROMENTSETTINGBOOKIMPORTQUERY =  'SELECT MasterLabel,'+ BOOKIMPORTAPINAME + ' FROM ' + NAMESPACEPREFIX +'EnvironmentSettings__mdt  WHERE DeveloperName = \'Default\'';
    public static final String ENVIROMENTSETTINGEXPORTLIBRARYQUERY =  'SELECT MasterLabel,'+ EXPORTBOOKLIBRARYAPINAME + ' FROM ' + NAMESPACEPREFIX +'EnvironmentSettings__mdt  WHERE DeveloperName = \'Default\'';
    public static final String ENVIROMENTSETTINGBILLTEMPLATELIBRARYQUERY =  'SELECT MasterLabel,'+ BILL_TEMPLATE_LIBRARY_NAME_FIELD + ' FROM ' +  NAMESPACEPREFIX +'EnvironmentSettings__mdt  WHERE DeveloperName = \'Default\'';
    public static final String ENVIROMENTSETTINGDEVICEUPLOADQUERY =  'SELECT '+ DEVICEUPLOADLIBRARYAPINAME + ' FROM ' + NAMESPACEPREFIX +'EnvironmentSettings__mdt  WHERE DeveloperName = \'Default\'';
    public static final String FINALBILLQUERY =  'SELECT ' + DONOTPRINTAPINAME + ' FROM ' + NAMESPACEPREFIX + 'FinalBill__mdt LIMIT 1'; 
    public static final String ROLLINGDAILYUSAGEQUERY =  'SELECT Id,' + USEROLLINGAVERAGEAPINAME + ' FROM ' + NAMESPACEPREFIX + 'RollingDailyUsage__mdt LIMIT 1'; 
    public static final String AMENDMENT_REASON_FAILED_CHEQUE = 'Failed Cheque';
}