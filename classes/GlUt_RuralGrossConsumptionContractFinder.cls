public class GlUt_RuralGrossConsumptionContractFinder extends GlUt_ContractFinder {
	
	private static final String CLASS_NAME = 'GlUt_RuralGrossConsumptionContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Amit K.
	@date      		20 Dec 2018
	@param			Id - recordId
	@return			Set<Id> - the set of related contract Ids
	@description 	finds the set of contract Ids affected by Rural Gross Consumption Amendment.
	*******************************************************************************/
    public override Set<Id> retrieveContractIds (Id ruralGrossConsumptionId) {
        
        Set<Id> contractIds = new Set<Id>();
        for (RuralGrossConsumption__c rgc : [SELECT Id,
                                             RuralEntitlement__r.RuralLicense__r.BillingContract__c
                                             FROM RuralGrossConsumption__c 
                                             WHERE Id = :ruralGrossConsumptionId AND RuralEntitlement__r.Active__c = True]) {
                                                 if(rgc.RuralEntitlement__r.RuralLicense__r.BillingContract__c != null)
                                                     contractIds.add(rgc.RuralEntitlement__r.RuralLicense__r.BillingContract__c); 
                                             }
       
        return contractIds;
    } 
}