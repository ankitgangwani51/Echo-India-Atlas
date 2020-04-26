/************************************************************************************************************
@author      : Accenture : Ashish Tiwari
@date        : 15-Nov-2017
@description : This class use for CuAp_SelectOccupantsPage Lightning component to select Current Occupants for Move Out
Revision(s)  : Ashish Tiwari, 12-12-2017, Review Comment Added   
				08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
@revisions	   Tarun Gupta, 14/03/19 AT-5388,5461
**************************************************************************************************************/
public with sharing class CuAp_SelectOccupantsPageCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_SelectOccupantsPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<string> locOccupantFields;
    private static List<string> locRefFields;
    static{
        //Get Fields from the LocationOccupant__c Object
        locOccupantFields = new List<string>();
        locOccupantFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT);
        locOccupantFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE);
        locOccupantFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE);
        locOccupantFields.add(GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI);
        
        //Get Fields from the Location__c Object
        locRefFields = new List<string>();
        locRefFields.add(GlUt_APIConstantsLocation.NAMEAPINAME);
        locRefFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
  
	/**********************************************************************************************
    @author      : Accenture: Ashish Tiwari
    @date        : 15-Nov-2017
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
                   to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveLocationPropDetails() {
        //Get the field properties for the Location Occupants object
        List<GLAp_FieldProps> locProps;
        try {
            locProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, locOccupantFields);   
            //Want to make all of the Location Occupants fields readonly
            for(GLAp_FieldProps locProp: locProps){
                locProp.isEditable = false;
                if(locProp.fieldLabel == GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATEOLDLABEL){
                    locProp.fieldLabel = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATENEWLABEL;
                }
                if(locProp.fieldLabel == GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATEOLDLABEL){
                    locProp.fieldLabel = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATENEWLABEL;
                }
            }  
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return locProps; 
    }
 
	/**********************************************************************************************
    @author      : Accenture: Ashish Tiwari
    @date        : 15-Nov-2017
    @Param       : String
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the field properties for each of the fields that are
                   to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getLocationOccupants(string sLocationId,string sMoveOutDate) {
        List<BlAp_CombinedRecord>  locationSelectList = new List<BlAp_CombinedRecord>();
        
        try {
            //Only query datbase if one field is field in
            if (String.isNotBlank(sLocationId)) {
                
                //Add all of the input parameters to the search string
                string filterStatements = '';
                if (String.isNotBlank(sLocationId)) {
                    filterStatements += GlUt_FieldSecurity.appendSearchClause(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION, sLocationId,CuAp_Constants.OPERATIONEQUALS, true);
                }
                if(GlUt_RegionUtility.getAURegionCustomSetting()){
                    String strTenant = '\'' + GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPETENANT + '\'';
                    filterStatements += ' AND ' + GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI + ' = ' + strTenant;
                }
                filterStatements += ' order by '+ GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI + ' desc';
                
                List<LocationOccupant__c> locationOccList = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                                                            locOccupantFields,
                                                                                                                            String.format('WHERE {0} = true AND {1}', 
                                                                                                                                          new List<String>{
                                                                                                                                              GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACTIVE, 
                                                                                                                                                  filterStatements}));
                
                //Loop throught the location Occupants list and capture the appropriate location Occupants information
                for (LocationOccupant__c loc : locationOccList) {
                    BlAp_CombinedRecord locationSelectRecord = new BlAp_CombinedRecord();       
                    locationSelectRecord.uniqueId = loc.Id;
                    loc.EndDate__c = Date.valueOf(sMoveOutDate);     
                    if (loc.OccupancyType__c == GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPE) {
                        locationSelectRecord.isSelected = false; 
                    }
                    else{
                        locationSelectRecord.isSelected = true;
                    }
                    locationSelectRecord.objectMap = new Map<string, sObject>();
                    locationSelectRecord.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, loc);  
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
    
	/**********************************************************************************************
    @author      : Accenture: Ashish Tiwari
    @date        : 15-Nov-2017
    @Param       : String
    @return      : List<String>
    @description : This method returns the Address values for specified location
	**********************************************************************************************/
    @AuraEnabled
    public static List<String> queryLocation(string sLocationId) {
        List<String> LocationRefList = new List<String>();
        try {
            //Only query datbase if one field is field in
            if (String.isNotBlank(sLocationId)) {
                
                //Add all of the input parameters to the search string
                string filterStatements = '';
                if (String.isNotBlank(sLocationId)) {
                    filterStatements += 'WHERE ';
                    filterStatements += GlUt_FieldSecurity.appendSearchClause(GlUt_APIConstantsLocation.LOCATIONID, sLocationId, CuAp_Constants.OPERATIONEQUALS);
                }
                
                List<Location__c> locationList = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME, 
                                                                                                         locRefFields,
                                                                                                         filterStatements);
                for (Location__c loc : locationList) {
                    LocationRefList.add(loc.Name);
                    LocationRefList.add(loc.Address__c);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return LocationRefList;
    }
}