/************************************************************************************************************
@author         Echo : Amit K.
@date           22-May-2018
@description:   This is the constants class for all static fields used in the Scheduled Read object                
**************************************************************************************************************/
public class GlUt_APIConstantsScheduledRead {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    //objects API Name
    public static String  SCHEDULEDREADAPINAME 		= NAMESPACEPREFIX + 'ScheduledRead__c';
    public static final String ID     	 	        = 'Id';
    public static final String READPERIODAPINAME    = NAMESPACEPREFIX + 'ReadPeriod__c';
}