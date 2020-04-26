/************************************************************************************************************
@author         Echo : Swati Mathur
@date           08-May-2018
@description:   This is the constants class for all static fields used in the Read Timetable object                
**************************************************************************************************************/
public class GlUt_APIConstantsReadTimetable {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    //objects API Name
    public static String  READTIMETABLEAPINAME 		= NAMESPACEPREFIX + 'ReadTimetable__c';
    
    //object fields API Names	
    public static final String READTIMETABLENAMEAPINAME			= 'Name';    
    public static final String READFREQUENCYAPINAME     	 	= NAMESPACEPREFIX + 'ReadFrequency__c'; 

}