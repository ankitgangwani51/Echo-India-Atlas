/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		21 Feb 2018
@description 	Contract Finder class for Manual Amendment
@revision(s)		
*******************************************************************************/
public with sharing class GlUt_ManualAmendmentContractFinder extends GlUt_ContractFinder {
	
	private static final String CLASS_NAME = 'GlUt_ManualAmendmentContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		21 Feb 2018
	@param			Id - recordId
	@return			Set<Id> - the set of related contract Ids
	@description 	finds the set of contract Ids affected by an amendment
	*******************************************************************************/
	public override Set<Id> retrieveContractIds (Id manualAmendmentId) {

    	Set<Id> contractIds = new Set<Id>();
    	for (ManualAmendment__c manualAmendment : [select Id, 
														AmendedBillItem__r.ServiceItem__r.Service__r.BillingContract__c 
													from ManualAmendment__c 
													where Id = :manualAmendmentId]) {
    																	
    		contractIds.add(manualAmendment.AmendedBillItem__r.ServiceItem__r.Service__r.BillingContract__c);				
		}
		return contractIds;
    } 
}