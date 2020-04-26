/************************************************************************************************************
@author      : Accenture : Ashish Tiwari
@date        : 04-Nov-2017
@description : This class use for CuAp_MoveInDatePage Lightning component to get Move In/Move Out date
Revision(s)  : Ashish Tiwari - 12-12-2017, Review Comments added
                03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
**************************************************************************************************************/
public with sharing class CuAp_MoveInDatePageCtrlr {

    private static List<string> locFields;
    private static List<string> locRefFields;
    private static final String CLASS_NAME = 'CuAp_MoveInDatePageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    
    private static final List < String > locationOccListField = new List < string > {
        GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE,
        GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI,
        GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE
        };
            
    private static final List < String > locationOccListField1 = new List < string > {
        GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE,
        GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI
        };            
            
    private static final List < String > locationListField = new List < string > {
        GlUt_APIConstantsLocation.NUMOFOCCAPINAME
        };        

    static{
        //Get Fields from the LocationOccupant__c Object
        locFields = new List<string>();
        locFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT);
        locFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE);
        locFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE);
        locFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACTIVE);
        locFields.add(GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI);
        //MT - Added as per the field as per the Ticket AT-1446
        locFields.add(GlUt_APIConstantsLocationOccupant.PRIMARY);
        locFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT); //AT-3516
        
        //Get Fields from the Location__c Object
        locRefFields = new List<string>();
        //21-03-2018 MT - AT-1907 Changed the below field from Name to LocationReference__c
        //locRefFields.add(GlUt_APIConstantsLocation.LOCATIONREFERENCEAPINAME); //AT-3174
        locRefFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
  
    /**********************************************************************************************
    @author      : Accenture: Ashish Tiwari
    @date        : 04-Nov-2017
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
                   to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveLocationPropDetails() {
        List<GLAp_FieldProps> locProps; 
        try {
            //Get the field properties for the Location Occupants object
            locProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, locFields);   
            //Want to make all of the Location Occupants fields readonly
            for(GLAp_FieldProps locProp: locProps){
                locProp.isEditable = false;
                if(locProp.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTSTARTDATEOLDLABEL){
                    locProp.fieldLabel = CuAp_Constants.LOCATIONOCCUPANTSTARTDATENEWLABEL;
                }
                if(locProp.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTENDDATEOLDLABEL){
                    locProp.fieldLabel = CuAp_Constants.LOCATIONOCCUPANTENDDATENEWLABEL;
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
    @author      : Echo: Tarun Gupta
    @date        : 27-Feb-2018
    @params      : String
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back Location occupant and location related fields as List 
                   This change is done t cater name spaces changes
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveLocationFields() {
        try {
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> lstLocationOccFields = new List<GLAp_FieldProps>();
            
            Boolean regionAU = GlUt_RegionUtility.getAURegionCustomSetting();
            
            if(regionAU)
                lstLocationOccFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, locationOccListField1);
            else
                lstLocationOccFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, locationOccListField);
            
            List<GLAp_FieldProps> lstLocationFields = new List<GLAp_FieldProps>();
            lstLocationFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationListField);
            
            //This is to make a single list of GLAp_FieldProps
            for(integer z=0; z< lstLocationFields.size() ; z++){
                lstLocationOccFields.add(lstLocationFields[z]);
            }
            
            system.debug('lstLocationOccFields---'+ lstLocationOccFields);
            
            for(GLAp_FieldProps locProp: lstLocationOccFields){
                
                system.debug('locProp---'+ locProp);
                
                if(locProp.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTSTARTDATEOLDLABEL){
                    locProp.fieldLabel = Label.CuAp_MoveInDatePageMoveInDate;
                }
                
                if(locProp.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTOCCTYPEOLDLABEL){
                    locProp.fieldLabel = Label.CuAp_MoveInDatePageOccupancyType;
                }
                
                if(locProp.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTENDDATEOLDLABEL){
                    locProp.fieldLabel = Label.CuAp_MoveInDatePageMoveOutDate;
                }
                
                if(locProp.fieldLabel == CuAp_Constants.NUMOFOCCUPIEROLDLABEL){
                    locProp.fieldLabel = Label.CuAp_MoveInDatePageNumberOfOccupiers;
                }
                 
            }
            
            for(integer i=0; i < lstLocationOccFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstLocationOccFields[i]);
                
                if(secondEntryIndex < lstLocationOccFields.size()){
                    lstEntry.add(lstLocationOccFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
                system.debug('twoColFormattedList========'+ twoColFormattedList);
            }
            return twoColFormattedList;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }   
    } 
 
    /**********************************************************************************************
    @author      : Accenture: Ashish Tiwari
    @date        : 04-Nov-2017
    @Param       : String
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the field properties for each of the fields that are
                   to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getLocationOccupants(string sLocationId) {
        List<BlAp_CombinedRecord>  locationSelectList = new List<BlAp_CombinedRecord>();
        
        try {
            //Only query datbase if one field is field in
            if (String.isNotBlank(sLocationId)) {
                
                String filterStatements = 'WHERE ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACTIVE + ' = true and ';
                
                // Add all of the input parameters to the search string
                if (String.isNotBlank(sLocationId)) {
                    filterStatements += GlUt_FieldSecurity.appendSearchClause(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION, sLocationId, CuAp_Constants.OPERATIONEQUALS, true);
                }
                filterStatements += CuAp_Constants.SOQLCONDITION;
                List<LocationOccupant__c> locationOccList = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                                                            locFields,
                                                                                                                            filterStatements);
                
                //Loop throught the location Occupants list and capture the appropriate location Occupants information
                for(LocationOccupant__c loc : locationOccList){
                    BlAp_CombinedRecord locationSelectRecord = new BlAp_CombinedRecord();       
                    locationSelectRecord.uniqueId=loc.Id;
                    locationSelectRecord.isSelected = true;
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
    @date        : 04-Nov-2017
    @Param       : String
    @return      : List<String>
    @description : This method returns the Address values for specified location
    @revision    : 21-03-2018 MT - AT-1907 Changed the below field from Name to LocationReference__c
    **********************************************************************************************/
    @AuraEnabled
    public static List<String> getLocationDetails(string sLocationId, string recordId) {
        List<String> locationRefList = new List<String>();
        try {
            //Only query datbase if one field is field in
            if (String.isNotBlank(sLocationId)) {
                
                String filterStatements = 'WHERE ';
                
                //Add all of the input parameters to the location id
                if (String.isNotBlank(sLocationId)) {
                    filterStatements += GlUt_FieldSecurity.appendSearchClause(GlUt_APIConstantsLocation.LOCATIONID, sLocationId, CuAp_Constants.OPERATIONEQUALS, true);
                }
                List<Location__c> locationList = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME, 
                                                                                                         locRefFields,
                                                                                                         filterStatements);
                
                for (Location__c loc : locationList) {
                    // locationRefList.add(loc.LocationReference__c); //21-03-2018 MT - AT-1907 Changed the field from Name to LocationReference__c //AT-3174
                    locationRefList.add(loc.Address__c);
                } 
                
                List<Account> accountList = [Select Id from Account where Id = :recordId and Recordtype.DeveloperName = :CuAp_Constants.ACCOUNTRECORDTYPE];
                if (accountList.size() > 0) {
                    locationRefList.add(CuAp_Constants.FLAGTRUE);
                } else {
                    locationRefList.add(CuAp_Constants.FLAGFALSE);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return locationRefList;
    }
    
    /**********************************************************************************************
    @author      : Accenture: Ashish Tiwari
    @date        : 04-Nov-2017
    @return      : List<String>
    @description : This method returns the picklist field values for Occupancy Type field from Location Occupant object
    **********************************************************************************************/
    @AuraEnabled
    public static List<String> occupancyType(){
        List<String> returnOptionsList = new List<String>();
        try {
            returnOptionsList.add(CuAp_Constants.INITIALFORPICKLIST);
            List<GlAp_FieldProps> fldProps = GlUt_FieldSecurity.getFieldPropertiesObject(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,new List<String>{GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI});
            for(GlAp_FieldProps fp : fldProps){
                if(fp.isFLSVisible){
                    for(String optionVal : fp.pickListEntries.Values()){
                        if(optionVal != ''){
                            returnOptionsList.add(optionVal);
                        }
                    }    
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return returnOptionsList;
    }
    
    /**********************************************************************************************
    @author      : ECHO: Mohit Tayal
    @date        : 02-Aug-2018
    @Param       : String
    @return      : Date
    @description : AT - 2336 This method returns the end date of the last occupant
    **********************************************************************************************/
    @AuraEnabled
    public static Date getLastOccupantMoveOutDate(string sLocationId) {
        try {
            //Only query datbase if one field is field in
            if (String.isNotBlank(sLocationId)) {
                
                String filterStatements = 'WHERE ' + GlUt_FieldSecurity.appendSearchClause(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION, sLocationId, CuAp_Constants.OPERATIONEQUALS, true);
                
                filterStatements += ' ORDER BY ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE + ' DESC';
                List<LocationOccupant__c> locationOccList = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                                                            locFields,
                                                                                                                            filterStatements);
                //Error Coming in SIT -Fix Dependra Singh- 10-04-2018
                if(!locationOccList.isEmpty() && locationOccList[0].EndDate__c != null){
                    return locationOccList[0].EndDate__c;
                }
                else{
                    return null;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
        }
        return Null;
    }
}