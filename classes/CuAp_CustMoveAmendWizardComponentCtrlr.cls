/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		12 Sept 2018
@description 	Component controller for cust move amend wizard
*******************************************************************************/
public with sharing class CuAp_CustMoveAmendWizardComponentCtrlr {
	
	private static final String CLASS_NAME = 'CuAp_CustMoveAmendWizardComponentCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	private static WizardObject wizObject;
	
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           12 Sept 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
	/*
	Screen	wizardprop element name			type
	==============================================================================
	Base
			recordId						Id (the Id of the host page record) - should be the same as accountId but use accountId
			accountId						Id (the Id of the person moving in's account)
	
	WS1		Select Location Occupant
			selectedLocOcc					LocationOccupant__c
											Id
											StartDate__c
											EndDate__c

			locationId						Location__c Id
			locationName					Location__c Name
			locationAddress					Location__c Address__c

			accountName						Account Name
			deleteRecord					String - 'true' or 'false'

	WS2		Amend Either Move In Or Move Out Date
			moveInDate						Date
			moveOutDate						Date

	WS3		Enter Readings
			newReadingsLists				List<Reading__c>

	WS4		Enter Billing Address
			newBillingAddress				BillingContract__c


	
	
	*/		
	public class WizardObject {
		
		@TestVisible private Id recordId;		// DEPRECATED - do not use
		@TestVisible private Id accountId;
        @TestVisible private Id contractId;
        @TestVisible private LocationOccupant__c selectedLocOcc;
        @TestVisible private Id locationId;		// DEPRECATED - use location
        @TestVisible private String locationName;		
        @TestVisible private String locationAddress;		
        @TestVisible private Location__c location;
        @TestVisible private String accountName;
        @TestVisible private String deleteRecord;
        @TestVisible private Date moveInDate;
        @TestVisible private Date moveOutDate;
        @TestVisible private List<Reading__c> newReadingsLists;
        @TestVisible private BillingContract__c newBillingAddress;
        @TestVisible private Boolean prevOcc;
        @TestVisible private Boolean subsequentOcc;      
	}
    
	/******************************************************************************
	@author         Echo: Tarun Gupta
    @date           12 Sept 2018
	@param			String - wizardprop
	@description	Updates the wizard properties
	*******************************************************************************/
	public static void updateWizardProperties(String wizardprop) {
		
		// strip out all the SObject type references from the json
		wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
		
		// and deserialise it
		wizObject = (WizardObject)System.JSON.deserialize(wizardprop, WizardObject.class);
		

	}

	/******************************************************************************
	@author         Echo: Tarun Gupta
    @date           12 Sept 2018
	@param			Id - account Id
	@return			Map<String, Boolean> - map of statuses keyed on the status name
	@description	Method called by the Component to determine any status required for navigation
	*******************************************************************************/
	@AuraEnabled
	public static Map<String, Boolean> wizardStatus(String wizardprop) {
		
		// build the wizard object from the wizard properties
		UpdateWizardProperties(wizardprop);
		
        Map<String, Boolean> status = new Map<String, Boolean>();
        
        try {
            GlUt_Logger.logDebug(DEBUG);
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        System.debug(DEBUG + 'status: ' + status);
        return status;
	}
    
	/******************************************************************************
	@author         Echo: Tarun Gupta
    @date           12 Sept 2018
	@param			String - json string of object wizardprop
	*******************************************************************************/
	@AuraEnabled
    public static List<Id> moveIn(String wizardprop) {
        list<BillEvent__c> listMoveInOutBillEvent = new list<BillEvent__c>() ;
        Set<Id> setContractIds = new Set<Id>();
        List<Id> listContractIds = new List<Id>();
        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            updateWizardProperties(wizardprop);
            
            setContractIds = GlUt_CustMoveAmendUtility.preRequisite(wizObject.accountId,
                                                                    wizObject.selectedLocOcc.Id, 
                                                                    wizObject.locationId, 
                                                                    wizObject.newReadingsLists,
                                                                    wizObject.deleteRecord, 
                                                                    wizObject.moveInDate,
                                                                    wizObject.moveOutDate,
                                                                    wizObject.newBillingAddress);
            
            for(Id objId : setContractIds){
                listContractIds.add(objId);
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
            
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return listContractIds;
		
	}
    
}