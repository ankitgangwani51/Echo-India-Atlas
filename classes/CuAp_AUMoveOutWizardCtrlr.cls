/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		30 Oct 2018
@description 	Component controller for AU move out wizard
@Revisions		AT-4858, Modified to add DPID fields
@Revisions		AT-5387
*******************************************************************************/
public with sharing class CuAp_AUMoveOutWizardCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_AUMoveOutWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static WizardObject wizObject;
    
    private static List<String> SPFieldsList;    
    static {
        SPFieldsList = new List<String>();         
        SPFieldsList.add(GlUt_APIConstantsSupplyPoint.ID);                  
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
	@date      		30 Oct 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
        /*
    Screen	wizardprop element name			type
    ==============================================================================
    Base
    recordId						Id (the Id of the host page record) - should be the same as accountId but use contractId
    accountId						Id (the Id of the account being ended)
    
    WS11
    location						Location__c
    Id
    NumberOfOccupiers__c
    moveOutDate						String/Date (format YYYY-MM-DD)
    
    WS14 (HH Account only)
    locationOccupantsToMoveOut:		List<LocationOccupant__c>
    Id
    EndDate__c - move out date
    
    WS12 (metered Supply Points only)
    moveOutReadings:				List<Reading__c>
    Device__c = device Id
    ActualDeviceReading__c = from screen
    ReadingDate__c = move out date
    ReadingMethod__c = 'System Estimated'/'Actual'
    ReadingSource__c = 'Customer Reading'/'Company Reading'/'Agent Entered'
    ReadingType__c = 'Move Out'
    
    WS13
    newBillingAddress:				Contract__c
    Id
    BillingStreet__c
    BillingCity__c
    BillingState__c
    BillingCountry__c
    BillingPostalCode__c
    WS14 (Eamil Send only)
    emailSend						Boolean (Value of checkbox to send email to Contract)  // AT-3157
    */		
    public class WizardObject {
        
        @TestVisible private Id recordId;		// DEPRECATED - do not use
        @TestVisible private Id accountId;
        @TestVisible private Location__c location;
        @TestVisible private Id locationId;		// DEPRECATED - use location
        @TestVisible private Date moveOutDate;
        @TestVisible private List<LocationOccupant__c> locationOccupantsToMoveOut;
        @TestVisible private List<Reading__c> moveOutReadings;
        @TestVisible private BillingContract__c newBillingAddress;
        @TestVisible private Boolean emailSend;     					// AT-3158	Core7b
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
	@date      		30 Oct 2018
    @param			String - wizardprop
    @description	Updates the wizard properties
    *******************************************************************************/
    public static void UpdateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserialize(wizardprop, WizardObject.class);
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
	@date      		30 Oct 2018
    @param			String - wizardprop
    @return			Map<String, Boolean> - map of statuses keyed on the status name
    @description	Method called by the Component to determine any status required for navigation
    *******************************************************************************/
    @AuraEnabled
    public static Map<String, Boolean> WizardStatus(String wizardprop) {
        Map<String, Boolean> status = new Map<String, Boolean>();
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
            
            
            status.put(CuAp_Constants.IS_HH_ACCOUNT, GlUt_AccountUtilities.isHHAccount(wizObject.accountId));		// true if account = Household account
            
            if (wizObject.location == null) {
                status.put(CuAp_Constants.HAS_MEASURED_SUPPLY_POINT, true);
                
            } else {
                status.put(CuAp_Constants.HAS_MEASURED_SUPPLY_POINT, GlUt_LocationUtilities.hasMeasuredSupplyPoints(wizObject.location.Id));		// true if the location has a measured supply point
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return status;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
	@date      		30 Oct 2018
    @param			LocationOccupant__c
    @return			Set<Id>
    @description	returns location occupant active contract Id
	@revision 		(AT-3820 -- Fix the CreateBillEvent logic to create the Bill Event for moveout contract)
					Ankit Gangwani, 27 Sept 2018
					Method has been modified to get the contract Id with the flow of 
					LocationOccupant__c (Id as incoming parameter ) --> Location__c --> SupplyPoint__c --> Service__c --> BillingContract__c
					Location Occupant must be lie between the services we found with the help of locationoccupant Id
					If service found then return the contractId
    *******************************************************************************/
    public static Set<Id> getLocationOccupantContractId(Id locationOccupantIdSet) {
        List<BillingContract__c> contractList  = new List<BillingContract__c>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> supplyPointIdSet = new Set<Id>();
        List<SupplyPoint__c> supplyPointLists = new List<SupplyPoint__c>();
        List<Service__c> serviceLists = new List<Service__c>();
        
        
        if (locationOccupantIdSet != null)
        {
            List<LocationOccupant__c> locationOccList = [SELECT Id,                                                         
                                                         Location__c, 
                                                         StartDate__c,
                                                         EndDate__c                                                          
                                                         FROM LocationOccupant__c 
                                                         WHERE Id =: locationOccupantIdSet];
            if(!locationOccList.isEmpty()){
                
                // get all the supply points based on location 
                supplyPointLists = [SELECT Id,
                                    Location__c
                                    FROM SupplyPoint__c
                                    WHERE Location__c = :locationOccList[0].Location__c];
                
                if(supplyPointLists != null && !supplyPointLists.isEmpty()){
                    for(SupplyPoint__c objSP : supplyPointLists){
                        supplyPointIdSet.add(objSP.Id);
                    }
                }

                if(supplyPointIdSet != null && supplyPointIdSet.size() > 0){
                    
                    // get all the services based on supply point
                    serviceLists = [SELECT Id,
                                    ServiceStartDate__c,
                                    ServiceEndDate__c,
                                    SupplyPoint__c,
                                    BillingContract__c
                                    FROM Service__c
                                    WHERE SupplyPoint__c =:supplyPointIdSet];
                    
                    // Return the contract Id for those service which is lie between the location occupant (Start Date and End Date)
                    if(serviceLists != null && !serviceLists.isEmpty()){
                        for(Service__c objService : serviceLists){
                            if(objService.ServiceStartDate__c >= locationOccList[0].StartDate__c && (objService.ServiceEndDate__c == null || (objService.ServiceEndDate__c != null && objService.ServiceEndDate__c <= locationOccList[0].EndDate__c))){
                                contractIdSet.add(objService.BillingContract__c);
                                break;                                   
                            }
                        }
                    }                    
                }
            }
        }
        if (!contractIdSet.isEmpty())
            return contractIdSet;        
        return null;        
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
	@date      		30 Oct 2018
    @param			String - json string of object wizardprop
    @param			Id - Id of the contract covering the moved out location
    @description 	Method called by wizard to complete the move out process
    
    Steps are:
    move out of location (location void)
    commit move out readings
    move out the current occupants
    end date all the current service items at the location
    update the contract billing addresses if required
    open a void contract using the default services items/services (linking the move in reading to the service)
    create a void management process
    *******************************************************************************/
    @AuraEnabled
    public static Id MoveOut(String wizardprop) {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<Id> setServiceIds = new Set<Id>();
            
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);            
            system.debug('wizObject***'+ wizObject);
            //end Occupancy of Tenant(s) 
            endTenantOccupancy();
            //Update the Landlord to Owner 
            updateOwnerOccupancy();
            
            //End Service Items not related to the Owner
            setServiceIds = GlUt_AUServiceItemUtilities.endServiceItemNotRelatedToOwner(wizobject.location.Id, wizObject.moveOutDate);
            system.debug('setServiceIds***'+ setServiceIds); 
            //Add any Service Items related to the Owner 
            if(setServiceIds.size() > 0){
                Id serviceId = new list<Id>(setServiceIds)[0];
                GlUt_AUServiceItemUtilities.addServiceItemRelatedToOwner(wizobject.location.Id, wizObject.moveOutDate, serviceId);
            }
            //Add the Move Out Reading(s)
            insertMoveOutReadings(); 
            //Update the Move Out Billing Address
            updateMoveOutBillingAddress();
            //Create Move Out Billing Event 
            if(wizObject.locationOccupantsToMoveOut != null){
                Set<Id> locationOccupantContractIdSet  = getLocationOccupantContractId(wizObject.locationOccupantsToMoveOut[0].Id);  // AT-2480	
                createMoveOutBillEvent(locationOccupantContractIdSet);
            }
            //Send Welcome Letter 
            sendWelcomeLetter();
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return wizObject.newBillingAddress.Id;
    }
    
    /**********************************************************************************************
	@author        Echo: Tarun Gupta
	@date          29-Oct-2018
	@param         null
	@return        void
	@description   This method is to end tenant occupancy
	**********************************************************************************************/
    public Static void endTenantOccupancy() {
        
        if (wizObject.locationOccupantsToMoveOut != null) {
            wizObject.locationOccupantsToMoveOut = (List<LocationOccupant__c>) (GlUt_FieldSecurity.cleanseFields(wizObject.locationOccupantsToMoveOut, false));
            update wizObject.locationOccupantsToMoveOut;
        }
    }
    
    /**********************************************************************************************
	@author        Echo: Tarun Gupta
	@date          29-Oct-2018
	@param         void
	@return        null
	@description   This method is to update owner occupancy
	**********************************************************************************************/
    public Static void updateOwnerOccupancy() {
        
        List<LocationOccupant__c> listOwnerLocOcc = new List<LocationOccupant__c>();
        
        if(wizObject.locationOccupantsToMoveOut != null && wizObject.locationOccupantsToMoveOut[0] != null){
            
            listOwnerLocOcc = [select Id,Name,OccupancyType__c 
                               FROM LocationOccupant__c 
                               WHERE Location__c =:wizObject.location.ID  
                               /*AND StartDate__c <: wizObject.locationOccupantsToMoveOut[0].StartDate__c
                               AND (EndDate__c >=: wizObject.locationOccupantsToMoveOut[0].StartDate__c OR EndDate__c = null) */
                               AND EndDate__c = null
                               AND OccupancyType__c =: Label.CuAp_AUMoveInOccTypeLandlord];  
            
            system.debug('listOwnerLocOcc***'+ listOwnerLocOcc);
            
            if(!listOwnerLocOcc.isEmpty()){
                for(LocationOccupant__c objOwnerLocOcc : listOwnerLocOcc){
                    objOwnerLocOcc.OccupancyType__c = Label.CuAp_AUMoveInOccTypeOwner;
                }
                update listOwnerLocOcc;
            }
        }
    }
    
    /**********************************************************************************************
	@author        Echo: Tarun Gupta
	@date          29-Oct-2018
	@param         null
	@return        true / false
	@description   This method is to insert move out readings
	**********************************************************************************************/
    public Static void insertMoveOutReadings() {
        List<Reading__c> listMoveOutReadings = new List<Reading__c>();
        if (wizObject.moveOutReadings != null) {
            for(Reading__c objReadings :wizObject.moveOutReadings){
                if(objReadings.ReadingType__c != Label.CuAp_ReadingReadingTypeVoidStart){
                    listMoveOutReadings.add(objReadings);
                }
            }
            if(!listMoveOutReadings.isEmpty()){
                listMoveOutReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listMoveOutReadings, false);
                insert listMoveOutReadings;
            }
        }
    }
    /**********************************************************************************************
	@author        Echo: Tarun Gupta
	@date          29-Oct-2018
	@param         null
	@return        void
	@description   This method is to update Move Out Billing Address
	**********************************************************************************************/
    public Static void updateMoveOutBillingAddress() {
        
        // update the billing addreses using the forwarding address
        if (wizObject.newBillingAddress != null) {
            
            // contract billing address
            wizObject.newBillingAddress = (BillingContract__c) GlUt_FieldSecurity.cleanseFields(wizObject.newBillingAddress, false);
            update wizObject.newBillingAddress;
            
            // account billing address
            for (Account account : [select Id, 
                                    AuDpid__c,
                                    BillingStreet, 
                                    BillingCity, 
                                    BillingState, 
                                    BillingPostalCode, 
                                    BillingCountry 
                                    from Account
                                    where Id = :wizObject.accountId]) {
                                        // MT 13-08-2018 Start of AT - 2195		
                                        account.BillingStreet = wizObject.newBillingAddress.BillingStreet__c; 
                                        account.BillingCity = wizObject.newBillingAddress.BillingCity__c;
                                        account.BillingState = wizObject.newBillingAddress.BillingState__c;
                                        account.BillingPostalCode = wizObject.newBillingAddress.BillingPostalCode__c;
                                        account.BillingCountry = wizObject.newBillingAddress.BillingCountry__c;
                                        account.AuDpid__c = wizObject.newBillingAddress.AlternativeAuDpid__c;
                                        // End of AT - 2195
                                        account = (Account) GlUt_FieldSecurity.cleanseFields(account, false);
                                        update account;
                                    }
        }
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
	@date      		30 Oct 2018
    @param			LocationOccupant Set<Id> contractId
    @return			null
    @description	Method to create Bill Event
    *******************************************************************************/
    private static void createMoveOutBillEvent(Set<Id> setContractId) {
        list<BillEvent__c> listMoveOutBillEvent = new list<BillEvent__c>();	
        
        if(setContractId != null && setContractId.size() > 0)
        {
            for(Id ContractObjId : setContractId )
            {
                BillEvent__c moveOutBillEvent = new BillEvent__c(EventType__c = CuAp_Constants.MOVEOUT, 
                                                                 Status__c = CuAp_Constants.PENDINGBILLEVENTSTATUS,
                                                                 BillingContract__c = ContractObjId) ; 	
                listMoveOutBillEvent.add(moveOutBillEvent) ;
            }
            if(!listMoveOutBillEvent.isEmpty()) {
                Database.insert(listMoveOutBillEvent) ;
            }
        }
    }
    
    /**********************************************************************************************
	@author        Echo: Tarun Gupta
	@date          25-Oct-2018
	@param         null
	@return        void
	@description   This method is to send welcome letter
	**********************************************************************************************/
    public Static void sendWelcomeLetter() {
        
        if(wizObject.emailSend != null && wizObject.emailSend == true){  
            String templateName;
            Id userId = GlUt_AccountUtilities.getContactByCustomSetting();  
			templateName = Label.CuAp_AUMoveInTenantLetter;            
            if(userId != null){
                GlUt_SendEmail emailUtil = new GlUt_SendEmail();
                emailUtil.targetObjectId(userId);
                emailUtil.TemplateName(templateName);
                emailUtil.SaveAsActivity(true);
                emailUtil.WhatId(wizObject.accountId);
                emailUtil.senderDisplayName(Label.CuAp_SenderDisplayName);      
                emailUtil.sendEmail();
            }
        }
    }
}