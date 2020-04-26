public class GlUt_SupplyPointBandContractFinder extends GlUt_ContractFinder {
	
	private static final String CLASS_NAME = 'GlUt_SupplyPointBandContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Amit K.
	@date      		13 July 2018
	@param			Id - recordId
	@return			Set<Id> - the set of related contract Ids
	@description 	finds the set of contract Ids affected by Supply Point Band.
	*******************************************************************************/
    public override Set<Id> retrieveContractIds (Id supplyPointBandId) {
        
        Set<Id> contractIds = new Set<Id>();
        Id supplyPointId; 
        Date spbStartDate;
        for (SupplyPointBand__c spb : [SELECT Id, 
                                       SupplyPoint__c,
                                       StartDate__c
                                       FROM SupplyPointBand__c 
                                       WHERE Id = :supplyPointBandId LIMIT 1]) {
                                           supplyPointId = spb.SupplyPoint__c;
                                           spbStartDate = spb.StartDate__c;
                                       }
        if(supplyPointId != null && spbStartDate !=null ){
            for (Service__c service : [SELECT Id, 
                                       SupplyPoint__c,
                                       BillingContract__c,
                                       ServiceEndDate__c
                                       FROM Service__c 
                                       WHERE SupplyPoint__c =:supplyPointId AND (ServiceEndDate__c = NULL OR ServiceEndDate__c >=: spbStartDate)]) {
                                           contractIds.add(service.BillingContract__c);				
                                       }
        }
        return contractIds;
    }  
}