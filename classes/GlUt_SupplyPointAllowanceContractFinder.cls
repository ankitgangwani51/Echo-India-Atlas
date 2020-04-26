/******************************************************************************
@author         Echo: Mohit Tayal
@date           04 July 2018
@description    Contract Finder class for Supply Point Allowance
@revision(s)        
*******************************************************************************/
public with sharing class GlUt_SupplyPointAllowanceContractFinder extends GlUt_ContractFinder{
    
    private static final String CLASS_NAME = 'GlUt_SupplyPointAllowanceContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           04 July 2018
    @param          Id - recordId
    @return         Set<Id> - the set of related Supply Point Allowance Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id supplypointallowanceId) {

        Set<Id> contractIds = new Set<Id>();
        for (SupplyPointAllowance__c objSupplyPointAllowance : [SELECT Id,  
										                        ServiceItem__r.Service__r.BillingContract__c 
									                            FROM SupplyPointAllowance__c 
									                            WHERE Id = :supplypointallowanceId]) {
        	
        	contractIds.add(objSupplyPointAllowance.ServiceItem__r.Service__r.BillingContract__c);
        }
        return contractIds;
    }  
}