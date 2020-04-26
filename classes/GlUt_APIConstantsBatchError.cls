/************************************************************************************************************
@author         Echo : Mohit Tayal
@date           31-May-2018
@description:   This is the constants class for all static fields used in the batch error object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsBatchError {
    
    // Get the prefix and append it to the object and fields api names
    public static final String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Batch Error Object API Name
    public static final String  BATCHERRORAPINAME = NAMESPACEPREFIX + 'BatchError__c';
    
    // Batch Error object fields API Names
    public static final String NAMEAPINAME = 'Name';
    public static final String ERRORDETAILSAPINAME = NAMESPACEPREFIX + 'ErrorDetails__c';
    public static final String BATCHREQUESTIDAPINAME = NAMESPACEPREFIX + 'BatchRequestQueue__c';
    public static final String OPERATINGRECORDIDAPINAME = NAMESPACEPREFIX + 'OperatingRecordId__c';
}