/******************************************************************************
@author         Echo: Mohit Tayal
@date           23 July 2018
@description    Contract Finder class for Available Bundle
@revision(s)        
*******************************************************************************/
public with sharing class GlUt_AvailableBundleContractFinder extends GlUt_ContractFinder{

    private static final String CLASS_NAME = 'GlUt_AvailableBundleContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           23 July 2018
    @param          Id - recordId of Available Bundle
    @return         Set<Id> - the set of contract Ids related Available Bundle Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id availableBundleId) {

        Set<Id> contractIds = new Set<Id>();
        Set<Id> availableServiceIds = new Set<Id>();
        for (AvailableBundle__c objAvailableBundle : [SELECT Id,  
										                     AvailableService__c 
									                         FROM AvailableBundle__c 
									                         WHERE Id = :availableBundleId]) {
        	if(objAvailableBundle.AvailableService__c != Null)
        	availableServiceIds.add(objAvailableBundle.AvailableService__c);
        }
        if(!availableServiceIds.isEmpty()){
            for(Service__c objService : [SELECT Id, BillingContract__c 
                                         FROM Service__c 
                                         WHERE AvailableService__c IN :availableServiceIds]){
               contractIds.add(objService.BillingContract__c);                              
            }
        }
        return contractIds;
    }
}