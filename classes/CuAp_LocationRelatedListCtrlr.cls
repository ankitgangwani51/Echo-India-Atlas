/******************************************************************************
@author         Accenture: Pratyush Kumar
@date           14 Dec 2017
@description    Component controller for CuAp_LocationRelatedList lightning component
Revision(s)		03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CuAp_LocationRelatedListCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_LocationRelatedListCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    private static final List<String> locationFields = new List<String> {
                                                        CuAp_Constants.LOCATIONADDRESSAPINAME, 
                                                        CuAp_Constants.LOCATIONTYPEAPINAME, 
                                                        CuAp_Constants.POSTALZIPCODEAPINAME, 
                                                        CuAp_Constants.STREETAPINAME, 
                                                        CuAp_Constants.CITYAPINAME, 
                                                        CuAp_Constants.LOCATIONCOUNTRYAPINAME
                                                        };
                                                        
                                                        
    private static final List<String> supplyLocationFields = new List<String> {
                                                        CuAp_Constants.LOCATIONAPINAME
                                                        };
    
    private static List<BlAp_CombinedRecord>  locationRelatedList;
    
    /**********************************************************************************************
    @author         Accenture: Pratyush Kumar
    @date           14 Dec 2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveLocationFieldPropDetails() {
        
        //Build a map list of all field properties
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        //Get the field properties from the contract object
        List<GLAp_FieldProps> locationPropertyList = GlAp_LightningDataAccess.getObjectsFieldProperties(CuAp_Constants.LOCATIONAPINAME, locationFields);
        List<GLAp_FieldProps> supplyPointPropertyList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supplyLocationFields);
        try {
            GlUt_Logger.logDebug(DEBUG);
            //Want to make all of the location fields readonly
            for(GLAp_FieldProps locationProp: locationPropertyList){
                locationProp.isEditable = false;
            }
            
            //Want to make all of the Supply Point fields readonly
            for(GLAp_FieldProps locationProp: supplyPointPropertyList){
                locationProp.isEditable = false;
            }
            
            for(GLAp_FieldProps fldProp : supplyPointPropertyList){
                if (fldProp.fieldName != CuAp_Constants.ID)   //AT-3709
                    fldPropList.add(fldProp); 
            }
            
            for(GLAp_FieldProps fldProp : locationPropertyList){
                if (fldProp.fieldName != CuAp_Constants.ID)   //AT-3709
                    fldPropList.add(fldProp); 
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return fldPropList;
        
    } 
    
    /**********************************************************************************************
    @author         Accenture: Pratyush Kumar
    @date           14 Dec 2017
    @param          String contractId
    @return         List<BlAp_SupressContracts>
    @description    This method takes the contractId to return all related location records in a combined 
                    list of wrapper objects
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveRelatedLocations(String contractId) {
        locationRelatedList = new List<BlAp_CombinedRecord>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            List<Service__c> serviceList = [SELECT Supplypoint__c, Supplypoint__r.Location__c 
                                            FROM Service__c 
                                            WHERE BillingContract__c = :contractId];
            
            Set<Id> locationIdSet = new Set<Id>();
            for (Service__c service : serviceList) {
                locationIdSet.add(service.supplypoint__r.location__c);
            }
            
            if (locationIdSet.isEmpty()) {
                return null;
            }
            
            List<Location__c> locationList = (List<Location__c>) GlAp_LightningDataAccess.getRecords(CuAp_Constants.LOCATIONAPINAME, 
                                                                                                     locationFields,
                                                                                                     'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(locationIdSet));
            
            Set<Id> supplyPointIdSet = new Set<Id>();
            for (Service__c service : serviceList) {
                supplyPointIdSet.add(service.SupplyPoint__c);
            }
            
            if (supplyPointIdSet.isEmpty()) {
                return null;
            }
            
            Map<Id, SupplyPoint__c> supplyLocationMap = new Map<Id, SupplyPoint__c>();
            for (SupplyPoint__c supplyPoint : (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(CuAp_Constants.SUPPLYPOINTAPINAME, 
                                                                                                         supplyLocationFields, 
                                                                                                         'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIdSet))) {
                                                                                                             
                                                                                                             if (supplyLocationMap.keySet().isEmpty() || !supplyLocationMap.containsKey(supplyPoint.Location__c)) {
                                                                                                                 supplyLocationMap.put(supplyPoint.Location__c, supplyPoint);
                                                                                                             }
                                                                                                         }
            
            List<SupplyPoint__c> supplyPointLocationList = supplyLocationMap.values();
            
            Map<Id, Location__c> locationCleansedMap = new Map<Id, Location__c>(locationList);
            for(SObject location : supplyPointLocationList) {
                BlAp_CombinedRecord locationCombRecord = new BlAp_CombinedRecord();            
                locationCombRecord.uniqueId = location.Id;
                locationCombRecord.isSelected = false;
                locationCombRecord.objectMap = new Map<string, sObject>();
                locationCombRecord.objectMap.put(CuAp_Constants.SUPPLYPOINTAPINAME, location);
                Id locationId = ((SupplyPoint__c)location).Location__c;
                System.debug( locationCleansedMap.get(locationId));
                locationCombRecord.objectMap.put(CuAp_Constants.LOCATIONAPINAME, (SObject) locationCleansedMap.get(locationId));
                locationRelatedList.add(locationCombRecord);
                
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return locationRelatedList;
    }
}