/******************************************************************************
@author         Tarun Gupta 
@date           15 Sep 2018
@description    This is the wizard to display active Location occupant records
@Revisions		CLB-152 CLB-153
*******************************************************************************/
public with sharing class CuAp_SelectLocationOccToAmendCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_SelectLocationOccToAmendCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
	private static final List<String> locOccFields = new List<string>{
                                                          GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE, 
                                                          GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE,
                                                          GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION
                                                          }; 
	                                                              
    private static final List<String> locationFields = new List<string>{
        												  GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME,
                                                          GlUt_APIConstantsLocation.NAMEAPINAME
                                                          };  
    /******************************************************************************
    @author         Tarun Gupta 
    @date           15 Sep 2018
	@parameters 	String sObjectName
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveLocationOccupantFieldPropDetails() {        
        // Get the field properties for the Bill Message object        
        List<GLAp_FieldProps> locOccProperties = new List<GLAp_FieldProps>();
        List<GLAp_FieldProps> locationProperties = new List<GLAp_FieldProps>();
        List<GLAp_FieldProps> updatedLocationProperties = new List<GLAp_FieldProps>();
        List<GLAp_FieldProps> returnFieldProp = new List<GLAp_FieldProps>();
        try {
            locOccProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, locOccFields); 
            locationProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationFields); 
            
            for(GLAp_FieldProps objField : locationProperties){
                if(objField.fieldName != GlUt_APIConstantsLocation.NAMEAPINAME && objField.fieldName != 'Id'){
                    returnFieldProp.add(objField);
                }
            }
            for(GlAp_FieldProps fieldProp : locOccProperties ){
                if(fieldProp.fieldName != 'Id'){
                    fieldProp.isEditable = false;
                    if(fieldProp.fieldName == GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE)
                        fieldProp.fieldLabel = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATENEWLABEL;
                    
                    if(fieldProp.fieldName == GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE)
                        fieldProp.fieldLabel = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATENEWLABEL;
                    
                    returnFieldProp.add(fieldProp);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return returnFieldProp;
    }   
    /******************************************************************************
    @author         Tarun Gupta 
    @date           15 Sep 2018
	@parameters		String sObjectName,
					String recordId
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the field of Location Occupant that are
                    to be displayed on the screen    
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> fetchListOfLocOccToAmend(String recordId) {
    
        List<BlAp_CombinedRecord> activeLocOccList = new List<BlAp_CombinedRecord>();
        List<LocationOccupant__c> locOccList = new List<LocationOccupant__c>();
        List<Location__c> locationList = new List<Location__c>();
        Map<Id,Location__c> mapLocOccId2ToLocationAddress = new Map<Id,Location__c>();
        Map<Id,Id> mapLocation2LocOcc = new Map<Id,Id>();
        String filterStatement;
        
        try {
            //AT-4023
            if(GlUt_RegionUtility.getAURegionCustomSetting()){
                // Occupancy type - Tenant
                String strTenant = '\'' + GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPETENANT + '\'';
                filterStatement = ' WHERE ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT + ' = \'' + String.escapeSingleQuotes(recordId) + '\'';
                filterStatement += ' AND ' + GlUt_APIConstantsLocationOccupant.PRIMARY + ' = true '; 
                filterStatement += ' AND ' + GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI + ' = ' + strTenant;
            }
            else{
                filterStatement = ' WHERE ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT + ' = \'' + String.escapeSingleQuotes(recordId) + '\'';
                filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsLocationOccupant.PRIMARY + ' = true '; 
            }
            locOccList = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                         locOccFields, 
                                                                                         filterStatement);
            if(!locOccList.isEmpty()){
                for(LocationOccupant__c objLocOcc : locOccList){
                    if(objLocOcc.Location__c != null){
                        if(!mapLocation2LocOcc.containsKey(objLocOcc.Location__c)){
                            mapLocation2LocOcc.put(objLocOcc.Location__c,objLocOcc.Id);
                        }
                    }
                }
            }
            if(mapLocation2LocOcc.keySet().size() > 0){
                
                locationList = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME, 
                                                                                       locationFields, 
                                                                                       'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(mapLocation2LocOcc.keySet()));
                if(!locationList.isEmpty()){
                    
                    for(Location__c objLocation : locationList){
                        if(mapLocation2LocOcc.keyset().size() > 0 && mapLocation2LocOcc.containsKey(objLocation.Id)){
                            if(!mapLocOccId2ToLocationAddress.containsKey(mapLocation2LocOcc.get(objLocation.Id))){
                                mapLocOccId2ToLocationAddress.put(mapLocation2LocOcc.get(objLocation.Id),objLocation);
                            }
                        }
                    }
                }
            }
            for (LocationOccupant__c objLocOcc : locOccList) {
                BlAp_CombinedRecord BillSelectRecord = new BlAp_CombinedRecord();  
                BillSelectRecord.uniqueId = objLocOcc.Id;
                BillSelectRecord.isSelected = false;
                BillSelectRecord.objectMap = new Map<string, sObject>();
                BillSelectRecord.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, objLocOcc);
                BillSelectRecord.objectMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME, mapLocOccId2ToLocationAddress.get(objLocOcc.Id));	
                activeLocOccList.add(BillSelectRecord);
            }      
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return activeLocOccList;
    } 
    /******************************************************************************
    @author         Tarun Gupta 
    @date           15 Sep 2018
	@parameters		String recordId
    @return 		String accountName
    *******************************************************************************/
    @AuraEnabled
    public static String getAccountRelatedDetails(String recordId) {
        List<Account> listAccount = new List<Account>();
        listAccount = [SELECT Name FROM Account WHERE Id =: recordId LIMIT 1];
        listAccount = (List<Account>) GlUt_FieldSecurity.cleanseFields(listAccount, false);
        if(listAccount != null && !listAccount.isEmpty())
            return listAccount[0].Name;
        else
            return null;    
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           15 Apr 2019
    @description    This wrapper class is used to diaplay information on page. 
    *******************************************************************************/
	public class LocationOccContainerWrapper{
		@AuraEnabled
		public List<GLAp_FieldProps> returnFieldProps;
		@AuraEnabled
		public List<BlAp_CombinedRecord> listLocOccRecords;
		@AuraEnabled
		public String accountName;
        public LocationOccContainerWrapper(){
              this.returnFieldProps = new List<GLAp_FieldProps>();
              this.listLocOccRecords = new List<BlAp_CombinedRecord>();
          }
	}
   /******************************************************************************
    @author         Tarun Gupta
    @date           15 Apr 2019
	@parameters		String recordId
    @return         Location Occupant Details wrapper class
    @description    This method is used to display page information.
    *******************************************************************************/
	@AuraEnabled
    public static LocationOccContainerWrapper getInfoToDisplay(String recordId) { 
        LocationOccContainerWrapper objWrapper = new LocationOccContainerWrapper();
        if(recordId != null ){
            objWrapper.returnFieldProps = retrieveLocationOccupantFieldPropDetails();
            objWrapper.listLocOccRecords = fetchListOfLocOccToAmend(recordId);
            objWrapper.accountName = getAccountRelatedDetails(recordId); 
        }
        return objWrapper;
	}
}