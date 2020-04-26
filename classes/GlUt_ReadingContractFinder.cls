/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		21 Feb 2018
@description 	Contract Finder class for Reading
Revision(s)		
*******************************************************************************/
public with sharing class GlUt_ReadingContractFinder extends GlUt_ContractFinder {
	
	private static final String CLASS_NAME = 'GlUt_ReadingContractFinder';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		21 Feb 2018
	@param			Id - recordId
	@return			Set<Id> - the set of related contract Ids
	@description 	finds the set of contract Ids affected by an amendment
	*******************************************************************************/
	public override Set<Id> retrieveContractIds (Id readingId) {

		// get the reading date to define the scope of affected contracts
    	Date readingDate;
    	for (Reading__c reading : [select Id, 
    									ReadingDate__c 
    								from Reading__c 
    								where Id = :readingId]) {
    									
    		readingDate = reading.ReadingDate__c;
    	}
    	
    	// build a set of supply point Ids
    	Set<Id> supplyPointIds = new Set<Id>();
    	for (SupplyPointDevice__c supplyPointDevice : [select Id, 
    														Device__c, 
    														SupplyPoint__c 
    													from SupplyPointDevice__c 
    													where Device__c in (select Device__c 
																			from Reading__c 
																			where Id = :readingId)]) {
    																	
    		supplyPointIds.add(supplyPointDevice.SupplyPoint__c);					
		}

		// and use it to find the contracts
    	Set<Id> contractIds = new Set<Id>();
    	for (Service__c service : [select Id, 
    									BillingContract__c, 
    									SupplyPoint__c 
    								from Service__c 
    								where SupplyPoint__c in :supplyPointIds
    									and ServiceStartDate__c < :readingDate
    									and (ServiceEndDate__c >= :readingDate 
    										or ServiceEndDate__c = null)]) {
    																	
    		contractIds.add(service.BillingContract__c);					
		}
        
        // Start Core 7a....AT-2930         
        Set<Id> sprMainSPId = new Set<Id>();
        for(SupplyPointRelationship__c objSPR: [SELECT Id,
                                                	   MainSupply__c
                                                FROM SupplyPointRelationship__c
                                                WHERE SubSupply__c IN: supplyPointIds
                                               	  AND StartDate__c <= :readingDate
                                                  AND (EndDate__c > :readingDate
                                                       OR EndDate__c = null)]){            
        	sprMainSPId.add(objSPR.MainSupply__c);                                                     
        }
        
        if(sprMainSPId.size() > 0){ 
                
            Boolean validMainSP = false;
            for (Reading__c reading : [SELECT Id,ReadingDate__c,Device__c
                                       FROM Reading__c 
                                       WHERE Device__c IN (SELECT Device__c
                                                                    FROM SupplyPointDevice__c
                                                                    WHERE SupplyPoint__c IN: sprMainSPId
                                                                    AND Active__c = true)
                                       AND Billed__c = false
                                       AND BillableType__c =: GlUt_Constants.BILLABLE
                                       AND ReadingDate__c =: system.today() ]){ 
            	validMainSP = true;                
            }                                                  
            if (validMainSP == true){
                for (Service__c service : [SELECT Id,BillingContract__c,SupplyPoint__c 
                                           FROM Service__c 
                                           WHERE SupplyPoint__c in :sprMainSPId
                                           AND ServiceStartDate__c < :system.today()
                                           AND (ServiceEndDate__c >= :system.today()                                             
                                                OR ServiceEndDate__c = null)  ]) {                                                                                
                    contractIds.add(service.BillingContract__c);					
                }
            }
        }
        // end Core 7a....AT-2930         
		return contractIds;
    }  
}