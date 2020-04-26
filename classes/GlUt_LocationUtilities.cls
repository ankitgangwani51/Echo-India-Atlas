/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		29 Nov 2017
@description 	Class for Location utilities
*******************************************************************************/
public with sharing class GlUt_LocationUtilities {
    
	private static final String CLASS_NAME = 'GlUt_LocationUtilities';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final String CONTRACTSTATUS_ACTIVE = 'Active';
    private static final String VOID_LOC = 'YES';
    
	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		29 Nov 2017
	@param			Id - location Id
	@return			Boolean - true if the location has measured supply points
	@description	Checks the location to see if it has measured supply points
	*******************************************************************************/
	public static Boolean hasMeasuredSupplyPoints(Id locationId) {

		// check the supply points at the location for a measured device
		for (SupplyPointDevice__c supplyPointDevice : [select Id 
														from SupplyPointDevice__c
														where RemovalDate__c = null 
															and SupplyPoint__r.Location__c = :locationId]) {

			return true;
		}
		return false;
	}    

	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		11 Dec 2017
	@param			List<AvailableService__c> - list of available services
	@return			Boolean - true if any of the available services are at measured supply points
	@description	Checks the available services to see if any have measured supply points
	*******************************************************************************/
	public static Boolean hasMeasuredSupplyPoints(List<AvailableService__c> availableServices) {
		
		// build a list of the supply point Ids
		List<Id> supplyPointIds = new List<Id>();
		for (AvailableService__c availableService : availableServices) {
			if (availableService.SupplyPoint__c != null) {
				supplyPointIds.add(availableService.SupplyPoint__c);
			}
		}

		// check for a current supply point device at the supply points
		for (SupplyPointDevice__c supplyPointDevice : [select Id 
														from SupplyPointDevice__c
														where RemovalDate__c = null 
															and SupplyPoint__c in :supplyPointIds]) {

			return true;
		}
		return false;
	}    

	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		04 Dec 2017
	@param			Location__c - location Id
	@param			Boolean - true if it's a household account
	@param			Date - the date on which the location is void
	@return			Boolean - true if the location was updated
	@description	Sets the location as void
	*******************************************************************************/
    /*
	public static Boolean setLocationVoid(Location__c location, Boolean isHHAccount, Date voidDate) {

		if (location != null) {

			// void the location
			location.VoidEndDate__c = null;
			location.VoidStartDate__c = voidDate;
				
			// for NHH Accounts also clear the number of occupants at the location
			if (!isHHAccount) location.NumberOfOccupiers__c = 0;
				
			// update location
			location = (Location__c) GlUt_FieldSecurity.cleanseFields(location, false);
			update location;
			return true;

		} else {
			return false;
		}
	}   
    */
    /* Checkmarx: Bulkify - Sudhir */
     public static Boolean setLocationVoid(list<Location__c> listLocation, Boolean isHHAccount, Date voidDate) {

		if (listLocation != null && !listLocation.isEmpty()) {

			// void the location
			listLocation[0].VoidEndDate__c = null;
			listLocation[0].VoidStartDate__c = voidDate;
				
			// for NHH Accounts also clear the number of occupants at the location
			if (!isHHAccount) listLocation[0].NumberOfOccupiers__c = 0;
				
			// update location
			listLocation = (list<Location__c>) GlUt_FieldSecurity.cleanseFields(listLocation, false);
			update listLocation;
			return true;

		} else {
			return false;
		}
	}

	

	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		04 Dec 2017
	@param			Location__c - location Id
	@param			Date - the date on which the location is occupied
	@return			Boolean - true if the location was updated
	@description	Sets the location as occupied
	*******************************************************************************/
	public static Boolean setLocationOccupied(Location__c location, Date moveInDate) {

		if (location != null) {

			// clear void location
			location.VoidEndDate__c = moveInDate;
		    location.VoidStartDate__c = null;   //AT-2276
				
			// update location
			location = (Location__c) GlUt_FieldSecurity.cleanseFields(location, false);  
			update location;
			return true;

		} else {
			return false;
		}
	} 
    
    /******************************************************************************
	@author    		Echo: Neha
	@date      		27/02/2018
	@param			Location__c - location Id
	@return			String - 'YES' if the location is void
	@description	Sets the location as occupied
	*******************************************************************************/
    public static String getVoidContractStatus(Id recordId) {
        
        List<BillingContract__c> voidContractList = [SELECT Id, Void__c 
                                              FROM BillingContract__c
                                              WHERE Void__c = true
                                              AND Status__c = :CONTRACTSTATUS_ACTIVE
                                              AND Id IN (SELECT BillingContract__c
                                                         FROM Service__c
                                                         WHERE SupplyPoint__r.Location__c  = :recordId)];
        
        if(voidContractList.size() >= 1) {
            return VOID_LOC;
        }
        return null;
    }
    
    
}