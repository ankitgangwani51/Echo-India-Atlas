/******************************************************************************
@author         Echo: Ankit Gangwani
@date           11 March 2019
@description    Component controller for Manage Site Supply Records
*******************************************************************************/
public with sharing class LoAp_ManageSiteSupplyCtrlr {
    
    @TestVisible private static List<String> locationFields;
    private static List<String> supplyPointList;
    private static List<String> siteSupplyFields;
    private static List<String> locationList;
    
    static{
        //Get Fields from the Location Object
        locationFields = new List<String>();
        locationFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    
     static{
        //Get Fields from the Supply Point Object
        supplyPointList = new List<String>();
        supplyPointList.add(GlUt_APIConstantsSupplyPoint.ID);
        supplyPointList.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME);
        supplyPointList.add(GlUt_APIConstantsLocation.LOCATIONAPINAME);
    }
    
     static{
         //Get Fields from the Site Supply Object
         siteSupplyFields = new List<String>();
         siteSupplyFields.add(GlUt_APIConstantsSiteSupply.SUPPLYPOINTAPINAME);
         siteSupplyFields.add(GlUt_APIConstantsSiteSupply.STARTDATEAPINAME);
         siteSupplyFields.add(GlUt_APIConstantsSiteSupply.ENDDATEAPINAME);
         siteSupplyFields.add(GlUt_APIConstantsSiteSupply.INVALIDAPINAME);         
         siteSupplyFields.add(GlUt_APIConstantsSiteSupply.PERCENTAGESPLITAPINAME);        
    }
    
    static{
        //Get Fields from the Location Object
        locationList = new List<String>();
        locationlist.add(GlUt_APIConstantsLocation.LOCATIONID);
        locationlist.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 11 March 2019    
    @description : Wrapper class for Site Supply Records 
    **********************************************************************************************/   
    public class SiteSupplyWrapper {
        @AuraEnabled public SupplyPoint__c objSupplyPoint;
        @AuraEnabled public String startDate;
        @AuraEnabled public Id  SiteSupplyId;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String strLocationName;
        @AuraEnabled public String recordType;
        @AuraEnabled public String recordIdType;
        @AuraEnabled public String strPercentageSplit;
        @AuraEnabled public String supplyPointId;
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 11 March 2019    
    @description : Wrapper class for Location Address 
    **********************************************************************************************/   
    public class AddressWrapper {
        @AuraEnabled public String address;
        @AuraEnabled public Id locationId;
    }
    
    /******************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 11 March 2019
    @return      : SiteSupplyWrapper
    @description : This method adds a new Site Supply row instance in the component
    *******************************************************************************/
    @AuraEnabled
    public static SiteSupplyWrapper AddMoreRows(String startDate){
        DateTime dt;
        if(startDate != null)
            dt = Date.valueOf(startDate);
        
        SiteSupplyWrapper siteSupplyWrap = new SiteSupplyWrapper();        
        try {
            siteSupplyWrap.objSupplyPoint = new SupplyPoint__c();
            siteSupplyWrap.startDate = startDate != null ? dt.format('dd-MMM-yyyy') : '';
            siteSupplyWrap.endDate = null;
            siteSupplyWrap.strLocationName = '';
            siteSupplyWrap.recordType = System.Label.LoAp_SiteSupplyNewRecord;
            siteSupplyWrap.recordIdType = System.Label.LoAp_SiteSupplyExternal;
            siteSupplyWrap.strPercentageSplit = '';
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return siteSupplyWrap;
    }
    
    /******************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 11 March 2019
    @return      : AddressWrapper
    @description : This method is used to get the address from loation id 
    *******************************************************************************/
    @AuraEnabled
    public static AddressWrapper getAddressFromLocation(string locationId) {
        AddressWrapper addWrap = new AddressWrapper();  
        string strLocationAddress = '';
        if(locationId != null){
            Location__c objLocation = (Location__c)GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsLocation.LOCATIONAPINAME,locationId, locationFields); 
            if(objLocation != null){
                addWrap.locationId = objLocation.Id;
                addWrap.address = objLocation.Address__c.length() > 28 ? objLocation.Address__c.substring(1,28) : objLocation.Address__c;
            }
        }
        return addWrap;
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 March 2019
    @return         List<SiteSupplyWrapper>
    @description    This method is used to get all the existing site supply records based on Supply Point
    **********************************************************************************************/    
    @AuraEnabled
    public static List<SiteSupplyWrapper> retreiveSiteSupplyRecordList(Id supplyPointId){
        List<SiteSupplyWrapper> siteSuppliesWrapper = new List<SiteSupplyWrapper>();    
        
        Set<Id> supplyPointIdSet = new Set<Id>();
        String whereClause;
        Map<Id,Id> mapOfSPIdToLocationId = new Map<Id,Id>();
        Map<Id,SupplyPoint__c> mapOfSupplyPointIdToRecord = new Map<Id,SupplyPoint__c>();
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
                        if(!mapOfSupplyPointIdToRecord.containsKey(sp.Id)){
                            mapOfSupplyPointIdToRecord.put(sp.Id, sp);
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
            
            for(SiteSupply__c objSS : siteSupplyLists) { 
                SiteSupplyWrapper oneRecordSiteSupplyWrap = new SiteSupplyWrapper();
                String address = '';                
                if(mapOfSPIdToLocationId.containsKey(objSS.SupplyPoint__c)){
                    if(mapOfLocationIdToAddress.containsKey(mapOfSPIdToLocationId.get(objSS.SupplyPoint__c))){
                        address = mapOfLocationIdToAddress.get(mapOfSPIdToLocationId.get(objSS.SupplyPoint__c));                                               
                    }
                }
                DateTime dt = Date.valueOf(objSS.StartDate__c);
                oneRecordSiteSupplyWrap.objSupplyPoint = mapOfSupplyPointIdToRecord.containsKey(objSS.SupplyPoint__c) ? mapOfSupplyPointIdToRecord.get(objSS.SupplyPoint__c) : null;
                oneRecordSiteSupplyWrap.startDate = objSS.StartDate__c != null ? dt.format('dd-MMM-yyyy') : null;
                oneRecordSiteSupplyWrap.SiteSupplyId = objSS.Id;
                oneRecordSiteSupplyWrap.strLocationName = address.length() > 28 ? address.substring(1,28) : address;
                oneRecordSiteSupplyWrap.recordType = System.Label.LoAp_SiteSupplyExistingRecord;
                oneRecordSiteSupplyWrap.recordIdType = System.Label.LoAp_SiteSupplyInternal;
                oneRecordSiteSupplyWrap.strPercentageSplit = String.valueOf(objSS.PercentageSplit__c);
                siteSuppliesWrapper.add(oneRecordSiteSupplyWrap);
            }
        }
        return siteSuppliesWrapper;        
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 March 2019
    @return         Id - Site Supply Id
    @description    This method is used to maked the site supply record to Invalid
    **********************************************************************************************/    
    @AuraEnabled
    public static Id updateInvalidSiteSupply(Id siteSupplyPointId){
        
        String filterStatement  = 'WHERE ' +  LoAp_Constants.Id + ' = \''+ string.escapeSingleQuotes(siteSupplyPointId) +'\'';
        List<SiteSupply__c> objSS = (List<SiteSupply__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSiteSupply.SITESUPPLYAPINAME, 
                                                                                                       siteSupplyFields,
                                                                                                       filterStatement);
        if(objSS != null && objSS.size() > 0){
            objSS[0].Invalid__c = true;
            Database.update(objSS);
            return objSS[0].Id;
        }
        return null;
    }
}