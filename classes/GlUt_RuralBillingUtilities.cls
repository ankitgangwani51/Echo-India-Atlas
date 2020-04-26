/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		11 Dec 2018
@description 	Class for Rural Billing utilities
*******************************************************************************/
public class GlUt_RuralBillingUtilities {
    
    private static final String CLASS_NAME = 'GlUt_RuralBillingUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
	@author    		Echo: Tarun Gupta
	@date      		11 Dec 2018
	@param			Id - rural License Id
	@return			Boolean - true for a Active Rural License
	@description	Checks the rural license to see if it's active
	*******************************************************************************/
    public static Boolean isActiveRuralLicense(Id ruralLicenseId) {
        
        // check if the account record type is a match
        for (RuralLicense__c account : [select Id,Status__c 
                                from RuralLicense__c
                                where Id = :ruralLicenseId
                                and Status__c =: Label.BlAp_RuralLicenseStatusActive]) {
                                    return true;
                                }
        return false;
    }  
    
   /******************************************************************************
	@author    		Echo: Amit K.
	@date      		11 Dec 2018
	@param			Set<Id> licenceIdSet
	@return			List<RuralEntitlement__c> list of Active Rural Entitlement on the basis
                    of Licence Ids.
	@description	Fetch the Active rural entitlemet record on the basis of licences.
	*******************************************************************************/
    public static List<RuralEntitlement__c> getActiveRuralEntitlement(Set<Id> licenceIdSet) {
        List<RuralEntitlement__c> ruralEntitlementList = new List<RuralEntitlement__c>();
        for(RuralEntitlement__c ruralEntitlement: [Select Id,
                                                   RuralLicense__c
                                                   from RuralEntitlement__c
                                                   Where RuralLicense__c In: licenceIdSet AND Active__c = True ]){
                                                       ruralEntitlementList.add(ruralEntitlement);                             
                                                   }  
        return ruralEntitlementList;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		11 Dec 2018
	@param			Set<Id> channelIdSet
	@return			List<RuralChannel__c> list of Rural Channel on the basis
                    of rural channel Ids.
	@description	Fetch the rural Channel record on the basis of rural channelIds.
	*******************************************************************************/
    public static List<RuralChannel__c> getRuralChannel(Set<Id> ruralChannelIdSet) {
        List<RuralChannel__c> ruralChannelList = new List<RuralChannel__c>();
        for(RuralChannel__c ruralChannel: [Select Id,
                                           UncontrolledDailyVolume__c,
                                           ValidDeviceTypes__c,
                                           ValidOutletTypes__c  // AT-4473
                                           from RuralChannel__c
                                           Where Id In: ruralChannelIdSet]){
                                               ruralChannelList.add(ruralChannel);                             
                                           }  
        return ruralChannelList;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		11 Dec 2018
	@param			List<String> queryFields, String objectName, Set<Id> objectSpecificIdSet, string filterField, string extrafilterField, string ruralOutletBillingType, string recordType
	@return			List<sObject> list of sobject on the basis
                    of Ids and rural outlet Billing type and record Type.
	@description	Fetch the Supply Point record on the basis of rural channelIds or supply point Ids.
	*******************************************************************************/
    public static List<sObject> fetchSupplyPoint(List<String> queryFields, String objectName, Set<Id> objectSpecificIdSet, string filterField, string extrafilterField, string ruralOutletBillingType, string recordType) {
        string queryString = String.format('select {0} from {1}', new List<String>{String.join(queryFields, ', '),objectName}); 
        String filterStatement = ' WHERE '+ filterField +' In:objectSpecificIdSet';
        if(string.isNotBlank(recordType))
           filterStatement = filterStatement +'  AND RecordTypeId =: recordType ';
        if(string.isNotBlank(extrafilterField) && string.isNotBlank(ruralOutletBillingType))
            filterStatement = filterStatement +'  AND '+ extrafilterField +'=: ruralOutletBillingType';
        queryString = queryString + filterStatement;
        return Database.query(queryString);
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		11 Dec 2018
	@param			Set<Id> supplyPointLicenceIds
	@return			Map<Id,Id> map of rural Licence having Entitlement.
	@description	get map of Licence Id having Entitlement associated with it.
	*******************************************************************************/
    public static Map<Id,Id> getMapOfRuralLicenceHavingEntitlementId(Set<Id> supplyPointLicenceIds) {
        Map<Id,Id> mapOfRuralLicenceId2RuralEntitlementId = new Map<Id,Id>();
        //Fetch rural entitlement that are associated with Supply point licence and are active.
        List<RuralEntitlement__c> listActiveRuralEntitlement = getActiveRuralEntitlement(supplyPointLicenceIds);
        if(listActiveRuralEntitlement != null && !listActiveRuralEntitlement.isEmpty()){
            for(RuralEntitlement__c ruralEntitlement : listActiveRuralEntitlement){
                mapOfRuralLicenceId2RuralEntitlementId.put(ruralEntitlement.RuralLicense__c,ruralEntitlement.Id);                                         
            }
        }
        return mapOfRuralLicenceId2RuralEntitlementId;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		11 Dec 2018
	@param			Set<Id> readingIds
	@return			List<RuralGrossConsumption__c> rural gross consumption
	@description	get rural gross consumptions on the basis of reading.
	*******************************************************************************/
    public static List<RuralGrossConsumption__c> getRuralGrossConsumptionFromReading(Set<Id> readingIds) {
        List<RuralGrossConsumption__c> ruralGrossConsumptionList = new List<RuralGrossConsumption__c>();
        for(RuralGrossConsumption__c ruralGrossConsumption : [Select Id,
                                                              Reading__c,
                                                              StartDate__c,
                                                              EndDate__c,
                                                              Consumption__c,
                                                              Type__c
                                                              from RuralGrossConsumption__c where Reading__c In: readingIds]){
                                                                  ruralGrossConsumptionList.add(ruralGrossConsumption); 
                                                              }
        return ruralGrossConsumptionList;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		14 Dec 2018
	@param			Set<Id> contractIds
	@return			List<RuralEntitlement__c> rural Entitlement
	@description	get rural entitlement on the basis of contractId.
	*******************************************************************************/
    public static List<RuralEntitlement__c> getRuralEntitlementFromContractIds(Set<Id> contractIds) {
        List<RuralEntitlement__c> ruralEntitlementList = new List<RuralEntitlement__c>();
        for(RuralEntitlement__c ruralEntitlement: [Select Id,
                                                   RuralLicense__c,
                                                   RuralLicense__r.BillingContract__c,
                                                   EndDate__c,
                                                   BaseVolume__c,
                                                   SeasonalAllocation__c,
                                                   PermanentTransfersIn__c,
                                                   PermanentTransfersOut__c,
                                                   TemporaryTransfersIn__c,
                                                   TemporaryTransfersOut__c,
                                                   DeliveredMeteredVolume__c,
                                                   DeliveredHeadVolume__c,
                                                   DeliveredUncontrolledVolume__c,
                                                   AllocatedVolume__c,
                                                   RuralLicense__r.Name,
                                                   RuralLicense__r.TransferredFromLicense__r.TransferDate__c
                                                   from RuralEntitlement__c
                                                   Where RuralLicense__r.BillingContract__c In: contractIds AND Active__c = True]){
                                                       ruralEntitlementList.add(ruralEntitlement);                             
                                                   }  
        return ruralEntitlementList;
    }
    
}