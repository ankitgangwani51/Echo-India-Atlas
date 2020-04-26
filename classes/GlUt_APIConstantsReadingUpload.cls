/******************************************************************************
@author         Neha Rajput
@date           21 may 2018
@description    Reading Upload Constants
*******************************************************************************/
public class GlUt_APIConstantsReadingUpload {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String READINGUPLOADEAPINAME = NAMESPACEPREFIX + 'ReadingUpload__c';
    
    // Reading Upload object fields API Names
    public static String Id						= 'Id';
    public static String BRQAPINAME 			= NAMESPACEPREFIX + 'BatchRequestQueue__c';
    public static String MANUFACTURERAPINAME 	= NAMESPACEPREFIX + 'Manufacturer__c';
    public static String SERIALNOAPINAME 		= NAMESPACEPREFIX + 'SerialNumber__c';
    public static String DEVICEREFERENCEAPINAME	= NAMESPACEPREFIX + 'DeviceReference__c';
    public static String READINGDATEAPINAME		= NAMESPACEPREFIX + 'ReadingDate__c';
    public static String READINGVALUEAPINAME 	= NAMESPACEPREFIX + 'ReadingValue__c';  //AT - 3174
    public static String READINGMETHODAPINAME	= NAMESPACEPREFIX + 'ReadingMethod__c';
    public static String READSOURCEAPINAME 		= NAMESPACEPREFIX + 'ReadSource__c';
    public static String REJECTIONREASONAPINAME	= NAMESPACEPREFIX + 'RejectionReason__c';    
    public static String READINGTYPEAPINAME		= NAMESPACEPREFIX + 'ReadingType__c';
    public static String BILLABLEAPINAME		= NAMESPACEPREFIX + 'Billable__c';
    public static String PROCESSEDAPINAME		= NAMESPACEPREFIX + 'Processed__c';
    public static String READPERIODIDAPINAME	= NAMESPACEPREFIX + 'ReadPeriodId__c';
    public static String TRIPPEDAPINAME 	    = NAMESPACEPREFIX + 'Tripped__c';
    public static String SKIPCODENAMEAPINAME    = NAMESPACEPREFIX + 'SkipCodeName__c';
	public static String REMARKAPINAME          = NAMESPACEPREFIX + 'Remarks__c';
    public static String READINGSTATUSAPINAME	= NAMESPACEPREFIX + 'ReadingStatus__c';
    public static String NEWWALKORDERAPINAME    = NAMESPACEPREFIX + 'NewWalkOrder__c';
    public static String READERAPINAME	        = NAMESPACEPREFIX + 'Reader__c';
    public static String READTTTHRESHOLDAPINAME	= NAMESPACEPREFIX + 'ReadTimetableThreshold__c';
    public static String READTIMETABLEAPINAME	= NAMESPACEPREFIX + 'ReadTimetableId__c';
    public static String AVERAGEDAILYUSAGEAPINAME	= NAMESPACEPREFIX + 'AverageDailyUsage__c';
    public static String ADVICEAPINAME	        = NAMESPACEPREFIX + 'Advice__c';      // AT-5209
    public static String CHECKSITOLERANCEAPINAME= NAMESPACEPREFIX + 'CheckServiceItemTolerance__c'; // UL-21, Ankit, 21/02/2019
    public static String READPERIODLOOKUPAPINAME= NAMESPACEPREFIX + 'ReadPeriod__c'; // CLB-18, Ankit, 03/04/2019
    public static String READTIMETABLELOOKUPAPINAME	= NAMESPACEPREFIX + 'ReadTimetable__c'; // CLB-18, Ankit, 03/04/2019
    public static String READINGAPINAME	= NAMESPACEPREFIX + 'Reading__c';

}