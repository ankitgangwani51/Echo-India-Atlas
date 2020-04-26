/************************************************************************************************************
@author         Echo : Amit K.
@date           10-May-2018
@description:   This is the constants class for all static fields used in the Depot object                
**************************************************************************************************************/
public class GlUt_APIConstantsDepot {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  DEPOTAPINAME = NAMESPACEPREFIX + 'Depot__c';
    // Reading Mode object fields API Names
    public static final string  ID = 'Id';
    public static final string  NAME = 'Name';
    public static final string  AREAAPINAME = NAMESPACEPREFIX + 'Area__c';    
    public static final string  DEPOTNAME = NAMESPACEPREFIX + 'Depot__c.Name';
}