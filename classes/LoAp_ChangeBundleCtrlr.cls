/******************************************************************************
@author    		Echo: Mohit Tayal
@date      		24 July 2018
@description 	Controller for Change Bundle Lightning Component
@revision	    Echo: Sudhir Kumar - AT-3762 (Core CC), AT-3738(Core Misc)
*******************************************************************************/
public with sharing class LoAp_ChangeBundleCtrlr {

    private static final String CLASS_NAME = 'LoAp_ChangeBundleCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public static List<String> lstAvailableBundleFields = new List<String>();
    public static List<String> lstBundleFields = new List<String>();
    public static List<String> lstAvailableServiceFields = new List<String>();
    
    static{
        lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.BUNDLEAPINAME);
        lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.LASTBUNDLECHANGEDATEAPINAME);
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           24 July 2018
    @param          
    @return         List<List<GlAp_FieldProps>>
    @description    returns the field properties of available bundle 
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveFieldProps(){
        try{
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GlAp_FieldProps> lstFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, lstAvailableBundleFields);
            for(GlAp_FieldProps objFieldProp : lstFieldProps){
                if(objFieldProp.fieldName == GlUt_APIConstantsAvailableBundle.LASTBUNDLECHANGEDATEAPINAME){
                    objFieldProp.fieldLabel = LoAp_Constants.EFFECTIVEDATE;
                }
            }
            for (integer i = 0; i < lstFieldProps.size(); i = i + 2) {
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstFieldProps[i]);
                
                if (secondEntryIndex < lstFieldProps.size()) {
                    lstEntry.add(lstFieldProps[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           24 July 2018
    @param          
    @return         AvailableBundle__c
    @description    returns the record of available bundle 
    *******************************************************************************/
    @AuraEnabled
    public static AvailableBundle__c retrieveRecords(String recId){
        try {
            if(String.isNotBlank(recId)){
                lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.DEFAULTAPINAME);
                AvailableBundle__c objAvailableBundle = (AvailableBundle__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, recId, lstAvailableBundleFields);
                return objAvailableBundle;
            }
            return null;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
    }

    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           24 July 2018
    @param          
    @return         AvailableBundle__c
    @description    update the available bundle record with the new bundle
    *******************************************************************************/
    @AuraEnabled
    public static String saveRecords(String objectName, String supplyPointId, String newRecordObject){
        try {
            SObject newRecord = (SObject) System.JSON.deserialize(newRecordObject, Type.forName(objectName));
            AvailableBundle__c objAvailableBundle = (AvailableBundle__c) newRecord;
            if(objAvailableBundle.Default__c){
                Bundle__c objBundle = [select TariffLimit__c
                                       from Bundle__c 
                                       where Id =:objAvailableBundle.Bundle__c];
                if(objBundle.TariffLimit__c){  //AT-3280
                    //Start: AT-3738 - Sudhir
                    AuraHandledException e = new AuraHandledException(LoAp_Constants.TARIFFLIMITBUNDLEERROR);
                    e.setMessage(LoAp_Constants.TARIFFLIMITBUNDLEERROR);
                    throw e;        
                    //End: AT-3738 - Sudhir
                }  
            }
            Set<Id> setOfAvailableServices = new Set<Id>();
            lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.AVAILABLESERVICEAPINAME);
            for(AvailableBundle__c objAvailableBundle2 : [select AvailableService__c,
                                                          Bundle__c,
                                                          LastBundleChangeDate__c
                                                          from AvailableBundle__c 
                                                          where Bundle__c =:objAvailableBundle.Bundle__c]){
           		if(objAvailableBundle2.AvailableService__c != null)
            		setOfAvailableServices.add(objAvailableBundle2.AvailableService__c);
            }
            Boolean sameSupplyPoint = false;	// Sudhir: AT-3762 (Core CC)
            
            for(AvailableService__c objAvailableService : [select SupplyPoint__c from AvailableService__c where Id In:setOfAvailableServices]){
                if(objAvailableService.SupplyPoint__c != null && supplyPointId != null){
                    if(objAvailableService.SupplyPoint__c == supplyPointId){
                        sameSupplyPoint = True;
                        break;
                    }
                }      
            }
            if(sameSupplyPoint){
                //Start: AT-3738 - Sudhir
                AuraHandledException e = new AuraHandledException(LoAp_Constants.SAMESUPPLYPOINTERROR);
                e.setMessage(LoAp_Constants.SAMESUPPLYPOINTERROR);
                throw e;
                //End: AT-3738 - Sudhir
            }
            // save the new record
            newRecord = (SObject) GlUt_FieldSecurity.cleanseFields(newRecord, false);
            Database.update(newRecord);
			return null ;            
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
        
    }   
}