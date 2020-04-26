/******************************************************************************
@author         Echo: Mohit Tayal
@date           05 July 2018
@description    Contract Finder class for SI Agreed Volume
@revision(s)        
*******************************************************************************/
public with sharing class GlUt_SIAgreedVolumeContractFinder extends GlUt_ContractFinder{

    private static final String CLASS_NAME = 'GlUt_SIAgreedVolumeContractFinder';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           05 July 2018
    @param          Id - recordId
    @return         Set<Id> - the set of related SI Agreed Volume Ids
    @description    finds the set of contract Ids affected by an amendment
    *******************************************************************************/
    public override Set<Id> retrieveContractIds (Id siAgreedVolumeId) {

        Set<Id> contractIds = new Set<Id>();
        for (SIAgreedVolume__c objSIAgreedVolume : [SELECT Id,  
										                   ServiceItem__r.Service__r.BillingContract__c     
									                       FROM SIAgreedVolume__c 
									                       WHERE Id = :siAgreedVolumeId]) {
        	
        	contractIds.add(objSIAgreedVolume.ServiceItem__r.Service__r.BillingContract__c);
        }
        return contractIds;
    }  
}