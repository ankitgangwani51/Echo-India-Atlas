/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		21 Feb 2018
@description 	Contract Finder class for Charge Basis
@revision(s)		
*******************************************************************************/
public with sharing class GlUt_ChargeBasisContractFinder extends GlUt_ContractFinder {
	
	private static final String CLASS_NAME = 'GlUt_ChargeBasisContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		21 Feb 2018
	@param			Id - recordId
	@return			Set<Id> - the set of related contract Ids
	@description 	finds the set of contract Ids affected by an amendment
	*******************************************************************************/
	public override Set<Id> retrieveContractIds (Id chargeBasisId) {

		// get the charge basis dates to define the scope of affected contracts
    	Date chargeBasisStartDate;
    	Date chargeBasisEndDate;
    	for (ChargeBasis__c chargeBasis : [select Id, 
		    									StartDate__c, 
		    									EndDate__c 
		    								from ChargeBasis__c 
		    								where Id = :chargeBasisId]) {
    									
    		chargeBasisStartDate = chargeBasis.StartDate__c;
    		chargeBasisEndDate = chargeBasis.EndDate__c == null ? Date.today() : chargeBasis.EndDate__c;
    	}

    	// build a set of available service Ids
    	Set<Id> availableServiceIds = new Set<Id>();
    	for (ChargeBasis__c chargeBasis : [select Id, 
												AvailableService__c 
											from ChargeBasis__c 
											where Id = :chargeBasisId]) {
    																	
    		availableServiceIds.add(chargeBasis.AvailableService__c);					
		}

		// and use them to find the contracts
    	Set<Id> contractIds = new Set<Id>();
    	for (Service__c service : [select Id, 
										BillingContract__c 
									from Service__c 
									where AvailableService__c in :availableServiceIds 
    									and ServiceStartDate__c <= :chargeBasisEndDate 
    									and (ServiceEndDate__c = null 
    										or ServiceEndDate__c > :chargeBasisStartDate)]) {
    																	
    		contractIds.add(service.BillingContract__c);				
		}
		return contractIds;
    }  
}