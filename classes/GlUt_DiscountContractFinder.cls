/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		21 Feb 2018
@description 	Contract Finder class for Discount
@revision(s)		
*******************************************************************************/
public with sharing class GlUt_DiscountContractFinder extends GlUt_ContractFinder {
	
	private static final String CLASS_NAME = 'GlUt_DiscountContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		21 Feb 2018
	@param			Id - recordId
	@return			Set<Id> - the set of related contract Ids
	@description 	finds the set of contract Ids affected by an amendment
	*******************************************************************************/
	public override Set<Id> retrieveContractIds (Id discountId) {

    	Set<Id> contractIds = new Set<Id>();
    	for (Discount__c discount : [select Id, 
											BillingContract__c 
										from Discount__c 
										where Id = :discountId]) {
    																	
    		contractIds.add(discount.BillingContract__c);				
		}
		return contractIds;
    }  
}