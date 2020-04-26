/**************************************************************************************************************************************
@author        Accenture : Shivangi Gaur
@date          12-Sep-2017
@description:  This class is uesd to handle lightning component for overriding record type selection page for HH account.  
@group         Lightning Component Controller
Revision(s)    18-09-2017 - Shivangi Gaur - Updated method getRecTypeId() as per new solution.
               04-10/2017 - Shivangi Gaur - Removed hard coding from the class.
               10-10-2017 - Shivangi Gaur - Updated method fetchRecordTypeValues() to add check for 
                                            available record types as per user/ profile access.
               21-12-2017 - Shivangi Gaur - Updated class name as per naming standards.
@Revisions	   AT-3981 ,Tarun, Security review changes , modified classname
***************************************************************************************************************************************/
public with sharing class CuAp_HHAccountOverrideComponentCtrlr{
    
    private static final String CLASS_NAME = 'CuAp_HHAccountOverrideComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] '; 
    // Variable declaration start
    
    
    
    // End variable declaration
    
    /**********************************************************************************************
    @author        Accenture: Shivangi Gaur
    @date          12-Sep-2017
    @param         null
    @return        List<String>
    @description   This method is used to return record type values for account.
    **********************************************************************************************/
	@AuraEnabled        
    public static List<RecordType> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordTypes = Account.SObjectType.getDescribe().getRecordTypeInfos();    
        List<RecordType> rtNames = new List<RecordType>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            for(RecordTypeInfo rt : recordTypes){
                
                //fetch record types only if it is not Master
                if(rt.isAvailable() && rt.getName() != CuAp_Constants.MASTERRECORDTYPE)
                    rtNames.add(new RecordType(Id = rt.getRecordTypeId(),Name = rt.getName(),IsActive = rt.isDefaultRecordTypeMapping()));
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        //Return list of record types fetched        
        return rtNames;
    }
    
    /**********************************************************************************************
    @author        Accenture: Shivangi Gaur
    @date          12-Sep-2017
    @param         String
    @return        Id
    @description   This method is used to return Id of the record type for account.
    **********************************************************************************************/    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        system.debug('recordTypeLabel = '+recordTypeLabel);
        Id recId ;
        try {
            GlUt_Logger.logDebug(DEBUG);
            recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
            
            system.debug('recId = ' + recId);

        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return recId;
    }
}