/************************************************************************************************************
@author      : Echo : Ankit Gangwani
@date        : 19 Sept 2018
@description : LoAp_ChargeBasisCtrlr class is used to display charge basis based on location
Location >> Supply Point >> Available Service >> Charge Basis
**************************************************************************************************************/
public with sharing class LoAp_ChargeBasisCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_ChargeBasisCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> supplyPointFields;
    private static final List<String> availableServiceFields;
    private static final List<String> chargeBasisFields;
    
    static{
        availableServiceFields = new List<String>();
        availableServiceFields.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);
        
        supplyPointFields = new List<String>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME);
        
        chargeBasisFields = new List<String>();
        chargeBasisFields.add(GlUt_APIConstantsChargeBasis.TYPEAPINAME);  
        chargeBasisFields.add(GlUt_APIConstantsChargeBasis.AVAILABLESERVICEAPINAME);
        chargeBasisFields.add(GlUt_APIConstantsChargeBasis.NAMEAPINAME);
        chargeBasisFields.add(GlUt_APIConstantsChargeBasis.STARTDATEAPINAME);
        chargeBasisFields.add(GlUt_APIConstantsChargeBasis.ENDDATEAPINAME);
        chargeBasisFields.add(GlUt_APIConstantsChargeBasis.AMOUNTAPINAME);        
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 19 Sept 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> getChargeBasisFields() {        
        try{
            List<GlAp_FieldProps> addFieldProp = new List<GlAp_FieldProps>();
            
            //Get the field properties for the Available Service object
            List<GLAp_FieldProps> supplyPointFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supplyPointFields); 
            
            //Get the field properties for the charge Basis object
            List<GLAp_FieldProps> chargeBasisFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsChargeBasis.OBJECTAPINAME, chargeBasisFields); 
            
            
            // Added the Available Service fields 
            for(GlAp_FieldProps fieldProp : supplyPointFieldProp){             
                fieldProp.isEditable = false;                  
                //fieldProp.transformField = true;
                addFieldProp.add(fieldProp);
            } 
            
            // Added the Charge Basis fields
            for(GlAp_FieldProps fieldProp : chargeBasisFieldProp){
                fieldProp.isEditable = false;
                addFieldProp.add(fieldProp);
            }
            
            // Return Available Service and Charge Basis fields to display
            return addFieldProp;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           19 Sept 2018
    @param          locationId
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the BlAp_CombinedRecord with list of Supply Points, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getChargeBasisRecords(Id locationId) {
        
        // Initialised collections
        Set<Id> supplyPointIdsSet = new Set<Id>();
        Set<Id> availableServiceIdsSet = new Set<Id>();
        List<SupplyPoint__c> supplyPointLists = new List<SupplyPoint__c>();
        List<AvailableService__c> availableServiceLists = new List<AvailableService__c>();
        List<ChargeBasis__c> chargeBasisLists = new List<ChargeBasis__c>();
        List<BlAp_CombinedRecord> activeSPDeviceList = new List<BlAp_CombinedRecord>();
        Map<Id,SupplyPoint__c> mapOfSPId2SP = new Map<Id,SupplyPoint__c>();
        Map<Id,AvailableService__c> mapOfAvailServiceId2AvailService= new Map<Id,AvailableService__c>();
        Map<Id,List<ChargeBasis__c>> mapOfAvailServiceId2ChargeBasisLists = new Map<Id,List<ChargeBasis__c>>();
        
        try {
            String filterStatement;            
            filterStatement = ' WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = \'' + locationId + '\'';            
            supplyPointLists = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                          new List<String>{LoAp_Constants.Id,'Name',
                                                                                              GlUt_APIConstantsLocation.LOCATIONAPINAME}, 
                                                                                          filterStatement);                        
            if(!supplyPointLists.isEmpty()){                
                for(SupplyPoint__c objSupplyPoint : supplyPointLists){
                    supplyPointIdsSet.add(objSupplyPoint.Id);
                    mapOfSPId2SP.put(objSupplyPoint.Id,objSupplyPoint);
                }
            }
            
            if(supplyPointIdsSet.size() > 0){
                filterStatement = 'WHERE ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIdsSet) ;                
                availableServiceLists = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME,
                                                                                                        availableServiceFields, 
                                                                                                        filterStatement);
                if(!availableServiceLists.isEmpty()){                    
                    for(AvailableService__c objAvailableService : availableServiceLists){ 
                        availableServiceIdsSet.add(objAvailableService.Id);
                        if(!mapOfAvailServiceId2AvailService.containsKey(objAvailableService.Id)){
                            mapOfAvailServiceId2AvailService.put(objAvailableService.Id,objAvailableService);
                        }
                    }
                }
            }
            
            if(availableServiceIdsSet.size() > 0){
                filterStatement = 'WHERE ' + GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(availableServiceIdsSet) ;                
                chargeBasisLists = (List<ChargeBasis__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsChargeBasis.OBJECTAPINAME,
                                                                                              chargeBasisFields, 
                                                                                              filterStatement);
                
                if(!chargeBasisLists.isEmpty()){                    
                    for(ChargeBasis__c objChargeBasis : chargeBasisLists){ 
                        if(!mapOfAvailServiceId2ChargeBasisLists.containsKey(objChargeBasis.AvailableService__c)){
                            mapOfAvailServiceId2ChargeBasisLists.put(objChargeBasis.AvailableService__c,new List<ChargeBasis__c>());
                        }
                        mapOfAvailServiceId2ChargeBasisLists.get(objChargeBasis.AvailableService__c).add(objChargeBasis);
                    }
                }                
            }
            
            if(!chargeBasisLists.isEmpty()){
                for(ChargeBasis__c objChargeBasis : chargeBasisLists){
                    // Initialised the Combined record to display the data into table
                    BlAp_CombinedRecord combinedRecord = new BlAp_CombinedRecord();
                    combinedRecord.uniqueId = objChargeBasis.Id;
                    combinedRecord.isSelected = false;
                    combinedRecord.objectMap = new Map<String, sObject>();
                    combinedRecord.objectMap.put(GlUt_APIConstantsChargeBasis.OBJECTAPINAME,objChargeBasis);
                    combinedRecord.objectMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,mapOfSPId2SP.get(mapOfAvailServiceId2AvailService.get(objChargeBasis.AvailableService__c).SupplyPoint__c));                    
                    activeSPDeviceList.add(combinedRecord);                    
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return activeSPDeviceList;
    }    
}