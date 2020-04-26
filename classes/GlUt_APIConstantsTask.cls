/************************************************************************************************************
@author         Echo : Amit K.
@date           05-June-2018
@description:   This is the constants class for all static fields used in the Task object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsTask {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
	
    // Task Object API Name
    public static String  TASKAPINAME =  'Task';
    
    // Task object fields API Names
    public static String  IDAPINAME = 'Id';
    public static String  S3FILENAMEAPINAME = NAMESPACEPREFIX + 'S3Filename__c';

}