/******************************************************************************
@author         Accenture: Patrick Dixon
@date           08 Nov 2017
@description    Component controller for move in wizard
*******************************************************************************/
public with sharing class CuAp_MoveInWizardComponentCtrlr {
     
    private static final String CLASS_NAME = 'CuAp_MoveInWizardComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static WizardObject wizObject;
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           08 Nov 2017
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
        
        @TestVisible private Id recordId;       // DEPRECATED - do not use
        @TestVisible private Id accountId;
        @TestVisible private Location__c location;
        @TestVisible private Id locationId;     // DEPRECATED - use location
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
        @TestVisible private Boolean emailSend;                         // AT-3157  Core7b  
    }
    
    private static List<String> SPFieldsList;    
    static{
        SPFieldsList = new List<String>();         
        SPFieldsList.add(GlUt_APIConstantsSupplyPoint.ID);                  
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           30 Nov 2017
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void updateWizardProperties(String wizardprop) {
        system.debug('50000000000------------wizardprop  ' + wizardprop);
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        system.debug(DEBUG + 'wizardprop: ' + wizardprop);
        
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserialize(wizardprop, WizardObject.class);
        system.debug(DEBUG + 'wizObject: ' + wizObject);
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           13 Nov 2017
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
        System.debug(DEBUG + 'status: ' + status);
        return status;
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi   AT-2480
    @date           31 May 2018
    @param          LocationOccupant__c
    @return         Set<Id>
    @description    returns location occupant active contract Id
    *******************************************************************************/
    public static Set<Id> getLocationOccupantContractId() {
        Set<Id> locationOccupantIdSet = new Set<Id>();
        List<BillingContract__c> contractList  = new List<BillingContract__c>();
        Set<Id> contractIdSet = new Set<Id>();
        List<Service__c> serviceLists = new List<Service__c>();
        
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
                                                             from LocationOccupant__c 
                                                             where Id IN: locationOccupantIdSet limit 1];
                
                if(!locationOccList.isEmpty())
                {
                    /* AT-3911 (FR), AT-3912                                                                 
                     * 11 October 2018
                     * Ankit Gangwani        
                     * Earlier the location has been identified with BillingContract__c.HouseholdBilling__c, 
                     * now the location will be identified with BillingContract__c --> Service__c --> SupplyPoint__c --> Location__c 
                     */
                    serviceLists = [SELECT Id,
                                    BillingContract__c,
                                    ServiceStartDate__c,
                                    ServiceEndDate__c,
                                    SupplyPoint__r.Location__c 
                                    FROM Service__c 
                                    WHERE SupplyPoint__r.Location__c = :locationOccList[0].location__c];
                    
                    if(!serviceLists.isEmpty()){
                        for(Service__c objService : serviceLists){
                            if(objService.ServiceStartDate__c >= locationOccList[0].StartDate__c && (objService.ServiceEndDate__c == null || (objService.ServiceEndDate__c != null && objService.ServiceEndDate__c <= locationOccList[0].EndDate__c))){
                                contractIdSet.add(objService.BillingContract__c);
                                break;                                   
                            }
                        }
                    } 
                    /* AT-3912 --  Ended -- */
                }                
            }
            
            if (!contractIdSet.isEmpty())
                return contractIdSet;
        }
        return null;
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           17 Nov 2017
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
    @revision       Echo: Sudhir Kumar
                    AT-2480: Update Customer Moves Wizard - BillEvent record creation
                    AT-4532: For multiple contracts i.e. Move out + Move In contracts
    *******************************************************************************/
    @AuraEnabled
    public static List<Id> moveIn(String wizardprop) { // Changes for AT-4532 Starts/Ends here
        list<BillEvent__c> listMoveInOutBillEvent = new list<BillEvent__c>() ;
        List<Id> contractIdList = new List<Id>();   // Changes for AT-4532 Starts/Ends here

        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            updateWizardProperties(wizardprop);
            List<Reading__c> moveoutReadingList = new List<Reading__c>();
            
            Boolean isHHAccount = GlUt_AccountUtilities.isHHAccount(wizObject.accountId);       // true if account = Household account
            Boolean isStaleAccount = GlUt_AccountUtilities.isStaleAccount(wizObject.accountId);     // true if account has no active location occupants
            Date moveOutReadingDate;   // AT-2276
            
            if (wizObject.moveInReadings != null) {
                wizObject.moveInReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(wizObject.moveInReadings, false);
            
                for(Reading__c objReading : wizObject.moveInReadings){  
                    
                    if(objReading.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveOut){
                        moveoutReadingList.add(objReading);
                        moveOutReadingDate = objReading.ReadingDate__c;    // AT-2276
                    }                            
                }        
            }  
            
            Integer daysBetween = wizObject.moveOutDate.daysBetween(wizObject.moveInDate);            
           
            // At-2211, Void Contract should be created if the number of days in between movein date of new occupier and moveout date of previous occupier has greater than or equal to 2 days.
            if (daysBetween > 1 && moveoutReadingList.size() > 0) {
                
                // create a void contract using default services and service items
                Id voidId = GlUt_ContractUtilities.createVoidContract(wizObject.location.Id, wizObject.moveOutDate.addDays(1), moveoutReadingList, wizObject.moveInDate);
                
                // suppress the void contract
                GlUt_SuppressionUtilities.suppressVoidContract(voidId, wizObject.moveOutDate.addDays(1));
            }             
          
            // get the location  AT-2276 starts...          
            Map<Id,Location__c> locationMap = new Map<Id,Location__c>();
            for (Location__c objLocation : [SELECT Id,VoidStartDate__c 
                                         FROM Location__c
                                         WHERE Id = :wizObject.location.Id]) {              
                locationMap.put(objLocation.Id,objLocation);                            
            }  
            
            Date voidEndReadingDate;  
            List<Reading__c> newMoveInReadingsList = new List<Reading__c>();
            if (wizObject.moveInReadings != null) {
                for(Reading__c objReading : wizObject.moveInReadings){  
                    if(objReading.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidEnd &&
                       (locationMap.get(wizObject.location.Id).VoidStartDate__c != null && objReading.ReadingDate__c < locationMap.get(wizObject.location.Id).VoidStartDate__c) ){
                       // || (locationMap.get(wizObject.location.Id).VoidStartDate__c == null && objReading.ReadingDate__c.addDays(-1)  == moveOutReadingDate))){     // commented under AT-4271                            
                            voidEndReadingDate = wizObject.moveInDate;
                            objReading.ReadingDate__c = wizObject.moveInDate;                         
                        }
                    newMoveInReadingsList.add(objReading);                
                } 
            }
            if(newMoveInReadingsList.size() > 0) 
                wizObject.moveInReadings = newMoveInReadingsList.clone();
            
            if(voidEndReadingDate != null){
                // set the location as occupied && AT-2276, Add (-1) days to movein date so that location will occupied one day early.
                GlUt_LocationUtilities.setLocationOccupied(wizObject.location, voidEndReadingDate);
            }   //AT-2276 end...
            else{
                // update Void End and Start Date to Null, if there is 1 day gap in retrospective MoveIn-MoveOut AT-4271
                if(moveOutReadingDate != null && moveOutReadingDate.daysBetween(wizObject.moveInDate) <= 1 && wizObject.location != null){ 
                    Location__c objLocation = wizObject.location;
                    objLocation.VoidEndDate__c = null;
                    objLocation.VoidStartDate__c = null;
                    //update location
                    objLocation = (Location__c) GlUt_FieldSecurity.cleanseFields(objLocation, false);  
                    update objLocation;
                }
                else{
                    GlUt_LocationUtilities.setLocationOccupied(wizObject.location, wizObject.moveInDate.addDays(-1));
                }
                
                // set the location as occupied && AT-2276, Add (-1) days to movein date so that location will occupied one day early.
                //if(daysBetween > 1) // AT-2276, Revised, Ankit Gangwani, Void End Date will only update if there is more than 1 day gap in between New Move-In Occupier and Previously Move-Out Occupied
                 
                // AT-2276, Revised, Ankit Gangwani, Void End Date will only update if there is more than 1 day gap in between New Move-In Occupier and Previously Move-Out Occupied
               /* */
            }
           
            // must move out location occupants before moving in to avoid record level validation rule failure
            // update the move out location occupants 
            if (wizObject.locationOccupantsToMoveOut != null) {
                wizObject.locationOccupantsToMoveOut = (List<LocationOccupant__c>) (GlUt_FieldSecurity.cleanseFields(wizObject.locationOccupantsToMoveOut, false));
                update wizObject.locationOccupantsToMoveOut;
            }
                            
            // insert the move in primary location occupant 
            if (wizObject.locationOccupantToMoveIn != null) {
                wizObject.locationOccupantToMoveIn = (LocationOccupant__c) GlUt_FieldSecurity.cleanseFields(wizObject.locationOccupantToMoveIn, false);
                insert wizObject.locationOccupantToMoveIn;
            }
            
            // insert the additional move in location occupants 
            if (wizObject.additionalLocationOccupants != null) {
                wizObject.additionalLocationOccupants = (List<LocationOccupant__c>) (GlUt_FieldSecurity.cleanseFields(wizObject.additionalLocationOccupants, false));
                insert wizObject.additionalLocationOccupants;
            }
            
            // Moving this code after the location occupants are inserted to have the loc occ created at the time of ADU Calculation
            // add move in, move out and current readings (require move in reading Ids to link to services later)
            if (wizObject.moveInReadings != null) {
                wizObject.moveInReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(wizObject.moveInReadings, false);                
                insert wizObject.moveInReadings;
            }            

            // force a move out by end dating all the open service items at the location 
            // (which ends the move out/void contract if there are no other open service items)
            GlUt_ServiceItemUtilities.endSupplyAtLocation(wizobject.location.Id, wizObject.moveOutDate);
            
            //place the code for AT-2211 to line no. 190-212          

            // get the location address
            for (Location__c location : [select Id, 
                                            Street__c, 
                                            City__c, 
                                            State__c, 
                                            PostalCode__c, 
                                            Country__c
                                        from Location__c
                                        where Id = :wizObject.location.Id]) {
                
                wizObject.location = location;                          
            }
            
            //get the first Supply Point Frequency AT-1994 
            SupplyPoint__c supplyPointList = [select Id, Read_Frequency__c from SupplyPoint__c where Location__c =:wizObject.location.ID order by CreatedDate limit 1];
            
            // if the account billing/shipping addresses are blank,
            // or if it's a stale HH Account, populate with location address
            Account accountAddress;
            Boolean updateAccount = false;
          
            
            for (Account account : [select Id, 
                                            BillingAddress, 
                                            BillingStreet, 
                                            BillingCity, 
                                            BillingState, 
                                            BillingPostalCode, 
                                            BillingCountry, 
                                            ShippingAddress, 
                                            ShippingStreet, 
                                            ShippingCity, 
                                            ShippingState, 
                                            ShippingPostalCode, 
                                            ShippingCountry
                                        from Account
                                        where Id = :wizObject.accountId]) {
                // AT-2214- Added by Dependra                            
                List<Contact> contactList =  [Select Id, Name, MailingAddress, MailingCity, MailingStreet, MailingState,MailingPostalCode from Contact Where AccountId =:account.Id ];                   
                if (account.BillingAddress == null || (isHHAccount && isStaleAccount)) {
                    account.BillingStreet = wizObject.location.Street__c; 
                    account.BillingCity = wizObject.location.City__c;
                    account.BillingState = wizObject.location.State__c;
                    account.BillingPostalCode = wizObject.location.PostalCode__c;
                    account.BillingCountry = wizObject.location.Country__c;
                    updateAccount = true;
                }

                if (account.ShippingAddress == null || (isHHAccount && isStaleAccount)) {
                    account.ShippingStreet = wizObject.location.Street__c; 
                    account.ShippingCity = wizObject.location.City__c;
                    account.ShippingState = wizObject.location.State__c;
                    account.ShippingPostalCode = wizObject.location.PostalCode__c;
                    account.ShippingCountry = wizObject.location.Country__c;
                    updateAccount = true;
                }
                // AT-2214- Added by Dependra
                if(!contactList.isEmpty()){
                    for (integer i = 0; i <= contactList.size() - 1; i++) {
                        contactList[i].MailingStreet = wizObject.location.Street__c;
                        contactList[i].MailingCity = wizObject.location.City__c;
                        contactList[i].MailingState = wizObject.location.State__c;
                        contactList[i].MailingPostalCode = wizObject.location.PostalCode__c;
                        contactList[i].MailingCountry = wizObject.location.Country__c;
                    }                   
                }                             
                if (updateAccount) {
                    account = (Account) GlUt_FieldSecurity.cleanseFields(account, false);
                    update account;
                }
                if(!contactList.isEmpty()){ // AT-2214- Added by Dependra
                   update contactList;                             
                }                             
                accountAddress = account;
            }
            // create the new contract or add services to an existing contract
            if (wizObject.contractId == null) {
            // create a new contract
            BillingContract__c contract = new BillingContract__c(AccountName__c = wizObject.accountId, 
                                                                 
                                                                 // address defaults to account billing address
                                                                 BillingStreet__c = accountAddress.BillingStreet, 
                                                                 BillingCity__c = accountAddress.BillingCity, 
                                                                 BillingState__c = accountAddress.BillingState, 
                                                                 BillingPostalCode__c = accountAddress.BillingPostalCode, 
                                                                 BillingCountry__c = accountAddress.BillingCountry, 
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
                Set<Id> locationOccupantContractIdSet  = getLocationOccupantContractId(); // Changes for AT-4532 Starts/Ends here
                // Create Bill Event of Type for  'Move Out' AT-2480
                if(wizObject.locationOccupantsToMoveOut != null) {
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
                
                insert contract;
                wizObject.contractId = contract.Id;
                /* Changes for AT-4532 Starts here*/
                contractIdList.add(contract.Id); // Collection of new contract
                if(locationOccupantContractIdSet != null)
                    contractIdList.addAll(locationOccupantContractIdSet); // Collection of existing location occupant move-out contract + new move in loc occ contract.
                /* Changes for AT-4532 Ends here*/
            }
            //AT-3236
            GlUt_ContractUtilities.AddServiceItemsToContract(wizObject.accountId, 
                                                             wizObject.contractId, 
                                                             wizObject.moveInDate, 
                                                             wizObject.selectedServices, 
                                                             wizObject.availableBundles, 
                                                             wizObject.selectedServiceItems, 
                                                             wizObject.selectedSundryItems, 
                                                             wizObject.moveInReadings,
                                                             null); //AT-4038
            // Create Bill Event of Type 'Move In' AT-2480
            if(wizObject.contractId != null) {                                                              
                
                BillEvent__c moveInBillEvent = new BillEvent__c(EventType__c       = CuAp_Constants.MOVEIN, 
                                                                Status__c          = CuAp_Constants.PENDINGBILLEVENTSTATUS,
                                                                BillingContract__c = wizObject.contractId);         
                listMoveInOutBillEvent.add(moveInBillEvent) ;
                
                if(!listMoveInOutBillEvent.isEmpty())   {
                    Database.insert(listMoveInOutBillEvent) ;
                }
            }
            
            // AT-3157(core7b) start... To send email to user 
            if(wizObject.emailSend != null && wizObject.emailSend == true){  
                
                // SupplyPoint Record...to check Locations is measured or unmeasured
                List<SupplyPoint__c> measuredsupplyPointList = new List<SupplyPoint__c>(); 
                String queryFilter = ' WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = \'' + wizObject.location.Id + '\'' +
                                     ' AND ' + GlUt_APIConstantsSupplyPoint.MEASUREDAPINAME + ' = true '; // AT-3174 
                measuredsupplyPointList = (List<SupplyPoint__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                    SPFieldsList,                   
                                                                                                    queryFilter);
                String templateName;
                if(measuredsupplyPointList.size() > 0)   // Measured Location
                    templateName = Label.CuAp_MeasuredLocWelcomeLetterTemplate;
                else
                    templateName =   Label.CuAp_UnmeasuredLocWelcomeLetterTemplate;                   
               
                // Id userId = CuAp_MoveInWizardComponentCtrlr.getContactByCustomSetting();   
                Id userId = GlUt_AccountUtilities.getContactByCustomSetting();
                
                system.debug('userId******* '   +  userId);
                if(userId != null){
                    //use the  util class to send an email
                    GlUt_SendEmail emailUtil = new GlUt_SendEmail();
                    emailUtil.targetObjectId(userId);
                    emailUtil.TemplateName(templateName);
                    emailUtil.WhatId(wizObject.accountId);
                    emailUtil.SaveAsActivity(true);
                    emailUtil.senderDisplayName(Label.CuAp_SenderDisplayName);      
                    emailUtil.sendEmail();
                     system.debug('email sent******* '   +  emailUtil);
                }
            }           
            // AT-3157 to send email to user end
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
            
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return contractIdList; // Changes for AT-4532 Starts/Ends here
        
    }
    /******************************************************************************
    @author         Echo: Neha R.
    @date           26 July 2018
    @param           
    @return         Id 
    @description    Method is used to Get the contact id based on email address which we are getting from custom setting.
                    // AT-3157 core7b
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
    
    /**********************************************************************************************
    @author        Echo: Vivek Sethi  AT-3777
    @date          25-Sep-2018
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