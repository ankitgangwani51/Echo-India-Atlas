/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		21 Feb 2018
@description 	Contract Finder class for Service Item
@revision(s)		
*******************************************************************************/
public with sharing class GlUt_ServiceItemContractFinder extends GlUt_ContractFinder {
	private static final String CLASS_NAME = 'GlUt_ServiceItemContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		21 Feb 2018
	@param			Id - recordId
	@return			Set<Id> - the set of related contract Ids
	@description 	finds the set of contract Ids affected by an amendment
	*******************************************************************************/
	public override Set<Id> retrieveContractIds (Id serviceItemId) {

    	Set<Id> contractIds = new Set<Id>();
    	for (ServiceItem__c serviceItem : [select Id, 
												Service__r.BillingContract__c 
											from ServiceItem__c 
											where Id = :serviceItemId]) {
    																	
    		contractIds.add(serviceItem.Service__r.BillingContract__c);				
		}
		return contractIds;
    } 
}