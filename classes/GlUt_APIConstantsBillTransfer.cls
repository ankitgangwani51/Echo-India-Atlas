/************************************************************************************************************
@author         Echo : Dependra Singh
@date           13-Nov-2018
@description:   This is the constants class for all static fields used in the Bill Transfer object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBillTransfer {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bill Tranfer Object API Name
    public static String  BILLTRANSFERAPINAME = NAMESPACEPREFIX + 'BillTransfer__c';
    public static String  TRANSFERTOCONTRACTAPINAME = NAMESPACEPREFIX + 'TransferToContract__c';
    public static String  TRANSFERREASONAPINAME = NAMESPACEPREFIX + 'TransferReason__c';
    public static String  TRANSFERFROMCONTRACTAPINAME = NAMESPACEPREFIX + 'TransferFromContract__c';
    public static String  TRANSFERAMOUNTAPINAME = NAMESPACEPREFIX + 'TransferAmount__c';
    public static String  LOCATIONAPINAME = NAMESPACEPREFIX + 'Location__c';
}