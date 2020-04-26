/******************************************************************************
@author         Accenture: Luke Emberton
@date           04-Sep-2017
@description    Component controller for Select Location wizard page
@revision       SG/AE - MP2 Updates
				08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
				22/10/2018, Tarun Gupta , AT-4039
*******************************************************************************/
public with sharing class CuAp_SelectLocationPageCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_SelectLocationPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static String strAUMoveInSearchLocation = GlUt_NamespacePrefix.getNamespacePrefix() + Label.CuAp_AUMoveInSearchLocation;
    private static String strAUMoveInSearchLocationResults = GlUt_NamespacePrefix.getNamespacePrefix() + Label.CuAp_AUMoveInSearchLocationResults;
                                                        
    /******************************************************************************
    @author         Andrew Edge
    @date           14-Nov-2017
    @return         List<GLAp_FieldProps>
	@params			String - fieldsetName to get location field properties
    @description    This method returns the field properties for each of the location search fields,
                    in 2 column format
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrieveSearchLocationDetails() {
        
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            List<GLAp_FieldProps> locProps = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsLocation.LOCATIONAPINAME,strAUMoveInSearchLocation);
            
            for(integer i=0; i < locProps.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(locProps[i]);
                
                if(secondEntryIndex < locProps.size()){
                    lstEntry.add(locProps[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return twoColFormattedList;
    }
    
    
    /******************************************************************************
    @author         Accenture: Luke Emberton
    @date           04-Sep-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveLocationPropDetails() {
        
        // Get the field properties for the Location object
        
        List<GLAp_FieldProps> locProps;
        try {
            locProps = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsLocation.LOCATIONAPINAME,strAUMoveInSearchLocationResults);
            
            for(GlAp_FieldProps fieldProp : locProps ){
                fieldProp.isEditable = false;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return locProps;
    }
        
    /******************************************************************************
    @author         Accenture: Luke Emberton
    @date           10-Sep-2017
    @return         List<BlAp_CombinedRecord>
	@params			Location__c sobject - searchLoc
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> queryForLocations(Location__c searchLoc) {    
    
        List<BlAp_CombinedRecord> locationSelectList = new List<BlAp_CombinedRecord>();
        List<string> locFieldListForSearch = new List<string>();
        try {
            
            locFieldListForSearch = GlAp_LightningDataAccess.getFieldSetFields(GlUt_APIConstantsLocation.LOCATIONAPINAME,  strAUMoveInSearchLocation);
            
            String filterStatements = 'where ';
            boolean isStart = true;
            Integer iCount = 0;
            
            for(String objField : locFieldListForSearch){
                if(String.isNotBlank(String.valueOf(searchLoc.get(objField))) ){
                    iCount += 1;
                    if(iCount > 1){
                        isStart = false;
                    }
                    filterStatements += GlUt_FieldSecurity.appendSearchClause(objField, String.valueOf(searchLoc.get(objField)), isStart);
                }
            }
            if(iCount >= 1){
                
                List<string> fieldNames = GlAp_LightningDataAccess.getFieldSetFields(GlUt_APIConstantsLocation.LOCATIONAPINAME,  strAUMoveInSearchLocationResults);
                system.debug('fieldNames===='+fieldNames);
                List<Location__c> locationList = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME, 
                                                                                                         fieldNames,
                                                                                                         filterStatements);
                system.debug('locationList===='+locationList);
                
                // Loop through the location list and capture the appropriate location information
                for (Location__c loc : locationList) {
                    
                    BlAp_CombinedRecord locationSelectRecord = new BlAp_CombinedRecord();           
                    
                    locationSelectRecord.uniqueId = loc.Id;
                    locationSelectRecord.isSelected = false;
                    locationSelectRecord.objectMap = new Map<string, sObject>();
                    locationSelectRecord.objectMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME, loc);                                    
                    locationSelectList.add(locationSelectRecord);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return locationSelectList;
    }
    
}