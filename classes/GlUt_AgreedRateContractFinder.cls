/******************************************************************************
@author         Echo: Patrick Dixon
@date           19 Mar 2018
@description    Contract Finder class for Agreed Rate
@revision(s)        
*******************************************************************************/
public with sharing class GlUt_AgreedRateContractFinder extends GlUt_ContractFinder {
    
    private static final String CLASS_NAME = 'GlUt_AgreedRateContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           19 Mar 2018
    @param          Id - recordId
    @return         Set<Id> - the set of related agreed rate Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id agreedRateId) {

        Set<Id> contractIds = new Set<Id>();
        for (AgreedRate__c agreedRate : [select Id, 
        										ServiceItem__r.Service__r.BillingContract__c 
										from AgreedRate__c 
										where Id = :agreedRateId]) {
        	
        	contractIds.add(agreedRate.ServiceItem__r.Service__r.BillingContract__c);
        }
        return contractIds;
    }  
}