/************************************************************************************************************
@author			Accenture : Ashish Tiwari
@date			20-Nov-2017
@description	This class use for CuAp_SelectAccountLocationPage Lightning component to get select Account Location
Revision(s)		Ashish Tiwari, 12-12-2017, Review Comment Added   
				04 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
**************************************************************************************************************/
public with sharing class CuAp_SelectAccountLocationPageCtrlr {

    private static List<string> locFields;
    private static final String CLASS_NAME = 'CuAp_SelectAccountLocationPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> locOccFields;
    private static String strMoveOutLocResults = GlUt_NamespacePrefix.getNamespacePrefix() + Label.CuAp_MoveOutLocResults;
    private static String strMoveOutLocOccResults = GlUt_NamespacePrefix.getNamespacePrefix() + Label.CuAp_MoveOutLocOccResults;
    private static String strMoveOutLocSearchCriteria = GlUt_NamespacePrefix.getNamespacePrefix() + Label.CuAp_MoveOutLocSearchCriteria;
    
        
    static {
        //Get Fields from the LocationOccupant__c Object
        locOccFields = new List<string>();
        locOccFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE);
        locOccFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACTIVE);
        locOccFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE);
        
        //Get Fields from the Location__c Object
        locFields = new List<string>();
        locFields.add(GlUt_APIConstantsLocation.NAMEAPINAME);
        locFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    
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
            List<GLAp_FieldProps> locProp = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsLocation.LOCATIONAPINAME,strMoveOutLocSearchCriteria);
            for(integer i=0; i < locProp.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(locProp[i]);
                
                if(secondEntryIndex < locProp.size()){
                    lstEntry.add(locProp[secondEntryIndex]);   
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
  
	/**********************************************************************************************
    @author      : Accenture: Ashish Tiwari
    @date        : 20-Nov-2017
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
                   to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveLocationPropDetails() {
        List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();
        try {
            
            
            //Get the field properties for the Location object
            //List<GLAp_FieldProps> locProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locFields); 
            List<GLAp_FieldProps> locProp = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsLocation.LOCATIONAPINAME,strMoveOutLocResults);
            //Get the field properties for the Location Occupants object
            //List<GLAp_FieldProps> locOccProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, locOccFields);   
            List<GLAp_FieldProps> locOccProp = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,strMoveOutLocOccResults);
            for(GLAp_FieldProps locProps: locProp){
                //Want to make all of the Location fields readonly
                locProps.isEditable = false;
                if(locProps.fieldLabel == GlUt_APIConstantsLocation.NAMEAPINAME){
                    locProps.fieldLabel = CuAp_Constants.LOCATIONADDRESSREF;
                }
                allFieldProp.add(locProps);
            } 
            for(GLAp_FieldProps locOccProps: locOccProp){
                //Want to make all of the Location Occupants fields readonly
                if(locOccProps.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTSTARTDATEOLDLABEL){
                    locOccProps.fieldLabel = CuAp_Constants.LOCATIONOCCUPANTSTARTDATENEWLABEL;
                }
                if(locOccProps.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTENDDATEOLDLABEL){
                    locOccProps.fieldLabel = CuAp_Constants.LOCATIONOCCUPANTENDDATENEWLABEL;
                }
                
                if(locOccProps.fieldLabel == GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTOCCUPANCYTYPELABEL){
                    locOccProps.isEditable = false;
                }
                allFieldProp.add(locOccProps);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return allFieldProp; 
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
    public static List<BlAp_CombinedRecord> queryForLocations(string sAccountId, Location__c searchLoc) {    
    
        List<BlAp_CombinedRecord> locationOccupantsSelectList = new List<BlAp_CombinedRecord>();
        List<string> locFieldListForSearch = new List<string>();
        try {
            
            locFieldListForSearch = GlAp_LightningDataAccess.getFieldSetFields(GlUt_APIConstantsLocation.LOCATIONAPINAME,  strMoveOutLocSearchCriteria);
            
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
                
                List<String> fieldNames = new List<String>{GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME, GlUt_APIConstantsLocation.NAMEAPINAME};
                List<string> fieldNamesNew = GlAp_LightningDataAccess.getFieldSetFields(GlUt_APIConstantsLocation.LOCATIONAPINAME,  strMoveOutLocSearchCriteria);
                fieldNames.addall(fieldNamesNew);
                
                List<Location__c> locationList = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME, 
                                                                                                         fieldNames,
                                                                                                         filterStatements);
                
                
                Map<Id,Location__c> locMap = new Map<Id,Location__c>();
                for (Location__c loc : locationList) {
                    locMap.put(loc.Id, loc);
                }
                
                
                Set<Id> locationIds = locMap.keySet();
                
                
                List<String> locationOccupantFields = new List<String>{GlUt_APIConstantsLocation.LOCATIONAPINAME};
                List<String> locationOccupantFieldsNew = GlAp_LightningDataAccess.getFieldSetFields(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,  strMoveOutLocOccResults);
                locationOccupantFields.addAll(locationOccupantFieldsNew);
                
                
                
                Boolean regionAU = GlUt_RegionUtility.getAURegionCustomSetting();
                String filterStatementNew;
                
                if(regionAU){
                    String strTenant = '\'' + GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPETENANT + '\'';
                    filterStatementNew = String.format('{0} in {1} and {2} = true and {3} = {4}', 
                                                       new List<String>{
                                                           GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION,
                                                               GlUt_FieldSecurity.IdsToString(locationIds), 
                                                               GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACTIVE,
                                                               GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI,
                                                               strTenant
                                                               });
                }
                else {
                    filterStatementNew = String.format('{0} in {1} and {2} = true', 
                                                       new List<String>{
                                                           GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION,
                                                               GlUt_FieldSecurity.IdsToString(locationIds), 
                                                               GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACTIVE});
                }
                
                
                
                List<LocationOccupant__c> locationOccList = new List<LocationOccupant__c>();
                locationOccList = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                                  locationOccupantFields, 
                                                                                                  sAccountId, 
                                                                                                  GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT, 
                                                                                                  filterStatementNew);
                //if(locationOccList != null && !locationOccList.isEmpty()){
                    for (LocationOccupant__c loc : locationOccList) {
                        BlAp_CombinedRecord locationSelectRecord = new BlAp_CombinedRecord();       
                        locationSelectRecord.uniqueId = loc.Id;
                        locationSelectRecord.isSelected = false;
                        locationSelectRecord.readOnlyFields = new Map<string, boolean>();
                        locationSelectRecord.objectMap = new Map<string, sObject>();
                        locationSelectRecord.objectMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME, locMap.get(loc.Location__c));  
                        locationSelectRecord.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, loc);  
                        locationOccupantsSelectList.add(locationSelectRecord);
                    }
                //}
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return locationOccupantsSelectList;
    }
    
}