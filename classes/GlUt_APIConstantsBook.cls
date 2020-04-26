/************************************************************************************************************
@author         Echo : Amit K.
@date           08-May-2018
@description:   This is the constants class for all static fields used in the Book object                
**************************************************************************************************************/
public class GlUt_APIConstantsBook {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  BOOKAPINAME = NAMESPACEPREFIX + 'Book__c';
    
    // Book object fields API Names
    public static final string  ID = 'Id';
    public static final string  NAME = 'Name';
    public static final string  READTIMETABLEAPINAME = NAMESPACEPREFIX + 'ReadTimetable__c';
    public static final string  DEPOTAPINAME = NAMESPACEPREFIX + 'Depot__c';
    public static final string  BOOKNAME = NAMESPACEPREFIX + 'Book__c.Name';
    
    public static final string  BUDGETRESETMONTHAPINAME = NAMESPACEPREFIX + 'BudgetResetMonth__c';
    public static final string  READFREQUENCYAPINAME = NAMESPACEPREFIX + 'ReadFrequency__c';
}