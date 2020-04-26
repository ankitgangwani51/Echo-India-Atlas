/************************************************************************************************************
@author         Echo : Amit K.
@date           10-May-2018
@description:   This is the constants class for all static fields used in the Area object                
**************************************************************************************************************/
public class GlUt_APIConstantsArea {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  AREAAPINAME = NAMESPACEPREFIX + 'Area__c';
    // Reading Mode object fields API Names
    public static final string  ID = 'Id';
    public static final string  NAME = 'Name';
    public static final string  AREANAME = NAMESPACEPREFIX + 'Area__c.Name';
}