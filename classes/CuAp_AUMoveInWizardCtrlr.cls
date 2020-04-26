/******************************************************************************
@author         Echo: Tarun Gupta
@date           24 Oct 2018
@description    Component controller for AU move in wizard
@Revisions      AT-3494, Modified to add SI start date 
@Revisions      AT-4858, Modified to add DPID fields
@Revisions      AT-5283,AT-5277
@Revisions      AT-5326
@Revisions      AT-5379
*******************************************************************************/
public with sharing class CuAp_AUMoveInWizardCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_AUMoveInWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static WizardObject wizObject;
    private static list<BillEvent__c> listMoveInOutBillEvent = new list<BillEvent__c>() ;
    private static Date lastBillItemEndDate;
    private static Id previousOccupantContractId;
    private static List<BlAp_CombinedRecord> listAvailService2StartDate = new List<BlAp_CombinedRecord>();
    private static Set<Id> setContractIdsUpdatedBasedOnSI = new Set<Id>();
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           24 Oct 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
    /*
    Screen  wizardprop element name         type
    ==============================================================================
    Base
            recordId                        Id (the Id of the host page record) - should be the same as accountId but use accountId
            accountId                       Id (the Id of the person moving in's account)
    
    WS1
            location                        Location__c
                                                Id
                                                NumberOfOccupiers__c
    
    WS2
            moveInDate                      String/Date (format YYYY-MM-DD)
            
            moveOutDate                     String/Date (format YYYY-MM-DD)

            locationOccupantToMoveIn:       LocationOccupant__c
                                                Account__c = accountId
                                                EndDate__c = null
                                                Location__c = locationId
                                                NumberofOccupiers__c = from screen
                                                OccupancyType__c = from screen
                                                Primary__c = true   
                                                ShowOnBill__c = true
                                                StartDate__c = move in date
    
            locationOccupantsToMoveOut:     List<LocationOccupant__c>
                                                Id
                                                EndDate__c - move out date
    
    WS3 (HH Account only)
            additionalLocationOccupants:    List<LocationOccupant__c>
                                                Account__c = from screen
                                                EndDate__c = null
                                                Location__c = locationId
                                                NumberofOccupiers__c = from screen
                                                OccupancyType__c = from screen
                                                Primary__c = false  
                                                ShowOnBill__c = true
                                                StartDate__c = move in date
    
    WS4
            selectedServices:               List<AvailableService__c>
                                                Id
                                                ServiceType__c
                                                SupplyPoint__c
    
    WS5
            availableBundles:               List<AvailableBundle__c>
                                                Id
                                                AvailableService__c
    
            selectedServiceItems:           List<AvailableServiceItem__c>
                                                Id
                                                AvailableBundle__c
                                                ServiceItemType__c
                                                
            selectedSundryItems:            List<ServiceItemType__c>
                                                Id
    
    WS6 (metered Supply Points only)
            moveInReadings:                 List<Reading__c>
                                                Device__c = device Id
                                                ActualDeviceReading__c = from screen
                                                ReadingDate__c = move in date
                                                ReadingMethod__c =  'Manual Estimated'/'Actual'
                                                ReadingSource__c = 'Customer Reading'/'Company Reading'/'Agent Entered'
                                                ReadingType__c = 'Move In'
    
            currentReadings:                List<Reading__c>
                                                Device__c = device Id
                                                ActualDeviceReading__c = from screen
                                                ReadingDate__c = today
                                                ReadingMethod__c =  'Manual Estimated'/'Actual'
                                                ReadingSource__c = 'Customer Reading'/'Company Reading'/'Agent Entered'
                                                ReadingType__c = 'Regular'
                                                
    WS7 (Account has Contract(s) only)
            contractId                      Id (the Id of an existing contract to use)
    WS8 (Eamil Send only)
            emailSend                       Boolean (Value of checkbox to send email to Contract)  // AT-3157
    */      
    public class WizardObject {
        
        @TestVisible private Id recordId;       
        @TestVisible private Id accountId;
        @TestVisible private Location__c location;
        @TestVisible private Id locationId;     
        @TestVisible private Date moveInDate;
        @TestVisible private Date moveOutDate;
        @TestVisible private LocationOccupant__c locationOccupantToMoveIn;
        @TestVisible private List<LocationOccupant__c> locationOccupantsToMoveOut;
        @TestVisible private List<LocationOccupant__c> additionalLocationOccupants;
        @TestVisible private List<AvailableService__c> selectedServices;
        @TestVisible private List<AvailableBundle__c> availableBundles;
        @TestVisible private List<AvailableServiceItem__c> selectedServiceItems;
        @TestVisible private List<ServiceItemType__c> selectedSundryItems;
        @TestVisible private List<Reading__c> moveInReadings;
        @TestVisible private Id contractId;
        @TestVisible private Boolean emailSend;
        @TestVisible private String selectedOccType;
        @TestVisible private Decimal creditAmountToTransfer;
        @TestVisible private Decimal creditAmountOnContract;
        @TestVisible private Decimal debtOnLocation;      
        @TestVisible private Id wizBillCalculationId;
        @TestVisible private String jsonString;
    }
    
    private static List<String> SPFieldsList;    
    static{
        SPFieldsList = new List<String>();         
        SPFieldsList.add(GlUt_APIConstantsSupplyPoint.ID);                  
    }    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           24 Oct 2018
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void updateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserialize(wizardprop, WizardObject.class);
        if(String.isNotBlank(wizObject.jsonString)){
            listAvailService2StartDate = (List<BlAp_CombinedRecord>) System.JSON.deserialize(wizObject.jsonString, List<BlAp_CombinedRecord>.class);  
        }
    }

    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           24 Oct 2018
    @param          Id - account Id
    @return         Map<String, Boolean> - map of statuses keyed on the status name
    @description    Method called by the Component to determine any status required for navigation
    *******************************************************************************/
    @AuraEnabled
    public static Map<String, Boolean> wizardStatus(String wizardprop) {
        
        // build the wizard object from the wizard properties
        UpdateWizardProperties(wizardprop);
        
        Map<String, Boolean> status = new Map<String, Boolean>();
        
        try {
            status.put(CuAp_Constants.IS_HH_ACCOUNT, GlUt_AccountUtilities.isHHAccount(wizObject.accountId));       // true if account = Household account
            status.put(CuAp_Constants.IS_STALE_ACCOUNT, GlUt_AccountUtilities.isStaleAccount(wizObject.accountId));     // true if account has no active location occupants
            status.put(CuAp_Constants.HAS_CONTRACT, GlUt_AccountUtilities.hasActiveContract(wizObject.accountId, wizObject.moveInDate));        // true if account has an active contract
            status.put(CuAp_Constants.HAS_MEASURED_SUPPLY_POINT, wizObject.selectedServices != null 
                       ? GlUt_LocationUtilities.hasMeasuredSupplyPoints(wizObject.selectedServices)
                       : false);        // true if there is a measured supply point
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return status;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           24 Oct 2018
    @param          LocationOccupant__c
    @return         Set<Id>
    @description    returns location occupant active contract Id
    *******************************************************************************/
    public static Set<Id> getLocationOccupantContractId() {
        Set<Id> locationOccupantIdSet = new Set<Id>();
        List<BillingContract__c> contractList  = new List<BillingContract__c>();
        Set<Id> contractIdSet = new Set<Id>();
        if(wizObject.locationOccupantsToMoveOut != null) {
            for(LocationOccupant__c locationoccupantObj  : wizObject.locationOccupantsToMoveOut) {
                locationOccupantIdSet.add(locationoccupantObj.Id);
            }
            if (!locationOccupantIdSet.isEmpty())
            {
                List<LocationOccupant__c> locationOccList = [SELECT 
                                                             location__c,
                                                             StartDate__c,
                                                             EndDate__c,
                                                             Id 
                                                             FROM LocationOccupant__c 
                                                             WHERE Id IN: locationOccupantIdSet limit 1];
                if(!locationOccList.isEmpty())
                {   
                    for(Service__c objService : [SELECT Id,BillingContract__c,ServiceStartDate__c,ServiceEndDate__c,SupplyPoint__r.Location__c FROM Service__c 
                                                 WHERE SupplyPoint__r.Location__c = :locationOccList[0].location__c
                                                 AND OccupancyType__c =: Label.CuAp_AUMoveInOccType]){
                                                     if(objService.ServiceStartDate__c >= locationOccList[0].StartDate__c && 
                                                        (objService.ServiceEndDate__c == null || (objService.ServiceEndDate__c != null && objService.ServiceEndDate__c <= wizObject.moveInDate))){
                                                            contractIdSet.add(objService.BillingContract__c);
                                                            break;                                   
                                                        }
                                                 }
                }                
            }
            if (!contractIdSet.isEmpty())
                return contractIdSet;
        }
        return null;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           24 Oct 2018
    @param          String - json string of object wizardprop
    @param          Id - Id of the contract covering the moved in location
    @description    Method called by wizard to complete the move in process
    
                    Steps are:
                    move in to location
                    commit move in and current readings
                    move in the new occupants
                    move out the previous occupants
                    end date all the current service items at the location
                    update the account addresses with the location address if blank
                    open a new contract if required
                    add the new service items/services to the contract (linking the move in reading to the service)
    *******************************************************************************/
    @AuraEnabled
    public static Map<String, String> moveIn(String wizardprop) {
        
        Map<String, String> mapObject2Id = new Map<String, String>();
        List<LocationOccupant__c> listTenantLocOcc = new List<LocationOccupant__c>();
        Set<Id> setContractIds = new Set<Id>();
        String strContractIds = '';
        
        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            updateWizardProperties(wizardprop);
            
            //AT-5575 start           
            Location__c objLocation = wizObject.location;            
            //update location
            objLocation = (Location__c) GlUt_FieldSecurity.cleanseFields(objLocation, false); 
            update objLocation;
            //AT-5575 end...
           
           // If the New Occupancy Type is Tenant
            if(wizObject.locationOccupantToMoveIn != null && wizObject.locationOccupantToMoveIn.OccupancyType__c == Label.CuAp_AUMoveInOccType){
                
                // Move the previous Tenant out if required & End previous Tenant Service Items
                listTenantLocOcc = updatePreviousOccupier(Label.CuAp_AUMoveInOccType);
                
                //Update the Owner to a Landlord & End owner Service Items               
                updateOwnerDetails();
                //Create new Billing Contract 
                createOrUpdateContract();
                //Create new Services & Create Tenant Service Items
                createNewServicesAndItems();
                //Create new Tenant Occupancy
                createNewOccupancyRecords();
                //Save the Move in Readings - not in case of owner
                saveMoveInReadingRecords();
                // Create Move in Billing Event
                createBillingEventRecords();
            }
            // If the New Occupancy Type is Owner
            else if(wizObject.locationOccupantToMoveIn != null && 
                    (wizObject.locationOccupantToMoveIn.OccupancyType__c == Label.CuAp_AUMoveInOccTypeOwner || wizObject.locationOccupantToMoveIn.OccupancyType__c == Label.CuAp_AUMoveInOccTypeLandlord)){
                       
                // Move the previous previous Landlord/Owner out & End previous Owner/Landlord Service Items
                listTenantLocOcc = updatePreviousOccupier(wizObject.locationOccupantToMoveIn.OccupancyType__c);
                //Create new Billing Contract 
                createOrUpdateContract();
                //Create new Services & Create Tenant Service Items
                createNewServicesAndItems();
                //Create new Location Occupant record 
                createNewOccupancyRecords();
                //Transfer Debt/Credit 
                transferDebtOrCredit();
                                      
                // AT-5598 Start....
                if (wizObject.locationOccupantToMoveIn.OccupancyType__c == Label.CuAp_AUMoveInOccTypeOwner && wizObject.selectedServices != null && !wizObject.selectedServices.isEmpty()){
                	List<Id> supplyPointIds = new List<Id>();  
                    
                    for (AvailableService__c objAvailableService : wizObject.selectedServices){
                        if(objAvailableService.SupplyPoint__c != null && !supplyPointIds.contains(objAvailableService.SupplyPoint__c))
                            supplyPointIds.add(objAvailableService.SupplyPoint__c);
                    }
                  
                    if (!supplyPointIds.isEmpty()){
                        List<SupplyPointDevice__c> activeSPDonSPlst = new List<SupplyPointDevice__c>(); 
                        activeSPDonSPlst = [SELECT SupplyPoint__c,Device__c
                                           FROM SupplyPointDevice__c 
                                           WHERE SupplyPoint__c IN: supplyPointIds AND Active__c = true];
                        
                        if (!activeSPDonSPlst.isEmpty()){
                            Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
                            for(SupplyPointDevice__c objSupplyPointDevice : activeSPDonSPlst){
                                deviceIdMap.put(objSupplyPointDevice.Device__c, NULL);                                
                            }
                            
                            if(!deviceIdMap.isEmpty())            
                                BlUt_ADUCalculation.calculateADU(deviceIdMap, wizObject.moveInDate);  
                        }   
                    }
                } 
                // AT-5598 End....
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
        //If Tenant && previous listTenantLocOcc is not blank
        if(wizObject.locationOccupantToMoveIn.OccupancyType__c == Label.CuAp_AUMoveInOccType && !listTenantLocOcc.isEmpty()){
            
            Set<Id> setAccountId = new Set<Id>();
            for(LocationOccupant__c objLocOcc :listTenantLocOcc){
                setAccountId.add(objLocOcc.Account__c);
            }
            
            if(setAccountId != null && setAccountId.size() > 0){
                List<BillingContract__c> listContractToBill = [SELECT Id,AccountName__c FROM BillingContract__c WHERE AccountName__c IN: setAccountId];
                
                if(listContractToBill != null && !listContractToBill.isEmpty()){
                    for(BillingContract__c objContractToBill : listContractToBill){
                        setContractIds.add(objContractToBill.Id);
                    }
                }
            }
        }
        
        setContractIds.add(wizObject.contractId);
        List<Id> listContractId = new List<Id>();
        
        if(setContractIds != null && setContractIds.size() > 0){
            listContractId.addAll(setContractIds);
        }
        if(setContractIdsUpdatedBasedOnSI != null && setContractIdsUpdatedBasedOnSI.size() > 0){
            listContractId.addAll(setContractIdsUpdatedBasedOnSI);
        }
        for(Id objId : listContractId){
            strContractIds += ';' + String.valueOf(objId);
        }
        strContractIds = strContractIds.removeStart(';');
        mapObject2Id.put('contractIdList', strContractIds);
        mapObject2Id.put('contractId', String.valueOf(wizObject.contractId));
        mapObject2Id.put('debtOnLocation', String.valueOf(wizObject.debtOnLocation));
        mapObject2Id.put('wizBillCalculationId', String.valueOf(wizObject.wizBillCalculationId));
        mapObject2Id.put('locationId', String.valueOf(wizObject.location.Id));
        
        return mapObject2Id;
        //return wizObject.contractId;
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         String - occupancy type
    @return        List<LocationOccupant__c>
    @description   This method is to update previous occupier details
    **********************************************************************************************/
    public Static List<LocationOccupant__c> updatePreviousOccupier(String occType) {
        
        Set<Id> setContractIdsUpdated = new Set<Id>();
        
        List<LocationOccupant__c> listTenantlocationOccupantsToMoveOut = new List<LocationOccupant__c>();
        if (wizObject.locationOccupantsToMoveOut != null) {
            wizObject.locationOccupantsToMoveOut = (List<LocationOccupant__c>) (GlUt_FieldSecurity.cleanseFields(wizObject.locationOccupantsToMoveOut, false));
            
            for(LocationOccupant__c objLocOcc : wizObject.locationOccupantsToMoveOut){
                if(occType == Label.CuAp_AUMoveInOccType || occType == Label.CuAp_AUMoveInOccTypeLandlord){ //Tenant or Landlord
                    if(objLocOcc.OccupancyType__c == occType){
                        listTenantlocationOccupantsToMoveOut.add(objLocOcc);
                    }
                }
                else if(occType == Label.CuAp_AUMoveInOccTypeOwner){
                    listTenantlocationOccupantsToMoveOut.add(objLocOcc);
                }
            }
            
            if(!listTenantlocationOccupantsToMoveOut.isEmpty()){
                listTenantlocationOccupantsToMoveOut = (List<LocationOccupant__c>) GlUt_FieldSecurity.cleanseFields(listTenantlocationOccupantsToMoveOut, false);
                update listTenantlocationOccupantsToMoveOut;
            }
        }
        //  End previous Tenant Service Items
        if(!listTenantlocationOccupantsToMoveOut.isEmpty()){
            if(occType == Label.CuAp_AUMoveInOccType ){ // Tenant
                setContractIdsUpdated = GlUt_AUServiceItemUtilities.endTenantServiceItemAtSupplyAtLocation(wizobject.location.Id, wizObject.moveOutDate, occType); 
            }
            if(occType == Label.CuAp_AUMoveInOccTypeOwner || occType == Label.CuAp_AUMoveInOccTypeLandlord){ //Owner or Landlord
                Map<Id,Date> mapPreviousOccContract2LastBillItemEndDate = GlUt_AUServiceItemUtilities.endOwnerAndLandlordServiceItemAtLocation(wizobject.location.Id, wizObject.moveOutDate, occType);
                
                if(mapPreviousOccContract2LastBillItemEndDate != null && mapPreviousOccContract2LastBillItemEndDate.keySet().size() > 0){
                    lastBillItemEndDate = mapPreviousOccContract2LastBillItemEndDate.values()[0];
                    previousOccupantContractId = (new list<Id>(mapPreviousOccContract2LastBillItemEndDate.keySet())[0]);
                }
            }
        }
        setContractIdsUpdatedBasedOnSI.addAll(setContractIdsUpdated);
        return listTenantlocationOccupantsToMoveOut;
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         null
    @return        void
    @description   This method is to update owner details
    **********************************************************************************************/
    public Static void updateOwnerDetails() {
        
        Set<Id> setContractIdsUpdated = new Set<Id>();
        List<LocationOccupant__c> listOwnerLocOcc = new List<LocationOccupant__c>();
        
        listOwnerLocOcc = [select Id,Name,OccupancyType__c 
                          FROM LocationOccupant__c 
                          WHERE Location__c =:wizObject.location.ID  
                          AND StartDate__c <: wizObject.moveInDate
                          AND (EndDate__c >=: wizObject.moveInDate OR EndDate__c = null) 
                          AND OccupancyType__c =: Label.CuAp_AUMoveInOccTypeOwner];
        
        if(!listOwnerLocOcc.isEmpty()){
            for(LocationOccupant__c objOwnerLocOcc : listOwnerLocOcc){
                objOwnerLocOcc.OccupancyType__c = Label.CuAp_AUMoveInOccTypeLandlord;
                //objOwnerLocOcc.Primary__c = false;
            }
            listOwnerLocOcc = (List<LocationOccupant__c>) GlUt_FieldSecurity.cleanseFields(listOwnerLocOcc, false);
            update listOwnerLocOcc;
        }
        //End owner Service Items
        setContractIdsUpdated = GlUt_AUServiceItemUtilities.endOwnerServiceItemAtSupplyAtLocation(wizobject.location.Id, wizObject.moveOutDate);  
        setContractIdsUpdatedBasedOnSI.addAll(setContractIdsUpdated);
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         null
    @return        void
    @description   This method is to create\update billing contract
    **********************************************************************************************/
    public Static void createOrUpdateContract() {
        
        Boolean isHHAccount = GlUt_AccountUtilities.isHHAccount(wizObject.accountId);       // true if account = Household account
        Boolean isStaleAccount = GlUt_AccountUtilities.isStaleAccount(wizObject.accountId);     // true if account has no active location occupants
       
        for (Location__c location : [select Id, 
                                     Street__c, 
                                     City__c, 
                                     State__c, 
                                     PostalCode__c, 
                                     Country__c,
                                     AuDpid__c
                                     from Location__c
                                     where Id = :wizObject.location.Id]) {
                                         wizObject.location = location;                         
                                     }
        
        // if the account billing/shipping addresses are blank,
        // or if it's a stale HH Account, populate with location address      
        Account accountAddress;
        Boolean updateAccount = false;
        //List<Contact> contactList = new List<Contact>();
        List<Account> accountList = new List<Account>();
        List<Contact> contactList =  [Select Id, Name, MailingAddress, MailingCity, MailingStreet, MailingState,MailingPostalCode  from Contact Where AccountId =:wizObject.accountId];
        SupplyPoint__c supplyPointList = [select Id, Read_Frequency__c from SupplyPoint__c where Location__c =:wizObject.location.ID order by CreatedDate limit 1];
        for (Account account : [SELECT Id, AuDpid__c,BillingAddress,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingAddress, 
                                ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry  FROM Account WHERE Id = :wizObject.accountId]) {
                                    
                                    //List<Contact> contactList =  [Select Id, Name, MailingAddress, MailingCity, MailingStreet, MailingState,MailingPostalCode  from Contact Where AccountId =:account.Id ];                   
                                    if (account.BillingAddress == null || (isHHAccount && isStaleAccount)) {
                                        account.BillingStreet = wizObject.location.Street__c; 
                                        account.BillingCity = wizObject.location.City__c;
                                        account.BillingState = wizObject.location.State__c;
                                        account.BillingPostalCode = wizObject.location.PostalCode__c;
                                        account.BillingCountry = wizObject.location.Country__c;
                                        account.AuDpid__c = wizObject.location.AuDpid__c;
                                        updateAccount = true;
                                    }
                                    if(account.ShippingAddress == null || (isHHAccount && isStaleAccount)) {
                                        account.ShippingStreet = wizObject.location.Street__c; 
                                        account.ShippingCity = wizObject.location.City__c;
                                        account.ShippingState = wizObject.location.State__c;
                                        account.ShippingPostalCode = wizObject.location.PostalCode__c;
                                        account.ShippingCountry = wizObject.location.Country__c;
                                        account.AuDpid__c = wizObject.location.AuDpid__c;
                                        updateAccount = true;
                                    }
                                    /*if(account.Contacts.size() > 0 ){
                                        for(Contact objContact : account.Contacts){
                                        objContact.MailingStreet = wizObject.location.Street__c;
                                        objContact.MailingCity = wizObject.location.City__c;
                                        objContact.MailingState = wizObject.location.State__c;
                                        objContact.MailingPostalCode = wizObject.location.PostalCode__c;
                                        objContact.MailingCountry = wizObject.location.Country__c;
                                        contactList.add(objContact);
                                        }
                                     }*/
                                    if (updateAccount) {
                                        accountList.add(account);
                                    }
                                    accountAddress = account;
                                }
        
        
        if(!accountList.isEmpty()){ 
            accountList = (List<Account>) GlUt_FieldSecurity.cleanseFields(accountList, false);
            update accountList;                             
        }           
        if(contactList != null && !contactList.isEmpty()){
            for(integer i =0 ; i < contactList.size(); i++){
                contactList[i].MailingStreet = wizObject.location.Street__c;
                contactList[i].MailingCity = wizObject.location.City__c;
                contactList[i].MailingState = wizObject.location.State__c;
                contactList[i].MailingPostalCode = wizObject.location.PostalCode__c;
                contactList[i].MailingCountry = wizObject.location.Country__c;
            }
            contactList = (List<Contact>) GlUt_FieldSecurity.cleanseFields(contactList, false);
            update contactList;     
        }    
        if (wizObject.contractId == null) {
            // create a new contract
            BillingContract__c contract = new BillingContract__c(AccountName__c = wizObject.accountId, 
                                                                 
                                                                 // address defaults to account billing address
                                                                 BillingStreet__c = accountAddress.BillingStreet, 
                                                                 BillingCity__c = accountAddress.BillingCity, 
                                                                 BillingState__c = accountAddress.BillingState, 
                                                                 BillingPostalCode__c = accountAddress.BillingPostalCode, 
                                                                 BillingCountry__c = accountAddress.BillingCountry, 
                                                                 BillingAuDpid__c = accountAddress.AuDpid__c, 
                                                                 AlternativeAuDpid__c = accountAddress.AuDpid__c, 
                                                                 // other contract defaults
                                                                 //BillingMethod__c = GlUt_Constants.DEFAULT_BILLING_METHOD, // GG- should be defaul from picklist field 
                                                                 //  BillingFrequency__c = GlUt_Constants.DEFAULT_BILLING_FREQUENCY,    //VS- Commented   AT-1994
                                                                 BillingFrequency__c =   (supplyPointList != null && supplyPointList.Read_Frequency__c != null) ? supplyPointList.Read_Frequency__c : GlUt_Constants.DEFAULT_BILLING_FREQUENCY,   //AT-1994
                                                                 BillTemplate__c = GlUt_ContractUtilities.getDefaultBillTemplateId()
                                                                );
           
            // add the household lookup for HH Accounts only
            if (isHHAccount) {
                contract.HouseholdBilling__c = wizObject.location.Id ;
            }
            contract.EligibleforBudgetPlan__c = checkEligibleforBudgetPlan(wizObject.location.Id); //AT-3777
           
            contract = (BillingContract__c) GlUt_FieldSecurity.cleanseFields(contract, false);
            if(wizObject.locationOccupantsToMoveOut != null) {
                Set<Id> locationOccupantContractIdSet  = getLocationOccupantContractId();
                If(locationOccupantContractIdSet != null) 
                {
                    for(Id contractObj   : locationOccupantContractIdSet)
                    {
                        BillEvent__c moveOutBillEvent = new BillEvent__c(EventType__c       = CuAp_Constants.MOVEOUT, 
                                                                         Status__c          = CuAp_Constants.PENDINGBILLEVENTSTATUS,
                                                                         BillingContract__c = contractObj);     
                        listMoveInOutBillEvent.add(moveOutBillEvent) ;
                    }
                }
            }  
            contract = (BillingContract__c) GlUt_FieldSecurity.cleanseFields(contract, false);
            insert contract;
            wizObject.contractId = contract.Id;
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         wizObject
    @return        void
    @description   This method is to create new service items
    **********************************************************************************************/
    public Static void createNewServicesAndItems() {
        
        GlUt_AUContractUtilities.AddServiceItemsToContract(wizObject.accountId, 
                                                         wizObject.contractId, 
                                                         lastBillItemEndDate != null ? lastBillItemEndDate.addDays(1) : wizObject.moveInDate, 
                                                         listAvailService2StartDate,
                                                         wizObject.availableBundles, 
                                                         wizObject.selectedServiceItems, 
                                                         wizObject.selectedSundryItems, 
                                                         wizObject.moveInReadings,
                                                         wizObject.selectedOccType);
        
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         null
    @return        void
    @description   This method is to create new occupancy records
    **********************************************************************************************/
    public Static void createNewOccupancyRecords() {
        
        if (wizObject.locationOccupantToMoveIn != null) {
            wizObject.locationOccupantToMoveIn = (LocationOccupant__c) GlUt_FieldSecurity.cleanseFields(wizObject.locationOccupantToMoveIn, false);
            insert wizObject.locationOccupantToMoveIn;
        }
        // insert the additional move in location occupants 
        if (wizObject.additionalLocationOccupants != null) {
            wizObject.additionalLocationOccupants = (List<LocationOccupant__c>) (GlUt_FieldSecurity.cleanseFields(wizObject.additionalLocationOccupants, false));
            insert wizObject.additionalLocationOccupants;
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         null
    @return        void
    @description   This methos is to save move in readings came from wizard
    **********************************************************************************************/
    public Static void saveMoveInReadingRecords() {
        
        if (wizObject.moveInReadings != null) {
            wizObject.moveInReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(wizObject.moveInReadings, false);                
            
            List<Reading__c> listMoveInReadingsToInsert = new List<Reading__c>();
            List<LocationOccupant__c> listLocOccOnLocation = [SELECT Id FROM LocationOccupant__c WHERE Location__c =: wizObject.locationId];
            
            for(Reading__c objReading: wizObject.moveInReadings){
                //It means there are only 2 Loc Occ i.e. Owner and new Tenant. So don't create move out reading
                if(listLocOccOnLocation != null && !listLocOccOnLocation.isEmpty() && listLocOccOnLocation.size() == 2){
                    if(objReading.ReadingType__c != Label.CuAp_ReadingReadingTypeMoveOut){
                        listMoveInReadingsToInsert.add(objReading);
                    }
                }
                else{
                    listMoveInReadingsToInsert.add(objReading);
                }
            }
            listMoveInReadingsToInsert = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listMoveInReadingsToInsert, false);
            insert listMoveInReadingsToInsert;
        }    
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         null
    @return        void
    @description   This method is to sebd welcome letter
    **********************************************************************************************/
    public Static void sendWelcomeLetter() {
        
        if(wizObject.emailSend != null && wizObject.emailSend == true){  
            
            // SupplyPoint Record...to check Locations is measured or unmeasured
            List<SupplyPoint__c> measuredsupplyPointList = new List<SupplyPoint__c>(); 
            String queryFilter = ' WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = \'' + wizObject.location.Id + '\'' +
                ' AND ' + GlUt_APIConstantsSupplyPoint.MEASUREDAPINAME + ' = true '; 
            measuredsupplyPointList = (List<SupplyPoint__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                SPFieldsList,                   
                                                                                                queryFilter);
           
            String templateName;
            if(wizObject.selectedOccType == Label.CuAp_AUMoveInOccType){
                templateName = Label.CuAp_AUMoveInTenantLetter;
            }
            else if(wizObject.selectedOccType == Label.CuAp_AUMoveInOccTypeOwner){
                templateName = Label.CuAp_AUMoveInOwnerLetter;
            }
            else if(wizObject.selectedOccType == Label.CuAp_AUMoveInOccTypeLandlord){
                templateName = Label.CuAp_AUMoveInLandlordLetter;
            }
            
            Id userId = GlUt_AccountUtilities.getContactByCustomSetting();              
            if(userId != null){
                GlUt_SendEmail emailUtil = new GlUt_SendEmail();
                emailUtil.targetObjectId(userId);
                emailUtil.TemplateName(templateName);
                emailUtil.WhatId(wizObject.accountId);
                emailUtil.SaveAsActivity(true);
                emailUtil.senderDisplayName(Label.CuAp_SenderDisplayName);      
                emailUtil.sendEmail();
            }
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         null
    @return        void
    @description   This method is to create bill event records
    **********************************************************************************************/
    public Static void createBillingEventRecords() {
        
        if(wizObject.contractId != null) {  
            BillEvent__c moveInBillEvent = new BillEvent__c(EventType__c       = CuAp_Constants.MOVEIN, 
                                                            Status__c          = CuAp_Constants.PENDINGBILLEVENTSTATUS,
                                                            BillingContract__c = wizObject.contractId);         
            listMoveInOutBillEvent.add(moveInBillEvent) ;
            if(!listMoveInOutBillEvent.isEmpty())   {
                listMoveInOutBillEvent = (List<BillEvent__c>) GlUt_FieldSecurity.cleanseFields(listMoveInOutBillEvent, false); 
                Database.insert(listMoveInOutBillEvent) ;
            }
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @param         
    @return        void
    @description   This method is to create transfer or return credit if any on contract
    **********************************************************************************************/
    public Static void transferDebtOrCredit() {
        
        Id accountId;
        BillingContract__c oldContract;
        for(LocationOccupant__c objLocOcc : wizObject.locationOccupantsToMoveOut){
            if(objLocOcc.OccupancyType__c != Label.CuAp_AUMoveInOccType){
                accountId = objLocOcc.Account__c;
                break;
            }
        }
        if(accountId != null){
            oldContract = [SELECT Id, AccountName__c, Status__c, Balance__c FROM BillingContract__c WHERE AccountName__c =: accountId LIMIT 1];
        }
        if(wizObject.debtOnLocation != null && wizObject.debtOnLocation > 0){
            Id billCalculationId;
            billCalculationId = createBillCalculation(wizObject.contractId);
            wizObject.wizBillCalculationId = billCalculationId;
        }
        else if(wizObject.creditAmountOnContract > 0 && wizObject.creditAmountToTransfer > 0){
            Payment__c newPayment = new Payment__c(
                Account__c = wizObject.accountId, 
                BillingContract__c =  wizObject.contractId,      
                Amount__c = wizObject.creditAmountToTransfer
            );
            PyAp_RefundTransferCreditUtility.transferCredit(newPayment, oldContract);
        }
    }
    
    /******************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @parameters    String billCalcId, String contractId, String locationId
    @return        String - response code 
    @description   This method is to call out in case of debt on location
    *******************************************************************************/
    @AuraEnabled
    public static String debtTransferCallOut(String billCalcId, String contractId, String locationId){
        
        String responseCode; 
        return responseCode = LoAp_DebtTransferCtrlr.transferDebts(locationId, contractId, Label.CuAp_AUMoveInDebtTransferReason, billCalcId);
    }
    
    /******************************************************************************
    @author        Echo: Tarun Gupta
    @date          25-Oct-2018
    @parameters    String contractId
    @return         BillCalculation Id
    @description    This method create  bill calculation record and return id 
    *******************************************************************************/
    @AuraEnabled
    public static Id createBillCalculation(string contractId){
        BillCalculation__c billCalculationObj = GlUt_BillCalculationUtilities.createBillCalculation(contractId,Label.GlUt_Transfer,Label.BlIn_BillCalculationStatusNew);
        return billCalculationObj.Id;
    }

    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           24 Oct 2018
    @param         List<Id> LocationId
    @return        true / false
    @description   Returns True if there is any active Supply Point Device 
    **********************************************************************************************/
    public Static Boolean checkEligibleforBudgetPlan(Id LocationId) {
        Set<Id> supplyPointIdSet = new Set<Id>();
        Boolean isEligibleForBudgetPlan = false;
        
        for(SupplyPoint__c objSupplyPoint : [SELECT Id FROM SupplyPoint__c WHERE Location__c =: LocationId AND Measured__c = TRUE]) {
            supplyPointIdSet.add(objSupplyPoint.Id);
        }
        if(!supplyPointIdSet.isEmpty()) {
            for(SupplyPointDevice__c objSPD : [SELECT Id FROM SupplyPointDevice__c WHERE SupplyPoint__c IN: supplyPointIdSet AND Active__c = TRUE]) {
                isEligibleForBudgetPlan = true;
                break;
            }
        }
        return isEligibleForBudgetPlan;
    }
}