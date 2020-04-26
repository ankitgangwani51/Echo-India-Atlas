/************************************************************************************************************
@author      : Echo : Swati Mathur
@date        : 13-09-2018
@description : This class use for CuAp_MoveAmendmentDetailsPageCtrlr Lightning component to get Move In/Move Out date
**************************************************************************************************************/
public with sharing class CuAp_MoveAmendmentDetailsPageCtrlr {

	private static List<string> locFields;
    private static List<string> locRefFields;
    private static final String CLASS_NAME = 'CuAp_MoveAmendmentDetailsPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    
    private static final List < String > locationOccListField = new List < string > {
        GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE,
        GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE            
        };            

    /**********************************************************************************************
    @author      : Echo : Swati Mathur
    @date        : 13-09-2018
    @params      : Id locId, LocationOccupant__c loccOcc
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back Location occupant and location related fields as List 
				   
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveLocationFields(Id locId, LocationOccupant__c loccOcc) {
        try {
            
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            Map<String,Id> mapPrevOrSebOcc2LocOccId = new Map<String,Id>();
                      
            List<GLAp_FieldProps> lstDisplayFields = new List<GLAp_FieldProps>();  
            //Create Transform Field for Available Service having parent object Supply Point.
            GLAp_FieldProps accountProp = new GLAp_FieldProps();
            accountProp.isFLSVisible = true;
            accountProp.isEncrypted = false;
            accountProp.isEditable = false;
            accountProp.isRequired = false;
            accountProp.fieldName  =  GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT;
            accountProp.fieldLabel =  'Name';
            accountProp.fieldType = 'text';
            accountProp.transformField = true; 
            accountProp.showLabel = true;
            accountProp.parentObject = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME; 
            lstDisplayFields.add(accountProp);
            
            //Create Transform Field for Available Service having parent object Supply Point.
            GLAp_FieldProps locProp = new GLAp_FieldProps();
            locProp.isFLSVisible = true;
            locProp.isEncrypted = false;
            locProp.isEditable = false;
            locProp.isRequired = false;
            locProp.fieldName  = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION;
            locProp.fieldLabel =  'Location';
            locProp.fieldType = 'text';
            locProp.transformField = true; 
            locProp.showLabel = true;
            locProp.parentObject = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME; 
            lstDisplayFields.add(locProp);
            
            List<GLAp_FieldProps> lstLocationOccFields = new List<GLAp_FieldProps>();  
            lstLocationOccFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, locationOccListField);                   
            for(GLAp_FieldProps locOccProp: lstLocationOccFields){
                
                if(locOccProp.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTSTARTDATEOLDLABEL){
                    locOccProp.fieldLabel = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATENEWLABEL;
                }
                
                if(locOccProp.fieldLabel == CuAp_Constants.LOCATIONOCCUPANTENDDATEOLDLABEL){
                    locOccProp.fieldLabel = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATENEWLABEL;
                }
                lstDisplayFields.add(locOccProp);
            }
            mapPrevOrSebOcc2LocOccId = checkPreviousAndSubsequentOccupancy(locId,loccOcc);
            Boolean regionAU = GlUt_RegionUtility.getAURegionCustomSetting();
            if(regionAU && mapPrevOrSebOcc2LocOccId.keyset().size() > 0){
                if(mapPrevOrSebOcc2LocOccId.containsKey(Label.CuAp_AUMoveAmendPrevOcc)){
                    //Create Transform Field for adjust previous occupancy checkbox.
                    GLAp_FieldProps prevOcc = new GLAp_FieldProps();
                    prevOcc.isFLSVisible = true;
                    prevOcc.isEncrypted = false;
                    prevOcc.isEditable = true;
                    prevOcc.isRequired = false;
                    prevOcc.fieldName  = GlUt_APIConstantsLocationOccupant.PREVIOUSLOCATIONOCCUPANTLABEL;
                    prevOcc.fieldLabel =  Label.CuAp_AUMoveAmendAdjustPrevOcc;
                    prevOcc.fieldType = 'checkbox';
                    prevOcc.transformField = true; 
                    prevOcc.parentObject = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME; 
                    lstDisplayFields.add(prevOcc);
                }
                if(mapPrevOrSebOcc2LocOccId.containsKey(Label.CuAp_AUMoveAmendSubOcc)){
                    //Create Transform Field for adjust subsequent occupancy checkbox.
                    GLAp_FieldProps subOcc = new GLAp_FieldProps();
                    subOcc.isFLSVisible = true;
                    subOcc.isEncrypted = false;
                    subOcc.isEditable = true;
                    subOcc.isRequired = false;
                    subOcc.fieldName  = GlUt_APIConstantsLocationOccupant.SUBSEQUENTLOCATIONOCCUPANTLABEL;
                    subOcc.fieldLabel =  Label.CuAp_AUMoveAmendAdjustSubOcc;
                    subOcc.fieldType = 'checkbox';
                    subOcc.transformField = true; 
                    subOcc.parentObject = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME; 
                    lstDisplayFields.add(subOcc);
                }
            }
            
            for(integer i=0; i < lstDisplayFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstDisplayFields[i]);
                
                if(secondEntryIndex < lstDisplayFields.size()){
                    lstEntry.add(lstDisplayFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
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
    @author      : Echo : Swati Mathur
    @date        : 14-09-2018
    @params      : Id locId, LocationOccupant__c loccOcc
    @return      : LocationOccupant__c
    @description : This method returns back Location occupant and location related fields as List 
				   
    **********************************************************************************************/   
    @AuraEnabled
    public static LocationOccupant__c getPrevOccupierDetails(Id locId, LocationOccupant__c loccOcc){
        try {

            Date locOccStartDate = loccOcc.StartDate__c;
            String dateInString = String.valueOf(locOccStartDate);
            List<String> dateInList = dateInString.split(' ');
            DateTime dt1 = Date.valueOf(dateInList[0]);      
            
            String filterStatement = ' WHERE ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION + ' = \'' + String.escapeSingleQuotes(locId) + '\'';
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE + ' < ' + dt1.format('yyyy-MM-dd') ; 
            filterStatement = filterStatement + ' ORDER BY  ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE + ' DESC ';

            List <LocationOccupant__c> lstPrevOccupiers = new List <LocationOccupant__c>();
            lstPrevOccupiers = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                               locationOccListField, 
                                                                                               filterStatement);
            

           
            if(lstPrevOccupiers != null && !lstPrevOccupiers.isEmpty()){
                return lstPrevOccupiers[0];
                
            }            
            else{
                return null;
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }   
    } 
    
    
    /**********************************************************************************************
    @author      : Echo : Swati Mathur
    @date        : 14-09-2018
    @params      : Id locId, LocationOccupant__c loccOcc
    @return      : LocationOccupant__c
    @description : This method returns back Location occupant and location related fields as List 
				   
    **********************************************************************************************/   
    @AuraEnabled
    public static LocationOccupant__c getNextOccupierDetails(Id locId, LocationOccupant__c loccOcc){
        try {
            
            List <LocationOccupant__c> lstNextOccupiers = new List <LocationOccupant__c>();
            
            if(loccOcc.EndDate__c !=null){            
                
                Date locOccEndDate = loccOcc.EndDate__c;
                String dateInString = String.valueOf(locOccEndDate);
                List<String> dateInList = dateInString.split(' ');
                DateTime dt1 = Date.valueOf(dateInList[0]); 
                String filterStatement = ' WHERE ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION + ' = \'' + String.escapeSingleQuotes(locId) + '\'';
                filterStatement += ' AND (' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE + ' > ' + dt1.format('yyyy-MM-dd') + ' OR '; 
                filterStatement += GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE + ' = null ) ' ;
                filterStatement += ' ORDER BY  ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE + ' ASC ';
                lstNextOccupiers = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                                   locationOccListField, 
                                                                                                   filterStatement);
            }
            
            if(!lstNextOccupiers.isEmpty()){
                return lstNextOccupiers[0];               
            }
            else{
                return null;
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }   
    }
    
    /**********************************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @param          readingPeriodId
    @return         instance of wrapper class 
    @description    This method will collect the required details in wrapper and send it to helper
    **********************************************************************************************/
    @AuraEnabled
    Public static ContainerWrapper getLocAndLocOccDetails(Id locId, LocationOccupant__c loccOcc){
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper();
        try {
            
            resultContainer.twoColFormattedList = retrieveLocationFields(locId,loccOcc);
            if(getPrevOccupierDetails(locId,loccOcc) != null){
                resultContainer.prevOccStartDate = getPrevOccupierDetails(locId,loccOcc).StartDate__c; 
                resultContainer.previousOccupier = getPrevOccupierDetails(locId,loccOcc);
            }
            if(getNextOccupierDetails(locId,loccOcc) != null){
                resultContainer.nextOccEndDate = getNextOccupierDetails(locId,loccOcc).EndDate__c;
                resultContainer.nextOccupier = getNextOccupierDetails(locId,loccOcc);
            }
            Boolean regionAU = GlUt_RegionUtility.getAURegionCustomSetting();
            if(regionAU)
                resultContainer.auAmendment = true;
            else
                resultContainer.auAmendment = false;
            return resultContainer;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           11 May 2018
    @param          none
    @return         none
    @description    Wrapper Class 
    *******************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<List<GlAp_FieldProps>> twoColFormattedList;
        @AuraEnabled public Date prevOccStartDate;
        @AuraEnabled public Date nextOccEndDate;
        @AuraEnabled public LocationOccupant__c previousOccupier;
        @AuraEnabled public LocationOccupant__c nextOccupier;
        @AuraEnabled public Boolean auAmendment;
    } 
    
    /**********************************************************************************************
    @author      : Echo : Swati Mathur
    @date        : 14-09-2018
    @params      : Id locId, LocationOccupant__c loccOcc
    @return      : Map<String,Id>
    @description : This method returns back Location occupant and location related fields as List 
    **********************************************************************************************/   
    @AuraEnabled
    public static Map<String,Id> checkPreviousAndSubsequentOccupancy(Id locId, LocationOccupant__c loccOcc){
    
        List <LocationOccupant__c> lstNextOccupiers = new List <LocationOccupant__c>();
        List <LocationOccupant__c> lstPreviousOccupiers = new List <LocationOccupant__c>();
        Map<String,Id> mapPrevOrSebOcc2LocOccId = new Map<String,Id>();
        if(loccOcc != null && loccOcc.EndDate__c !=null){            
            lstNextOccupiers = [Select Id,
                                StartDate__c,
                                Enddate__c 
                                From LocationOccupant__c 
                                Where Location__c = :locId
                                And Startdate__c > :loccOcc.EndDate__c
                                AND OccupancyType__c =: Label.CuAp_AUMoveInOccType //Tenant
                                Order By Startdate__c ASC];
            lstNextOccupiers = (List <LocationOccupant__c>) GlUt_FieldSecurity.cleanseFields(lstNextOccupiers, false);
        }
        if(!lstNextOccupiers.isEmpty()){
            mapPrevOrSebOcc2LocOccId.put(Label.CuAp_AUMoveAmendSubOcc, lstNextOccupiers[0].Id);
        }
        lstPreviousOccupiers = [Select Id,
                                StartDate__c,
                                Enddate__c 
                                From LocationOccupant__c 
                                Where Location__c = :locId
                                And Enddate__c < :loccOcc.StartDate__c
                                AND OccupancyType__c =: Label.CuAp_AUMoveInOccType //Tenant
                                Order By EndDate__c DESC];
        lstPreviousOccupiers = (List <LocationOccupant__c>) GlUt_FieldSecurity.cleanseFields(lstPreviousOccupiers, false);
        if(!lstPreviousOccupiers.isEmpty()){
            mapPrevOrSebOcc2LocOccId.put(Label.CuAp_AUMoveAmendPrevOcc, lstPreviousOccupiers[0].Id);
        }
        return mapPrevOrSebOcc2LocOccId;
    }
}