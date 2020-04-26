/************************************************************************************************************
@author         Echo : Swati Mathur
@date           09-May-2018
@description:   This is the constants class for all static fields used in the Read Timetable object                
**************************************************************************************************************/
public class GlUt_APIConstantsReadPeriod {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    //objects API Name
    public static String  READPERIODAPINAME 		= NAMESPACEPREFIX + 'ReadPeriod__c';
    
    //object fields API Names	
    public static final String NAMEAPINAME     	                = 'Name'; 
    public static final String BILLINGPERIODSTARTAPINAME     	= NAMESPACEPREFIX + 'BillingPeriodStart__c'; 
    public static final String BILLINGPERIODENDAPINAME     	 	= NAMESPACEPREFIX + 'BillingPeriodEnd__c'; 
    public static final String READSTARTAPINAME     	     	= NAMESPACEPREFIX + 'ReadStart__c';
    public static final String READENDAPINAME     	 	        = NAMESPACEPREFIX + 'ReadEnd__c'; 
    public static final String ORDERAPINAME     	 	        = NAMESPACEPREFIX + 'Order__c';
    public static final String ID     	 	                    = 'Id';
    public static final String READTIMETABLEAPINAME     	 	= NAMESPACEPREFIX + 'ReadTimeTable__c';

}