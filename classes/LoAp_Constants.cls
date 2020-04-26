/************************************************************************************************************
@author         ECHO : Mohit Tayal
@date           06-Feb-2018
@description:   This is the constants class for all static strings used in this namespace
@revision:      07-Mar-2018 MT - Added the namespace prefix
**************************************************************************************************************/
public class LoAp_Constants {

    // The prefix for this namespace
    public static string NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static string PREFIX          = 'LoAp_';
    public static String LOCATIONAPINAME = NAMESPACEPREFIX + 'Location__c';
    
    public static String BUNDLEITEMLABEL       = 'Bundle Item';
    public static String SERVICETYPELABEL      = 'Service Type';
    public static String BUNDLELABEL           = 'Bundle';
    public static String NEWDEVICE             = 'NewDevice';
    public static String REMOVEDEVICE          = 'RemoveDevice';
    public static String EXCHANGEDEVICE        = 'ExchangeDevice';
    public static String TEXT                  = 'text'; 
    public static String AVAILABLESERVICELABEL = 'Available Services';
    public static String AVAILABLESERVICENAME  = 'AvailableServices';
    public static String TYPEOFDEVICE          = 'Device Type';
    public static String SERVICETYPE           = 'Service Type';
    
    /* Contants related to Meter Books Components*/
    public static String ACTUALMODE            = 'Actual';
    public static String ESTIMATEMODE          = 'Estimate';
    public static String AREASECTION           = 'Area';
    public static String DEPOTSECTION          = 'Depot';
    public static String BOOKSECTION           = 'Book';
    public static String HIGH                  = 'High';
    public static String LOW                   = 'Low';
    public static String INITIALISED           = 'Initialised';
    public static String METEREXPORT           = 'Meter Export';
    public static String BATCHPROCESSOPERATION  = 'Export';
    public static String BATCHPROCESSOPERATIONIMPORT  = 'Import';
    public static String BATCHPROCESSREADINGTYPE  = 'Reading';    
    public static String BATCHPROCESSEXPORTBOOKCLASSNAME  = 'LoBt_ExportBooks';
    public static String BATCHPROCESSEXPORTREQUESTEDREADINGCLASSNAME = 'LoBt_ExportRequestedReadings';    
    public static String BATCHPROCESSSCHEDULEESTIMATES = 'LoBt_ScheduledEstimates';
    public static String BATCHPROCESSSWEEPUPESTIMATES = 'LoBt_SweepUpEstimates';
    public static String BATCHPROCESSCONSCESSIONEXPORT = 'CuBt_ConcessionExport';
    public static String FIRSTCHARACTER = 'a';
    public static String BATCHPROCESSTYPE  = 'Meter Book';
    public static String BATCHPROCESSTYPECONCESSION  = 'Concession';
    public static String LOADING  = 'Loading';   // AT-2442
    public static String VIEWER_PERMISSION  = 'V';   // AT-2442 Viewer permission
    public static String READING_IMPORT = 'LoBt_ReadingImport'; // AT-2442 
    public static String CONCESSION_IMPORT = 'CuBt_ConcessionImport'; // AT-4854
    
    public static String ACTION = 'Action';		// Heading name for button column
    public static String CANCEL                     = 'Cancel';
    public static String READPERIODLABEL            = 'Read Period';
    public static String READTIMETABLELABEL         = 'Read Timetable';
    public static String PERIODSTARTLABEL           = 'Period Start';
    public static String PERIODENDLABEL             = 'Period End';
    public static String READINGTIMETABLELABEL      = 'Reading Timetable'; 
    public static String NOTIFICATIONUSERFIELDNAME  = 'Notification User';
    public static String USERLABEL					= 'User';
    public static String REFERENCEFIELD             = 'reference';
    public static String READFREQUENCYLABEL         = 'Read Frequency';
    public static String READPERIODNOLABEL          = 'Read Period No.';
    public static String LoAp_EstimationSchedulingLABEL = NAMESPACEPREFIX + 'LoAp_EstimationScheduling';
    
