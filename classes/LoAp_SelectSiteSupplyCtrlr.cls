/******************************************************************************
@author         Echo: Ankit Gangwani
@date           11 March 2019
@description    Component controller for Existing Site Supply records selection
*******************************************************************************/
public with sharing class LoAp_SelectSiteSupplyCtrlr {
    
    private static List<String> locationFields;
    private static List<String> siteSupplyFields;
    private static List<String> locationList;
    private static List<String> supplyPointList;
    
    static{
        //Get Fields from the Location Object
        locationFields = new List<String>();
        locationFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    
    static{
        //Get Fields from the Site Supply Object
        siteSupplyFields = new List<String>();
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.SUPPLYPOINTAPINAME);
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.STARTDATEAPINAME);
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.ENDDATEAPINAME);
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.PERCENTAGESPLITAPINAME);        
    }
    
    static{
        //Get Fields from the Supply Point Object
        supplyPointList = new List<String>();
        supplyPointList.add(GlUt_APIConstantsSupplyPoint.ID);
        supplyPointList.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME);
        supplyPointList.add(GlUt_APIConstantsLocation.LOCATIONAPINAME);
    }
    
    static{
        //Get Fields from the Location Object
        locationList = new List<String>();
        locationlist.add(GlUt_APIConstantsLocation.LOCATIONID);
        locationlist.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 March 2019
    @return         List<GLAp_FieldProps>
    @description    method for the properties of Site Supply fields displayed in wizard screen
    **********************************************************************************************/    
    @AuraEnabled
    public static List<GLAp_FieldProps> retreiveSiteSupplyFieldList(){
        List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();

        List<GLAp_FieldProps> siteSupplyFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSiteSupply.SITESUPPLYAPINAME, siteSupplyFields);
        
        for(GlAp_FieldProps fieldProp : siteSupplyFieldProp){
            fieldProp.isEditable = false;
            if(fieldProp.fieldName == GlUt_APIConstantsSiteSupply.SUPPLYPOINTAPINAME){
                fieldProp.fieldLabel = PyAp_Constants.SUPPLYPOINT_FIELDLABEL;
                allFieldProp.add(fieldProp);
            }
        }
        
        //Transform Field for Location 
        GLAp_FieldProps locProp = new GLAp_FieldProps();
        locProp.isFLSVisible = false;
        locProp.isEncrypted  = false;
        locProp.isEditable   = true;
        locProp.isRequired   = false;
        locProp.fieldName    = GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME;
        locProp.fieldLabel   = LoAp_Constants.LOCATIONADDRESSLABEL;
        locProp.fieldType    = LoAp_Constants.TEXT;
        locProp.transformField = true; 
        locProp.parentObject = GlUt_APIConstantsLocation.LOCATIONAPINAME;
        allFieldProp.add(locProp);
        
        //Transform Field for Location 
        GLAp_FieldProps spName = new GLAp_FieldProps();
        spName.isFLSVisible = false;
        spName.isEncrypted  = false;
        spName.isEditable   = true;
        spName.isRequired   = false;
        spName.fieldName    = GlUt_APIConstantsSupplyPoint.NAMEAPINAME;
        spName.fieldLabel   = GlUt_APIConstantsSupplyPoint.NAMEAPINAME;
        spName.fieldType    = LoAp_Constants.TEXT;
        spName.transformField = true; 
        spName.parentObject = GlUt_APIConstantsSupplyPoint.NAMEAPINAME;        
        
        for(GlAp_FieldProps fieldProp : siteSupplyFieldProp){
            fieldProp.isEditable = false;
            if(fieldProp.fieldName != GlUt_APIConstantsSiteSupply.SUPPLYPOINTAPINAME){
                allFieldProp.add(fieldProp);
            }
        }
        return allFieldProp;
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 March 2019
    @return         List<GLAp_FieldProps>
    @description    method to get all the existing site supply records based on Supply Point to be displayed on wizard screen
    **********************************************************************************************/    
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retreiveSiteSupplyRecordList(Id supplyPointId){
        List<BlAp_CombinedRecord> combinedRecord = new List<BlAp_CombinedRecord>();
        Set<Id> supplyPointIdSet = new Set<Id>();
        String whereClause;
        Map<Id,Id> mapOfSPIdToLocationId = new Map<Id,Id>();
        Map<Id,String> mapOfSPIdToName = new Map<Id,String>();
        Map<Id,String> mapOfLocationIdToAddress = new Map<Id,String>();
        
        String filterStatement  = 'WHERE ' +  GlUt_APIConstantsSiteSupply.SITESUPPLYPOINTAPINAME + ' = \''+ string.escapeSingleQuotes(supplyPointId) +'\' ' 
            +  ' AND ' + GlUt_APIConstantsSiteSupply.INVALIDAPINAME + ' = FALSE' 
            + ' AND ' + GlUt_APIConstantsSiteSupply.AMENDEDBYSITESUPPLYAPINAME + ' = null '
            + ' AND (' + GlUt_APIConstantsSiteSupply.ENDDATEAPINAME + ' = null OR ' + GlUt_APIConstantsSiteSupply.ENDDATEAPINAME + ' >= TODAY)';
        
        List<SiteSupply__c> siteSupplyLists = (List<SiteSupply__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSiteSupply.SITESUPPLYAPINAME, 
                                                                                                       siteSupplyFields,
                                                                                                       filterStatement);
        
        if(!siteSupplyLists.isEmpty() && siteSupplyLists.size() > 0){
            for(SiteSupply__c objSS : siteSupplyLists){                
                supplyPointIdSet.add(objSS.SupplyPoint__c);
            }
            
            if(supplyPointIdSet != null && supplyPointIdSet.size() > 0){
                whereClause = String.format('WHERE {0} IN {1}',new List<String>{LoAp_Constants.Id,GlUt_FieldSecurity.IdsToString(supplyPointIdSet)});
                List<SupplyPoint__c> supplyPointLists = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                            supplyPointList,
                                                                                            whereClause);   
                
                if(!supplyPointLists.isEmpty() && supplyPointLists.size() > 0){
                    for(SupplyPoint__c sp : supplyPointLists){
                        if(!mapOfSPIdToLocationId.containsKey(sp.Id)){
                            mapOfSPIdToLocationId.put(sp.Id, sp.Location__c);
                        }
                        if(!mapOfSPIdToName.containsKey(sp.Id)){
                            mapOfSPIdToName.put(sp.Id, sp.Name);
                        }
                        
                    }
                    if(mapOfSPIdToLocationId != null && mapOfSPIdToLocationId.KeySet().size() > 0){
                        whereClause = String.format('WHERE {0} IN {1}',new List<String>{LoAp_Constants.Id,GlUt_FieldSecurity.IdsToString(mapOfSPIdToLocationId.values())});
                        List<Location__c> locationLists = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME, 
                                                                                                    locationList,
                                                                                                    whereClause); 
                        
                        if(!locationLists.isEmpty() && locationLists.size() > 0){
                            for(Location__c loc : locationLists){
                                if(!mapOfLocationIdToAddress.containsKey(loc.Id)){
                                    mapOfLocationIdToAddress.put(loc.Id,loc.Address__c);
                                }
                            }
                        }
                    }
                }
            }
            
            for (SiteSupply__c objSS : siteSupplyLists) { 
                String address = '';                
                if(mapOfSPIdToLocationId.containsKey(objSS.SupplyPoint__c)){
                    if(mapOfLocationIdToAddress.containsKey(mapOfSPIdToLocationId.get(objSS.SupplyPoint__c))){
                        address = mapOfLocationIdToAddress.get(mapOfSPIdToLocationId.get(objSS.SupplyPoint__c));                                               
                    }
                }
                BlAp_CombinedRecord combRec = new BlAp_CombinedRecord();            
                combRec.uniqueId            = objSS.Id;
                combRec.isSelected          = false;
                combRec.readOnlyFields      = new Map<string, boolean>();
                combRec.objectMap           = new Map<string, sObject>();
                combRec.objectMap.put(GlUt_APIConstantsSiteSupply.SITESUPPLYAPINAME, objSS);
                combRec.transformFieldMap = new Map<String,Map<String,String>>();
                
                Map<String,String> LocationTransformFieldMap = new Map<String,String>();
                LocationTransformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME,address.length() > 28 ? address.substring(1,28) : address);
                combRec.transformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME,LocationTransformFieldMap); 
                
                Map<String,String> spNameTransformFieldMap = new Map<String,String>();
                spNameTransformFieldMap.put(GlUt_APIConstantsSupplyPoint.NAMEAPINAME,mapOfSPIdToName.get(objSS.SupplyPoint__c));
                combRec.transformFieldMap.put(GlUt_APIConstantsSupplyPoint.NAMEAPINAME,spNameTransformFieldMap);
                combinedRecord.add(combRec);
            }
        }
        return combinedRecord;        
    }
}