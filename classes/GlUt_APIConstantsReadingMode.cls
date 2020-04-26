/************************************************************************************************************
@author         Echo : Amit K.
@date           09-May-2018
@description:   This is the constants class for all static fields used in the Reading Mode object                
**************************************************************************************************************/
public class GlUt_APIConstantsReadingMode {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  READINGMODEAPINAME = NAMESPACEPREFIX + 'ReadingMode__c';
    
    // Reading Mode object fields API Names
    public static final string  ID = 'Id';
    public static final string  NAME = 'Name';
    public static final string  READPERIODAPINAME = NAMESPACEPREFIX + 'ReadPeriod__c';
    public static final string  DEPOTAPINAME = NAMESPACEPREFIX + 'Depot__c';
    public static final string  AREAAPINAME  = NAMESPACEPREFIX + 'Area__c';
    public static final string  BOOKAPINAME  = NAMESPACEPREFIX + 'Book__c';
    public static final string  MODEAPINAME  = NAMESPACEPREFIX + 'Mode__c';
    public static final string  ESTIMATEDATEAPINAME = NAMESPACEPREFIX + 'EstimateDate__c';
    public static final string  ESTIMATEDATEFIELDREFERENCE = NAMESPACEPREFIX + 'ReadingMode__c.' + NAMESPACEPREFIX +'EstimateDate__c';   
    
}