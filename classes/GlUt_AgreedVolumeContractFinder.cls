/******************************************************************************
@author         Echo: Patrick Dixon
@date           19 Mar 2018
@description    Contract Finder class for Agreed Volume
@revision(s)        
*******************************************************************************/
public with sharing class GlUt_AgreedVolumeContractFinder extends GlUt_ContractFinder {
    
    private static final String CLASS_NAME = 'GlUt_AgreedVolumeContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           19 Mar 2018
    @param          Id - recordId
    @return         Set<Id> - the set of related agreed volume Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id agreedVolumeId) {

     /*   Set<Id> contractIds = new Set<Id>();    //AT-3147 Commented as  DischargeAgreement is moved to Service Item
        for (Service__c service : [select Id, 
										DischargeAgreement__c, 
										Contract__c 
									from Service__c 
									where DischargeAgreement__c in (select DischargeAgreement__c 
																	from AgreedVolume__c 
																	where Id = :agreedVolumeId)]) {
        	
        	contractIds.add(service.Contract__c);
        }*/
        
        //AT-3147  Block started
        Set<Id> contractIds = new Set<Id>(); 
        Set<Id> serviceItemSet = new Set<Id>();
        
        for (ServiceItem__c serviceItemObj : [select Id, 
                                              Service__c
                                              from ServiceItem__c 
                                              where DischargeAgreement__c in (select DischargeAgreement__c 
                                                                              from AgreedVolume__c 
                                                                              where Id = :agreedVolumeId)]) {
            serviceItemSet.add(serviceItemObj.Service__c);
        }
        if(serviceItemSet != null)  {
            for(Service__c service : [select Id, BillingContract__c from Service__c where Id in:serviceItemSet]) {
                contractIds.add(service.BillingContract__c);
            }
        }
        //AT-3147  Block Ends
        return contractIds;
    }  
}