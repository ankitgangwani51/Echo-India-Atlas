/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		01 Dec 2017
@description 	Class for ServiceItem utilities
*******************************************************************************/
public with sharing class GlUt_ServiceItemUtilities {
    
	private static final String CLASS_NAME = 'GlUt_ServiceItemUtilities';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		01 Dec 2017
	@param			Id - location Id
	@param			Date - the end date for the service items
	@param			Boolean - true for a household account
	@description 	Ends all the active service items at a location 
					If all service items on a contract are ended it will also end the contract
	*******************************************************************************/
	public static void EndSupplyAtLocation(Id locationId, Date endDate) {
    
		// end date all the service items on the contract
		List<ServiceItem__c> serviceItemsToEndDate = new List<ServiceItem__c>();
        for (ServiceItem__c serviceItem : [SELECT Id, StartDate__c, EndDate__c FROM ServiceItem__c WHERE Service__r.Supplypoint__r.Location__c = :locationId AND EndDate__c = null]) {
            
            // AT-2271, When Service Item start date is greater than move-out date then service item end date will be same as the service item start date
            if(serviceItem.StartDate__c > endDate){
                serviceItem.EndDate__c = serviceItem.StartDate__c;
            }else{
                serviceItem.EndDate__c = endDate;
            }

            serviceItemsToEndDate.add(serviceItem);
        }
        
		// update the service items
		serviceItemsToEndDate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToEndDate, false);
		if (!serviceItemsToEndDate.isEmpty()) update serviceItemsToEndDate;
	}
}