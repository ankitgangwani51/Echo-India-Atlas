/************************************************************************************************************
@author         Echo: Amit K.
@date           22-May-2018
@description:   This is the constants class for all static strings used in this namespace(Meter Book Batches)
**************************************************************************************************************/
public class LoBt_Constants {
    public static string NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    public static final String DEVICEREFERENCE = 'Device Reference';
    public static final String ACCOUNTNAME = 'Account Name';
    public static final String LOCATIONSUPPLYADDRESS = 'Location Supply Address';
    public static final String DEPOT = 'Depot';
    public static final String BOOKNUMBER = 'Book Number';
    public static final String WALKORDER = 'Walk Order';
    public static final String VOIDS = 'Void';
    public static final String MANUFACTURER = 'Manufacturer';
    public static final String SERIALNUMBER = 'Serial Number';
    public static final String DEVICELOCATION = 'Device Location';
    public static final String GEOLOCATION = 'Geolocation';
    public static final String SPECIALINSTRUCTION = 'Special Instructions';
    public static final String LASTREADING = 'Last Reading';
    public static final String LASTREADINGDATE = 'Last Reading Date';
    public static final String LASTREADINGMETHOD = 'Last Reading Method';
    public static final String LASTACTUALREADING = 'Last Actual Reading';
    public static final String LASTACTUALREADINGDATE = 'Last Actual Reading Date';
    public static final String EXPECTEDCONSUMPTIONHIGH = 'Expected Consumption High';
    public static final String EXPECTEDCONSUMPTIONLOW = 'Expected Consumption Low';
    public static final String READREASON = 'Read Reason (Requested Read)';
    public static final String READBYDATE = 'Read By Date (Requested Read)';
    public static final String COMMENTS = 'Comments (Requested Read)';
    public static final String TARGETREADINGDATE = 'Target Reading Date';
    public static final String READPERIODID = 'Read Period Id';
    public static final String SHARE_TYPE = 'V';
    public static final String BRQSTATUS = 'Completed';
    public static final String BRQSTATUSERRORS= 'Errors';
    public static final String READINGREQUESTNEWSTATUS = 'New';
    public static final String READINGREQUESTEXPORTEDSTATUS = 'Exported';
    public static final String READINGMETHOD = 'Actual';
    public static final String FILENAME = ' File Name: ';
    public static final String TOTALNUMBEROFBOOKEXTRACTED = ' Total No. of Book Extracted: ';
    public static final String TOTALNUMBEROFSUPPLYPOINTEXTRACTED = ' Total No. of Supply Point Extracted: ';
    public static final String TOTALNUMBEROFSUPPLYPOINTEXTRACTPERBOOK = 'Total No. of SupplyPoint Extracted per Book:';
    public static final String NUMBEROFSUPPLYPOINT = ' No. Of SupplyPoint: ';
    public static final String BOOKNAME = 'Book Name: ';
    public static final String AREANAME = 'Area Name: ';
    public static final String DEPOTNAME = 'Depot Name: ';
    public static final String AREALABEL = 'Area';
    public static final String DEPOTLABEL = 'Depot Name';
    public static final String SUPPLYPOINT = 'Supply Point';
    public static final String TOTALSUPPLYPOINTS = 'Total SupplyPoints: ';
    public static final String DATETIMEFORMAT = 'yyyy-MM-dd_hh-mm-ss';
    public static final String DATEFORMAT = 'yyMMdd';
    public static final String ZIPFILEEXTENSION = '.zip';
    public static final String TXTFILEEXTENSION = '.txt';
    public static final String CSVFILEEXTENSION = '.csv';
    public static final String XMLFILEEXTENSION = '.xml';
    public static final String INVALIDPARAMETERSERROR = 'Invalid Parameters';
    public static final String COMPANYREADING = 'Company Reading';
    public static final String SYSTEMESTIMATED = 'System Estimated';
    public static final String READINGTYPEREGULAR = 'Regular';
    public static final String SWEEPUPTYPE = 'Sweep Up';
    public static final String BRQPROCESSINGSTATUS = 'Processing';  //AT-3204 Starts/Ends Here
    public static final String ENTITLEMENTRENEWEDERROR = 'has already been renewed for this period';  //AT-3605
    public static final String RURALENTITLEMENTLABEL = 'Rural Entitlement';
    public static final String ENTITLEMENTRENEWAL = 'Entitlement Renewal';  //AT-3605
    public static final String Advice	          =	'Advice' ;
    //Start: AT-4767
    public static final String LOCATION_IMPORT_LIBRARY				=	'Location Import' ;	
    public static final String BATCH_REQUEST_OPERATION_TYPE			=	'Import' ;	
    public static final String MISSING_CITY							=	'City' ;	
    public static final String MISSING_POSTALCODE					=	'Postal Code' ;
    public static final String MISSING_STATE						=	'State' ;
    public static final String MISSING_STREET						=	'Street' ;
    public static final String MISSING_LOCATION_TYPE				=	'Location Type' ;
    public static final String MISSING_BUILD_DATE					=	'Build Date' ;
    public static final String MISSING_SUPPLYPOINT_USAGE_TYPE		=	'Supply Point Usage Type' ;
    public static final String MISSING								=	'Missing ' ;
    //End: AT-4767
    public static final String MISSING_CURRENT_MANUFACTURER	    =	'Current Manufacturer' ;
    public static final String MISSING_CURRENT_SERIAL_NUMBER	=	'Current Serial Number' ;
    public static final String MISSING_DEVICE_SERIAL_NUMBER	    =	'Device Serial No.' ;
    public static final String MISSING_DEVICE_MANUFACTURER	    =	'Device Manufacturer' ;
    public static final String MISSING_DEVICE_SIZE	            =	'Device Size' ;
    public static final String MISSING_INSTALLATION_DATE	    =	'Installation Date' ;
    public static final String MISSING_DEVICE_DIGITS	        =	'Device Digits' ;
    public static final String MISSING_SUPPLY_POINT          	=	'SupplyPoint' ;
    public static final String MISSING_REMOVAL_DATE         	=	'Removal Date' ;
    public static final String MISSING_FINAL_READING	        =	'Final Reading' ;
    public static final String MISSING_INITIAL_READING	        =	'Initial Reading' ;
    public static final String MISSING_INITIAL_READING_DATE	    =	'Initial Reading Date' ;
    public static final String MISSING_LOCATION	                =	'Location' ;
    public static final String MISSING_BUNDLES	                =	'Bundles' ;
    public static final String EXCHANGE_METER	                =	'E' ;
    public static final String NEW_METER	                    =	'N' ;
    public static final String REMOVE_METER	                    =	'R' ;
    public static final String EXCHANGE_FINAL	                =	'Final' ;
    public static final String EXCHANGE_INITIAL	                =	'Initial' ;
    public static final String DEVICE_IMPORT	                =	'Device Import' ;
    public static final String INVALID_BUNDLE	                =	'Invalid Bundle' ;
    public static final String TOTAL_NO_ERRORS	                =	'Total Number Of Errors: ' ;
    public static final String NUMBER_OF_AVAILABLE_BUNDLE   	=	'Number of Available Bundle Created: ' ;
    public static final String NUMBER_OF_SUPPLYPOINT	        =	'Number of Supply Point Created: ' ;
    public static final String NUMBER_OF_SUPPLY_POINT_DEVICE	=	'Number of Supply Point Device Created: ' ;
    public static final String NUMBER_OF_READING_CREATED	    =	'Number of Readings Created: ' ;
    public static final String NUMBER_OF_DEVICES_CREATED	    =	'Number of Devices Created: ' ;
    public static final String DEVICE_ALREADY_REMOVED_EXCHANGED	=	'Device has already been removed/exchanged' ;
    public static final String MISSING_DEVICE	                =	'Missing Device' ;
    public static final String NO_ACTIVE_SUPPLYPOINT	        =	'No Active Supply Point' ;
    public static final String UNMEASURED_SUPPLY_POINT	        =	'Supply point defined as unmeasured – Device cannot be attached' ;
    
