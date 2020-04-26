/******************************************************************************
@author         Echo: Ankit Gangwani
@date           11 March 2019
@description    Component controller for Site Supply Wizard
*******************************************************************************/
public class LoAp_SiteSupplyWizardCtrlr {
    
    public static WizardObject wizObject;
    
    private static final String CLASS_NAME = 'LoAp_SiteSupplyWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    public class WizardObject {
        @TestVisible private Id recordId;
        @TestVisible private Id supplyPointId; 
        @TestVisible private String wizardType;
        @TestVisible private Datetime effectiveEndDate;  
        @TestVisible private List<SiteSupply__c> siteSuppliesToEnded; 
        @TestVisible private List<SiteSupply__c> siteSuppliesToCreate;
        @TestVisible private List<SiteSupply__c> siteSupplyToCreateAddRows;
        @TestVisible private List<SiteSupply__c> siteSupplyToAmendCreate;
        @TestVisible private List<SiteSupply__c> siteSuppliesToInvalid;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 March 2019
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    @AuraEnabled
    public static void WizardStatus(String wizardprop) {
        try{
            GlUt_Logger.logDebug(DEBUG);
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }      
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 March 2019
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void UpdateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserializeStrict(wizardprop, WizardObject.class);       
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           11 March 2019
    @param          String - json string of object wizardprop
    @return         List<Id> - Return the list of Billing Contract IDs
    @description    Method called by wizard to complete the Site Supply Records.
    *******************************************************************************/
    @AuraEnabled
    public static List<Id> processSiteSupplies(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        Set<Id> setOfSiteSuppliesForBilling = new Set<Id>();
        Set<Id> setOfSiteSuppliesForSplit = new Set<Id>();
        List<Id> listOfSSContractIdsForBilling = new List<Id>();
        List<SiteSupply__c> amendedSiteSupplyList = new List<SiteSupply__c>();
        List<SiteSupply__c> siteSuppliesToAmend = new List<SiteSupply__c>();
        List<SiteSupply__c> siteSuppliesToCreate = new List<SiteSupply__c>();
        Map<Id,SiteSupply__c> mapOfSSIdToModifiedRecord = new Map<Id,SiteSupply__c>();
        Map<Id,SiteSupply__c> mapOfSSIdToExistingRecord = new Map<Id,SiteSupply__c>();
        Map<Id,SiteSupply__c> mapOfSSIdToActualModifiedRecord = new Map<Id,SiteSupply__c>();
        Map<Id,SiteSupply__c> addedSiteSupplyMap = new  Map<Id,SiteSupply__c>();
        Map<Id,Id> mapOfSSSPIdToExistingSSId = new Map<Id,Id>();
        Map<Id,Id> mapOfExistingSSIdToNewSSId = new Map<Id,Id>();
        
        
        try{
            UpdateWizardProperties(wizardprop); 
            
            if(wizObject.siteSupplyToCreateAddRows!=null) {
                wizObject.siteSupplyToCreateAddRows = (List<SiteSupply__c>) GlUt_FieldSecurity.cleanseFields(wizObject.siteSupplyToCreateAddRows, false);
                insert wizObject.siteSupplyToCreateAddRows;
            }
            
            if(wizObject.siteSuppliesToEnded!=null) {
                wizObject.siteSuppliesToEnded = (List<SiteSupply__c>) GlUt_FieldSecurity.cleanseFields(wizObject.siteSuppliesToEnded, false);
                update wizObject.siteSuppliesToEnded;
                for(SiteSupply__c objSS: wizObject.siteSuppliesToEnded){
                    setOfSiteSuppliesForBilling.add(objSS.Id);    
                } 
            }
            
            if(wizObject.siteSupplyToAmendCreate != null) {                
                for(SiteSupply__c objSS: wizObject.siteSupplyToAmendCreate){
                    if(!mapOfSSIdToModifiedRecord.containsKey(objSS.Id))
                        mapOfSSIdToModifiedRecord.put(objSS.Id,objSS);
                }
                if(!mapOfSSIdToModifiedRecord.isEmpty()){
                    for(SiteSupply__c objSS: [SELECT Id, 
                                              StartDate__c,
                                              EndDate__c,
                                              SupplyPoint__c,
                                              Ended__c, 
                                              PercentageSplit__c ,
                                              SiteSupplyPoint__c, 
                                              AmendedBySiteSupply__c
                                              FROM SiteSupply__c WHERE Id IN:mapOfSSIdToModifiedRecord.keySet()])
                    {
                        if(objSS.PercentageSplit__c != mapOfSSIdToModifiedRecord.get(objSS.Id).PercentageSplit__c || 
                           objSS.StartDate__c != mapOfSSIdToModifiedRecord.get(objSS.Id).StartDate__c){
                               mapOfSSIdToActualModifiedRecord.put(objSS.Id,mapOfSSIdToModifiedRecord.get(objSS.Id));
                               if(!mapOfSSIdToExistingRecord.containsKey(objSS.Id))
                                   mapOfSSIdToExistingRecord.put(objSS.Id,objSS);
                           }
                    }
                    
                    System.debug('mapOfSSIdToActualModifiedRecord = '+mapOfSSIdToActualModifiedRecord);
                    for(SiteSupply__c modifiedSiteSupply: mapOfSSIdToActualModifiedRecord.values()){
                        SiteSupply__c ssObj = new SiteSupply__c(StartDate__c = modifiedSiteSupply.StartDate__c,
                                                               SupplyPoint__c = modifiedSiteSupply.SupplyPoint__c,
                                                               SiteSupplyPoint__c = modifiedSiteSupply.SiteSupplyPoint__c,
                                                               PercentageSplit__c = modifiedSiteSupply.PercentageSplit__c);
                        addedSiteSupplyMap.put(modifiedSiteSupply.Id,ssObj); 
                        if(modifiedSiteSupply.SupplyPoint__c != null && !mapOfSSSPIdToExistingSSId.containsKey(modifiedSiteSupply.SupplyPoint__c))
                            mapOfSSSPIdToExistingSSId.put(modifiedSiteSupply.SupplyPoint__c,modifiedSiteSupply.Id);
                        
                    }
                    
                    System.debug('addedSiteSupplyMap = '+addedSiteSupplyMap);
                    if(!addedSiteSupplyMap.isEmpty()){
                        List<SiteSupply__c> listSiteSupply = addedSiteSupplyMap.values();
                        listSiteSupply = (List<SiteSupply__c>) GlUt_FieldSecurity.cleanseFields(listSiteSupply, false);
                        System.debug('listSiteSupply = '+listSiteSupply);
                        insert listSiteSupply ;
                        System.debug('After insert listSiteSupply = '+listSiteSupply);
                        for(SiteSupply__c objSS: listSiteSupply){
                            if(objSS.SupplyPoint__c != null && mapOfSSSPIdToExistingSSId.containsKey(objSS.SupplyPoint__c) && !mapOfExistingSSIdToNewSSId.containsKey(objSS.SupplyPoint__c))
                                mapOfExistingSSIdToNewSSId.put(mapOfSSSPIdToExistingSSId.get(objSS.SupplyPoint__c),objSS.Id);                            
                        }
                        System.debug('mapOfExistingSSIdToNewSSId = '+mapOfExistingSSIdToNewSSId);
                    }
                    
                    for(SiteSupply__c existingSS: mapOfSSIdToExistingRecord.values()){
                        existingSS.AmendedBySiteSupply__c = mapOfExistingSSIdToNewSSId.containsKey(existingSS.Id) ? mapOfExistingSSIdToNewSSId.get(existingSS.Id) : null;
                        setOfSiteSuppliesForBilling.add(existingSS.Id);
                        amendedSiteSupplyList.add(existingSS);
                    }
                    System.debug('amendedSiteSupplyList = '+amendedSiteSupplyList);
                    if(!amendedSiteSupplyList.isEmpty()){
                        amendedSiteSupplyList = (List<SiteSupply__c>) GlUt_FieldSecurity.cleanseFields(amendedSiteSupplyList, false);
                        System.debug('cleanse amendedSiteSupplyList = '+amendedSiteSupplyList);
                        update amendedSiteSupplyList;
                        System.debug('after update amendedSiteSupplyList = '+amendedSiteSupplyList);
                    }   
                }
            }
            if(!setOfSiteSuppliesForBilling.isEmpty()) {
                GlUt_SiteSupplyContractFinder siteSupplyContractFinder = new GlUt_SiteSupplyContractFinder();
                listOfSSContractIdsForBilling.addAll(siteSupplyContractFinder.retrieveContractIds(setOfSiteSuppliesForBilling));                
            } 
            return listOfSSContractIdsForBilling;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}