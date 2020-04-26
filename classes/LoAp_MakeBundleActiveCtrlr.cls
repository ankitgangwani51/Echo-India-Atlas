/******************************************************************************
@author         Echo: Mohit Tayal
@date           19 July 2018
@description    Controller for Make Bundle Active Lightning Component
@revesion 		Changes by Dependra Singh - Security Review - 20-09-2018 - AT-3749
*******************************************************************************/
public with sharing class LoAp_MakeBundleActiveCtrlr {

    private static final String CLASS_NAME = 'LoAp_MakeBundleActiveCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public static List<String> lstAvailableBundleFields = new List<String>();
    private static List<string> lstBundleFields = new List<String>();
    
    static{
       // lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.BUNDLENAMEAPINAME);  // -- Swati 29-08-2018 , AT-3174
        lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.BUNDLEAPINAME);
        lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.LASTBUNDLECHANGEDATEAPINAME);
        lstBundleFields.add(GlUt_APIConstantsBundle.NAMEAPINAME); // -- Swati 29-08-2018 , AT-3174
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           19 July 2018
    @param          
    @return         List<List<GlAp_FieldProps>>
    @description    returns the field properties of available bundle 
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveFieldProps(){
        try{
            List<GlAp_FieldProps> lstFieldProps = new List<GlAp_FieldProps>(); // -- Swati 29-08-2018 , AT-3174
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> bundleProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBundle.BUNDLEAPINAME, lstBundleFields);// -- Swati 29-08-2018 , AT-3174
            List<GlAp_FieldProps> avlBundleProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, lstAvailableBundleFields);
            //AT-3174
            for(GlAp_FieldProps objFieldProp : bundleProps){
                if(objFieldProp.fieldName == GlUt_APIConstantsBundle.NAMEAPINAME){
                    objFieldProp.fieldLabel = CuAp_Constants.AVAILABLEBUNDLELABEL;
                    objFieldProp.isEditable = False;
                    objFieldProp.showLabel = True;
                    lstFieldProps.add(objFieldProp);
                }                
            }
            for(GlAp_FieldProps objFieldProp : avlBundleProps){
                if(objFieldProp.fieldName == GlUt_APIConstantsAvailableBundle.LASTBUNDLECHANGEDATEAPINAME){
                    objFieldProp.fieldLabel = LoAp_Constants.EFFECTIVEDATE;
                    lstFieldProps.add(objFieldProp);
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
    @date           19 July 2018
    @param          String recId
    @return         ResultWrapper (Wrapper Class) 
    @description    returns the record of available bundle 
    *******************************************************************************/
    @AuraEnabled
    public static ResultWrapper retrieveRecords(String recId){
    ResultWrapper recordToDisplay  = new resultWrapper();
        try {
            AvailableBundle__c objAvailableBundle = (AvailableBundle__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, recId, lstAvailableBundleFields);
             // -- Swati 29-08-2018 , AT-3174
            List<Id> bundleIdList = new List<Id>();
            bundleIdList.add(objAvailableBundle.Bundle__c);
            List<Bundle__c> bundleList =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBundle.BUNDLEAPINAME,
                                                                                       lstBundleFields,
                                                                                       String.format('WHERE {0} IN {1}', 
                                                                                                      new List<String>{
                                                                                                      GlUt_APIConstantsBundle.ID, 
                                                                                                      GlUt_FieldSecurity.IdsToString(bundleIdList)}));
            recordToDisplay.objAvailableBundle = objAvailableBundle;
            recordToDisplay.objBundle = bundleList[0];
            return recordToDisplay;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 Aug 2018
    @description    wrapper class
    *******************************************************************************/    
    public class resultWrapper {
       @AuraEnabled public AvailableBundle__c objAvailableBundle;
       @AuraEnabled public Bundle__c objBundle;
    }


    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           19 July 2018
    @param          String objectName, String newRecordObject
    @return         
    @description    update the available bundle record and calls GlUt_ActivateAvailableBundle
                    to activate the bundle
    *******************************************************************************/
    @AuraEnabled
    public static void saveRecords(String objectName, String newRecordObject){
        system.debug('saveRecords-newRecordObject= ' + newRecordObject) ;
        system.debug('saveRecords-objectName= ' + objectName) ;
        SObject newRecord = (SObject) System.JSON.deserialize(newRecordObject, Type.forName(objectName));
        Id recordId = (Id) newRecord.get('Id');
        try {
            // save the new record
            GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper();
            Map<Id,GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper> mapOfAvailableBundleIdToWrapper = new Map<Id,GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper>();
			//Changes by Dependra Singh - Security Review - 20-09-2018 - AT-3749
            List<string> fieldNames = GlAp_LightningDataAccess.getFieldSetFields(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME,
                                                                                 LoAp_Constants.MAKEBUNDLEACTIVEAVAILABLEBUNDLE);
            
           /* String soqlQuery ='';  
			if(fieldNames!= null && !fieldNames.isEmpty()){
				soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,' + 
                String.join(fieldNames,','), 
                GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\''});  
			}	*/
            // Clayton Review: Changed By Dependra
            String filterStatement = ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
            List<AvailableBundle__c> availableBundleList =(List<AvailableBundle__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, 
                                                                                                                       fieldNames, 
                                                                                                                       filterStatement);
                                                                                                                       
            // get reading upload records using query string.
			/*if(string.isNotBlank(soqlQuery)){
				List<AvailableBundle__c> availableBundleList = Database.query(soqlQuery);
				if(availableBundleList!= null && !availableBundleList.isEmpty()){
					objWrapper.availableBundle = availableBundleList[0];
				}
            }*/
            if(availableBundleList!= null && !availableBundleList.isEmpty()){
                objWrapper.availableBundle = availableBundleList[0];
            }                                                                            
            objWrapper.effectiveDate = (Date)newRecord.get(GlUt_APIConstantsAvailableBundle.LASTBUNDLECHANGEDATEAPINAME);
            mapOfAvailableBundleIdToWrapper.put(recordId, objWrapper);
            system.debug('mapOfAvailableBundleIdToWrapper= ' + mapOfAvailableBundleIdToWrapper) ;
            GlUt_ActivateAvailableBundle.activateAvailableBundle(mapOfAvailableBundleIdToWrapper);
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
    }    
}