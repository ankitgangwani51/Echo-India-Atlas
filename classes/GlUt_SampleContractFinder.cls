/******************************************************************************
@author    		Echo: Dependra Singh
@date      		19 Sept 2018
@description 	Contract Finder class for Sample
Revision(s)		
*******************************************************************************/
public with sharing class GlUt_SampleContractFinder extends GlUt_ContractFinder{
    private static final String CLASS_NAME = 'GlUt_SampleContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           19 Sept 2018
    @param          Id - sampleId
    @return         Set<Id> - the set of related agreed rate Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id sampleId) {
        // and use it to find the contracts
        Set<Id> contractIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        for (Sample__c sampleObj : [SELECT Id, DischargeAgreement__r.Location__c FROM Sample__c WHERE Id = :sampleId]) {
            locationIds.add(sampleObj.DischargeAgreement__r.Location__c);
        }
        // build a set of supplypoint Ids
        Set<Id> supplyPointsIds = new Set<Id>();
        if(locationIds.size() > 0){
            for(SupplyPoint__c supplyPointObj : [SELECT Id, Location__c FROM SupplyPoint__c WHERE Location__c IN : locationIds]){
                supplyPointsIds.add(supplyPointObj.Id);                                           
            }
        }
        if(supplyPointsIds.size() > 0){
            for(Service__c serviceObj : [SELECT Id, BillingContract__c FROM Service__c WHERE SupplyPoint__c IN : supplyPointsIds]){
                contractIds.add(serviceObj.BillingContract__c);                                           
            }
        }
        return contractIds;
    }
}