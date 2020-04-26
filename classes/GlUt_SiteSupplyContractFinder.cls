/******************************************************************************
@author         Echo: Sudhir Kumar
@date           06 Feb 2019
@description    AT-5110/AT-3489 Contract Finder class for Site Supply
				Retrieve the Contract ID for each Service associated with the Site Supply -> Supply Point where the Service End Date >= Site Supply Start Date or Service End Date is NULL
    
*******************************************************************************/

public with sharing class GlUt_SiteSupplyContractFinder extends GlUt_ContractFinder {
	
    public override set<Id> retrieveContractIds(set<Id> setSiteSupplyIds) {
        system.debug('setSiteSupplyIds=> ' + setSiteSupplyIds) ;
        set<Id> setSiteSupplyContractIds = new set<Id>() ;
        map<Id, SiteSupply__c> mapSiteSupplyPointId2SiteSupplyObj = new map<Id, SiteSupply__c>() ;
        set<Id> setSupplyPointServiceIds ;
        for(SiteSupply__c objSiteSupply : [SELECT Id, SupplyPoint__c, SiteSupplyPoint__c, StartDate__c, EndDate__c, Invalid__c FROM SiteSupply__c WHERE Id IN: setSiteSupplyIds]) {
            mapSiteSupplyPointId2SiteSupplyObj.put(objSiteSupply.SupplyPoint__c, objSiteSupply) ;
        }
        system.debug('mapSiteSupplyPointId2SiteSupplyObj=> ' + mapSiteSupplyPointId2SiteSupplyObj) ;
        if(!mapSiteSupplyPointId2SiteSupplyObj.isEmpty()) {
            setSupplyPointServiceIds = new set<Id>() ;
            for(Service__c service : [SELECT Id, ServiceStartDate__c, BillingContract__c, SupplyPoint__c, ServiceEndDate__c FROM Service__c WHERE SupplyPoint__c IN: mapSiteSupplyPointId2SiteSupplyObj.keySet()]) {
                SiteSupply__c objSiteSupply = mapSiteSupplyPointId2SiteSupplyObj.get(service.SupplyPoint__c) ;
                if(service.ServiceEndDate__c > = objSiteSupply.StartDate__c || service.ServiceEndDate__c == null) {
                    setSiteSupplyContractIds.add(service.BillingContract__c) ;
                }
            }
        }
        system.debug('setSiteSupplyContractIds=> ' + setSiteSupplyContractIds) ;
        return setSiteSupplyContractIds ;
    }
}