    public static final String ENVSETTINGDEVICEUPLOADQUERY =  'SELECT ' + NAMESPACEPREFIX + 'DeviceUploadLibrary__c FROM ' + NAMESPACEPREFIX + 'EnvironmentSettings__mdt LIMIT 1'; //Ankit:condev deployment issue
    public static final String DEVICEUPLOAD_FIELD = NAMESPACEPREFIX + 'DeviceUploadLibrary__c';       
    public static final String DEVICEUPLOAD_VALUE = 'Device Upload'; 
    
    public static final String CENTERLINKMETADATAQUERY = 'SELECT QualifiedApiName,' + NAMESPACEPREFIX + 'UserID__c,' + NAMESPACEPREFIX + 'Username__c,' + 
        NAMESPACEPREFIX + 'Password__c,' + NAMESPACEPREFIX + 'PasswordType__c' + ' FROM '+ NAMESPACEPREFIX +'CentrelinkUserCredential__mdt WHERE ' + 
        NAMESPACEPREFIX + 'Username__c  != null LIMIT 1'; //Ankit:condev deployment issue
    
    public static final String QUALIFIED_FIELD 		= 'QualifiedApiName';       
    public static final String USERID_FIELD 		= NAMESPACEPREFIX + 'UserID__c';       
    public static final String USERNAME_FIELD 		= NAMESPACEPREFIX + 'Username__c';
    public static final String PASSWORD_FIELD 		= NAMESPACEPREFIX + 'Password__c';
    public static final String PASSWORDTYPE_FIELD 	= NAMESPACEPREFIX + 'PasswordType__c';
    public static final String QUALIFIED_VALUE 		= 'CentrelinkUser'; 
    public static final String USERID_VALUE 		= 'TestUserId'; 
    public static final String USERNAME_VALUE 		= 'TestUsername';
    public static final String PASSWORD_VALUE 		= 'TestPassword123';
    public static final String PASSWORDTYPE_VALUE 	= 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest';
    public static final String CENTERLINKEXCEPTIONMETADATAQUERY = 'SELECT QualifiedApiName,' + NAMESPACEPREFIX + 'ExceptionString__c,' + 
                                                                   NAMESPACEPREFIX + 'Meanings__c,' + NAMESPACEPREFIX + 'PossibleFollowupActions__c' + 
                                                                   ' FROM ' + NAMESPACEPREFIX +'CentrelinkException__mdt WHERE ' + 
        														   NAMESPACEPREFIX + 'Meanings__c  != null'; //Ankit:condev deployment issue
    
    public static final String EXCEPTIONSTRING_FIELD 		= NAMESPACEPREFIX + 'ExceptionString__c';       
    public static final String MEANINGS_FIELD 				= NAMESPACEPREFIX + 'Meanings__c';
    public static final String POSSIBLEFOLLOWUP_FIELD 		= NAMESPACEPREFIX + 'PossibleFollowupActions__c';
    public static final String EXCEPTIONSTRING_VALUE 		= 'TestUserId'; 
    public static final String MEANINGS_VALUE 				= 'TestUsername';
    public static final String POSSIBLEFOLLOWUP_VALUE 		= 'TestPassword123';    
    
    public static final String ENTITLEMENTACTIVE = 'EntitlementActive';
    public static final String ACCOUNT_TYPE_HOUSEHOLD = 'HouseHold';
    
}