    public static String DIRECTDEBITEXPORT          = 'Direct Debit Export';   //AT-2895
    public static String IMPORTFROMFILEFALSE        = 'No'; 				   //AT-2895
    
    public static String ENDDATE                    = 'End Date';
    public static String EFFECTIVEDATE              = 'Effective Date';
    public static String ACTIVEFIELD                = 'Active__c';
    public static String CHANGEBUTTONLABEL          = 'Change Bundle';
    public static String MAKEACTIVELABEL            = 'Make Active';
    public static String ACTIVELABEL                = 'Active';
    public static String YES                        = 'Yes';
    public static String NO                         = 'No';
    
    // For Stepped Tariff Process, Ankit Gangwani
    public static String Id							= 'Id';
    public static String NameLabel					= 'Name';
    public static String Regular					= 'Regular';
    public static String Billable					= 'Billable';
    public static String Title						= 'Title';
    public static String ContentSize				= 'ContentSize';
    public static String FileType					= 'FileType';
    public static String ContentDocumentId			= 'ContentDocumentId';
    public static String ContentDocument			= 'ContentDocument';    
    public static String NonBillable				= 'Non Billable';
    public static String supplyPointId				= 'supplyPointId';
    public static String DeviceDigit				= 'DeviceDigit';
    public static String lastReading				= 'lastReading';
    public static String fileName					= 'File Name';
    public static String ContentDocumentLink		= 'ContentDocumentLink'; 
    public static String Cancelled					= 'Cancelled';
    public static String DeviceId					= 'DeviceId';
    public static String NewLabel					= 'New';
    public static String processed					= 'processed';
    public static String scheduleReadId				= 'scheduleReadId';
    public static String amendListSize				= 'amendListSize';
    public static String readingId					= 'readingId';    
    public static String RenewalClassLabel			= 'BlAp_SteppedTariffRenewalCtrlr';
    public static String STLocationClassLabel		= 'BlAp_SteppedTariffRenewalCtrlr';
    public static String STAmendmentClassLabel 		= 'BlAp_SteppedTariffAmendmentCtrlr';

    public static String SupplyPointDeviceId     	= 'supplyPointDeviceId';   //AT-3855

    public static String MAKEBUNDLEACTIVEAVAILABLEBUNDLE  = NAMESPACEPREFIX + 'LoAp_MakeBundleActiveAvailableBundle'; 
    
    public static String SAMESUPPLYPOINTERROR    = 'The Bundle is already linked to this Supply Point';
    public static String TARIFFLIMITBUNDLEERROR  = 'Default Bundle Cannot be a Tariff Limit Bundle';
    public static String NEXTRUN  = 'NextRun';
    public static String LASTRUN  = 'LastRun';
    public static String DATEFORMAT  = ' yyyy-MM-dd\'T\'HH:mm:ss';
    public static String BILLABLETYPEINVALID  = 'Invalid';
    
    //AT-4099: AU1
    public static String LANDLORD						= 'Landlord' ;
    public static String OWNER							= 'Owner' ;
    public static String INFORMATION_STATEMENT			= 'Information Statement' ;
    
    //  public static String SINGLESHARED_CHANNEL			= 'Channel - Single Shared' ; //AT-4512
    public static String  SUPPLYPOINTNAMELABEL = 'Supply Point';   //AT-5330
    public static String LOCATIONADDRESSLABEL = 'Location Address'; //AT-5413, Ankit, 12/03/2019
    
    public static String SERVICENAMELABEL          =	'Service No' ;
    public static String SERVICESTARTDATELABEL     =    'Service Start Date';
    public static String BILLINGCONTRACTLABEL      =    'Billing Contract';
    public static String SUPPLYPOINTLABEL          =    'Supply Point';
    public static String DEBTAMOUNTLABEL          =    'Debt Amount';
    public static String DEBTAMOUNTAPI          =    'DebtAmount';
    public static String READINGLABEL         =    'Reading';
    
    
    
    
    
}