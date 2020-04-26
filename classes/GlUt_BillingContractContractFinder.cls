/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		08 Mar 2018
@description 	Contract Finder class for Contract
				Used to support simulated billing from a button on the contract page
Revision(s)		
*******************************************************************************/
public with sharing class GlUt_BillingContractContractFinder extends GlUt_ContractFinder {
	
	private static final String CLASS_NAME = 'GlUt_ContractContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		21 Feb 2018
	@param			Id - recordId
	@return			Set<Id> - the set of contract Ids
	@description 	returns the record Id as a set of contract Ids
	*******************************************************************************/
	public override Set<Id> retrieveContractIds (Id contractId) {

		return new Set<Id> {contractId};
    }  
}