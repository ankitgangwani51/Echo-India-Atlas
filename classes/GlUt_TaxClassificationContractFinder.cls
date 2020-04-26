/******************************************************************************
@author         Echo: Patrick Dixon
@date           21 Feb 2018
@description    Contract Finder class for Tax Classification
@revision(s)        
*******************************************************************************/
public with sharing class GlUt_TaxClassificationContractFinder extends GlUt_ContractFinder {
    
    private static final String CLASS_NAME = 'GlUt_TaxClassificationContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           21 Feb 2018
    @param          Id - recordId
    @return         Set<Id> - the set of related contract Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id taxClassificationId) {

        // get the account Id and the dates to define the scope of affected contracts
        Id accountId;
        Date taxClassificationStartDate;
        Date taxClassificationEndDate;
        for (TaxClassification__c taxClassification : [select Id, 
                                                            Account__c, 
                                                            SICStartDate__c, 
                                                            SICEndDate__c  
                                                        from TaxClassification__c 
                                                        where Id = :taxClassificationId]) {
                                        
            accountId = taxClassification.Account__c;
            taxClassificationStartDate = taxClassification.SICStartDate__c;
            taxClassificationEndDate = taxClassification.SICEndDate__c;
        }

        // and use them to find the contracts
        Set<Id> contractIds = new Set<Id>();

        for (Account account : [select Id, 
                                (select Id, 
                                 ContractStartDate__c, 
                                 ContractEndDate__c 
                                 from BillingContracts__r 
                                 where ContractStartDate__c <= :taxClassificationStartDate 
                                ) from Account where Id = :accountId]) {
                                    for (BillingContract__c contract : account.BillingContracts__r) {
                                        if((contract.ContractEndDate__c != null && taxClassificationEndDate != null && contract.ContractEndDate__c > taxClassificationEndDate)
                                           || (contract.ContractEndDate__c == null && taxClassificationEndDate == null)
                                           || (contract.ContractEndDate__c != null && taxClassificationEndDate == null && contract.ContractEndDate__c >= taxClassificationStartDate)
                                           || (contract.ContractEndDate__c == null && taxClassificationEndDate != null && contract.ContractStartDate__c <= taxClassificationEndDate)){
                                               contractIds.add(contract.Id);
                                           }
                                    }   
                                }
        return contractIds;
    }
}