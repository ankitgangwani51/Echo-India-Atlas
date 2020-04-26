/******************************************************************************
@author         Echo: Patrick Dixon
@date           19 Mar 2018
@description    Contract Finder class for Agreed Sample Strength
@revision(s)        
*******************************************************************************/
public with sharing class GlUt_AgreedSampleStrengthContractFinder extends GlUt_ContractFinder {
    
    private static final String CLASS_NAME = 'GlUt_AgreedSampleStrengthContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           19 Mar 2018
    @param          Id - recordId
    @return         Set<Id> - the set of related agreed sample strength Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id agreedSampleStrengthId) {

     /*   Set<Id> contractIds = new Set<Id>();    //AT-3147 Commented as  DischargeAgreement is moved to Service Item
        for (Service__c service : [select Id, 
										DischargeAgreement__c, 
										Contract__c 
									from Service__c 
									where DischargeAgreement__c in (select DischargeAgreement__c 
																	from AgreedSampleStrength__c 
																	where Id = :agreedSampleStrengthId)]) {
        	
        	contractIds.add(service.Contract__c);*/
        
        //AT-3147  Block started
        Set<Id> contractIds = new Set<Id>(); 
        Set<Id> serviceItemSet = new Set<Id>();
        
        for (ServiceItem__c serviceItemObj : [select Id, 
                                              Service__c
                                              from ServiceItem__c 
                                              where DischargeAgreement__c in (select DischargeAgreement__c 
                                                                              from AgreedSampleStrength__c 
                                                                              where Id = :agreedSampleStrengthId)]) {
            serviceItemSet.add(serviceItemObj.Service__c);
        }
        if(serviceItemSet != null) {
            for(Service__c service : [select Id, BillingContract__c from Service__c where Id in:serviceItemSet]) {
                contractIds.add(service.BillingContract__c);
            }
        }
        //AT-3147  Block Ends
        
        return contractIds;
    }  
}