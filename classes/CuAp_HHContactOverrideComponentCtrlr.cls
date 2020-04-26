/**************************************************************************************************************************************
@author        Accenture : Shivangi Gaur
@date          18-Sep-2017
@description:  This class is uesd to handle lightning component for overriding record type selection page for HH contact.  
@group         Lightning Component Controller
Revision(s)    04-10-2017 - Shivangi Gaur - Removed hard coding from the class.
               10-10-2017 - Shivangi Gaur - Updated method fetchRecordTypeValues() to add check for 
                                            available record types as per user/ profile access.
               12-12-2017 - Shivangi Gaur - Updated class as per the latest changes where custom record type selection page is changed 
                                            back to standard overridden.
               21-12-2017 - Shivangi Gaur - Updated class name as per naming convention.
@Revisions		 AT-3984 . Tarun, Changed the name of class as per security review changes 
***************************************************************************************************************************************/
public with sharing class CuAp_HHContactOverrideComponentCtrlr{
      
    private static final String CLASS_NAME = 'CuAp_HHContactOverrideComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // Variable declaration start
    
    // End variable declaration
    
    /**********************************************************************************************
    @author        Accenture: Pratyush Kumar
    @date          28-Nov-2017
    @param         Id
    @return        String
    @description   This method is used to return record type Name of the record type for contact.
    **********************************************************************************************/    
    @AuraEnabled
    public static String getRecTypeName(Id recordTypeId){
        String getRecTypeString;
        try {
            GlUt_Logger.logDebug(DEBUG);
            getRecTypeString =  Schema.SObjectType.Contact.getRecordTypeInfosById().get(recordTypeId).getName();  
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return getRecTypeString;
    }
}