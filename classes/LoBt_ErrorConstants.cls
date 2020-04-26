/******************************************************************************
@author      	Echo: Neha
@date      		07/06/2018
@description	 Class to define errors of LoBt_ReadingImport	
*******************************************************************************/
public class LoBt_ErrorConstants {
    
    public static String NUMOFFIELD          	= 'File do not include the correct number of fields in Line ';
    public static String READINGDATE_INVALID 	= 'Reading Date invalid in Line ';
    public static String WALKORDER_INVALID  	= 'New Walk Order invalid in Line ';
    public static String BILLABLE_INVALID   	= 'Invalid value of Billable in Line ';
    public static String TRIPPED_INVALID 	 	= 'Invalid value of Tripped in Line ';       
    public static String MANUFACTURER_INVALID   = 'Invalid Manufacturer';
    public static String SERIALNO_INVALID       = 'Invalid Serial Number';
	public static String READINGSOURCE_INVALID  = 'Invalid Reading Source';
    public static String READINGMETHOD_INVALID  = 'Invalid Reading Method';
    public static String READINGPERIOD_BLANK    = 'Invalid Setup (Reading Period Id Missing)';
    public static String NOACTIVESUPPLYPOINT    = 'Invalid Setup (No active supply point associated with device)';
    public static String READINGLESS            = 'Reading lower than Previous';
    public static String NOESTIMATECONSUMPTION  = 'No ADU exist for estimate consumption';   
    public static String READINGPERIOD_MISSING  = 'Reading period Id is missing';
    public static String NOREADINGMODE          = 'No Reading Mode exist';    
    public static String THRESHOLD_OUTSIDE      = 'Outside of Thresholds';
    public static String SKIP_CODE_ERROR        = 'Skip Code Error';
    public static String READING_DATE_MISSING   = 'Reading Date is missing';
    public static String READING_MISSING        = 'Reading is missing';
    public static String READSOURCE_MISSING     = 'Read Source is missing';
    public static String READINGMETHOD_MISSING  = 'Read Method is missing';
    public static String BILLABLE_MISSING       = 'Billable is missing';
    public static String READTIMETABLE_MISSING  = 'Read Timetable Id is missing';
    public static String TRIPPED_MISSING        = 'Tripped is missing';
    public static String READINGEXIST           = 'Reading already exist';
    public static String SKIPCODEORREADINGMISSING = 'Either Reading Value OR Skip Code Name should be populated';
    public static String ADVICE_INVALID         = 'Invalid value of Advice in Line ';  // AT-5209
    public static String ZERO_CONSUMPTION       = 'Zero Consumption ' ;  //CLB-19
    
    // CLB-18, Ankit, 03/04/2019
    public static String READINGPERIOD_INVALID  = 'Read Period Id is Invalid'; 
    public static String READINGTIMETABLE_INVALID  = 'Read Time Table Id is Invalid';
    public static String READTIMETABLENOTMATCHED = 'ReadTimeTable of Reading Upload is not matched with ReadTimeTable of Read Period';
     
}