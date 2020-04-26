/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		10 Nov 2017
@description 	Component controller for move out wizard
*******************************************************************************/
public with sharing class CuAp_MoveOutWizardComponentCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_MoveOutWizardComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static WizardObject wizObject;
    
    private static List<String> SPFieldsList;    
    static {
        SPFieldsList = new List<String>();         
        SPFieldsList.add(GlUt_APIConstantsSupplyPoint.ID);                  
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           10 Nov 2017
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
    @author    		Accenture: Patrick Dixon
    @date      		30 Nov 2017
    @param			String - wizardprop
    @description	Updates the wizard properties
    *******************************************************************************/
    public static void UpdateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        system.debug(DEBUG + 'wizardprop: ' + wizardprop);
        
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserialize(wizardprop, WizardObject.class);
        system.debug(DEBUG + 'wizObject: ' + wizObject);
    }
    
    /******************************************************************************
    @author    		Accenture: Patrick Dixon
    @date      		23 Nov 2017
    @param			String - wizardprop
    @return			Map<String, Boolean> - map of statuses keyed on the status name
    @description	Method called by the Component to determine any status required for navigation
    *******************************************************************************/
    @AuraEnabled
    public static Map<String, Boolean> WizardStatus(String wizardprop) {
        Map<String, Boolean> status = new Map<String, Boolean>();
        try {
            GlUt_Logger.logDebug(DEBUG);
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
        
        System.debug(DEBUG + 'status: ' + status);
        return status;
    }
    
    /******************************************************************************
    @author    		Echo: Vivek Sethi   AT-2480
    @date      		31 May 2018
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
        System.debug('****contractIdSet'+contractIdSet);
        if (!contractIdSet.isEmpty())
            return contractIdSet;        
        return null;        
    }
    
    /******************************************************************************
    @author    		Accenture: Patrick Dixon
    @date      		10 Sep 2017
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
    @revision		Echo: Sudhir Kumar
    AT-2480: Update Customer Moves Wizard - BillEvent record creation
    *******************************************************************************/
    @AuraEnabled
    public static Id MoveOut(String wizardprop) {
        system.debug('199******************wizardprop ' + wizardprop);
        Savepoint sp = Database.setSavepoint();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
            
            Boolean isHHAccount = GlUt_AccountUtilities.isHHAccount(wizObject.accountId);		// true if account = Non-Household account
            
            // set the location as void
            //GlUt_LocationUtilities.setLocationVoid(wizObject.location, isHHAccount, wizObject.moveOutDate + 1);
            GlUt_LocationUtilities.setLocationVoid(new list<Location__c> {wizObject.location}, isHHAccount, wizObject.moveOutDate + 1); // Checkmarx Review - Sudhir
            list<BillEvent__c> listMoveOutBillEvent = new list<BillEvent__c>() ;	// AT-2480	
            // insert move out readings (require move out reading Ids to link to void contract services later)
            if (wizObject.moveOutReadings != null) {
                wizObject.moveOutReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(wizObject.moveOutReadings, false);
                insert wizObject.moveOutReadings;
            }
            
            // move the moving out occupants out
            if (!isHHAccount) {
                
                // for a NHH Account
                LocationOccupant__c primaryLocationOccupant;
                // get the primary location occupant
                for (LocationOccupant__c locationOccupant : [select Id, 
                                                             EndDate__c  
                                                             from LocationOccupant__c
                                                             where Account__c = :wizObject.accountId
                                                             and Location__c = :wizObject.location.Id]) {
                                                                 
                                                                 primaryLocationOccupant = locationOccupant;
                                                             }
                
                
                // move the primary occupant out
                primaryLocationOccupant.EndDate__c = wizObject.moveOutDate;
                
                primaryLocationOccupant = (LocationOccupant__c) GlUt_FieldSecurity.cleanseFields(primaryLocationOccupant, false);
                update primaryLocationOccupant;
                
                Set<Id> locationOccupantContractIdSet  = getLocationOccupantContractId(primaryLocationOccupant.Id);  // AT-2480	
                createMoveOutBillEvent(listMoveOutBillEvent, locationOccupantContractIdSet) ;	// AT-2480	
            } else {
                // otherwise move the selected location occupants out
                if (wizObject.locationOccupantsToMoveOut != null) {
                    wizObject.locationOccupantsToMoveOut = (List<LocationOccupant__c>) GlUt_FieldSecurity.cleanseFields(wizObject.locationOccupantsToMoveOut, false);
                    update wizObject.locationOccupantsToMoveOut;
                    Set<Id> locationOccupantContractIdSet  = getLocationOccupantContractId(wizObject.locationOccupantsToMoveOut[0].Id);  // AT-2480	
                    createMoveOutBillEvent(listMoveOutBillEvent ,locationOccupantContractIdSet) ;	// AT-2480	
                }
            }
            if(!listMoveOutBillEvent.isEmpty()) {	// AT-2480	
                Database.insert(listMoveOutBillEvent) ;
            }
            
            // end date all the open service items at the location
            // (which ends the contract if there are no remaining open service items at other locations)
            GlUt_ServiceItemUtilities.EndSupplyAtLocation(wizobject.location.Id, wizObject.moveOutDate);
            
            // update the billing addreses using the forwarding address
            if (wizObject.newBillingAddress != null) {
                
                // contract billing address
                wizObject.newBillingAddress = (BillingContract__c) GlUt_FieldSecurity.cleanseFields(wizObject.newBillingAddress, false);
                update wizObject.newBillingAddress;
                
                // account billing address
                for (Account account : [select Id, 
                                        BillingStreet, 
                                        BillingCity, 
                                        BillingState, 
                                        BillingPostalCode, 
                                        BillingCountry 
                                        from Account
                                        where Id = :wizObject.accountId]) {
                                            // MT 13-08-2018 Start of AT - 2195
                                            if(wizObject.newBillingAddress.BillingStreet__c != null && wizObject.newBillingAddress.BillingPostalCode__c != null){
                                                account.BillingStreet = wizObject.newBillingAddress.BillingStreet__c; 
                                                account.BillingCity = wizObject.newBillingAddress.BillingCity__c;
                                                account.BillingState = wizObject.newBillingAddress.BillingState__c;
                                                account.BillingPostalCode = wizObject.newBillingAddress.BillingPostalCode__c;
                                                account.BillingCountry = wizObject.newBillingAddress.BillingCountry__c;
                                                
                                                account = (Account) GlUt_FieldSecurity.cleanseFields(account, false);
                                                update account;
                                            }
                                            // End of AT - 2195
                                        }
            }
            
            // create a void contract using default services and service items
            Id voidId = GlUt_ContractUtilities.createVoidContract(wizObject.location.Id, wizObject.moveOutDate.addDays(1), wizObject.moveOutReadings, null); 
            
            // suppress the void contract
            GlUt_SuppressionUtilities.suppressVoidContract(voidId, wizObject.moveOutDate.addDays(1));
            
            // create a void management process
            GlUt_VoidManagementProcessUtilities.createVoidManagementProcess(wizObject.location.Id, 
                                                                            wizObject.moveOutDate.addDays(1), 
                                                                            GlUt_AccountUtilities.isHHAccount(wizObject.accountId));
            
            // AT-3158(core7b) start... To send email to user 
            if(wizObject.emailSend != null && wizObject.emailSend == true){  
                // SupplyPoint Record...to check Locations is measured or unmeasured
                List<SupplyPoint__c> measuredsupplyPointList = new List<SupplyPoint__c>(); 
                String queryFilter = ' WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = \'' + wizObject.location.Id + '\'' +
                    ' AND ' + GlUt_APIConstantsSupplyPoint.MEASUREDAPINAME + ' = true ';  // AT-3174 
                measuredsupplyPointList = (List<SupplyPoint__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                    SPFieldsList,                   
                                                                                                    queryFilter);                
                
                String templateName;
                if(measuredsupplyPointList.size() > 0)   // Measured Location
                    templateName = Label.CuAp_MeasuredLocOccupationFormTemplate;
                else
                    templateName = Label.CuAp_UnmeasuredLocOccupationFormTemplate;              
                
                //Id userId = CuAp_MoveOutWizardComponentCtrlr.getContactByCustomSetting();                
                Id userId = GlUt_AccountUtilities.getContactByCustomSetting(); 
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
            // AT-3158 to send email to user end
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return wizObject.newBillingAddress.Id;
    }
    
    /******************************************************************************
    @author    		Echo: Vivek Sethi   AT-2480
    @date      		31 May 2018
    @param			LocationOccupant Set<Id> contractId
    @return			null
    @description	Method to create Bill Event
    *******************************************************************************/
        
    private static void createMoveOutBillEvent(list<BillEvent__c> listMoveOutBillEvent , Set<Id> contractId) {	// AT-2480	
        System.debug('createMoveOutBillEvent inside the method');
        System.debug('listMoveOutBillEvent = '+listMoveOutBillEvent + '\n' + 'contractId = '+contractId);
        
        if(contractId != null)
        {
            for(Id ContractObjId : contractId )
            {
                BillEvent__c moveOutBillEvent = new BillEvent__c(EventType__c = CuAp_Constants.MOVEOUT, 
                                                                 Status__c = CuAp_Constants.PENDINGBILLEVENTSTATUS,
                                                                 BillingContract__c = ContractObjId) ; 	
                listMoveOutBillEvent.add(moveOutBillEvent) ;
            }
            
        }
    }
    
    /******************************************************************************
    @author         Echo: Neha R.
    @date           26 July 2018
    @param           
    @return         Id 
    @description    Method is used to Get the contact id based on email address which we are getting from custom setting.
    // AT-3158 core7b
    *******************************************************************************/
        /* private static Id getContactByCustomSetting(){
    string printLetterEmailAddress = '';
    List<Contact> contactList = new List<Contact>();
    // Need to pass profile id or user id. 
    ConfigureTemplate__c templateSetting = ConfigureTemplate__c.getOrgDefaults();
    if(templateSetting.PrintedLetterEmailAddress__c != null){
    printLetterEmailAddress = templateSetting.PrintedLetterEmailAddress__c;
    }
    if(string.isNotBlank(printLetterEmailAddress)){
    contactList = [SELECT Id, Email FROM Contact WHERE Email =:printLetterEmailAddress];
    }         
    System.debug(DEBUG + 'contactList: ' + contactList);
    if(!contactList.isEmpty() && contactList[0] != null){
    return contactList[0].Id;
    }else{
    return null;
    }
    }*/
    
}